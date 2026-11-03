#!/bin/bash
# 新竹市消防局 OHCA 現場輔助 (金山分隊專用) - 一鍵啟動與安裝服務指令

PORT=8080
IP=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || echo "localhost")

echo "========================================================"
echo "  新竹市消防局到院前救護 OHCA 現場輔助 (金山分隊專用)"
echo "========================================================"
echo ""
echo "正在啟動安裝服務..."
echo ""
echo "▶ 本機電腦開啟：http://localhost:$PORT"
echo "▶ 手機/平板開啟 (同分隊 Wi-Fi 或熱點)：http://$IP:$PORT"
echo ""
echo "📱 手機直接安裝至主畫面方式："
echo "   - iPhone (iOS) ：Safari 開啟上方網址 -> 點底部「分享」圖示 -> 選擇「加入主畫面」"
echo "   - Android 手機：Chrome 開啟上方網址 -> 點右上選單 -> 選擇「加到主螢幕」或「安裝應用程式」"
echo ""
echo "安裝後即可脫離網路，在現場 100% 離線執行！"
echo "按 Ctrl + C 可隨時停止伺服器。"
echo "========================================================"

if [ -d "build/web" ]; then
  WEB_DIR="build/web"
else
  WEB_DIR="web"
fi

python3 -m http.server $PORT -d "$WEB_DIR"
