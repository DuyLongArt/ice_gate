// ─────────────────────────────────────────────────
// 📊 ICE Shield — Global Point Constants
// ─────────────────────────────────────────────────
// Edit these to tune the entire scoring system.

// ─── 🏃 Health ───
const int STEPS_PER_POINT = 1000; // 100 steps = 1 point
const int CALORIE_LIMIT = 1500; // daily kcal threshold
const int CALORIE_BONUS_POINTS = 15; // points if day < 1500 kcal

// ─── ❤️ Social ───
const int CONTACT_POINTS = 30; // each contact = +30 points
const int AFFECTION_PER_UNIT = 5; // every 5 affection...
const int AFFECTION_POINTS = 10; // ...= +10 points

// ─── 💼 Projects ───
const double TASK_SCORE_INCREMENT = 5; // each task completion = +2
const double PROJECT_SCORE_INCREMENT = 500; // each project completion = +50

// ─── 💰 Finance ───
const double FINANCE_SAVINGS_MILESTONE = 1000.0; // Every $1000 saved
const int FINANCE_SAVINGS_POINTS = 50; // ...= +50 points
const int FINANCE_BUDGET_ADHERENCE_POINTS =
    20; // Staying under budget = +20 points
const double FINANCE_INVESTMENT_RETURN_THRESHOLD = 5.0; // Every 5% return
const int FINANCE_INVESTMENT_POINTS = 10; // ...= +10 points
