import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // for PlatformException
import 'package:flutter_sim_data/sim_data.dart';
import 'package:flutter_sim_data/sim_data_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _simDataPlugin = SimData();

  /// Sends an SMS and surfaces the outcome as a SnackBar.
  /// Shared by the iOS and Android (per-SIM) buttons.
  Future<void> _trySendSms({
    required String phoneNumber,
    required String message,
    required int subId,
    int timeoutSeconds = 30, // iOS only; Android ignores it. 0 disables.
  }) async {
    try {
      final ok = await _simDataPlugin.sendSMS(
        phoneNumber: phoneNumber,
        message: message,
        subId: subId,
        timeoutSeconds: timeoutSeconds,
      );
      if (ok == true) {
        _showSnack('SMS committed');
      }
    } on PlatformException catch (e) {
      final msg = switch (e.code) {
        'CANCELLED' => 'User cancelled',
        'TIMEOUT' => 'Timed out waiting for user to send',
        'SEND_FAILED' => 'Send failed: ${e.message}',
        'UNAVAILABLE' => 'This device cannot send SMS',
        'IN_PROGRESS' => 'A message screen is already open',
        'INVALID_ARGS' => 'Bad arguments: ${e.message}',
        'NO_VC' => 'No screen available to show the composer',
        'PERMISSION_DENIED' => 'SMS permission denied',
        _ => 'Unexpected error [${e.code}]: ${e.message}',
      };
      _showSnack(msg);
    }
  }

  void _showSnack(String text) {
    if (!mounted) return; // sendSMS is a long await; widget may be gone
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SIM Data Example'),
      ),
      body: Platform.isIOS
          ? Center(
        child: ElevatedButton(
          onPressed: () => _trySendSms(
            phoneNumber: "", // Enter phone number with country code
            message: "This is a test message",
            subId: 0, // This value is not used for iOS
          ),
          child: const Text("Send SMS using this SIM"),
        ),
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
                    onPressed: () => _trySendSms(
                      phoneNumber:
                      "", // Enter phone number with country code
                      message: "This is a test message",
                      subId: e.subscriptionId,
                    ),
                    child: const Text("Send SMS using this SIM"),
                  ),
                  const Divider(),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }
}