import 'package:flutter/material.dart';
import 'package:ice_shield/data_layer/DataSources/local_database/Database.dart';
import 'package:ice_shield/initial_layer/CoreLogics/GamificationService.dart';
import 'package:ice_shield/initial_layer/CoreLogics/PowerPoint/Const.dart';
import 'package:ice_shield/ui_layer/ReusableWidget/SwipeablePage.dart';
import 'package:ice_shield/ui_layer/home_page/MainButton.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:ice_shield/data_layer/Protocol/User/PersonProtocol.dart';
import 'package:ice_shield/orchestration_layer/IDGen.dart';

class SocialPage extends StatefulWidget {
  const SocialPage({super.key});

  static Widget icon(BuildContext context, {double? size}) {
    return MainButton(
      type: "social",
      destination: "/social",
      size: size,
      icon: Icons.people,
      mainFunction: () {
        context.go('/social');
      },
      subButtons: [
        SubButton(
          icon: Icons.favorite,
          backgroundColor: Colors.pink,
          onPressed: () {}, // Dating shortcut?
        ),
        SubButton(
          icon: Icons.family_restroom,
          backgroundColor: Colors.orange,
          onPressed: () {}, // Family shortcut?
        ),
      ],
    );
  }

  @override
  State<SocialPage> createState() => _SocialPageState();
}

class _SocialPageState extends State<SocialPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _points = 0;
  int _level = 0;
  double _progress = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadGamificationData();
  }

  Future<void> _loadGamificationData() async {
    final healthMetricsDao = context.read<HealthMetricsDAO>();
    final healthMealDao = context.read<HealthMealDAO>();
    final personDao = context.read<PersonManagementDAO>();
    final scoreDao = context.read<ScoreDAO>();
    final financeDao = context.read<FinanceDAO>();
    final service = GamificationService(
      healthMetricsDao,
      healthMealDao,
      personDao,
      financeDao,
    );

    // Assume current user ID is 1
    final totalPoints = await service.calculateTotalPoints(1);
    final level = GamificationService.getLevel(totalPoints);
    final progress = GamificationService.getProgressToNextLevel(totalPoints);

    // Calculate social-specific points and push to global score
    try {
      final contacts = await personDao.getAllContacts().first;
      int totalAffection = 0;
      for (var c in contacts) {
        totalAffection += c.affection;
      }
      // Social score = contacts * CONTACT_POINTS + (affection / AFFECTION_PER_UNIT) * AFFECTION_POINTS
      final socialScore =
          (contacts.length * CONTACT_POINTS).toDouble() +
          ((totalAffection ~/ AFFECTION_PER_UNIT) * AFFECTION_POINTS)
              .toDouble();
      await scoreDao.updateSocialScore(1, socialScore);
    } catch (e) {
      print('Error updating social score: $e');
    }

    // Calculate finance-specific points and push to global score
    try {
      final accounts = await financeDao.watchAccounts(1).first;
      final assets = await financeDao.watchAssets(1).first;

      double totalNetWorth = 0;
      for (var acc in accounts) {
        totalNetWorth += acc.balance;
      }
      for (var asset in assets) {
        totalNetWorth += (asset.currentEstimatedValue ?? 0.0);
      }

      final financeScore =
          ((totalNetWorth / FINANCE_SAVINGS_MILESTONE) *
          FINANCE_SAVINGS_POINTS);
      await scoreDao.updateFinancialScore(1, financeScore);
    } catch (e) {
      print('Error updating finance score: $e');
    }

    if (mounted) {
      setState(() {
        _points = totalPoints;
        _level = level;
        _progress = progress;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SwipeablePage(
      onSwipe: () => Navigator.maybePop(context),
      direction: SwipeablePageDirection.leftToRight,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: const Text('Social & Growth'),
          centerTitle: true,
          backgroundColor: colorScheme.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => context.pop(),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Level Header
                  _buildLevelHeader(context),

                  const SizedBox(height: 16),

                  // Tabs
                  TabBar(
                    controller: _tabController,
                    labelColor: colorScheme.primary,
                    unselectedLabelColor: colorScheme.onSurfaceVariant,
                    indicatorColor: colorScheme.primary,
                    tabs: const [
                      Tab(text: 'Friends', icon: Icon(Icons.people_outline)),
                      Tab(text: 'Dating', icon: Icon(Icons.favorite_border)),
                      Tab(text: 'Family', icon: Icon(Icons.family_restroom)),
                    ],
                  ),

                  // Tab Views
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildContactList(context, 'friend'),
                        _buildContactList(context, 'dating'),
                        _buildContactList(context, 'family'),
                      ],
                    ),
                  ),
                ],
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddContactDialog(context),
          child: const Icon(Icons.person_add),
        ),
      ),
    );
  }

  Widget _buildLevelHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Level Circle
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'LV',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$_level',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Points: $_points',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Next Level: ${(_level + 1) * 100} pts',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.black.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactList(BuildContext context, String type) {
    final personDao = context.watch<PersonManagementDAO>();

    return StreamBuilder<List<SocialContact>>(
      stream: personDao.getContactsByRelationship(type),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final contacts = snapshot.data!;

        if (contacts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_off_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No contacts yet',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            final socialContact = contacts[index];
            final contact = socialContact.person;
            final affection = socialContact.affection;
            final affectionLevel = (affection / 100).floor();
            final progressToNext = (affection % 100) / 100;

            return GestureDetector(
              onDoubleTap: () {
                personDao.increaseAffection(contact.personID);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Affection increased with ${contact.firstName}! ❤️',
                    ),
                    duration: const Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      // Top row: avatar + info + actions
                      Row(
                        children: [
                          // Avatar with heart badge
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: _getRelationshipColor(
                                  type,
                                ).withOpacity(0.15),
                                child: Text(
                                  contact.firstName.isNotEmpty
                                      ? contact.firstName[0].toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    color: _getRelationshipColor(type),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              if (affection > 0)
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.favorite,
                                      size: 10,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 12),

                          // Name + ID + relationship tag
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${contact.firstName} ${contact.lastName ?? ''}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Text(
                                      'ID: ${contact.personID}',
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                        fontSize: 11,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getRelationshipColor(
                                          type,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        type.toUpperCase(),
                                        style: TextStyle(
                                          color: _getRelationshipColor(type),
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Action buttons
                          IconButton(
                            icon: const Icon(
                              Icons.favorite_border,
                              color: Colors.pink,
                              size: 20,
                            ),
                            onPressed: () {
                              personDao.increaseAffection(
                                contact.personID,
                                amount: 5,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Sent a gift! (+5 ❤️)'),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.chat_bubble_outline,
                              size: 20,
                            ),
                            onPressed: () {
                              // TODO: Chat
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Affection progress bar (always visible)
                      Row(
                        children: [
                          const Icon(
                            Icons.favorite,
                            size: 14,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'LV $affectionLevel',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: progressToNext,
                                backgroundColor: Colors.grey.withOpacity(0.15),
                                color: _getRelationshipColor(type),
                                minHeight: 6,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$affection pts',
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _getRelationshipColor(String type) {
    switch (type) {
      case 'dating':
        return Colors.pink;
      case 'family':
        return Colors.orange;
      case 'friend':
      default:
        return Colors.blue;
    }
  }

  void _showAddContactDialog(BuildContext context) {
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final personIdController = TextEditingController();
    String selectedType = _getTabName(_tabController.index).toLowerCase();
    bool addByID = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Contact'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Toggle: new or by ID
                    Row(
                      children: [
                        ChoiceChip(
                          label: const Text('New Person'),
                          selected: !addByID,
                          onSelected: (_) =>
                              setDialogState(() => addByID = false),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('By Person ID'),
                          selected: addByID,
                          onSelected: (_) =>
                              setDialogState(() => addByID = true),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (addByID) ...[
                      // Add by existing person ID
                      TextField(
                        controller: personIdController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Person ID',
                          hintText: 'Enter existing person ID',
                          prefixIcon: Icon(Icons.tag),
                        ),
                      ),
                    ] else ...[
                      // Create new person
                      TextField(
                        controller: firstNameController,
                        decoration: const InputDecoration(
                          labelText: 'First Name',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: lastNameController,
                        decoration: const InputDecoration(
                          labelText: 'Last Name (Optional)',
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedType,
                      items: const [
                        DropdownMenuItem(
                          value: 'friend',
                          child: Text('Friend'),
                        ),
                        DropdownMenuItem(
                          value: 'dating',
                          child: Text('Dating'),
                        ),
                        DropdownMenuItem(
                          value: 'family',
                          child: Text('Family'),
                        ),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          selectedType = value!;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Relationship',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final dao = context.read<PersonManagementDAO>();

                    if (addByID) {
                      // Link existing person by ID
                      final id = int.tryParse(personIdController.text);
                      if (id != null) {
                        final person = await dao.getPersonById(id);
                        if (person != null) {
                          await dao.updateRelationship(id, selectedType);
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Person ID not found!'),
                            ),
                          );
                        }
                      }
                    } else {
                      // Create new person
                      if (firstNameController.text.isNotEmpty) {
                        await dao.createPerson(
                          PersonProtocol.create(
                            firstName: firstNameController.text,
                            lastName: lastNameController.text,
                            isActive: true,
                            personID: IDGen.generate(),
                          ),
                          relationship: selectedType,
                        );
                        Navigator.pop(context);
                      }
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) => setState(() {}));
  }

  String _getTabName(int index) {
    switch (index) {
      case 0:
        return 'Friend';
      case 1:
        return 'Dating';
      case 2:
        return 'Family';
      default:
        return 'Friend';
    }
  }
}
