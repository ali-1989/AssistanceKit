
class CalendarType {
  TypeOfCalendar _type = TypeOfCalendar.gregorian;

  CalendarType.gregorian();

  CalendarType.byName(String? name){
    if(name == null){
      _type = TypeOfCalendar.unKnow;
    }

    if(name == 'solar-hijri') {
      _type = TypeOfCalendar.solarHijri;
    }
    else if(name == 'gregorian') {
      _type = TypeOfCalendar.gregorian;
    }

    _type = TypeOfCalendar.unKnow;
  }

  CalendarType.byType(TypeOfCalendar t){
    _type = t;
  }

  String get name {
    if(_type == TypeOfCalendar.gregorian) {
      return 'gregorian';
    }

    if(_type == TypeOfCalendar.solarHijri) {
      return 'solar-hijri';
    }

    return 'unknown';
  }

  TypeOfCalendar get type {
    return _type;
  }

  @override
  bool operator ==(Object other) {
    if(other is! CalendarType) {
      return false;
    }

    return (other.type == type);
  }

  @override
  int get hashCode => super.hashCode;
}
///===========================================================================================================
enum TypeOfCalendar {
  gregorian,
  solarHijri,
  unKnow,
}

extension TypeOfCalendarExtension on TypeOfCalendar {

  String get name {
    switch (this) {
      case TypeOfCalendar.gregorian:
        return 'gregorian';
      case TypeOfCalendar.solarHijri:
        return 'solar-hijri';
      default:
        return 'unknown';
    }
  }

  TypeOfCalendar byName(String? name){
    if(name == null){
      return TypeOfCalendar.gregorian;
    }

    if(name == 'solar-hijri') {
      return TypeOfCalendar.solarHijri;
    }
    else if(name == 'gregorian'){
      return TypeOfCalendar.gregorian;
    }

    return TypeOfCalendar.unKnow;
  }
}
