#property strict
#include "Common2.mqh"

// ==== CẤU HÌNH PANEL ======
input group "====== CÀI ĐẶT PANEL ======";
static input int PANEL_WIDTH     = 300; // Chiều rộng panel
static input int PANEL_HEIGHT    = 400; // Chiều cao panel
static input int PANEL_FONT_SIZE = 9;   // Kích thước chữ

// ==== MÀU SẮC ======
color PANEL_BG_COLOR      = clrDimGray; // Nền panel
color PANEL_TEXT_COLOR    = clrBlack;   // Chữ panel
color BTN_BG_COLOR        = clrOrange;  // Nền nút
color BTN_TEXT_COLOR      = clrBlack;   // Chữ nút

// ==== TÊN OBJECT ======
#define PANEL_BG     "panel_bg"
#define BTN_CLOSEALL "btn_close_all"

// Dòng cơ bản trước khi hiển thị section
#define BASE_PANEL_LINES 3

//+------------------------------------------------------------------+
// Tạo panel
//+------------------------------------------------------------------+
void CreatePanel()
{
   // Background panel
   if(ObjectFind(0,PANEL_BG)==-1)
   {
       ObjectCreate(0, PANEL_BG, OBJ_RECTANGLE_LABEL, 0, 0, 0);
       ObjectSetInteger(0, PANEL_BG, OBJPROP_CORNER, CORNER_LEFT_UPPER);
       ObjectSetInteger(0, PANEL_BG, OBJPROP_XDISTANCE, 10);
       ObjectSetInteger(0, PANEL_BG, OBJPROP_YDISTANCE, 10);
       ObjectSetInteger(0, PANEL_BG, OBJPROP_XSIZE, PANEL_WIDTH);
       ObjectSetInteger(0, PANEL_BG, OBJPROP_YSIZE, PANEL_HEIGHT);
       ObjectSetInteger(0, PANEL_BG, OBJPROP_COLOR, PANEL_BG_COLOR);
       ObjectSetInteger(0, PANEL_BG, OBJPROP_BACK, false);
   }

   // Tạo các dòng cơ bản rỗng
   int startY = 20;
   int lineSpacing = 20;
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
           ObjectSetString(0,name,OBJPROP_TEXT,"");
       }
   }

   // Nút "Đóng tất cả lệnh"
   if(ObjectFind(0,BTN_CLOSEALL)==-1)
   {
       ObjectCreate(0, BTN_CLOSEALL, OBJ_BUTTON, 0, 0, 0);
       ObjectSetInteger(0, BTN_CLOSEALL, OBJPROP_CORNER, CORNER_LEFT_UPPER);
       ObjectSetInteger(0, BTN_CLOSEALL, OBJPROP_XDISTANCE, (PANEL_WIDTH - 180)/2 + 10);
       ObjectSetInteger(0, BTN_CLOSEALL, OBJPROP_YDISTANCE, 10 + PANEL_HEIGHT - 40);
       ObjectSetInteger(0, BTN_CLOSEALL, OBJPROP_XSIZE, 180);
       ObjectSetInteger(0, BTN_CLOSEALL, OBJPROP_YSIZE, 30);
       ObjectSetInteger(0, BTN_CLOSEALL, OBJPROP_COLOR, BTN_TEXT_COLOR);
       ObjectSetInteger(0, BTN_CLOSEALL, OBJPROP_BGCOLOR, BTN_BG_COLOR);
       ObjectSetInteger(0, BTN_CLOSEALL, OBJPROP_FONTSIZE, PANEL_FONT_SIZE);
       ObjectSetString(0, BTN_CLOSEALL, OBJPROP_TEXT, "Đóng tất cả lệnh");
   }
}

//+------------------------------------------------------------------+
// Cập nhật panel động (tự động hiển thị section)
//+------------------------------------------------------------------+
void UpdatePanel(int totalOrders, bool istopTime, datetime stopTime)
{
    datetime now = TimeCurrent();
    int sectionCount = ArraySize(Section_Profit_List);
    int maxDisplay = 11;
    int startIndex = sectionCount > maxDisplay ? sectionCount - maxDisplay : 0;
    int displayCount = sectionCount - startIndex;

    string lines[];
    ArrayResize(lines, BASE_PANEL_LINES + displayCount);

    // Dòng cơ bản
    lines[0] = "Tổng số lệnh: " + IntegerToString(totalOrders);
    lines[1] = istopTime ? "Mở Section: Đang dừng" : "Mở Section: ✅ Đang hoạt động";
    if(istopTime)
    {
        int remaining = (int)(stopTime - now);
        if(remaining < 0) remaining = 0;
        lines[2] = "==> Còn: " + StringFormat("%02d:%02d:%02d", remaining/3600, (remaining%3600)/60, remaining%60) + " Mở lại";
    }
    else lines[2] = " ";

    // Xóa Section cũ
    int i = BASE_PANEL_LINES;
    while(ObjectFind(0,"panel_line_" + IntegerToString(i)) != -1)
        ObjectDelete(0,"panel_line_" + IntegerToString(i));

    // Thêm Section mới (11 phần tử cuối)
    int startY = 20, lineSpacing = 20;
    for(i = 0; i < displayCount; i++)
    {
        int idx = startIndex + i; // Lấy phần tử cuối
        string name = "panel_line_" + IntegerToString(BASE_PANEL_LINES + i);
        ObjectCreate(0,name,OBJ_LABEL,0,0,0);
        ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
        ObjectSetInteger(0,name,OBJPROP_XDISTANCE,15);
        ObjectSetInteger(0,name,OBJPROP_YDISTANCE,startY + (BASE_PANEL_LINES + i) * lineSpacing);
        ObjectSetInteger(0,name,OBJPROP_COLOR,PANEL_TEXT_COLOR);
        ObjectSetInteger(0,name,OBJPROP_FONTSIZE,PANEL_FONT_SIZE);

        lines[BASE_PANEL_LINES + i] = "Section:" + IntegerToString(Section_Profit_List[idx].id)
                                     + ", Lãi: " + DoubleToString(Section_Profit_List[idx].profit,2)
                                     + ", Status: " + (Section_Profit_List[idx].status ? "✅" : "❌");

        ObjectSetString(0,name,OBJPROP_TEXT,lines[BASE_PANEL_LINES + i]);
    }

    // Cập nhật 3 dòng cơ bản
    for(i = 0; i < BASE_PANEL_LINES; i++)
    {
        string name = "panel_line_" + IntegerToString(i);
        if(ObjectFind(0,name) != -1)
        {
            ObjectSetString(0,name,OBJPROP_TEXT,lines[i]);
            if(i == 1) ObjectSetInteger(0,name,OBJPROP_COLOR,istopTime ? clrRed : clrLime);
        }
    }
}


//+------------------------------------------------------------------+
// Xóa panel
//+------------------------------------------------------------------+
void DeletePanel()
{
    ObjectDelete(0,PANEL_BG);
    for(int i=0;;i++)
    {
        string name = "panel_line_" + IntegerToString(i);
        if(ObjectFind(0,name)==-1) break; // hết label -> dừng
        ObjectDelete(0,name);
    }
    ObjectDelete(0,BTN_CLOSEALL);
}

//+------------------------------------------------------------------+
// Sự kiện click chart
//+------------------------------------------------------------------+
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
{
    if(id==CHARTEVENT_OBJECT_CLICK)
    {
        if(sparam==BTN_CLOSEALL)
        {
            Print("❌ Đã đóng tất cả lệnh");
        }
    }
}
