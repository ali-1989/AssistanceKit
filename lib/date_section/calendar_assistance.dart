
enum CalendarType {
  solarHijri,
  gregorian,
  unKnow,
}
///=============================================================================
extension TypeOfCalendarExtension on CalendarType {
  static CalendarType fromName(String? name){
    for(final t in CalendarType.values){
      if(t.name == name){
        return t;
      }
    }

    return CalendarType.unKnow;
  }
}
///=============================================================================
class CalendarTypeHelper {
  static CalendarType calendarTypeFrom(String? name){
    for(final t in CalendarType.values){
      if(t.name == name){
        return t;
      }
    }

    return CalendarType.unKnow;
  }
}