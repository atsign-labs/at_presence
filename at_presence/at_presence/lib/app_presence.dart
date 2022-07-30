class AppPresence{
  // late AppPresenceValues value;
  late String appNameSpace;
  late String description;
  late int lastSeen;

  AppPresence({required this.appNameSpace, required this.description, required this.lastSeen});

  @override
  String toString(){
    return 'App: $appNameSpace Description: $description LastSeen: $lastSeen';
  }

  Map toJson ()=> {
    AppPresenceConstants.description : description,
    AppPresenceConstants.appNameSpace : appNameSpace,
    AppPresenceConstants.currentTime : lastSeen,
  };
}

// enum AppPresenceValues  {offline, online}

abstract class AppPresenceConstants{
  static String description = 'description';
  static String key = 'appPresence';
  static String appNameSpace = 'appNameSpace';
  static String currentTime = 'currentTime';
  static String offlineCutoff = '5 minutes';
}