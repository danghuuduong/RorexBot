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

void CloseSectionsIfProfitOver()
{
   if(PositionsTotal() == 0 && ArraySize(Section_List) > 0 && isOderLandau == true) {
            ArrayFree(Section_Profit_List);
            ArrayFree(Section_List);
            isOderLandau = false;
   }

   if(ArraySize(Section_List) > 0) {
      for(int i = ArraySize(Section_List) - 1; i >= 0; i--)
      {
         double totalProfit = 0.0;
         int count = 0;

         // 1️⃣ Tính tổng profit các vị thế trong Section
         for(int j = PositionsTotal() - 1; j >= 0; j--)
         {
            ulong ticket = PositionGetTicket(j);
            if(PositionSelectByTicket(ticket))
            {
                int magic = (int)PositionGetInteger(POSITION_MAGIC);
               string comment = PositionGetString(POSITION_COMMENT);
               string symbol  = PositionGetString(POSITION_SYMBOL);

               string commentB = IntegerToString(Section_List[i].id) + "-" + _Symbol;

               if(magic == MagicEA && symbol == _Symbol && comment == commentB)
               {
                     totalProfit += PositionGetDouble(POSITION_PROFIT);
                     count++;
               }
            }
         }
        
      
      if(count > 0)
         {

            double profitCut = (int)(totalProfit * 100) / 100.0;

            // StopLossValue truyền vào là số dương (vd: 200)
            bool reached = (totalProfit >= TpForSection) 
                        || (totalProfit <= -SLForSection);
            
            if(totalProfit <= -SLForSection && isStopSection_WhenSL){
             stopTime = TimeCurrent() + TimeChanBot * 60 * 60; // 16 tiếng
             isStopSection = true;
            }
            AddOrUpdateSectionProfit(Section_List[i].id, profitCut, reached);
            
            if (reached)
            {
                CloseOrdersWithCommentA(Section_List[i].id);
            }
         }
      }


   }


  
  
}

void CloseOrdersWithCommentA(int sectionId)
{
    for(int i = PositionsTotal()-1; i >= 0; i--)
    {
        if(PositionGetSymbol(i) == _Symbol)
        {
            ulong ticket = PositionGetInteger(POSITION_TICKET);
            string comment = PositionGetString(POSITION_COMMENT);
             string commentB = IntegerToString(sectionId) + "-" + _Symbol;

            //  if(comment == IntegerToString(sectionId) || StringFind(comment, IntegerToString(sectionId)) >= 0)
             
            if(comment == commentB)
            {
                // Lấy thông tin lệnh
                string symbol = PositionGetString(POSITION_SYMBOL);
                double volume = PositionGetDouble(POSITION_VOLUME);
                int position_type = (int)PositionGetInteger(POSITION_TYPE);
                double profit = PositionGetDouble(POSITION_PROFIT);
                // Tạo request đóng lệnh
                MqlTradeRequest request;
                MqlTradeResult result;
                
                ZeroMemory(request);
                ZeroMemory(result);
                
                request.action = TRADE_ACTION_DEAL;
                request.position = ticket;
                request.symbol = symbol;
                request.volume = volume;
                request.deviation = 150;
                
                // Đặt giá đóng (ngược với loại lệnh)
                if(position_type == POSITION_TYPE_BUY)
                {
                    request.type = ORDER_TYPE_SELL;
                    request.price = SymbolInfoDouble(symbol, SYMBOL_BID);
                }
                else
                {
                    request.type = ORDER_TYPE_BUY;
                    request.price = SymbolInfoDouble(symbol, SYMBOL_ASK);
                }
                
                request.comment = "Closed by EA";
                
               //  Gửi lệnh đóng
                if(!OrderSend(request, result))
                {
                  //   Print("============================================================================================================ LỖI ", profit, "  SECTION: ", sectionId, GetLastError()," ============================================================================================================ " );
                }
                else
                {
                  //   Print("============================================================================================================Đã đóng lệnh ", profit, " SECTION: ", sectionId," ============================================================================================================ " );
                }
            }
        }
    }
    
    // === THÊM PHẦN NÀY ===
      if( ArraySize(Section_List)> 0) {
         for(int k = ArraySize(Section_List) - 1; k >= 0; k--)
         {
            if(Section_List[k].id == sectionId)
            {
                  Section_List[k].isTrading = false; // Đánh dấu đã đóng và không giao dịch nữa
                  // Print("Đã đóng section ", sectionId, " không giao dịch nữa.");
                  break;
            }
         }
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
            isStopSection = true;
        }
        //  Alert(StringFormat("[%s] ĐÃ DỪNG LỖ! Tổng lỗ: %.2f", _Symbol, totalProfit));
        //  PlaySound("alert.wav");
      }
   }
}





double TotalProfitBySymbol(string symbol)
{
   double total = 0;
   for(int i = PositionsTotal()-1; i >= 0; i--)
   {
      if(PositionGetSymbol(i) == symbol)
      {
         total += PositionGetDouble(POSITION_PROFIT);
      }
   }
   return total;
}