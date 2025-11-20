class LabConstants {
  static const Map<String, String> labNames = {
    'BA': 'Lab Analisa Bisnis',
    'IS': 'Lab Sistem Informasi',
    'SE': 'Lab Rekayasa Perangkat Lunak',
    'STUDIO': 'Lab Self Learning',
    'NCS': 'Lab Jaringan & Keamanan Siber',
  };

  static const Map<String, String> labIcons = {
    'BA': '📊',
    'IS': '💻',
    'SE': '⚙️',
    'STUDIO': '🎓',
    'NCS': '🔒',
  };

  static String getLabName(String code) {
    return labNames[code] ?? code;
  }

  static String getLabIcon(String code) {
    return labIcons[code] ?? '📦';
  }

  static List<String> getAllLabCodes() {
    return labNames.keys.toList();
  }
}
