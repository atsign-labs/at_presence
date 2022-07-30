import 'package:at_client/at_client.dart';

import '../bin/at_demo_data.dart' as demo_credentials;

class TestUtils {
  static AtClientPreference getPreference(String atsign) {
    var preference = AtClientPreference();
    preference.hiveStoragePath = 'test/hive/client';
    preference.commitLogPath = 'test/hive/client/commit';
    preference.isLocalStoreRequired = true;
    preference.privateKey = demo_credentials.pkamPrivateKeyMap[atsign];
    preference.rootDomain = 'root.atsign.org';
    return preference;
  }
}
