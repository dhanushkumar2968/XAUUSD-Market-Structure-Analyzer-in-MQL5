# XAUUSD Market Structure Analyzer

A MetaTrader 5 Expert Advisor (EA) that reads market structure on **D1, H4, and H1** and draws the analysis on the active chart. It is intended for XAUUSD symbols, including broker-suffixed names such as `XAUUSD.m`; the EA analyzes whichever symbol is open on the chart.

The project is a rule-based chart analyzer. It does not use machine learning, send orders, or manage positions. BOS, CHoCH/MSS, zones, levels, and the dashboard are analytical markings, not guaranteed trade signals.

## Features

- D1, H4, and H1 analysis continues while the chart is on another timeframe.
- Confirmed swing labels: HH, HL, LH, LL, EQH, and EQL.
- Closed-candle structure breaks: BOS, CHoCH, and MSS. The latest reversal event is highlighted with a dashed amber level and a direction/price label.
- Candidate and active support/resistance, reaction-based supply/demand zones, equal-high/equal-low liquidity pools, and sweep/reclaim annotations.
- Swing-anchored trendlines with a marked close-confirmed breakout.
- D1 analysis panel annotations, including a directional plan zone and its calculated SL/TP1/TP2/TP3 reference levels when a plan is valid. These are chart levels only; the EA does not submit those orders.
- Movable and resizable dashboard with D1/H4/H1 cards, an overall alignment decision, compact/expanded and show/hide controls, and per-timeframe/all-markings visibility controls.
- Chart drawings are configured to remain visible when the active chart timeframe changes. Marking visibility controls hide drawings without turning off analysis.

## Package contents

| File | Purpose |
| --- | --- |
| `XAUUSD_Market_Structure_Analyzer.mq5` | EA entry point: initialization, timer/tick updates, chart-event routing, and cleanup. |
| `MTFTrendAnalysis.mqh` | D1/H4/H1 structure calculations, event/zone/level detection, chart drawings, and dashboard. |
| `D1Analysis.mqh` | Additional D1 structure, indicator confirmation, and directional-plan chart annotations. |
| `.gitignore` | Excludes MetaEditor output (`.ex5`) and log files from source control. |

## Requirements

- MetaTrader 5 terminal and its MetaEditor compiler with MQL5 support.
- The three source files in the same EA folder so the two `#include` files resolve.
- Historical chart data for the chart symbol on H1, H4, and D1. Initial analysis uses up to 800 H1, 600 H4, and 360 D1 bars; D1 plan analysis requests up to 360 daily bars.
- No Python runtime, DLL, external API, credentials, or third-party MQL library is required.
- A broker symbol with valid price/tick information. XAUUSD is the intended symbol, but the code uses the active chart symbol rather than hard-coding a ticker.

## Install and compile

1. In MetaTrader 5, choose **File → Open Data Folder**.
2. Open `MQL5/Experts` and create a folder named `XAUUSD_Market_Structure_Analyzer`.
3. Copy the `.mq5` and both `.mqh` files from this package into that folder.
4. Open `XAUUSD_Market_Structure_Analyzer.mq5` in MetaEditor and compile it (F7).
5. In MetaTrader 5, refresh **Navigator → Expert Advisors**, then attach **XAUUSD_Market_Structure_Analyzer** to a chart.
6. Allow the terminal to download H1, H4, and D1 history. If a timeframe card says `INSUFFICIENT DATA` or waits for history, load more history and allow the EA to refresh.

The compiled `.ex5` file is generated locally by MetaEditor and is intentionally not tracked in Git. Compile the `.mq5` source for the terminal where you plan to run it.

## How the analysis works

1. **Read independent timeframe data.** The EA requests rates explicitly for H1, H4, and D1. The active chart timeframe is used for display placement, not as a replacement for those analysis timeframes.
2. **Confirm pivots.** Left/right swing-bar settings determine when a pivot becomes confirmed. Confirmed highs/lows are compared with prior swings and classified as HH/HL/LH/LL or equal highs/lows.
3. **Detect structure breaks.** A closed candle must cross a confirmed swing level by the configured point/ATR buffer. A break in the prevailing structural direction is BOS. An opposing break is CHoCH; a sufficiently large reversal candle body, measured against ATR, is classified as MSS.
4. **Build context.** Swing clusters produce support/resistance candidates; reaction and move-away criteria produce supply/demand zones. Nearby equal highs/lows are treated as liquidity pools. A sweep/reclaim requires price to cross a pool and close back through it.
5. **Check trendlines.** Lines are drawn from qualifying successive higher lows or lower highs. A close beyond the projected line, with the configured buffer, marks a breakout.
6. **Combine timeframe bias.** D1 is the primary direction, H4 confirms or conflicts, and H1 describes the trading location. The dashboard reports BUY BIAS, SELL BIAS, WAIT, CONFLICTING, RANGE/WAIT, or INSUFFICIENT DATA with a reason. A bias is not an entry command.

D1 analysis also reports structural direction and uses RSI, MACD, and ADX as additional context. Its calculated entry-zone, stop, and target levels are drawn for reference only.

## Dashboard controls

- **Header drag:** move the dashboard; its position is remembered when enabled.
- **Bottom-right handle:** resize the expanded dashboard.
- **EXPAND / COMPACT:** switch the amount and arrangement of detail.
- **HIDE / SHOW:** hide the dashboard or restore it.
- **H1, H4, D1, ALL:** toggle the corresponding chart markings. Analysis continues while markings are hidden.
- On wide dashboards, the timeframe cards use three columns. Narrow dashboards rearrange them into a two-row layout.

## Configurable inputs

Inputs are grouped in the EA's **Inputs** tab. Values below are the source defaults.

### MTF swing and break settings

| Input | Default | Meaning |
| --- | ---: | --- |
| `MTFInpH1SwingLeftBars`, `MTFInpH1SwingRightBars` | 2, 2 | H1 pivot confirmation bars. |
| `MTFInpH4SwingLeftBars`, `MTFInpH4SwingRightBars` | 2, 2 | H4 pivot confirmation bars. |
| `MTFInpD1SwingLeftBars`, `MTFInpD1SwingRightBars` | 2, 2 | D1 pivot confirmation bars. |
| `MTFInpH1LookbackBars`, `MTFInpH4LookbackBars`, `MTFInpD1LookbackBars` | 800, 600, 360 | Requested history per timeframe. |
| `MTFInpATRPeriod` | 14 | ATR period used for volatility-scaled thresholds. |
| `MTFInpMinimumSwingDistancePoints`, `MTFInpMinimumSwingDistanceATR` | 0, 0.10 | Minimum distance between accepted swings. |
| `MTFInpEqualSwingTolerancePoints`, `MTFInpEqualSwingToleranceATR` | 0, 0.02 | Equal-high/equal-low tolerance. |
| `MTFInpBreakBufferPoints`, `MTFInpBreakBufferATR` | 0, 0.02 | Extra distance required to confirm a break. |
| `MTFInpMinimumBreakBodyATR` | 0 | Optional minimum break-candle body. Zero disables this filter. |
| `MTFInpMSSBodyATR` | 0.80 | Reversal body size used for MSS classification. |

### MTF levels, liquidity, and zones

| Inputs | Defaults | Meaning |
| --- | --- | --- |
| `MTFInpLevelTolerancePoints`, `MTFInpLevelToleranceATR` | 0, 0.15 | Support/resistance swing-cluster tolerance. |
| `MTFInpLevelInvalidationATR`, `MTFInpMinimumLevelTests` | 0.50, 2 | Level invalidation buffer and minimum tests for an active level. |
| `MTFInpLiquidityTolerancePoints`, `MTFInpLiquidityToleranceATR` | 0, 0.02 | Equal-swing liquidity tolerance. |
| `MTFInpZoneReactionBars`, `MTFInpZoneLookbackBars` | 12, 180 | Reaction test and zone search windows. |
| `MTFInpZoneMinMoveAwayATR`, `MTFInpZoneHalfWidthATR`, `MTFInpZoneInvalidationATR` | 0.75, 0.25, 0.50 | Zone departure, width, and invalidation thresholds in ATR units. |

### MTF chart and dashboard settings

- Drawing: `MTFInpExtendTrendlines=true`, `MTFInpShowHistoricalEvents=false`, `MTFInpHistoricalBars=120`, and `MTFInpShowSwingLabels`, `MTFInpShowZones`, `MTFInpShowBreakLevels`, `MTFInpShowTrendlines`, `MTFInpShowLiquidityLevels`, `MTFInpShowDashboard`, `MTFInpShowLabels`, `MTFInpShowH1Markings`, `MTFInpShowH4Markings`, and `MTFInpShowD1Markings` all default to `true`.
- Refresh/logging: `MTFInpDiagnosticLogging=false`, `MTFInpRefreshSeconds=1`, and `MTFInpLineWidth=1`.
- Dashboard: `MTFInpDashboardWidth=650`, `MTFInpDashboardHeight=330`, `MTFInpDashboardMinWidth=360`, `MTFInpDashboardMinHeight=250`, `MTFInpDashboardFontSize=9`, `MTFInpDashboardPosition=MTF_PANEL_TOP_LEFT`, and `MTFInpRememberDashboard=true`.
- Line styles: `MTFInpTrendLineStyle=STYLE_DOT` and `MTFInpBreakLineStyle=STYLE_DOT`.
- Default timeframe colors: H1 blue, H4 dark orange, and D1 dark violet (`MTFInpH1Color`, `MTFInpH4Color`, `MTFInpD1Color`).

### D1 analysis settings

- History and pivots: `D1InpLookbackBars=360`, `D1InpPivotLeft=2`, `D1InpPivotRight=2`.
- Zones: `D1InpZoneLookback=240`, `D1InpReactionBars=12`, `D1InpZoneHalfWidthATR=0.25`, `D1InpMinMoveAwayATR=0.75`.
- Break/plan thresholds: `D1InpBreakBufferATR=0.02`, `D1InpMSSBodyATR=0.80`, `D1InpStopBufferATR=0.25`, `D1InpEquilibriumATR=0.10`.
- Indicator context: `D1InpRSIPeriod=14`, `D1InpADXPeriod=14`, `D1InpMACDFast=12`, `D1InpMACDSlow=26`, `D1InpMACDSignal=9`, `D1InpADXTrendLevel=25.0`.

## Limitations and safe use

- Market structure is subjective and depends on the configured pivot, ATR, and tolerance rules. This EA cannot promise a win rate or 100% accuracy.
- It does not place, modify, or close trades. It does not calculate position size or account risk.
- The dashboard bias and D1 SL/TP reference levels do not guarantee entries or execution prices. Validate the markings and test settings on historical data and a demo account before relying on them.
- Historical pivot confirmation uses right-side bars, so a swing is only labeled after those bars have completed.
- Insufficient or unavailable symbol history can delay a timeframe's analysis.

## Troubleshooting

- **No dashboard or markings:** check the EA is attached, the dashboard/marking toggles are on, and the Experts tab for initialization messages.
- **INSUFFICIENT DATA / WAIT FOR HISTORY:** open the symbol on H1, H4, and D1, allow history to load, then wait for the timer refresh.
- **EA does not appear in Navigator:** compile the `.mq5` file with MetaEditor and refresh **Navigator → Expert Advisors**.
- **Dashboard position/size resets:** enable `MTFInpRememberDashboard`; dashboard settings are stored locally by the terminal.