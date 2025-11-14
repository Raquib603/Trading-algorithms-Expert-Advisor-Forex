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
   
   

   
   CopyBuffer(atr_handle_LTF, 0, 0, 1, atr_temp_array);
   atr_LTF = atr_temp_array[0];
   
   
   static int last_candle = 0;
   int candles = iBars(_Symbol, PERIOD_CURRENT);
   
   if(last_candle!= candles){
      Get_ZZ_Values_LTF();
   }
   
   
   
   
   
   if(isBearishTrend2){
      if(isBearishTrend){
         Find_Double_Bottom_LTF();
        }
      
     }
   
   
   
   
   if(isBullishTrend2){
      if(isBullishTrend){
         Find_Double_Top_LTF();
        }
      
     }
   
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


bool Find_Double_Bottom_LTF() {
   if (PositionSelect(_Symbol)) return false;

   static double last_order_price = 0;
   
   double first_leg = MathAbs(ZZ_Values_LTF[6]-ZZ_Values_LTF[7]);
   double second_leg = MathAbs(ZZ_Values_LTF[4]-ZZ_Values_LTF[3]);
   double mid_leg_1 = MathAbs(ZZ_Values_LTF[6]-ZZ_Values_LTF[5]);
   double mid_leg_2 = MathAbs(ZZ_Values_LTF[4]-ZZ_Values_LTF[5]);
   
   
   double first_value = ZZ_Values_LTF[1];
   double second_value = ZZ_Values_LTF[2];
   double third_value = ZZ_Values_LTF[3];
   
   double fourth_value  = ZZ_Values_LTF[4];
   double fifth_value = ZZ_Values_LTF[5];
   double sixth_value  = ZZ_Values_LTF[6];

 



   if (fourth_value < fifth_value && fifth_value > sixth_value && MathAbs(fourth_value - sixth_value) <= atr_LTF * Distance_Coeff_LTF) {
     
      if((first_leg > mid_leg_1) && (second_leg >  mid_leg_2)){
      
         if((second_value > sixth_value) && (second_value < fifth_value)){
         
         
            // Draw horizontal lines
            DrawLine("LTF_Bottom_Line_Second", fifth_value, clrGreen);
            DrawLine("LTF_Bottom_Line_First", fourth_value, clrBlue);
            
            datetime t1 = iTime(_Symbol, LTF, ZZ_Bars_LTF[1]);
            datetime t2 = iTime(_Symbol, LTF, ZZ_Bars_LTF[2]);
            datetime t3 = iTime(_Symbol, LTF, ZZ_Bars_LTF[3]);

            
            DrawVerticalLine("BOTTOM_1", t1, clrMagenta);
            DrawVerticalLine("BOTTOM_2", t2, clrMagenta);
            DrawVerticalLine("BOTTOM_3", t3, clrMagenta);
            
                  
            if (fifth_value != last_order_price) {
               double sl = MathMin(sixth_value, fourth_value);
               double tp = fifth_value + (fifth_value - sl);
   
               if (trade.BuyStop(0.01, fifth_value, _Symbol, sl, tp, ORDER_TIME_DAY, TimeCurrent() + 3600 * 12, "Buy Stop")) {
                  last_order_price = fifth_value;
      


              }
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



   double first_value = ZZ_Values_LTF[1];
   double second_value = ZZ_Values_LTF[2];
   double third_value = ZZ_Values_LTF[3];

   
   double fourth_value  = ZZ_Values_LTF[4];
   double fifth_value = ZZ_Values_LTF[5];
   double sixth_value  = ZZ_Values_LTF[6];
   

   if (fourth_value > fifth_value && fifth_value < sixth_value && MathAbs(fourth_value - sixth_value) <= atr_LTF * Distance_Coeff_LTF) {
     
      if((first_leg> mid_leg_1) && (second_leg> mid_leg_2)){
           
          if((second_value < sixth_value) && (second_value > fifth_value)){
            
            // Draw horizontal lines
            DrawLine("LTF_Top_Line_Second", fifth_value, clrRed);
            DrawLine("LTF_Top_Line_First", fourth_value, clrOrange);
            
            datetime t1 = iTime(_Symbol, LTF, ZZ_Bars_LTF[1]);
            datetime t2 = iTime(_Symbol, LTF, ZZ_Bars_LTF[2]);
            datetime t3 = iTime(_Symbol, LTF, ZZ_Bars_LTF[3]);

            
            DrawVerticalLine("TOP_1", t1, clrYellow);
            DrawVerticalLine("TOP_2", t2, clrYellow);
            DrawVerticalLine("TOP_3", t3, clrYellow); 
            
            if (fifth_value != last_order_price) {
               double sl = MathMax(sixth_value, fourth_value);
               double tp = fifth_value - (sl - fifth_value);
      
               if (trade.SellStop(0.01, fifth_value, _Symbol, sl, tp, ORDER_TIME_DAY, TimeCurrent() + 3600 * 12, "Sell Stop")) {
                  last_order_price = fifth_value;
      

               }
                  
             }
         }
      }
   }

   return false;
}


