 #property strict

// ==== CẤU HÌNH PANEL ======
input group "====== CÀI ĐẶT PANEL ======";
static input int PANEL_WIDTH     = 300; // Chiều rộng panel
static input int PANEL_HEIGHT    = 400; // Chiều cao panel
static input int PANEL_FONT_SIZE = 12;  // Kích thước chữ

// ==== MÀU SẮC ======
color PANEL_BG_COLOR      = clrDimGray; // Nền panel
color PANEL_TEXT_COLOR    = clrBlack;   // Chữ panel
color BTN_BG_COLOR        = clrOrange;  // Nền nút
color BTN_TEXT_COLOR      = clrBlack;   // Chữ nút

// ==== TÊN OBJECT ======
#define PANEL_BG     "panel_bg"
#define BTN_CLOSEALL "btn_close_all"

// Số dòng hiển thị tối đa trong panel
#define MAX_PANEL_LINES 3

//+------------------------------------------------------------------+
// Tạo panel
//+------------------------------------------------------------------+
void CreatePanel()
{
   // Background panel
   ObjectCreate(0, PANEL_BG, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, PANEL_BG, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, PANEL_BG, OBJPROP_XDISTANCE, 10);
   ObjectSetInteger(0, PANEL_BG, OBJPROP_YDISTANCE, 10);
   ObjectSetInteger(0, PANEL_BG, OBJPROP_XSIZE, PANEL_WIDTH);
   ObjectSetInteger(0, PANEL_BG, OBJPROP_YSIZE, PANEL_HEIGHT);
   ObjectSetInteger(0, PANEL_BG, OBJPROP_COLOR, PANEL_BG_COLOR);
   ObjectSetInteger(0, PANEL_BG, OBJPROP_BACK, false);

   // Tạo các dòng text rỗng
   int startY = 20;
   int lineSpacing = 20;
   for(int i=0; i<MAX_PANEL_LINES; i++)
   {
       string name = "panel_line_" + IntegerToString(i);
       ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
       ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
       ObjectSetInteger(0, name, OBJPROP_XDISTANCE, 15);
       ObjectSetInteger(0, name, OBJPROP_YDISTANCE, startY + i * lineSpacing);
       ObjectSetInteger(0, name, OBJPROP_COLOR, PANEL_TEXT_COLOR);
       ObjectSetInteger(0, name, OBJPROP_FONTSIZE, PANEL_FONT_SIZE);
       ObjectSetString(0, name, OBJPROP_TEXT, ""); // Ban đầu rỗng
   }

   // Nút "Đóng tất cả lệnh"
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

//+------------------------------------------------------------------+
// Cập nhật panel động
//+------------------------------------------------------------------+
void UpdatePanel(int totalOrders, bool istopTime, datetime stopTime)
{
    // Tạo mảng text cho từng dòng
    string lines[MAX_PANEL_LINES];
    datetime now = TimeCurrent();
    lines[0] = "Tổng số lệnh: " + IntegerToString(totalOrders);
    lines[1] = istopTime ? "Mở Section: Đang dừng" : "Mở Section: ✅ Đang hoạt động";
    lines[2] = istopTime ? ("Mở lại sau: " + IntegerToString((stopTime - now)) + " giờ") : " ";
    // Cập nhật text cho từng label
    for(int i=0; i<MAX_PANEL_LINES; i++)
    {
        string name = "panel_line_" + IntegerToString(i);
        if(ObjectFind(0, name) != -1)
        {
            ObjectSetString(0, name, OBJPROP_TEXT, lines[i]);
        }
    }
}

//+------------------------------------------------------------------+
// Xóa panel
//+------------------------------------------------------------------+
void DeletePanel()
{
   ObjectDelete(0, PANEL_BG);
   for(int i=0; i<MAX_PANEL_LINES; i++)
   {
       string name = "panel_line_" + IntegerToString(i);
       ObjectDelete(0, name);
   }
   ObjectDelete(0, BTN_CLOSEALL);
}

//+------------------------------------------------------------------+
// Sự kiện click chart
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   if(id == CHARTEVENT_OBJECT_CLICK)
   {
      if(sparam == BTN_CLOSEALL)
      {
         Print("❌ Đã đóng tất cả lệnh");
      }
   }
}
