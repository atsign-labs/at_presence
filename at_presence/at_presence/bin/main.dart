import 'package:at_client/at_client.dart';
import 'package:at_presence/app_presence.dart';
import 'package:at_presence/app_presence_service.dart';
import 'package:at_presence/at_presence_service.dart';
import 'package:at_presence/presence_model.dart';

import '../test/setup_localkeys.dart';
import 'commons.dart';

void main() async {
  var atsign = '@zathura97tall';
  var otheratSign = '@mangotangostable';
  var atClientManager = await AtClientManager.getInstance().setCurrentAtSign(
      atsign, 'at_presence_example', Utils.getAtsignPreference(atsign));
  AppPresenceService appPresenceService = AppPresenceService(atClientManager);
  AtPresenceService presenceService =
      AtPresenceService(atClientManager.atClient, 'at_presence_example');
  await setEncryptionKeys(atsign, Utils.getAtsignPreference(atsign));
  try {
    var response = await presenceService.setPresence(
        Presence(PresenceStatus.unavailable, [PresenceServices.call],
            'Available for calls only'),
        atSign: otheratSign);
    print(response);
    var a = await appPresenceService.setOnline(
      AppPresence(
          appNameSpace: 'at_presence_example',
          description: 'I\'m online now',
          lastSeen: DateTime.now().millisecondsSinceEpoch),
    );
    print(a);

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
