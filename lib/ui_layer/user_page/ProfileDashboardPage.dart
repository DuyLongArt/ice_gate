import 'package:flutter/material.dart';
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
       
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Header
              // ProfileHeader(profile: profile),
              const SizedBox(height: 24),

              // Section Title
              Text(
                '4 life elements',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

           

              const SizedBox(height: 32),

              // --- SECTION: ANALYSIS ---
              Text(
                'Analysis',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildAnalysisSection(context, colorScheme),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildAnalysisSection(BuildContext context, ColorScheme colorScheme) {
    return Column(
      children: [
        _buildAnalysisCard(
          context,
          title: "Productivity Trend",
          subtitle: "+15% from last week",
          icon: Icons.trending_up_rounded,
          color: Colors.green,
          content: Container(
            height: 100,
            alignment: Alignment.center,
            child: Text(
              "Chart Placeholder",
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildAnalysisCard(
          context,
          title: "Focus Distribution",
          subtitle: "Mostly Deep Work",
          icon: Icons.pie_chart_rounded,
          color: Colors.blue,
          content: Container(
            height: 100,
            alignment: Alignment.center,
            child: Text(
              "Pie Chart Placeholder",
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget content,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
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
          if (tx.amount > 0) {
            income += tx.amount;
          } else {
            expense += tx.amount.abs();
          }
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
}
