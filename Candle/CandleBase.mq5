#include <Trade/Trade.mqh>

input double RRRatio = 1.0;         // Risk-to-Reward ratio
input double FixedLotSize = 0.01;   // Lot size

CTrade trade;

//+------------------------------------------------------------------+
//| Candle body size                                                 |
//+------------------------------------------------------------------+
double GetBodySize(double o, double c)
{
   return MathAbs(c - o);
}

//+------------------------------------------------------------------+
//| Body-dominant candle check                                       |
//+------------------------------------------------------------------+
bool IsBodyDominant(double o, double c, double h, double l)
{
   double body = GetBodySize(o, c);
   double upperWick = h - MathMax(o, c);
   double lowerWick = MathMin(o, c) - l;
   double wick = upperWick + lowerWick;
   return body > 2 * wick;
}

//+------------------------------------------------------------------+
//| Opposite candle with big body check                              |
//+------------------------------------------------------------------+
bool IsOppositeAndBigEnough(double o1, double c1, double o2, double c2)
{
   double body1 = GetBodySize(o1, c1);
   double body2 = GetBodySize(o2, c2);
   bool isOpposite = (c1 > o1 && c2 < o2) || (c1 < o1 && c2 > o2);
   return isOpposite && body2 >= 0.5 * body1;
}

//+------------------------------------------------------------------+
//| Open trades or pending orders                                    |
//+------------------------------------------------------------------+
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

//+------------------------------------------------------------------+
//| OnTick Main Logic                                                |
//+------------------------------------------------------------------+
void OnTick(){
   if(Bars(_Symbol, _Period) < 4)
      return;

   // Candle Indexes:
   // 2 = Dominant candle (fully closed)
   // 1 = Confirmation candle (fully closed)
   // 0 = Current forming candle
   
   
   double o4 = iOpen(_Symbol, _Period, 4);
   double c4 = iClose(_Symbol, _Period, 4);
   double h4 = iHigh(_Symbol, _Period, 4);
   double l4 = iLow(_Symbol, _Period, 4);
   
   double o3 = iOpen(_Symbol, _Period, 3);
   double c3 = iClose(_Symbol, _Period, 3);
   double h3 = iHigh(_Symbol, _Period, 3);
   double l3 = iLow(_Symbol, _Period, 3);

   double o2 = iOpen(_Symbol, _Period, 2);
   double c2 = iClose(_Symbol, _Period, 2);
   double h2 = iHigh(_Symbol, _Period, 2);
   double l2 = iLow(_Symbol, _Period, 2);

   double o1 = iOpen(_Symbol, _Period, 1);
   double c1 = iClose(_Symbol, _Period, 1);
   double h1 = iHigh(_Symbol, _Period, 1);
   double l1 = iLow(_Symbol, _Period, 1);

   double o0 = iOpen(_Symbol, _Period, 0);
   double c0 = iClose(_Symbol, _Period, 0);
   double h0 = iHigh(_Symbol, _Period, 0);
   double l0 = iLow(_Symbol, _Period, 0);

   //bool hasBodyDom = IsBodyDominant(o2, c2, h2, l2);
   //bool hasOppositeBig = IsOppositeAndBigEnough(o2, c2, o1, c1);

   bool isBullish = ( o4 > c4 && o3 > c3 && o2 < c2 && o1 < c1 );
   bool isBearish = (o4 < c4 && o3 < c3 && o2 > c2 && o1 > c1);

   if(!HasOpenTradesOrOrders()){
   
   
   
      if(isBullish){
      
         datetime line_time = iTime(_Symbol, _Period, 1);
         DrawVerticalLine("Downtrend", line_time, clrGreen);
            
         
         
         double entry = o0;
         double sl = entry - (entry - l2) / 2.0;
         double tp = entry + RRRatio * (entry - sl);
         //trade.BuyStop(FixedLotSize, entry, _Symbol, sl, tp);
      }
      
      
      
      
      
      if(isBearish){
      
      
         datetime line_time = iTime(_Symbol, _Period, 1);
         DrawVerticalLine("Downtrend", line_time, clrRed);
         
         
         double entry = o0;
         double sl = entry + (h2 - entry) / 2.0;
         double tp = entry - RRRatio * (sl - entry);
         //trade.SellStop(FixedLotSize, entry, _Symbol, sl, tp);
      }
   }
}





void DrawVerticalLine(string name, datetime time, color clr) {

         string obj_name = name + "_" + IntegerToString(time); // Ensure uniqueness
         if (!ObjectCreate(0, obj_name, OBJ_VLINE, 0, time, 0)) {
            Print("Failed to create vertical line: ", obj_name);
            return;
         }
         ObjectSetInteger(0, obj_name, OBJPROP_COLOR, clr);
         ObjectSetInteger(0, obj_name, OBJPROP_WIDTH, 1);
         ObjectSetInteger(0, obj_name, OBJPROP_STYLE, STYLE_SOLID);
}
