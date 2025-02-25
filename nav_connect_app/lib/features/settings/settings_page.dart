import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sist_nav_connect/utils/constants.dart';

class SettingsPage extends StatefulWidget {
  static const routename = "/settingspage";
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // String dropdownvalue = 'http://98.130.15.185:8000';
  String dropdownvalue = 'http://$baseurl';

  // List of items in our dropdown menu
  var items = [
    "http://$baseurl",
    "https://probable-chainsaw-94wwxrw4xqr2p46v-8000.app.github.dev",
  ];

  SharedPreferences? prefs;
  Future<void> initiSharedPrefernces() async {
    prefs = await SharedPreferences.getInstance();
    if(prefs!.getString("httpUrl") != null){
      dropdownvalue = prefs!.getString("httpUrl")!;
      print("is not null .............");
    }
    setState(() {
      dropdownvalue = dropdownvalue;
    });
  }

  @override
  void initState() {
    initiSharedPrefernces();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("settings"),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Current URL"),
          Container(
            // color: Colors.amber,
            alignment: Alignment.center,
            // width: MediaQuery.of(context).size.width / 1.2,
            child: DropdownButton(
              value: dropdownvalue,
              icon: const Icon(Icons.keyboard_arrow_down),
              items: items.map((String items) {
                return DropdownMenuItem(
                  value: items,
                  child: Container(
                    width: MediaQuery.of(context).size.width / 1.4,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        items,
                        style: const TextStyle(
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) async {
                setState(() {
                  dropdownvalue = newValue!;
                });
                if (prefs == null) await initiSharedPrefernces();
                // if (newValue == "http://98.130.15.185:8000") {
                //   prefs!.setString("httpUrl", "http://98.130.15.185:8000");
                //   prefs!.setString("webUrl", "ws://98.130.15.185:8000");
                // } else {
                if (newValue == "http://$baseurl") {
                  prefs!.setString("httpUrl", "http://$baseurl");
                  prefs!.setString("webUrl", "ws://$baseurl");
                } else {
                  prefs!.setString("httpUrl",
                      "https://probable-chainsaw-94wwxrw4xqr2p46v-8000.app.github.dev");
                  prefs!.setString("webUrl",
                      "wss://probable-chainsaw-94wwxrw4xqr2p46v-8000.app.github.dev");
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
