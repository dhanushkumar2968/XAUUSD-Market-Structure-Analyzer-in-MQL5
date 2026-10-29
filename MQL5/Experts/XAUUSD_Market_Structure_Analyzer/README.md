# XAUUSD Market Structure Analyzer for MetaTrader 5

> A chart-analysis Expert Advisor for MetaTrader 5. It reads D1, H4, and H1 market structure and displays the results on the chart you attach it to.

This README is the complete project guide: requirements, source files, installation, analysis logic, dashboard controls, settings, visual validation, limitations, and troubleshooting.

## Quick summary

- **Platform:** MetaTrader 5 (MT5), written in MQL5.
- **Intended market:** XAUUSD. The EA uses the chart's symbol, so broker names such as `XAUUSD.m` are supported.
- **Analysis timeframes:** D1 (primary direction), H4 (confirmation), H1 (trading location).
- **Trading behavior:** analysis and chart markings only. The EA does **not** send, modify, or close orders.
- **Main source:** `XAUUSD_Market_Structure_Analyzer.mq5`.

## Module 1 — What this EA does

The EA independently reads D1, H4, and H1 data, even when the visible chart is on a different timeframe. It identifies confirmed swings, structure breaks, zones, liquidity levels, and trendline breaks. A dashboard summarizes the three timeframes and the combined directional context.

It is a rule-based analyzer, not an AI model and not an automated trading system. Its labels and plans are interpretations produced by configurable rules; they are not guaranteed signals or financial advice.

## Module 2 — What appears on the chart

- **Swing structure:** HH, HL, LH, LL, EQH, and EQL labels.
- **Structure events:** BOS, CHoCH, and MSS based on confirmed levels and closed candles.
- **Support and resistance:** swing clusters and their test/invalidation state.
- **Supply and demand:** reaction zones formed from price departure criteria.
- **Liquidity:** equal-high/equal-low pools and sweep/reclaim annotations.
- **Trendlines:** lines anchored to qualifying swings, with a marker when a closed candle breaks the projected line.
- **D1 plan references:** when the D1 analysis can form a plan, it may draw an entry area and SL/TP1/TP2/TP3 reference levels. These are drawings, not orders.
- **Dashboard:** D1, H4, and H1 summaries plus a combined status and reason.

Chart object colors and line styles help distinguish timeframe and event types. Marking visibility can be toggled without turning off the underlying calculations.

## Module 3 — Requirements and dependencies

### Required

1. MetaTrader 5 terminal.
2. MetaEditor included with MT5, with an MQL5 compiler.
3. All three source files from this package kept together in the same EA folder:
   - `XAUUSD_Market_Structure_Analyzer.mq5`
   - `MTFTrendAnalysis.mqh`
   - `D1Analysis.mqh`
4. Historical price data for the chart symbol on H1, H4, and D1. The initial MTF analysis requests up to 800 H1, 600 H4, and 360 D1 bars; D1 plan analysis requests up to 360 daily bars.
5. A broker symbol with valid price data. XAUUSD is intended, but the EA analyzes the active chart symbol rather than enforcing a ticker name.

### Not required

No Python, DLL, external API, network service, credentials, or third-party MQL library is needed. The EA does not use a separate AI service.

## Module 4 — Package and source-file map

| File | Role |
| --- | --- |
| `XAUUSD_Market_Structure_Analyzer.mq5` | EA entry point. Sets up analysis, timer/tick processing, chart events, and cleanup. |
| `MTFTrendAnalysis.mqh` | Main D1/H4/H1 engine: structure, zones, liquidity, trendlines, chart objects, and dashboard. |
| `D1Analysis.mqh` | Additional D1 context, including RSI/MACD/ADX confirmation and directional plan reference markings. |
| `README.md` | This installation and user guide. |
| `.gitignore` | Keeps compiled `.ex5` and log outputs out of source control. |

MetaEditor creates `XAUUSD_Market_Structure_Analyzer.ex5` when the source compiles. The compiled file is local output; compile the source in the terminal where you intend to run the EA.

## Module 5 — Install in MetaTrader 5

1. In MT5, select **File → Open Data Folder**.
2. Open `MQL5/Experts` and create `XAUUSD_Market_Structure_Analyzer`.
3. Copy the `.mq5` and both `.mqh` files into that folder. Keep them together so the include files can be found.
4. Open `XAUUSD_Market_Structure_Analyzer.mq5` in MetaEditor.
5. Press **F7** or choose **Compile**.
6. Return to MT5 and refresh **Navigator → Expert Advisors**.
7. Attach **XAUUSD_Market_Structure_Analyzer** to the chart for the symbol you want to inspect.
8. Allow MT5 to load H1, H4, and D1 history. The dashboard may show a waiting or insufficient-data state until data is available.

## Module 6 — First-run checklist

- Confirm the EA name appears under **Navigator → Expert Advisors** after compilation.
- Confirm it is attached to the intended symbol and the smiley/EA status indicates it initialized.
- Open the **Experts** and **Journal** tabs if initialization or history messages appear.
- Wait for H1/H4/D1 data to load and for the EA refresh cycle to update the chart.
- Check the dashboard's timeframe rows and final status before interpreting chart markings.
- Start with default settings. Change one threshold at a time so you can see how it affects the analysis.

Algo Trading permission is not required for the dashboard and analysis markings because this EA does not trade.

## Module 7 — How the analysis engine works

1. **Load timeframe data.** The EA requests H1, H4, and D1 rates explicitly. The visible chart period does not replace those analysis periods.
2. **Confirm swings.** Left/right pivot bars define when a high or low is confirmed. A pivot is only known after the configured right-side bars have closed.
3. **Classify structure.** Confirmed highs and lows are compared with previous swings to label HH/HL/LH/LL and equal highs/lows.
4. **Detect breaks.** A closed candle must cross a confirmed swing level by the configured point/ATR buffer. A break aligned with current structure is labeled BOS. A break against it is labeled CHoCH; a sufficiently large reversal candle body can be classified as MSS.
5. **Find levels and zones.** Swing clusters are evaluated as support/resistance. Reaction and move-away criteria are used for candidate supply/demand zones. Levels and zones can later be invalidated by price movement.
6. **Check liquidity.** Similar highs/lows within the configured tolerance form candidate liquidity pools. A sweep/reclaim requires price to pass a pool and close back through it.
7. **Check trendlines.** Qualifying higher lows or lower highs are joined. A closed candle beyond the projected line and configured buffer marks a breakout.
8. **Combine context.** D1 supplies the primary direction, H4 provides confirmation or conflict, and H1 describes the nearer trading location. The dashboard reports the result and a reason.

The D1 module also uses RSI, MACD, and ADX as context. These indicators supplement the structural rules; they do not guarantee a forecast.

## Module 8 — Market-structure glossary

| Label | Meaning in this analyzer |
| --- | --- |
| HH | A confirmed swing high above the previous confirmed swing high. |
| HL | A confirmed swing low above the previous confirmed swing low. |
| LH | A confirmed swing high below the previous confirmed swing high. |
| LL | A confirmed swing low below the previous confirmed swing low. |
| EQH / EQL | Highs or lows within the configured equal-swing tolerance. |
| BOS | Break of a confirmed structure level in the prevailing structural direction. |
| CHoCH | Close-confirmed break against the prevailing structural direction, suggesting a possible change. |
| MSS | A qualifying opposing structure break whose candle body meets the configured reversal threshold. |
| Sweep/reclaim | Price trades through a liquidity level and closes back across it. |
| Supply / demand | A price area identified from a reaction and subsequent move-away rule. |

These terms are operational definitions implemented by this EA. Other traders and systems may define them differently.

## Module 9 — Dashboard and chart controls

- **Drag the header** to move the dashboard.
- **Drag the lower-right handle** to resize it.
- **COMPACT / EXPAND** changes how much analysis is shown.
- **HIDE / SHOW** hides or restores the dashboard.
- **H1, H4, D1** toggle chart markings for that timeframe.
- **ALL ON/OFF** toggles all analysis markings together.
- A wide chart can show D1/H4/H1 cards in columns; a narrow chart rearranges them to fit.

Hiding markings affects chart objects only. The engine continues analyzing the data. The dashboard position and size can be remembered by the terminal when `MTFInpRememberDashboard` is enabled.

### Dashboard decision terms

The final line may report **BUY BIAS**, **SELL BIAS**, **WAIT**, **CONFLICTING**, **RANGE**, or **INSUFFICIENT DATA**, along with a reason. A bias summarizes timeframe context; it is not an entry instruction. The actual status depends on available history and current calculated structure.

## Module 10 — Entry, stop, and target markings

When a valid D1 directional plan is available, the EA may display an entry/reaction area and reference levels for a stop loss and three targets. The displayed values are analytical levels calculated from the strategy rules and current market data.

They do not account for an individual trader's lot size, account risk, spread, slippage, commission, or broker execution. The EA does not submit trades at these levels. Always verify the price labels against the live chart before using them in a separate trading decision.

## Module 11 — Inputs and tuning guide

Inputs are available in the EA's **Inputs** tab. Values below are the source defaults. Change settings carefully; changing a threshold changes the labels and zones the EA produces.

### Swing and break settings

| Inputs | Defaults | Purpose |
| --- | --- | --- |
| `MTFInpH1SwingLeftBars`, `MTFInpH1SwingRightBars` | 2, 2 | H1 pivot confirmation. |
| `MTFInpH4SwingLeftBars`, `MTFInpH4SwingRightBars` | 2, 2 | H4 pivot confirmation. |
| `MTFInpD1SwingLeftBars`, `MTFInpD1SwingRightBars` | 2, 2 | D1 pivot confirmation. |
| `MTFInpH1LookbackBars`, `MTFInpH4LookbackBars`, `MTFInpD1LookbackBars` | 800, 600, 360 | Requested history per MTF analysis. |
| `MTFInpATRPeriod` | 14 | ATR period used for volatility-scaled thresholds. |
| `MTFInpMinimumSwingDistancePoints`, `MTFInpMinimumSwingDistanceATR` | 0, 0.10 | Minimum distance between accepted swings. |
| `MTFInpEqualSwingTolerancePoints`, `MTFInpEqualSwingToleranceATR` | 0, 0.02 | Equal-high/equal-low tolerance. |
| `MTFInpBreakBufferPoints`, `MTFInpBreakBufferATR` | 0, 0.02 | Extra distance needed to confirm a break. |
| `MTFInpMinimumBreakBodyATR` | 0 | Optional minimum break-candle body; zero disables this filter. |
| `MTFInpMSSBodyATR` | 0.80 | Reversal body threshold for MSS classification. |

### Levels, liquidity, and zones

| Inputs | Defaults | Purpose |
| --- | --- | --- |
| `MTFInpLevelTolerancePoints`, `MTFInpLevelToleranceATR` | 0, 0.15 | Swing-cluster tolerance for support/resistance. |
| `MTFInpLevelInvalidationATR`, `MTFInpMinimumLevelTests` | 0.50, 2 | Invalidation distance and minimum tests for an active level. |
| `MTFInpLiquidityTolerancePoints`, `MTFInpLiquidityToleranceATR` | 0, 0.02 | Tolerance for equal-swing liquidity pools. |
| `MTFInpZoneReactionBars`, `MTFInpZoneLookbackBars` | 12, 180 | Reaction and zone-search windows. |
| `MTFInpZoneMinMoveAwayATR`, `MTFInpZoneHalfWidthATR`, `MTFInpZoneInvalidationATR` | 0.75, 0.25, 0.50 | Zone move-away, width, and invalidation thresholds. |

### Markings and dashboard

- `MTFInpExtendTrendlines=true`, `MTFInpShowHistoricalEvents=false`, `MTFInpHistoricalBars=120` control trendline extension and historical event drawings.
- `MTFInpShowSwingLabels`, `MTFInpShowZones`, `MTFInpShowBreakLevels`, `MTFInpShowTrendlines`, `MTFInpShowLiquidityLevels`, `MTFInpShowDashboard`, `MTFInpShowLabels`, `MTFInpShowH1Markings`, `MTFInpShowH4Markings`, and `MTFInpShowD1Markings` default to `true`.
- `MTFInpDiagnosticLogging=false`, `MTFInpRefreshSeconds=1`, and `MTFInpLineWidth=1` control logging, refresh interval, and line width.
- Dashboard defaults: width 650, height 330, minimum width 360, minimum height 250, font size 9, top-left position, and `MTFInpRememberDashboard=true`.
- `MTFInpTrendLineStyle=STYLE_DOT` and `MTFInpBreakLineStyle=STYLE_DOT` set line styles.
- Default timeframe colors are H1 blue, H4 dark orange, and D1 dark violet (`MTFInpH1Color`, `MTFInpH4Color`, `MTFInpD1Color`).

### D1-analysis settings

- History and pivots: `D1InpLookbackBars=360`, `D1InpPivotLeft=2`, `D1InpPivotRight=2`.
- Zones: `D1InpZoneLookback=240`, `D1InpReactionBars=12`, `D1InpZoneHalfWidthATR=0.25`, `D1InpMinMoveAwayATR=0.75`.
- Break and plan thresholds: `D1InpBreakBufferATR=0.02`, `D1InpMSSBodyATR=0.80`, `D1InpStopBufferATR=0.25`, `D1InpEquilibriumATR=0.10`.
- Indicator context: `D1InpRSIPeriod=14`, `D1InpADXPeriod=14`, `D1InpMACDFast=12`, `D1InpMACDSlow=26`, `D1InpMACDSignal=9`, `D1InpADXTrendLevel=25.0`.

## Module 12 — Visual testing and validation

This is an analyzer, so MT5 Strategy Tester will not produce trading performance statistics from the EA as supplied: it does not open or close positions. Use the tester's **visual mode** to inspect how markings evolve through historical candles.

Suggested review procedure:

1. Open MT5's **View → Strategy Tester** and select the EA, symbol, date range, and a chart period.
2. Enable visual mode and run the historical replay.
3. Check whether confirmed swing labels only appear after the pivot-confirmation bars, and whether BOS/CHoCH/MSS appear after candle close.
4. Compare H1/H4/D1 cards and markings as the visible chart period changes.
5. Record false breaks, delayed pivots, and zones that are too broad or too narrow; adjust one related input and repeat.
6. Run the same review on out-of-sample historical dates and then observe the EA on a demo account before relying on its readings.

Visual inspection is not proof of profitability or accuracy. No backtest result is claimed by this package.

## Module 13 — Limitations and responsible use

- No market-structure rule can provide 100% accuracy. Swings, zones, and breaks depend on thresholds and interpretation.
- Confirmed pivots are delayed by right-side bars; this is expected and avoids labeling an unconfirmed pivot too early.
- The analyzer does not place, modify, or close trades, size positions, or manage account risk.
- Dashboard biases and SL/TP reference levels do not guarantee a valid entry, execution price, or future outcome.
- Missing or limited broker history can delay analysis or produce insufficient-data states.
- Spread, slippage, market gaps, broker feed differences, and symbol digit formats can affect how chart levels behave in live conditions.

Validate results on historical charts and a demo account. Do not risk funds based only on a dashboard label.

## Module 14 — Troubleshooting

| Symptom | What to check |
| --- | --- |
| EA is missing from Navigator | Compile the `.mq5` file in MetaEditor, then refresh **Navigator → Expert Advisors**. |
| No dashboard or markings | Confirm the EA is attached, display toggles are enabled, and inspect MT5's **Experts** tab for errors. |
| `INSUFFICIENT DATA` or waiting for history | Open/load H1, H4, and D1 history for the symbol, then allow the EA to refresh. |
| Include file cannot be found | Keep `MTFTrendAnalysis.mqh` and `D1Analysis.mqh` beside the `.mq5` source in the same EA folder. |
| Markings hidden | Use the dashboard's timeframe or all-markings toggle and check the corresponding display inputs. |
| Dashboard position/size does not persist | Enable `MTFInpRememberDashboard`; persistence is local to the MT5 terminal profile. |
| Different results from another broker | Compare symbol, history, candle close times, and price feed; structure is calculated from that broker's candles. |

## Module 15 — Frequently asked questions

### Does it automatically buy or sell?

No. It is chart analysis only. The BUY/SELL bias wording describes direction context and does not send an order.

### Does it work when I change the chart timeframe?

The analysis requests D1, H4, and H1 data independently of the visible chart period. Markings are configured to remain visible across chart periods. The chart still needs the relevant symbol history loaded.

### Can I use it on another symbol?

The EA analyzes the active chart symbol. It is designed and named for XAUUSD, but can be attached to another symbol; tune and validate settings for that market before use.

### Why do some labels appear after the move?

Swing labels require right-side confirmation bars. Break events are based on closed candles. This confirmation introduces delay by design.

### Where do I get the compiled EA?

Compile `XAUUSD_Market_Structure_Analyzer.mq5` in MetaEditor. This generates the `.ex5` file in that terminal's Experts folder. Compiled binaries are not the maintained source; use the package's `.mq5` and `.mqh` files.

## Module 16 — Change log and contribution notes

The repository contains the MQL5 source and this guide. When changing the strategy, update the relevant source defaults or logic and keep this README aligned with actual behavior. Recompile in MetaEditor after MQL5 changes and inspect the chart in visual mode. Do not describe a trading feature or test result here unless it has been implemented and verified.
