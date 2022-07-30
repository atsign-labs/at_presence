import 'package:at_client/at_client.dart';
import '../test/setup_localkeys.dart';
import 'commons.dart';

void main() async {
  var atsign = '@supremegull48';
  try {
    print('Starting recipient..');
    await setEncryptionKeys(atsign, Utils.getAtsignPreference(atsign));
    AtClientManager.getInstance()
        .notificationService
        .subscribe(shouldDecrypt: true)
        .listen((event) {
      print(event.key);
      print(event.value);
    });
    print('Recipient started...');
    await Future.delayed(Duration(minutes: 60));
  } on AtException catch (e, stacktrace) {
    // e.toString();
    // TODO
    print(e);
    print(stacktrace);
  }
}
