# CNI 與 VNet 架構深度分析

## 概述

本文檔深入分析 Azure CNI 與 VNet 的架構關係，以及雲端與地端 CNI 實作的根本差異。

## 🔍 Azure CNI 與 VNet 的綁定機制

### AKS 網路架構現狀

#### 當前配置
```
VNet: vnet-aks-dev (10.0.0.0/8)
├── Service CIDR: 10.0.0.0/24    ← Kubernetes Services (虛擬網路)
├── DNS Service:  10.0.0.10      ← CoreDNS
├── AKS Subnet:   10.0.1.0/24    ← Node Pool & Pod IP (CNI 管理)
├── AGW Subnet:   10.0.2.0/24    ← Application Gateway (CNI 不管理)
└── 可用空間:     10.0.3.0/24+   ← 未來 Node Pool 可用
```

#### CNI 管理範圍驗證
- **已管理的 Subnet**: 10.0.1.0/24 (透過 Node Pool 指定)
- **已使用的 Pod IP**: 10.0.1.10~10.0.1.57 (實際分配)
- **不受管理**: 10.0.2.0/24 (Application Gateway 專用)

### Azure CNI 的動態管理機制

#### 核心運作原理
```
Azure CNI 的動態綁定流程：
┌─────────────────────────────────────────┐
│ 1. 建立 Node Pool 時指定 subnet         │
│ 2. Azure 自動將該 subnet 加入 CNI 管理  │
│ 3. CNI Agent 在新節點上啟動             │
│ 4. 從指定 subnet 預分配 IP 池 (30個/節點)│
│ 5. 動態分配 IP 給新建的 Pod             │
│ 6. 自動建立跨 subnet 路由規則           │
└─────────────────────────────────────────┘
```

#### 為什麼可以跨 Subnet 通訊？
1. **VNet 內建路由**: Azure VNet 預設同 VNet 內所有 subnet 互通
2. **真實 IP 分配**: Pod 取得真實的 VNet IP，無需 NAT
3. **Azure Fabric 路由**: 底層自動管理路由表
4. **Kubernetes Service**: 跨 subnet 透明運作

## 🆚 雲端 vs 地端 CNI 比較

### Azure CNI 的雲端優勢

#### 平台深度整合
```
Azure CNI 獨特能力：
┌─────────────────────────────────────────┐
│ 1. Azure API 知道 VNet 的所有 subnet    │
│ 2. AKS 與 Azure Fabric 深度整合         │
│ 3. Node Pool API 觸發 CNI 自動重配置    │
│ 4. 無需手動管理 IP Pool 或路由          │
└─────────────────────────────────────────┘
```

#### 自動化特性
- ✅ **Zero-config**: 新 Node Pool 自動配置網路
- ✅ **動態發現**: 自動偵測新的 subnet 配置
- ✅ **路由自動化**: Azure Fabric 處理所有路由
- ✅ **大範圍支援**: 可輕鬆使用 10.0.0.0/8 等大網段

### 地端 CNI 的限制

#### 基礎設施隔離
```
地端 CNI 的現實限制：
┌─────────────────────────────────────────┐
│ 1. CNI 無法控制物理網路設備             │
│ 2. 無法自動發現新的網路段               │
│ 3. 需要手動配置 IP Pool 和路由          │
│ 4. 大網段 (10.0.0.0/8) 管理複雜度高    │
└─────────────────────────────────────────┘
```

#### 支援大 CIDR 的地端 CNI

| CNI | 大 CIDR 支援 | 實務考量 |
|-----|-------------|---------|
| **Calico** | ✅ 支援 10.0.0.0/8 | 路由表可能過大，需要階層規劃 |
| **Cilium** | ✅ 支援但需調優 | eBPF 限制，記憶體使用量高 |
| **Flannel** | ✅ 基本支援 | VXLAN 封包開銷，效能影響 |

#### 地端最佳實踐
```yaml
# 推薦的地端網段規劃
小型集群: 10.0.0.0/16   (65K IP)
中型集群: 10.0.0.0/12   (1M IP)  
大型集群: 分多個集群管理，避免單一巨大 CIDR
```

## 🏗️ 雲端 vs 地端架構差異

### Node Pool vs 個別 Node 管理

#### 雲端 (AKS) 的 Node Pool 概念
```
AKS Node Pool 特性：
┌─────────────────────────────────────────┐
│ Node Pool = 一群同質化機器的集合        │
│                                         │
│ Dev Pool     │ Stage Pool   │ Prod Pool │
│ ├─ VM (同)   │ ├─ VM (同)   │ ├─ VM (同) │
│ ├─ VM (同)   │ ├─ VM (同)   │ ├─ VM (同) │
│ └─ VM (同)   │ └─ VM (同)   │ └─ VM (同) │
│              │              │           │
│ 優勢:                                   │
│ - 環境隔離清楚                          │
│ - 管理簡單                              │
│ - 自動擴展                              │
│ - 故障自動處理                          │
└─────────────────────────────────────────┘
```

#### 地端的個別 Node 管理
```
地端 Node 特性：
┌─────────────────────────────────────────┐
│ 每台機器都是獨立個體                    │
│                                         │
│ Cluster                                 │
│ ├─ Server-1 (Dell R640, 32GB)          │
│ ├─ Server-2 (HP DL380, 64GB)           │
│ ├─ Server-3 (Dell R740, 128GB)         │
│ └─ Server-4 (舊機器, 16GB)             │
│                                         │
│ 優勢:                                   │
│ - 硬體異質化混用                        │
│ - 成本優化空間大                        │
│ - 逐步升級可能                          │
│ - 完全控制權                            │
└─────────────────────────────────────────┘
```

### 環境隔離策略

#### 雲端做法
```bash
# 透過 Node Pool 做天然隔離
az aks nodepool add --name dev-pool --node-taints="env=dev:NoSchedule"
az aks nodepool add --name prod-pool --node-taints="env=prod:NoSchedule"

# 工作負載自動調度到對應 Pool
apiVersion: v1
kind: Pod
spec:
  nodeSelector:
    agentpool: prod-pool
```

#### 地端做法
```bash
# 透過 Node 標籤和 Taint 做隔離
kubectl label node server-1 env=dev
kubectl label node server-3 env=prod
kubectl taint node server-3 env=prod:NoSchedule

# 需要額外的調度邏輯
```

## 🔧 CNI CIDR 管理機制

### Azure CNI 的 CIDR 檢查機制

#### 自動驗證規則
```
建立 Node Pool 時 Azure 會檢查：
┌─────────────────────────────────────────┐
│ 1. Service CIDR 衝突檢查                │
│    ❌ 不可使用 10.0.0.0/24             │
│                                         │
│ 2. VNet 範圍檢查                        │
│    ✅ 必須在 10.0.0.0/8 內             │
│                                         │
│ 3. Subnet 重疊檢查                      │
│    ❌ 不可與現有 subnet 重疊            │
│                                         │
│ 4. 動態加入 CNI 管理                    │
│    ✅ 自動納入 CNI 控制範圍             │
└─────────────────────────────────────────┘
```

#### 目前的網路分配
```
已使用的 CIDR:
├── 10.0.0.0/24  ← Service CIDR (虛擬網路)
├── 10.0.1.0/24  ← AKS Nodes & Pods  
├── 10.0.2.0/24  ← Application Gateway
└── 10.0.3.0/24+ ← 可用於新 Node Pool

CNI 實際管理:
└── 10.0.1.0/24 (透過 Node Pool 指定)
    ├── Node IP: 10.0.1.10, 10.0.1.39
    └── Pod IP:  10.0.1.10~10.0.1.57
```

### 新 Node Pool 的網路整合

#### 整合流程
```bash
# 1. 建立新 subnet
az network vnet subnet create \
  --name subnet-aks-new \
  --address-prefix 10.0.3.0/24

# 2. 建立 Node Pool 綁定新 subnet
az aks nodepool add \
  --name newpool \
  --vnet-subnet-id "/subscriptions/.../subnets/subnet-aks-new"

# 3. Azure CNI 自動處理
# - 將 10.0.3.0/24 納入管理
# - 建立跨 subnet 路由
# - 確保 Pod 間互通
```

#### 跨 Subnet 通訊驗證
```
新舊 Node Pool 互通性：
┌─────────────────────────────────────────┐
│ Pod A (10.0.1.50) ←→ Pod B (10.0.3.20)  │
│                                         │
│ 通訊路徑:                               │
│ Pod A → VNet 路由 → Pod B               │
│                                         │
│ 無需額外配置:                           │
│ ✅ Kubernetes Service 跨 subnet 運作    │
│ ✅ DNS 解析正常                         │
│ ✅ 網路策略適用                         │
└─────────────────────────────────────────┘
```

## 💡 關鍵理解

### Azure CNI 的核心價值
1. **自動化程度**: 將地端手動管理 IP Pool 的工作完全自動化
2. **平台整合**: 與 Azure VNet 深度整合，提供無縫體驗
3. **動態管理**: 只管理被指派給 AKS 的 subnet，不是整個 VNet
4. **Zero-config**: 新 Node Pool 自動獲得網路配置

### 地端 CNI 的現實
1. **手動管理**: 必須手動配置每個 IP Pool
2. **靜態規劃**: 需要預先規劃網路拓撲
3. **複雜性**: 大網段管理會帶來路由和 IPAM 複雜度
4. **靈活性**: 但提供更高的客製化彈性

### 架構選擇考量
1. **雲端 Node Pool**: 適合標準化環境、快速擴展、環境隔離
2. **地端個別 Node**: 適合硬體異質化、成本優化、完全控制

## 🚀 實務建議

### 雲端環境
```bash
# 充分利用 Node Pool 特性
Dev Environment:    Standard_B2s  (便宜)
Stage Environment:  Standard_D4s  (中等)
Prod Environment:   Standard_D8s  (高性能)

# 網路規劃
每個環境使用不同 subnet:
dev:   10.0.10.0/24
stage: 10.0.20.0/24  
prod:  10.0.30.0/24
```

### 地端環境
```yaml
# 階層式網路規劃
datacenter:
  rack1: 10.1.0.0/16
  rack2: 10.2.0.0/16
  rack3: 10.3.0.0/16

# 避免過大的單一 CIDR
推薦: 多個 /16 而非單一 /8
```

## 結論

Azure CNI 通過與 Azure 平台的深度整合，實現了地端環境難以達到的自動化網路管理。其「只管理被指派的 subnet」的設計，既提供了靈活性，又保持了管理的簡潔性。這種雲端特有的架構優勢，正是企業選擇託管 Kubernetes 服務的重要原因之一。

---

*文檔建立日期：2025-08-15*  
*基於 AKS 集群：aks-dev-cluster (East Asia)*  
*VNet 配置：vnet-aks-dev (10.0.0.0/8)*