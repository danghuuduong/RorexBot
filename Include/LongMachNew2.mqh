#include "Common.mqh"
// Định nghĩa các hằng số trả về (giả sử bạn đã có các biến này)

// ===================== EMA200 + UT BOT =====================
string handlePriceMomentum(
   string symbol,
   ENUM_TIMEFRAMES tfTrend,   // ví dụ: PERIOD_M15 (EMA200)
   ENUM_TIMEFRAMES tfEntry    // ví dụ: PERIOD_M5  (UT Bot)
)
{
   // =====================================================
   // 1. LẤY NẾN KHUNG TREND (EMA)
   // =====================================================
   MqlRates trendRates[];
   ArraySetAsSeries(trendRates, true);
   if(CopyRates(symbol, tfTrend, 0, 5, trendRates) <= 0)
      return TypeNULL;

   double trendClose = trendRates[1].close; // nến trend đã đóng

   // =====================================================
   // 2. EMA 200 (KHUNG TREND)
   // =====================================================
   int emaHandle = iMA(symbol, tfTrend, 200, 0, MODE_EMA, PRICE_CLOSE);
   if(emaHandle == INVALID_HANDLE)
      return TypeNULL;

   double emaBuf[];
   ArraySetAsSeries(emaBuf, true);
   if(CopyBuffer(emaHandle, 0, 0, 5, emaBuf) <= 0)
      return TypeNULL;

   double ema200 = emaBuf[1]; // EMA200 tại nến đã đóng

   bool trendBuy  = (trendClose > ema200); // trend tăng
   bool trendSell = (trendClose < ema200); // trend giảm

   // =====================================================
   // 3. LẤY NẾN KHUNG ENTRY (UT BOT)
   // =====================================================
   MqlRates entryRates[];
   ArraySetAsSeries(entryRates, true);
   if(CopyRates(symbol, tfEntry, 0, 5, entryRates) <= 0)
      return TypeNULL;

   double close1 = entryRates[1].close; // nến entry vừa đóng
   double close2 = entryRates[2].close; // nến trước đó

   // =====================================================
   // 4. ATR (UT BOT CORE - KHUNG ENTRY)
   // =====================================================
   int    atrPeriod = 10;
   double keyVal    = 1.0;

   int atrHandle = iATR(symbol, tfEntry, atrPeriod);
   if(atrHandle == INVALID_HANDLE)
      return TypeNULL;

   double atrBuf[];
   ArraySetAsSeries(atrBuf, true);
   if(CopyBuffer(atrHandle, 0, 0, 5, atrBuf) <= 0)
      return TypeNULL;

   double atr = atrBuf[1];

   // =====================================================
   // 5. TRAILING STOP (UT BOT)
   // =====================================================
   static double trailingStop = 0;

   double longStop  = close1 - atr * keyVal;
   double shortStop = close1 + atr * keyVal;

   // Khởi tạo trailing stop theo TREND LỚN
   if(trailingStop == 0)
   {
      if(trendBuy)
         trailingStop = longStop;
      else if(trendSell)
         trailingStop = shortStop;

      return TypeNULL;
   }

   // =====================================================
   // 6. LOGIC SELL (TREND M15 → ENTRY M5)
   // =====================================================
   if(trendSell)
   {
      // UT Bot cắt xuống
      if(close2 > trailingStop && close1 < trailingStop)
      {
         trailingStop = shortStop;
         return TypeSELL;
      }

      trailingStop = MathMin(trailingStop, shortStop);
      return TypeNULL;
   }

   // =====================================================
   // 7. LOGIC BUY (TREND M15 → ENTRY M5)
   // =====================================================
   if(trendBuy)
   {
      // UT Bot cắt lên
      if(close2 < trailingStop && close1 > trailingStop)
      {
         trailingStop = longStop;
         return TypeBUY;
      }

      trailingStop = MathMax(trailingStop, longStop);
      return TypeNULL;
   }

   return TypeNULL;
}

