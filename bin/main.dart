import 'package:at_client/at_client.dart';
import 'package:at_presence/at_presence_service.dart';
import 'package:at_presence/presence_model.dart';
import '../test/setup_localkeys.dart';
import 'commons.dart';

void main() async {
  var atsign = '@zathura97tall';
  var otheratSign = '@supremegull48';
  var atClientManager = await AtClientManager.getInstance()
      .setCurrentAtSign(atsign, 'wavi', Utils.getAtsignPreference(atsign));
  AtPresenceService presenceService =
      AtPresenceService(atClientManager.atClient, 'wavi');
  await setEncryptionKeys(atsign, Utils.getAtsignPreference(atsign));
  try {
    var response = await presenceService.setPresence(
        Presence(PresenceStatus.available, [PresenceServices.message],
            'Available for messages only'),
        atSign: otheratSign);
    print(response);
    var getPresenceResponse =
        await presenceService.getPresence(atSign: otheratSign);
    print(getPresenceResponse);
    AtClientManager.getInstance()
        .notificationService
        .subscribe(shouldDecrypt: true)
        .listen((event) {
      print(event.key);
      print(event.value);
    });
  } on AtException catch (e, stacktrace) {
    // e.toString();
    // TODO
    print(e);
    print(stacktrace);
  }
}
