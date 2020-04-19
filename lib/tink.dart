import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';
import 'dart:core';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class TinkAddIntegration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tink Integration')),
      body: Builder(
        builder: (BuildContext context) {
          var queryParameters = {
            'client_id': 'cfdc3cb11450483e9d5f70ed71bc4eb9',
            'redirect_uri': 'sparly://login/tink',
            'scope':
                'accounts:read,investments:read,transactions:read,user:read',
            'market': 'SE',
            'locale': 'en_US',
            //  'test': 'true',
          };
          var uri =
              Uri.https('link.tink.com', '/1.0/authorize/', queryParameters);
          print(uri.toString());
          return WebView(
            initialUrl: uri.toString(),
            javascriptMode: JavascriptMode.unrestricted,
            navigationDelegate: (NavigationRequest request) {
              if (request.url.startsWith('sparly://login/tink')) {
                print(request.url);
                final tc = parseLoginUrl(request.url);
                Navigator.pop(context, tc);
                return NavigationDecision.prevent;
              }
              if (request.url.startsWith('bankid://')) {
                launch(request.url);
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
          );
        },
      ),
    );
  }
}

Future<TinkIntegration> initIntegration(code) async {
  var url = "https://api.tink.com/api/v1/oauth/token";
  var body = {
    'code': code,
    'client_id': 'cfdc3cb11450483e9d5f70ed71bc4eb9',
    'client_secret': '67197e004d3b4083be202fe9680ef83f',
    'grant_type': 'authorization_code',
  };
  print(body);
  var response = await http.post(url, body: body);
  print(response.body);
  var bodyJSON = json.decode(response.body);
  return TinkIntegration.fromJson(bodyJSON);
}

class TinkAccount {
  final String id;
  final String name;
  final String accountNumber;
  final String type;
  final double balance;

 TinkAccount.fromJson(Map<String, dynamic> json):
        id = json['id'],
        name=  json['name'],
        accountNumber = json['accountNumber'],
        type = json ['type'],
        balance= json['balance'];
}

class TinkIntegration {
  String accessToken;
  final String refreshToken;
  final String idHint;
  num expiresIn;
  final String scope ;
  final String tokenType ;

  TinkIntegration.fromJson(Map<String, dynamic> json):
        accessToken = json['access_token'],
        refreshToken=  json['refresh_token'],
        expiresIn = json['expires_in'],
        idHint = json ['id_hint'],
        scope = json['scope'],
        tokenType = json['token_type'];

  Map<String, dynamic> toJson() =>
      {
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'expires_in': expiresIn,
        'id_hint':idHint,
        'scope':scope,
        'token_type':tokenType,
      };

  Future<List<TinkAccount>> getAccounts() async {
    var accountURL = "https://api.tink.com/api/v1/accounts/list";
    var accounts = await http
        .get(accountURL, headers: {"Authorization": "Bearer " + this.accessToken});
    print(accounts.statusCode);
    if (accounts.statusCode != 200){
      throw "access denied";
    }
    print(accounts.body);
    List<TinkAccount> out;
    out = json.decode(accounts.body)["accounts"].map((account) => TinkAccount.fromJson(account)).toList();
    return out;
  }
}

parseLoginUrl(String uri) {
  var loginUri = Uri.parse(uri);
  var params = loginUri.queryParameters;
  // TODO: parse errors
  // I/flutter ( 3298): sparly://login/tink?error=TEMPORARY_ERROR&message=Authentication%20got%20TEMPORARY_ERROR%20with%20message%3A%20Temporary%20error.%20Please%20try%20again%20later.

  var code = params["code"];
  var credentialsId = params["code"];

  print(params["code"]);
  print(params["credentialsId"]);
  return initIntegration(code);
}

