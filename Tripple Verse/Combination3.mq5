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


double lotSize = 0.1;  // Change this based on your risk management


//Group Higher TimeFrame
input string _group1 = "Higher Timeframe Settings"; 

input ENUM_TIMEFRAMES HTF = PERIOD_CURRENT;  // Higher Timeframe to use
#resource "\\Indicators\\Examples\\ZigZag.ex5";

input double Distance_Coeff_HTF = 0.5;

input int Depth_HTF = 12;
input int Deviation_HTF = 5;
input int Backstep_HTF = 3;

int zz_handle_HTF;
static int find_value_HTF = 5;

int atr_handle_HTF;
double atr_HTF = 0;
double atr_temp_array_HTF[];




//Group Lower TimeFrame
input string _group2 = "Lower Timeframe Settings"; 
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





input string _group3 = "Other Filters"; 
input ENUM_TIMEFRAMES emaFilterTimeframeHTF = PERIOD_H1; 
// Define EMA handles and buffers
int emaFast, emaMid, emaSlow;
double emaFastVal[], emaMidVal[], emaSlowVal[];


input ENUM_TIMEFRAMES emaFilterTimeframeLTF = PERIOD_M5; 
// Define EMA handles and buffers
int emaFast_2, emaMid_2, emaSlow_2;
double emaFastVal2[], emaMidVal2[], emaSlowVal2[];


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){
   ArrayResize(ZZ_Values_HTF, find_value_HTF, 0);
   ArrayResize(ZZ_Times_HTF, find_value_HTF, 0);
   zz_handle_HTF = iCustom(_Symbol, HTF, "::Indicators\\Examples\\ZigZag.ex5", Depth_HTF, Deviation_HTF, Backstep_HTF);
   atr_handle_HTF = iATR(_Symbol, HTF, 14);
   
   
   
   

   emaFast = iMA(_Symbol, emaFilterTimeframeHTF, 50, 0, MODE_EMA, PRICE_CLOSE);
   emaMid  = iMA(_Symbol, emaFilterTimeframeHTF, 100, 0, MODE_EMA, PRICE_CLOSE);
   emaSlow = iMA(_Symbol, emaFilterTimeframeHTF, 200, 0, MODE_EMA, PRICE_CLOSE);
   
   emaFast_2 = iMA(_Symbol, emaFilterTimeframeLTF, 50, 0, MODE_EMA, PRICE_CLOSE);
   emaMid_2  = iMA(_Symbol, emaFilterTimeframeLTF, 100, 0, MODE_EMA, PRICE_CLOSE);
   emaSlow_2 = iMA(_Symbol, emaFilterTimeframeLTF, 200, 0, MODE_EMA, PRICE_CLOSE);

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
    
   
   CopyBuffer(atr_handle_HTF, 0, 0, 1, atr_temp_array_HTF);
   atr_HTF = atr_temp_array_HTF[0];
  
   static int last_candle_HTF = 0;
   int candles_HTF = iBars(_Symbol, HTF);
   
   if(last_candle_HTF!= candles_HTF){
      Get_ZZ_Values_HTF();
   }
   
   
   
   
   CopyBuffer(atr_handle_LTF, 0, 0, 1, atr_temp_array_LTF);
   atr_LTF = atr_temp_array_LTF[0];
   
   static int last_candle_LTF = 0;
   int candles_LTF = iBars(_Symbol, LTF);
   
      if(last_candle_LTF!= candles_LTF){
      Get_ZZ_Values_LTF();
   }
   
   
   
   
   
   
   double secondVal, minVal, maxVal;
   double first_value_ltf, sixth_value_ltf;

   static double last_order_price = 0;

       
     
     
      if (Find_Double_Bottom_HTF(secondVal, minVal)) {
         // Now you can use secondVal and minVal
         Print("Second value: ", secondVal);
         Print("Minimum of first & third: ", minVal);
         
         if(GoLong(first_value_ltf, sixth_value_ltf)){
               Print("Third Low: ", first_value_ltf);
               Print("Starting of trend: ", sixth_value_ltf);
               
              if(last_order_price != first_value_ltf){
               
                    if(minVal < sixth_value_ltf && secondVal > first_value_ltf ){
                    
                           double sl = minVal;
                           double tp = first_value_ltf + (first_value_ltf - minVal);  // 1:1 R:R (optional)
               
                           if (trade.BuyStop(lotSize, first_value_ltf, _Symbol, sl, tp, ORDER_TIME_GTC, 0, "BuyStop from DB")) {
                              Print("Buy Stop placed at: ", first_value_ltf);
                              last_order_price = first_value_ltf;
                           } else {
                              Print("Buy Stop failed. Error: ", GetLastError());
                           }
                           
                       }       
   
              }
            
           }
         
         // Use them to place trades, alerts, etc.
      }
   
   
   

     
        if (Find_Double_Top_HTF(secondVal, maxVal)) {
            Print("Second value (middle point): ", secondVal);
            Print("Max of first & third: ", maxVal);
            
            if(GoShort(first_value_ltf, sixth_value_ltf)){
                  Print("Third Low: ", first_value_ltf);
                  Print("Starting of trend: ", sixth_value_ltf);
                  
                 if(last_order_price != first_value_ltf){
      
                  
                     if(maxVal > sixth_value_ltf && secondVal < first_value_ltf ){
                        double sl = maxVal;
                        double tp = first_value_ltf - (maxVal - first_value_ltf);  // 1:1 R:R (optional)
            
                        if (trade.SellStop(lotSize, first_value_ltf, _Symbol, sl, tp, ORDER_TIME_GTC, 0, "SellStop from DT")) {
                           Print("Sell Stop placed at: ", first_value_ltf);
                           last_order_price = first_value_ltf;
                        } else {
                           Print("Sell Stop failed. Error: ", GetLastError());
                        }   
                  }
                  
                 
           }
            // You can now use these for zones, entries, alerts, etc.
         }
   
   }
   
   
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
bool Find_Double_Bottom_HTF(double &secondVal, double &minVal) {
   double first_value  = ZZ_Values_HTF[1];
   double second_value = ZZ_Values_HTF[2];
   double third_value  = ZZ_Values_HTF[3];
   double fourth_value  = ZZ_Values_HTF[4];

   datetime t1 = ZZ_Times_HTF[1];
   datetime t2 = ZZ_Times_HTF[2];
   datetime t3 = ZZ_Times_HTF[3];
   
   double yo1 = MathAbs(ZZ_Values_HTF[4]-ZZ_Values_HTF[3]);
   double yo2 = MathAbs(ZZ_Values_HTF[3]-ZZ_Values_HTF[2]);
   bool length_is_okk = yo1 > 1.2*yo2;

   if (first_value < second_value && second_value > third_value && MathAbs(first_value - third_value) <= atr_HTF * Distance_Coeff_HTF) {
      if(length_is_okk){
         
        
      DrawHorizontalLine("Bottom_Line_1", first_value, clrGreen);
      DrawHorizontalLine("Bottom_Line_2", second_value, clrGreen);

      DrawVerticalLine("Bottom_2", t1, clrYellow);
      DrawVerticalLine("Bottom_Mid",t2, clrYellow);
      DrawVerticalLine("Bottom_1", t3, clrYellow);
      
      // Output values
      secondVal = second_value;
      minVal = MathMin(first_value, third_value);

      return true;
   }
 }
   return false;
}

//+------------------------------------------------------------------+
//| Detect Double Top Pattern                                        |
//+------------------------------------------------------------------+
bool Find_Double_Top_HTF(double &secondVal, double &maxVal) {
   double first_value  = ZZ_Values_HTF[1];
   double second_value = ZZ_Values_HTF[2];
   double third_value  = ZZ_Values_HTF[3];
   double fourth_value  = ZZ_Values_HTF[4];

   datetime t1 = ZZ_Times_HTF[1];
   datetime t2 = ZZ_Times_HTF[2];
   datetime t3 = ZZ_Times_HTF[3];
   
   double yo1 = MathAbs(ZZ_Values_HTF[4]-ZZ_Values_HTF[3]);
   double yo2 = MathAbs(ZZ_Values_HTF[3]-ZZ_Values_HTF[2]);
   bool length_is_okk = yo1 > 1.2*yo2;
   
   
   if (first_value > second_value && second_value < third_value && MathAbs(first_value - third_value) <= atr_HTF * Distance_Coeff_HTF) {
   
      if(length_is_okk){
      
         DrawHorizontalLine("Top_Line_1", first_value, clrRed);
         DrawHorizontalLine("Top_Line_2", second_value, clrRed);
   
         DrawVerticalLine("TOP_2",    t1, clrAqua);
         DrawVerticalLine("Top_Mid", t2, clrAqua);
         DrawVerticalLine("TOP_1",    t3, clrAqua);
   
         // Output values
         secondVal = second_value;
         maxVal = MathMax(first_value, third_value);
   
         return true;
   }
}
   return false;
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



void DrawV_Line(string name, datetime time, color clr) {
   string obj_name = name + "_" + IntegerToString(time); // Ensure uniqueness
   if (!ObjectCreate(0, obj_name, OBJ_VLINE, 0, time, 0)) {
      Print("Failed to create vertical line: ", obj_name);
      return;
   }
   ObjectSetInteger(0, obj_name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, obj_name, OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, obj_name, OBJPROP_STYLE, STYLE_SOLID);
}

void DrawLine(string name, double price, color lineColor) {
   if (!ObjectCreate(0, name, OBJ_HLINE, 0, 0, price))
      return;

   ObjectSetInteger(0, name, OBJPROP_COLOR, lineColor);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 2);
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
}



bool GoShort(double &first_value_ltf, double &sixth_value_ltf) {

   if (PositionSelect(_Symbol)) return false;
   static double last_order_price = 0;

   double first_value  = ZZ_Values_LTF[1]; // Low 3
   double second_value = ZZ_Values_LTF[2]; // High 3
   double third_value  = ZZ_Values_LTF[3]; // Low 2
   double fourth_value = ZZ_Values_LTF[4]; // High 2
   double fifth_value  = ZZ_Values_LTF[5]; // Low 1
   double sixth_value  = ZZ_Values_LTF[6]; // High 1

   if (fifth_value > third_value && third_value > first_value && first_value < second_value) {
      if ((MathAbs(fourth_value - second_value) <= atr_LTF * Pullbacks_Distance_Coeff_LTF) || (fourth_value <= second_value)) {
         Print("Downtrend detected");

         datetime line_time = iTime(_Symbol, LTF, ZZ_Bars_LTF[1]);
         DrawV_Line("Downtrend", line_time, clrWhite);
         
         
         first_value_ltf = first_value;
         sixth_value_ltf = sixth_value;
      }
      
      return true;
   }





   return false;
}







bool GoLong(double &first_value_ltf, double &sixth_value_ltf) {



   double first_value  = ZZ_Values_LTF[1]; // High 3
   double second_value = ZZ_Values_LTF[2]; // Low 3
   double third_value  = ZZ_Values_LTF[3]; // High 2
   double fourth_value = ZZ_Values_LTF[4]; // Low 2
   double fifth_value  = ZZ_Values_LTF[5]; // High 1
   double sixth_value  = ZZ_Values_LTF[6]; // Low 1

   if (fifth_value < third_value && third_value < first_value && first_value > second_value) {
      if ((MathAbs(fourth_value - second_value) <= atr_LTF * Pullbacks_Distance_Coeff_LTF) || (fourth_value >= second_value)) {
            Print("Uptrend detected");
   
            datetime line_time = iTime(_Symbol, LTF, ZZ_Bars_LTF[1]);
            DrawV_Line("Uptrend", line_time, clrWhite);
            
            first_value_ltf = first_value;
            sixth_value_ltf = sixth_value;
            
            
            
            
      }
      
      return true;
   }

   return false;
}
