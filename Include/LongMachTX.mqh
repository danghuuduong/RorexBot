
#include "Common.mqh"
#define T "TÀI"
#define X "o"

struct PriceTrendState
{
   double init_price;          
   string trend_list[10];      
   int    count;               
   bool   isSetPrice;          
};

// ================= INIT =================
void InitPriceTrendState(PriceTrendState &state){
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
void CheckLongMachTX(PriceTrendState &state, string symbol)
{
   double current_price = SymbolInfoDouble(symbol, SYMBOL_BID);

   if(!state.isSetPrice)
   {
      state.init_price = current_price;
      state.isSetPrice = true;
      return;
   }

   if(current_price >= state.init_price + targetState)
   {
      PushTrend(state, T);
      state.init_price = current_price;
   }
   else if(current_price <= state.init_price - targetState)
   {
      PushTrend(state, X);
      state.init_price = current_price;
   }
}

// =============== ANALYZE PATTERN =================

struct TrendResult
{
   string type;    // "TX-ChanLe", "TX-song" hoặc "null"
   string huong;   // "BUY", "SELL" hoặc "null"
};


TrendResult KQLongMachTX(const PriceTrendState &state)
{
   TrendResult result;
   result.type  = "null";
   result.huong = "null";

   int n = state.count;

   // xử lý 4 cây cản tàu
   if(n >= 4)
   {
      // string a5  = state.trend_list[n-5];
      string a4  = state.trend_list[n-4];
      string a3  = state.trend_list[n-3];
      string a2  = state.trend_list[n-2];
      string a1  = state.trend_list[n-1];

      if(a4==X && a3==X && a2==X && a1==X)
      {
         result.type  = TX_be4;
         result.huong = TypeBUY;
         return result;
      }

       if(a4==T && a3==T && a2==T && a1==T)
      {
         result.type  = TX_be4;
         result.huong = TypeSELL;
         return result;
      }
   }

   if(n >= 6)
   {
      string a6  = state.trend_list[n-6];
      string a5  = state.trend_list[n-5];
      string a4  = state.trend_list[n-4];
      string a3  = state.trend_list[n-3];
      string a2  = state.trend_list[n-2];
      string a1  = state.trend_list[n-1];

      if(
         (a5==X && a4==X && a3==T && a2==T && a1==X) 
      )
      {
         result.type  = TX_becau22;
         result.huong = TypeBUY;
         return result;
      }

      if(
         ( a6==X && a5==X && a4==T && a3==T && a2==X && a1==X) 
      )
      {
         result.type  = TX_becau22;
         result.huong = TypeSELL;
         return result;
      }


      if(
         ( a5==T && a4==T && a3==X && a2==X && a1==T) 
      )
      {
         result.type  = TX_becau22;
         result.huong = TypeSELL;
         return result;
      }

      if(
         ( a6==T && a5==T && a4==X && a3==X && a2==T && a1==T) 
      )
      {
         result.type  = TX_becau22;
         result.huong = TypeBUY;
         return result;
      }
   }

   return result;
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

