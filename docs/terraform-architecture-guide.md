# Terraform 架構設計與模組分工說明

## 🎯 整體架構概念

本專案採用模組化 Terraform 架構，將基礎設施分為兩個主要層級：
- **環境層** (`environments/dev/`) - 負責完整基礎架構環境
- **模組層** (`modules/aks/`, `modules/networking/`) - 負責特定服務實作

## 📁 目錄結構與職責

```
terraform/
├── environments/
│   └── dev/                    # 開發環境 - 完整基礎架構編排
│       ├── main.tf            # 環境資源編排
│       ├── variables.tf       # 環境變數定義
│       ├── outputs.tf         # 環境輸出
│       └── terraform.tfvars   # 實際變數值
├── modules/
│   ├── aks/                   # AKS 模組 - 純 Kubernetes 叢集
│   │   ├── main.tf           # AKS 資源實作
│   │   ├── variables.tf      # AKS 變數
│   │   └── outputs.tf        # AKS 輸出
│   └── networking/            # 網路模組 - VNet/Subnet
│       ├── main.tf           # 網路資源實作
│       ├── variables.tf      # 網路變數
│       └── outputs.tf        # 網路輸出
```

## 🔧 模組分工說明

### ☸️ **AKS 模組職責** - 純 Kubernetes 叢集
**檔案位置**: `modules/aks/main.tf`

**建立的 Azure 資源:**
- AKS Cluster 本體
- System Node Pool (系統元件專用)
- User Node Pool (應用程式專用)
- Managed Identity (叢集身份)
- Role Assignments (權限設定)

**主要配置:**
```hcl
# 1. AKS 叢集基本設定
resource "azurerm_kubernetes_cluster" "aks" {
  # 基本配置：名稱、位置、K8s 版本
  # Azure CNI 網路配置
  # RBAC + Azure AD 整合
  # 自動擴展設定
}

# 2. 額外的 User Node Pool
resource "azurerm_kubernetes_cluster_node_pool" "user" {
  # 應用程式專用節點
}

# 3. 權限設定
resource "azurerm_role_assignment" "acr_pull"         # ACR 存取權限
resource "azurerm_role_assignment" "network_contributor"  # VNet 管理權限
```

### 🏗️ **DEV 環境職責** - 完整基礎架構環境
**檔案位置**: `environments/dev/main.tf`

**建立的 Azure 資源:**
- Resource Group (資源容器)
- 呼叫網路模組建立 VNet/Subnet
- 呼叫 AKS 模組建立 Kubernetes 叢集
- (未來可擴展: ACR, Log Analytics, Application Gateway)

**部署順序:**
```hcl
# 1. 基礎資源
resource "azurerm_resource_group" "main"

# 2. 網路基礎
module "networking" {
  # 建立 VNet、Subnet、NSG
}

# 3. Kubernetes 叢集
module "aks" {
  # 使用上面建立的網路資源
  subnet_id = module.networking.subnet_id
  vnet_id   = module.networking.vnet_id
}
```

## 🌐 網路配置統整

### Azure CNI 相關設定
所有網路配置都在變數中統一管理，確保一致性：

```hcl
# VNet 和 Subnet (實際的 Azure 網路資源)
vnet_address_space      = ["10.0.0.0/8"]    # VNet 大範圍
subnet_address_prefixes = ["10.0.1.0/24"]   # AKS 節點子網路

# Azure CNI 配置 (Kubernetes 內部網路)
service_cidr      = "10.0.0.0/24"     # K8s 服務網段 (不與 subnet 重疊)
dns_service_ip    = "10.0.0.10"       # DNS 服務 IP (在 service_cidr 內)
docker_bridge_cidr = "172.17.0.1/16"  # Docker 橋接網路 (完全分離)
```

## 🔍 架構優勢

### ✅ **優點:**
1. **模組重用性** - AKS 模組可被 dev/staging/prod 環境重用
2. **責任分離** - 環境管理「什麼要部署」，模組管理「如何部署」
3. **維護性** - 修改 AKS 配置時，只需更新模組
4. **擴展性** - 可輕鬆加入新的環境或模組

### ⚠️ **注意事項:**
1. **網路設定環境相關** - CNI 配置雖在 AKS 模組，但實際上很環境特定
2. **變數傳遞** - 需確保環境層正確傳遞網路資源 ID 到 AKS 模組
3. **複雜性** - 過度模組化可能增加理解和調試難度

## 🚀 實際部署流程

```bash
# 1. 進入 dev 環境目錄
cd terraform/environments/dev

# 2. 複製變數範例檔案
cp terraform.tfvars.example terraform.tfvars

# 3. 編輯變數值
# 設定 cluster_name, location, 網路配置等

# 4. 初始化 Terraform
terraform init

# 5. 檢查部署計畫
terraform plan

# 6. 執行部署
terraform apply
```

## 📊 建立的 Azure 資源清單

執行完成後，將在 Azure 上建立以下資源：

### 主要資源群組 (`rg-aks-dev`)
- Virtual Network (`vnet-aks-dev`)
- Subnet (`subnet-aks-dev`) 
- Network Security Group (`subnet-aks-dev-nsg`)
- AKS Cluster (`aks-dev-cluster`)

### AKS 管理的資源群組 (`MC_rg-aks-dev_aks-dev-cluster_eastasia`)
- Virtual Machine Scale Sets (節點池)
- Load Balancer
- Public IP
- Route Table
- Storage Account (診斷用)

**總計約 10-15 個 Azure 資源**

---

*文件建立日期: 2025-08-07*  
*專案: DS-AKS - 地端 Kubernetes 遷移至 Azure AKS*