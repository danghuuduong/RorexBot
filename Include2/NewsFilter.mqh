#include "Common.mqh"

bool isStart = true;

// ===== INPUT =====
input int StopBeforeNewsMin     = 60; // Dừng Mở Section trước Tin (phút)
input int DisableAfterNewsHours = 16; // Tắt EA sau tin (giờ)

datetime timeResumeTrade = 0;

// ===============================
// kiểm tra tin mạnh sắp ra
// ===============================
bool IsHighImpactNewsComing(int minutesAhead, int &secondsToNews)
{
   datetime now = TimeCurrent();
   datetime to  = now + minutesAhead * 60;

   MqlCalendarValue values[];
   int count = CalendarValueHistory(values, now, to);
   if(count <= 0)
      return false;

   for(int i = 0; i < count; i++)
   {
      MqlCalendarEvent event;
      if(!CalendarEventById(values[i].event_id, event))
         continue;

      if(event.importance == CALENDAR_IMPORTANCE_HIGH)
      {
         secondsToNews = (int)(values[i].time - now);
         return true;
      }
   }
   return false;
}

// ===============================
// logic né tin + delay
// ===============================
void HandleNewsFilter()
{
   datetime now = TimeCurrent();

   // ---- đang chạy, kiểm tra tin ----
   int secToNews = 0;
   if(isStart && IsHighImpactNewsComing(StopBeforeNewsMin, secToNews))
   {
      PrintFormat(
         "⚠️ ⚠️----------------- Sắp ra tin mạnh sau %d phút %d giây → DỪNG TRADE",
         secToNews / 60, secToNews % 60
      );

      isStart = false;
      timeResumeTrade = now + DisableAfterNewsHours * 60 * 60;
      return;
   }

   // ---- đang bị khóa ----
   if(!isStart && timeResumeTrade > 0)
   {
      int secLeft = (int)(timeResumeTrade - now);

      if(secLeft > 0)
      {
         PrintFormat(
            "🔒 EA đang khóa – còn %d phút %d giây sẽ mở lại",
            secLeft / 60, secLeft % 60
         );
      }
      else
      {
         isStart = true;
         timeResumeTrade = 0;
         Print("✅ Hết thời gian né tin – EA hoạt động lại");
      }
   }
}
