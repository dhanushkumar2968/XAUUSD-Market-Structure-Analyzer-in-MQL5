#property copyright "Copyright 2026, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.60"
#property strict
#property description "XAUUSD Market Structure Analyzer"

#include "MTFTrendAnalysis.mqh"
#include "D1Analysis.mqh"

CMTFTrendAnalysis g_mtf_analysis;
CD1Analysis       g_d1_analysis;

// This EA draws market-structure analysis only. It does not place orders.
int OnInit()
  {
   if(!g_mtf_analysis.InputsValid())
     {
      Print("XAUUSD Market Structure Analyzer: invalid market-structure inputs.");
      return INIT_PARAMETERS_INCORRECT;
     }

   // Remove buttons left by an older EA version from this chart.
   ObjectDelete(0, "AI_TRADING_SIGNAL_BUY_BUTTON");
   ObjectDelete(0, "AI_TRADING_SIGNAL_SELL_BUTTON");
   g_d1_analysis.Initialize();
   if(!g_mtf_analysis.Initialize())
     {
      g_d1_analysis.Deinitialize();
      return INIT_FAILED;
     }
   g_d1_analysis.SetMarkingsVisible(g_mtf_analysis.MarkingsVisible(2));
   if(!EventSetTimer(MTFInpRefreshSeconds))
     {
      Print("XAUUSD Market Structure Analyzer: timer initialization failed. Error ", GetLastError());
      g_mtf_analysis.Deinitialize();
      g_d1_analysis.Deinitialize();
      return INIT_FAILED;
     }
   return INIT_SUCCEEDED;
  }

void OnDeinit(const int reason)
  {
   EventKillTimer();
   bool preserve_chart_objects = (reason == REASON_CHARTCHANGE);
   g_mtf_analysis.Deinitialize(preserve_chart_objects);
   g_d1_analysis.Deinitialize(preserve_chart_objects);
   ObjectDelete(0, "AI_TRADING_SIGNAL_BUY_BUTTON");
   ObjectDelete(0, "AI_TRADING_SIGNAL_SELL_BUTTON");
  }

void OnTick()
  {
   g_d1_analysis.Update();
   g_mtf_analysis.Update();
  }

void OnTimer()
  {
   g_d1_analysis.Update();
   g_mtf_analysis.Update();
  }

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   g_mtf_analysis.HandleChartEvent(id, lparam, dparam, sparam);
   if(id == CHARTEVENT_OBJECT_CLICK)
      g_d1_analysis.SetMarkingsVisible(g_mtf_analysis.MarkingsVisible(2));
  }
