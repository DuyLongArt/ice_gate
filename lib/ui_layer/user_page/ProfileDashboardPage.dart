import 'package:flutter/material.dart';
import 'package:ice_shield/initial_layer/Notification/NotificationInit.dart';
import 'package:ice_shield/data_layer/DomainData/Plugin/GPSTracker/PersonProfile.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:ice_shield/ui_layer/user_page/main_deparment/ProfileHeader.dart';
import 'package:ice_shield/ui_layer/user_page/main_deparment/HealthSectionCard.dart';
import 'package:ice_shield/ui_layer/user_page/main_deparment/FinanceSectionCard.dart';
import 'package:ice_shield/ui_layer/user_page/main_deparment/SocialSectionCard.dart';
import 'package:ice_shield/ui_layer/user_page/main_deparment/ProjectSectionCard.dart';
import 'package:go_router/go_router.dart';
import 'package:ice_shield/ui_layer/home_page/MainButton.dart';
import 'package:ice_shield/orchestration_layer/ReactiveBlock/User/AuthBlock.dart';
import 'package:provider/provider.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:ice_shield/orchestration_layer/ReactiveBlock/User/PersonBlock.dart';
import 'package:ice_shield/orchestration_layer/ReactiveBlock/User/ObjectDatabaseBlock.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:ice_shield/data_layer/DataSources/local_database/Database.dart';

class ProfileDashboardPage extends StatelessWidget {
  const ProfileDashboardPage({super.key});

  static Widget icon(BuildContext context, {double? size}) {
    return MainButton(
      type: "profile",
      destination: "/profile",
      size: size,
      icon: Icons.edit,
      mainFunction: () async {
        final database = context.read<AppDatabase>();
        final financeDAO = database.financeDAO;

        // Seed Finance Data
        // 1. Create Main Account
        await financeDAO.createAccount(
          FinancialAccountsTableCompanion(
            personID: const Value(1), // Assuming ID 1 for now
            accountName: const Value('Main Account'),
            balance: const Value(5420.00),
            currency: const Value(CurrencyType.USD),
          ),
        );

        final now = DateTime.now();
        // 2. Add Transactions for current month
        await financeDAO.insertTransaction(
          TransactionsTableCompanion(
            personID: const Value(1),
            type: const Value('income'),
            category: const Value('Salary'),
            amount: const Value(6500.00),
            transactionDate: Value(now),
            description: const Value('Monthly Salary'),
          ),
        );

        await financeDAO.insertTransaction(
          TransactionsTableCompanion(
            personID: const Value(1),
            type: const Value('expense'),
            category: const Value('Rent'),
            amount: const Value(2100.00),
            transactionDate: Value(now),
            description: const Value('Monthly Rent'),
          ),
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Finance Data Seeded!'),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Watch((context) {
      final authBlock = context.watch<AuthBlock>();
      final personBlock = context.watch<PersonBlock>();
      final objectBlock = context.watch<ObjectDatabaseBlock>();

      final info = personBlock.information.watch(context);
      final objectResource = objectBlock.userObjectResource.watch(context);

      final displayName = info.profiles.firstName.isNotEmpty
          ? "${info.profiles.firstName} ${info.profiles.lastName}"
          : authBlock.username.value ?? 'DuyLong Art';

      // Use actual data from signals
      final profile = PersonProfile(
        id: info.profiles.id?.toString() ?? '1',
        name: displayName,
        email:
            "@${info.profiles.alias.split('-').first}", // Using alias as "email/handle" placeholder
        avatarUrl: objectResource.avatarImage.isNotEmpty
            ? objectResource.avatarImage
            : info.profiles.profileImageUrl,
        health: const HealthMetrics(
          todaySteps: 10234,
          caloriesConsumed: 1800,
          caloriesBurned: 520,
          sleepHours: 7.5,
          heartRate: 72,
        ),
        finance: const FinanceMetrics(
          balance: 5420.00,
          monthlyIncome: 6500.00,
          monthlyExpenses: 2100.00,
          savingsRate: 0.35,
        ),
        social: SocialMetrics(
          friendsCount: info.profiles.friends,
          unreadMessages: 5,
          upcomingEvents: 3,
        ),
        projects: const ProjectMetrics(
          activeProjects: 4,
          completedProjects: 12,
          tasksToday: 7,
        ),
      );

      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: // Wrap your Text in AutoSizeText
          AutoSizeText(
            'Life Dashboard',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            minFontSize: 12, // Prevents it from becoming unreadable
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          centerTitle: true,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Header
              ProfileHeader(profile: profile),

              const SizedBox(height: 24),

              // Section Title
              Text(
                'Life Dashboard',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              // 2x2 Grid of Section Cards
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
                children: [
                  HealthSectionCard(
                    metrics: profile.health,
                    onTap: () => context.go('/health'),
                  ),
                  StreamBuilder<FinanceMetrics>(
                    stream: _getFinanceStream(
                      context,
                      int.tryParse(info.profiles.id?.toString() ?? '1') ?? 1,
                    ),
                    builder: (context, snapshot) {
                      final metrics =
                          snapshot.data ??
                          const FinanceMetrics(
                            balance: 0,
                            monthlyIncome: 0,
                            monthlyExpenses: 0,
                            savingsRate: 0,
                          );
                      return FinanceSectionCard(
                        metrics: metrics,
                        onTap: () => context.go('/finance'),
                      );
                    },
                  ),
                  SocialSectionCard(
                    metrics: profile.social,
                    onTap: () => context.go('/social'),
                  ),
                  ProjectSectionCard(
                    metrics: profile.projects,
                    onTap: () => context.go('/projects'),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // --- SECTION: SETTINGS ---
              Text(
                'Settings',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildNotificationToggle(context, colorScheme),
            ],
          ),
        ),
      );
    });
  }

  Stream<FinanceMetrics> _getFinanceStream(BuildContext context, int personID) {
    final database = context.read<AppDatabase>();
    final financeDAO = database.financeDAO;

    return financeDAO.watchAccounts(personID).asyncMap((accounts) async {
      double balance = 0;
      for (var acc in accounts) {
        balance += acc.balance;
      }

      final now = DateTime.now();
      // Fetch transactions for current month to calc Income/Expense
      final transactions = await financeDAO
          .watchMonthlyTransactions(personID, now.year, now.month)
          .first;

      double income = 0;
      double expense = 0;

      for (var tx in transactions) {
        // Assuming 'type' column stores 'income'/'expense' or amount sign indicates it
        // Or check TransactionType enum if available.
        // Based on typical schema:
        if (tx.type == 'income') {
          income += tx.amount;
        } else if (tx.type == 'expense') {
          expense += tx.amount;
        } else {
          // Fallback based on sign if type is ambiguous
          if (tx.amount > 0)
            income += tx.amount;
          else
            expense += tx.amount.abs();
        }
      }

      double savingsRate = 0;
      if (income > 0) {
        savingsRate = (income - expense) / income;
      }

      return FinanceMetrics(
        balance: balance,
        monthlyIncome: income,
        monthlyExpenses: expense,
        savingsRate: savingsRate,
      );
    });
  }

  Widget _buildNotificationToggle(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    final notificationService = context.read<LocalNotificationService>();
    return Watch((context) {
      final enabled = notificationService.notificationsEnabled.value;
      return Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
        ),
        child: SwitchListTile.adaptive(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 4,
          ),
          secondary: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: enabled
                  ? Colors.amber.withOpacity(0.15)
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              enabled
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_off_rounded,
              color: enabled ? Colors.amber : colorScheme.onSurfaceVariant,
              size: 24,
            ),
          ),
          title: Text(
            'Notifications',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: colorScheme.onSurface,
            ),
          ),
          subtitle: Text(
            enabled ? 'Daily 7 AM briefing active' : 'All notifications off',
            style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
          ),
          value: enabled,
          activeColor: Colors.amber,
          onChanged: (value) async {
            await notificationService.setNotificationsEnabled(value);
          },
        ),
      );
    });
  }
}
