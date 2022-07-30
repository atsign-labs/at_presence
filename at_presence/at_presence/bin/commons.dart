import 'package:at_client/at_client.dart';

import 'at_demo_data.dart';

class Utils {
  static AtClientPreference getAtsignPreference(String atsign) {
    var preference = AtClientPreference();
    preference.hiveStoragePath = 'hive/client';
    preference.commitLogPath = 'hive/commit/commit';
    preference.isLocalStoreRequired = true;
    preference.privateKey = pkamPrivateKeyMap[atsign];
    preference.rootDomain = 'root.atsign.org';
    return preference;
  }
}
