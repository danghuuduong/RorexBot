#define TypeBuy  "BUY"
#define TypeSELL "SELL"
#define TypeNULL "null"

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
        return TypeBuy;

    return TypeNULL;
}
// PERIOD_M30
// PERIOD_H1 ddang co lai~

string CheckRSI57_43(string symbol, int periodRSI = 14)
{
   double rsi[2];
   if(CopyBuffer(iRSI(symbol, PERIOD_M5, periodRSI, PRICE_CLOSE), 0, 1, 2, rsi) < 2)
      return TypeNULL;

   double prevRSI = rsi[1];
   double curRSI  = rsi[0];

   // RSI cắt lên 57 → BUY
   if(prevRSI < 65 && curRSI >= 65)
      return TypeBuy;

   // RSI cắt xuống 43 → SELL
   if(prevRSI > 35 && curRSI <= 35)
      return TypeSELL;

   return TypeNULL;
}

string CheckRSI57_43cac(string symbol, int periodRSI = 14)
{
   // 65 và 35 khung m15 kết quả cực tốt .
   // 448 
   // 900$ 
   // 900$ 
   // 67 33 còn ác hơn ( ổn định cả 2 năm)
   double rsi[2];
   if(CopyBuffer(iRSI(symbol, PERIOD_M15, periodRSI, PRICE_CLOSE), 0, 1, 2, rsi) < 2)
      return TypeNULL;

   double prevRSI = rsi[1];
   double curRSI  = rsi[0];

   // RSI cắt lên 57 → BUY
   if(prevRSI < 67 && curRSI >= 67)
      return TypeBuy;

   // RSI cắt xuống 43 → SELL
   if(prevRSI > 33 && curRSI <= 33)
      return TypeSELL;

   return TypeNULL;
}


// RSI đi xuống chạm 43 → Short
bool IsRSIDownTo43(string symbol, int periodRSI = 14){
   double rsi[2];
   if(CopyBuffer(iRSI(symbol, PERIOD_M15, periodRSI, PRICE_CLOSE), 0, 1, 2, rsi) < 2)
      return false;

   double prevRSI = rsi[1];
   double curRSI  = rsi[0];

   return (prevRSI > 43 && curRSI <= 43);
};

