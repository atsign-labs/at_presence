import 'package:at_client/at_client.dart';
import 'package:at_presence/at_presence_service.dart';
import 'package:at_presence/presence_model.dart';
import 'package:test/test.dart';

import '../test/setup_localkeys.dart';
import 'test_utils.dart';

void main() {
  test('test for set and get presence', () async {
    var atsign = '@zathura97tall';
    var preference = TestUtils.getPreference(atsign);
    final atClientManager = await AtClientManager.getInstance()
        .setCurrentAtSign(atsign, 'at_presence_example', preference);
    await setEncryptionKeys(atsign, preference);
    var atClient = atClientManager.atClient;
    atClientManager.syncService.sync();
    var presence = AtPresenceService(atClient, 'at_presence_example');
    var presenceResult = await presence.setPresence(Presence(PresenceStatus.available,
          [PresenceServices.message], 'Available for messages only'));
    expect(presenceResult, true);
    var response = await presence.getPresence();
    expect(response.description, 'Available for messages only');
    expect(response.presenceStatus, PresenceStatus.available);
    expect(response.presenceServicesList, [PresenceServices.message]);
  });
}

