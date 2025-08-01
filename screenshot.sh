#!/bin/bash

# Kindle 視窗截圖腳本 (macOS Kindle App 專用)
# 更新：自動使用 $HOME，並允許自訂輸出資料夾

# 1) 確認系統權限:
#   • 系統設定 > 隱私與安全性 > 螢幕錄製  
#   • 系統設定 > 隱私與安全性 > 輔助使用  
#   • 系統設定 > 隱私與安全性 > 自動化（允許 Terminal 控制 System Events）

# 2) 詢問要截圖的頁數
read -p "請輸入要截圖的頁數: " PAGES

# 3) 預設輸出資料夾
DEFAULT_OUTDIR="$HOME/Documents/kindle screenshot/KindleWindowShots_$(date +%Y%m%d_%H%M%S)"

# 4) 允許自訂
read -p "若要自訂輸出資料夾，請輸入完整路徑（按 Enter 使用預設: $DEFAULT_OUTDIR）: " CUSTOM_OUTDIR
OUTDIR="${CUSTOM_OUTDIR:-$DEFAULT_OUTDIR}"

echo "即將截取 Kindle 視窗共 $PAGES 頁，截圖將儲存於："
echo "  $OUTDIR"
read -p "確認後按 Enter 開始。"

# 5) 建資料夾
mkdir -p "$OUTDIR"

# 6) 主迴圈：截圖、翻頁
for ((i=1; i<=PAGES; i++)); do
  open -b com.amazon.Lassen           # 喚醒 Kindle
  sleep 1

  # 取得位置與尺寸
  POS=$(osascript -e 'tell application "System Events" to get position of window 1 of process "Kindle"')
  SIZE=$(osascript -e 'tell application "System Events" to get size of window 1 of process "Kindle"')
  POS=(${POS//,/}); SIZE=(${SIZE//,/})
  x=${POS[0]}; y=${POS[1]}; w=${SIZE[0]}; h=${SIZE[1]}

  if [[ -z "$x" || -z "$y" || -z "$w" || -z "$h" ]]; then
    echo "❌ 無法取得 Kindle 視窗座標/尺寸，請確認權限設定與 Kindle 是否開啟。"
    exit 1
  fi

  GEOM="${x},${y},${w},${h}"
  screencapture -R"$GEOM" -x "$OUTDIR/page_$(printf "%03d" $i).png"
  echo "✅ 已截第 $i 頁 (區域: $GEOM)。"

  osascript -e 'tell application "System Events" to key code 124'  # 右鍵翻頁
  sleep 0.8
done

echo "🎉 全部完成！所有截圖已存於：$OUTDIR"
