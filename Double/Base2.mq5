//+------------------------------------------------------------------+
//|                                                        Base2.mq5 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Trade\Trade.mqh>
CTrade trade;


double Ask = 0;
double Bid = 0;


input ENUM_TIMEFRAMES LTF = PERIOD_M1;  // Lower Timeframe to use
#resource "\\Indicators\\Examples\\ZigZag.ex5";

input double Distance_Coeff_LTF = 0.2;

input int Depth_LTF = 12;
input int Deviation_LTF = 5;
input int Backstep_LTF = 3;

int zz_handle_LTF;
static int find_value_LTF = 8;



int atr_handle_LTF;
double atr_LTF = 0;
double atr_temp_array[];


input double TP_Coeff_LTF = 2;
input double SL_Coeff_LTF = 5;



//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){
   ArrayResize(ZZ_Values_LTF, find_value_LTF, 0);
   zz_handle_LTF = iCustom(_Symbol, LTF, "::Indicators\\Examples\\ZigZag.ex5", Depth_LTF, Deviation_LTF, Backstep_LTF);
   
   atr_handle_LTF = iATR(_Symbol, LTF, 14);


   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){

   
  }
  
  
  
  
  
  
  
  
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(){
   Ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   Bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   CopyBuffer(atr_handle_LTF, 0, 0, 1, atr_temp_array);
   atr_LTF = atr_temp_array[0];
   
   
   static int last_candle = 0;
   int candles = iBars(_Symbol, PERIOD_CURRENT);
   
   if(last_candle!= candles){
      Get_ZZ_Values_LTF();
   }
   
   Find_Double_Bottom_LTF();
   Find_Double_Top_LTF();
  }




void DrawLine(string name, double price, color lineColor) {
   if (!ObjectCreate(0, name, OBJ_HLINE, 0, 0, price))
      return;

   ObjectSetInteger(0, name, OBJPROP_COLOR, lineColor);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 2);
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
}











static double ZZ_Values_LTF[];

void Get_ZZ_Values_LTF(){
   int found_values_LTF = 0;
   int iteration = 1;
   double temp_Array_LTF[];
   
   while(found_values_LTF < find_value_LTF){
         
         CopyBuffer(zz_handle_LTF, 0, iteration, 1, temp_Array_LTF);
         if(temp_Array_LTF[0] > 0){
             ZZ_Values_LTF[found_values_LTF] = temp_Array_LTF[0];
             found_values_LTF += 1;     
           } 
       iteration += 1;
     }
}




bool Find_Double_Bottom_LTF() {
   if (PositionSelect(_Symbol)) return false;

   static double last_order_price = 0;
   
   double first_leg = MathAbs(ZZ_Values_LTF[6]-ZZ_Values_LTF[7]);
   double second_leg = MathAbs(ZZ_Values_LTF[4]-ZZ_Values_LTF[3]);
   double mid_leg_1 = MathAbs(ZZ_Values_LTF[6]-ZZ_Values_LTF[5]);
   double mid_leg_2 = MathAbs(ZZ_Values_LTF[4]-ZZ_Values_LTF[5]);
   
   
   double first_value  = ZZ_Values_LTF[4];
   double second_value = ZZ_Values_LTF[5];
   double third_value  = ZZ_Values_LTF[6];

   if (first_value < second_value && second_value > third_value && MathAbs(first_value - third_value) <= atr_LTF * Distance_Coeff_LTF) {
      if((first_leg> mid_leg_1) && (second_leg > 2* mid_leg_2)){
         if (second_value != last_order_price) {
            double sl = MathMin(third_value, first_value);
            double tp = second_value + (second_value - sl);
   
               if (trade.BuyStop(0.01, second_value, _Symbol, sl, tp, ORDER_TIME_DAY, TimeCurrent() + 3600 * 12, "Buy Stop")) {
                  last_order_price = second_value;
      
                  // Draw horizontal lines
                  DrawLine("LTF_Bottom_Line_Second", second_value, clrGreen);
                  DrawLine("LTF_Bottom_Line_First", first_value, clrBlue);
            }
         }
      }
   }

   return false;
}




bool Find_Double_Top_LTF() {
   if (PositionSelect(_Symbol)) return false;

   static double last_order_price = 0;
   
   
   double first_leg = MathAbs(ZZ_Values_LTF[6]-ZZ_Values_LTF[7]);
   double second_leg = MathAbs(ZZ_Values_LTF[4]-ZZ_Values_LTF[3]);
   double mid_leg_1 = MathAbs(ZZ_Values_LTF[6]-ZZ_Values_LTF[5]);
   double mid_leg_2 = MathAbs(ZZ_Values_LTF[4]-ZZ_Values_LTF[5]);
   
   double first_value  = ZZ_Values_LTF[4];
   double second_value = ZZ_Values_LTF[5];
   double third_value  = ZZ_Values_LTF[6];
   
   
   

   if (first_value > second_value && second_value < third_value && MathAbs(first_value - third_value) <= atr_LTF * Distance_Coeff_LTF) {
      if((first_leg> mid_leg_1) && (second_leg> 2* mid_leg_2)){
        
         if (second_value != last_order_price) {
            double sl = MathMax(third_value, first_value);
            double tp = second_value - (sl - second_value);
   
               if (trade.SellStop(0.01, second_value, _Symbol, sl, tp, ORDER_TIME_DAY, TimeCurrent() + 3600 * 12, "Sell Stop")) {
                  last_order_price = second_value;
      
                  // Draw horizontal lines
                  DrawLine("LTF_Top_Line_Second", second_value, clrRed);
                  DrawLine("LTF_Top_Line_First", first_value, clrOrange);
             }
         }
      }
   }

   return false;
}


