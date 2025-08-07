# AKS 叢集部署記錄

**日期**: 2025-08-07  
**專案**: DS-AKS (地端 Kubernetes 遷移至 Azure AKS)  
**環境**: DEV  
**執行者**: Claude Code Assistant  

## 概述

本次操作成功建立了完整的 AKS 開發環境，包含模組化 Terraform 配置和基礎網路設施。此部署為地端 Kubernetes 遷移至 Azure AKS 專案的第一階段。

## 操作流程記錄

### 階段一：AKS 模組建立與配置
1. **檢查現有 AKS 模組結構**
   - 位置: `terraform/modules/aks/`
   - 檔案: `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`

2. **更新 Kubernetes 版本**
   - 原始版本: 1.27.7
   - 最終版本: 1.33.2 (因區域支援限制調整)
   - 原因: 1.27.102 為 LTS 版本需 Premium tier

3. **網路配置最佳化**
   - 移除過時的 `docker_bridge_cidr` 參數
   - 支援現代 containerd CRI
   - 變數化網路 CIDR 設定

### 階段二：變數統一與模組化
4. **統一變數管理架構**
   - AKS 模組: 維護技術預設值
   - DEV 環境: 只覆寫環境特定配置
   - 移除重複變數定義

5. **修復棄用參數警告**
   - 網路模組: `private_endpoint_network_policies_enabled` → `private_endpoint_network_policies`
   - Azure AD: 採用條件式配置移除警告

6. **恢復變數驗證邏輯**
   - 網路外掛和政策驗證
   - 確保參數正確性

### 階段三：部署問題解決
7. **Availability Zone 修正**
   - 錯誤: East Asia 不支援 Zone 3
   - 解決: 調整為 Zone 1, 2
   
8. **Kubernetes 版本調整**  
   - 錯誤: 1.27.102 需要 Premium tier + LTS
   - 解決: 更新至 1.33.2 標準版本

### 階段四：成功部署
9. **Terraform Apply 執行**
   - 總建置時間: ~6分鐘
   - AKS 叢集: 4分4秒
   - Node Pool: 2分8秒
   - 角色指派: 27秒

## 最終架構配置

### 技術配置
```yaml
Kubernetes版本: 1.33.2
CNI: Azure CNI
Network Policy: Calico  
Container Runtime: containerd
Identity: System Assigned
RBAC: 啟用
Azure Policy: 啟用
```

### 網路配置
```yaml
VNet: vnet-aks-dev (10.0.0.0/8)
Subnet: subnet-aks-dev (10.0.1.0/24)
Service CIDR: 10.0.0.0/24
DNS Service IP: 10.0.0.10
Load Balancer: Standard
```

### 節點池配置
```yaml
System Node Pool:
  - Name: system
  - VM Size: Standard_D2s_v3
  - Zones: [1, 2]
  - Auto Scaling: 1-3 nodes
  - OS Disk: 128GB Managed

User Node Pool:
  - Name: user  
  - VM Size: Standard_D2s_v3
  - Zones: [1, 2]
  - Auto Scaling: 1-5 nodes
  - OS Disk: 128GB Managed
  - Labels: environment=dev, nodepool-type=user, workload=applications
```

## 部署結果

### 成功建立的 Azure 資源 (共8個)

#### 網路基礎設施
- **Resource Group**: `rg-aks-dev`
- **Virtual Network**: `vnet-aks-dev`
- **Subnet**: `subnet-aks-dev` 
- **Network Security Group**: `subnet-aks-dev-nsg`
- **NSG Association**: subnet-aks-dev

#### AKS 叢集
- **AKS Cluster**: `aks-dev-cluster`
- **System Node Pool**: system (已包含在叢集中)
- **User Node Pool**: user
- **Network Contributor Role**: 網路權限指派

### 輸出資訊
```yaml
cluster_fqdn: "aks-dev-p8evm4on.hcp.eastasia.azmk8s.io"
cluster_id: "/subscriptions/7f004e94-ef6d-49df-8f43-ac31ddf854fd/resourceGroups/rg-aks-dev/providers/Microsoft.ContainerService/managedClusters/aks-dev-cluster"
cluster_identity:
  type: "SystemAssigned"
  principal_id: "2435433a-cec1-4a4e-b453-47f7dfad3c02"
  tenant_id: "10f0f3b2-c2b5-445f-84f7-584515916a82"
kubelet_identity:
  client_id: "1c3c3355-d2b5-4c24-8be8-2f81f3e077cf"
  object_id: "4804f753-2a48-44c5-9416-53693f0e4854"
  user_assigned_identity_id: "/subscriptions/7f004e94-ef6d-49df-8f43-ac31ddf854fd/resourceGroups/MC_rg-aks-dev_aks-dev-cluster_eastasia/providers/Microsoft.ManagedIdentity/userAssignedIdentities/aks-dev-cluster-agentpool"
```

## 模組化架構優勢

### 變數管理統一
- **AKS 模組**: 維護技術預設值和驗證邏輯
- **環境層**: 只定義環境特定配置 (節點大小、網路範圍)
- **配置簡化**: DEV 環境 tfvars 從複雜配置簡化為核心參數

### 可重用性
- **多環境支援**: 同一模組可用於 dev/staging/prod
- **參數彈性**: 可選擇性覆寫任何模組預設值  
- **維護效率**: 技術升級只需修改模組一次

### 最佳實踐
- **現代化CRI**: 移除 Docker 依賴，使用 containerd
- **安全配置**: Calico 網路政策提供進階流量控制
- **高可用性**: Multi-zone 部署確保服務可用性
- **自動擴縮**: 節點自動調整應對負載變化

## 遇到的問題與解決方案

### 1. Availability Zone 不相容
**問題**: East Asia 地區不支援 Zone 3  
**錯誤**: `"The zone(s) '3' for resource 'system' is not supported"`  
**解決**: 調整 availability_zones 預設值為 `["1", "2"]`

### 2. Kubernetes 版本限制
**問題**: 1.27.102 為 LTS 版本需要 Premium tier  
**錯誤**: `"version 1.27.102, which is only available for Long-Term Support (LTS)"`  
**解決**: 更新至標準支援版本 1.33.2

### 3. 棄用參數警告
**問題**: 多個 Azure Provider 參數棄用警告  
**解決**: 
- `private_endpoint_network_policies_enabled` → `private_endpoint_network_policies`
- Azure AD 整合改用條件式配置

### 4. 變數驗證衝突
**問題**: null 值導致 Terraform 驗證失敗  
**解決**: 重新設計變數傳遞邏輯，DEV 環境使用模組預設值

## 後續建議

### 1. 安全強化
- 實施 Network Policy 規則限制 Pod 間通訊
- 啟用 Azure AD 整合進行身分驗證
- 設定 Private Cluster 提高安全性

### 2. 監控與維運  
- 整合 Azure Monitor 和 Log Analytics
- 設定 Application Insights 應用程式監控
- 建立告警規則和儀表板

### 3. 應用程式部署準備
- 設定 Azure Container Registry (ACR)
- 建立 Azure DevOps Pipeline
- 部署 Application Gateway Ingress Controller

### 4. 備份與災難恢復
- 啟用 AKS 叢集備份
- 設定跨區域災難恢復策略
- 建立 PV 快照自動化

## 成本優化考量

### DEV 環境配置
- **節點規格**: Standard_D2s_v3 (適合開發測試)
- **節點數量**: 最小化配置 (system: 1-3, user: 1-5)
- **SKU Tier**: Free (開發環境無 SLA 需求)
- **儲存**: 標準 Managed Disk

### 建議
- 非工作時間可縮減節點數量
- 監控資源使用率優化 VM 規格
- 定期檢討不必要的資源

## 文件連結

### Terraform 配置位置
- **AKS 模組**: `terraform/modules/aks/`
- **DEV 環境**: `terraform/environments/dev/`
- **網路模組**: `terraform/modules/networking/`

### 相關文件
- **專案架構**: `Claude.md`
- **網路規劃**: `terraform-architecture-notes.md`
- **Pipeline 配置**: `azure-devops/pipelines/`

## 總結

本次 AKS 叢集部署成功達成以下目標：
- ✅ 建立完整的開發環境 AKS 叢集
- ✅ 實現模組化 Terraform 架構
- ✅ 採用現代化容器技術 (containerd + Calico)
- ✅ 支援高可用性和自動擴縮
- ✅ 為後續應用程式遷移奠定基礎

此環境已準備就緒，可開始進行應用程式容器化和部署測試，為正式遷移 53 個無狀態服務做準備。

---

**建置完成時間**: 2025-08-07  
**狀態**: ✅ 成功  
**下一步**: 應用程式部署與 CI/CD Pipeline 整合