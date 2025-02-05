import 'package:adb_gui/components/window_buttons.dart';
import 'package:adb_gui/screens/device_info_screen.dart';
import 'package:adb_gui/screens/package_manager_screen.dart';
import 'package:adb_gui/services/adb_services.dart';
import 'package:adb_gui/services/platform_services.dart';
import 'package:adb_gui/utils/enums.dart';
import 'package:adb_gui/models/device.dart';
import 'package:adb_gui/screens/file_manager_screen.dart';
import 'package:adb_gui/screens/power_controls_screen.dart';
import 'package:adb_gui/services/android_api_checks.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';

import '../utils/const.dart';

class HomeScreen extends StatefulWidget {
  final Device device;
  const HomeScreen({Key? key,required this.device}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState(device);
}

class _HomeScreenState extends State<HomeScreen> {

  Screens _currentScreen=Screens.fileManager;
  final Device device;

  _HomeScreenState(this.device);


  String _getScreenName(Screens screenEnum){
    switch(screenEnum){
      case Screens.fileManager: return "Files";
      case Screens.powerControls: return "Power Controls";
      case Screens.packageManager: return "Apps";
      case Screens.deviceInfo: return "Device Info";
      default: return "Wtf??";
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          width: double.infinity,
          height: 50,
          child: MoveWindow(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Tooltip(
                  message: "${device.id} - ${device.model}",
                  child: Text("${_getScreenName(_currentScreen)} (${device.model})",overflow: TextOverflow.ellipsis,style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20
                  ),),
                ),
                const Spacer(),
                if(isPreMarshmallowAndroid(device.androidAPILevel))
                  WindowMaterialButton(
                  // buttonColor: Colors.blue,
                  hoverColor: Colors.amber[300],
                  buttonIcon: Icon(Icons.warning,color: Colors.amber[700],),
                  onPressed: (){
                    showDialog(
                      context: context,
                      builder: (context)=>AlertDialog(
                        title: const Text("Stability Alert",style: TextStyle(
                          color: kAccentColor
                        ),),
                        content: Text("You may experience degraded performance/glitches since your device runs on Android ${device.androidVersion} .\nThe recommended Android version is 7.0 and above"),
                        actions: [
                          TextButton(
                            onPressed: (){
                              Navigator.pop(context);
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text("OK",style: TextStyle(
                                color: kAccentColor
                              ),),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                WindowMaterialButton(
                  // buttonColor: Colors.blue,
                  buttonIcon: const Icon(Icons.exit_to_app_rounded,color: Colors.white,),
                  onPressed: () async{
                    await ADBService(device: device).disconnect();
                    Navigator.pop(context);
                  },
                ),
                CustomMinimizeWindowButton(),
                CustomMaximizeWindowButton(),
                CustomCloseWindowButton(),
              ],
            ),
          ),
        ),
      ),
      drawer: Drawer(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(10),
                bottomRight: Radius.circular(10))),
        child: Builder(builder: (context) {
          return ListView(
            children: [
              DrawerHeader(
                  decoration: BoxDecoration(
                    gradient: Theme.of(context).brightness==Brightness.light?const LinearGradient(
                      colors: [Colors.blueGrey, Colors.grey],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ):null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      Image.asset("assets/lightningBoltLogo.png",width: 50,height: 50,),
                      const Padding(
                        padding: EdgeInsets.only(left: 12.0, bottom: 4),
                        child: Text(
                          "Android Toolbox",
                          style: TextStyle(color: Colors.white, fontSize: 25),
                        ),
                      ),
                    ],
                  )),
              ListTile(
                leading: const Icon(Icons.drive_file_move),
                title: const Text("File Manager",),
                dense: false,
                onTap: (){
                  setState(() {
                    _currentScreen=Screens.fileManager;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.power_settings_new_rounded),
                enabled: !isWSA(device.id),
                title: Text("Power Controls ${isWSA(device.id)?"(N/A for WSA)":""}"),
                dense: false,
                onTap: (){
                  setState(() {
                    _currentScreen=Screens.powerControls;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.apps_rounded),
                title: const Text("Applications"),
                dense: false,
                onTap: (){
                  setState(() {
                    _currentScreen=Screens.packageManager;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline_rounded),
                title: const Text("Device Info"),
                dense: false,
                onTap: (){
                  setState(() {
                    _currentScreen=Screens.deviceInfo;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          );
        }),
      ),
      body: Column(
        children: [
          Expanded(
            child: Builder(
              builder: (context){
                switch(_currentScreen){
                  case Screens.fileManager: return FileManagerScreen(device: device);
                  case Screens.powerControls: return PowerControlsScreen(device: device);
                  case Screens.packageManager: return PackageManagerScreen(device: device);
                  case Screens.deviceInfo: return DeviceInfoScreen(device: device);
                  default: return Container();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
