#!/usr/bin/env bash
#
# Elasticsearch API 金鑰測試腳本
#
# 功能：使用 API 金鑰測試 Elasticsearch 連線
# 查詢叢集健康狀態以驗證 API 金鑰是否有效

set -euo pipefail

# 設定 API 金鑰 (請替換為實際的 API 金鑰)
ES_APIKEY="Nk5ZOGM1Y0JkVjVWNTl1REo3RXk6Y3pyTXJsX3BSdTJweUpBYlBob0VSUQ=="
ES_URL="https://localhost:9200"

# 使用 API 金鑰查詢叢集健康狀態
echo "使用 API 金鑰測試 Elasticsearch 連線..."
curl -k -H "Authorization: ApiKey $ES_APIKEY" \
     "$ES_URL/_cluster/health?pretty"
echo
