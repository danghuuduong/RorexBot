#include "Common2.mqh"
#include <Trade\Trade.mqh>

CTrade Trade;



void OpenOrder(ENUM_ORDER_TYPE type,double lot,int sectionId)
{
   MqlTradeRequest req;
   MqlTradeResult  res;

   ZeroMemory(req);
   ZeroMemory(res);

   req.action    = TRADE_ACTION_DEAL;
   req.symbol    = _Symbol;
   req.volume    = lot;
   req.type      = type;
   req.price     = (type==ORDER_TYPE_BUY)
                   ? SymbolInfoDouble(_Symbol,SYMBOL_ASK)
                   : SymbolInfoDouble(_Symbol,SYMBOL_BID);
   req.deviation = 50;
   req.comment =  IntegerToString(sectionId) + "-" + _Symbol;
   req.magic     = MagicEA;

   if(OrderSend(req,res))
   {
      if(isOderLandau == false){
         isOderLandau = true;
      }
      // PrintFormat("Mua successfully: type=%s, lot=%.2f, price=%.5f, sectionId=%d, ticket=%d",
                  // EnumToString(type), lot, req.price, sectionId, res.order);
   }
   else
   {
      // PrintFormat("mua thất bại FAILED: type=%s, lot=%.2f, price=%.5f, sectionId=%d, retcode=%d",
      //             EnumToString(type), lot, req.price, sectionId, res.retcode);
   }


}

void CloseAllOrdersIfSymbolProfitOver(double profitTarget, double lossLimit) // lossLimit là số dương 200
{
   double totalProfit = 0.0;
   int totalPositions = PositionsTotal();
   ulong tickets[];
   int symbolCount = 0;
   
   if(totalPositions == 0) 
      return;
   
   // 1️⃣ Tính tổng profit và thu thập tickets của _Symbol
   for(int i = totalPositions - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0 && PositionSelectByTicket(ticket))
      {
         string symbol = PositionGetString(POSITION_SYMBOL);
         long magic = PositionGetInteger(POSITION_MAGIC);
         
         if(symbol == _Symbol && magic == MagicEA)
         {
            totalProfit += PositionGetDouble(POSITION_PROFIT);
            
            // Thêm ticket vào mảng
            symbolCount++;
            ArrayResize(tickets, symbolCount);
            tickets[symbolCount - 1] = ticket;
         }
      }
   }

   if(symbolCount == 0)
      return;

   // 2️⃣ Kiểm tra điều kiện đóng lệnh
   bool shouldClose = false;
   string closeReason = "";
   
   if(totalProfit >= profitTarget) // Lời đạt target
   {
      shouldClose = true;
      closeReason = StringFormat("Đạt target lợi nhuận %.2f", profitTarget);
   }
   else if(totalProfit <= -lossLimit) // Lỗ vượt quá lossLimit (truyền vào 200, nhưng so sánh với -200)
   {
      shouldClose = true;
      closeReason = StringFormat("Vượt quá giới hạn lỗ %.2f", lossLimit);
   }

   // 3️⃣ Đóng lệnh nếu đạt điều kiện
   if(shouldClose)
   {
    //   PrintFormat("[%s] %s (Lợi nhuận hiện tại: %.2f), đóng %d lệnh", 
    //               _Symbol, closeReason, totalProfit, symbolCount);
      
      // Đóng từng lệnh
      for(int i = 0; i < symbolCount; i++)
      {
         if(PositionSelectByTicket(tickets[i]))
         {
            Trade.PositionClose(tickets[i]);
            // PrintFormat("  - Đã đóng lệnh #%d", tickets[i]);
         }
      }
      
      // Reset dữ liệu Section của symbol này
      ArrayFree(Section_List);
      ArrayFree(Section_Profit_List);
      isOderLandau = false;
      
      // Thêm âm thanh cảnh báo nếu lỗ
      if(totalProfit <= -lossLimit)
      {
         if(isStopSection_WhenSL){
            stopTime = TimeCurrent() + TimeChanBot * 60 * 60; // 16 tiếng
            isStop = true;
        }
        //  Alert(StringFormat("[%s] ĐÃ DỪNG LỖ! Tổng lỗ: %.2f", _Symbol, totalProfit));
        //  PlaySound("alert.wav");
      }
   }
}

