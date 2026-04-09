/// Na Android / iOS / Desktop sqflite funguje nativně bez další inicializace.
Future<void> initDatabaseFactory() async {
  // no-op: sqflite registruje vlastní factory automaticky přes plugin systém
}
