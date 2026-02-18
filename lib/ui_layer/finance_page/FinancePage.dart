import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ice_shield/data_layer/DataSources/local_database/Database.dart';
import 'package:ice_shield/ui_layer/home_page/MainButton.dart';
import 'package:ice_shield/ui_layer/finance_page/models/FinanceAsset.dart';
import 'package:ice_shield/ui_layer/finance_page/services/FinanceService.dart';
import 'package:ice_shield/ui_layer/ReusableWidget/SwipeablePage.dart';
import 'package:ice_shield/orchestration_layer/ReactiveBlock/User/FinanceBlock.dart';
import 'package:go_router/go_router.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:provider/provider.dart';
import 'package:signals/signals_flutter.dart';

class FinancePage extends StatefulWidget {
  const FinancePage({super.key});

  static Widget icon(BuildContext context, {double? size}) {
    return MainButton(
      type: "finance",
      destination: "/finance",
      size: size,
      icon: Icons.add,
      mainFunction: () {
        _showAddTransactionDialog(context);
      },
      subButtons: [
        SubButton(
          icon: Icons.savings_rounded,
          backgroundColor: Colors.green,
          label: 'Save',
          tooltip: 'Add Savings',
          onPressed: () => _showAddTransactionDialog(context, type: 'savings'),
        ),
        SubButton(
          icon: Icons.shopping_cart_rounded,
          backgroundColor: Colors.red,
          label: 'Spend',
          tooltip: 'Add Expense',
          onPressed: () => _showAddTransactionDialog(context, type: 'expense'),
        ),
        SubButton(
          icon: Icons.attach_money_rounded,
          backgroundColor: Colors.blue,
          label: 'Income',
          tooltip: 'Add Income',
          onPressed: () => _showAddTransactionDialog(context, type: 'income'),
        ),
      ],
    );
  }

  static void _showAddTransactionDialog(BuildContext context, {String? type}) {
    final financeBlock = context.read<FinanceBlock>();
    final amountController = TextEditingController();
    final descController = TextEditingController();
    String selectedType = type ?? 'expense';
    String selectedCategory = 'general';

    final categories = {
      'expense': [
        'food',
        'coffee',
        'transport',
        'software',
        'shopping',
        'bills',
        'rent',
        'subscriptions',
        'entertainment',
        'health',
        'education',
        'investing',
        'general',
      ],
      'income': [
        'salary',
        'freelance',
        'investment',
        'gift',
        'bonus',
        'general',
      ],
      'savings': ['emergency', 'goal', 'retirement', 'investment', 'general'],
    };

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: Text(
              type != null
                  ? 'Add ${type[0].toUpperCase()}${type.substring(1)}'
                  : 'Add Transaction',
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (type == null)
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'expense', label: Text('Expense')),
                        ButtonSegment(value: 'income', label: Text('Income')),
                        ButtonSegment(value: 'savings', label: Text('Savings')),
                      ],
                      selected: {selectedType},
                      onSelectionChanged: (val) {
                        setDialogState(() {
                          selectedType = val.first;
                          selectedCategory = 'general';
                        });
                      },
                    ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      prefixText: '\$ ',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: (categories[selectedType] ?? ['general'])
                        .map(
                          (c) => DropdownMenuItem(
                            value: c,
                            child: Text(c[0].toUpperCase() + c.substring(1)),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setDialogState(
                      () => selectedCategory = val ?? 'general',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  final amount = double.tryParse(amountController.text);
                  if (amount == null || amount <= 0) return;
                  await financeBlock.addTransaction(
                    category: selectedCategory,
                    type: selectedType,
                    amount: amount,
                    description: descController.text.isEmpty
                        ? null
                        : descController.text,
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> {
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '\$');
  late final List<FinanceAsset> _stocks = [];
  final List<FinanceAsset> _coins = FinanceService.getCoins();
  final Map<int, String> _projectNamesCache = {};

  Future<void> _initWatchlist() async {
    const List<String> myTickers = ['FPT', 'VNM', 'HPG', 'SSI'];

    for (String ticker in myTickers) {
      final asset = await FinanceService.fetchVnStock(ticker);
      if (mounted) {
        setState(() {
          _stocks.add(asset);
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _initWatchlist();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final financeBlock = context.read<FinanceBlock>();

    return SwipeablePage(
      onSwipe: () => Navigator.maybePop(context),
      direction: SwipeablePageDirection.leftToRight,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 0,
              floating: true,
              pinned: true,
              elevation: 0,
              backgroundColor: colorScheme.surface,
              title: SwipeablePage(
                onSwipe: () => context.pop(),
                child: const AutoSizeText(
                  'Finance',
                  style: TextStyle(fontWeight: FontWeight.w900),
                  maxLines: 1,
                ),
              ),
              centerTitle: false,
            ),

            // Portfolio Summary
            SliverToBoxAdapter(
              child: Watch((context) {
                return _buildPortfolioHeader(context, financeBlock);
              }),
            ),

            // Savings & Spending Overview
            SliverToBoxAdapter(
              child: Watch((context) {
                return _buildSavingsSpendingCards(context, financeBlock);
              }),
            ),

            // Monthly Spending Breakdown
            SliverToBoxAdapter(
              child: Watch((context) {
                return _buildMonthlyBreakdown(context, financeBlock);
              }),
            ),

            // Recent Transactions
            _buildSectionHeader(
              context,
              'Recent Transactions',
              Icons.receipt_long_rounded,
            ),
            Watch((context) {
              final txns = financeBlock.transactions.value;
              if (txns.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withOpacity(
                          0.3,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.receipt_long_rounded,
                            color: colorScheme.onSurface.withOpacity(0.3),
                            size: 40,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No transactions yet',
                            style: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap + to add your first transaction',
                            style: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.3),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              final recentTxns = txns.take(10).toList();
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildTransactionItem(
                      context,
                      recentTxns[index],
                      financeBlock,
                    ),
                    childCount: recentTxns.length,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPortfolioHeader(BuildContext context, FinanceBlock block) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final totalBalance = block.totalBalance.value;

    // For now, keep change/percent static or calculated if possible.
    // Calculating "Change" requires history which we don't have easily yet.
    // I'll leave change as dummy or 0 for now to avoid errors.
    final totalChange = 0.0;
    final changePercent = 0.0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TOTAL NET WORTH', // Changed from Total Balance to be more accurate
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onPrimary.withOpacity(0.8),
              letterSpacing: 1.2,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _currencyFormat.format(totalBalance),
            style: textTheme.headlineMedium?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.onPrimary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_upward_rounded,
                  color: Colors.greenAccent[400],
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${_currencyFormat.format(totalChange)} ($changePercent%)',
                  style: TextStyle(
                    color: Colors.greenAccent[400],
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsSpendingCards(
    BuildContext context,
    FinanceBlock financeBlock,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final savings = financeBlock.totalSavings.value;
    final spending = financeBlock.monthlySpending.value;
    final income = financeBlock.monthlyIncome.value;
    final monthName = DateFormat.MMMM().format(DateTime.now());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMiniCard(
                  context,
                  title: 'Total Savings',
                  amount: savings,
                  icon: Icons.savings_rounded,
                  color: Colors.green,
                  gradient: [Colors.green.shade600, Colors.green.shade400],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMiniCard(
                  context,
                  title: '$monthName Spending',
                  amount: spending,
                  icon: Icons.shopping_cart_rounded,
                  color: Colors.redAccent,
                  gradient: [Colors.red.shade600, Colors.red.shade400],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildMiniCard(
            context,
            title: '$monthName Income',
            amount: income,
            icon: Icons.trending_up_rounded,
            color: Colors.blue,
            gradient: [Colors.blue.shade600, Colors.blue.shade400],
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMiniCard(
    BuildContext context, {
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
    required List<Color> gradient,
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _currencyFormat.format(amount),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyBreakdown(
    BuildContext context,
    FinanceBlock financeBlock,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final categories = financeBlock.spendingByCategory.value;
    final totalSpending = financeBlock.monthlySpending.value;
    final monthName = DateFormat.MMMM().format(DateTime.now());

    if (categories.isEmpty) return const SizedBox.shrink();

    final sortedCategories = categories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final categoryIcons = {
      'food': Icons.restaurant_rounded,
      'coffee': Icons.coffee_rounded,
      'transport': Icons.directions_car_rounded,
      'software': Icons.code_rounded,
      'shopping': Icons.shopping_bag_rounded,
      'bills': Icons.receipt_rounded,
      'rent': Icons.home_rounded,
      'subscriptions': Icons.subscriptions_rounded,
      'entertainment': Icons.movie_rounded,
      'health': Icons.medical_services_rounded,
      'education': Icons.school_rounded,
      'investing': Icons.trending_up_rounded,
      'crypto': Icons.currency_bitcoin_rounded,
      'stock': Icons.show_chart_rounded,
      'real_estate': Icons.home_work_rounded,
      'salary': Icons.payments_rounded,
      'bonus': Icons.card_giftcard_rounded,
      'gift': Icons.redeem_rounded,
      'general': Icons.category_rounded,
    };

    final categoryColors = {
      'food': Colors.orange,
      'coffee': Colors.brown,
      'transport': Colors.blue,
      'software': Colors.indigo,
      'shopping': Colors.pink,
      'bills': Colors.teal,
      'rent': Colors.deepOrange,
      'subscriptions': Colors.deepPurple,
      'entertainment': Colors.purple,
      'health': Colors.red,
      'education': Colors.cyan,
      'investing': Colors.indigo,
      'crypto': Colors.amber,
      'stock': Colors.lightGreen,
      'real_estate': Colors.brown,
      'salary': Colors.green,
      'bonus': Colors.orangeAccent,
      'gift': Colors.pinkAccent,
      'general': Colors.grey,
    };

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: colorScheme.outlineVariant.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$monthName Breakdown',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            ...sortedCategories.map((entry) {
              final percentage = totalSpending > 0
                  ? entry.value / totalSpending
                  : 0.0;
              final catColor = categoryColors[entry.key] ?? colorScheme.primary;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: catColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        categoryIcons[entry.key] ?? Icons.category_rounded,
                        color: catColor,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                entry.key[0].toUpperCase() +
                                    entry.key.substring(1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                _currencyFormat.format(entry.value),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: percentage,
                              backgroundColor: catColor.withOpacity(0.1),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                catColor,
                              ),
                              minHeight: 4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    TransactionData txn,
    FinanceBlock financeBlock,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isExpense = txn.type == 'expense' || txn.type == 'investment';
    final isSavings = txn.type == 'savings';
    final color = isExpense
        ? Colors.red
        : isSavings
        ? Colors.green
        : Colors.blue;
    final prefix = isExpense ? '-' : '+';

    final typeIcons = {
      'expense': Icons.arrow_downward_rounded,
      'income': Icons.arrow_upward_rounded,
      'savings': Icons.savings_rounded,
    };

    return Dismissible(
      key: Key('txn_${txn.transactionID}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      onDismissed: (_) => financeBlock.deleteTransaction(txn.transactionID),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outlineVariant.withOpacity(0.4),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                typeIcons[txn.type] ?? Icons.swap_horiz,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    txn.description ??
                        (txn.category[0].toUpperCase() +
                            txn.category.substring(1)),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (txn.projectID != null)
                        _buildProjectTag(context, txn.projectID!),
                      Text(
                        '${txn.category[0].toUpperCase()}${txn.category.substring(1)} • ${DateFormat.MMMd().format(txn.transactionDate)}',
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.5),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              '$prefix${_currencyFormat.format(txn.amount)}',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectTag(BuildContext context, int projectID) {
    if (_projectNamesCache.containsKey(projectID)) {
      return _renderProjectTag(context, _projectNamesCache[projectID]!);
    }

    return FutureBuilder<ProjectData?>(
      future: context.read<AppDatabase>().projectsDAO.getProjectById(projectID),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          _projectNamesCache[projectID] = snapshot.data!.name;
          return _renderProjectTag(context, snapshot.data!.name);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _renderProjectTag(BuildContext context, String name) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 4.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        decoration: BoxDecoration(
          color: colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          name.toUpperCase(),
          style: TextStyle(
            color: colorScheme.primary,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
        child: Row(
          children: [
            Icon(icon, size: 20, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {},
              child: const Text(
                'See All',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetItem(BuildContext context, FinanceAsset asset) {
    final colorScheme = Theme.of(context).colorScheme;
    final isPositive = asset.change24h >= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: asset.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(asset.icon, color: asset.color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asset.symbol,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                Text(
                  asset.name,
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _currencyFormat.format(asset.price),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              Text(
                '${isPositive ? '+' : ''}${asset.change24h}%',
                style: TextStyle(
                  color: isPositive ? Colors.green : Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
