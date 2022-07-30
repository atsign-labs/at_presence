import 'package:at_client/at_client.dart';
import 'package:at_presence/app_presence.dart';
import 'package:at_presence/app_presence_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

Map localKeyStore = {};

class MockAtClientManager extends Mock implements AtClientManager {}

class MockAtClient extends Mock implements AtClientImpl {
  @override
  Future<bool> put(AtKey key, dynamic value, {bool isDedicated = false}) {
    localKeyStore.putIfAbsent(key.toString(), () => AtValue().value = value);
    return Future.value(true);
  }

  @override
  Future<AtValue> get(AtKey key, {bool isDedicated = false}) {
    var response;
    if (localKeyStore.containsKey(key.toString())) {
      response = localKeyStore[key.toString()];
    }
    var atValue = AtValue()..value = response;
    return Future.value(atValue);
  }
}

void main() {
  AtClientManager mockAtClientManager = MockAtClientManager();
  AtClient mockAtClient = MockAtClient();

  when(() => mockAtClientManager.atClient).thenAnswer((_) => mockAtClient);

  when(() => mockAtClient.getCurrentAtSign()).thenAnswer((_) => '@bob');

  group('A group of test to validate presence service', () {
    test('test to set online', () async {
      var appPresenceService = AppPresenceService(mockAtClientManager);
      var appNameSpace = 'at_presence_example';
      var description = 'online';
      var lastSeen = DateTime.now().millisecondsSinceEpoch;
      await appPresenceService.setOnline(AppPresence(
          appNameSpace: appNameSpace,
          description: description,
          lastSeen: lastSeen));
      var result = await appPresenceService.getOnline('@bob', 'at_presence_example');
      expect(result.appNameSpace, appNameSpace);
      expect(result.description, description);
      expect(result.lastSeen, lastSeen);
    });
  });
}
