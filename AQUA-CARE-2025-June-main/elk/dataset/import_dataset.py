#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
水產養殖資料集匯入腳本

功能：
1. 讀取 CSV 格式的魚類水質監測資料
2. 建立 Elasticsearch 索引並定義資料結構
3. 批次匯入資料到 Elasticsearch
4. 使用多執行緒提升匯入效率

資料欄位：
- ph: 水質 pH 值 (浮點數)
- temperature: 水溫 (浮點數)  
- turbidity: 濁度 (浮點數)
- fish: 魚種類別 (字串)
"""

import csv
import requests
import os
from joblib import Parallel, delayed
from tqdm import tqdm
import warnings
import urllib3
from urllib3.exceptions import InsecureRequestWarning

# 抑制 SSL 憑證警告，用於開發環境
warnings.simplefilter('ignore', InsecureRequestWarning)
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# Elasticsearch 連線設定
ES_APIKEY = os.getenv("ES_APIKEY", "Nk5ZOGM1Y0JkVjVWNTl1REo3RXk6Y3pyTXJsX3BSdTJweUpBYlBob0VSUQ==")
ES_URL = os.getenv("ES_URL", "https://localhost:9200")
INDEX_NAME = "iot-fishdata"  # 索引名稱
CSV_FILE = "realfishdataset.csv"  # 資料檔案

# HTTP 請求標頭設定
headers = {
    "Authorization": f"ApiKey {ES_APIKEY}",
    "Content-Type": "application/json"
}

def create_index():
    """
    建立 Elasticsearch 索引並定義資料欄位對應
    """
    # 定義索引的資料結構對應
    mapping = {
        "mappings": {
            "properties": {
                "ph": {"type": "float"},           # pH 值為浮點數
                "temperature": {"type": "float"},  # 溫度為浮點數
                "turbidity": {"type": "float"},    # 濁度為浮點數
                "fish": {"type": "keyword"}        # 魚種為關鍵字類型
            }
        }
    }
    resp = requests.put(f"{ES_URL}/{INDEX_NAME}", headers=headers, json=mapping, verify=False)
    print("索引建立回應:", resp.status_code, resp.text)

def import_csv_to_es():
    """
    讀取 CSV 檔案並匯入到 Elasticsearch
    使用多執行緒並行處理提升效率
    """
    with open(CSV_FILE, newline="") as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            # 轉換資料類型
            doc = {
                "ph": float(row["ph"]),
                "temperature": float(row["temperature"]),
                "turbidity": float(row["turbidity"]),
                "fish": row["fish"]
            }
            
            def send_request(doc):
                """發送單筆資料到 Elasticsearch"""
                return requests.post(f"{ES_URL}/{INDEX_NAME}/_doc", headers=headers, json=doc, verify=False)

            # 使用 joblib 進行並行請求處理
            # 初始化進度條
            if not hasattr(import_csv_to_es, "pbar"):
                import_csv_to_es.pbar = tqdm(total=None, desc="匯入資料行")

            # 並行執行請求 (使用 8 個執行緒)
            results = Parallel(n_jobs=8)(delayed(send_request)(doc) for _ in range(1))
            import_csv_to_es.pbar.update(1)
            
            resp = results[0]
            # 檢查回應狀態
            if resp.status_code not in (200, 201):
                print(f"資料匯入失敗: {doc}, 回應: {resp.status_code}, {resp.text}")

def main():
    """
    主程式入口
    1. 建立索引
    2. 匯入資料
    """
    create_index()
    import_csv_to_es()

if __name__ == "__main__":
    main()
