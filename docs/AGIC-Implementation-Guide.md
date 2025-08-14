# AGIC (Application Gateway Ingress Controller) 實作指南

## 概述

本文檔記錄從地端 Kubernetes 遷移至 Azure AKS 後，實作 Application Gateway Ingress Controller (AGIC) 的完整過程，包含遇到的問題和解決方案。

## 專案背景

- **目標**：將 Flask 應用程式從 LoadBalancer Service 改為透過 AGIC 對外提供服務
- **架構**：AKS + Application Gateway + AGIC addon
- **網路**：Azure CNI + ClusterIP Service + Application Gateway Ingress

## 實作步驟

### 1. 基礎設施準備

#### 1.1 Terraform 模組更新

**Networking 模組更新**
```hcl
# terraform/modules/networking/main.tf
# 新增 Application Gateway 子網路
resource "azurerm_subnet" "agw_subnet" {
  count                = var.enable_application_gateway ? 1 : 0
  name                 = var.agw_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  address_prefixes     = var.agw_subnet_address_prefixes
}

# Application Gateway NSG
resource "azurerm_network_security_group" "agw_nsg" {
  count               = var.enable_application_gateway ? 1 : 0
  name                = "${var.agw_subnet_name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "Allow-Application-Gateway-Manager"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "65200-65535"
    source_address_prefix      = "GatewayManager"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-HTTPS"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
```

**AKS 模組更新**
```hcl
# terraform/modules/aks/main.tf
# AGIC addon 配置
dynamic "ingress_application_gateway" {
  for_each = var.enable_application_gateway ? [1] : []
  content {
    gateway_id = var.application_gateway_id
  }
}
```

**Application Gateway 模組**
```hcl
# terraform/modules/application-gateway/main.tf
resource "azurerm_application_gateway" "agw" {
  name                = var.application_gateway_name
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name     = var.sku_name
    tier     = var.sku_tier
    capacity = var.enable_autoscale ? null : var.capacity
  }

  gateway_ip_configuration {
    name      = "gateway-ip-configuration"
    subnet_id = var.subnet_id
  }

  frontend_port {
    name = "http-port"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "frontend-ip-config"
    public_ip_address_id = azurerm_public_ip.agw.id
  }

  backend_address_pool {
    name = "default-backend-pool"
  }

  backend_http_settings {
    name                  = "default-backend-http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = "default-listener"
    frontend_ip_configuration_name = "frontend-ip-config"
    frontend_port_name             = "http-port"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "default-routing-rule"
    priority                   = 1
    rule_type                  = "Basic"
    http_listener_name         = "default-listener"
    backend_address_pool_name  = "default-backend-pool"
    backend_http_settings_name = "default-backend-http-settings"
  }

  # AGIC 會管理這些設定，使用 lifecycle 忽略變更
  lifecycle {
    ignore_changes = [
      backend_address_pool,
      backend_http_settings,
      http_listener,
      request_routing_rule,
      url_path_map,
      probe
    ]
  }
}
```

#### 1.2 Environment 配置

**terraform.tfvars**
```hcl
# Application Gateway 啟用
enable_application_gateway = true
application_gateway_name = "agw-aks-dev"
agw_subnet_name         = "subnet-agw-dev"
agw_subnet_address_prefixes = ["10.0.2.0/24"]

# SKU 配置 (dev環境)
agw_sku_name  = "Standard_v2"
agw_sku_tier  = "Standard_v2"
agw_capacity  = 1

# 自動擴展
enable_agw_autoscale = true
agw_min_capacity    = 1
agw_max_capacity    = 3

# WAF 在 dev 環境關閉以節省成本
enable_agw_waf = false

# 可用區域配置
availability_zones = ["1", "2", "3"]
```

### 2. Terraform 部署

```bash
# 執行 Terraform 部署
terraform init
terraform plan
terraform apply -auto-approve
```

### 3. Service 配置調整

將 Flask Service 從 LoadBalancer 改為 ClusterIP：

```yaml
# k8s-manifests/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: py-flask-service
  namespace: py-flask-app
spec:
  type: ClusterIP  # 改為 ClusterIP，只透過 Ingress 對外存取
  ports:
  - name: http
    port: 80
    targetPort: 8087  # Flask 應用程式實際運行端口
  selector:
    app: py-flask-app
```

### 4. AGIC Ingress 配置

建立 AGIC 專用的 Ingress 資源：

```yaml
# k8s-manifests/ingress-agic.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: py-flask-agic-ip-ingress
  namespace: py-flask-app
  labels:
    app: py-flask-app
    ingress: agic-ip
  annotations:
    kubernetes.io/ingress.class: azure/application-gateway
    appgw.ingress.kubernetes.io/ssl-redirect: "false"
    appgw.ingress.kubernetes.io/health-probe-path: "/health"
    appgw.ingress.kubernetes.io/health-probe-port: "8087"
    appgw.ingress.kubernetes.io/health-probe-status-codes: "200-399"
    appgw.ingress.kubernetes.io/health-probe-interval: "30"
    appgw.ingress.kubernetes.io/health-probe-timeout: "5"
    appgw.ingress.kubernetes.io/health-probe-unhealthy-threshold: "3"
    appgw.ingress.kubernetes.io/backend-path-prefix: "/"
spec:
  rules:
  - http:  # 沒有指定 host，通過 Application Gateway 的 IP 直接存取
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: py-flask-service
            port:
              number: 80
```

### 5. AGIC Addon 啟用方式

### 方式一：透過 Terraform (本專案使用的方式)
AGIC addon 透過 Terraform 自動啟用，在 AKS 模組中配置：
```hcl
# terraform/modules/aks/main.tf
dynamic "ingress_application_gateway" {
  for_each = var.enable_application_gateway ? [1] : []
  content {
    gateway_id = var.application_gateway_id
  }
}
```

### 方式二：透過 Azure CLI
```bash
az aks enable-addons \
  --resource-group rg-aks-dev \
  --name aks-dev-cluster \
  --addons ingress-appgw \
  --appgw-id /subscriptions/{subscription-id}/resourceGroups/rg-aks-dev/providers/Microsoft.Network/applicationGateways/agw-aks-dev
```

### 方式三：透過 Azure Portal
1. 進入 Azure Portal → Kubernetes 服務
2. 選擇您的 AKS cluster (aks-dev-cluster)
3. 左側選單：**設定** → **網路** → **虛擬網路整合**
4. 在 "Application Gateway Ingress Controller" 區段點擊 **啟用**
5. 選擇現有的 Application Gateway (agw-aks-dev)
6. 點擊 **儲存** 完成設定

### 驗證 AGIC Addon 狀態
```bash
# 確認 AGIC addon 狀態
az aks show --resource-group rg-aks-dev --name aks-dev-cluster \
  --query "addonProfiles.ingressApplicationGateway.enabled"
```

## 遇到的問題與解決方案

### 問題 1: AGIC 控制器權限不足

**錯誤訊息：**
```
ErrorApplicationGatewayForbidden: The client does not have authorization to perform action 'Microsoft.Network/applicationGateways/read'
```

**解決方案：**
```bash
# 1. Resource Group Reader 權限
az role assignment create \
  --role Reader \
  --scope /subscriptions/{subscription-id}/resourceGroups/rg-aks-dev \
  --assignee {agic-identity-client-id}

# 2. Application Gateway Contributor 權限
az role assignment create \
  --role Contributor \
  --scope /subscriptions/{subscription-id}/resourceGroups/rg-aks-dev/providers/Microsoft.Network/applicationGateways/agw-aks-dev \
  --assignee {agic-identity-client-id}
```

### 問題 2: VNet 子網路權限不足

**錯誤訊息：**
```
ApplicationGatewayInsufficientPermissionOnSubnet: Client does not have permission on the Virtual Network resource to perform action Microsoft.Network/virtualNetworks/subnets/join/action
```

**解決方案：**
```bash
# 最終解決方案：給予整個 Resource Group 的 Contributor 權限
az role assignment create \
  --role "Contributor" \
  --scope /subscriptions/{subscription-id}/resourceGroups/rg-aks-dev \
  --assignee {agic-identity-client-id}
```

### 問題 3: Terraform Zones 配置衝突

**問題描述：**
Application Gateway 實際 zones 為 `["1","2","3"]`，但 terraform.tfvars 設定為 `["1","2"]`，導致 Terraform 強制重建 Application Gateway。

**解決方案：**
更新 terraform.tfvars 使其與實際配置一致：
```hcl
availability_zones = ["1", "2", "3"]
```

### 問題 4: 502 Bad Gateway

**問題分析：**
1. Flask 應用程式內部運行正常 (localhost:8087/health 返回 200)
2. Service 連接正常 (通過 ClusterIP 可以存取)
3. Application Gateway backend pool 為空
4. AGIC 控制器權限問題導致無法更新 Application Gateway 配置

**解決過程：**
1. 檢查 Flask pod 健康狀態 ✅
2. 檢查 Service endpoints ✅  
3. 檢查 AGIC 控制器日誌 → 發現權限錯誤
4. 設定正確的權限 ✅
5. 重啟 AGIC 控制器
6. 驗證 Application Gateway backend pool 已填入地址
7. 測試外部存取成功 ✅

## 最終驗證

### 成功指標

1. **AGIC addon 啟用**
```bash
az aks show --resource-group rg-aks-dev --name aks-dev-cluster \
  --query "addonProfiles.ingressApplicationGateway.enabled"
# 輸出: true
```

2. **Application Gateway 狀態**
```bash
az network application-gateway show --resource-group rg-aks-dev --name agw-aks-dev \
  --query "provisioningState"
# 輸出: "Succeeded"
```

3. **Ingress 取得 IP**
```bash
kubectl get ingress -n py-flask-app
# py-flask-agic-ip-ingress 應顯示 Application Gateway 的 Public IP
```

4. **外部存取測試**
```bash
curl http://57.158.96.178/health
# 輸出: {"service":"Flask Azure DevOps Test App","status":"healthy","timestamp":"..."}
```

### 網路架構

```
Internet → Application Gateway (57.158.96.178) → AKS Cluster → ClusterIP Service → Flask Pod (10.0.1.13:8087)
```

## 重要權限清單

AGIC Identity 需要的最小權限：

| 範圍 | 角色 | 用途 |
|------|------|------|
| Resource Group | Reader | 讀取資源群組資訊 |
| Application Gateway | Contributor | 管理 Application Gateway 配置 |
| VNet/Subnet | Network Contributor | 加入子網路和管理網路資源 |

**建議做法（生產環境）：**
為了簡化權限管理，在測試/開發環境可以直接給予 Resource Group 的 Contributor 權限。

## 網路安全設定

### Application Gateway NSG 規則

| 規則名稱 | 方向 | 優先順序 | 來源 | 目標端口 | 用途 |
|----------|------|----------|------|----------|------|
| Allow-Application-Gateway-Manager | Inbound | 100 | GatewayManager | 65200-65535 | Azure 管理流量 |
| Allow-HTTP | Inbound | 110 | * | 80 | HTTP 流量 |
| Allow-HTTPS | Inbound | 120 | * | 443 | HTTPS 流量 |

### 子網路配置

- **AKS 子網路**: 10.0.1.0/24
- **Application Gateway 子網路**: 10.0.2.0/24
- **Service CIDR**: 10.0.0.0/24
- **DNS Service IP**: 10.0.0.10

## 故障排除指令

### 檢查 AGIC 狀態
```bash
# AGIC addon 狀態
az aks show --resource-group rg-aks-dev --name aks-dev-cluster \
  --query "addonProfiles.ingressApplicationGateway"

# AGIC 控制器 Pod
kubectl get pods -n kube-system | grep ingress

# AGIC 日誌
kubectl logs -n kube-system deployment/ingress-appgw-deployment --tail=20
```

### 檢查 Application Gateway
```bash
# Application Gateway 狀態
az network application-gateway show --resource-group rg-aks-dev --name agw-aks-dev \
  --query "{name: name, state: provisioningState, publicIP: frontendIPConfigurations[0].publicIPAddress.id}"

# Backend Pool 地址
az network application-gateway show --resource-group rg-aks-dev --name agw-aks-dev \
  --query "backendAddressPools[0].backendAddresses"

# Backend 健康狀態
az network application-gateway show-backend-health --resource-group rg-aks-dev --name agw-aks-dev
```

### 檢查 Kubernetes 資源
```bash
# Ingress 狀態
kubectl get ingress -n py-flask-app -o wide

# Service Endpoints
kubectl get endpoints -n py-flask-app py-flask-service

# Pod 狀態
kubectl get pods -n py-flask-app

# 測試 Pod 內部連接
kubectl exec -n py-flask-app deployment/py-flask-app -- python3 -c "
import urllib.request
response = urllib.request.urlopen('http://localhost:8087/health')
print('Status:', response.getcode())
print('Response:', response.read().decode())
"
```

## 效能與成本考量

### 開發環境設定
- **SKU**: Standard_v2 (最基本的 v2 SKU)
- **容量**: 1 個實例（最小值）
- **自動擴展**: 1-3 個實例
- **WAF**: 關閉（節省成本）

### 生產環境建議
- **SKU**: WAF_v2 (啟用 Web Application Firewall)
- **容量**: 至少 2 個實例（高可用性）
- **自動擴展**: 2-10 個實例
- **監控**: 啟用 Azure Monitor 和 Application Insights

## 後續改進事項

1. **SSL/TLS 設定**: 配置 HTTPS 和 SSL 憑證
2. **WAF 政策**: 在生產環境啟用 Web Application Firewall
3. **監控整合**: 設定 Azure Monitor 和告警
4. **多環境管理**: dev/staging/prod 環境的配置差異化
5. **備份策略**: Application Gateway 配置的備份和還原程序

## 相關文檔

- [Azure Application Gateway Ingress Controller 官方文檔](https://docs.microsoft.com/en-us/azure/application-gateway/ingress-controller-overview)
- [AGIC 註解參考](https://azure.github.io/application-gateway-kubernetes-ingress/annotations/)
- [AKS 網路概念](https://docs.microsoft.com/en-us/azure/aks/concepts-network)
- [Terraform AzureRM Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

---

*建立日期：2025-08-14*  
*最後更新：2025-08-14*  
*維護者：DevOps Team*