class Language {
  int id;
  String name;
  String languageCode;
  String flag;

  Language(this.id, this.name, this.languageCode, this.flag);

  static List<Language> getLanguages() {
    return <Language>[
      Language(0, 'English', 'en', 'assets/flags/ic_us.png'),
      Language(1, 'Hindi', 'hi', 'assets/flags/ic_india.png'),
      Language(2, 'Spanish', 'es', 'assets/flags/ic_spain.png'),
      Language(3, 'Afrikaans', 'af', 'assets/flags/ic_south_africa.png'),
      Language(4, 'French', 'fr', 'assets/flags/ic_france.png'),
      Language(5, 'German', 'de', 'assets/flags/ic_germany.png'),
      Language(6, 'Indonesian', 'id', 'assets/flags/ic_indonesia.png'),
      Language(7, 'Portuguese', 'pt', 'assets/flags/ic_portugal.png'),
      Language(8, 'Turkish', 'tr', 'assets/flags/ic_turkey.png'),
      Language(9, 'Arabic', 'ar', 'assets/flags/ic_arabic.png'),
    ];
  }
}
