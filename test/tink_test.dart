import 'dart:convert';

import 'package:test/test.dart';
import '../lib/tink.dart';

main() {
  test('Tink example should seriailize and deserialize correctly', () {
    var testJSON = '''{
  "access_token": "3084989d7eb94d58995217807441bdf4",
  "expires_in": 7200,
  "id_hint": "John Doe",
  "refresh_token": "8bc289f2dd94440bb4561c55e1903845",
  "scope": "transactions:read,accounts:read",
  "token_type": "bearer"
}''';

    var decoded = TinkIntegration.fromJson(json.decode(testJSON));
    var encodedJSON = json.encode(decoded);
    print(encodedJSON);
    var decodedEncodedJSON =
        TinkIntegration.fromJson(json.decode(encodedJSON));
    expect(decoded.toJson(), equals(decodedEncodedJSON.toJson()));
  });
}
