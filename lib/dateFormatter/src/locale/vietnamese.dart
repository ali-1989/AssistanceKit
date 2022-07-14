import '../../date_format.dart';

class VietNameseLocale implements Locale {
  const VietNameseLocale();

  @override
  final List<String> monthsShort = const [
    'Th1',
    'Th2',
    'Th3',
    'Th4',
    'Th5',
    'Th6',
    'Th7',
    'Th8',
    'Th9',
    'Th10',
    'Th11',
    'Th12'
  ];

  @override
  final List<String> monthsLong = const [
    'Tháng một',
    'Tháng hai',
    'Tháng ba',
    'Tháng tư',
    'Tháng năm',
    'Tháng sáu',
    'Tháng bảy',
    'Tháng tám',
    'Tháng chín',
    'Tháng mười',
    'Tháng mười một',
    'Tháng mười hai'
  ];

  @override
  final List<String> daysShort = const [
    'T2',
    'T3',
    'T4',
    'T5',
    'T6',
    'T7',
    'CN'
  ];

  @override
  final List<String> daysLong = const [
    'Thứ hai',
    'Thứ ba',
    'Thứ tư',
    'Thứ năm',
    'Thứ sáu',
    'Thứ bảy',
    'Chủ nhật'
  ];

  @override
  String get am => 'SA';

  @override
  String get pm => 'CH';
}
