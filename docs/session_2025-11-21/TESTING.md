# Testing Guide

## Overview
This guide provides comprehensive testing instructions for all features implemented in this session.

---

## Prerequisites

### Environment Setup
- Flutter SDK installed
- iOS Simulator or physical iOS device
- Android Emulator or physical Android device
- Camera permissions granted (for camera testing)

### Running the App
```bash
cd /Users/duylong/Code/Flutter/ice_shield
flutter run
```

---

## Test Plan

### 1. Health Metric Navigation Tests

#### Test 1.1: Navigate to StepsPage
**Steps:**
1. Launch the app
2. Navigate to Health section
3. Tap on "Steps" card

**Expected Result:**
- ✅ Navigates to StepsPage
- ✅ Shows current step count (8,500)
- ✅ Shows progress bar
- ✅ Displays 4 stat cards

**Pass Criteria:**
- Navigation is smooth
- All UI elements visible
- No errors in console

---

#### Test 1.2: Navigate to HeartRatePage
**Steps:**
1. From Health page
2. Tap on "Heart Rate" card

**Expected Result:**
- ✅ Navigates to HeartRatePage
- ✅ Shows current BPM (72)
- ✅ Displays heart rate zone
- ✅ Shows zone color indicator

**Pass Criteria:**
- Zone color matches BPM
- Statistics are calculated correctly

---

#### Test 1.3: Navigate to SleepPage
**Steps:**
1. From Health page
2. Tap on "Sleep Hours" card

**Expected Result:**
- ✅ Navigates to SleepPage
- ✅ Shows sleep duration (7.5 hrs)
- ✅ Displays sleep quality rating
- ✅ Shows bedtime and wake time

**Pass Criteria:**
- Time pickers work
- Sleep calculation is accurate

---

#### Test 1.4: Navigate to CaloriesPage
**Steps:**
1. From Health page
2. Tap on "Calories Burned" card

**Expected Result:**
- ✅ Navigates to CaloriesPage
- ✅ Shows net calories
- ✅ Displays consumed vs burned
- ✅ Shows "Take Food Photo" button

**Pass Criteria:**
- All sections visible
- Camera button present

---

### 2. StepsPage Functionality Tests

#### Test 2.1: Add Steps Manually
**Steps:**
1. Navigate to StepsPage
2. Enter "500" in the text field
3. Tap the "+" button

**Expected Result:**
- ✅ Steps increase to 9,000
- ✅ Distance updates to 7.20 km
- ✅ Calories update to 360 kcal
- ✅ Progress bar updates
- ✅ Text field clears

**Pass Criteria:**
- All calculations update in real-time
- No lag or errors

---

#### Test 2.2: Reset Steps
**Steps:**
1. From StepsPage with steps > 0
2. Tap "Reset Today's Steps" button

**Expected Result:**
- ✅ Steps reset to 0
- ✅ All metrics reset to 0
- ✅ Progress bar shows 0%

**Pass Criteria:**
- Reset is immediate
- No errors

---

#### Test 2.3: Reach Goal
**Steps:**
1. Add steps until reaching 10,000

**Expected Result:**
- ✅ Progress bar reaches 100%
- ✅ "100% Complete" message shows
- ✅ Remaining steps shows 0

**Pass Criteria:**
- Visual feedback is clear
- Calculations are accurate

---

### 3. HeartRatePage Functionality Tests

#### Test 3.1: Add Heart Rate Reading
**Steps:**
1. Navigate to HeartRatePage
2. Enter "85" in BPM field
3. Tap "+" button

**Expected Result:**
- ✅ Current BPM updates to 85
- ✅ Zone changes to "Normal" (Green)
- ✅ Reading added to history
- ✅ Average recalculates
- ✅ Text field clears

**Pass Criteria:**
- Zone color updates correctly
- Statistics recalculate

---

#### Test 3.2: Test Zone Detection
**Test Cases:**
| BPM | Expected Zone | Expected Color |
|-----|---------------|----------------|
| 55  | Resting       | Blue           |
| 75  | Normal        | Green          |
| 120 | Elevated      | Orange         |
| 160 | High          | Red            |

**Steps:**
1. Enter each BPM value
2. Verify zone and color

**Pass Criteria:**
- All zones detect correctly
- Colors match zones

---

#### Test 3.3: Reading History
**Steps:**
1. Add 12 readings
2. Check reading count

**Expected Result:**
- ✅ Only last 10 readings kept
- ✅ Oldest readings removed
- ✅ Count shows "10 total"

**Pass Criteria:**
- History limit enforced
- No memory issues

---

### 4. SleepPage Functionality Tests

#### Test 4.1: Set Sleep Schedule
**Steps:**
1. Navigate to SleepPage
2. Tap bedtime selector
3. Select 11:00 PM
4. Tap wake time selector
5. Select 7:00 AM

**Expected Result:**
- ✅ Sleep hours calculate to 8.0
- ✅ Rating shows "Excellent" (Green)
- ✅ Sleep cycles show 5
- ✅ Progress bar at 100%

**Pass Criteria:**
- Calculation is accurate
- Rating updates correctly

---

#### Test 4.2: Test Overnight Calculation
**Steps:**
1. Set bedtime to 11:30 PM
2. Set wake time to 6:30 AM

**Expected Result:**
- ✅ Correctly calculates 7.0 hours
- ✅ Handles midnight crossing
- ✅ Rating shows "Good"

**Pass Criteria:**
- No negative values
- Calculation crosses midnight correctly

---

#### Test 4.3: Sleep Quality Ratings
**Test Cases:**
| Hours | Expected Rating | Color       |
|-------|----------------|-------------|
| 9.0   | Excellent      | Green       |
| 7.5   | Good           | Light Green |
| 6.5   | Fair           | Orange      |
| 5.0   | Poor           | Red         |

**Pass Criteria:**
- All ratings correct
- Colors match ratings

---

### 5. CaloriesPage Functionality Tests

#### Test 5.1: Log Food
**Steps:**
1. Navigate to CaloriesPage
2. Enter "Pizza" in food name
3. Enter "500" in calories
4. Tap "+" button

**Expected Result:**
- ✅ Calories consumed increases by 500
- ✅ Net calories recalculates
- ✅ Status updates if needed
- ✅ Fields clear

**Pass Criteria:**
- Calculations update
- UI reflects changes

---

#### Test 5.2: Log Exercise
**Steps:**
1. Enter "200" in calories burned
2. Tap "+" button

**Expected Result:**
- ✅ Calories burned increases by 200
- ✅ Net calories recalculates
- ✅ Total burn updates

**Pass Criteria:**
- Math is correct
- UI updates

---

#### Test 5.3: Quick Add Exercise
**Steps:**
1. Tap "Running 30min" chip

**Expected Result:**
- ✅ Calories burned increases by 300
- ✅ SnackBar shows "Added 300 kcal burned"
- ✅ Net calories updates

**Pass Criteria:**
- Instant feedback
- Correct amount added

---

### 6. Camera Feature Tests

#### Test 6.1: Open Camera Interface
**Steps:**
1. Navigate to CaloriesPage
2. Tap "Take Food Photo" button

**Expected Result:**
- ✅ Bottom sheet appears
- ✅ Shows "Camera" option
- ✅ Shows "Gallery" option
- ✅ Both options have icons

**Pass Criteria:**
- Bottom sheet animates smoothly
- Options are tappable

---

#### Test 6.2: Camera Capture (Physical Device Required)
**Steps:**
1. Tap "Camera" option
2. Grant camera permission if prompted
3. Take a photo
4. Review preview

**Expected Result:**
- ✅ Camera opens
- ✅ Photo captures successfully
- ✅ Preview shows captured image
- ✅ "Confirm" button appears
- ✅ "Retake" button appears

**Pass Criteria:**
- Camera works
- Preview is clear
- Buttons functional

---

#### Test 6.3: Gallery Selection
**Steps:**
1. Tap "Take Food Photo"
2. Select "Gallery"
3. Grant photo library permission if prompted
4. Select an image

**Expected Result:**
- ✅ Gallery opens
- ✅ Image selection works
- ✅ Preview shows selected image
- ✅ Confirm/retake buttons appear

**Pass Criteria:**
- Gallery accessible
- Selection works
- Preview correct

---

#### Test 6.4: Confirm Photo
**Steps:**
1. Capture/select a photo
2. Tap "Confirm" button

**Expected Result:**
- ✅ Returns to CaloriesPage
- ✅ Green SnackBar appears
- ✅ Message: "Photo captured! Add food details below"
- ✅ SnackBar has checkmark icon

**Pass Criteria:**
- Navigation works
- Feedback is clear
- Image data available (XFile returned)

---

#### Test 6.5: Retake Photo
**Steps:**
1. Capture/select a photo
2. Tap "Retake" button

**Expected Result:**
- ✅ Bottom sheet appears again
- ✅ Can select different source
- ✅ Previous image cleared

**Pass Criteria:**
- Flow repeats
- No errors

---

#### Test 6.6: Cancel/Back
**Steps:**
1. Open camera interface
2. Tap back button (without taking photo)

**Expected Result:**
- ✅ Returns to CaloriesPage
- ✅ No SnackBar appears
- ✅ No errors

**Pass Criteria:**
- Clean cancellation
- No side effects

---

### 7. Permission Tests

#### Test 7.1: Camera Permission (iOS)
**Steps:**
1. Fresh install or reset permissions
2. Tap "Camera" option
3. Observe permission dialog

**Expected Result:**
- ✅ Permission dialog appears
- ✅ Shows custom message: "We need camera access to let you take photos of your food for calorie tracking"
- ✅ "Allow" and "Don't Allow" options

**Pass Criteria:**
- Custom message displays
- Permission can be granted

---

#### Test 7.2: Photo Library Permission (iOS)
**Steps:**
1. Tap "Gallery" option
2. Observe permission dialog

**Expected Result:**
- ✅ Permission dialog appears
- ✅ Shows custom message about photo library
- ✅ Options to allow/deny

**Pass Criteria:**
- Message is clear
- Permission works

---

#### Test 7.3: Permission Denial Handling
**Steps:**
1. Deny camera permission
2. Try to use camera

**Expected Result:**
- ✅ Error dialog appears
- ✅ Explains permission is needed
- ✅ Provides "OK" button

**Pass Criteria:**
- Graceful error handling
- User can retry

---

### 8. Edge Case Tests

#### Test 8.1: Invalid Input - Steps
**Steps:**
1. Enter "abc" in steps field
2. Tap "+" button

**Expected Result:**
- ✅ Nothing happens (validation prevents)
- ✅ No error thrown
- ✅ Steps remain unchanged

**Pass Criteria:**
- Input validation works
- No crashes

---

#### Test 8.2: Invalid Input - Heart Rate
**Steps:**
1. Enter "300" (out of range)
2. Tap "+" button

**Expected Result:**
- ✅ Validation prevents (40-220 range)
- ✅ No reading added
- ✅ Or: Reading added but clamped to valid range

**Pass Criteria:**
- Range validation works
- No invalid data stored

---

#### Test 8.3: Empty State - Camera
**Steps:**
1. Open CameraFoodImport
2. Don't take/select photo
3. Observe UI

**Expected Result:**
- ✅ Shows empty state
- ✅ Large camera icon
- ✅ "No Photo Selected" message
- ✅ Quick action buttons visible

**Pass Criteria:**
- Empty state is clear
- Actions are obvious

---

## Performance Tests

### Test 9.1: Navigation Speed
**Metric:** Time from tap to page display
**Target:** < 300ms
**Test:** Tap each health metric card 5 times
**Pass Criteria:** Average < 300ms

### Test 9.2: Calculation Speed
**Metric:** Time for calculations to update
**Target:** Instant (< 16ms for 60fps)
**Test:** Add steps/calories/BPM
**Pass Criteria:** No visible lag

### Test 9.3: Camera Launch Speed
**Metric:** Time from tap to camera ready
**Target:** < 1 second
**Test:** Open camera 5 times
**Pass Criteria:** Average < 1s

---

## Regression Tests

### Test 10.1: Existing Features
**Verify:**
- ✅ Health page still loads
- ✅ Other app features work
- ✅ Theme switching works
- ✅ Navigation drawer works

### Test 10.2: Hot Reload
**Steps:**
1. Make a small code change
2. Hot reload (press 'r')

**Expected Result:**
- ✅ Changes apply
- ✅ State preserved
- ✅ No errors

---

## Test Results Template

```
Test Date: _______________
Tester: _______________
Device: _______________
OS Version: _______________

| Test ID | Test Name | Status | Notes |
|---------|-----------|--------|-------|
| 1.1 | Navigate to StepsPage | ☐ Pass ☐ Fail | |
| 1.2 | Navigate to HeartRatePage | ☐ Pass ☐ Fail | |
| 1.3 | Navigate to SleepPage | ☐ Pass ☐ Fail | |
| 1.4 | Navigate to CaloriesPage | ☐ Pass ☐ Fail | |
| 2.1 | Add Steps Manually | ☐ Pass ☐ Fail | |
| ... | ... | ... | |

Overall Result: ☐ All Pass ☐ Some Failures

Issues Found:
1. 
2. 
3. 
```

---

## Automated Testing (Future)

### Unit Tests Needed
- [ ] Step calculation functions
- [ ] Heart rate zone detection
- [ ] Sleep duration calculation
- [ ] Calorie calculations

### Widget Tests Needed
- [ ] Navigation tests
- [ ] Button tap tests
- [ ] Input validation tests

### Integration Tests Needed
- [ ] Full user flow tests
- [ ] Camera integration tests
- [ ] Permission handling tests

---

## Known Issues

1. **iOS Simulator**: Camera not available (use physical device)
2. **Android Emulator**: Virtual camera available but quality is low
3. **Hot Reload**: May need full restart after permission changes

---

## Support

If tests fail:
1. Check Flutter console for errors
2. Verify permissions are granted
3. Try full app restart (hot restart 'R')
4. Check device/emulator compatibility
5. Review CHANGES.md for implementation details
