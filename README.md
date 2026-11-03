# 新竹市消防局 金山分隊到院前救護 OHCA 現場紀錄與決策輔助 App

專為**高壓、吵雜、分秒必爭之 OHCA 急救現場**設計的手機應用程式，專注於協助現場指揮官（Leader）與救護技術員（EMT）精準掌握 CPR 循環節奏、給藥時間點與下一步 ACLS 決策。

---

## 📱 App 核心畫面說明 (Screen Previews)

| 1. 急救主操作與 Leader 指令卡 | 2. 捷運圖連續時間軸 (Metro Rail) | 3. 一鍵 LINE 救護報告交接 |
| :---: | :---: | :---: |
| <img src="docs/screenshots/01_main_active_cpr.jpg" width="260" alt="急救主操作畫面"/> | <img src="docs/screenshots/02_continuous_timeline.jpg" width="260" alt="連續圖示時間軸"/> | <img src="docs/screenshots/03_line_report_export.jpg" width="260" alt="LINE 救護通報格式"/> |
| **金山分隊專屬主畫面**<br>• 指令驅動 CPR 2分鐘倒數<br>• 動態 ACLS 決策指引卡<br>• Epinephrine 給藥冷卻指示<br>• LUCAS、SGA、IV/IO 處置鍵 | **圖示化連續時間軸**<br>• 站點式時間軸（接觸➔CPR➔電擊➔ROSC）<br>• 急診交接儀表板（總按壓時間/Shock/Epi）<br>• 快速檢視關鍵醫療處置節點 | **金山分隊標準通報格式**<br>• 單位預設「金山91」<br>• 地點、案情、病史快速輸入彈窗<br>• 一鍵複製直接貼入分隊 LINE 群組 |

---

## 🌟 核心特色 (現場指令驅動設計)

1. **現場指令驅動倒數 (Leader Command-Driven Timing)**：
   - **絕不擅自跳轉或盲目空轉**：所有 CPR、AED 心律分析、電擊與給藥時間點，皆由現場指揮官（Leader）於聽到/下達現場口令後點擊記錄。
   - **指令下達後啟動倒數**：點擊「指令下達：開始 CPR」即刻精確記錄時間並啟動 2 分鐘倒數；點擊「現場 AED 分析」立即記錄分析時間並暫停按壓計時；點擊「現場執行電擊」精確記錄電擊時間，提示 Leader 下達「立即恢復按壓」，並在按下恢復時重啟下一輪 120 秒倒數。
   - **2 分鐘循環超時警示**：若 2 分鐘循環已滿但現場尚未分析心律，App 顯示超時秒數（如 `+00:15`）並語音警示，等待 Leader 現場指令。
2. **動態 ACLS 決策指引卡**：
   - 即時根據心律判定（VF/pVT vs PEA/Asystole）與電擊/給藥進度，動態顯示下一步處置建議。
   - 4H4T 可逆病因一鍵檢核抽屜。
3. **Epinephrine 智慧冷卻計時**：
   - Leader 下達給藥指令後點擊，記錄時間並啟動 4 分鐘倒數，T-30s 預告、T-0s 提示可下達下一劑。
4. **新竹市專屬裝備與進階處置**：
   - **LUCAS 2/3** 自動心肺復甦機上機與運轉計時。
   - **EZ-IO 骨內針** 與周邊靜脈（IV）穿刺部位快速標記。
   - **SGA (i-gel) / ETT 氣管插管**（含視訊喉頭鏡與深度設定）。
   - **ETCO2 連續數值監測**（突升自動提示 ROSC 評估）。
5. **金山分隊標準 LINE 救護通報格式（支援即時快速編輯）**：
   - 單位預設 **金山91**，出勤同仁名單留空由現場彈性填寫。
   - 彈出視窗支援快速填寫：**出勤地點**、**患者姓名/性別/年齡**、**案情簡述**、**過去病史與過敏史**。
   - 自動匯入時間鏈與統計數據（CPR 歷時、LUCAS、電擊次數、給藥清單），一鍵複製直接轉傳。
6. **案件封存與多案管理 (Case Archive & History)**：
   - 急救結束可選結局（ROSC 送醫、送抵急診交接、現場終止急救 TOR）。
   - 支援「僅存檔」與「存檔並立即開新案」雙模式，並可隨時翻查歷史紀錄與重新匯出報告。

---

## 📋 金山分隊 LINE 通報範例

```text
金山分隊報告
1.出勤時間：9月3日20時51分
2.單位：金山91
3.救護類別：OHCA-救護
4.地點：新竹市東區光復路一段O號
5.患者：王O明，男性，68歲
6.案情：
現場家屬表示患者突倒地無意識無反應，91人員到達評估無呼吸無脈搏，立即實施 CPR 及各項急救處置。

【⏱️ 現場急救處置與時間鏈】
- 接觸患者：20:51:15
- 開始CPR：20:51:30
- 首次電擊：20:52:45 (200J)
- 送醫出發：21:05:20
- 抵達醫院：21:12:10
- 恢復循環 (ROSC)：21:09:40 🌟

【⚡ 處置統計摘要】
- CPR 總歷時：20分40秒 (共 10 循環)
- LUCAS 機械按壓：已使用 (運轉約 16分15秒)
- 去顫電擊：共 2 次 [20:52:45(200J)、20:54:50(200J)]
- Epinephrine 1mg：共 3 劑 [20:53:10、20:57:15、21:01:20]
- 呼吸道處置：SGA (i-gel) #4
- 血管通路：EZ-IO 骨內針 (右側近端脛骨)
- ETCO2 最新數值：38 mmHg
金山91人員持續急救後送往新竹台大分院急診室交接。

7.過去病史：高血壓、心臟病。
  過敏史：無。
8.出勤人員：
金山 隊員A（T2)
金山 隊員B（T2)
金山 志工C（T1)

TP隊員D(輪休)
TP隊員E(輪休)

【📜 詳細處置事件歷程】
1. [20:51:15] 接觸患者
2. [20:51:30] 開始 CPR (第 1 循環開始)
...
```

---

## 📁 專案架構 (Flutter Layered Architecture)

```text
OHCA App/
├── lib/
│   ├── main.dart                                # 應用程式進入點 (鎖定直向、暗色高對比主題)
│   ├── domain/
│   │   ├── models/
│   │   │   ├── rhythm_type.dart                 # 心律類型 (VF, pVT, PEA, Asystole, ROSC)
│   │   │   ├── cpr_event.dart                   # 急救事件模型
│   │   │   ├── ohca_session.dart                # 完整出勤案件資料模型
│   │   │   └── decision_guidance.dart           # ACLS 決策指引模型
│   │   └── engine/
│   │       └── ohca_decision_engine.dart        # ACLS 臨床決策演算法
│   ├── data/
│   │   ├── services/
│   │   │   ├── tts_service.dart                 # 中文語音播報服務
│   │   │   ├── vibration_service.dart           # 觸覺與強烈震動回饋
│   │   │   └── line_report_formatter.dart       # 金山分隊標準 LINE 報告產生器
│   │   └── repositories/
│   │       └── session_repository.dart          # 本機離線儲存與歸檔管理
│   └── ui/
│       ├── core/
│       │   └── app_colors.dart                  # 高對比救護專用顏色庫
│       └── features/
│           ├── active_cpr/
│           │   ├── view_models/
│           │   │   └── active_cpr_view_model.dart # 核心狀態機與計時器
│           │   └── views/
│           │       ├── active_cpr_screen.dart   # 急救操作主畫面
│           │       └── widgets/                 # 計時卡、決策卡、處置面板、LINE 輸入視窗、結束案件彈窗
│           └── timeline/
│               └── views/
│                   └── timeline_sheet.dart      # 捷運圖連續時間軸與交接儀表板
├── test/
│   ├── ohca_decision_engine_test.dart           # 決策引擎單元測試
│   └── line_report_formatter_test.dart          # 金山分隊通報格式化測試
└── web/
    └── index.html                               # 獨立即時網頁預覽 (免安裝 Flutter 即可立即測試)
```

---

## 🚀 快速啟動與安裝方式

### 1. Android 原生安裝（直接安裝）
- 專案根目錄已產出最新編譯版：[`jinshan_ohca_app.apk`](jinshan_ohca_app.apk)
- 直接將該 APK 檔案傳輸至 Android 手機點擊即可安裝更新。

### 2. 瀏覽器即時體驗 (免安裝 Flutter)
在終端機執行或雙擊開啟 `web/index.html`：
```bash
python3 -m http.server 8080 -d web
```
開啟瀏覽器前往 `http://localhost:8080`，即可完整體驗金山分隊 OHCA 紀錄系統！

### 3. 以 Flutter 開發與編譯
```bash
# 取得套件依賴
flutter pub get

# 執行單元測試
flutter test

# 打包 Android Release APK
flutter build apk --release

# 打包 Web 版
flutter build web --release
```
