import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'main.g.dart';

const String contactsBoxName = "contacts";

@HiveType(typeId: 1)
enum Relationship {
  @HiveField(0)
  Family,
  @HiveField(1)
  Friend,
}
const relationships = <Relationship, String>{
  Relationship.Family: "Family",
  Relationship.Friend: "Friend",
};

@HiveType(typeId: 0)
class Contact {
  @HiveField(0)
  String name;
  @HiveField(1)
  int age;
  @HiveField(2)
  Relationship relationship;
  @HiveField(3)
  String phoneNumber;

  Contact(this.name, this.age, this.phoneNumber, this.relationship);
}

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(ContactAdapter());
  Hive.registerAdapter(RelationshipAdapter());
  await Hive.openBox<Contact>(contactsBoxName);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget _buildDivider() => const SizedBox(height: 5);

    return MaterialApp(
      title: 'Contacts App',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Contacts App with Hive'),
        ),
        body: ValueListenableBuilder(
          valueListenable: Hive.box<Contact>(contactsBoxName).listenable(),
          builder: (context, Box<Contact> box, _) {
            if (box.values.isEmpty)
              return Center(
                child: Text("No contacts"),
              );
            return ListView.builder(
              itemCount: box.length,
              itemBuilder: (context, index) {
                Contact c = box.getAt(index);
                String relationship = relationships[c.relationship];
                return InkWell(
                  onLongPress: () {
                    showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (_) => AlertDialog(
                        content: Text(
                          "Do you want to delete ${c.name}?",
                        ),
                        actions: <Widget>[
                          FlatButton(
                            child: Text("No"),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          FlatButton(
                            child: Text("Yes"),
                            onPressed: () async {
                              Navigator.of(context).pop();
                              await box.deleteAt(index);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _buildDivider(),
                          Text(c.name),
                          _buildDivider(),
                          Text(c.phoneNumber),
                          _buildDivider(),
                          Text("Age: ${c.age}"),
                          _buildDivider(),
                          Text("Relationship: $relationship"),
                          _buildDivider(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: Builder(
          builder: (context) {
            return FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => AddContact()),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class AddContact extends StatefulWidget {
  final formKey = GlobalKey<FormState>();

  @override
  _AddContactState createState() => _AddContactState();
}

class _AddContactState extends State<AddContact> {
  String name;
  int age;
  String phoneNumber;
  Relationship relationship;

  void onFormSubmit() {
    if (widget.formKey.currentState.validate()) {
      Box<Contact> contactsBox = Hive.box<Contact>(contactsBoxName);
      contactsBox.add(Contact(name, age, phoneNumber, relationship));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: widget.formKey,
          child: ListView(
            padding: const EdgeInsets.all(8.0),
            children: <Widget>[
              TextFormField(
                autofocus: true,
                initialValue: "",
                decoration: const InputDecoration(
                  labelText: "Name",
                ),
                onChanged: (value) {
                  setState(() {
                    name = value;
                  });
                },
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                initialValue: "",
                maxLength: 3,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                decoration: const InputDecoration(
                  labelText: "Age",
                ),
                onChanged: (value) {
                  setState(() {
                    age = int.parse(value);
                  });
                },
              ),
              TextFormField(
                keyboardType: TextInputType.phone,
                initialValue: "",
                decoration: const InputDecoration(
                  labelText: "Phone",
                ),
                onChanged: (value) {
                  setState(() {
                    phoneNumber = value;
                  });
                },
              ),
              DropdownButtonFormField(
                items: relationships.keys.map((Relationship value) {
                  return DropdownMenuItem<Relationship>(
                    value: value,
                    child: Text(relationships[value]),
                  );
                }).toList(),
                value: relationship,
                hint: Text("Relationship"),
                onChanged: (value) {
                  setState(() {
                    relationship = value;
                  });
                },
              ),
              OutlinedButton(
                child: Text("Submit"),
                onPressed: onFormSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
