import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ice_shield/data_layer/DataSources/local_database/Database.dart';
import 'package:ice_shield/initial_layer/Notification/NotificationInit.dart';
import 'package:provider/provider.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' hide Column;

class NotificationManagerPage extends StatelessWidget {
  const NotificationManagerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationService = context.watch<LocalNotificationService>();
    final isEnabled = notificationService.notificationsEnabled.watch(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Container(color: const Color(0xFF0A0E27).withOpacity(0.9)),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Notification Center",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TabBar(
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      dividerColor: Colors.transparent,
                      indicatorColor: Colors.blueAccent,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white.withOpacity(0.4),
                      tabs: const [
                        Tab(text: "Reminders"),
                        Tab(text: "Quotes Board"),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildRemindersTab(context, isEnabled),
                          _buildQuotesTab(context),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemindersTab(BuildContext context, bool isEnabled) {
    final notificationService = context.read<LocalNotificationService>();
    final customNotificationDao = context.watch<CustomNotificationDAO>();

    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        _buildGlassCard(
          child: SwitchListTile(
            value: isEnabled,
            onChanged: (val) =>
                notificationService.setNotificationsEnabled(val),
            title: const Text(
              "Allow Notifications",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              isEnabled
                  ? "You will receive updates about your stats and tasks."
                  : "Notifications are paused.",
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isEnabled
                    ? Colors.greenAccent.withOpacity(0.2)
                    : Colors.redAccent.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isEnabled
                    ? Icons.notifications_active_rounded
                    : Icons.notifications_off_rounded,
                color: isEnabled ? Colors.greenAccent : Colors.redAccent,
              ),
            ),
            activeColor: Colors.blueAccent,
          ),
        ),
        if (isEnabled) ...[
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Custom Reminders",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () => _showAddNotificationDialog(context),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text("Add New"),
                style: TextButton.styleFrom(foregroundColor: Colors.blueAccent),
              ),
            ],
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<CustomNotificationData>>(
            stream: customNotificationDao.watchAllNotifications(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(
                      "No custom reminders set.",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _buildCustomNotificationTile(
                    context,
                    snapshot.data![index],
                  );
                },
              );
            },
          ),
          const SizedBox(height: 32),
          const Text(
            "Quick Channels",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildChannelTile(
            "Daily Briefing",
            "Morning summary with quote of the day",
            Icons.wb_sunny_rounded,
            Colors.orangeAccent,
            onTest: () => notificationService.scheduleDailyNotification(),
          ),
          const SizedBox(height: 12),
          _buildChannelTile(
            "Quest Updates",
            "Task status and milestones",
            Icons.shield_rounded,
            Colors.purpleAccent,
          ),
          const SizedBox(height: 32),
        ],
      ],
    );
  }

  Widget _buildQuotesTab(BuildContext context) {
    final quoteDao = context.watch<QuoteDAO>();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Your Wisdom Board",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () => _showAddQuoteDialog(context),
              icon: const Icon(Icons.auto_awesome, size: 20),
              label: const Text("New Quote"),
              style: TextButton.styleFrom(foregroundColor: Colors.blueAccent),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: StreamBuilder<List<QuoteData>>(
            stream: quoteDao
                .watchActiveQuotes(), // Or watchAll if we want to show disabled too
            builder: (context, snapshot) {
              final quotes = snapshot.data ?? [];
              if (quotes.isEmpty &&
                  snapshot.connectionState == ConnectionState.active) {
                return Center(
                  child: Text(
                    "Your wisdom board is empty.\nAdd quotes to inspire your day.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withOpacity(0.4)),
                  ),
                );
              }

              return ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemCount: quotes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final quote = quotes[index];
                  return _buildQuoteTile(context, quote);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildChannelTile(
    String title,
    String subtitle,
    IconData icon,
    Color color, {
    VoidCallback? onTest,
  }) {
    return _buildGlassCard(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onTest != null)
              IconButton(
                icon: Icon(
                  Icons.notifications_active_rounded,
                  color: color.withOpacity(0.8),
                  size: 20,
                ),
                onPressed: onTest,
                tooltip: "Test Notification",
              ),
            Switch(
              value: true, // Mock individual channel toggle for now
              onChanged: (val) {},
              activeColor: color,
              trackColor: MaterialStateProperty.resolveWith(
                (states) => states.contains(MaterialState.selected)
                    ? color.withOpacity(0.5)
                    : Colors.white.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomNotificationTile(
    BuildContext context,
    CustomNotificationData notification,
  ) {
    final dao = context.read<CustomNotificationDAO>();
    final service = context.read<LocalNotificationService>();
    final formattedTime = DateFormat(
      'MMM dd, HH:mm',
    ).format(notification.scheduledTime);

    return _buildGlassCard(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          notification.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.content,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 14,
                  color: Colors.blueAccent.withOpacity(0.8),
                ),
                const SizedBox(width: 4),
                Text(
                  formattedTime,
                  style: TextStyle(color: Colors.blueAccent, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: notification.isEnabled,
              onChanged: (val) async {
                final updated = notification.copyWith(isEnabled: val);
                await dao.updateNotification(updated);
                await service.syncAllNotifications();
              },
              activeColor: Colors.blueAccent,
            ),
            IconButton(
              icon: Icon(
                Icons.delete_outline_rounded,
                color: Colors.redAccent.withOpacity(0.8),
              ),
              onPressed: () async {
                await dao.deleteNotification(notification.notificationID);
                await service.syncAllNotifications();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddNotificationDialog(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(minutes: 5));
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(selectedDate);
    String repeatFrequency = 'once';
    List<int> repeatDays = [];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF161B33),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                "New Reminder",
                style: TextStyle(color: Colors.white),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Title",
                        labelStyle: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: contentController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Content",
                        labelStyle: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    DropdownButtonFormField<String>(
                      dropdownColor: const Color(0xFF161B33),
                      value: repeatFrequency,
                      items: ['once', 'daily', 'weekly'].map((f) {
                        return DropdownMenuItem(
                          value: f,
                          child: Text(
                            f.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) =>
                          setDialogState(() => repeatFrequency = val!),
                      decoration: InputDecoration(
                        labelText: "Repeat",
                        labelStyle: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ),
                    if (repeatFrequency == 'weekly') ...[
                      const SizedBox(height: 16),
                      const Text(
                        "Select Days",
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      _buildDayPicker(
                        repeatDays,
                        (days) => setDialogState(() => repeatDays = days),
                      ),
                    ],
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        "Time: ${selectedTime.format(context)}",
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: const Icon(
                        Icons.access_time_rounded,
                        color: Colors.blueAccent,
                      ),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                        );
                        if (time != null)
                          setDialogState(() => selectedTime = time);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isEmpty) return;
                    final now = DateTime.now();
                    final scheduled = DateTime(
                      now.year,
                      now.month,
                      now.day,
                      selectedTime.hour,
                      selectedTime.minute,
                    );

                    final dao = context.read<CustomNotificationDAO>();
                    final service = context.read<LocalNotificationService>();

                    dao
                        .insertNotification(
                          CustomNotificationsTableCompanion.insert(
                            title: titleController.text,
                            content: contentController.text,
                            scheduledTime: scheduled,
                            repeatFrequency: Value(repeatFrequency),
                            repeatDays: Value(
                              repeatDays.isEmpty ? null : repeatDays.join(','),
                            ),
                          ),
                        )
                        .then((id) {
                          // Trigger fresh sync
                          service.syncAllNotifications();
                          Navigator.pop(context);
                        });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                  ),
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDayPicker(
    List<int> selectedDays,
    Function(List<int>) onChanged,
  ) {
    final days = ["M", "T", "W", "T", "F", "S", "S"];
    return Wrap(
      spacing: 6,
      children: List.generate(7, (index) {
        final dayNum = index + 1; // 1=Mon, 7=Sun
        final isSelected = selectedDays.contains(dayNum);
        return InkWell(
          onTap: () {
            final newDays = List<int>.from(selectedDays);
            if (isSelected) {
              newDays.remove(dayNum);
            } else {
              newDays.add(dayNum);
            }
            onChanged(newDays);
          },
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.blueAccent
                  : Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              days[index],
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }),
    );
  }

  void _showAddQuoteDialog(BuildContext context) {
    final contentController = TextEditingController();
    final authorController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF161B33),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Inspirational Quote",
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: contentController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: _dialogInputDecoration("Quote Contents"),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: authorController,
                style: const TextStyle(color: Colors.white),
                decoration: _dialogInputDecoration("Author"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (contentController.text.isEmpty) return;
                final dao = context.read<QuoteDAO>();
                dao.insertQuote(
                  QuotesTableCompanion.insert(
                    content: contentController.text,
                    author: Value(
                      authorController.text.isEmpty
                          ? null
                          : authorController.text,
                    ),
                  ),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuoteTile(BuildContext context, QuoteData quote) {
    final dao = context.read<QuoteDAO>();
    return _buildGlassCard(
      child: ListTile(
        title: Text(
          "\"${quote.content}\"",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontStyle: FontStyle.italic,
          ),
        ),
        subtitle: quote.author != null
            ? Text(
                "- ${quote.author}",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 13,
                ),
              )
            : null,
        trailing: IconButton(
          icon: const Icon(
            Icons.delete_outline,
            color: Colors.redAccent,
            size: 20,
          ),
          onPressed: () => dao.deleteQuote(quote.quoteID),
        ),
      ),
    );
  }

  InputDecoration _dialogInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.blueAccent),
      ),
    );
  }
}
