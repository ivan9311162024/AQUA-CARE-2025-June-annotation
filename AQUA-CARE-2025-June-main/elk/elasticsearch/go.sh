#!/usr/bin/env bash
#
# Elasticsearch 連線測試和狀態檢查腳本
#
# 功能：
# 1. 從 Kubernetes Secret 取得 Elasticsearch 認證資訊
# 2. 自動偵測 Elasticsearch 服務端口
# 3. 測試 Elasticsearch 服務可用性
# 4. 列出所有已建立的索引

set -euo pipefail

# 1️⃣ 從 Kubernetes Secret 取得基本認證帳號密碼
ES_ACCOUNT=$(kubectl get secret elasticsearch-master-credentials \
  -o jsonpath="{.data.username}" | base64 --decode)
ES_PASSWORD=$(kubectl get secret elasticsearch-master-credentials \
  -o jsonpath="{.data.password}" | base64 --decode)

echo "使用 ES 帳號: $ES_ACCOUNT $ES_PASSWORD"

# 取得 Elasticsearch Service 的暴露端口
ES_SVC_NAME="elasticsearch-master"
ES_NAMESPACE="default"
ES_PORT=$(kubectl get svc $ES_SVC_NAME -n $ES_NAMESPACE -o jsonpath='{.spec.ports[?(@.name=="http")].port}')

# 驗證端口是否成功取得
if [ -z "$ES_PORT" ]; then
  echo "❌ 無法確定 Elasticsearch 服務端口."
  exit 1
fi

# 取得本機外部 IP 位址
ES_HOST=$(curl -s ifconfig.me)
ES_URL="https://$ES_HOST:$ES_PORT"
echo "Elasticsearch URL: $ES_URL"

# 測試 Elasticsearch 服務是否可用
response=$(curl -k -s -o /dev/null -w "%{http_code}" -u "$ES_ACCOUNT:$ES_PASSWORD" "$ES_URL")
if [ "$response" -eq 200 ]; then
  echo "✅ Elasticsearch 服務可用."
else
  echo "❌ Elasticsearch 服務無法連線. HTTP 狀態碼: $response"
  exit 1
fi

# 列出所有 Elasticsearch 索引
echo "取得 Elasticsearch 索引清單..."
curl -k -s -u "$ES_ACCOUNT:$ES_PASSWORD" "$ES_URL/_cat/indices?v"
