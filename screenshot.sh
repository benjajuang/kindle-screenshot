#!/bin/bash

# Kindle 視窗截圖腳本 (macOS Kindle App 專用)
# 更新：改用 open -b 啟動 Kindle，避免找不到 "Kindle" 應用程式 (-1728)

# ✅ 請先確認以下三項系統權限都已開啟給 Terminal：
# - 系統設定 > 隱私與安全性 > 螢幕錄製
# - 系統設定 > 隱私與安全性 > 輔助使用
# - 系統設定 > 隱私與安全性 > 自動化（允許 Terminal 控制 System Events）

# 詢問要截圖的頁數
read -p "請輸入要截圖的頁數: " PAGES

echo "即將截取 Kindle 視窗共 $PAGES 頁，請先將 Kindle APP 視窗定位到起始頁並停好位置…"
read -p "確認後按 Enter 開始。"

# 建立輸出資料夾
OUTDIR="/Users/benm4pro/Documents/kindle screenshot/KindleWindowShots_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUTDIR"
echo "截圖檔案將儲存於：$OUTDIR"


# 循環截圖 & 翻頁
for ((i=1; i<=PAGES; i++)); do
  # 1. 強制喚醒 Kindle App（使用 bundle ID，不依賴名稱）
  open -b com.amazon.Lassen
  sleep 1

  # 2. 取得 Kindle 視窗位置與尺寸
  POS=$(osascript -e 'tell application "System Events" to get position of window 1 of process "Kindle"')
  SIZE=$(osascript -e 'tell application "System Events" to get size of window 1 of process "Kindle"')

  POS=($(echo ${POS//,/}))   # 分割為陣列 [x y]
  SIZE=($(echo ${SIZE//,/})) # 分割為陣列 [w h]
  x=${POS[0]}; y=${POS[1]}; w=${SIZE[0]}; h=${SIZE[1]}

  if [[ -z "$x" || -z "$y" || -z "$w" || -z "$h" ]]; then
    echo "❌ 無法取得 Kindle 視窗座標/尺寸，請確認權限設定與 Kindle 是否開啟。"
    exit 1
  fi

  # 3. 擷取指定區域
  GEOM="${x},${y},${w},${h}"
  screencapture -R"$GEOM" -x "$OUTDIR/page_$(printf "%03d" $i).png"
  echo "✅ 已截第 $i 頁 (區域: $GEOM)。"

  # 4. 模擬按右鍵翻頁
  osascript -e 'tell application "System Events" to key code 124'
  sleep 0.8
done

echo "🎉 全部完成！所有截圖已存於：$OUTDIR"
