# Azure DevOps Service Connections 建立指南

**專案**: DS-AKS Flask 應用程式 CI/CD  
**建立日期**: 2025-08-08  
**狀態**: ACR 和 Azure RM 連接成功，AKS 連接需手動建立  

## 🎯 概述

本文件詳細記錄了為 Python Flask 應用程式建立 Azure DevOps Service Connections 的完整過程，包含遇到的問題和解決方案。

## 📋 前置需求

### Azure 資源狀態
- ✅ **AKS 叢集**: `aks-dev-cluster` (rg-aks-dev)
- ✅ **Azure Container Registry**: `acrdev9vgrsdq8.azurecr.io`
- ✅ **資源群組**: `rg-aks-dev`
- ✅ **Azure 訂閱**: `Visual Studio Enterprise 訂閱 – MPN`

### Azure DevOps 專案
- **組織**: `kai-lab`
- **專案**: `py-flask`
- **專案 ID**: `5c70574c-e790-401e-894d-6aef57901848`

## 🚀 Service Principal 建立

### 1. 建立 Service Principal

```bash
az ad sp create-for-rbac --name "AKS-DevOps-SP" --role contributor --scopes /subscriptions/7f004e94-ef6d-49df-8f43-ac31ddf854fd --sdk-auth
```

**輸出結果**:
```json
{
  "clientId": "d25e759a-141c-4100-b680-5a21c0a11a6a",
  "clientSecret": "YOUR_CLIENT_SECRET_HERE",
  "subscriptionId": "7f004e94-ef6d-49df-8f43-ac31ddf854fd",
  "tenantId": "10f0f3b2-c2b5-445f-84f7-584515916a82"
}
```

### 2. 分配必要權限

```bash
# ACR 權限
az role assignment create --assignee d25e759a-141c-4100-b680-5a21c0a11a6a --role AcrPush --scope /subscriptions/7f004e94-ef6d-49df-8f43-ac31ddf854fd/resourceGroups/rg-aks-dev/providers/Microsoft.ContainerRegistry/registries/acrdev9vgrsdq8

az role assignment create --assignee d25e759a-141c-4100-b680-5a21c0a11a6a --role Owner --scope /subscriptions/7f004e94-ef6d-49df-8f43-ac31ddf854fd/resourceGroups/rg-aks-dev/providers/Microsoft.ContainerRegistry/registries/acrdev9vgrsdq8

# AKS 權限
az role assignment create --assignee d25e759a-141c-4100-b680-5a21c0a11a6a --role "Azure Kubernetes Service Cluster Admin Role" --scope /subscriptions/7f004e94-ef6d-49df-8f43-ac31ddf854fd/resourceGroups/rg-aks-dev/providers/Microsoft.ContainerService/managedClusters/aks-dev-cluster
```

## 🔧 Service Connections 建立

### 1. Azure RM Service Connection ✅

**配置檔案**: `/tmp/azure-rm-connection.json`
```json
{
  "name": "Azure-Subscription",
  "type": "azurerm", 
  "url": "https://management.azure.com/",
  "authorization": {
    "parameters": {
      "serviceprincipalid": "d25e759a-141c-4100-b680-5a21c0a11a6a",
      "serviceprincipalkey": "YOUR_SERVICE_PRINCIPAL_SECRET",
      "tenantid": "10f0f3b2-c2b5-445f-84f7-584515916a82"
    },
    "scheme": "ServicePrincipal"
  },
  "data": {
    "subscriptionId": "7f004e94-ef6d-49df-8f43-ac31ddf854fd",
    "subscriptionName": "Visual Studio Enterprise 訂閱 – MPN",
    "environment": "AzureCloud",
    "scopeLevel": "Subscription",
    "creationMode": "Manual"
  }
}
```

**建立命令**:
```bash
az devops service-endpoint create --service-endpoint-configuration /tmp/azure-rm-connection.json --project py-flask
```

**結果**: 
- ✅ **狀態**: `isReady: true`
- ✅ **ID**: `7e7643da-13f2-432a-86d4-7d56320cc7e9`

### 2. ACR Service Connection ✅

**配置檔案**: `/tmp/acr-simple.json`
```json
{
  "name": "acrdev9vgrsdq8", 
  "type": "dockerregistry",
  "url": "https://acrdev9vgrsdq8.azurecr.io",
  "authorization": {
    "parameters": {
      "username": "d25e759a-141c-4100-b680-5a21c0a11a6a",
      "password": "YOUR_SERVICE_PRINCIPAL_SECRET",
      "registry": "https://acrdev9vgrsdq8.azurecr.io"
    },
    "scheme": "UsernamePassword"
  }
}
```

**建立命令**:
```bash
az devops service-endpoint create --service-endpoint-configuration /tmp/acr-simple.json --project py-flask
```

**結果**: 
- ✅ **狀態**: `isReady: true`
- ✅ **ID**: `7b25d09e-c63e-4a26-83ee-13de99477d17`

### 3. AKS Service Connection ❌

**問題**: 透過 Azure CLI 建立 Kubernetes Service Connection 持續失敗

**嘗試的配置**:
```json
{
  "name": "aks-dev-connection",
  "type": "kubernetes",
  "url": "https://aks-dev-p8evm4on.hcp.eastasia.azmk8s.io:443",
  "authorization": {
    "scheme": "Kubernetes",
    "parameters": {}
  },
  "data": {
    "authorizationType": "AzureSubscription",
    "azureSubscriptionId": "7f004e94-ef6d-49df-8f43-ac31ddf854fd",
    "azureSubscriptionName": "Visual Studio Enterprise 訂閱 – MPN",
    "clusterId": "/subscriptions/7f004e94-ef6d-49df-8f43-ac31ddf854fd/resourceGroups/rg-aks-dev/providers/Microsoft.ContainerService/managedClusters/aks-dev-cluster"
  }
}
```

**錯誤訊息**: "Unable to fetch cluster credentials as the Azure environment is not provided."

## 🔐 Federated Identity Credentials

### 現代化認證需求

Azure DevOps 現在建議使用 **Workload Identity Federation** 而不是 Service Principal 密鑰。

**網頁提示訊息**:
> Manually created service connections use an App Registration that was created by the user. Please add a federated credential to the App Registration with the following details: Issuer: https://vstoken.dev.azure.com/<org id>, Subject identifier: sc://<org>/<project>/<sc name>

### Federated Credentials 建立

#### 1. ACR Federated Credential
```json
{
  "name": "AzureDevOps-ACR-Connection",
  "issuer": "https://vstoken.dev.azure.com/5c70574c-e790-401e-894d-6aef57901848",
  "subject": "sc://kai-lab/py-flask/acrdev9vgrsdq8",
  "description": "Federated credential for ACR service connection in Azure DevOps",
  "audiences": ["api://AzureADTokenExchange"]
}
```

#### 2. Azure RM Federated Credential
```json
{
  "name": "AzureDevOps-ARM-Connection",
  "issuer": "https://vstoken.dev.azure.com/5c70574c-e790-401e-894d-6aef57901848",
  "subject": "sc://kai-lab/py-flask/Azure-Subscription",
  "description": "Federated credential for Azure RM service connection in Azure DevOps",
  "audiences": ["api://AzureADTokenExchange"]
}
```

#### 3. AKS Federated Credential
```json
{
  "name": "AzureDevOps-AKS-Connection",
  "issuer": "https://vstoken.dev.azure.com/5c70574c-e790-401e-894d-6aef57901848",
  "subject": "sc://kai-lab/py-flask/aks-dev-connection",
  "description": "Federated credential for AKS service connection in Azure DevOps",
  "audiences": ["api://AzureADTokenExchange"]
}
```

**建立命令**:
```bash
az ad app federated-credential create --id d25e759a-141c-4100-b680-5a21c0a11a6a --parameters /tmp/federated-credential.json
```

## 📊 最終狀態

### 成功建立的 Service Connections

| 名稱 | 類型 | 狀態 | ID | 用途 |
|------|------|------|----|----|
| `Azure-Subscription` | azurerm | ✅ Ready | `7e7643da-13f2-432a-86d4-7d56320cc7e9` | Azure 資源管理 |
| `acrdev9vgrsdq8` | dockerregistry | ✅ Ready | `7b25d09e-c63e-4a26-83ee-13de99477d17` | Docker 映像推送 |
| `yk-cheng` | GitHub | ✅ Ready | `d617b74e-2edd-4a55-a111-84ec71338c19` | 程式碼存取 |

### 待建立的 Service Connections

| 名稱 | 類型 | 狀態 | 建議方法 |
|------|------|------|---------|
| `aks-dev-connection` | kubernetes | ❌ Failed | 手動在網頁建立 |

## 🔍 問題分析與解決方案

### 問題 1: ACR Service Connection 初始建立失敗

**問題描述**: 使用複雜配置建立 ACR connection 時一直停留在 `InProgress` 狀態

**解決方案**: 使用簡化的 `UsernamePassword` scheme 配置
- ✅ 移除不必要的 metadata
- ✅ 使用 Service Principal ID 作為 username
- ✅ 使用 Service Principal secret 作為 password

### 問題 2: AKS Service Connection 建立失敗

**問題描述**: 所有嘗試都出現 "Azure environment is not provided" 錯誤

**嘗試的解決方案**:
1. ❌ 添加 environment 欄位 → 不被接受的欄位
2. ❌ 添加 azureSubscriptionEndpointId → 不被接受的欄位
3. ❌ 使用 Federated Credentials → 仍然失敗

**最終建議**: 在 Azure DevOps 網頁上手動建立 AKS Service Connection

### 問題 3: 認證方式演進

**發現**: Azure DevOps 正在從 Service Principal 密鑰轉向 Workload Identity Federation

**行動**: 為所有 Service Connections 預先建立 Federated Credentials，為未來做準備

## 🚀 Pipeline 配置更新

### 更新的變數
```yaml
variables:
  containerRegistry: 'acrdev9vgrsdq8'  # 匹配 Service Connection 名稱
  imageRepository: 'py-flask'
```

### Service Connections 在 Pipeline 中的使用
```yaml
# ACR Push
- task: Docker@2
  inputs:
    containerRegistry: 'acrdev9vgrsdq8'  # ✅ Ready

# AKS Deploy  
- task: KubernetesManifest@0
  inputs:
    kubernetesServiceConnection: 'aks-dev-connection'  # ❌ 需手動建立
```

## 📈 建議的下一步

### 立即可執行
1. ✅ **測試 ACR 部分**: 執行 Build stage 驗證 Docker build 和 push
2. ✅ **驗證權限**: 確認 Service Principal 可以存取 ACR

### 需要手動完成
1. 🔧 **在網頁建立 AKS Service Connection**: 使用 Azure DevOps 界面
2. 🔧 **建立 Environment**: 為 AKS deployment 建立環境

### 優化選項
1. 💡 **使用 Azure CLI Tasks**: 替代 Kubernetes tasks 避免 Service Connection 問題
2. 💡 **實施完整 Workload Identity**: 完全移除 Service Principal 密鑰依賴

## 🔧 故障排解

### 常見錯誤與解決方案

#### ACR Login 失敗
```bash
# 測試 Service Principal 是否能訪問 ACR
az acr login --name acrdev9vgrsdq8 --username YOUR_SERVICE_PRINCIPAL_ID --password "YOUR_SERVICE_PRINCIPAL_SECRET"
```

#### 檢查 Service Connection 狀態
```bash
az devops service-endpoint list --project py-flask --query "[].{Name:name,Type:type,Status:isReady}" -o table
```

#### 檢查角色分配
```bash
az role assignment list --assignee d25e759a-141c-4100-b680-5a21c0a11a6a --query "[].{Role:roleDefinitionName,Scope:scope}" -o table
```

### 權限檢查清單

#### Service Principal 權限
- ✅ **訂閱層級**: Contributor
- ✅ **ACR**: AcrPush + Owner
- ✅ **AKS**: Azure Kubernetes Service Cluster Admin Role

#### Federated Credentials
- ✅ **ACR**: `sc://kai-lab/py-flask/acrdev9vgrsdq8`
- ✅ **Azure RM**: `sc://kai-lab/py-flask/Azure-Subscription`  
- ✅ **AKS**: `sc://kai-lab/py-flask/aks-dev-connection`

## 📞 參考資源

### Azure 官方文檔
- [Azure DevOps Service Connections](https://docs.microsoft.com/azure/devops/pipelines/library/service-endpoints)
- [Workload Identity Federation](https://docs.microsoft.com/azure/active-directory/workload-identities/workload-identity-federation)
- [ACR Authentication](https://docs.microsoft.com/azure/container-registry/container-registry-authentication)

### 相關指令參考
```bash
# Azure DevOps CLI Extension
az extension add --name azure-devops

# 設定預設組織
az devops configure --defaults organization=https://dev.azure.com/kai-lab/

# 列出所有 service endpoints
az devops service-endpoint list --project py-flask
```

## 📝 學習重點

### 成功因素
1. **簡化配置**: 複雜的配置往往導致失敗，簡化的配置更容易成功
2. **權限充足**: 確保 Service Principal 有足夠權限
3. **現代認證**: Federated Credentials 是未來趨勢

### 挑戰
1. **CLI 限制**: 某些 Service Connection 類型透過 CLI 建立困難
2. **文檔落差**: 實際需求與文檔說明有差異
3. **認證演進**: 從密鑰認證轉向 Workload Identity 的過渡期

---

**最後更新**: 2025-08-08  
**維護者**: DevOps Team  
**狀態**: ACR 和 Azure RM 連接成功，可進行 Build 和 Push 測試