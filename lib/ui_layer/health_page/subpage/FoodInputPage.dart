import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ice_shield/data_layer/DataSources/local_database/Database.dart';
import 'package:ice_shield/ui_layer/home_page/MainButton.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:ice_shield/initial_layer/CoreLogics/Health/AIFoodCaloriesServices.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:signals_flutter/signals_core.dart';
import 'package:signals_flutter/src/core/signal.dart';
import 'package:path/path.dart' as path; // Add this alias to avoid conflicts

class FoodInputPage extends StatefulWidget {
  const FoodInputPage({super.key});

  @override
  State<FoodInputPage> createState() => _FoodInputPageState();
  static Widget icon(BuildContext context, {double? size}) {
    return MainButton(
      type: "health",
      destination: "/health",
      size: size,
      mainFunction: () {
        print("Main button clicked");
        context.go('/health/food/dashboard');
      },
      icon: Icons.sunny,
      subButtons: [
        SubButton(
          icon: Icons.restaurant,
          // size: 100,
          backgroundColor: Colors.orange,
          onPressed: () {
            print("Main button clicked");
            context.go('/health/food');
          },
        ),
        SubButton(
          icon: Icons.fitness_center,
          backgroundColor: Colors.red,
          onPressed: () => context.go('/health/exercise'),
        ),
        SubButton(
          icon: Icons.bedtime,
          backgroundColor: Colors.indigo,
          onPressed: () => context.go('/health/sleep'),
        ),
        SubButton(
          icon: Icons.water_drop,
          backgroundColor: Colors.cyan,
          onPressed: () {
            context.go('/health/water');
            // print("Water button clicked");
          },
        ),
      ],
      // isShow: false,
      // onPressed: () {
      //   setState(() {
      //     isShow=true;
      //   })
      // },
    );
  }
}

class _FoodInputPageState extends State<FoodInputPage> {
  final _aiService = Aifoodcaloriesservices();
  // final database = AppDatabase();
  bool _isAnalyzing = false;
  final List<Map<String, dynamic>> _meals = [
    // {'name': 'Breakfast', 'calories': 450, 'time': '08:30 AM'},
    // {'name': 'Lunch', 'calories': 650, 'time': '01:15 PM'},
  ];

  final _foodController = TextEditingController();
  final _caloriesController = TextEditingController();
  File? _pickedImage;
  String _imagePath = "";
  final ImagePicker _picker = ImagePicker();
  FlutterSignal<double> totalCalories = signal(0);
  late HealthMealDAO _healthMealDAO;
  late Directory appDir;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _healthMealDAO = context.read<HealthMealDAO>();
    appDir = await getApplicationDocumentsDirectory();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      print("Path when I pick image: ${image!.path}");
      // Sử dụng path_provider

      //  final Directory appDir=await
      final String fileName = path.basename(image.path);
      final File savedImage = await File(
        image.path,
      ).copy('${appDir.path}/$fileName');
      // final String fileName = path.basename(image!.path);
      //   final String permanentPath = '${appDir.path}/$fileName';

      setState(() {
        _pickedImage = File(savedImage.path);
        _imagePath = fileName;
        print("Path when I save image: ${savedImage.path}");
      });
      // Trigger AI analysis if food name is also present or just analysis from image
      _analyzeFood();
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _analyzeFood() async {
    if (_pickedImage == null) return;

    setState(() => _isAnalyzing = true);

    try {
      final calories = await _aiService.getCalories(
        _foodController.text,
        image: _pickedImage,
      );

      if (mounted) {
        setState(() {
          _caloriesController.text =
              "${calories.carbs}|${calories.protein}|${calories.fat}|${calories.calories}";
          _isAnalyzing = false;
        });
      }
    } catch (e) {
      debugPrint('Error analyzing food: $e');
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  Future<void> _addMeal() async {
    if (_caloriesController.text.isNotEmpty) {
      // print(_caloriesController.text);
      if (_foodController.text.isEmpty) {
        _foodController.text = _timeInDay(DateTime.now())['label']!;
      }
      final energy = _caloriesController.text.split("|");

      final carbs = double.tryParse(energy[0]) ?? 0.0;
      final protein = double.tryParse(energy[1]) ?? 0.0;
      final fat = double.tryParse(energy[2]) ?? 0.0;
      final calories = double.tryParse(energy[3]) ?? 0.0;

      // final totalCalories = (carbs + protein + fat).toInt();

      final now = DateTime.now();

      // 1. Insert Meal details
      final mealId = await _healthMealDAO.insertMeal(
        MealsTableCompanion.insert(
          mealName: _foodController.text,

          mealImageUrl: Value(_imagePath),
          carbs: Value(carbs),
          protein: Value(protein),
          fat: Value(fat),
          calories: Value(calories),
          eatenAt: Value(now),
        ),
      );

      // 2. Insert Day log
      await _healthMealDAO.insertDay(
        DaysTableCompanion.insert(
          dayID: now,
          caloriesOut: Value(0),
          weight: Value(0),
        ),
      );

      setState(() {
        // _meals.add({
        //   'name': _foodController.text,
        //   'calories': calories.toInt(),
        //   'time': now.toString(),
        //   'image': _pickedImage,
        // });
        _foodController.clear();
        _caloriesController.clear();
        _pickedImage = null;
      });
    }
  }

  Future<void> _getTotalCalories() async {
    final calories = await _healthMealDAO.getCaloriesByDate(DateTime.now());
    if (mounted) {
      totalCalories.value = calories;
    }
  }

  @override
  void initState() {
    super.initState();

    // 1. Initialize the DAO immediately (Provider access is safe here if using context.read)
    _healthMealDAO = context.read<HealthMealDAO>();

    // 2. Load the directory and THEN load calories
    getApplicationDocumentsDirectory().then((dir) {
      if (mounted) {
        setState(() {
          appDir = dir;
        });
        _getTotalCalories(); // Now safe to call
      }
    });
  }

  // Remove didChangeDependencies entirely unless you have other logic there
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const AutoSizeText('Food Tracker', maxLines: 1),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      AutoSizeText(
                        'Today\'s Intake',
                        style: textTheme.titleSmall,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 8),
                      AutoSizeText(
                        '$totalCalories kcal',
                        style: textTheme.displayMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                      ),
                      // AutoSizeText(
                      //   'Goal: 2000 kcal',
                      //   style: textTheme.bodySmall,
                      //   maxLines: 1,
                      // ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
            AutoSizeText(
              'Recent Meals',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
            ),
            const SizedBox(height: 12),
            // 1. Dùng StreamBuilder để lắng nghe thay đổi từ Database
            StreamBuilder<List<DayWithMeal>>(
              stream: _healthMealDAO
                  .watchDaysWithMeals(), // Gọi hàm watch từ database
              builder: (context, snapshot) {
                // 2. Xử lý các trạng thái loading/error
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                // 3. Lấy dữ liệu từ snapshot
                final mealsList = snapshot.data ?? [];

                if (mealsList.isEmpty) {
                  return const Text("No meals added yet");
                }

                // 4. Render danh sách (Code cũ của bạn nằm ở đây)
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: mealsList.length, // Dùng độ dài list từ DB
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final meal =
                        mealsList[index]; // meal là Object, không phải Map

                    return ListTile(
                      // --- XỬ LÝ ẢNH ---
                      // Lưu ý: Database thường lưu đường dẫn ảnh (String), không lưu File trực tiếp.
                      // Giả sử meal.imagePath là đường dẫn file.
                      // Thay thế đoạn Image.file trong ListTile bằng đoạn này:
                      leading:
                          meal.meal.mealImageUrl != null &&
                              meal.meal.mealImageUrl!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(
                                  '${appDir.path}/${meal.meal.mealImageUrl!}',
                                ), // Nối thư mục hiện tại với tên file
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                      Icons.broken_image,
                                    ), // Chống crash nếu file bị xóa
                              ),
                            )
                          : const CircleAvatar(child: Icon(Icons.restaurant)),

                      // --- HIỂN THỊ TEXT ---
                      // Thay meal['name'] bằng meal.name
                      title: AutoSizeText(meal.meal.mealName, maxLines: 1),
                      subtitle: Row(
                        children: [
                          AutoSizeText(
                            meal.meal.eatenAt.toString().substring(0, 16),
                            maxLines: 1,
                          ),
                          const SizedBox(width: 8),
                          AutoSizeText(
                            _timeInDay(meal.meal.eatenAt)['label']!,
                            style: TextStyle(
                              color: _getMealColor(meal.meal.eatenAt),
                              fontWeight: FontWeight.bold,
                            ),

                            maxLines: 1,
                          ),
                        ],
                      ),

                      // --- TRAILING ---
                      // Giả sử bạn muốn hiển thị calories hoặc giá tiền
                      trailing: AutoSizeText(
                        "${meal.meal.calories} kcal",
                        maxLines: 1,
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'manual',
            onPressed: () => _showAddMealDialog(context, null),
            label: const Text('Manual'),
            icon: const Icon(Icons.edit),
            backgroundColor: Colors.orange,
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'capture',
            onPressed: () => _showCaptureOptions(context),
            label: const Text('Capture'),
            icon: const Icon(Icons.camera_alt),
            backgroundColor: colorScheme.primary,
          ),
        ],
      ),
    );
  }

  void _showCaptureOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context); // Close sheet
                _pickImage(ImageSource.camera).then((_) {
                  if (_pickedImage != null) {
                    _showAddMealDialog(context, _pickedImage);
                  }
                });
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context); // Close sheet
                _pickImage(ImageSource.gallery).then((_) {
                  if (_pickedImage != null) {
                    _showAddMealDialog(context, _pickedImage);
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMealDialog(BuildContext context, File? image) {
    // If an image was passed in, set it as the picked image
    if (image != null) {
      _pickedImage = image;
      // Trigger analysis automatically if image is provided
      _analyzeFood();
    } else {
      // Clear if manual mode
      _pickedImage = null;
      _imagePath = "";
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(image != null ? 'Edit Captured Meal' : 'Add Meal'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_pickedImage != null)
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_pickedImage!, fit: BoxFit.cover),
                    ),
                  ),
                if (_pickedImage == null)
                  GestureDetector(
                    onTap: () {
                      // Fallback for manual adding photo inside dialog
                      Navigator.pop(context);
                      _showCaptureOptions(context);
                    },
                    child: Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.add_a_photo, color: Colors.grey),
                          Text(
                            "Add Photo (Optional)",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                TextField(
                  controller: _foodController,
                  decoration: const InputDecoration(
                    labelText: 'Food Name',
                    border: OutlineInputBorder(),
                  ),
                  onEditingComplete: _analyzeFood,
                ),
                const SizedBox(height: 12),
                 TextField(
                  controller: _caloriesController,
                  decoration: InputDecoration(
                    labelText: 'Energy',
                    border: const OutlineInputBorder(),
                    suffixIcon: _isAnalyzing
                        ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.auto_awesome),
                            onPressed: _analyzeFood,
                            tooltip: 'Analyze Food',
                          ),
                  ),
                  keyboardType: TextInputType.number,
                ),
               
              ],
            ),
            
          ),
          actions: [
            TextButton(
              onPressed: () {
                _pickedImage = null;
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _addMeal();
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}

Map<String, dynamic> _timeInDay(DateTime time) {
  final hour = time.hour;

  if (hour >= 5 && hour < 12) {
    return {'label': 'BREAKFAST', 'color': 0xFFFFB74D}; // Orange
  } else if (hour >= 12 && hour < 17) {
    return {'label': 'LUNCH', 'color': 0xFF81C784}; // Green
  } else if (hour >= 17 && hour < 21) {
    return {'label': 'DINNER', 'color': 0xFF64B5F6}; // Blue
  } else {
    return {'label': 'Snack', 'color': 0xFFBA68C8}; // Purple
  }
}

Color _getMealColor(DateTime time) {
  final hour = time.hour;
  if (hour < 11) return Colors.green;
  if (hour < 16) return Colors.orange;
  return Colors.blue;
}
