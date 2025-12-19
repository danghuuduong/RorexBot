
#include "Common.mqh"
#define T "green"
#define X "red"

struct PriceTrendState
{
   double init_price;          
   string trend_list[10];      
   int    count;               
   bool   isSetPrice;          
};

// ================= INIT =================
void InitPriceTrendState(PriceTrendState &state)
{
   state.init_price = 0;
   state.count = 0;
   state.isSetPrice = false;

   for(int i=0;i<10;i++)
      state.trend_list[i] = "";
}

// =============== PUSH SLIDING ===============
void PushTrend(PriceTrendState &state, string value)// mã đã là 10 sẽ không vào đây nữa
{
   if(state.count < 10)
   {
      state.trend_list[state.count] = value;  // 0  khi chỗ này lên 9 ở dưới sẽ là 10
      state.count = state.count + 1; // 1  ==> trên 9 thì đây 10
      return;
   }
   //count 10: index 9

   for(int i=0; i<9 ;i++)state.trend_list[i] = state.trend_list[i+1]; // sẽ lấy index từ 0-8 gán lấy giá 1-9 ( bỏ cái 0 đầu tiên)
   state.trend_list[9] = value; // sau đó gán giá trị mới vào cuối cùng
   // => count luôn luôn 10 . 
}

// =============== UPDATE =================
void UpdatePriceTrendState(PriceTrendState &state, string symbol)
{
   double current_price = SymbolInfoDouble(symbol, SYMBOL_BID);

   if(!state.isSetPrice)
   {
      state.init_price = current_price;
      state.isSetPrice = true;
      return;
   }

   if(current_price >= state.init_price + 3)
   {
      PushTrend(state, XANH);
      state.init_price = current_price;
   }
   else if(current_price <= state.init_price - 3)
   {
      PushTrend(state, DO);
      state.init_price = current_price;
   }
}

// =============== ANALYZE PATTERN =================

struct TrendResult
{
   string type;    // "TX-ChanLe", "TX-song" hoặc "null"
   string huong;   // "BUY", "SELL" hoặc "null"
};


TrendResult AnalyzeTrendSignal(const PriceTrendState &state){
   TrendResult result;
   result.type  = "null";
   result.huong = "null";
   int n = state.count;
   int thep = state.th;//add z

   if(n >= 4)
   {
      string a = state.trend_list[n-4];
      string b = state.trend_list[n-3];
      string c = state.trend_list[n-2];
      string d = state.trend_list[n-1];

      if(a==X && b==T && c==X && d==T)
      {
         result.type  = TX_SenKe4;
         result.huong = TypeBUY;
         return result;
      }

      if(a==X && b==T && c==X && d==T)
      {
         result.type  = TX_SenKe4;
         result.huong = TypeSELL;
         return result;
      }
   }

   if(n >= 5)
   {
      string a = state.trend_list[n-5];
      string b = state.trend_list[n-4];
      string c = state.trend_list[n-3];
      string d = state.trend_list[n-2];
      string e = state.trend_list[n-1];

      if(a==X && b==X && c==T && d==T && e==X && thep == 0)   //X-X-T-T-X         => T    (1)
      {
         result.type  = TX_becau22;
         result.huong = TypeBUY;
         return result;
      }

      if(a==X && b==T && c==T && d==X && e==X && thep == 1)    //X X T T X X          => X   (2)
      {
         result.type  = TX_becau22;
         result.huong = TypeSELL;
         return result;
      }

      if(a==X && b==T && c==T && d==X && e==X && thep == 1)    //X X T T X X T          => X    (3)
      {
         result.type  = TX_becau22;
         result.huong = TypeSELL;
         return result;
      }

      if(a==X && b==T && c==T && d==X && e==X)    //X X T T X X T T          => T    (4)
      {
         result.type  = TX_becau22;
         result.huong = TypeSELL;
         return result;
      }

       if(a==X && b==T && c==T && d==X && e==X)    //X X T T X X T T X         => T    (5)
      {
         result.type  = TX_becau22;
         result.huong = TypeSELL;
         return result;
      }
      // END MODEL //X-X-T-T-X   


      if(a==T && b==T && c==X && d==X && e==T)  // T T X X T        => X (1)
      {
         result.type  = TX_becau22;
         result.huong = TypeSELL;
         return result;
      }

      

     

      if(a==T && b==X && c==X && d==T && e==T)   //T T X X T T   => T  (2)
      {
         result.type  = TX_becau22;
         result.huong = TypeBUY;
         return result;
      }
      if(a==T && b==X && c==X && d==T && e==T)   //T T X X T T X   => T (3)
      {
         result.type  = TX_becau22;
         result.huong = TypeBUY;
         return result;
      }

      if(a==T && b==X && c==X && d==T && e==T)   //T T X X T T X x  => X (4)
      {
         result.type  = TX_becau22;
         result.huong = TypeBUY;
         return result;
      }
       if(a==T && b==X && c==X && d==T && e==T)   //T T X X T T X X T  => X (5)
      {
         result.type  = TX_becau22;
         result.huong = TypeBUY;
         return result;
      }
   }

   return result; 
}

void LogInitPrice(const PriceTrendState &state)
{
   if(!state.isSetPrice) return;

   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

   PrintFormat(
      "Init= %.*f | ASK= %.*f | BID= %.*f",
      _Digits, state.init_price,
      _Digits, ask,
      _Digits, bid
   );
}
void LogTrendArray(const PriceTrendState &state)
{
   string log = "[";

   for(int i = 0; i < state.count; i++)
   {
      log += "\"" + state.trend_list[i] + "\"";
      if(i < state.count - 1)
         log += ",";
   }

   log += "]";
   Print("Trend array = ", log);
}

