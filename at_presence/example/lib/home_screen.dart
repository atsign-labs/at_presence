import 'package:at_app_flutter/at_app_flutter.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_presence/app_presence.dart';
import 'package:at_presence/app_presence_service.dart';
import 'package:at_presence/at_presence_service.dart';
import 'package:at_presence/presence_model.dart';
import 'package:flutter/material.dart';

// * Once the onboarding process is completed you will be taken to this screen
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AtClientManager atClientManager = AtClientManager.getInstance();
  late AtPresenceService presenceService;
  bool busy = false;
  PresenceStatus status = PresenceStatus.available;
  List<String> _otherAtSigns = <String>['@zathura97tall'];
  late AppPresenceService appPresenceService;
  @override
  void initState() {
    appPresenceService = AppPresenceService(atClientManager);
    presenceService =
        AtPresenceService(atClientManager.atClient, AtEnv.appNamespace);
    super.initState();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: const Text('What\'s my current @sign?'),
        actions: [
          SizedBox.square(
            dimension: 60,
            child: FutureBuilder<bool>(
                future: appPresenceService.isOnline(
                    atSign: atClientManager.atClient.getCurrentAtSign()!,
                    appNameSpace: AtEnv.appNamespace),
                builder: (context, snapshot) {
                  return Stack(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          setState(() => busy = !busy);
                          await appPresenceService.setOnline(AppPresence(
                            appNameSpace: AtEnv.appNamespace,
                            description: '',
                            lastSeen: DateTime.now().millisecondsSinceEpoch,
                          ));
                        },
                        child: CircleAvatar(
                          radius: 50,
                          child: Icon(Icons.person),
                        ),
                      ),
                      PresenceWidget(snapshot.data ?? false),
                    ],
                  );
                }),
          ),
        ],
      ),
      body: Center(
        child: ListView.builder(
            itemCount: _otherAtSigns.length,
            itemBuilder: (context, index) {
              return FutureBuilder<Presence>(
                  future:
                  presenceService.getPresence(atSign: _otherAtSigns[index]),
                  builder: (context, snapshot) {
                    return ListTile(
                      onLongPress: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text(
                                    'Set presence for ${_otherAtSigns[index]}'),
                                content: StatefulBuilder(
                                    builder: (context, setState) {
                                      return Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                              'Set specific presence to ${_otherAtSigns[index]}'),
                                          RadioListTile(
                                            onChanged: (PresenceStatus? value) {
                                              setState(() => status = value!);
                                            },
                                            title: Text('Available'),
                                            value: PresenceStatus.available,
                                            groupValue: status,
                                          ),
                                          RadioListTile(
                                            onChanged: (PresenceStatus? value) {
                                              setState(() => status = value!);
                                            },
                                            title: Text('UnAvailable'),
                                            value: PresenceStatus.unavailable,
                                            groupValue: status,
                                          ),
                                        ],
                                      );
                                    }),
                                actions: [
                                  TextButton(
                                    child: Text('Cancel'),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  TextButton(
                                    child: Text('Ok'),
                                    onPressed: () async {
                                      await presenceService.setPresence(
                                          Presence(
                                              status,
                                              [
                                                status ==
                                                    PresenceStatus.available
                                                    ? PresenceServices.message
                                                    : PresenceServices.call
                                              ],
                                              'Available for ${busy ? 'messages only' : 'calls'}'),
                                          atSign: atClientManager.atClient
                                              .getCurrentAtSign());
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              );
                            });
                      },
                      leading: FutureBuilder<bool>(
                          future: appPresenceService.isOnline(
                              atSign: _otherAtSigns[index],
                              appNameSpace: AtEnv.appNamespace),
                          builder: (context, snapshot) {
                            return Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                  color: snapshot.data != null
                                      ? Colors.lightGreen
                                      : Colors.red,
                                  width: 3,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 50,
                                child: Icon(Icons.person),
                              ),
                            );
                          }),
                      trailing: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (snapshot.data != null &&
                                snapshot.data!.presenceServicesList.length ==
                                    2) ...[
                              Icon(Icons.call),
                              SizedBox(width: 10),
                              Icon(Icons.message),
                            ],
                            if (snapshot.data != null &&
                                snapshot.data!.presenceServicesList.length ==
                                    1 &&
                                snapshot.data!.presenceServicesList.first ==
                                    PresenceServices.call)
                              Icon(Icons.call),
                            if (snapshot.data != null &&
                                snapshot.data!.presenceServicesList.length ==
                                    1 &&
                                snapshot.data!.presenceServicesList.first ==
                                    PresenceServices.message)
                              Icon(Icons.message),
                          ]),
                      title: Text(_otherAtSigns[index]),
                      onTap: () async {
                        setState(() => busy = !busy);
                        await presenceService.setPresence(
                            Presence(
                                busy
                                    ? PresenceStatus.unavailable
                                    : PresenceStatus.available,
                                [
                                  busy
                                      ? PresenceServices.message
                                      : PresenceServices.call
                                ],
                                'Available for messages only'),
                            atSign: _otherAtSigns[index]);
                      },
                    );
                  });
            }),
      ),
    );
  }
}

class PresenceWidget extends StatelessWidget {
  const PresenceWidget(this.isOnline, {Key? key}) : super(key: key);
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      right: 0,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        height: 20,
        width: 20,
        decoration: BoxDecoration(
          color: isOnline ? Colors.red : Colors.green,
          borderRadius: BorderRadius.circular(50),
        ),
      ),
    );
  }
}
