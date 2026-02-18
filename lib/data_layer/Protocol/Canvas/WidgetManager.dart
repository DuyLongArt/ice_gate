import 'InternalWidgetDragProtocol.dart';
// import 'models.dart'; // Import the file above

class WidgetManager  {
  // The source of truth
  List<InternalWidgetDragProtocol> widgets = [];

  WidgetManager(List<InternalWidgetDragProtocol>? initialWidgets) {
    if (initialWidgets != null) {
      widgets = List.from(initialWidgets);
    } else {
      // Initialize with 16 empty slots by default (4x4 Grid)
      widgets = List.generate(16, (_) => InternalWidgetDragProtocol.empty());
    }
  }

  // ==================================================
  // 1. REORDERING (List List / Drag Logic)
  // ==================================================

  /// Moves the object physically in the list (Standard ReorderableListView).
  void reorderWidgets(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final InternalWidgetDragProtocol item = widgets.removeAt(oldIndex);
    widgets.insert(newIndex, item);

    // notifyListeners();
  }

  // ==================================================
  // 2. SWAPPING (Grid Logic)
  // ==================================================

  /// Swaps the DATA between two slots, but keeps IDs if needed,
  /// or swaps the whole objects. Here we swap entire objects.
  void swapContentBetweenIndices(int indexA, int indexB) {
    if (indexA == indexB) return;
    if (!_isValidIndex(indexA) || !_isValidIndex(indexB)) return;

    final widgetA = widgets[indexA];
    final widgetB = widgets[indexB];

    // OPTION A: Swap Physical Locations (Simple)
    widgets[indexA] = widgetB;
    widgets[indexB] = widgetA;

    // OPTION B: Swap Properties but keep Location IDs (Advanced)
    // Use this if 'widgetID' is tied to the SLOT, not the ITEM.
    /*
    widgets[indexA] = widgetA.copyWith(
      name: widgetB.name,
      score: widgetB.score,
      color: widgetB.color,
    );
    widgets[indexB] = widgetB.copyWith(
      name: widgetA.name,
      score: widgetA.score,
      color: widgetA.color,
    );
    */

    _updateDependencies(widgetA); // Trigger side effects
    // notifyListeners();
  }

  // ==================================================
  // 3. MERGING (Game/RPG Logic)
  // ==================================================

  void mergeWidgets(int sourceIndex, int targetIndex) {
    if (sourceIndex == targetIndex) return;

    final source = widgets[sourceIndex];
    final target = widgets[targetIndex];

    // 1. Create new Target with combined score
    final newTarget = target.copyWith(
      score: target.score + source.score,
      // Example: Combine names "Health" + "Potion"
      alias: "${target.alias} +",
    );

    // 2. Reset Source to Empty
    final newSource = InternalWidgetDragProtocol.empty();

    // 3. Update List
    widgets[targetIndex] = newTarget;
    widgets[sourceIndex] = newSource;

    // notifyListeners();
  }

  // ==================================================
  // 4. COMPLEX INTERACTION (Target/Conditional)
  // ==================================================

  void handleInteraction(int sourceIndex, int targetIndex) {
    if (!_isValidIndex(sourceIndex) || !_isValidIndex(targetIndex)) return;

    final source = widgets[sourceIndex];
    final target = widgets[targetIndex];

    // CASE 1: Target is special (e.g., a folder or a trash can)
    if (target.isTarget && !source.isTarget) {

      // Logic: Target "eats" the source
      final newTarget = target.copyWith(
        score: target.score + source.score,
        alias: "Consumed ${source.name}",
      );

      final newSource = InternalWidgetDragProtocol.empty();

      widgets[targetIndex] = newTarget;
      widgets[sourceIndex] = newSource;

      // notifyListeners();
    }
    // CASE 2: Standard Swap
    else {
      swapContentBetweenIndices(sourceIndex, targetIndex);
    }
  }

  // ==================================================
  // 5. CRUD / UPDATE SINGLE ITEM
  // ==================================================

  void updateWidget(int index, {String? newName, int? newScore}) {
    if (!_isValidIndex(index)) return;

    final current = widgets[index];

    // Freezed CopyWith handles nulls automatically (only updates if provided)
    // However, since we are passing specific args, we check them:
    widgets[index] = current.copyWith(
      name: newName ?? current.name,
      score: newScore ?? current.score,
    );

    // notifyListeners();
  }

  void addWidget(InternalWidgetDragProtocol newItem) {
    widgets.add(newItem);
    // notifyListeners();
  }

  void removeWidget(int index) {
    if (_isValidIndex(index)) {
      widgets.removeAt(index);
      // notifyListeners();
    }
  }

  // ==================================================
  // 6. INTERNAL HELPERS
  // ==================================================

  bool _isValidIndex(int index) {
    return index >= 0 && index < widgets.length;
  }

  /// Example of a "Side Effect":
  /// If an item becomes very powerful (score > 100),
  /// update other items to reflect fear/status.
  void _updateDependencies(InternalWidgetDragProtocol changedWidget) {
    if (changedWidget.score > 100) {
      for (int i = 0; i < widgets.length; i++) {
        final current = widgets[i];

        // Don't update self or empty slots
        if (current.widgetID == changedWidget.widgetID || current.name == 'Empty') continue;

        // Modify others
        widgets[i] = current.copyWith(
          isStay: true, // Make others freeze in fear
        );
      }
    }
  }
}