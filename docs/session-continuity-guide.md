# Session 接續指南

**建立日期**: 2025-08-07  
**最後更新**: 2025-08-07  
**作者**: Kai Cheng  

## 📋 當前專案狀態

### ✅ 已完成項目

1. **基礎架構建置**
   - AKS 叢集部署完成 (Kubernetes 1.33.2)
   - Azure CNI + Calico 網路配置
   - 多區域部署 (East Asia zones 1,2)

2. **模組化架構**
   - AKS 模組: `terraform/modules/aks/`
   - ACR 模組: `terraform/modules/acr/`  
   - AGIC 模組: `terraform/modules/application-gateway/`
   - 網路模組: `terraform/modules/networking/` (已更新)

3. **ACR 整合**
   - ACR 實例: `acrdev9vgrsdq8`
   - SystemAssigned Identity 整合
   - AcrPull 角色分配完成

4. **成本優化**
   - AKS 叢集已完全停用 (節省 70%+ 費用)
   - 當前每日費用: 約 NT$60-65

5. **版本控制**
   - Git repository 已建立並推送
   - 完整文檔體系建立
   - 29 個檔案，3775 行程式碼

## 🎯 下次 Session 快速啟動步驟

### 1. 環境檢查 (2 分鐘)

```bash
# 切換到專案目錄
cd /Users/chengyukai/Documents/緯謙/Azure/AKS/DS-AKS

# 檢查 Git 狀態
git status
git log --oneline -5

# 檢查 Azure 連線
az account show --query "name" -o tsv

# 檢查當前資源狀態
az aks show --resource-group rg-aks-dev --name aks-dev-cluster \
  --query "powerState.code" -o tsv
```

### 2. 重啟 AKS (如需要) (5-8 分鐘)

```bash
# 啟動 AKS 叢集
az aks start --resource-group rg-aks-dev --name aks-dev-cluster

# 等待啟動完成
az aks show --resource-group rg-aks-dev --name aks-dev-cluster \
  --query "powerState.code" -o tsv

# 獲取 kubeconfig
az aks get-credentials --resource-group rg-aks-dev --name aks-dev-cluster

# 驗證連接
kubectl get nodes
kubectl get pods -n kube-system
```

### 3. 開發環境準備 (2 分鐘)

```bash
# 切換到 Terraform DEV 環境
cd terraform/environments/dev

# 檢查 Terraform 狀態
terraform show

# 如需要重新初始化
terraform init
terraform plan
```

## 📁 重要檔案位置

### 🏗️ Terraform 模組
```
terraform/modules/
├── aks/                    # AKS 叢集模組
├── acr/                    # Container Registry 模組  
├── application-gateway/    # AGIC 模組
└── networking/             # 網路模組
```

### 🌍 環境配置
```
terraform/environments/
├── dev/                    # 開發環境 (當前使用)
│   ├── main.tf            # 主要配置
│   ├── variables.tf       # 變數定義
│   ├── outputs.tf         # 輸出定義
│   └── terraform.tfvars   # 實際配置 (git ignored)
├── staging/               # 測試環境 (範本)
└── prod/                  # 生產環境 (範本)
```

### 📚 文檔資料
```
docs/
├── README.md                           # 文檔索引
├── acr-agic-integration-20250807.md    # ACR/AGIC 整合記錄
├── deployment-log-20250807.md          # 部署操作記錄
├── dev-environment-status-report.md    # DEV 環境狀態
├── terraform-architecture-guide.md     # 架構設計指南
└── session-continuity-guide.md         # 本檔案
```

## 🔧 常用命令參考

### AKS 管理
```bash
# 啟動叢集
az aks start --resource-group rg-aks-dev --name aks-dev-cluster

# 停止叢集
az aks stop --resource-group rg-aks-dev --name aks-dev-cluster

# 擴展節點
az aks nodepool scale --resource-group rg-aks-dev \
  --cluster-name aks-dev-cluster --name user --node-count 1

# 縮減節點
az aks nodepool scale --resource-group rg-aks-dev \
  --cluster-name aks-dev-cluster --name user --node-count 0
```

### Kubernetes 操作
```bash
# 獲取節點狀態
kubectl get nodes

# 檢查系統 Pod
kubectl get pods -n kube-system

# 檢查 ACR 整合
kubectl create deployment nginx --image=acrdev9vgrsdq8.azurecr.io/nginx:latest
```

### Terraform 操作
```bash
# 切換到 DEV 環境
cd terraform/environments/dev

# 規劃變更
terraform plan

# 應用變更
terraform apply

# 查看輸出
terraform output
```

## 🎯 下一階段工作項目

### 短期目標 (1-2週)
1. **應用程式部署測試**
   - 使用 ACR 部署測試應用
   - 驗證網路連通性
   - 測試 Pod 調度

2. **AGIC 功能測試**
   - 在 Staging 環境啟用 AGIC
   - 測試 Application Gateway 整合
   - 驗證負載均衡功能

3. **成本自動化**
   - 建立自動停止/啟動腳本
   - Azure DevOps Pipeline 整合
   - 監控和告警設定

### 中期目標 (2-4週)
1. **CI/CD 流程**
   - Azure DevOps Pipeline 建立
   - 自動化測試整合
   - 多環境部署策略

2. **安全強化**
   - Network Policy 實施
   - Private Endpoint 配置
   - RBAC 細化設定

3. **監控整合**
   - Azure Monitor 設定
   - Log Analytics 配置
   - 效能基準建立

### 長期目標 (1-2個月)
1. **生產環境準備**
   - Staging/Prod 環境建立
   - 災難恢復策略
   - 安全掃描和合規

2. **應用程式遷移**
   - 53 個服務遷移計畫
   - 效能調優
   - 容量規劃

## 📊 當前資源清單

### 運行中資源
```yaml
Azure Container Registry: acrdev9vgrsdq8 (Basic SKU)
Load Balancer: kubernetes (Standard)
Public IP: 1 個靜態 IP
Virtual Network: vnet-aks-dev (10.0.0.0/8)
Subnet: subnet-aks-dev (10.0.1.0/24)
```

### 已停用資源
```yaml
AKS Cluster: aks-dev-cluster (Stopped)
System Node Pool: 1 × Standard_D2s_v3 (Stopped)
User Node Pool: 0 × Standard_D2s_v3 (Stopped)
```

### 每日費用
```yaml
運行狀態: NT$230/天
停用狀態: NT$60-65/天 (當前)
完全刪除: NT$5-10/天 (僅 ACR + 儲存)
```

## 🔍 問題排解

### 常見問題

1. **AKS 啟動失敗**
   ```bash
   # 檢查資源狀態
   az aks show --resource-group rg-aks-dev --name aks-dev-cluster
   
   # 檢查活動記錄
   az monitor activity-log list --resource-group rg-aks-dev
   ```

2. **Kubectl 連接失敗**
   ```bash
   # 重新獲取憑證
   az aks get-credentials --resource-group rg-aks-dev \
     --name aks-dev-cluster --overwrite-existing
   ```

3. **Terraform 狀態不一致**
   ```bash
   # 刷新狀態
   terraform refresh
   
   # 重新同步
   terraform import azurerm_kubernetes_cluster.aks \
     /subscriptions/7f004e94-ef6d-49df-8f43-ac31ddf854fd/resourceGroups/rg-aks-dev/providers/Microsoft.ContainerService/managedClusters/aks-dev-cluster
   ```

## 📞 支援資源

### 內部文檔
- **架構指南**: `docs/terraform-architecture-guide.md`
- **狀態報告**: `docs/dev-environment-status-report.md`
- **操作記錄**: `docs/deployment-log-20250807.md`

### 外部資源
- [AKS 官方文檔](https://docs.microsoft.com/en-us/azure/aks/)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Claude Code 文檔](https://docs.anthropic.com/en/docs/claude-code)

## 💡 最佳實踐提醒

1. **開始工作前**
   - 檢查 Azure 訂用帳戶狀態
   - 確認叢集是否需要啟動
   - 審查上次的 git commit

2. **結束工作時**
   - 停止 AKS 叢集節省費用
   - 提交程式碼變更
   - 更新文檔記錄

3. **定期維護**
   - 每週檢查 Azure 費用
   - 定期更新 Terraform 狀態
   - 保持文檔同步

---

**下次 Session 開始指令**:
```bash
cd /Users/chengyukai/Documents/緯謙/Azure/AKS/DS-AKS
git status && az account show --query name -o tsv
```

這樣您就可以快速繼續專案開發！