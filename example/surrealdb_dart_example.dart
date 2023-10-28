import 'package:surrealdb_dart/surrealdb_dart.dart';

void main() async {
  try {
    // Connect to the database
    final db = SurrealDB.connect(Uri.parse('wss://dei-surrealdb.fly.dev/rpc'));

    // Signin as a namespace, database, or root user
    await db.signin(
      username: "root",
      password: "root",
    );

    // Select a specific namespace / database
    await db.use(namespace: "test", database: "test");

    // Create a new person with a random id
    final created = await db.create("person", data: {
      'title': "Founder & CEO",
      'name': {
        'first': "Tobie",
        'last': "Morgan Hitchcock",
      },
      'marketing': true,
    });
    print(created);


    // Update a person record with a specific id
    final updated = await db.merge("person:jaime", data: {
      'marketing': true,
    });
    print(updated);


    // Select all people records
    final people = await db.select("person");
    print(people);

    // Perform a custom advanced query
    final groups = await db.query(
      "SELECT marketing, count() FROM type::table(\$tb) GROUP BY marketing",
      vars: {
        'tb': "person",
      },
    );
    print(groups);

  } catch (e) {
    print(e);
  }
}
