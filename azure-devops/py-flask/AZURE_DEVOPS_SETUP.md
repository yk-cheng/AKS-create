# Azure DevOps Pipeline 設定指南

**專案**: Python Flask 應用程式部署到 AKS  
**更新日期**: 2025-08-08  
**狀態**: 準備測試  

## 🎯 概述

本指南說明如何設定 Azure DevOps CI/CD Pipeline，將 Python Flask 應用程式自動建置並部署到 Azure Kubernetes Service (AKS)。

## 📋 前置條件

### Azure 資源 (已準備完成)
- ✅ **AKS 叢集**: `aks-dev-cluster` (rg-aks-dev)
- ✅ **Azure Container Registry**: `acrdev9vgrsdq8.azurecr.io`
- ✅ **Application Gateway**: 已整合 AKS
- ✅ **資源群組**: `rg-aks-dev`

### 驗證狀態
```bash
# 檢查 AKS 叢集
az aks show --resource-group rg-aks-dev --name aks-dev-cluster --query "provisioningState"

# 檢查 ACR
az acr show --name acrdev9vgrsdq8 --query "provisioningState"

# 測試 ACR 推送 (已完成)
az acr build --registry acrdev9vgrsdq8 --image py-flask:v1.0.0 .
```

## 🚀 Azure DevOps 設定步驟

### 1. 建立 Azure DevOps 專案

1. 前往 [Azure DevOps](https://dev.azure.com)
2. 建立新專案: `DS-AKS-FlaskApp`
3. 選擇版本控制: Git
4. 可見性: Private

### 2. 建立 Service Connections

#### ACR Service Connection
```yaml
Name: acrdev9vgrsdq8
Type: Docker Registry
Registry URL: acrdev9vgrsdq8.azurecr.io
Authentication: Service Principal (Auto)
```

#### AKS Service Connection
```yaml
Name: aks-dev-connection
Type: Kubernetes
Authentication Method: Service Account
Server URL: <從 AKS 取得>
```

**取得 AKS Server URL:**
```bash
az aks show --resource-group rg-aks-dev --name aks-dev-cluster --query "fqdn" -o tsv
```

### 3. 建立 Environment

```yaml
Name: aks-dev-environment
Type: Kubernetes
Resource: aks-dev-cluster
Namespace: py-flask-app
```

### 4. 設定 Pipeline

#### Pipeline 檔案位置
- 檔案: `azure-devops/py-flask/azure-pipelines-aks.yml`
- Branch: `main`

#### Pipeline 變數
| 變數名稱 | 值 |
|----------|---|
| containerRegistry | acrdev9vgrsdq8.azurecr.io |
| imageRepository | py-flask |
| resourceGroupName | rg-aks-dev |
| aksClusterName | aks-dev-cluster |
| k8sNamespace | py-flask-app |

## 📁 專案結構

```
applications/py-flask/
├── app.py                          # Flask 應用程式
├── requirements.txt                 # Python 依賴
├── Dockerfile                       # Docker 建置檔
├── azure-pipelines-aks.yml         # Azure DevOps Pipeline
├── templates/
│   └── index.html                   # HTML 模板
└── k8s-manifests/
    ├── namespace.yaml               # Kubernetes Namespace
    ├── deployment.yaml              # 應用程式部署
    ├── service.yaml                 # 服務 (LoadBalancer 類型)
    └── ingress.yaml                 # Ingress 設定 (可選)
```

## 🔧 Pipeline 流程說明

### Stage 1: Build
1. **建置 Docker Image**
   - 使用 `applications/py-flask/Dockerfile`
   - 標籤: `$(Build.BuildId)` 和 `latest`

2. **推送到 ACR**
   - 目標: `acrdev9vgrsdq8.azurecr.io/py-flask`
   - 使用 Service Connection: `acrdev9vgrsdq8`

### Stage 2: Deploy
1. **建立/更新 Namespace**
   - 命名空間: `py-flask-app`

2. **部署 Kubernetes 資源**
   - Deployment: 2 個副本，資源限制 256Mi/200m CPU
   - Service: LoadBalancer 類型，端口 80 → 8087
   - 使用動態映像標籤: `$(Build.BuildId)`

3. **驗證部署**
   - 檢查 Pods、Services、Ingress 狀態

## ⚙️ 重要設定細節

### Docker 建置內容
- **建置目錄**: `applications/py-flask/`
- **基礎映像**: `python:3.9-slim`
- **應用程式端口**: 8087
- **健康檢查**: `/health` 端點

### Kubernetes 資源配置
```yaml
# Deployment 重點
spec:
  replicas: 2
  template:
    spec:
      containers:
      - image: acrdev9vgrsdq8.azurecr.io/py-flask:latest  # 會被 Pipeline 動態替換
        resources:
          requests: { memory: "128Mi", cpu: "100m" }
          limits: { memory: "256Mi", cpu: "200m" }
        livenessProbe:
          httpGet: { path: /health, port: 8087 }
        readinessProbe:
          httpGet: { path: /health, port: 8087 }
```

### Service 外部存取
- **類型**: LoadBalancer (Azure 會自動分配公共 IP)
- **端口映射**: 80:8087
- **外部存取**: `http://<EXTERNAL-IP>/health`

## 🔍 測試步驟

### 1. 手動觸發 Pipeline
1. 前往 Azure DevOps → Pipelines
2. 選擇 Flask Pipeline
3. 點擊 "Run pipeline"
4. 監控建置和部署過程

### 2. 驗證部署結果
```bash
# 檢查 namespace 和 pods
kubectl get all -n py-flask-app

# 檢查服務外部 IP
kubectl get svc -n py-flask-app

# 測試應用程式
curl http://<EXTERNAL-IP>/health
curl http://<EXTERNAL-IP>/api/info
```

### 3. 程式碼變更觸發
1. 修改 `app.py` 任何內容
2. 提交到 `main` 分支
3. Pipeline 應自動觸發
4. 驗證新版本部署

## 📊 監控和除錯

### Pipeline 除錯
- **建置階段失敗**: 檢查 Dockerfile 和依賴
- **推送階段失敗**: 驗證 ACR Service Connection
- **部署階段失敗**: 檢查 AKS Service Connection 和權限

### Kubernetes 除錯
```bash
# 檢查 Pod 詳細資訊
kubectl describe pod -n py-flask-app -l app=py-flask-app

# 查看 Pod 日誌
kubectl logs -n py-flask-app -l app=py-flask-app

# 檢查事件
kubectl get events -n py-flask-app --sort-by='.lastTimestamp'
```

## 🔐 安全配置

### Service Principal 權限
ACR Service Connection 需要的權限:
- `AcrPush` (推送映像)
- `AcrPull` (拉取映像)

AKS Service Connection 需要的權限:
- `Azure Kubernetes Service Cluster User Role`
- 對目標命名空間的 RBAC 權限

### 映像安全掃描
```yaml
# 可選: 加入安全掃描步驟
- task: AzureContainerRegistry@0
  displayName: 'Scan Image for Vulnerabilities'
  inputs:
    command: 'scan'
    repository: '$(imageRepository)'
    tags: '$(tag)'
```

## 📈 效能優化

### 建置優化
- 使用 `.dockerignore` 減少建置上下文
- 多階段建置減少映像大小
- 快取 Python 依賴層

### 部署優化  
- 設定適當的資源限制
- 使用 Horizontal Pod Autoscaler
- 設定 readiness/liveness 探針

## 🚨 故障排解

### 常見問題

1. **ACR 認證失敗**
   ```
   解決方案: 重新建立 ACR Service Connection
   確認 Service Principal 權限
   ```

2. **AKS 部署失敗**
   ```
   解決方案: 檢查 kubeconfig 和 RBAC 權限
   驗證命名空間存在
   ```

3. **Pod 無法啟動**
   ```
   解決方案: 檢查映像標籤是否正確
   驗證資源限制設定
   ```

## 🔄 後續改進

### 進階功能
- [ ] 藍綠部署策略
- [ ] 金絲雀部署
- [ ] 自動化測試整合
- [ ] 效能測試
- [ ] 安全掃描整合

### 多環境支援
- [ ] Staging 環境設定
- [ ] Production 環境設定
- [ ] 環境特定設定管理

## 📞 支援資源

- **Azure DevOps 文檔**: https://docs.microsoft.com/azure/devops/
- **AKS 文檔**: https://docs.microsoft.com/azure/aks/
- **ACR 文檔**: https://docs.microsoft.com/azure/container-registry/
- **專案文檔**: `../docs/README.md`

---

**最後更新**: 2025-08-08  
**維護者**: DevOps Team  
**版本**: v1.0.0