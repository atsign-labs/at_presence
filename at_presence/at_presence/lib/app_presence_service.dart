import 'dart:async';
import 'dart:convert';

import 'package:at_client/at_client.dart';
import 'package:at_client/src/response/json_utils.dart';
import 'package:at_presence/app_presence.dart';

class AppPresenceService {
  late Timer periodicTimer;
  late AtClient atClient;
  late AtClientManager atClientManager;

  AppPresenceService(this.atClientManager) {
    atClient = atClientManager.atClient;
  }

  Future<bool> setOnline(AppPresence appPresence, {String? appAtSign}) async {
    var response = await _setAppPresence(appPresence, appAtSign);
    return response;
  }

  Future<bool> _setAppPresence(
      AppPresence appPresence, String? appAtSign) async {
    AtKey atKey = (AtKey.public(AppPresenceConstants.key,
            namespace: appPresence.appNameSpace)
          ..sharedBy(atClient.getCurrentAtSign()!))
        .build();
    if (appAtSign != null) {
      atClientManager.notificationService.notify(NotificationParams.forUpdate(
          atKey,
          value: jsonEncode(appPresence.toJson())));
    }
    return await atClient.put(atKey, jsonEncode(appPresence.toJson()));
  }

  Future<AppPresence> getOnline(String atSign, String appNameSpace) async {
    late Map decodedResponse;

    decodedResponse = await _getAppPresence(atSign, appNameSpace);

    return AppPresence(
      appNameSpace: decodedResponse[AppPresenceConstants.appNameSpace],
      description: decodedResponse[AppPresenceConstants.description],
      lastSeen: decodedResponse[AppPresenceConstants.currentTime],
    );
  }

  Future<Map> _getAppPresence(String atSign, String appNameSpace) async {
    AtKey atKey = AtKey()
      ..key = AppPresenceConstants.key
      ..namespace = appNameSpace
      ..metadata = (Metadata()..isPublic = true)
      ..sharedBy = atSign;
    var appPresenceResponse = await atClient.get(atKey);
    return JsonUtils.decodeJson(appPresenceResponse.value);
  }

  Future<bool> isOnline(
      {required String atSign, required String appNameSpace}) async {
    AppPresence appPresence = await getOnline(atSign, appNameSpace);
    num i = (DateTime.now().millisecondsSinceEpoch - appPresence.lastSeen);
    return i < 5 * 1000 * 60;
  }

  void startPeriodicUpdate(AppPresence appPresence, {String? appAtSign}) {
    periodicTimer = Timer.periodic(Duration(seconds: 5), (timer) async {
      appPresence.lastSeen = DateTime.now().toUtc().millisecondsSinceEpoch;
      await setOnline(appPresence, appAtSign: appAtSign);
    });
  }

  void stopPeriodicUpdate() {
    periodicTimer.cancel();
  }
}
