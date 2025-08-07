# Claude Code 使用指南

## 概述

Claude Code 是 Anthropic 提供的命令行工具，讓開發者可以直接從終端將編程任務委託給 Claude。本文件專門針對從地端 Kubernetes 遷移到 Azure Kubernetes Service (AKS) 專案，使用 Terraform 進行基礎設施建置，並透過 Azure DevOps 部署測試應用程式。

## 安裝與設定

### 前置需求
- 確保您有 Anthropic API 存取權限
- 已安裝 Node.js 或 Python（依 Claude Code 版本而定）

### 安裝步驟
```bash
# 請參考 https://docs.anthropic.com/en/docs/claude-code 取得最新安裝指令
# 例如：
npm install -g @anthropic-ai/claude-code
```

### API 金鑰設定
```bash
export ANTHROPIC_API_KEY="your-api-key-here"
```

## 專案結構建議

基於地端 K8s 遷移到 AKS 的需求，建議在專案根目錄建立以下結構：

```
project-root/
├── Claude.md                    # 本文件
├── terraform/
│   ├── modules/
│   │   ├── aks/                 # AKS 模組
│   │   ├── networking/          # 網路設定
│   │   ├── acr/                 # Container Registry
│   │   └── monitoring/          # 監控設定
│   ├── environments/
│   │   ├── dev/                 # 開發環境
│   │   ├── staging/             # 測試環境
│   │   └── prod/                # 生產環境
│   └── main.tf                  # 主要 Terraform 設定
├── azure-devops/
│   ├── pipelines/
│   │   ├── infrastructure/      # 基礎設施部署 Pipeline
│   │   └── applications/        # 應用程式部署 Pipeline
│   └── templates/               # YAML 範本
├── k8s-manifests/
│   ├── cni/                     # Azure CNI 設定
│   ├── csi/                     # Container Storage Interface
│   ├── ingress/                 # Ingress Controller 設定
│   ├── agic/                    # Application Gateway Ingress Controller
│   ├── network-policies/        # Network Policy 設定
│   └── applications/            # 應用程式 Kubernetes 清單
├── migration/
│   ├── assessment/              # 遷移評估
│   ├── scripts/                 # 遷移腳本
│   └── validation/              # 驗證工具
└── docs/
    ├── migration-plan.md        # 遷移計畫
    ├── architecture.md          # 架構說明
    └── runbooks/                # 操作手冊
```

## Claude Code 使用情境

### 1. Terraform AKS 基礎設施建置

**情境：** 建立完整的 AKS 基礎設施，包含所有必要元件

```bash
# 建立 AKS Terraform 模組
claude-code "Create a comprehensive Terraform module for AKS deployment with:
- AKS cluster version 1.27.102
- Azure CNI networking
- Azure Container Registry (ACR) integration
- Application Gateway Ingress Controller (AGIC)
- Container Storage Interface (CSI) drivers
- Network policies enabled
- Multi-zone deployment for high availability
- ExpressRoute integration support"
```

### 2. Azure DevOps Pipeline 設定

**情境：** 建立 CI/CD Pipeline 部署測試應用程式到 AKS

```bash
# 建立基礎設施部署 Pipeline
claude-code "Generate Azure DevOps YAML pipeline for:
- Terraform plan and apply for AKS infrastructure
- Multi-environment deployment (dev/staging/prod)
- Service connection to Azure subscription
- Terraform state management with Azure Storage
- Pipeline approval gates for production"

# 建立應用程式部署 Pipeline
claude-code "Create Azure DevOps pipeline for deploying applications to AKS:
- Docker image build and push to ACR
- Kubernetes manifest deployment
- Helm chart deployment option
- Integration with AGIC for ingress
- Health checks and rollback strategies
- Multi-stage deployment (dev → staging → prod)"
```

### 3. Kubernetes 元件設定

**情境：** 設定 AKS 相關的 Kubernetes 元件

```bash
# Azure CNI 網路設定
claude-code "Generate Kubernetes network configuration for:
- Azure CNI with custom subnet allocation
- Pod and service CIDR configuration
- Network security groups integration
- Support for 53 applications with 4GB RAM/2 CPU limits"

# CSI 存儲設定
claude-code "Create Container Storage Interface configuration for:
- Azure Disk CSI driver
- Azure Files CSI driver  
- Storage classes for different performance tiers
- Persistent volume claim templates
- Backup and snapshot policies"

# Network Policy 設定
claude-code "Design Kubernetes Network Policies for:
- Pod-to-pod communication restrictions
- Ingress traffic control
- Supplier access control through Kong API Gateway
- Namespace isolation
- Azure CNI compatibility"
```

### 4. Application Gateway Ingress Controller (AGIC)

**情境：** 設定 AGIC 整合 Azure Application Gateway

```bash
claude-code "Configure Application Gateway Ingress Controller with:
- Azure Application Gateway integration
- SSL/TLS termination
- WAF (Web Application Firewall) policies
- Backend health probes
- Path-based and host-based routing
- Integration with Azure DNS
- Support for multiple applications ingress"
```

### 5. 遷移評估與規劃

**情境：** 從地端 K8s 遷移到 AKS 的評估工具

```bash
# 遷移評估工具
claude-code "Create migration assessment scripts to:
- Analyze current on-premise Kubernetes resources
- Identify incompatible configurations for AKS
- Generate resource usage reports
- Validate network connectivity requirements
- Check Azure CNI compatibility
- Assess storage migration needs"

# 遷移執行腳本
claude-code "Generate migration execution scripts for:
- Export configurations from on-premise K8s
- Transform configurations for AKS compatibility
- Migrate persistent data to Azure storage
- Update DNS and load balancer configurations
- Validate application functionality post-migration"
```

## 最佳實踐

### 1. 提示詞撰寫技巧

- **具體明確：** 包含確切的技術需求（如：AKS 1.27.102, Azure CNI）
- **提供脈絡：** 說明我們的架構（ExpressRoute, Kong API Gateway）
- **要求文件：** 請 Claude 同時產生相關文件和註解

### 2. 專案特定資訊

在使用 Claude Code 時，請包含以下專案脈絡：

```markdown
專案背景：
- 從地端 Kubernetes 遷移至 Azure AKS
- 使用 Terraform 建置 AKS 基礎設施
- 透過 Azure DevOps 進行 CI/CD 部署
- 53 個無狀態應用服務遷移
- 整合 Azure CNI、CSI、AGIC、Network Policy
- Azure Container Registry (ACR) 作為映像倉庫  
- ExpressRoute 網路連接
- Kong API Gateway 控制供應商存取
```

### 3. 安全考量

- 不要在提示詞中包含敏感資訊（API keys, passwords）
- 使用環境變數或設定檔管理機密資訊
- 定期檢視產生的程式碼是否符合安全最佳實踐

## 常用命令範例

### Terraform 基礎設施管理

```bash
# 建立完整的 AKS Terraform 設定
claude-code "Generate a complete Terraform configuration for AKS with:
- Main AKS cluster configuration
- Azure CNI networking setup
- ACR integration with AKS
- AGIC (Application Gateway Ingress Controller) setup
- Network security groups for multi-tier applications
- CSI drivers for Azure Disk and Files
- Variable definitions for multi-environment deployment"

# Terraform 模組化架構
claude-code "Create modular Terraform structure for:
- Reusable AKS module
- Networking module with Azure CNI
- Storage module with CSI drivers
- Security module with Network Policies
- Monitoring module with Azure Monitor integration"
```

### Azure DevOps Pipeline 建置

```bash
# 基礎設施 Pipeline
claude-code "Create Azure DevOps pipeline YAML for Terraform deployment:
- Multi-stage pipeline (validate → plan → apply)
- Terraform backend configuration for Azure Storage
- Service principal authentication
- Environment-specific variable groups
- Approval gates for production deployment
- Pipeline templates for reusability"

# 應用程式部署 Pipeline
claude-code "Generate Azure DevOps application deployment pipeline:
- Docker build and push to ACR
- Kubernetes manifest deployment to AKS
- Integration with Application Gateway Ingress
- Blue-green deployment strategy
- Automated testing and health checks
- Rollback capabilities on failure"
```

### Kubernetes 組態管理

```bash
# Network Policy 設定
claude-code "Design comprehensive Network Policies for AKS:
- Default deny all ingress/egress
- Allow specific pod-to-pod communication
- Database access restrictions
- External API access control
- Namespace isolation policies
- Integration with Azure CNI"

# AGIC Ingress 設定
claude-code "Create Application Gateway Ingress Controller configurations:
- Multiple application ingress rules
- SSL/TLS certificate management
- WAF policy integration
- Health probe configurations
- Path-based routing for microservices
- Custom backend settings"
```

### 遷移工具與腳本

```bash
# 遷移前評估
claude-code "Create pre-migration assessment tools:
- Kubernetes resource inventory script
- Network policy compatibility checker
- Storage requirement analysis
- Application dependency mapping
- Performance baseline establishment
- Security compliance validation"

# 應用程式遷移
claude-code "Generate application migration scripts:
- Export configurations from on-premise K8s
- Transform manifests for AKS compatibility
- Update image references to ACR
- Migrate persistent volumes to Azure storage
- Update service discovery configurations
- Validate post-migration functionality"
```

### 監控與運維

```bash
# 監控設定
claude-code "Setup comprehensive monitoring for AKS migration:
- Azure Monitor integration
- Application Insights for application telemetry
- Log Analytics workspace configuration
- Custom dashboards for migration progress
- Alerting rules for critical metrics
- Cost monitoring and optimization alerts"

# 災難恢復
claude-code "Design disaster recovery for AKS deployment:
- Multi-region backup strategies
- Persistent volume snapshot automation
- Configuration backup to Azure Blob Storage
- Cross-region replication setup
- Recovery time objective (RTO) planning
- Automated failover procedures"
```

## 疑難排解

### 常見問題

1. **API 速率限制：** 如果遇到速率限制，請適當間隔命令執行
2. **大型檔案處理：** 對於複雜的設定，建議分段處理
3. **版本相容性：** 確保產生的設定檔案相容於 K8s 1.27.x

### 支援資源

- Claude Code 官方文件：https://docs.anthropic.com/en/docs/claude-code
- Anthropic API 文件：https://docs.anthropic.com
- 專案內部文件：參考 `docs/` 目錄

## 協作流程

1. **基礎設施規劃階段：** 使用 Claude Code 產生 Terraform 模組和 AKS 架構設計
2. **CI/CD 建置階段：** 建立 Azure DevOps Pipeline 範本和部署策略
3. **遷移準備階段：** 產生遷移評估工具和相容性檢查腳本
4. **測試環境部署：** 建立測試應用程式部署至 AKS 的完整流程
5. **網路與安全設定：** 配置 CNI、Network Policy、AGIC 等元件
6. **生產環境遷移：** 執行實際遷移並驗證所有應用程式功能
7. **監控與維護：** 建立持續監控、備份和故障排除機制

## 遷移階段重點

### 階段一：基礎設施準備
- Terraform AKS 叢集建置
- Azure Container Registry 設定
- 網路安全群組配置
- ExpressRoute 整合

### 階段二：Kubernetes 元件部署
- Azure CNI 網路設定
- CSI 存儲驅動程式安裝
- AGIC 部署與設定
- Network Policy 實施

### 階段三：應用程式遷移
- Docker 映像推送至 ACR
- Kubernetes 清單部署
- Ingress 路由設定
- 應用程式驗證測試

### 階段四：運維整合
- Azure DevOps Pipeline 整合
- 監控與告警設定
- 備份策略實施
- 災難恢復驗證

## 注意事項

- 始終檢視和測試 Claude 產生的 Terraform 程式碼和 Kubernetes 設定
- 將所有基礎設施程式碼和 Pipeline 設定納入版本控制
- 在正式環境部署前，先在開發/測試環境驗證所有配置
- 確保 Azure DevOps Service Principal 具有適當的權限
- 定期更新 AKS 版本和相關元件至最新穩定版本
- 遵循 Azure 安全最佳實踐和企業合規要求
- 監控 Azure 成本並優化資源配置
- 建立完整的遷移回滾計畫以應對緊急情況

## 相關技術文件

### Azure 官方文件
- [AKS 官方文件](https://docs.microsoft.com/en-us/azure/aks/)
- [Azure CNI 網路設定](https://docs.microsoft.com/en-us/azure/aks/configure-azure-cni)
- [Application Gateway Ingress Controller](https://docs.microsoft.com/en-us/azure/application-gateway/ingress-controller-overview)
- [Container Storage Interface (CSI)](https://docs.microsoft.com/en-us/azure/aks/csi-storage-drivers)

### Terraform 相關
- [Azure Provider 文件](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [AKS Terraform 範例](https://github.com/Azure/terraform-azurerm-aks)

### Azure DevOps
- [Pipeline YAML 結構說明](https://docs.microsoft.com/en-us/azure/devops/pipelines/yaml-schema)
- [Kubernetes 部署任務](https://docs.microsoft.com/en-us/azure/devops/pipelines/tasks/deploy/kubernetes)

---

*最後更新：[日期]*  
*維護者：[您的姓名/團隊]*
