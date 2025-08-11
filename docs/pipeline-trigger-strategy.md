# Pipeline 觸發策略

## 🎯 目標

優化 CI/CD Pipeline 觸發條件，避免不必要的建置執行，提高效率並節省資源。

## 📋 觸發條件配置

### ✅ **會觸發 Pipeline 的變更**

#### 應用程式程式碼
```
azure-devops/py-flask/
├── app.py                    # Flask 應用主程式
├── requirements.txt          # Python 依賴
├── Dockerfile               # Docker 建置配置
├── templates/               # Flask 模板
└── static/                  # 靜態檔案 (如果有)
```

#### 部署配置
```
azure-devops/py-flask/
├── k8s-manifests/           # Kubernetes 部署檔案
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   └── namespace.yaml
└── azure-pipelines-aks.yml  # Pipeline 配置本身
```

### ❌ **不會觸發 Pipeline 的變更**

#### 文檔變更
```
docs/                        # 所有文檔資料夾
├── *.md                     # 各種 Markdown 文檔
├── README.md               # 專案說明
└── runbooks/               # 操作手冊
```

#### 基礎設施程式碼
```
terraform/                   # Terraform 基礎設施 (有獨立 Pipeline)
├── modules/
├── environments/
└── *.tf
```

#### 臨時檔案
```
tmp/                        # 臨時設定檔
software/                   # Self-hosted Agent 檔案
*.log                       # 日誌檔案
```

## 🔧 配置範例

### 當前設定 (已優化)
```yaml
trigger:
  branches:
    include:
    - main
  paths:
    include:
    - azure-devops/py-flask/**
    exclude:
    - docs/**
    - '*.md'
    - terraform/**
    - tmp/**

pr:
  branches:
    include:
    - main
  paths:
    include:
    - azure-devops/py-flask/**
    exclude:
    - docs/**
    - '*.md'
    - terraform/**
    - tmp/**
```

## 📊 預期效果

### 🚀 **效率提升**
| 變更類型 | 之前 | 之後 |
|---------|------|------|
| **文檔更新** | ✅ 觸發 CI/CD | ❌ 不觸發 |
| **Terraform 更新** | ✅ 觸發 CI/CD | ❌ 不觸發 |
| **Flask 程式碼** | ✅ 觸發 CI/CD | ✅ 觸發 CI/CD |
| **K8s Manifests** | ✅ 觸發 CI/CD | ✅ 觸發 CI/CD |

### 💰 **資源節省**
- **Agent 使用時間**: 減少 ~60-80%
- **不必要的建置**: 文檔變更不再觸發
- **開發效率**: 更快的反饋週期

## 🎯 **進階觸發策略**

### 分支特定策略
```yaml
trigger:
  branches:
    include:
    - main
    - develop
    - release/*
  paths:
    include:
    - azure-devops/py-flask/**
```

### 多應用程式支援
如果未來有多個應用程式：
```yaml
# 應用程式 A
trigger:
  paths:
    include:
    - azure-devops/app-a/**

# 應用程式 B  
trigger:
  paths:
    include:
    - azure-devops/app-b/**
```

### 條件式部署
```yaml
# 只有特定檔案變更才部署到生產環境
- stage: DeployProduction
  condition: |
    and(
      eq(variables['Build.SourceBranch'], 'refs/heads/main'),
      or(
        contains(variables['Build.SourceVersionMessage'], '[deploy]'),
        eq(variables['forceProductionDeploy'], 'true')
      )
    )
```

## 🧪 **測試場景**

### 應該觸發的變更
1. 修改 `app.py` → ✅ 觸發
2. 更新 `requirements.txt` → ✅ 觸發
3. 修改 `deployment.yaml` → ✅ 觸發
4. 更新 `Dockerfile` → ✅ 觸發

### 不應該觸發的變更
1. 更新 `README.md` → ❌ 不觸發
2. 修改 `docs/guide.md` → ❌ 不觸發
3. 更改 Terraform 檔案 → ❌ 不觸發
4. 添加 `tmp/` 下的檔案 → ❌ 不觸發

## 📝 **最佳實踐**

1. **明確的路径過濾**: 使用具體的路径而非泛用規則
2. **測試觸發條件**: 定期驗證觸發邏輯是否正確
3. **文檔同步**: 確保觸發策略文檔與實際配置一致
4. **監控觸發頻率**: 追蹤觸發次數的變化
5. **靈活調整**: 根據團隊工作流程調整策略

## 🚨 **注意事項**

1. **Pipeline 配置變更**: 修改 `azure-pipelines-aks.yml` 本身會觸發 Pipeline
2. **萬用字符語法**: 使用正確的 glob 模式
3. **大小寫敏感**: 路径匹配區分大小寫
4. **斜線方向**: 使用 `/` 而非 `\`
5. **測試充分**: 確保重要變更不會被過濾掉

---

**建立日期**: 2025-08-11  
**最後更新**: 2025-08-11  
**維護者**: DevOps Team