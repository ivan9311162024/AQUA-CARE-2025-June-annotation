# ELK Stack 部署指南

## 安裝順序

ELK Stack 各元件的 Helm 安裝命令，請按照以下順序執行：

```bash
# 進入 elk 目錄
cd elk/

# 1. 安裝 Elasticsearch (核心搜尋引擎)
helm install elasticsearch elastic/elasticsearch -f elasticsearch/values.yml

# 2. 安裝 Filebeat (日誌收集器)
helm install filebeat elastic/filebeat -f filebeat/values.yml

# 3. 安裝 Logstash (日誌處理器)
helm install logstash elastic/logstash -f logstash/values.yml

# 4. 安裝 Kibana (視覺化介面)
helm install kibana elastic/kibana -f kibana/values.yml
```

## 相關資源

### Filebeat 配置參考

- 影片教學：https://www.youtube.com/watch?v=GLGCJU4nR3M
