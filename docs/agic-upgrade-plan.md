# AGIC 升級計畫

**目標**: 將 nginx Ingress Controller 升級為 Azure Application Gateway Ingress Controller (AGIC)

## 📋 當前架構

### 現況 (nginx Ingress)
```
Internet → LoadBalancer → nginx Ingress Controller (Pod) → Flask App (Pod)
```

- **Ingress Controller**: nginx (部署在 AKS 內)
- **External Access**: LoadBalancer Service
- **Configuration**: `spec.ingressClassName: "nginx"`

## 🎯 目標架構

### 升級後 (AGIC)
```
Internet → Azure Application Gateway → Flask App (Pod) 直接路由
```

- **Ingress Controller**: AGIC (監控 K8s Ingress，配置 Application Gateway)
- **External Access**: Azure Application Gateway (外部資源)
- **Configuration**: `spec.ingressClassName: "azure-application-gateway"`

## 🛠️ 升級步驟

### 階段 1: 準備工作
- [ ] 確認 Azure Application Gateway 已部署並設定
- [ ] 驗證 AGIC Add-on 在 AKS 上已啟用
- [ ] 檢查 Application Gateway 與 AKS 的網路連接

### 階段 2: 更新 Ingress 配置
- [ ] 修改 `ingress.yaml`:
  ```yaml
  metadata:
    annotations:
      # 移除 nginx 相關 annotations
      # nginx.ingress.kubernetes.io/rewrite-target: /
      
      # 新增 AGIC annotations
      appgw.ingress.kubernetes.io/ssl-redirect: "false"
      appgw.ingress.kubernetes.io/use-private-ip: "false"
      appgw.ingress.kubernetes.io/backend-path-prefix: "/"
  spec:
    ingressClassName: "azure-application-gateway"  # 改為 AGIC
  ```

### 階段 3: Service 配置調整
- [ ] 確認 Service type 可以改為 ClusterIP (不需要 LoadBalancer)
- [ ] 驗證 Service port 配置與 Application Gateway 相容

### 階段 4: 測試與驗證
- [ ] 部署更新後的配置
- [ ] 測試外部存取功能
- [ ] 驗證流量路由正常
- [ ] 效能測試 (AGIC 通常效能更佳)

### 階段 5: 清理
- [ ] 移除不需要的 nginx Ingress Controller (如果沒有其他應用使用)
- [ ] 清理 LoadBalancer Service (如果改用 ClusterIP)

## 📊 比較表

| 特性 | nginx Ingress | AGIC |
|------|---------------|------|
| **部署位置** | AKS 內部 Pod | Azure 管理服務 |
| **效能** | 經過 AKS 內部轉發 | 直接路由到 Pod |
| **擴展性** | 受限於 AKS 資源 | Azure Application Gateway 擴展 |
| **SSL 終止** | nginx Pod 內 | Application Gateway 層級 |
| **維護** | 需要管理 nginx Pod | Azure 託管 |
| **成本** | AKS 計算資源 | Application Gateway 費用 |
| **設定複雜度** | 中等 | 需要 Azure 資源整合 |

## ⚠️ 注意事項

1. **費用影響**: Application Gateway 有固定費用，評估成本效益
2. **網路設定**: 確保 Application Gateway 與 AKS 網路互通
3. **SSL 憑證**: 需要在 Application Gateway 層級管理憑證
4. **監控**: 監控工具需要調整為支援 Application Gateway
5. **回滾計畫**: 準備回滾到 nginx 的程序

## 🔧 相關資源

### Terraform 模組
- Application Gateway 模組: `terraform/modules/application-gateway/`
- AGIC 整合設定: 需要在 AKS 模組中啟用

### 文檔參考
- [AGIC 官方文檔](https://docs.microsoft.com/en-us/azure/application-gateway/ingress-controller-overview)
- [AKS AGIC Add-on](https://docs.microsoft.com/en-us/azure/application-gateway/ingress-controller-install-new)

---

**建立日期**: 2025-08-11  
**狀態**: 規劃中  
**優先級**: P2 (效能改善)  
**負責人**: DevOps Team