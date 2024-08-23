import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sim_data/sim_data.dart';
import 'package:flutter_sim_data/sim_data_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _simDataPlugin = SimData();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('SIM Data Example'),
          ),
          body: Platform.isIOS
              ? Center(
                  child: ElevatedButton(
                      onPressed: () {
                        _simDataPlugin.sendSMS(
                            phoneNumber:
                                "", //Enter phone number with country code
                            message: "This is a test message",
                            subId: 0 //This value is not used for iOS
                            );
                      },
                      child: const Text("Send SMS using this SIM")),
                )
              : FutureBuilder(
                  future: _simDataPlugin.getSimData(),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<SimDataModel>> snapshot) {
                    if (snapshot.data == null) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return ListView(
                      children: snapshot.data!.map((e) {
                        return Column(
                          children: [
                            ListTile(
                              title: const Text("Carrier Name"),
                              trailing: Text(e.carrierName),
                            ),
                            ListTile(
                              title: const Text("Is ESIM"),
                              trailing: Text("${e.isESIM}"),
                            ),
                            ListTile(
                              title: const Text("Subscription ID"),
                              trailing: Text("${e.subscriptionId}"),
                            ),
                            ListTile(
                              title: const Text("SIM Slot Index"),
                              trailing: Text("${e.simSlotIndex}"),
                            ),
                            ListTile(
                              title: const Text("Card ID"),
                              trailing: Text("${e.cardId}"),
                            ),
                            ListTile(
                              title: const Text("Phone Number"),
                              trailing: Text(e.phoneNumber),
                            ),
                            ListTile(
                              title: const Text("Display Name"),
                              trailing: Text(e.displayName),
                            ),
                            ListTile(
                              title: const Text("Country Code"),
                              trailing: Text(e.countryCode),
                            ),
                            ElevatedButton(
                                onPressed: () {
                                  _simDataPlugin.sendSMS(
                                      phoneNumber:
                                          "", //Enter phone number with country code
                                      message: "This is a test message",
                                      subId: e.subscriptionId);
                                },
                                child: const Text("Send SMS using this SIM")),
                            const Divider()
                          ],
                        );
                      }).toList(),
                    );
                  },
                )),
    );
  }
}
