#include "Common.mqh"

string CheckThreeCandlesPattern(string symbol)
{
    MqlRates candles[3];

    // Lấy 3 nến đã đóng
    if(CopyRates(symbol, PERIOD_M1, 1, 3, candles) < 3)
        return TypeNULL;

    // candles[2] = xa nhất
    bool red_oldest   = candles[2].close < candles[2].open;
    bool green_oldest = candles[2].close > candles[2].open;

    // candles[2] = giữa
    bool red_mid      = candles[1].close < candles[1].open;
    bool green_mid    = candles[1].close > candles[1].open;

    // candles[0] = gần nhất
    bool red_latest   = candles[0].close < candles[0].open;
    bool green_latest = candles[0].close > candles[0].open;

    // đỏ (xa nhất) - xanh - xanh (gần nhất) → BUY
    if(red_oldest && green_mid && green_latest)
        return TypeSELL;

    // xanh (xa nhất) - đỏ - đỏ (gần nhất) → SELL
    if(green_oldest && red_mid && red_latest)
        return TypeBUY;

    return TypeNULL;
}
// PERIOD_M30
// PERIOD_H1 ddang co lai~


string handleRSI_57_43(string symbol, ENUM_TIMEFRAMES tf, int periodRSI = 14)
{
   double rsi[2];

   int rsiHandle = iRSI(symbol, tf, periodRSI, PRICE_CLOSE);
   if(rsiHandle == INVALID_HANDLE)
      return TypeNULL;

   // Lấy bar 0 và bar 1
   if(CopyBuffer(rsiHandle, 0, 0, 2, rsi) < 2)
   {
      IndicatorRelease(rsiHandle);
      return TypeNULL;
   }

   double curRSI  = rsi[0]; // bar hiện tại
   double prevRSI = rsi[1]; // bar trước

   IndicatorRelease(rsiHandle);

   if(prevRSI < 57 && curRSI >= 57)
      return TypeBUY;

   if(prevRSI > 43 && curRSI <= 43)
      return TypeSELL;

   return TypeNULL;
}



string handleRSI_67_33(string symbol, ENUM_TIMEFRAMES tf, int periodRSI = 14)
{
   double rsi[2];

   int rsiHandle = iRSI(symbol, tf, periodRSI, PRICE_CLOSE);
   if(rsiHandle == INVALID_HANDLE)
      return TypeNULL;

   if(CopyBuffer(rsiHandle, 0, 1, 2, rsi) < 2)
      return TypeNULL;

   double prevRSI = rsi[1];
   double curRSI  = rsi[0];

   if(prevRSI < 67 && curRSI >= 67)
      return TypeBUY;

   if(prevRSI > 33 && curRSI <= 33)
      return TypeSELL;

   return TypeNULL;
}


string CheckRSIBullBear(string symbol, int periodRSI = 14)
{
   double rsi[3];
   if(CopyBuffer(iRSI(symbol, PERIOD_M30, periodRSI, PRICE_CLOSE), 0, 1, 3, rsi) < 3)
      return TypeNULL;

   double rsi2 = rsi[2]; // cũ nhất
   double rsi1 = rsi[1];
   double rsi0 = rsi[0]; // mới nhất

   // Bull: RSI tăng liên tục
   if(rsi2 < rsi1 && rsi1 < rsi0)
      return TypeBUY;

   // Bear: RSI giảm liên tục
   if(rsi2 > rsi1 && rsi1 > rsi0)
      return TypeSELL;
   return TypeNULL;
}

string CheckRSIBullBear2(string symbol, int periodRSI = 14)
{
   double rsi[3];
   if(CopyBuffer(iRSI(symbol, PERIOD_H1, periodRSI, PRICE_CLOSE), 0, 1, 3, rsi) < 3)
      return TypeNULL;

   double rsi2 = rsi[2]; // cũ nhất
   double rsi1 = rsi[1];
   double rsi0 = rsi[0]; // mới nhất

   // Bull: RSI tăng liên tục
   if(rsi2 < rsi1 && rsi1 < rsi0)
      return TypeBUY;

   // Bear: RSI giảm liên tục
   if(rsi2 > rsi1 && rsi1 > rsi0)
      return TypeSELL;
   return TypeNULL;
}

// string CheckRSI57_43cac(string symbol, int periodRSI = 14)
// {
//    // --- RSI
//    double rsi[3];
//    if(CopyBuffer(iRSI(symbol, PERIOD_M30, periodRSI, PRICE_CLOSE), 0, 1, 3, rsi) < 3)
//       return TypeNULL;

//    double rsiA = rsi[2]; // điểm A
//    double rsiB = rsi[1]; // điểm B
//    double rsiC = rsi[0];

//    // =========================
//    // PHÂN KỲ GIẢM – VÙNG 70 → SELL
//    // A chạm 70+, B xuống dưới 70
//    if(rsiA >= 71 && rsiB < 69)
//       return TypeSELL;

//    // =========================
//    // PHÂN KỲ TĂNG – VÙNG 30 → BUY
//    // A chạm 30-, B lên trên 30
//    if(rsiA <= 29 && rsiB > 31)
//       return TypeBUY;

//    return TypeNULL;
// }



// RSI đi xuống chạm 43 → Short
bool IsRSIDownTo43(string symbol, int periodRSI = 14){
   double rsi[2];
   if(CopyBuffer(iRSI(symbol, PERIOD_M15, periodRSI, PRICE_CLOSE), 0, 1, 2, rsi) < 2)
      return false;

   double prevRSI = rsi[1];
   double curRSI  = rsi[0];

   return (prevRSI > 43 && curRSI <= 43);
};

