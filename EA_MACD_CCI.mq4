//+------------------------------------------------------------------+
//|                                                  EA_MACD_CCI.mq4 |
//|                                                  Leyla Khojasteh |
//|                                          n.khojasteh80@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Leyla Khojasteh"
#property link      "n.khojasteh80@gmail.com"
#property version   "1.00"
#property strict

extern double lotsize=0.05;  //Enter lot size:
int input ma_period = 100;
int input macd_fast_period = 12;
int input macd_slow_period = 26;
int input macd_sma_period = 9;
int input cci_period = 14;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   Print("EA MACD CCI started:...");
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   Print("EA MACD CCI removed:...");
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(ExitSignal()=="closebuy")
      closing(444);
   if(ExitSignal()=="closesell")
      closing(555);

   if(Volume[0]<=1 && CountOrders(444)==0  && CountOrders(555)==0)
     {
      if(EntrySignal()=="Buy" && iMA(_Symbol,PERIOD_CURRENT,ma_period,0,MODE_SMA,PRICE_CLOSE,1)<Close[1])
         int ticket=OrderSend(Symbol(),OP_BUY,lotsize,Ask,5,0,0,"MACD CCI Buy",444,0,clrGreen);


      if(EntrySignal()=="Sell" && iMA(_Symbol,PERIOD_CURRENT,ma_period,0,MODE_SMA,PRICE_CLOSE,1)>Close[1])
         int ticket=OrderSend(Symbol(),OP_SELL,lotsize,Bid,5,0,0,"MACD CCI Sell",555,0,clrYellow);

     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string EntrySignal()
  { 
   double prev_macd_main=   iMACD(Symbol(),0,macd_fast_period,macd_slow_period,macd_sma_period,PRICE_CLOSE,MODE_MAIN,2);
   double prev_macd_signal= iMACD(Symbol(),0,macd_fast_period,macd_slow_period,macd_sma_period,PRICE_CLOSE,MODE_SIGNAL,2);
   
   double new_macd_main=   iMACD(Symbol(),0,macd_fast_period,macd_slow_period,macd_sma_period,PRICE_CLOSE,MODE_MAIN,1);
   double new_macd_signal= iMACD(Symbol(),0,macd_fast_period,macd_slow_period,macd_sma_period,PRICE_CLOSE,MODE_SIGNAL,1);
   double new_cci=         iCCI(Symbol(),0,cci_period,PRICE_TYPICAL,1);
   
   if(prev_macd_main<prev_macd_signal && new_macd_main>new_macd_signal && new_cci>100)
      return("Buy");

   else
      if(prev_macd_main>prev_macd_signal && new_macd_main<new_macd_signal && new_cci<-100)
         return("Sell");

      else
         return("no signal");
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string ExitSignal()
  {
   if(iMACD(Symbol(),0,12,26,9,PRICE_CLOSE,MODE_MAIN,2)>iMACD(Symbol(),0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,2) && iMACD(Symbol(),0,12,26,9,PRICE_CLOSE,MODE_MAIN,1)<iMACD(Symbol(),0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,1))
      return("closebuy");

   else
      if(iMACD(Symbol(),0,12,26,9,PRICE_CLOSE,MODE_MAIN,2)<iMACD(Symbol(),0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,2) && iMACD(Symbol(),0,12,26,9,PRICE_CLOSE,MODE_MAIN,1)>iMACD(Symbol(),0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,1))
         return("closesell");

      else
         return("nothing");
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void closing(int Magic)
  {
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderMagicNumber()==Magic)
           {
            if(OrderType()==OP_BUY)
              {
               bool clos=OrderClose(OrderTicket(),OrderLots(),Bid,5,clrRed);
              }
            else
               if(OrderType()==OP_SELL)
                 {
                  bool clos=OrderClose(OrderTicket(),OrderLots(),Ask,5,clrRed);
                 }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CountOrders(int Magic)
  {
   int num=0;
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderMagicNumber()==Magic)
           {num++;}
        }
     }
   return(num);
  }


//+------------------------------------------------------------------+