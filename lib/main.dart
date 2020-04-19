import 'package:flutter/material.dart';
import 'tink.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sparla',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Sparla'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _storage = FlutterSecureStorage();
  List<TinkIntegration> integrations = [];

  @override
  void initState() {
    super.initState();
    loadIntegrations().then((i) {
      setState(() {
        integrations = i;
      });
    });
  }

  Future<List<TinkIntegration>> loadIntegrations() async {
    var all = await _storage.readAll();
    print(all);
    return all.values
        .map((i) => (TinkIntegration.fromJson(json.decode(i))))
        .toList();
  }

  void _addIntegration(context) async {
    final Future<TinkIntegration> i = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => TinkAddIntegration()));
    final integration = await i;
    _storage.write(key: "integration:" + integration.accessToken, value: json.encode(integration));

    loadIntegrations().then((i) {
      setState(() {
        integrations = i;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            integrations.isEmpty
                ? Text("empty")
                : ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: integrations.length,
                    itemBuilder: (BuildContext context, int i) {
                      return Account(integration: integrations[i]);
                    },
                  ),
            RaisedButton(
              child: const Text('Link accounts'),
              onPressed: () {
                _addIntegration(context);
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addIntegration(context);
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}

class Account extends StatefulWidget {
  final TinkIntegration integration;
  Account({Key key, this.integration}) : super(key: key);
  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
  Future<List<TinkAccount>> accounts;

  @override
  void initState() {
    accounts = widget.integration.getAccounts();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text("Account"),
      FutureBuilder<List<TinkAccount>>(
        future: accounts,
        builder: (BuildContext context, AsyncSnapshot<List<TinkAccount>> snapshot) {
          if (snapshot.hasData) {
            var a = snapshot.data;
            return Column(children: [
              Text(a[0].accountNumber),
              Text(a[0].name),
              Text(a[0].balance.toString(),
                  style: TextStyle(fontSize: 44)),
              RaisedButton(
                child: const Text("Refresh"),
                onPressed: () {
                  setState(() {
                    accounts = widget.integration.getAccounts();
                  });
                },
              ),
            ]);
          }
          else if (snapshot.hasError){
            return Text("error: "+ snapshot.error.toString());
          }
          else {
            return Text("loading");
          }
        },
      ),
    ]);
  }
}
