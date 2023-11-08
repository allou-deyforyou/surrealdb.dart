part of surrealdb;

sealed class SurrealDB {
  const SurrealDB();

  static void initialize() {
    initializePlatformBindings();
  }

  void close();
}
