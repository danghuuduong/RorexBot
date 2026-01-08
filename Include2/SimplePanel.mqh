#property strict
#include "Common2.mqh"

// ==== CẤU HÌNH PANEL ======
input group "====== CÀI ĐẶT PANEL ======";
input int PANEL_WIDTH     = 300;
input int PANEL_HEIGHT    = 400;
input int PANEL_FONT_SIZE = 9;

// ==== MÀU SẮC ======
color PANEL_BG_COLOR   = clrDimGray;
color PANEL_TEXT_COLOR = clrBlack;
color BTN_BG_COLOR     = clrOrange;
color BTN_TEXT_COLOR   = clrBlack;

// ==== TÊN OBJECT ======
#define PANEL_BG     "panel_bg"
#define BTN_CLOSEALL "btn_close_all"
#define BASE_PANEL_LINES 4

//+------------------------------------------------------------------+
// Tạo panel
//+------------------------------------------------------------------+
void CreatePanel()
{
   if(ObjectFind(0,PANEL_BG)==-1)
   {
      ObjectCreate(0,PANEL_BG,OBJ_RECTANGLE_LABEL,0,0,0);
      ObjectSetInteger(0,PANEL_BG,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetInteger(0,PANEL_BG,OBJPROP_XDISTANCE,10);
      ObjectSetInteger(0,PANEL_BG,OBJPROP_YDISTANCE,10);
      ObjectSetInteger(0,PANEL_BG,OBJPROP_XSIZE,PANEL_WIDTH);
      ObjectSetInteger(0,PANEL_BG,OBJPROP_YSIZE,PANEL_HEIGHT);
      ObjectSetInteger(0,PANEL_BG,OBJPROP_COLOR,PANEL_BG_COLOR);
      ObjectSetInteger(0,PANEL_BG,OBJPROP_BACK,false);
   }

   int startY = 20, lineSpacing = 20;
   for(int i=0;i<BASE_PANEL_LINES;i++)
   {
      string name = "panel_line_" + IntegerToString(i);
      if(ObjectFind(0,name)==-1)
      {
         ObjectCreate(0,name,OBJ_LABEL,0,0,0);
         ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
         ObjectSetInteger(0,name,OBJPROP_XDISTANCE,15);
         ObjectSetInteger(0,name,OBJPROP_YDISTANCE,startY+i*lineSpacing);
         ObjectSetInteger(0,name,OBJPROP_COLOR,PANEL_TEXT_COLOR);
         ObjectSetInteger(0,name,OBJPROP_FONTSIZE,PANEL_FONT_SIZE);
      }
   }

   if(ObjectFind(0,BTN_CLOSEALL)==-1)
   {
      ObjectCreate(0,BTN_CLOSEALL,OBJ_BUTTON,0,0,0);
      ObjectSetInteger(0,BTN_CLOSEALL,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetInteger(0,BTN_CLOSEALL,OBJPROP_XDISTANCE,(PANEL_WIDTH-180)/2+10);
      ObjectSetInteger(0,BTN_CLOSEALL,OBJPROP_YDISTANCE,10+PANEL_HEIGHT-40);
      ObjectSetInteger(0,BTN_CLOSEALL,OBJPROP_XSIZE,180);
      ObjectSetInteger(0,BTN_CLOSEALL,OBJPROP_YSIZE,30);
      ObjectSetInteger(0,BTN_CLOSEALL,OBJPROP_BGCOLOR,BTN_BG_COLOR);
      ObjectSetInteger(0,BTN_CLOSEALL,OBJPROP_COLOR,BTN_TEXT_COLOR);
      ObjectSetInteger(0,BTN_CLOSEALL,OBJPROP_FONTSIZE,PANEL_FONT_SIZE);
      ObjectSetString(0,BTN_CLOSEALL,OBJPROP_TEXT,"Đóng tất cả lệnh");
   }
}

//+------------------------------------------------------------------+
// Xóa section cũ
//+------------------------------------------------------------------+
void DeleteOldSectionLines()
{
   for(int i=ObjectsTotal(0)-1;i>=0;i--)
   {
      string name = ObjectName(0,i);
      if(StringFind(name,"panel_line_")==0)
      {
         int idx = (int)StringToInteger(StringSubstr(name,11));
         if(idx>=BASE_PANEL_LINES)
            ObjectDelete(0,name);
      }
   }
}

//+------------------------------------------------------------------+
// Update panel
//+------------------------------------------------------------------+
void UpdatePanel(int totalOrders,bool isStopTime,datetime stopTime)
{
   datetime now = TimeCurrent();

   // ===== 3 dòng cố định =====
   ObjectSetString(0,"panel_line_0",OBJPROP_TEXT,"Tổng lệnh số: " +IntegerToString(totalOrders) + " ,Đồng: " + _Symbol);

      ObjectSetString(
      0,
      "panel_line_1",
      OBJPROP_TEXT,
      isStopTime
      ? "Mở Section: Còn " +
      StringFormat(
         "%02d:%02d:%02d",
         MathMax(0,(int)(stopTime-TimeCurrent()))/3600,
         (MathMax(0,(int)(stopTime-TimeCurrent()))%3600)/60,
         MathMax(0,(int)(stopTime-TimeCurrent()))%60
      )
      : "Mở Section: ✅ Đang hoạt động"
   );

   ObjectSetInteger(
      0,
      "panel_line_1",
      OBJPROP_COLOR,
      isStopTime ? clrRed : clrLime
   );


   double totalProfit = TotalProfitBySymbol(_Symbol);

   ObjectSetString(
      0,
      "panel_line_2",
      OBJPROP_TEXT,
      "Tổng Profit: " + DoubleToString(totalProfit,2) +(Tp_ALL_Section > 0 ? "/" + DoubleToString(Tp_ALL_Section,2) : "")
   );

   ObjectSetInteger(
      0,
      "panel_line_2",
      OBJPROP_COLOR,
        totalProfit > 0 ? clrLime : (totalProfit < 0 ? clrRed : clrBlack)
   );

   ObjectSetString(0,"panel_line_3",OBJPROP_TEXT,"___________________________________________");



   // ===== Section =====
   DeleteOldSectionLines();

   int total = ArraySize(Section_Profit_List);
   int maxShow = 11;
   int start = total>maxShow ? total-maxShow : 0;

   int startY = 20, lineSpacing = 20;
   for(int i=0;i<total-start;i++)
   {
      int idx = start+i;
      string name = "panel_line_" + IntegerToString(BASE_PANEL_LINES+i);

      ObjectCreate(0,name,OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,15);
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,
         startY+(BASE_PANEL_LINES+i)*lineSpacing);
      ObjectSetInteger(0,name,OBJPROP_COLOR,PANEL_TEXT_COLOR);
      ObjectSetInteger(0,name,OBJPROP_FONTSIZE,PANEL_FONT_SIZE);

      ObjectSetString(0,name,OBJPROP_TEXT,
         "Section:"+IntegerToString(Section_Profit_List[idx].id)+
         ", Lãi:"+DoubleToString(Section_Profit_List[idx].profit,2)+
         ", Status:"+(Section_Profit_List[idx].status?"✅":"❌"));
   }
}

//+------------------------------------------------------------------+
// Click
//+------------------------------------------------------------------+
void OnChartEvent(const int id,const long &l,const double &d,const string &s)
{
   if(id==CHARTEVENT_OBJECT_CLICK && s==BTN_CLOSEALL)
      Print("❌ Đã đóng tất cả lệnh");
}
