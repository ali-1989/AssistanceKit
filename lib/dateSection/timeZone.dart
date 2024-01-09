import 'package:assistance_kit/api/system.dart';

class TimeZone {
  TimeZone._();


  // android: IRDT
  static String getCurrentTimezone(){
    final cTz = DateTime.now().timeZoneName;

    if(System.isWindows()){
      final filter = cTz.replaceFirst(' Daylight Time', '');
      var res = windowsTzToLinuxTz(filter);
      res ??= windowsTzToLinuxTz('$filter Standard Time');

      if(res == null) {
        return cTz;
      }

      return res;
    }

    return cTz;
  }

  static String? linuxTzToWindowsTz(String linux){
    for(final m in _windowsTzToLinuxTz){
      final lin = m['linux'];

      if(linux == lin) {
        return m['windows']!;
      }
    }

    return null;
  }

  static String? windowsTzToLinuxTz(String windows){
    for(final m in _windowsTzToLinuxTz){
      var win = m['windows'];

      if(win == windows) {
        return m['linux']!;
      }
    }

    return null;
  }

  static List<int>? getOffsetAsMillis(String timezone){
    final res = getUtcOffsetsForTimezone(timezone);

    if(res == null){
      return null;
    }

    return [res[0].inMilliseconds, res[1].inMilliseconds];
  }

  /// return a List with 2 Duration, 1th is without DayLight, 2th with it.
  static List<Duration>? getUtcOffsetsForTimezone(String timezone) {
    final offsets = _timezoneUTCOffsets[timezone];

    if (offsets == null){
      return null;
    }

    return [Duration(seconds: offsets[0]), Duration(seconds: offsets[1])];
  }

  // getDateTimeZoned('Europe/Rome')
  static DateTime getDateTimeZoned(String timezone, bool isInDayLight){
    final localNow = DateTime.now();
    final offsetMillLocal = localNow.timeZoneOffset.inMilliseconds;
    var utc = DateTime.fromMillisecondsSinceEpoch(localNow.millisecondsSinceEpoch - offsetMillLocal);

    final offsetMillTz = getUtcOffsetsForTimezone(timezone)!;
    utc = utc.add(isInDayLight? offsetMillTz[1] : offsetMillTz[0]);

    return utc;
  }

  /// [offsetMillis] must be in un-dayLight period.
  static List<String> getTimezoneNamesForOffset(int offsetMillis) {
    bool daylight = false;
    offsetMillis = offsetMillis ~/ 1000;
    final res = <String>[];

    try{
      for (final element in _timezoneUTCOffsets.entries) {
        if(daylight){
          if(element.value[1] == offsetMillis) {
            res.add(element.key);
          }
        }
        else{
          if(element.value[0] == offsetMillis) {
            res.add(element.key);
          }
        }
      }
    }
    catch (e){}

    return res;
  }

  // (tehran & kabul) is same
  static String getFirstTimeZoneByOffset(int offsetMillis){
    final list = getTimezoneNamesForOffset(offsetMillis);

    if(list.isEmpty){
      return  '-tz null-';
    }

    return list[0];
  }

  static String getFirstTimeZoneByOffsetInDayLightPeriod(int offsetMillis){
    final list = getTimezoneNamesForOffset(offsetMillis);

    if(list.isEmpty){
      return  '-tz null-';
    }

    return list[1];
  }
  ///===========================================================================
  static const Map<String, List<int>> _timezoneUTCOffsets = {
    'Africa/Abidjan': [0, 0],
    'Africa/Accra': [0, 0],
    'Africa/Addis_Ababa': [10800, 10800],
    'Africa/Algiers': [3600, 3600],
    'Africa/Asmara': [10800, 10800],
    'Africa/Asmera': [10800, 10800],
    'Africa/Bamako': [0, 0],
    'Africa/Bangui': [3600, 3600],
    'Africa/Banjul': [0, 0],
    'Africa/Bissau': [0, 0],
    'Africa/Blantyre': [7200, 7200],
    'Africa/Brazzaville': [3600, 3600],
    'Africa/Bujumbura': [7200, 7200],
    'Africa/Cairo': [7200, 7200],
    'Africa/Casablanca': [0, 3600],
    'Africa/Ceuta': [3600, 7200],
    'Africa/Conakry': [0, 0],
    'Africa/Dakar': [0, 0],
    'Africa/Dar_es_Salaam': [10800, 10800],
    'Africa/Djibouti': [10800, 10800],
    'Africa/Douala': [3600, 3600],
    'Africa/El_Aaiun': [0, 3600],
    'Africa/Freetown': [0, 0],
    'Africa/Gaborone': [7200, 7200],
    'Africa/Harare': [7200, 7200],
    'Africa/Johannesburg': [7200, 7200],
    'Africa/Juba': [10800, 10800],
    'Africa/Kampala': [10800, 10800],
    'Africa/Khartoum': [10800, 10800],
    'Africa/Kigali': [7200, 7200],
    'Africa/Kinshasa': [3600, 3600],
    'Africa/Lagos': [3600, 3600],
    'Africa/Libreville': [3600, 3600],
    'Africa/Lome': [0, 0],
    'Africa/Luanda': [3600, 3600],
    'Africa/Lubumbashi': [7200, 7200],
    'Africa/Lusaka': [7200, 7200],
    'Africa/Malabo': [3600, 3600],
    'Africa/Maputo': [7200, 7200],
    'Africa/Maseru': [7200, 7200],
    'Africa/Mbabane': [7200, 7200],
    'Africa/Mogadishu': [10800, 10800],
    'Africa/Monrovia': [0, 0],
    'Africa/Nairobi': [10800, 10800],
    'Africa/Ndjamena': [3600, 3600],
    'Africa/Niamey': [3600, 3600],
    'Africa/Nouakchott': [0, 0],
    'Africa/Ouagadougou': [0, 0],
    'Africa/Porto-Novo': [3600, 3600],
    'Africa/Sao_Tome': [0, 0],
    'Africa/Timbuktu': [0, 0],
    'Africa/Tripoli': [7200, 7200],
    'Africa/Tunis': [3600, 3600],
    'Africa/Windhoek': [3600, 7200],
    'America/Adak': [-36000, -32400],
    'America/Anchorage': [-32400, -28800],
    'America/Anguilla': [-14400, -14400],
    'America/Antigua': [-14400, -14400],
    'America/Araguaina': [-10800, -10800],
    'America/Argentina/Buenos_Aires': [-10800, -10800],
    'America/Argentina/Catamarca': [-10800, -10800],
    'America/Argentina/ComodRivadavia': [-10800, -10800],
    'America/Argentina/Cordoba': [-10800, -10800],
    'America/Argentina/Jujuy': [-10800, -10800],
    'America/Argentina/La_Rioja': [-10800, -10800],
    'America/Argentina/Mendoza': [-10800, -10800],
    'America/Argentina/Rio_Gallegos': [-10800, -10800],
    'America/Argentina/Salta': [-10800, -10800],
    'America/Argentina/San_Juan': [-10800, -10800],
    'America/Argentina/San_Luis': [-10800, -10800],
    'America/Argentina/Tucuman': [-10800, -10800],
    'America/Argentina/Ushuaia': [-10800, -10800],
    'America/Aruba': [-14400, -14400],
    'America/Asuncion': [-10800, -10800],
    'America/Atikokan': [-18000, -18000],
    'America/Atka': [-36000, -32400],
    'America/Bahia': [-10800, -10800],
    'America/Bahia_Banderas': [-21600, -18000],
    'America/Barbados': [-14400, -14400],
    'America/Belem': [-10800, -10800],
    'America/Belize': [-21600, -21600],
    'America/Blanc-Sablon': [-14400, -14400],
    'America/Boa_Vista': [-14400, -14400],
    'America/Bogota': [-18000, -18000],
    'America/Boise': [-25200, -21600],
    'America/Buenos_Aires': [-10800, -10800],
    'America/Cambridge_Bay': [-25200, -21600],
    'America/Campo_Grande': [-14400, -10800],
    'America/Cancun': [-18000, -18000],
    'America/Caracas': [-16200, -16200],
    'America/Catamarca': [-10800, -10800],
    'America/Cayenne': [-10800, -10800],
    'America/Cayman': [-18000, -18000],
    'America/Chicago': [-21600, -18000],
    'America/Chihuahua': [-25200, -21600],
    'America/Coral_Harbour': [-18000, -18000],
    'America/Cordoba': [-10800, -10800],
    'America/Costa_Rica': [-21600, -21600],
    'America/Creston': [-25200, -25200],
    'America/Cuiaba': [-14400, -10800],
    'America/Curacao': [-14400, -14400],
    'America/Danmarkshavn': [0, 0],
    'America/Dawson': [-28800, -25200],
    'America/Dawson_Creek': [-25200, -25200],
    'America/Denver': [-25200, -21600],
    'America/Detroit': [-18000, -14400],
    'America/Dominica': [-14400, -14400],
    'America/Edmonton': [-25200, -21600],
    'America/Eirunepe': [-18000, -18000],
    'America/El_Salvador': [-21600, -21600],
    'America/Ensenada': [-28800, -25200],
    'America/Fort_Nelson': [-25200, -25200],
    'America/Fort_Wayne': [-18000, -14400],
    'America/Fortaleza': [-10800, -10800],
    'America/Glace_Bay': [-14400, -10800],
    'America/Godthab': [-10800, -7200],
    'America/Goose_Bay': [-14400, -10800],
    'America/Grand_Turk': [-14400, -14400],
    'America/Grenada': [-14400, -14400],
    'America/Guadeloupe': [-14400, -14400],
    'America/Guatemala': [-21600, -21600],
    'America/Guayaquil': [-18000, -18000],
    'America/Guyana': [-14400, -14400],
    'America/Halifax': [-14400, -10800],
    'America/Havana': [-18000, -14400],
    'America/Hermosillo': [-25200, -25200],
    'America/Indiana/Indianapolis': [-18000, -14400],
    'America/Indiana/Knox': [-21600, -18000],
    'America/Indiana/Marengo': [-18000, -14400],
    'America/Indiana/Petersburg': [-18000, -14400],
    'America/Indiana/Tell_City': [-21600, -18000],
    'America/Indiana/Vevay': [-18000, -14400],
    'America/Indiana/Vincennes': [-18000, -14400],
    'America/Indiana/Winamac': [-18000, -14400],
    'America/Indianapolis': [-18000, -14400],
    'America/Inuvik': [-25200, -21600],
    'America/Iqaluit': [-18000, -14400],
    'America/Jamaica': [-18000, -18000],
    'America/Jujuy': [-10800, -10800],
    'America/Juneau': [-32400, -28800],
    'America/Kentucky/Louisville': [-18000, -14400],
    'America/Kentucky/Monticello': [-18000, -14400],
    'America/Knox_IN': [-21600, -18000],
    'America/Kralendijk': [-14400, -14400],
    'America/La_Paz': [-14400, -14400],
    'America/Lima': [-18000, -18000],
    'America/Los_Angeles': [-28800, -25200],
    'America/Louisville': [-18000, -14400],
    'America/Lower_Princes': [-14400, -14400],
    'America/Maceio': [-10800, -10800],
    'America/Managua': [-21600, -21600],
    'America/Manaus': [-14400, -14400],
    'America/Marigot': [-14400, -14400],
    'America/Martinique': [-14400, -14400],
    'America/Matamoros': [-21600, -18000],
    'America/Mazatlan': [-25200, -21600],
    'America/Mendoza': [-10800, -10800],
    'America/Menominee': [-21600, -18000],
    'America/Merida': [-21600, -18000],
    'America/Metlakatla': [-28800, -28800],
    'America/Mexico_City': [-21600, -18000],
    'America/Miquelon': [-10800, -7200],
    'America/Moncton': [-14400, -10800],
    'America/Monterrey': [-21600, -18000],
    'America/Montevideo': [-10800, -7200],
    'America/Montreal': [-18000, -14400],
    'America/Montserrat': [-14400, -14400],
    'America/Nassau': [-18000, -14400],
    'America/New_York': [-18000, -14400],
    'America/Nipigon': [-18000, -14400],
    'America/Nome': [-32400, -28800],
    'America/Noronha': [-7200, -7200],
    'America/North_Dakota/Beulah': [-21600, -18000],
    'America/North_Dakota/Center': [-21600, -18000],
    'America/North_Dakota/New_Salem': [-21600, -18000],
    'America/Ojinaga': [-25200, -21600],
    'America/Panama': [-18000, -18000],
    'America/Pangnirtung': [-18000, -14400],
    'America/Paramaribo': [-10800, -10800],
    'America/Phoenix': [-25200, -25200],
    'America/Port-au-Prince': [-18000, -14400],
    'America/Port_of_Spain': [-14400, -14400],
    'America/Porto_Acre': [-18000, -18000],
    'America/Porto_Velho': [-14400, -14400],
    'America/Puerto_Rico': [-14400, -14400],
    'America/Punta_Arenas': [-10800, -10800],
    'America/Rainy_River': [-21600, -18000],
    'America/Rankin_Inlet': [-21600, -18000],
    'America/Recife': [-10800, -10800],
    'America/Regina': [-21600, -21600],
    'America/Resolute': [-21600, -18000],
    'America/Rio_Branco': [-18000, -18000],
    'America/Rosario': [-10800, -10800],
    'America/Santa_Isabel': [-28800, -25200],
    'America/Santarem': [-10800, -10800],
    'America/Santiago': [-10800, -10800],
    'America/Santo_Domingo': [-14400, -14400],
    'America/Sao_Paulo': [-10800, -7200],
    'America/Scoresbysund': [-3600, 0],
    'America/Shiprock': [-25200, -21600],
    'America/Sitka': [-32400, -28800],
    'America/St_Barthelemy': [-14400, -14400],
    'America/St_Johns': [-12600, -9000],
    'America/St_Kitts': [-14400, -14400],
    'America/St_Lucia': [-14400, -14400],
    'America/St_Thomas': [-14400, -14400],
    'America/St_Vincent': [-14400, -14400],
    'America/Swift_Current': [-21600, -21600],
    'America/Tegucigalpa': [-21600, -21600],
    'America/Thule': [-14400, -10800],
    'America/Thunder_Bay': [-18000, -14400],
    'America/Tijuana': [-28800, -25200],
    'America/Toronto': [-18000, -14400],
    'America/Tortola': [-14400, -14400],
    'America/Vancouver': [-28800, -25200],
    'America/Virgin': [-14400, -14400],
    'America/Whitehorse': [-28800, -25200],
    'America/Winnipeg': [-21600, -18000],
    'America/Yakutat': [-32400, -28800],
    'America/Yellowknife': [-25200, -21600],
    'Antarctica/Casey': [28800, 28800],
    'Antarctica/Davis': [25200, 25200],
    'Antarctica/DumontDUrville': [36000, 36000],
    'Antarctica/Macquarie': [39600, 39600],
    'Antarctica/Mawson': [18000, 18000],
    'Antarctica/McMurdo': [43200, 46800],
    'Antarctica/Palmer': [-10800, -10800],
    'Antarctica/Rothera': [-10800, -10800],
    'Antarctica/South_Pole': [43200, 46800],
    'Antarctica/Syowa': [10800, 10800],
    'Antarctica/Troll': [0, 7200],
    'Antarctica/Vostok': [21600, 21600],
    'Arctic/Longyearbyen': [3600, 7200],
    'Asia/Aden': [10800, 10800],
    'Asia/Almaty': [21600, 21600],
    'Asia/Amman': [7200, 10800],
    'Asia/Anadyr': [43200, 43200],
    'Asia/Aqtau': [18000, 18000],
    'Asia/Aqtobe': [18000, 18000],
    'Asia/Ashgabat': [18000, 18000],
    'Asia/Ashkhabad': [18000, 18000],
    'Asia/Atyrau': [18000, 18000],
    'Asia/Baghdad': [10800, 10800],
    'Asia/Bahrain': [10800, 10800],
    'Asia/Baku': [14400, 18000],
    'Asia/Bangkok': [25200, 25200],
    'Asia/Barnaul': [25200, 25200],
    'Asia/Beirut': [7200, 10800],
    'Asia/Bishkek': [21600, 21600],
    'Asia/Brunei': [28800, 28800],
    'Asia/Calcutta': [19800, 19800],
    'Asia/Chita': [28800, 28800],
    'Asia/Choibalsan': [28800, 32400],
    'Asia/Chongqing': [28800, 28800],
    'Asia/Chungking': [28800, 28800],
    'Asia/Colombo': [19800, 19800],
    'Asia/Dacca': [21600, 21600],
    'Asia/Damascus': [7200, 10800],
    'Asia/Dhaka': [21600, 21600],
    'Asia/Dili': [32400, 32400],
    'Asia/Dubai': [14400, 14400],
    'Asia/Dushanbe': [18000, 18000],
    'Asia/Famagusta': [7200, 10800],
    'Asia/Gaza': [7200, 10800],
    'Asia/Harbin': [28800, 28800],
    'Asia/Hebron': [7200, 10800],
    'Asia/Ho_Chi_Minh': [25200, 25200],
    'Asia/Hong_Kong': [28800, 28800],
    'Asia/Hovd': [25200, 28800],
    'Asia/Irkutsk': [28800, 28800],
    'Asia/Istanbul': [7200, 10800],
    'Asia/Jakarta': [25200, 25200],
    'Asia/Jayapura': [32400, 32400],
    'Asia/Jerusalem': [7200, 10800],
    'Asia/Kabul': [16200, 16200],
    'Asia/Kamchatka': [43200, 43200],
    'Asia/Karachi': [18000, 18000],
    'Asia/Kashgar': [21600, 21600],
    'Asia/Kathmandu': [20700, 20700],
    'Asia/Katmandu': [20700, 20700],
    'Asia/Khandyga': [32400, 32400],
    'Asia/Kolkata': [19800, 19800],
    'Asia/Krasnoyarsk': [25200, 25200],
    'Asia/Kuala_Lumpur': [28800, 28800],
    'Asia/Kuching': [28800, 28800],
    'Asia/Kuwait': [10800, 10800],
    'Asia/Macao': [28800, 28800],
    'Asia/Macau': [28800, 28800],
    'Asia/Magadan': [36000, 36000],
    'Asia/Makassar': [28800, 28800],
    'Asia/Manila': [28800, 28800],
    'Asia/Muscat': [14400, 14400],
    'Asia/Nicosia': [7200, 10800],
    'Asia/Novokuznetsk': [25200, 25200],
    'Asia/Novosibirsk': [21600, 21600],
    'Asia/Omsk': [21600, 21600],
    'Asia/Oral': [18000, 18000],
    'Asia/Phnom_Penh': [25200, 25200],
    'Asia/Pontianak': [25200, 25200],
    'Asia/Pyongyang': [30600, 30600],
    'Asia/Qatar': [10800, 10800],
    'Asia/Qostanay': [21600, 21600],
    'Asia/Qyzylorda': [21600, 21600],
    'Asia/Rangoon': [23400, 23400],
    'Asia/Riyadh': [10800, 10800],
    'Asia/Riyadh87': [10800, 10800],
    'Asia/Riyadh88': [10800, 10800],
    'Asia/Riyadh89': [10800, 10800],
    'Asia/Saigon': [25200, 25200],
    'Asia/Sakhalin': [36000, 36000],
    'Asia/Samarkand': [18000, 18000],
    'Asia/Seoul': [32400, 32400],
    'Asia/Shanghai': [28800, 28800],
    'Asia/Singapore': [28800, 28800],
    'Asia/Srednekolymsk': [39600, 39600],
    'Asia/Taipei': [28800, 28800],
    'Asia/Tashkent': [18000, 18000],
    'Asia/Tbilisi': [14400, 14400],
    'Asia/Tehran': [12600, 12600], // 12600: 3.5*60*60   16200: 4.5
    'Asia/Tel_Aviv': [7200, 10800],
    'Asia/Thimbu': [21600, 21600],
    'Asia/Thimphu': [21600, 21600],
    'Asia/Tokyo': [32400, 32400],
    'Asia/Tomsk': [25200, 25200],
    'Asia/Ujung_Pandang': [28800, 28800],
    'Asia/Ulaanbaatar': [28800, 32400],
    'Asia/Ulan_Bator': [28800, 32400],
    'Asia/Urumqi': [21600, 21600],
    'Asia/Ust-Nera': [36000, 36000],
    'Asia/Vientiane': [25200, 25200],
    'Asia/Vladivostok': [36000, 36000],
    'Asia/Yakutsk': [32400, 32400],
    'Asia/Yekaterinburg': [18000, 18000],
    'Asia/Yangon': [23400, 23400],
    'Asia/Yerevan': [14400, 14400],
    'Atlantic/Azores': [-3600, 0],
    'Atlantic/Bermuda': [-14400, -10800],
    'Atlantic/Canary': [0, 3600],
    'Atlantic/Cape_Verde': [-3600, -3600],
    'Atlantic/Faeroe': [0, 3600],
    'Atlantic/Faroe': [0, 3600],
    'Atlantic/Jan_Mayen': [3600, 7200],
    'Atlantic/Madeira': [0, 3600],
    'Atlantic/Reykjavik': [0, 0],
    'Atlantic/South_Georgia': [-7200, -7200],
    'Atlantic/St_Helena': [0, 0],
    'Atlantic/Stanley': [-10800, -10800],
    'Australia/ACT': [36000, 39600],
    'Australia/Adelaide': [34200, 37800],
    'Australia/Brisbane': [36000, 36000],
    'Australia/Broken_Hill': [34200, 37800],
    'Australia/Canberra': [36000, 39600],
    'Australia/Currie': [36000, 39600],
    'Australia/Darwin': [34200, 34200],
    'Australia/Eucla': [31500, 31500],
    'Australia/Hobart': [36000, 39600],
    'Australia/LHI': [37800, 39600],
    'Australia/Lindeman': [36000, 36000],
    'Australia/Lord_Howe': [37800, 39600],
    'Australia/Melbourne': [36000, 39600],
    'Australia/NSW': [36000, 39600],
    'Australia/North': [34200, 34200],
    'Australia/Perth': [28800, 28800],
    'Australia/Queensland': [36000, 36000],
    'Australia/South': [34200, 37800],
    'Australia/Sydney': [36000, 39600],
    'Australia/Tasmania': [36000, 39600],
    'Australia/Victoria': [36000, 39600],
    'Australia/West': [28800, 28800],
    'Australia/Yancowinna': [34200, 37800],
    'Brazil/Acre': [-18000, -18000],
    'Brazil/DeNoronha': [-7200, -7200],
    'Brazil/East': [-10800, -7200],
    'Brazil/West': [-14400, -14400],
    'CET': [3600, 7200],
    'CST6CDT': [-21600, -18000],
    'Canada/Atlantic': [-14400, -10800],
    'Canada/Central': [-21600, -18000],
    'Canada/East-Saskatchewan': [-21600, -21600],
    'Canada/Eastern': [-18000, -14400],
    'Canada/Mountain': [-25200, -21600],
    'Canada/Newfoundland': [-12600, -9000],
    'Canada/Pacific': [-28800, -25200],
    'Canada/Saskatchewan': [-21600, -21600],
    'Canada/Yukon': [-28800, -25200],
    'Chile/Continental': [-10800, -10800],
    'Chile/EasterIsland': [-18000, -18000],
    'Cuba': [-18000, -14400],
    'EET': [7200, 10800],
    'EST': [-18000, -18000],
    'EST5EDT': [-18000, -14400],
    'Egypt': [7200, 7200],
    'Eire': [0, 3600],
    'Etc/GMT': [0, 0],
    'Etc/GMT+0': [0, 0],
    'Etc/GMT+1': [-3600, -3600],
    'Etc/GMT+10': [-36000, -36000],
    'Etc/GMT+11': [-39600, -39600],
    'Etc/GMT+12': [-43200, -43200],
    'Etc/GMT+2': [-7200, -7200],
    'Etc/GMT+3': [-10800, -10800],
    'Etc/GMT+4': [-14400, -14400],
    'Etc/GMT+5': [-18000, -18000],
    'Etc/GMT+6': [-21600, -21600],
    'Etc/GMT+7': [-25200, -25200],
    'Etc/GMT+8': [-28800, -28800],
    'Etc/GMT+9': [-32400, -32400],
    'Etc/GMT-0': [0, 0],
    'Etc/GMT-1': [3600, 3600],
    'Etc/GMT-10': [36000, 36000],
    'Etc/GMT-11': [39600, 39600],
    'Etc/GMT-12': [43200, 43200],
    'Etc/GMT-13': [46800, 46800],
    'Etc/GMT-14': [50400, 50400],
    'Etc/GMT-2': [7200, 7200],
    'Etc/GMT-3': [10800, 10800],
    'Etc/GMT-4': [14400, 14400],
    'Etc/GMT-5': [18000, 18000],
    'Etc/GMT-6': [21600, 21600],
    'Etc/GMT-7': [25200, 25200],
    'Etc/GMT-8': [28800, 28800],
    'Etc/GMT-9': [32400, 32400],
    'Etc/GMT0': [0, 0],
    'Etc/Greenwich': [0, 0],
    'Etc/UCT': [0, 0],
    'Etc/UTC': [0, 0],
    'Etc/Universal': [0, 0],
    'Etc/Zulu': [0, 0],
    'Europe/Amsterdam': [3600, 7200],
    'Europe/Andorra': [3600, 7200],
    'Europe/Astrakhan': [14400, 14400],
    'Europe/Athens': [7200, 10800],
    'Europe/Belfast': [0, 3600],
    'Europe/Belgrade': [3600, 7200],
    'Europe/Berlin': [3600, 7200],
    'Europe/Bratislava': [3600, 7200],
    'Europe/Brussels': [3600, 7200],
    'Europe/Bucharest': [7200, 10800],
    'Europe/Budapest': [3600, 7200],
    'Europe/Busingen': [3600, 7200],
    'Europe/Chisinau': [7200, 10800],
    'Europe/Copenhagen': [3600, 7200],
    'Europe/Dublin': [0, 3600],
    'Europe/Gibraltar': [3600, 7200],
    'Europe/Guernsey': [0, 3600],
    'Europe/Helsinki': [7200, 10800],
    'Europe/Isle_of_Man': [0, 3600],
    'Europe/Istanbul': [7200, 10800],
    'Europe/Jersey': [0, 3600],
    'Europe/Kaliningrad': [7200, 10800],
    'Europe/Kiev': [7200, 10800],
    'Europe/Kirov': [10800, 10800],
    'Europe/Lisbon': [0, 3600],
    'Europe/Ljubljana': [3600, 7200],
    'Europe/London': [0, 3600],
    'Europe/Luxembourg': [3600, 7200],
    'Europe/Madrid': [3600, 7200],
    'Europe/Malta': [3600, 7200],
    'Europe/Mariehamn': [7200, 10800],
    'Europe/Minsk': [10800, 10800],
    'Europe/Monaco': [3600, 7200],
    'Europe/Moscow': [10800, 10800],
    'Europe/Nicosia': [7200, 10800],
    'Europe/Oslo': [3600, 7200],
    'Europe/Paris': [3600, 7200],
    'Europe/Podgorica': [3600, 7200],
    'Europe/Prague': [3600, 7200],
    'Europe/Riga': [7200, 10800],
    'Europe/Rome': [3600, 7200],
    'Europe/Samara': [14400, 14400],
    'Europe/San_Marino': [3600, 7200],
    'Europe/Sarajevo': [3600, 7200],
    'Europe/Saratov': [14400, 14400],
    'Europe/Simferopol': [7200, 10800],
    'Europe/Skopje': [3600, 7200],
    'Europe/Sofia': [7200, 10800],
    'Europe/Stockholm': [3600, 7200],
    'Europe/Tallinn': [7200, 10800],
    'Europe/Tirane': [3600, 7200],
    'Europe/Tiraspol': [7200, 10800],
    'Europe/Ulyanovsk': [14400, 14400],
    'Europe/Uzhgorod': [7200, 10800],
    'Europe/Vaduz': [3600, 7200],
    'Europe/Vatican': [3600, 7200],
    'Europe/Vienna': [3600, 7200],
    'Europe/Vilnius': [7200, 10800],
    'Europe/Volgograd': [10800, 10800],
    'Europe/Warsaw': [3600, 7200],
    'Europe/Zagreb': [3600, 7200],
    'Europe/Zaporozhye': [7200, 10800],
    'Europe/Zurich': [3600, 7200],
    'Factory': [0, 0],
    'GB': [0, 3600],
    'GB-Eire': [0, 3600],
    'GMT': [0, 0],
    'GMT+0': [0, 0],
    'GMT-0': [0, 0],
    'GMT0': [0, 0],
    'Greenwich': [0, 0],
    'HST': [-36000, -36000],
    'Hongkong': [28800, 28800],
    'Iceland': [0, 0],
    'Indian/Antananarivo': [10800, 10800],
    'Indian/Chagos': [21600, 21600],
    'Indian/Christmas': [25200, 25200],
    'Indian/Cocos': [23400, 23400],
    'Indian/Comoro': [10800, 10800],
    'Indian/Kerguelen': [18000, 18000],
    'Indian/Mahe': [14400, 14400],
    'Indian/Maldives': [18000, 18000],
    'Indian/Mauritius': [14400, 14400],
    'Indian/Mayotte': [10800, 10800],
    'Indian/Reunion': [14400, 14400],
    'Iran': [12600, 16200],
    'Israel': [7200, 10800],
    'Jamaica': [-18000, -18000],
    'Japan': [32400, 32400],
    'Kwajalein': [43200, 43200],
    'Libya': [7200, 7200],
    'MET': [3600, 7200],
    'MST': [-25200, -25200],
    'MST7MDT': [-25200, -21600],
    'Mexico/BajaNorte': [-28800, -25200],
    'Mexico/BajaSur': [-25200, -21600],
    'Mexico/General': [-21600, -18000],
    'Mideast/Riyadh87': [0, 0],
    'Mideast/Riyadh88': [0, 0],
    'Mideast/Riyadh89': [0, 0],
    'NZ': [43200, 46800],
    'NZ-CHAT': [45900, 49500],
    'Navajo': [0, 0],
    'PRC': [0, 0],
    'PST8PDT': [0, 0],
    'Pacific/Apia': [46800, 50400],
    'Pacific/Auckland': [43200, 46800],
    'Pacific/Bougainville': [39600, 39600],
    'Pacific/Chatham': [45900, 49500],
    'Pacific/Chuuk': [36000, 36000],
    'Pacific/Easter': [-18000, -18000],
    'Pacific/Efate': [39600, 39600],
    'Pacific/Enderbury': [46800, 46800],
    'Pacific/Fakaofo': [46800, 46800],
    'Pacific/Fiji': [43200, 46800],
    'Pacific/Funafuti': [43200, 43200],
    'Pacific/Galapagos': [-21600, -21600],
    'Pacific/Gambier': [-32400, -32400],
    'Pacific/Guadalcanal': [39600, 39600],
    'Pacific/Guam': [36000, 36000],
    'Pacific/Honolulu': [-36000, -36000],
    'Pacific/Johnston': [-36000, -36000],
    'Pacific/Kiritimati': [50400, 50400],
    'Pacific/Kosrae': [39600, 39600],
    'Pacific/Kwajalein': [43200, 43200],
    'Pacific/Majuro': [43200, 43200],
    'Pacific/Marquesas': [-34200, -34200],
    'Pacific/Midway': [-39600, -39600],
    'Pacific/Nauru': [43200, 43200],
    'Pacific/Niue': [-39600, -39600],
    'Pacific/Norfolk': [39600, 39600],
    'Pacific/Noumea': [39600, 39600],
    'Pacific/Pago_Pago': [-39600, -39600],
    'Pacific/Palau': [32400, 32400],
    'Pacific/Pitcairn': [-28800, -28800],
    'Pacific/Pohnpei': [39600, 39600],
    'Pacific/Ponape': [39600, 39600],
    'Pacific/Port_Moresby': [36000, 36000],
    'Pacific/Rarotonga': [-36000, -36000],
    'Pacific/Saipan': [36000, 36000],
    'Pacific/Samoa': [-39600, -39600],
    'Pacific/Tahiti': [-36000, -36000],
    'Pacific/Tarawa': [43200, 43200],
    'Pacific/Tongatapu': [46800, 46800],
    'Pacific/Truk': [36000, 36000],
    'Pacific/Wake': [43200, 43200],
    'Pacific/Wallis': [43200, 43200],
    'Pacific/Yap': [36000, 36000],
    'Poland': [3600, 7200],
    'Portugal': [0, 3600],
    'ROC': [28800, 28800],
    'ROK': [32400, 32400],
    'Singapore': [28800, 28800],
    'Turkey': [7200, 10800],
    'UCT': [0, 0],
    'US/Alaska': [-32400, -28800],
    'US/Aleutian': [-36000, -32400],
    'US/Arizona': [-25200, -25200],
    'US/Central': [-21600, -18000],
    'US/East-Indiana': [-18000, -14400],
    'US/Eastern': [-18000, -14400],
    'US/Hawaii': [-36000, -36000],
    'US/Indiana-Starke': [-21600, -18000],
    'US/Michigan': [-18000, -14400],
    'US/Mountain': [-25200, -21600],
    'US/Pacific': [-28800, -25200],
    'US/Pacific-New': [-28800, -25200],
    'US/Samoa': [-39600, -39600],
    'utc': [0, 0],
    'UTC': [0, 0],
    'Universal': [0, 0],
    'W-SU': [10800, 10800],
    'WET': [0, 3600],
    'Zulu': [0, 0],
  };

  static const _windowsTzToLinuxTz = <Map<String, String>>[
    {
      'windows': 'AUS Central Standard Time',
      'linux': 'Australia/Darwin'
    },
    {
      'windows': 'AUS Eastern Standard Time',
      'linux': 'Australia/Sydney'
    },
    {
      'windows': 'AUS Eastern Standard Time',
      'linux': 'Australia/Melbourne'
    },
    {
      'windows': 'Afghanistan Standard Time',
      'linux': 'Asia/Kabul'
    },
    {
      'windows': 'Alaskan Standard Time',
      'linux': 'America/Anchorage'
    },
    {
      'windows': 'Aleutian Standard Time',
      'linux': 'America/Adak'
    },
    {
      'windows': 'Altai Standard Time',
      'linux': 'Asia/Barnaul'
    },
    {
      'windows': 'Arab Standard Time',
      'linux': 'Asia/Riyadh'
    },
    {
      'windows': 'Arab Standard Time',
      'linux': 'Asia/Qatar'
    },
    {
      'windows': 'Arabian Standard Time',
      'linux': 'Asia/Dubai'
    },
    {
      'windows': 'Arabian Standard Time',
      'linux': 'Etc/GMT-4'
    },
    {
      'windows': 'Arabic Standard Time',
      'linux': 'Asia/Baghdad'
    },
    {
      'windows': 'Argentina Standard Time',
      'linux': 'America/Argentina/Buenos_Aires'
    },
    {
      'windows': 'Astrakhan Standard Time',
      'linux': 'Europe/Astrakhan'
    },
    {
      'windows': 'Atlantic Standard Time',
      'linux': 'America/Halifax'
    },
    {
      'windows': 'Atlantic Standard Time',
      'linux': 'Atlantic/Bermuda'
    },
    {
      'windows': 'Atlantic Standard Time',
      'linux': 'America/Thule'
    },
    {
      'windows': 'Aus Central W. Standard Time',
      'linux': 'Australia/Eucla'
    },
    {
      'windows': 'Azerbaijan Standard Time',
      'linux': 'Asia/Baku'
    },
    {
      'windows': 'Azores Standard Time',
      'linux': 'Atlantic/Azores'
    },
    {
      'windows': 'Azores Standard Time',
      'linux': 'America/Scoresbysund'
    },
    {
      'windows': 'Bahia Standard Time',
      'linux': 'America/Bahia'
    },
    {
      'windows': 'Bangladesh Standard Time',
      'linux': 'Asia/Dhaka'
    },
    {
      'windows': 'Bangladesh Standard Time',
      'linux': 'Asia/Thimphu'
    },
    {
      'windows': 'Belarus Standard Time',
      'linux': 'Europe/Minsk'
    },
    {
      'windows': 'Bougainville Standard Time',
      'linux': 'Pacific/Bougainville'
    },
    {
      'windows': 'Canada Central Standard Time',
      'linux': 'America/Regina'
    },
    {
      'windows': 'Canada Central Standard Time',
      'linux': 'America/Swift_Current'
    },
    {
      'windows': 'Cape Verde Standard Time',
      'linux': 'Atlantic/Cape_Verde'
    },
    {
      'windows': 'Cape Verde Standard Time',
      'linux': 'Etc/GMT+1'
    },
    {
      'windows': 'Caucasus Standard Time',
      'linux': 'Asia/Yerevan'
    },
    {
      'windows': 'Cen. Australia Standard Time',
      'linux': 'Australia/Adelaide'
    },
    {
      'windows': 'Cen. Australia Standard Time',
      'linux': 'Australia/Broken_Hill'
    },
    {
      'windows': 'Central America Standard Time',
      'linux': 'America/Guatemala'
    },
    {
      'windows': 'Central America Standard Time',
      'linux': 'America/Belize'
    },
    {
      'windows': 'Central America Standard Time',
      'linux': 'America/Costa_Rica'
    },
    {
      'windows': 'Central America Standard Time',
      'linux': 'Pacific/Galapagos'
    },
    {
      'windows': 'Central America Standard Time',
      'linux': 'America/Tegucigalpa'
    },
    {
      'windows': 'Central America Standard Time',
      'linux': 'America/Managua'
    },
    {
      'windows': 'Central America Standard Time',
      'linux': 'America/El_Salvador'
    },
    {
      'windows': 'Central America Standard Time',
      'linux': 'Etc/GMT+6'
    },
    {
      'windows': 'Central Asia Standard Time',
      'linux': 'Asia/Almaty'
    },
    {
      'windows': 'Central Asia Standard Time',
      'linux': 'Antarctica/Vostok'
    },
    {
      'windows': 'Central Asia Standard Time',
      'linux': 'Asia/Urumqi'
    },
    {
      'windows': 'Central Asia Standard Time',
      'linux': 'Indian/Chagos'
    },
    {
      'windows': 'Central Asia Standard Time',
      'linux': 'Asia/Bishkek'
    },
    {
      'windows': 'Central Asia Standard Time',
      'linux': 'Asia/Qyzylorda'
    },
    {
      'windows': 'Central Asia Standard Time',
      'linux': 'Etc/GMT-6'
    },
    {
      'windows': 'Central Brazilian Standard Time',
      'linux': 'America/Cuiaba'
    },
    {
      'windows': 'Central Brazilian Standard Time',
      'linux': 'America/Campo_Grande'
    },
    {
      'windows': 'Central Europe Standard Time',
      'linux': 'Europe/Budapest'
    },
    {
      'windows': 'Central Europe Standard Time',
      'linux': 'Europe/Tirane'
    },
    {
      'windows': 'Central Europe Standard Time',
      'linux': 'Europe/Prague'
    },
    {
      'windows': 'Central Europe Standard Time',
      'linux': 'Europe/Belgrade'
    },
    {
      'windows': 'Central European Standard Time',
      'linux': 'Europe/Warsaw'
    },
    {
      'windows': 'Central European Standard Time',
      'linux': 'Europe/Belgrade'
    },
    {
      'windows': 'Central Pacific Standard Time',
      'linux': 'Pacific/Guadalcanal'
    },
    {
      'windows': 'Central Pacific Standard Time',
      'linux': 'Antarctica/Casey'
    },
    {
      'windows': 'Central Pacific Standard Time',
      'linux': 'Antarctica/Macquarie'
    },
    {
      'windows': 'Central Pacific Standard Time',
      'linux': 'Pacific/Pohnpei Pacific/Kosrae'
    },
    {
      'windows': 'Central Pacific Standard Time',
      'linux': 'Pacific/Noumea'
    },
    {
      'windows': 'Central Pacific Standard Time',
      'linux': 'Pacific/Efate'
    },
    {
      'windows': 'Central Pacific Standard Time',
      'linux': 'Etc/GMT-11'
    },
    {
      'windows': 'Central Standard Time (Mexico)',
      'linux': 'America/Mexico_City'
    },
    {
      'windows': 'Central Standard Time',
      'linux': 'America/Chicago'
    },
    {
      'windows': 'Central Standard Time',
      'linux': 'America/Matamoros'
    },
    {
      'windows': 'Central Standard Time',
      'linux': 'CST6CDT'
    },
    {
      'windows': 'Chatham Islands Standard Time',
      'linux': 'Pacific/Chatham'
    },
    {
      'windows': 'China Standard Time',
      'linux': 'Asia/Shanghai'
    },
    {
      'windows': 'China Standard Time',
      'linux': 'Asia/Hong_Kong'
    },
    {
      'windows': 'China Standard Time',
      'linux': 'Asia/Macau'
    },
    {
      'windows': 'Cuba Standard Time',
      'linux': 'America/Havana'
    },
    {
      'windows': 'Dateline Standard Time',
      'linux': 'Etc/GMT+12'
    },
    {
      'windows': 'E. Africa Standard Time',
      'linux': 'Africa/Nairobi'
    },
    {
      'windows': 'E. Africa Standard Time',
      'linux': 'Antarctica/Syowa'
    },
    {
      'windows': 'E. Africa Standard Time',
      'linux': 'Africa/Khartoum'
    },
    {
      'windows': 'E. Africa Standard Time',
      'linux': 'Etc/GMT-3'
    },
    {
      'windows': 'E. Australia Standard Time',
      'linux': 'Australia/Brisbane'
    },
    {
      'windows': 'E. Australia Standard Time',
      'linux': 'Australia/Lindeman'
    },
    {
      'windows': 'E. Europe Standard Time',
      'linux': 'Europe/Chisinau'
    },
    {
      'windows': 'E. South America Standard Time',
      'linux': 'America/Sao_Paulo'
    },
    {
      'windows': 'Easter Island Standard Time',
      'linux': 'Pacific/Easter'
    },
    {
      'windows': 'Eastern Standard Time (Mexico)',
      'linux': 'America/Cancun'
    },
    {
      'windows': 'Eastern Standard Time',
      'linux': 'America/New_York'
    },
    {
      'windows': 'Eastern Standard Time',
      'linux': 'America/Nassau'
    },
    {
      'windows': 'Eastern Standard Time',
      'linux': 'EST5EDT'
    },
    {
      'windows': 'Egypt Standard Time',
      'linux': 'Africa/Cairo'
    },
    {
      'windows': 'Ekaterinburg Standard Time',
      'linux': 'Asia/Yekaterinburg'
    },
    {
      'windows': 'FLE Standard Time',
      'linux': 'Europe/Kiev'
    },
    {
      'windows': 'FLE Standard Time',
      'linux': 'Europe/Helsinki'
    },
    {
      'windows': 'FLE Standard Time',
      'linux': 'Europe/Sofia'
    },
    {
      'windows': 'FLE Standard Time',
      'linux': 'Europe/Tallinn'
    },
    {
      'windows': 'FLE Standard Time',
      'linux': 'Europe/Vilnius'
    },
    {
      'windows': 'FLE Standard Time',
      'linux': 'Europe/Riga'
    },
    {
      'windows': 'FLE Standard Time',
      'linux': 'Europe/Zaporozhye'
    },
    {
      'windows': 'Fiji Standard Time',
      'linux': 'Pacific/Fiji'
    },
    {
      'windows': 'GMT Standard Time',
      'linux': 'Europe/London'
    },
    {
      'windows': 'GMT Standard Time',
      'linux': 'Atlantic/Canary'
    },
    {
      'windows': 'GMT Standard Time',
      'linux': 'Atlantic/Faroe'
    },
    {
      'windows': 'GMT Standard Time',
      'linux': 'Europe/Dublin'
    },
    {
      'windows': 'GMT Standard Time',
      'linux': 'Atlantic/Madeira'
    },
    {
      'windows': 'GTB Standard Time',
      'linux': 'Europe/Bucharest'
    },
    {
      'windows': 'GTB Standard Time',
      'linux': 'Asia/Nicosia'
    },
    {
      'windows': 'GTB Standard Time',
      'linux': 'Europe/Athens'
    },
    {
      'windows': 'Georgian Standard Time',
      'linux': 'Asia/Tbilisi'
    },
    {
      'windows': 'Greenland Standard Time',
      'linux': 'America/Godthab'
    },
    {
      'windows': 'Greenwich Standard Time',
      'linux': 'Atlantic/Reykjavik'
    },
    {
      'windows': 'Greenwich Standard Time',
      'linux': 'Atlantic/St_Helena'
    },
    {
      'windows': 'Greenwich Standard Time',
      'linux': 'Africa/Abidjan'
    },
    {
      'windows': 'Greenwich Standard Time',
      'linux': 'Africa/Accra'
    },
    {
      'windows': 'Greenwich Standard Time',
      'linux': 'Africa/Bissau'
    },
    {
      'windows': 'Greenwich Standard Time',
      'linux': 'Africa/Monrovia'
    },
    {
      'windows': 'Haiti Standard Time',
      'linux': 'America/Port-au-Prince'
    },
    {
      'windows': 'Hawaiian Standard Time',
      'linux': 'Pacific/Honolulu'
    },
    {
      'windows': 'Hawaiian Standard Time',
      'linux': 'Pacific/Rarotonga'
    },
    {
      'windows': 'Hawaiian Standard Time',
      'linux': 'Pacific/Tahiti'
    },
    {
      'windows': 'Hawaiian Standard Time',
      'linux': 'Etc/GMT+10'
    },
    {
      'windows': 'India Standard Time',
      'linux': 'Asia/Kolkata'
    },
    {
      'windows': 'Iran Standard Time',
      'linux': 'Asia/Tehran'
    },
    {
      'windows': 'Israel Standard Time',
      'linux': 'Asia/Jerusalem'
    },
    {
      'windows': 'Jordan Standard Time',
      'linux': 'Asia/Amman'
    },
    {
      'windows': 'Kaliningrad Standard Time',
      'linux': 'Europe/Kaliningrad'
    },
    {
      'windows': 'Kamchatka Standard Time',
      'linux': 'Asia/Kamchatka'
    },
    {
      'windows': 'Korea Standard Time',
      'linux': 'Asia/Seoul'
    },
    {
      'windows': 'Libya Standard Time',
      'linux': 'Africa/Tripoli'
    },
    {
      'windows': 'Line Islands Standard Time',
      'linux': 'Pacific/Kiritimati'
    },
    {
      'windows': 'Line Islands Standard Time',
      'linux': 'Etc/GMT-14'
    },
    {
      'windows': 'Lord Howe Standard Time',
      'linux': 'Australia/Lord_Howe'
    },
    {
      'windows': 'Magadan Standard Time',
      'linux': 'Asia/Magadan'
    },
    {
      'windows': 'Marquesas Standard Time',
      'linux': 'Pacific/Marquesas'
    },
    {
      'windows': 'Mauritius Standard Time',
      'linux': 'Indian/Mauritius'
    },
    {
      'windows': 'Mauritius Standard Time',
      'linux': 'Indian/Reunion'
    },
    {
      'windows': 'Mauritius Standard Time',
      'linux': 'Indian/Mahe'
    },
    {
      'windows': 'Mid-Atlantic Standard Time',
      'linux': 'Etc/GMT+2'
    },
    {
      'windows': 'Middle East Standard Time',
      'linux': 'Asia/Beirut'
    },
    {
      'windows': 'Montevideo Standard Time',
      'linux': 'America/Montevideo'
    },
    {
      'windows': 'Morocco Standard Time',
      'linux': 'Africa/Casablanca'
    },
    {
      'windows': 'Morocco Standard Time',
      'linux': 'Africa/El_Aaiun'
    },
    {
      'windows': 'Mountain Standard Time (Mexico)',
      'linux': 'America/Chihuahua'
    },
    {
      'windows': 'Mountain Standard Time (Mexico)',
      'linux': 'America/Mazatlan'
    },
    {
      'windows': 'Mountain Standard Time',
      'linux': 'America/Denver'
    },
    {
      'windows': 'Mountain Standard Time',
      'linux': 'America/Edmonton'
    },
    {
      'windows': 'Mountain Standard Time',
      'linux': 'America/Ojinaga'
    },
    {
      'windows': 'Mountain Standard Time',
      'linux': 'America/Boise'
    },
    {
      'windows': 'Mountain Standard Time',
      'linux': 'MST7MDT'
    },
    {
      'windows': 'Myanmar Standard Time',
      'linux': 'Asia/Yangon'
    },
    {
      'windows': 'Myanmar Standard Time',
      'linux': 'Indian/Cocos'
    },
    {
      'windows': 'N. Central Asia Standard Time',
      'linux': 'Asia/Novosibirsk'
    },
    {
      'windows': 'Namibia Standard Time',
      'linux': 'Africa/Windhoek'
    },
    {
      'windows': 'Nepal Standard Time',
      'linux': 'Asia/Kathmandu'
    },
    {
      'windows': 'New Zealand Standard Time',
      'linux': 'Pacific/Auckland'
    },
    {
      'windows': 'Newfoundland Standard Time',
      'linux': 'America/St_Johns'
    },
    {
      'windows': 'Norfolk Standard Time',
      'linux': 'Pacific/Norfolk'
    },
    {
      'windows': 'North Asia East Standard Time',
      'linux': 'Asia/Irkutsk'
    },
    {
      'windows': 'North Asia Standard Time',
      'linux': 'Asia/Krasnoyarsk'
    },
    {
      'windows': 'North Asia Standard Time',
      'linux': 'Asia/Novokuznetsk'
    },
    {
      'windows': 'North Korea Standard Time',
      'linux': 'Asia/Pyongyang'
    },
    {
      'windows': 'Omsk Standard Time',
      'linux': 'Asia/Omsk'
    },
    {
      'windows': 'Pacific SA Standard Time',
      'linux': 'America/Santiago'
    },
    {
      'windows': 'Pacific SA Standard Time',
      'linux': 'Antarctica/Palmer'
    },
    {
      'windows': 'Pacific Standard Time (Mexico)',
      'linux': 'America/Tijuana'
    },
    {
      'windows': 'Pacific Standard Time',
      'linux': 'America/Los_Angeles'
    },
    {
      'windows': 'Pacific Standard Time',
      'linux': 'America/Vancouver'
    },
    {
      'windows': 'Pacific Standard Time',
      'linux': 'PST8PDT'
    },
    {
      'windows': 'Pakistan Standard Time',
      'linux': 'Asia/Karachi'
    },
    {
      'windows': 'Paraguay Standard Time',
      'linux': 'America/Asuncion'
    },
    {
      'windows': 'Romance Standard Time',
      'linux': 'Europe/Paris'
    },
    {
      'windows': 'Romance Standard Time',
      'linux': 'Europe/Brussels'
    },
    {
      'windows': 'Romance Standard Time',
      'linux': 'Europe/Copenhagen'
    },
    {
      'windows': 'Romance Standard Time',
      'linux': 'Africa/Ceuta'
    },
    {
      'windows': 'Romance Standard Time',
      'linux': 'Europe/Madrid'
    },
    {
      'windows': 'Russia Time Zone 10',
      'linux': 'Asia/Srednekolymsk'
    },
    {
      'windows': 'Russia Time Zone 11',
      'linux': 'Asia/Kamchatka'
    },
    {
      'windows': 'Russia Time Zone 11',
      'linux': 'Asia/Anadyr'
    },
    {
      'windows': 'Russia Time Zone 3',
      'linux': 'Europe/Samara'
    },
    {
      'windows': 'Russian Standard Time',
      'linux': 'Europe/Moscow'
    },
    {
      'windows': 'Russian Standard Time',
      'linux': 'Europe/Volgograd'
    },
    {
      'windows': 'Russian Standard Time',
      'linux': 'Europe/Simferopol'
    },
    {
      'windows': 'SA Eastern Standard Time',
      'linux': 'America/Cayenne'
    },
    {
      'windows': 'SA Eastern Standard Time',
      'linux': 'Antarctica/Rothera'
    },
    {
      'windows': 'SA Eastern Standard Time',
      'linux': 'America/Fortaleza'
    },
    {
      'windows': 'SA Eastern Standard Time',
      'linux': 'Atlantic/Stanley'
    },
    {
      'windows': 'SA Eastern Standard Time',
      'linux': 'America/Paramaribo'
    },
    {
      'windows': 'SA Eastern Standard Time',
      'linux': 'Etc/GMT+3'
    },
    {
      'windows': 'SA Pacific Standard Time',
      'linux': 'America/Bogota'
    },
    {
      'windows': 'SA Pacific Standard Time',
      'linux': 'America/Eirunepe'
    },
    {
      'windows': 'SA Pacific Standard Time',
      'linux': 'America/Atikokan'
    },
    {
      'windows': 'SA Pacific Standard Time',
      'linux': 'America/Guayaquil'
    },
    {
      'windows': 'SA Pacific Standard Time',
      'linux': 'America/Jamaica'
    },
    {
      'windows': 'SA Pacific Standard Time',
      'linux': 'America/Panama'
    },
    {
      'windows': 'SA Pacific Standard Time',
      'linux': 'America/Lima'
    },
    {
      'windows': 'SA Pacific Standard Time',
      'linux': 'Etc/GMT+5'
    },
    {
      'windows': 'SA Western Standard Time',
      'linux': 'America/La_Paz'
    },
    {
      'windows': 'SA Western Standard Time',
      'linux': 'America/Port_of_Spain'
    },
    {
      'windows': 'SA Western Standard Time',
      'linux': 'America/Curacao'
    },
    {
      'windows': 'SA Western Standard Time',
      'linux': 'America/Barbados'
    },
    {
      'windows': 'SA Western Standard Time',
      'linux': 'America/Manaus'
    },
    {
      'windows': 'SA Western Standard Time',
      'linux': 'America/Blanc-Sablon'
    },
    {
      'windows': 'SA Western Standard Time',
      'linux': 'America/Santo_Domingo'
    },
    {
      'windows': 'SA Western Standard Time',
      'linux': 'America/Guyana'
    },
    {
      'windows': 'SA Western Standard Time',
      'linux': 'America/Martinique'
    },
    {
      'windows': 'SA Western Standard Time',
      'linux': 'America/Puerto_Rico'
    },
    {
      'windows': 'SA Western Standard Time',
      'linux': 'Etc/GMT+4'
    },
    {
      'windows': 'SE Asia Standard Time',
      'linux': 'Asia/Bangkok'
    },
    {
      'windows': 'SE Asia Standard Time',
      'linux': 'Antarctica/Davis'
    },
    {
      'windows': 'SE Asia Standard Time',
      'linux': 'Indian/Christmas'
    },
    {
      'windows': 'SE Asia Standard Time',
      'linux': 'Asia/Jakarta Asia/Pontianak'
    },
    {
      'windows': 'SE Asia Standard Time',
      'linux': 'Asia/Ho_Chi_Minh'
    },
    {
      'windows': 'SE Asia Standard Time',
      'linux': 'Etc/GMT-7'
    },
    {
      'windows': 'Saint Pierre Standard Time',
      'linux': 'America/Miquelon'
    },
    {
      'windows': 'Sakhalin Standard Time',
      'linux': 'Asia/Sakhalin'
    },
    {
      'windows': 'Samoa Standard Time',
      'linux': 'Pacific/Apia'
    },
    {
      'windows': 'Singapore Standard Time',
      'linux': 'Asia/Singapore'
    },
    {
      'windows': 'Singapore Standard Time',
      'linux': 'Asia/Brunei'
    },
    {
      'windows': 'Singapore Standard Time',
      'linux': 'Asia/Makassar'
    },
    {
      'windows': 'Singapore Standard Time',
      'linux': 'Asia/Kuching'
    },
    {
      'windows': 'Singapore Standard Time',
      'linux': 'Asia/Manila'
    },
    {
      'windows': 'Singapore Standard Time',
      'linux': 'Etc/GMT-8'
    },
    {
      'windows': 'South Africa Standard Time',
      'linux': 'Africa/Johannesburg'
    },
    {
      'windows': 'South Africa Standard Time',
      'linux': 'Africa/Maputo'
    },
    {
      'windows': 'South Africa Standard Time',
      'linux': 'Etc/GMT-2'
    },
    {
      'windows': 'Sri Lanka Standard Time',
      'linux': 'Asia/Colombo'
    },
    {
      'windows': 'Syria Standard Time',
      'linux': 'Asia/Damascus'
    },
    {
      'windows': 'Taipei Standard Time',
      'linux': 'Asia/Taipei'
    },
    {
      'windows': 'Tasmania Standard Time',
      'linux': 'Australia/Hobart'
    },
    {
      'windows': 'Tasmania Standard Time',
      'linux': 'Australia/Currie'
    },
    {
      'windows': 'Tocantins Standard Time',
      'linux': 'America/Araguaina'
    },
    {
      'windows': 'Tokyo Standard Time',
      'linux': 'Asia/Tokyo'
    },
    {
      'windows': 'Tokyo Standard Time',
      'linux': 'Asia/Jayapura'
    },
    {
      'windows': 'Tokyo Standard Time',
      'linux': 'Pacific/Palau'
    },
    {
      'windows': 'Tokyo Standard Time',
      'linux': 'Asia/Dili'
    },
    {
      'windows': 'Tokyo Standard Time',
      'linux': 'Etc/GMT-9'
    },
    {
      'windows': 'Tomsk Standard Time',
      'linux': 'Asia/Tomsk'
    },
    {
      'windows': 'Tonga Standard Time',
      'linux': 'Pacific/Tongatapu'
    },
    {
      'windows': 'Tonga Standard Time',
      'linux': 'Pacific/Enderbury'
    },
    {
      'windows': 'Tonga Standard Time',
      'linux': 'Pacific/Fakaofo'
    },
    {
      'windows': 'Tonga Standard Time',
      'linux': 'Etc/GMT-13'
    },
    {
      'windows': 'Transbaikal Standard Time',
      'linux': 'Asia/Chita'
    },
    {
      'windows': 'Turkey Standard Time',
      'linux': 'Europe/Istanbul'
    },
    {
      'windows': 'Turkey Standard Time',
      'linux': 'Asia/Famagusta'
    },
    {
      'windows': 'Turks And Caicos Standard Time',
      'linux': 'America/Grand_Turk'
    },
    {
      'windows': 'US Eastern Standard Time',
      'linux': 'America/Indiana/Indianapolis'
    },
    {
      'windows': 'US Eastern Standard Time',
      'linux': 'America/Indiana/Marengo'
    },
    {
      'windows': 'US Eastern Standard Time',
      'linux': 'America/Indiana/Vevay'
    },
    {
      'windows': 'US Mountain Standard Time',
      'linux': 'America/Phoenix'
    },
    {
      'windows': 'US Mountain Standard Time',
      'linux': 'America/Hermosillo'
    },
    {
      'windows': 'US Mountain Standard Time',
      'linux': 'Etc/GMT+7'
    },
    {
      'windows': 'UTC+12',
      'linux': 'Etc/GMT-12'
    },
    {
      'windows': 'UTC+12',
      'linux': 'Pacific/Tarawa'
    },
    {
      'windows': 'UTC+12',
      'linux': 'Pacific/Majuro Pacific/Kwajalein'
    },
    {
      'windows': 'UTC+12',
      'linux': 'Pacific/Nauru'
    },
    {
      'windows': 'UTC+12',
      'linux': 'Pacific/Funafuti'
    },
    {
      'windows': 'UTC+12',
      'linux': 'Pacific/Wake'
    },
    {
      'windows': 'UTC+12',
      'linux': 'Pacific/Wallis'
    },
    {
      'windows': 'UTC',
      'linux': 'Etc/UTC'
    },
    {
      'windows': 'UTC',
      'linux': 'America/Danmarkshavn'
    },
    {
      'windows': 'UTC-02',
      'linux': 'Etc/GMT+2'
    },
    {
      'windows': 'UTC-02',
      'linux': 'America/Noronha'
    },
    {
      'windows': 'UTC-02',
      'linux': 'Atlantic/South_Georgia'
    },
    {
      'windows': 'UTC-08',
      'linux': 'Etc/GMT+8'
    },
    {
      'windows': 'UTC-08',
      'linux': 'Pacific/Pitcairn'
    },
    {
      'windows': 'UTC-09',
      'linux': 'Etc/GMT+9'
    },
    {
      'windows': 'UTC-09',
      'linux': 'Pacific/Gambier'
    },
    {
      'windows': 'UTC-11',
      'linux': 'Etc/GMT+11'
    },
    {
      'windows': 'UTC-11',
      'linux': 'Pacific/Pago_Pago'
    },
    {
      'windows': 'UTC-11',
      'linux': 'Pacific/Niue'
    },
    {
      'windows': 'Ulaanbaatar Standard Time',
      'linux': 'Asia/Ulaanbaatar'
    },
    {
      'windows': 'Venezuela Standard Time',
      'linux': 'America/Caracas'
    },
    {
      'windows': 'Vladivostok Standard Time',
      'linux': 'Asia/Vladivostok'
    },
    {
      'windows': 'Vladivostok Standard Time',
      'linux': 'Asia/Vladivostok Asia/Ust-Nera'
    },
    {
      'windows': 'W. Australia Standard Time',
      'linux': 'Australia/Perth'
    },
    {
      'windows': 'W. Central Africa Standard Time',
      'linux': 'Africa/Lagos'
    },
    {
      'windows': 'W. Central Africa Standard Time',
      'linux': 'Africa/Algiers'
    },
    {
      'windows': 'W. Central Africa Standard Time',
      'linux': 'Africa/Ndjamena'
    },
    {
      'windows': 'W. Central Africa Standard Time',
      'linux': 'Africa/Tunis'
    },
    {
      'windows': 'W. Central Africa Standard Time',
      'linux': 'Etc/GMT-1'
    },
    {
      'windows': 'W. Europe Standard Time',
      'linux': 'Europe/Berlin'
    },
    {
      'windows': 'W. Europe Standard Time',
      'linux': 'Europe/Andorra'
    },
    {
      'windows': 'W. Europe Standard Time',
      'linux': 'Europe/Vienna'
    },
    {
      'windows': 'W. Europe Standard Time',
      'linux': 'Europe/Zurich'
    },
    {
      'windows': 'W. Europe Standard Time',
      'linux': 'Europe/Berlin Europe/Zurich'
    },
    {
      'windows': 'W. Europe Standard Time',
      'linux': 'Europe/Gibraltar'
    },
    {
      'windows': 'W. Europe Standard Time',
      'linux': 'Europe/Rome'
    },
    {
      'windows': 'W. Europe Standard Time',
      'linux': 'Europe/Luxembourg'
    },
    {
      'windows': 'W. Europe Standard Time',
      'linux': 'Europe/Monaco'
    },
    {
      'windows': 'W. Europe Standard Time',
      'linux': 'Europe/Malta'
    },
    {
      'windows': 'W. Europe Standard Time',
      'linux': 'Europe/Amsterdam'
    },
    {
      'windows': 'W. Europe Standard Time',
      'linux': 'Europe/Oslo'
    },
    {
      'windows': 'W. Europe Standard Time',
      'linux': 'Europe/Stockholm'
    },
    {
      'windows': 'W. Mongolia Standard Time',
      'linux': 'Asia/Hovd'
    },
    {
      'windows': 'West Asia Standard Time',
      'linux': 'Asia/Tashkent'
    },
    {
      'windows': 'West Asia Standard Time',
      'linux': 'Antarctica/Mawson'
    },
    {
      'windows': 'West Asia Standard Time',
      'linux': 'Asia/Oral'
    },
    {
      'windows': 'West Asia Standard Time',
      'linux': 'Indian/Maldives'
    },
    {
      'windows': 'West Asia Standard Time',
      'linux': 'Indian/Kerguelen'
    },
    {
      'windows': 'West Asia Standard Time',
      'linux': 'Asia/Dushanbe'
    },
    {
      'windows': 'West Asia Standard Time',
      'linux': 'Asia/Ashgabat'
    },
    {
      'windows': 'West Asia Standard Time',
      'linux': 'Asia/Tashkent Asia/Samarkand'
    },
    {
      'windows': 'West Asia Standard Time',
      'linux': 'Etc/GMT-5'
    },
    {
      'windows': 'West Bank Standard Time',
      'linux': 'Asia/Hebron'
    },
    {
      'windows': 'West Bank Standard Time',
      'linux': 'Asia/Hebron Asia/Gaza'
    },
    {
      'windows': 'West Pacific Standard Time',
      'linux': 'Pacific/Port_Moresby'
    },
    {
      'windows': 'West Pacific Standard Time',
      'linux': 'Antarctica/DumontDUrville'
    },
    {
      'windows': 'West Pacific Standard Time',
      'linux': 'Pacific/Chuuk'
    },
    {
      'windows': 'West Pacific Standard Time',
      'linux': 'Pacific/Guam'
    },
    {
      'windows': 'West Pacific Standard Time',
      'linux': 'Etc/GMT-10'
    },
    {
      'windows': 'Yakutsk Standard Time',
      'linux': 'Asia/Yakutsk'
    },
    {
      'windows': 'Yakutsk Standard Time',
      'linux': 'Asia/Khandyga'
    },
  ];
}