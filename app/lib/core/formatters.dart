/// pt-BR formatting with Itapipoca's time zone (America/Fortaleza, UTC−3, no daylight saving).
class BR {
  static const _months = ['jan.', 'fev.', 'mar.', 'abr.', 'mai.', 'jun.', 'jul.', 'ago.', 'set.', 'out.', 'nov.', 'dez.'];
  static const _monthsLong = ['janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho', 'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro'];
  static const _weekdays = ['segunda-feira', 'terça-feira', 'quarta-feira', 'quinta-feira', 'sexta-feira', 'sábado', 'domingo'];

  /// Wall-clock time in Fortaleza for an instant.
  static DateTime local(DateTime instant) => instant.toUtc().subtract(const Duration(hours: 3));

  /// An instant from a Fortaleza wall-clock time.
  static DateTime fortaleza(int y, int m, int d, int h, int min) => DateTime.utc(y, m, d, h + 3, min);

  static String money(double value) {
    final cents = (value * 100).round();
    final whole = (cents ~/ 100).toString();
    final buffer = StringBuffer();
    for (var i = 0; i < whole.length; i++) {
      if (i > 0 && (whole.length - i) % 3 == 0) buffer.write('.');
      buffer.write(whole[i]);
    }
    return 'R\$ $buffer,${(cents % 100).toString().padLeft(2, '0')}';
  }

  static String km(double value) {
    final text = value >= 10 ? value.round().toString() : value.toStringAsFixed(1).replaceAll('.', ',');
    return '$text km';
  }

  static String rating(double value) => value.toStringAsFixed(2).replaceAll('.', ',');

  static String integer(int value) {
    final s = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write('.');
      buffer.write(s[i]);
    }
    return buffer.toString();
  }

  static String time(DateTime instant) {
    final t = local(instant);
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  static String shortDate(DateTime instant) {
    final t = local(instant);
    return '${t.day} de ${_months[t.month - 1]}';
  }

  static String longDate(DateTime instant) {
    final t = local(instant);
    return '${_weekdays[t.weekday - 1]}, ${t.day} de ${_monthsLong[t.month - 1]} às ${time(instant)}';
  }

  static String greeting(DateTime instant) {
    final h = local(instant).hour;
    if (h < 12) return 'Bom dia';
    if (h < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  static const _from = 'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ';
  static const _to = 'aaaaaeeeeiiiiooooouuuucaaaaaeeeeiiiiooooouuuuc';

  /// Accent- and case-insensitive key for search ("Rodoviária" matches "rodoviaria").
  static String searchKey(String text) {
    final buffer = StringBuffer();
    for (final ch in text.trim().split('')) {
      final i = _from.indexOf(ch);
      buffer.write(i >= 0 ? _to[i] : ch);
    }
    return buffer.toString().toLowerCase();
  }
}
