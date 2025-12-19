
#include "Common.mqh"
#define XANH "green"
#define DO "red"

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

   // ========= 4 PHẦN TỬ CUỐI =========
   if(n >= 4)
   {
      string a = state.trend_list[n-4];
      string b = state.trend_list[n-3];
      string c = state.trend_list[n-2];
      string d = state.trend_list[n-1];

      if(a==DO && b==XANH && c==DO && d==XANH)
      {
         result.type  = TX_chanle;
         result.huong = TypeBUY;
         return result;
      }

      if(a==XANH && b==DO && c==XANH && d==DO)
      {
         result.type  = TX_chanle;
         result.huong = TypeSELL;
         return result;
      }
   }

   // ========= 5 PHẦN TỬ CUỐI =========
   if(n >= 5)
   {
      string a = state.trend_list[n-5];
      string b = state.trend_list[n-4];
      string c = state.trend_list[n-3];
      string d = state.trend_list[n-2];
      string e = state.trend_list[n-1];

      if(a==DO && b==DO && c==XANH && d==XANH && e==DO)
      {
         result.type  = TX_becau22;
         result.huong = TypeBUY;
         return result;
      }

      if(a==DO && b==XANH && c==XANH && d==DO && e==DO)
      {
         result.type  = TX_becau22;
         result.huong = TypeSELL;
         return result;
      }

      if(a==XANH && b==XANH && c==DO && d==DO && e==XANH)
      {
         result.type  = TX_becau22;
         result.huong = TypeSELL;
         return result;
      }

      if(a==XANH && b==DO && c==DO && d==XANH && e==XANH)
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

