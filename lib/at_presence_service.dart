import 'dart:convert';
import 'package:at_client/at_client.dart';
import 'package:at_client/src/response/json_utils.dart';
import 'presence_model.dart';

class AtPresenceService {
  late AtClient atClient;
  late String namespace;

  AtPresenceService(this.atClient, this.namespace);

  static PresenceStatus getStatusFromName(String status) {
    if (status == 'available') {
      return PresenceStatus.available;
    }
    return PresenceStatus.unavailable;
  }

  Future<bool> setPresence(Presence presence, {String? atSign}) async {
    if (atSign.isNull) {
      var response = await _setGlobalPresence(presence);
      return response;
    }
    // create a shared key for atSign in users namespace and also notify
    var response = await _setPresenceFor(atSign!, presence);
    return response;
  }

  Future<Presence> getPresence({String? atSign}) async {
    late Map decodedResponse;
    if (atSign.isNotNull) {
      decodedResponse = await _getAtSignSpecificPresence(atSign!);
    }
    if (atSign.isNull) {
      decodedResponse = await _getGlobalPresence();
    }

    List<PresenceServices> presenceServiceList = [];
    return Presence(
        getStatusFromName(
            decodedResponse[PresenceServiceConstants.presenceStatus]),
        presenceServiceList.fromJson(jsonDecode(decodedResponse[
            PresenceServiceConstants.presenceServiceListStatus])),
        decodedResponse[PresenceServiceConstants.description]);
  }

  Future<bool> _setGlobalPresence(Presence presence) async {
    AtKey atKey = (AtKey.public(PresenceServiceConstants.key, namespace: namespace)
          ..sharedBy(atClient.getCurrentAtSign()!))
        .build();
    return await atClient.put(atKey, jsonEncode(presence.toJson()));
  }

  Future<bool> _setPresenceFor(String atSign, Presence presence) async {
    var atKey = AtKey()
      ..key = PresenceServiceConstants.key
      ..namespace = namespace
      ..sharedWith = atSign
      ..sharedBy = atClient.getCurrentAtSign()!
      ..metadata = (Metadata()
        ..ttr = 86400 //Cached time to refresh -1 represents universal truth
        // ..ttl = Time limit
        // ..ttb = Visible after
        ..ccd = true);

    // AtKey.shared(uuid)
    var response = await atClient.put(atKey, jsonEncode(presence.toJson()));
    return response;
  }

  Future<Map> _getGlobalPresence() async {
    // AtKey atKey = AtKey()
    //   ..key = PresenceServiceConstants.key
    //   ..namespace = namespace
    //   ..metadata = (Metadata()..isPublic = true)
    //   ..sharedBy = atClient.getCurrentAtSign();
    AtKey atKey =
        (AtKey.public(PresenceServiceConstants.key, namespace: namespace)
              ..sharedBy(atClient.getCurrentAtSign()!))
            .build();
    var presenceResponse = await atClient.get(atKey);
    return JsonUtils.decodeJson(presenceResponse.value);
  }

  Future<Map> _getAtSignSpecificPresence(String atSign) async {
    AtKey atKey = AtKey()
      ..key = PresenceServiceConstants.key
      ..namespace = namespace
      ..sharedBy = atSign
      ..sharedWith = atClient.getCurrentAtSign();
    var presenceResponse = await atClient.get(atKey);
    return JsonUtils.decodeJson(presenceResponse.value);
  }
}
