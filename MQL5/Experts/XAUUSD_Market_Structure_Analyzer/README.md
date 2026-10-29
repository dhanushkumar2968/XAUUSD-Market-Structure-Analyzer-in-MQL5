# XAUUSD Market Structure Analyzer

A MetaTrader 5 Expert Advisor that analyzes D1, H4, and H1 market structure and displays structure events, support/resistance, supply/demand zones, and trendline breakout information on the chart. The EA analyzes the chart symbol; the XAUUSD name identifies the intended setup.

## Files

- `XAUUSD_Market_Structure_Analyzer.mq5` — EA entry point
- `MTFTrendAnalysis.mqh` — D1/H4/H1 analysis and responsive chart dashboard
- `D1Analysis.mqh` — D1 analysis and chart plan annotations

## Install

Copy the three source files into a folder under `MQL5/Experts`, open the `.mq5` file in MetaEditor, and compile it. Attach the compiled EA to a chart. It does not place trades.