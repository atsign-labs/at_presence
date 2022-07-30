import 'package:at_client/at_client.dart';
import 'package:at_presence/app_presence.dart';
import 'package:at_presence/app_presence_service.dart';
import 'package:test/test.dart';

import '../test/setup_localkeys.dart';
import 'test_utils.dart';

void main() {
    test('test for set and get online methods', () async {
    var atsign = '@zathura97tall';
    var preference = TestUtils.getPreference(atsign);
    final atClientManager = await AtClientManager.getInstance()
        .setCurrentAtSign(atsign, 'at_presence_example', preference);
    await setEncryptionKeys(atsign, preference);
    // var atClient = atClientManager.atClient;
    atClientManager.syncService.sync();
    var appPresence = AppPresenceService(atClientManager);
    var appNameSpace = 'at_presence_example';
    var description = 'online';
    var lastSeen = DateTime.now().millisecondsSinceEpoch;
    var response = await appPresence.setOnline(AppPresence(
          appNameSpace: appNameSpace,
          description: description,
          lastSeen: lastSeen));
    print('set online response is $response');
    expect(response, true);
    var result = await appPresence.getOnline(atsign, appNameSpace);
    expect(result.appNameSpace, appNameSpace);
    expect(result.description, description);
    expect(result.lastSeen, lastSeen);
  }); 
  
}
