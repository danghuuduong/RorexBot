#include "Common.mqh"

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


//==================== 11. Inside Bar Break ====================
string handleInsideBarBreak(string symbol)
{
   double high[2], low[2], close[1];

   if(CopyHigh(symbol, PERIOD_CURRENT, 1, 2, high) < 2 ||
      CopyLow(symbol,  PERIOD_CURRENT, 1, 2, low)  < 2 ||
      CopyClose(symbol,PERIOD_CURRENT, 0, 1, close)< 1)
      return TypeNULL;

   if(high[0] < high[1] && low[0] > low[1])
   {
      if(close[0] > high[0]) return TypeBUY;
      if(close[0] < low[0])  return TypeSELL;
   }
   return TypeNULL;
}

//==================== 12. Marubozu (nến mạnh không râu) ====================
string handleMarubozu(string symbol, double minBodyPoints = 400)
{
   double open[1], close[1], high[1], low[1];

   if(CopyOpen(symbol, PERIOD_CURRENT, 1, 1, open)  < 1 ||
      CopyClose(symbol,PERIOD_CURRENT,1, 1, close) < 1 ||
      CopyHigh(symbol, PERIOD_CURRENT,1, 1, high)  < 1 ||
      CopyLow(symbol,  PERIOD_CURRENT,1, 1, low)   < 1)
      return TypeNULL;

   double body = MathAbs(close[0] - open[0]);
   double range = high[0] - low[0];

   if(range <= 0) return TypeNULL;

   if(body / range > 0.9 && body / _Point >= minBodyPoints)
   {
      if(close[0] > open[0]) return TypeBUY;
      if(close[0] < open[0]) return TypeSELL;
   }
   return TypeNULL;
}

//==================== 13. Gap giá (Forex ít gặp nhưng có) ====================
string handlePriceGap(string symbol, double gapPoints = 200)
{
   double open[1], closePrev[1];

   if(CopyOpen(symbol, PERIOD_CURRENT, 0, 1, open) < 1 ||
      CopyClose(symbol,PERIOD_CURRENT,1, 1, closePrev) < 1)
      return TypeNULL;

   double gap = (open[0] - closePrev[0]) / _Point;

   if(gap >= gapPoints)  return TypeBUY;
   if(gap <= -gapPoints) return TypeSELL;

   return TypeNULL;
}

//==================== 14. Đóng cửa vượt Mid nến trước ====================
string handleMidCandleBreak(string symbol)
{
   double high[1], low[1], close[1];

   if(CopyHigh(symbol, PERIOD_CURRENT, 1, 1, high) < 1 ||
      CopyLow(symbol,  PERIOD_CURRENT, 1, 1, low)  < 1 ||
      CopyClose(symbol,PERIOD_CURRENT, 0, 1, close)< 1)
      return TypeNULL;

   double mid = (high[0] + low[0]) / 2.0;

   if(close[0] > mid) return TypeBUY;
   if(close[0] < mid) return TypeSELL;

   return TypeNULL;
}

//==================== 15. 3 nến cùng màu (Price Action) ====================
string handleThreeCandleMomentum(string symbol)
{
   double open[3], close[3];

   if(CopyOpen(symbol, PERIOD_CURRENT, 1, 3, open)  < 3 ||
      CopyClose(symbol,PERIOD_CURRENT,1, 3, close) < 3)
      return TypeNULL;

   if(close[0] > open[0] &&
      close[1] > open[1] &&
      close[2] > open[2])
      return TypeBUY;

   if(close[0] < open[0] &&
      close[1] < open[1] &&
      close[2] < open[2])
      return TypeSELL;

   return TypeNULL;
}




//==================== 16. Pin Bar (râu dài) ====================
string handlePinBar(string symbol, double wickRatio = 2.5)
{
   double open[1], close[1], high[1], low[1];

   if(CopyOpen(symbol, PERIOD_CURRENT, 1, 1, open)  < 1 ||
      CopyClose(symbol,PERIOD_CURRENT,1, 1, close) < 1 ||
      CopyHigh(symbol, PERIOD_CURRENT,1, 1, high)  < 1 ||
      CopyLow(symbol,  PERIOD_CURRENT,1, 1, low)   < 1)
      return TypeNULL;

   double body = MathAbs(close[0] - open[0]);
   double upperWick = high[0] - MathMax(open[0], close[0]);
   double lowerWick = MathMin(open[0], close[0]) - low[0];

   if(body <= 0) return TypeNULL;

   if(lowerWick / body >= wickRatio && close[0] > open[0])
      return TypeBUY;

   if(upperWick / body >= wickRatio && close[0] < open[0])
      return TypeSELL;

   return TypeNULL;
}

//==================== 17. Break + Close ngoài High/Low ====================
string handleStrongBreakClose(string symbol)
{
   double high[1], low[1], close[1];

   if(CopyHigh(symbol, PERIOD_CURRENT, 1, 1, high) < 1 ||
      CopyLow(symbol,  PERIOD_CURRENT, 1, 1, low)  < 1 ||
      CopyClose(symbol,PERIOD_CURRENT, 0, 1, close)< 1)
      return TypeNULL;

   if(close[0] > high[0]) return TypeBUY;
   if(close[0] < low[0])  return TypeSELL;

   return TypeNULL;
}

//==================== 18. Fake Pullback (chạm nhưng không thủng) ====================
string handleFakePullback(string symbol, double rejectPoints = 150)
{
   double high[1], low[1], close[1];

   if(CopyHigh(symbol, PERIOD_CURRENT, 1, 1, high) < 1 ||
      CopyLow(symbol,  PERIOD_CURRENT, 1, 1, low)  < 1 ||
      CopyClose(symbol,PERIOD_CURRENT, 0, 1, close)< 1)
      return TypeNULL;

   if(close[0] > high[0] - rejectPoints * _Point)
      return TypeBUY;

   if(close[0] < low[0] + rejectPoints * _Point)
      return TypeSELL;

   return TypeNULL;
}

//==================== 19. Giá đóng cửa gần High / Low ====================
string handleCloseNearExtreme(string symbol, double percent = 0.8)
{
   double high[1], low[1], close[1];

   if(CopyHigh(symbol, PERIOD_CURRENT, 1, 1, high) < 1 ||
      CopyLow(symbol,  PERIOD_CURRENT, 1, 1, low)  < 1 ||
      CopyClose(symbol,PERIOD_CURRENT, 1, 1, close)< 1)
      return TypeNULL;

   double range = high[0] - low[0];
   if(range <= 0) return TypeNULL;

   if((close[0] - low[0]) / range >= percent)
      return TypeBUY;

   if((high[0] - close[0]) / range >= percent)
      return TypeSELL;

   return TypeNULL;
}

//==================== 20. Volatility Spike (nến đột biến) ====================
string handleVolatilitySpike(string symbol, double factor = 2.0)
{
   double high[3], low[3];

   if(CopyHigh(symbol, PERIOD_CURRENT, 1, 3, high) < 3 ||
      CopyLow(symbol,  PERIOD_CURRENT, 1, 3, low)  < 3)
      return TypeNULL;

   double range0 = high[0] - low[0];
   double range1 = high[1] - low[1];
   double range2 = high[2] - low[2];

   double avgRange = (range1 + range2) / 2.0;
   if(avgRange <= 0) return TypeNULL;

   if(range0 / avgRange >= factor)
   {
      double open[1], close[1];
      if(CopyOpen(symbol, PERIOD_CURRENT, 1, 1, open)  < 1 ||
         CopyClose(symbol,PERIOD_CURRENT,1, 1, close) < 1)
         return TypeNULL;

      if(close[0] > open[0]) return TypeBUY;
      if(close[0] < open[0]) return TypeSELL;
   }

   return TypeNULL;
}

