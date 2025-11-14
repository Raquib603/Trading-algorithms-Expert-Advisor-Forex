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



input ENUM_TIMEFRAMES emaFilterTimeframe2 = PERIOD_H1; 
// Define EMA handles and buffers
int emaFast_2, emaMid_2, emaSlow_2;
double emaFastVal2[], emaMidVal2[], emaSlowVal2[];


input ENUM_TIMEFRAMES emaFilterTimeframe = PERIOD_H1; 
// Define EMA handles and buffers
int emaFast, emaMid, emaSlow;
double emaFastVal[], emaMidVal[], emaSlowVal[];



input ENUM_TIMEFRAMES LTF = PERIOD_M5;  // Lower Timeframe to use [Pattern]
#resource "\\Indicators\\Examples\\ZigZag.ex5";

input double Pullbacks_Distance_Coeff_LTF = 0.5;

input int Depth_LTF = 12;
input int Deviation_LTF = 5;
input int Backstep_LTF = 3;

int zz_handle_LTF;
static int find_value_LTF = 7;



int atr_handle_LTF;
double atr_LTF = 0;
double atr_temp_array_LTF[];


input double TP_Coeff_LTF = 2;
input double SL_Coeff_LTF = 5;



//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){

   emaFast = iMA(_Symbol, emaFilterTimeframe, 50, 0, MODE_EMA, PRICE_CLOSE);
   emaMid  = iMA(_Symbol, emaFilterTimeframe, 100, 0, MODE_EMA, PRICE_CLOSE);
   emaSlow = iMA(_Symbol, emaFilterTimeframe, 200, 0, MODE_EMA, PRICE_CLOSE);
   
   emaFast_2 = iMA(_Symbol, emaFilterTimeframe2, 50, 0, MODE_EMA, PRICE_CLOSE);
   emaMid_2  = iMA(_Symbol, emaFilterTimeframe2, 100, 0, MODE_EMA, PRICE_CLOSE);
   emaSlow_2 = iMA(_Symbol, emaFilterTimeframe2, 200, 0, MODE_EMA, PRICE_CLOSE);

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
   
   // Retrieve EMA values
   if (CopyBuffer(emaFast, 0, 1, 1, emaFastVal) < 0) return;
   if (CopyBuffer(emaMid, 0, 1, 1, emaMidVal) < 0) return;
   if (CopyBuffer(emaSlow, 0, 1, 1, emaSlowVal) < 0) return;
   
   
   if (CopyBuffer(emaFast_2, 0, 1, 1, emaFastVal2) < 0) return;
   if (CopyBuffer(emaMid_2, 0, 1, 1, emaMidVal2) < 0) return;
   if (CopyBuffer(emaSlow_2, 0, 1, 1, emaSlowVal2) < 0) return;


   bool isBullishTrend = emaFastVal[0] > emaMidVal[0] && emaMidVal[0] > emaSlowVal[0];
   bool isBearishTrend = emaFastVal[0] < emaMidVal[0] && emaMidVal[0] < emaSlowVal[0];
   
   
   bool isBullishTrend2 = emaFastVal2[0] > emaMidVal2[0] && emaMidVal2[0] > emaSlowVal2[0];
   bool isBearishTrend2 = emaFastVal2[0] < emaMidVal2[0] && emaMidVal2[0] < emaSlowVal2[0];
   
   

   
   CopyBuffer(atr_handle_LTF, 0, 0, 1, atr_temp_array_LTF);
   atr_LTF = atr_temp_array_LTF[0];
   
   
   static int last_candle = 0;
   int candles = iBars(_Symbol, PERIOD_CURRENT);
   
   if(last_candle!= candles){
      Get_ZZ_Values_LTF();
   }
   
   
   
   
   

         GoShort();
         GoLong();

   
  }




void DrawLine(string name, double price, color lineColor) {
   if (!ObjectCreate(0, name, OBJ_HLINE, 0, 0, price))
      return;

   ObjectSetInteger(0, name, OBJPROP_COLOR, lineColor);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 2);
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
}




static double ZZ_Values_LTF[];
static int ZZ_Bars_LTF[];

void Get_ZZ_Values_LTF(){
   ArrayResize(ZZ_Values_LTF, find_value_LTF);
   ArrayResize(ZZ_Bars_LTF, find_value_LTF);

   int found_values_LTF = 0;
   int iteration = 1;
   double temp_Array_LTF[];

   while(found_values_LTF < find_value_LTF){
      if(CopyBuffer(zz_handle_LTF, 0, iteration, 1, temp_Array_LTF) <= 0){
         Print("CopyBuffer failed at iteration: ", iteration);
         break;
      }

      if(temp_Array_LTF[0] > 0){
         ZZ_Values_LTF[found_values_LTF] = temp_Array_LTF[0];
         ZZ_Bars_LTF[found_values_LTF] = iteration;  // Store bar shift/index
         found_values_LTF += 1;
      }

      iteration += 1;
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












bool GoShort() {
   bool isDowntrend = false;

   double first_value  = ZZ_Values_LTF[1]; // Low 3
   double second_value = ZZ_Values_LTF[2]; // High 3
   double third_value  = ZZ_Values_LTF[3]; // Low 2
   double fourth_value = ZZ_Values_LTF[4]; // High 2
   double fifth_value  = ZZ_Values_LTF[5]; // Low 1
   double sixth_value  = ZZ_Values_LTF[6]; // High 1

   if (fifth_value > third_value && third_value > first_value && first_value < second_value) {
      if ((MathAbs(fourth_value - second_value) <= atr_LTF * Pullbacks_Distance_Coeff_LTF) || (fourth_value <= second_value)) {
         isDowntrend = true; 
         Print("Downtrend detected");

         datetime line_time = iTime(_Symbol, _Period, ZZ_Bars_LTF[1]);
         DrawVerticalLine("Downtrend", line_time, clrRed);
      }
   }

   return isDowntrend;
}



bool GoLong() {
   bool isUptrend = false;


   double first_value  = ZZ_Values_LTF[1]; // High 3
   double second_value = ZZ_Values_LTF[2]; // Low 3
   double third_value  = ZZ_Values_LTF[3]; // High 2
   double fourth_value = ZZ_Values_LTF[4]; // Low 2
   double fifth_value  = ZZ_Values_LTF[5]; // High 1
   double sixth_value  = ZZ_Values_LTF[6]; // Low 1

   if (fifth_value < third_value && third_value < first_value && first_value > second_value) {
      if ((MathAbs(fourth_value - second_value) <= atr_LTF * Pullbacks_Distance_Coeff_LTF) || (fourth_value >= second_value)) {
         isUptrend = true;
         Print("Uptrend detected");

         datetime line_time = iTime(_Symbol, _Period, ZZ_Bars_LTF[1]);
         DrawVerticalLine("Uptrend", line_time, clrLime);
      }
   }

   return isUptrend;
}



