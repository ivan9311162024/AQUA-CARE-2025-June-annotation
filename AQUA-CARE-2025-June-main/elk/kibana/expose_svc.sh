#!/usr/bin/env bash
#
# Kibana 服務端口轉發腳本
# 
# 將 Kibana 服務的 5601 端口轉發到本地端口 5601
# 讓使用者可以透過 http://localhost:5601 存取 Kibana 介面

kubectl port-forward svc/kibana-kibana 5601:5601
