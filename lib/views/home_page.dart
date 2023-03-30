import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../controllers/reminder_controller.dart';
import '../controllers/theme_contoller.dart';
import '../helpers/db_helper.dart';
import '../helpers/noti_helper.dart';
import 'components/add_reminer.dart';
import 'components/edit.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ThemeController themeController = Get.put(ThemeController());

  ReminderController reminderController = Get.put(ReminderController());

  @override
  void initState() {
    super.initState();
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('mipmap/launcher_icon');
    var initializationSettingsIOs = const DarwinInitializationSettings();
    var initSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOs);

    NotificationHelper.flutterLocalNotificationsPlugin.initialize(initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Reminder"),
        actions: [
          Obx(
            () => IconButton(
              onPressed: () {
                themeController.changeTheme();
              },
              icon: Icon((themeController.isDark.value)
                  ? Icons.light_mode
                  : Icons.dark_mode),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey,
        onPressed: () {
          addReminder(context);
        },
        child: const Icon(Icons.add),
      ),
      body: Obx(
        () => SingleChildScrollView(
          child: Column(
            children: reminderController.reminders
                .map(
                  (e) => Container(
                    padding: const EdgeInsets.all(30),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(55),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            e.title,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        SizedBox(height: 5),
                        Divider(endIndent: 10, indent: 10),
                        SizedBox(height: 5),
                        Text("${e.description}"),
                        Row(
                          children: [
                            Text(
                                "Time : ${(e.hour > 12) ? e.hour - 12 : e.hour} : ${e.minute}  ${(e.hour > 12) ? "PM" : "AM"}",
                                style: Theme.of(context).textTheme.titleMedium),
                            const Spacer(),
                            IconButton(
                              onPressed: () {
                                editReminder(reminder: e, context: context);
                              },
                              icon: const Icon(Icons.edit),
                            ),
                            IconButton(
                              onPressed: () {
                                Get.dialog(
                                  AlertDialog(
                                    title: const Text("Delete reminder"),
                                    content: const Text(
                                      "Confirm ?",
                                    ),
                                    actions: [
                                      OutlinedButton(
                                        onPressed: () {
                                          Get.back();
                                        },
                                        child: const Text("Cancel"),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          DBHelper.dbHelper
                                              .deleteReminder(id: e.id);
                                          Get.back();
                                        },
                                        child: const Text("Delete"),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              icon: const Icon(Icons.delete),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
