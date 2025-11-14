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



input ENUM_TIMEFRAMES HTF = PERIOD_CURRENT;  // Higher Timeframe to use
#resource "\\Indicators\\Examples\\ZigZag.ex5";

input double Distance_Coeff_HTF = 0.5;

input int Depth_HTF = 12;
input int Deviation_HTF = 5;
input int Backstep_HTF = 3;

int zz_handle_HTF;
static int find_value_HTF = 4;



int atr_handle_HTF;
double atr_HTF = 0;
double atr_temp_array[];



//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){
   ArrayResize(ZZ_Values_HTF, find_value_HTF, 0);
   ArrayResize(ZZ_Times_HTF, find_value_HTF, 0);
   zz_handle_HTF = iCustom(_Symbol, HTF, "::Indicators\\Examples\\ZigZag.ex5", Depth_HTF, Deviation_HTF, Backstep_HTF);
   
   atr_handle_HTF = iATR(_Symbol, HTF, 14);


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
   
   CopyBuffer(atr_handle_HTF, 0, 0, 1, atr_temp_array);
   atr_HTF = atr_temp_array[0];
   
   
   static int last_candle = 0;
   int candles = iBars(_Symbol, PERIOD_CURRENT);
   
   if(last_candle!= candles){
      Get_ZZ_Values_HTF();
   }
   
   Find_Double_Bottom_HTF();
   Find_Double_Top_HTF();
}





















static double ZZ_Values_HTF[];
static datetime ZZ_Times_HTF[];

void Get_ZZ_Values_HTF() {
   ArrayResize(ZZ_Values_HTF, find_value_HTF);
   ArrayResize(ZZ_Times_HTF,  find_value_HTF);

   int found_values_HTF = 0;
   int iteration = 1;
   double temp_Array_HTF[];

   while (found_values_HTF < find_value_HTF) {
      CopyBuffer(zz_handle_HTF, 0, iteration, 1, temp_Array_HTF);
      if (temp_Array_HTF[0] > 0) {
         ZZ_Values_HTF[found_values_HTF] = temp_Array_HTF[0];
         ZZ_Times_HTF[found_values_HTF] = iTime(_Symbol, HTF, iteration);
         found_values_HTF++;
      }
      iteration++;
   }
}




//+------------------------------------------------------------------+
//| Draw a vertical line                                            |
//+------------------------------------------------------------------+
void DrawVerticalLine(string name, datetime time, color clr) {
   string obj_name = name + "_" + TimeToString(time, TIME_MINUTES); // Unique name using time
   if (!ObjectCreate(0, obj_name, OBJ_VLINE, 0, time, 0)) {
      Print("Failed to create vertical line: ", obj_name);
      return;
   }
   ObjectSetInteger(0, obj_name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, obj_name, OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, obj_name, OBJPROP_STYLE, STYLE_SOLID);
}

//+------------------------------------------------------------------+
//| Draw a horizontal line                                          |
//+------------------------------------------------------------------+
void DrawHorizontalLine(string name, double price, color clr) {
   string obj_name = name + "_" + DoubleToString(price, _Digits);
   if (!ObjectCreate(0, obj_name, OBJ_HLINE, 0, 0, price)) {
      Print("Failed to create horizontal line: ", obj_name);
      return;
   }
   ObjectSetInteger(0, obj_name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, obj_name, OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, obj_name, OBJPROP_STYLE, STYLE_DOT);
}


//+------------------------------------------------------------------+
//| Detect Double Bottom Pattern                                     |
//+------------------------------------------------------------------+
bool Find_Double_Bottom_HTF() {

   double first_value  = ZZ_Values_HTF[1];
   double second_value = ZZ_Values_HTF[2];
   double third_value  = ZZ_Values_HTF[3];

   datetime t1 = ZZ_Times_HTF[1];
   datetime t2 = ZZ_Times_HTF[2];
   datetime t3 = ZZ_Times_HTF[3];

   if (first_value < second_value && second_value > third_value && MathAbs(first_value - third_value) <= atr_HTF * Distance_Coeff_HTF) {

      DrawHorizontalLine("Bottom_Line_1", first_value, clrGreen);
      DrawHorizontalLine("Bottom_Line_2", second_value, clrGreen);

      DrawVerticalLine("Bottom_2", t1, clrYellow);
      DrawVerticalLine("Bottom_Mid",t2, clrYellow);
      DrawVerticalLine("Bottom_1", t3, clrYellow);
   }

   return false;
}

//+------------------------------------------------------------------+
//| Detect Double Top Pattern                                        |
//+------------------------------------------------------------------+
bool Find_Double_Top_HTF() {

   double first_value  = ZZ_Values_HTF[1];
   double second_value = ZZ_Values_HTF[2];
   double third_value  = ZZ_Values_HTF[3];

   datetime t1 = ZZ_Times_HTF[1];
   datetime t2 = ZZ_Times_HTF[2];
   datetime t3 = ZZ_Times_HTF[3];

   if (first_value > second_value && second_value < third_value && MathAbs(first_value - third_value) <= atr_HTF * Distance_Coeff_HTF) {

      DrawHorizontalLine("Top_Line_1", first_value, clrRed);
      DrawHorizontalLine("Top_Line_2", second_value, clrRed);

      DrawVerticalLine("TOP_2", t1, clrRed);
      DrawVerticalLine("Top_Mid",   t2, clrRed);
      DrawVerticalLine("TOP_1", t3, clrRed);
   }

   return false;
}
