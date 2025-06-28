#!/bin/bash
#
# Ansible 環境安裝腳本
#
# 功能：
# 1. 更新系統套件清單
# 2. 安裝 Python 虛擬環境模組
# 3. 建立 Python 虛擬環境
# 4. 提供後續手動安裝指令

set -e

# 更新套件清單
echo "正在更新套件清單..."
sudo apt update

# 確保安裝 Python venv 模組
echo "正在安裝 Python venv 模組..."
sudo apt install -y python3.12-venv

# 建立 Python 虛擬環境 (如果不存在)
if [ ! -d ".venv" ]; then
  echo "正在建立 Python 虛擬環境..."
  python3 -m venv .venv
  echo "虛擬環境建立完成: .venv"
else
  echo "虛擬環境已存在: .venv"
fi

echo "安裝完成！"
echo ""
echo "後續步驟請手動執行:"
echo "1. 啟動虛擬環境:"
echo "   source .venv/bin/activate"
echo ""
echo "2. 升級 pip 並安裝所需套件:"
echo "   pip install --upgrade pip"
echo "   pip install ansible requests joblib tqdm"
echo ""
echo "3. 開始使用 Ansible:"
echo "   ansible-playbook -i ansible/inventories/hosts.ini ansible/playbooks/install_k3s.yaml"

# 以下指令需要手動執行
# # 啟動虛擬環境
# source .venv/bin/activate

# # 升級 pip 並安裝 Ansible 和相關套件
# pip install --upgrade pip
# pip install ansible requests joblib tqdm

# echo "虛擬環境和 Ansible 準備就緒。"