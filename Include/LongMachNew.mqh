#include "Common.mqh"
//==================== 1. Trend + Pullback EMA20/50 + RSI ====================
string handleTrendPullback(string symbol, ENUM_TIMEFRAMES tf)
{
   double ema20[2], ema50[2], rsi[2];
   int hEma20 = iMA(symbol, tf, 20, 0, MODE_EMA, PRICE_CLOSE);
   int hEma50 = iMA(symbol, tf, 50, 0, MODE_EMA, PRICE_CLOSE);
   int hRSI   = iRSI(symbol, tf, 14, PRICE_CLOSE);

   if(hEma20==INVALID_HANDLE || hEma50==INVALID_HANDLE || hRSI==INVALID_HANDLE)
      return TypeNULL;

   if(CopyBuffer(hEma20,0,0,2,ema20)<2 ||
      CopyBuffer(hEma50,0,0,2,ema50)<2 ||
      CopyBuffer(hRSI,0,0,2,rsi)<2)
      return TypeNULL;

   if(ema20[0] > ema50[0] && rsi[1] < 50 && rsi[0] >= 50)
      return TypeBUY;

   if(ema20[0] < ema50[0] && rsi[1] > 50 && rsi[0] <= 50)
      return TypeSELL;

   return TypeNULL;
}

//==================== 2. Breakout High/Low gần nhất ====================
string handleBreakout(string symbol, ENUM_TIMEFRAMES tf)
{
   double high[2], low[2], close[1];

   if(CopyHigh(symbol,tf,1,2,high)<2 ||
      CopyLow(symbol,tf,1,2,low)<2 ||
      CopyClose(symbol,tf,0,1,close)<1)
      return TypeNULL;

   if(close[0] > high[0])
      return TypeBUY;

   if(close[0] < low[0])
      return TypeSELL;

   return TypeNULL;
}

//==================== 3. RSI Overbought / Oversold + đảo chiều ====================
string handleRSIExtreme(string symbol, ENUM_TIMEFRAMES tf)
{
   double rsi[2];
   int hRSI = iRSI(symbol, tf, 14, PRICE_CLOSE);

   if(hRSI == INVALID_HANDLE)
      return TypeNULL;

   if(CopyBuffer(hRSI,0,0,2,rsi)<2)
      return TypeNULL;

   if(rsi[1] < 20 && rsi[0] > 20)
      return TypeBUY;

   if(rsi[1] > 80 && rsi[0] < 80)
      return TypeSELL;

   return TypeNULL;
}

//==================== 4. EMA9 / EMA21 + Volume ====================
string handleEMA_Volume(string symbol, ENUM_TIMEFRAMES tf)
{
   double ema9[2], ema21[2];
   long   vol[2];

   ArraySetAsSeries(ema9,  true);
   ArraySetAsSeries(ema21, true);
   ArraySetAsSeries(vol,   true);

   int hEma9  = iMA(symbol, tf, 9, 0, MODE_EMA, PRICE_CLOSE);
   int hEma21 = iMA(symbol, tf, 21, 0, MODE_EMA, PRICE_CLOSE);

   if(hEma9 == INVALID_HANDLE || hEma21 == INVALID_HANDLE)
      return TypeNULL;

   if(CopyBuffer(hEma9,  0, 0, 2, ema9)  < 2 ||
      CopyBuffer(hEma21, 0, 0, 2, ema21) < 2 ||
      CopyTickVolume(symbol, tf, 0, 2, vol) < 2)
      return TypeNULL;

   if(ema9[1] < ema21[1] && ema9[0] > ema21[0] && vol[0] > vol[1])
      return TypeBUY;

   if(ema9[1] > ema21[1] && ema9[0] < ema21[0] && vol[0] > vol[1])
      return TypeSELL;

   return TypeNULL;
}


//==================== 5. Price Action – Engulfing ====================
string handleEngulfing(string symbol, ENUM_TIMEFRAMES tf)
{
   double open[2], close[2];

   if(CopyOpen(symbol,tf,1,2,open)<2 ||
      CopyClose(symbol,tf,1,2,close)<2)
      return TypeNULL;

   // Bullish engulfing
   if(close[1] < open[1] && close[0] > open[0] && close[0] > open[1])
      return TypeBUY;

   // Bearish engulfing
   if(close[1] > open[1] && close[0] < open[0] && close[0] < open[1])
      return TypeSELL;

   return TypeNULL;
}


//==================== 6. Momentum giá (ăn theo lực đẩy nhanh) ====================
string handlePriceMomentum(string symbol, double thresholdPoints = 300)
{
   double close[2];
   if(CopyClose(symbol, PERIOD_CURRENT, 0, 2, close) < 2)
      return TypeNULL;

   double diff = (close[0] - close[1]) / _Point;

   if(diff >= thresholdPoints)
      return TypeBUY;

   if(diff <= -thresholdPoints)
      return TypeSELL;

   return TypeNULL;
}

//==================== 7. Break High / Low nến trước ====================
string handlePriceBreakCandle(string symbol)
{
   double high[1], low[1], close[1];

   if(CopyHigh(symbol, PERIOD_CURRENT, 1, 1, high) < 1 ||
      CopyLow(symbol,  PERIOD_CURRENT, 1, 1, low)  < 1 ||
      CopyClose(symbol,PERIOD_CURRENT, 0, 1, close)< 1)
      return TypeNULL;

   if(close[0] > high[0])
      return TypeBUY;

   if(close[0] < low[0])
      return TypeSELL;

   return TypeNULL;
}

//==================== 8. Pullback theo giá (không indicator) ====================
string handlePricePullback(string symbol, double pullbackPoints = 200)
{
   double high[2], low[2], close[1];

   if(CopyHigh(symbol, PERIOD_CURRENT, 0, 2, high) < 2 ||
      CopyLow(symbol,  PERIOD_CURRENT, 0, 2, low)  < 2 ||
      CopyClose(symbol,PERIOD_CURRENT, 0, 1, close)< 1)
      return TypeNULL;

   if(high[1] - close[0] >= pullbackPoints * _Point)
      return TypeBUY;

   if(close[0] - low[1] >= pullbackPoints * _Point)
      return TypeSELL;

   return TypeNULL;
}

//==================== 9. False Break (quét đỉnh đáy) ====================
string handleFalseBreak(string symbol, double rejectPoints = 150)
{
   double high[2], low[2], close[1];

   if(CopyHigh(symbol, PERIOD_CURRENT, 1, 2, high) < 2 ||
      CopyLow(symbol,  PERIOD_CURRENT, 1, 2, low)  < 2 ||
      CopyClose(symbol,PERIOD_CURRENT, 0, 1, close)< 1)
      return TypeNULL;

   if(close[0] < high[0] - rejectPoints * _Point)
      return TypeSELL;

   if(close[0] > low[0] + rejectPoints * _Point)
      return TypeBUY;

   return TypeNULL;
}

//==================== 10. Range nhỏ → phá range ====================
string handlePriceRangeBreak(string symbol, double rangePoints = 400)
{
   double high[5], low[5], close[1];

   if(CopyHigh(symbol, PERIOD_CURRENT, 1, 5, high) < 5 ||
      CopyLow(symbol,  PERIOD_CURRENT, 1, 5, low)  < 5 ||
      CopyClose(symbol,PERIOD_CURRENT, 0, 1, close)< 1)
      return TypeNULL;

   double maxHigh = high[0];
   double minLow  = low[0];

   for(int i=1;i<5;i++)
   {
      if(high[i] > maxHigh) maxHigh = high[i];
      if(low[i]  < minLow)  minLow  = low[i];
   }

   if((maxHigh - minLow) / _Point > rangePoints)
      return TypeNULL;

   if(close[0] > maxHigh)
      return TypeBUY;

   if(close[0] < minLow)
      return TypeSELL;

   return TypeNULL;
}

