#!/usr/bin/env bash
# 
# Elasticsearch API 金鑰建立腳本
# 
# 功能：
# 1. 從 Kubernetes Secret 取得 Elasticsearch 認證資訊
# 2. 建立具有 IoT 資料寫入權限的 API 金鑰
# 3. 回傳編碼後的 API 金鑰供應用程式使用
#
# 權限範圍：
# - 叢集：監控和管理自己的 API 金鑰
# - 索引：對 iot-* 模式的索引具有建立和寫入權限

set -euo pipefail

# Elasticsearch 連線設定
ES_URL="https://localhost:9200"

# 1️⃣ 從 Kubernetes Secret 取得 Elasticsearch 基本認證資訊
ES_USER=$(kubectl get secret elasticsearch-master-credentials \
  -o jsonpath="{.data.username}" | base64 --decode)
ES_PASS=$(kubectl get secret elasticsearch-master-credentials \
  -o jsonpath="{.data.password}" | base64 --decode)

echo "使用 ES 帳號: $ES_USER $ES_PASS"

# 建立具有 IoT 索引寫入權限的 API 金鑰
API_JSON=$(curl -k -X POST -u "$ES_USER:$ES_PASS" \
  "$ES_URL/_security/api_key" \
  -H "Content-Type: application/json" \
  -d '{
        "name": "iot-key",
        "expiration": "30d",
        "role_descriptors": {
          "iot_writer": {
            "cluster": ["monitor","manage_own_api_key"],
            "indices": [{
              "names": ["iot-*"],
              "privileges": ["create_index","create","index","write"]
            }]
          }
        }
      }')

echo "API 金鑰建立回應:"
echo "$API_JSON" | jq .

# 提取編碼後的 API 金鑰
APIKEY=$(echo "$API_JSON" | jq -r .encoded)

# 驗證 API 金鑰是否成功建立
if [ -z "$APIKEY" ] || [ "$APIKEY" == "null" ]; then
  echo "❌ API 金鑰建立失敗!"
  exit 1
fi

echo "🌟 API 金鑰建立成功: $APIKEY"
