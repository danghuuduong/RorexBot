#include "Common2.mqh"

// ===== INPUT =====
// input group "====== CÀI ĐẶT Tin Tức ======";
// input bool   isStopNews         = true; // Sài chức năng
// input int StopBeforeNewsMin     = 60; // Chặn mở Section khi sắp ra tin(phút)
// input int DisableAfterNewsHours = 16; // Tắt Bot khi tin ra (giờ)

void GetUpcomingNews()
{
   //--- Lấy tin tức trong 7 ngày tới
   datetime now = TimeCurrent();
   datetime week_from_now = now + 7 * 86400;
   
   //--- Lấy tin từ nhiều quốc gia/quốc gia
   string countries[] = {"US", "EU", "GB", "JP", "CN", "CA", "AU", "NZ"};
   
   for(int c = 0; c < ArraySize(countries); c++)
   {
      PrintFormat("\n=== UPCOMING NEWS FOR %s ===", countries[c]);
      
      MqlCalendarValue values[];
      if(CalendarValueHistory(values, now, week_from_now, countries[c]))
      {
         //--- Sắp xếp theo thời gian
         ArraySort(values);
         
         //--- Lọc tin trong tương lai
         int future_count = 0;
         for(int i = 0; i < ArraySize(values); i++)
         {
            if(values[i].time > now) // Chỉ lấy tin chưa xảy ra
            {
               future_count++;
               DisplayNewsInfo(values[i]);
            }
         }
         
         if(future_count == 0)
         {
            Print("No upcoming news for " + countries[c]);
         }
      }
   }
}

// Hàm hiển thị thông tin tin tức
void DisplayNewsInfo(MqlCalendarValue &value)
{
   MqlCalendarEvent event_info;
   if(CalendarEventById(value.event_id, event_info))
   {
      string time_left = GetTimeLeft(value.time);
      string impact = GetImpactLevel(event_info.importance);
      
      PrintFormat("%s | In: %s | %s | %s ",
                  TimeToString(value.time, TIME_DATE|TIME_MINUTES),
                  time_left,
                  event_info.name,
                  impact);
   }
}

// Tính thời gian còn lại đến khi tin ra
string GetTimeLeft(datetime news_time)
{
   datetime now = TimeCurrent();
   int seconds_left = int(news_time - now);
   
   if(seconds_left < 0) return "PAST";
   
   int days = seconds_left / 86400;
   int hours = (seconds_left % 86400) / 3600;
   int minutes = (seconds_left % 3600) / 60;
   
   if(days > 0)
      return StringFormat("%dd %dh", days, hours);
   else if(hours > 0)
      return StringFormat("%dh %dm", hours, minutes);
   else
      return StringFormat("%dm", minutes);
}

// Xác định mức độ ảnh hưởng
string GetImpactLevel(int importance)
{
   switch(importance)
   {
      case 1: return "LOW";
      case 2: return "MEDIUM";
      case 3: return "HIGH";
      default: return "N/A";
   }
}