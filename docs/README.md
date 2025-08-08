# DS-AKS 專案文檔索引

**專案**: DS-AKS (地端 Kubernetes 遷移至 Azure AKS)  
**更新日期**: 2025-08-07  
**狀態**: DEV 環境已完成部署  

## 📚 文檔結構

```
docs/
├── README.md                           # 本檔案 - 文檔索引
├── deployment-log-20250807.md          # 部署操作記錄
├── dev-environment-status-report.md    # DEV 環境狀態報告  
├── terraform-architecture-guide.md     # Terraform 架構設計指南
├── acr-agic-integration-20250807.md    # ACR 和 AGIC 模組整合記錄
├── session-continuity-guide.md         # Session 接續指南
└── runbooks/                           # 操作手冊目錄
```

## 📖 文檔說明

### 🚀 [部署操作記錄](deployment-log-20250807.md)
**檔案**: `deployment-log-20250807.md`  
**用途**: 完整的 AKS 叢集建置操作記錄  
**內容**:
- 14 個階段的詳細操作流程
- 問題解決過程 (Availability Zone, Kubernetes 版本, 棄用參數)
- 技術配置和架構資訊
- 部署結果和資源清單
- 後續建議和最佳實踐
- 成本優化考量

**適用對象**: DevOps 工程師、系統管理員、新團隊成員  
**使用場景**: 部署參考、問題排查、標準作業程序

### 📊 [DEV 環境狀態報告](dev-environment-status-report.md)
**檔案**: `dev-environment-status-report.md`  
**用途**: DEV 環境的完整健康檢查報告  
**內容**:
- 8 個 Azure 資源的詳細狀態
- AKS 叢集配置和節點池資訊
- 網路配置 (Azure CNI + Calico)
- 系統元件健康檢查
- 效能和可用性分析
- 改進建議和行動計畫

**適用對象**: 運維團隊、開發團隊、專案經理  
**使用場景**: 環境監控、容量規劃、問題診斷

### 🏗️ [Terraform 架構設計指南](terraform-architecture-guide.md)
**檔案**: `terraform-architecture-guide.md`  
**用途**: Terraform 模組化架構設計說明  
**內容**:
- 整體架構概念和目錄結構
- AKS 模組 vs DEV 環境職責分工
- 網路配置統整 (Azure CNI 設定)
- 架構優勢和注意事項
- 實際部署流程
- Azure 資源清單

**適用對象**: Infrastructure Engineer、新加入的 DevOps 工程師  
**使用場景**: 架構理解、新環境建立、模組擴展

### 🔧 [ACR 和 AGIC 模組整合記錄](acr-agic-integration-20250807.md)
**檔案**: `acr-agic-integration-20250807.md`  
**用途**: Azure Container Registry 和 Application Gateway Ingress Controller 整合部署記錄  
**內容**:
- ACR 模組建立與 AKS 整合
- AGIC 模組建立與網路配置
- 身分認證優化 (SystemAssigned Identity)
- 技術問題解決過程
- 部署驗證和測試步驟
- 安全改進和成本分析

**適用對象**: DevOps 工程師、容器平台管理員  
**使用場景**: ACR/AGIC 部署、問題排查、安全配置參考

### 🔄 [Session 接續指南](session-continuity-guide.md)
**檔案**: `session-continuity-guide.md`  
**用途**: 跨 Session 工作接續和快速恢復指南  
**內容**:
- 當前專案完整狀態摘要
- 快速啟動步驟 (2-8 分鐘)
- 重要檔案和命令參考
- 下階段工作項目規劃
- 問題排解和最佳實踐
- 成本優化狀態說明

**適用對象**: 所有專案參與者  
**使用場景**: Session 切換、專案交接、快速恢復工作環境

## 🔍 快速查找指南

### 👷‍♂️ 我是新的 DevOps 工程師
1. 先讀 **[Terraform 架構設計指南](terraform-architecture-guide.md)** 了解整體架構
2. 再讀 **[部署操作記錄](deployment-log-20250807.md)** 了解部署流程
3. 參考 **[DEV 環境狀態報告](dev-environment-status-report.md)** 了解當前狀態

### 🔧 我需要部署新環境
1. 參考 **[部署操作記錄](deployment-log-20250807.md)** 的操作流程
2. 使用 **[Terraform 架構設計指南](terraform-architecture-guide.md)** 的部署流程
3. 參考 **[DEV 環境狀態報告](dev-environment-status-report.md)** 的配置設定

### 🚨 我需要解決問題
1. 查看 **[DEV 環境狀態報告](dev-environment-status-report.md)** 確認正常狀態
2. 參考 **[部署操作記錄](deployment-log-20250807.md)** 的問題解決記錄
3. 檢查 **runbooks/** 目錄下的操作手冊

### 📈 我需要了解環境狀況
1. 閱讀 **[DEV 環境狀態報告](dev-environment-status-report.md)** 獲取完整狀態
2. 參考其中的健康檢查摘要和改進建議
3. 查看下一步行動項目

## 🎯 專案狀態概覽

### ✅ 已完成
- **AKS 叢集部署**: Kubernetes 1.33.2 + Azure CNI + Calico
- **ACR 整合**: Azure Container Registry + SystemAssigned Identity
- **模組化架構**: AKS、ACR、AGIC、Networking 模組
- **DEV 環境**: 完整功能驗證包含 ACR
- **文檔體系**: 完整的記錄和指南

### 🔄 進行中
- **應用程式部署測試**: 準備開始
- **監控整合**: 規劃階段
- **CI/CD 流程**: 設計階段

### 📋 計劃中
- **Staging/Prod 環境**: 後續階段
- **53 個服務遷移**: 主要目標
- **災難恢復**: 安全考量

## 📞 文檔維護

### 更新頻率
- **部署記錄**: 每次重大部署後更新
- **環境狀態報告**: 每週檢查並更新
- **架構指南**: 架構變更時更新
- **索引檔案**: 新增文檔時更新

### 維護責任
- **DevOps 團隊**: 技術文檔更新
- **專案經理**: 狀態和計畫更新
- **架構師**: 設計文檔審查

### 文檔規範
- 使用 Markdown 格式
- 包含創建/更新日期
- 明確的標題和結構
- 適當的表格和清單格式
- 實用的快速查找功能

## 🔗 相關連結

### 專案資源
- **Terraform 配置**: `../terraform/`
- **Kubernetes 清單**: `../k8s-manifests/`
- **Azure DevOps Pipeline**: `../azure-devops/`
- **遷移工具**: `../migration/`

### 外部資源
- [Azure AKS 官方文檔](https://docs.microsoft.com/en-us/azure/aks/)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Calico 網路政策](https://docs.projectcalico.org/about/about-network-policy)

---

**最後更新**: 2025-08-07  
**維護者**: DevOps Team  
**聯絡方式**: 專案 DevOps 團隊