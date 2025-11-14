//+------------------------------------------------------------------+
//|                                                        Base1.mq5 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade\Trade.mqh>
CTrade trade;

input ENUM_TIMEFRAMES emaFilterTimeframe = PERIOD_H1;  // Timeframe for EMA filter
input int wick_multiplier = 1;

// Define EMA handles and buffers
int emaFast, emaMid, emaSlow;
double emaFastVal[], emaMidVal[], emaSlowVal[];

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){
   emaFast = iMA(_Symbol, emaFilterTimeframe, 50, 0, MODE_EMA, PRICE_CLOSE);
   emaMid  = iMA(_Symbol, emaFilterTimeframe, 100, 0, MODE_EMA, PRICE_CLOSE);
   emaSlow = iMA(_Symbol, emaFilterTimeframe, 200, 0, MODE_EMA, PRICE_CLOSE);
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){ }

//+------------------------------------------------------------------+
//| Detects if the candle has a weak body based on wick dominance    |
//+------------------------------------------------------------------+
bool IsWeakBody(double open, double high, double low, double close){
   double body = MathAbs(close - open);
   double upperWick = high - MathMax(open, close);
   double lowerWick = MathMin(open, close) - low;
   
   double total_wick = upperWick + lowerWick;
   
   return (body * wick_multiplier  <  total_wick);
}

//+------------------------------------------------------------------+
//| Returns the absolute body size of a candle                       |
//+------------------------------------------------------------------+
double GetBodySize(double open, double close){
    return MathAbs(close - open);
}



bool HasOpenTradesOrOrders()
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(PositionGetSymbol(i) == _Symbol)
         return true;
   }

   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if(OrderGetTicket(i))
      {
         if(OrderGetString(ORDER_SYMBOL) == _Symbol &&
            (OrderGetInteger(ORDER_TYPE) == ORDER_TYPE_BUY_STOP ||
             OrderGetInteger(ORDER_TYPE) == ORDER_TYPE_SELL_STOP))
            return true;
      }
   }

   return false;
}


// Cancel pending orders if they were not triggered in the current candle
void CancelUntriggeredPendingOrders()
{
   datetime lastBarTime = iTime(_Symbol, PERIOD_CURRENT, 1);  // Time of the previous closed candle
   datetime currentBarTime = iTime(_Symbol, PERIOD_CURRENT, 0);

   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if(OrderGetTicket(i))
      {
         if(OrderGetString(ORDER_SYMBOL) == _Symbol)
         {
            int type = (int)OrderGetInteger(ORDER_TYPE);
            double price = OrderGetDouble(ORDER_PRICE_OPEN);
            datetime timeSetup = (datetime)OrderGetInteger(ORDER_TIME_SETUP);

            // Order placed during previous candle
            if (timeSetup <= lastBarTime)
            {
               double high0 = iHigh(_Symbol, PERIOD_CURRENT, 0);
               double low0 = iLow(_Symbol, PERIOD_CURRENT, 0);

               if ((type == ORDER_TYPE_BUY_STOP && high0 < price) ||
                   (type == ORDER_TYPE_SELL_STOP && low0 > price))
               {
                  ulong ticket = OrderGetTicket(i);
                  if (!trade.OrderDelete(ticket))
                     Print("Failed to delete pending order: ", ticket, " - Error: ", GetLastError());
               }
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {

    CancelUntriggeredPendingOrders();

    // Retrieve EMA values
    if (CopyBuffer(emaFast, 0, 1, 1, emaFastVal) < 0) return;
    if (CopyBuffer(emaMid, 0, 1, 1, emaMidVal) < 0) return;
    if (CopyBuffer(emaSlow, 0, 1, 1, emaSlowVal) < 0) return;

    bool isBullishTrend = emaFastVal[0] > emaMidVal[0] && emaMidVal[0] > emaSlowVal[0];
    bool isBearishTrend = emaFastVal[0] < emaMidVal[0] && emaMidVal[0] < emaSlowVal[0];

    double open1 = iOpen(_Symbol, PERIOD_CURRENT, 1);
    double high1 = iHigh(_Symbol, PERIOD_CURRENT, 1);
    double low1 = iLow(_Symbol, PERIOD_CURRENT, 1);
    double close1 = iClose(_Symbol, PERIOD_CURRENT, 1);

    double open2 = iOpen(_Symbol, PERIOD_CURRENT, 0);
    double high2 = iHigh(_Symbol, PERIOD_CURRENT, 0);
    double low2 = iLow(_Symbol, PERIOD_CURRENT, 0);
    double close2 = iClose(_Symbol, PERIOD_CURRENT, 0);

    bool isWeak = IsWeakBody(open1, high1, low1, close1);
      
      
    bool bullishCandle = open1 < close1; 
    bool Bull_retraced = low2 < open1; 
    
    
    bool bearishCandle = open1 > close1;
    bool Bear_retraced = high2 > open1;
    
    
    if(!HasOpenTradesOrOrders()){
         if(isWeak){   
          // Try Buy Stop
          if (isBullishTrend && (bullishCandle && Bull_retraced)) {
              double entryPrice = close1;
              double slPrice = MathMin(low1, low2);
              double tpPrice = entryPrice + 2*MathAbs(entryPrice - slPrice);
      
              if (trade.BuyStop(0.1, entryPrice, _Symbol, slPrice, tpPrice)) {
      
              }
            }
          
          
          
          // Try Sell Stop
          if (isBearishTrend && (bearishCandle && Bear_retraced)) {
              double entryPrice = close1;
              double slPrice = MathMax(high1, high2);
              double tpPrice = entryPrice - 2*MathAbs(entryPrice - slPrice);
      
              if (trade.SellStop(0.1, entryPrice, _Symbol, slPrice, tpPrice)) {
            }
          }
        }
    
     }
}