# Flask Azure DevOps 專案

## 專案概述

這是一個簡單的 Python Flask 網站專案，主要用於測試 Azure DevOps CI/CD pipeline。目標是建立一個可以成功部署的基本網站。

## 技術棧

- **後端框架**: Python Flask
- **部署平台**: Azure Web App
- **CI/CD**: Azure DevOps Pipeline
- **Python 版本**: 3.9+

## 專案結構

```text
flask-azure-devops/
├── app.py                 # Flask 主程式
├── requirements.txt       # Python 依賴
├── azure-pipelines.yml    # CI/CD 配置
├── templates/
│   └── index.html        # 主頁模板
└── claude.md             # 這個文件
```

## 開發原則

### 程式碼風格

- 使用簡潔、易讀的程式碼
- 遵循 PEP 8 Python 編碼規範
- 添加適當的註解說明
- 保持函數簡短且功能單一

### Flask 應用程式要求

- 所有路由都要有錯誤處理
- 使用環境變數來配置設定
- 確保應用程式可以在 Azure Web App 上運行
- 提供健康檢查端點

### Azure DevOps 整合

- Pipeline 必須包含建置、測試、部署階段
- 使用適當的觸發條件 (main/master branch)
- 確保部署腳本與 Azure Web App 相容
- 包含適當的錯誤處理和回滾機制

## 當前功能

- 主頁面顯示專案狀態
- `/health` - 應用程式健康檢查
- `/api/info` - 基本應用程式資訊
- 響應式網頁設計
- Azure DevOps Pipeline 配置

## 開發指導

### 新增功能時請考慮

1. 是否需要更新 requirements.txt
2. 是否需要新的環境變數
3. 是否需要更新 Pipeline 配置
4. 是否需要添加測試

### 偏好的解決方案

- 優先使用 Flask 內建功能
- 最小化外部依賴
- 確保跨平台相容性
- 保持配置簡單明確

### 避免的做法

- 不要硬編碼敏感資訊
- 不要使用複雜的資料庫配置（這只是測試專案）
- 避免過度工程化

## 測試策略

- 基本的端點測試
- 健康檢查驗證
- Pipeline 整合測試

## 部署注意事項

- 確保 gunicorn 正確配置
- 檢查 Azure Web App 的 Python 版本相容性
- 驗證所有環境變數都已設定

## 參考資源

- [Flask 官方文檔](https://flask.palletsprojects.com/)
- [Azure DevOps 文檔](https://docs.microsoft.com/en-us/azure/devops/)
- [Azure Web Apps for Python](https://docs.microsoft.com/en-us/azure/app-service/quickstart-python)
