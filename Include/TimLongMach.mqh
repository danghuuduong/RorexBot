#define TypeBuy  "BUY"
#define TypeSELL "SELL"
#define TypeNULL "null"

string CheckFourCandlesPattern3(string symbol)
{
    MqlRates candles[4];

    if(CopyRates(symbol, PERIOD_M3, 1, 4, candles) < 4)
        return TypeNULL;

    // Kiểm tra mẫu nến
    if(candles[0].close < candles[0].open && candles[1].close > candles[1].open &&
       candles[2].close < candles[2].open && candles[3].close > candles[3].open)
        return TypeBuy;

    if(candles[0].close > candles[0].open && candles[1].close < candles[1].open &&
       candles[2].close > candles[2].open && candles[3].close < candles[3].open)
        return TypeSELL;

    return TypeNULL;
}
string CheckFourCandlesPattern5(string symbol)
{
    MqlRates candles[4];

    if(CopyRates(symbol, PERIOD_M5, 1, 4, candles) < 4)
        return TypeNULL;

    // Kiểm tra mẫu nến
    if(candles[0].close < candles[0].open && candles[1].close > candles[1].open &&
       candles[2].close < candles[2].open && candles[3].close > candles[3].open)
        return TypeBuy;

    if(candles[0].close > candles[0].open && candles[1].close < candles[1].open &&
       candles[2].close > candles[2].open && candles[3].close < candles[3].open)
        return TypeSELL;

    return TypeNULL;
}
string CheckFourCandlesPattern15(string symbol)
{
    MqlRates candles[4];

    if(CopyRates(symbol, PERIOD_M3, 1, 4, candles) < 4)
        return TypeNULL;

    // Kiểm tra mẫu nến
    if(candles[0].close < candles[0].open && candles[1].close > candles[1].open &&
       candles[2].close < candles[2].open && candles[3].close > candles[3].open)
        return TypeBuy;

    if(candles[0].close > candles[0].open && candles[1].close < candles[1].open &&
       candles[2].close > candles[2].open && candles[3].close < candles[3].open)
        return TypeSELL;

    return TypeNULL;
}



// RSI đi lên chạm 57 → Long
bool IsRSIUpTo57(string symbol, int periodRSI = 14){
   double rsi[2];
   if(CopyBuffer(iRSI(symbol, PERIOD_M15, periodRSI, PRICE_CLOSE), 0, 1, 2, rsi) < 2)
      return false;

   double prevRSI = rsi[1];
   double curRSI  = rsi[0];

   return (prevRSI < 57 && curRSI >= 57);
};

// RSI đi xuống chạm 43 → Short
bool IsRSIDownTo43(string symbol, int periodRSI = 14){
   double rsi[2];
   if(CopyBuffer(iRSI(symbol, PERIOD_M15, periodRSI, PRICE_CLOSE), 0, 1, 2, rsi) < 2)
      return false;

   double prevRSI = rsi[1];
   double curRSI  = rsi[0];

   return (prevRSI > 43 && curRSI <= 43);
};

bool IsThreeRedM3(string symbol)
{
   MqlRates candles[3];

   if(CopyRates(symbol, PERIOD_M3, 1, 3, candles) < 3)
      return false;

   for(int i = 0; i < 3; i++)
   {
      if(candles[i].close >= candles[i].open)
         return false;
   }

   return true;
};

bool IsThreeRedM5(string symbol)
{
   MqlRates candles[3];

   if(CopyRates(symbol, PERIOD_M5, 1, 3, candles) < 3)
      return false;

   for(int i = 0; i < 3; i++)
   {
      if(candles[i].close >= candles[i].open)
         return false;
   }

   return true;
};

bool IsThreeRedM15(string symbol)
{
   MqlRates candles[3];

   if(CopyRates(symbol, PERIOD_M15, 1, 3, candles) < 3)
      return false;

   for(int i = 0; i < 3; i++)
   {
      if(candles[i].close >= candles[i].open)
         return false;
   }

   return true;
}