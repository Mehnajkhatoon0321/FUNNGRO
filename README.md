# Funngro Mobile Engineering Assessment (Flutter)

A production-grade, highly optimized mobile engineering implementation built for **Funngro**. Designed specifically for high-volume consumer scale and smooth execution on low-to-mid-range Android devices (~₹8,000 retail, 2GB–3GB RAM).

---

## 📱 Project Architecture & Standards

The project follows a clean **BLoC (Business Logic Component)** architecture with strict separation of concerns:

- **State Management:** `flutter_bloc` with `equatable`. UI widgets contain zero API calls, business logic, or unmanaged streams.
- **Service & Networking Layer:** Centralized `ApiEndpoints` defining microservice base URLs (`https://api.funngro.com/v1`), timeouts, and endpoint paths. Dedicated service clients (`EarningsApi`, `ProjectsApi`) encapsulate all HTTP and WebSocket communication.
- **Design System & Tokens:** Centralized `AppColors`, `AppTextStyles`, and `AppStrings`. No hardcoded colors, arbitrary font sizes, or scattered inline text strings across widgets.
- **Device Optimization:**
  - Viewport virtualization using `ListView.builder`.
  - Memoized and precomputed currency formatting (`CurrencyFormatter`) to eliminate main-thread jank during scrolling.
  - Safe navigation and defensive lifecycle checks across asynchronous gaps.

---

## 📂 Project Directory Structure

```
lib/
├── main.dart                          # App entry point & theme initialization
├── core/
│   ├── constants/
│   │   ├── app_colors.dart            # Centralized brand, surface & semantic palette
│   │   ├── app_strings.dart           # User-facing string constants
│   │   └── app_text_styles.dart       # Typography scale adhering to design rules
│   ├── network/
│   │   └── api_endpoints.dart         # Base URLs, timeouts, and route constants
│   └── utils/
│       └── currency_formatter.dart    # Memoized Indian numbering formatter (₹X,XX,XXX)
├── models/
│   ├── earning.dart                   # Earning, EarningDetail & WalletUpdate entities
│   └── project.dart                   # Project data entity
├── services/
│   ├── earnings_api.dart              # Remote & mock client with WebSocket stream
│   └── projects_api.dart              # Paginated projects API with simulated flakiness
├── blocs/
│   ├── earnings/                      # Earnings BLoC, Events & States
│   │   ├── earnings_bloc.dart
│   │   ├── earnings_event.dart
│   │   └── earnings_state.dart
│   └── projects/                      # Projects Pagination BLoC, Events & States
│       ├── projects_bloc.dart
│       ├── projects_event.dart
│       └── projects_state.dart
├── screens/
│   ├── home_screen.dart               # Demonstration launcher for Part 1 & Part 2
│   ├── earnings_screen.dart           # Part 1: Rewritten virtualized earnings screen
│   ├── detail_screen.dart             # Transaction detail display
│   └── projects_screen.dart           # Part 2: Infinite scroll projects screen
└── widgets/
    ├── earning_tile.dart              # Individual virtualized earning list tile
    ├── project_card.dart              # Card representation for a project
    ├── pagination_footer.dart         # Distinct loading, retry & end-of-list footer
    └── error_view.dart                # Full-screen error state with retry action
```

---

## 📑 Assessment Documentation

The detailed technical write-ups are located in the `assessment/` folder:

1. **[Part 1: Code Review (assessment/part_1_code_review.md)](assessment/part_1_code_review.md)**
   - 8 critical problems ordered by user impact (worst first).
   - In-depth framework mechanics (rebuild loops, stream leaks, OOM from non-virtualized trees, ANR from 3ms formatting on main thread).
   - 4 concrete architectural guardrails to prevent these mistakes across the other 59 screens.
2. **[Part 3: Production Scenario (assessment/part_3_production_scenario.md)](assessment/part_3_production_scenario.md)**
   - Concise chat message to the founder halting the 20% rollout immediately.
   - Comprehensive day-1 investigation plan: Crashlytics breadcrumbs, OEM memory killer analysis (MIUI/OneUI surface destruction on app resume), code diff inspection.
   - Halt vs. Hold vs. Fix-forward decision framework.
   - Dynamic Remote Config ad kill-switch design and implementation.
3. **[Part 4: Walkthrough Recording Guide (assessment/recording_guide.md)](assessment/recording_guide.md)**
   - Structured 5-minute video guide with timed cues, live demonstration script, worst-bug justification, and architectural questions for the Funngro team.

---

## 🛠️ Verification & Running Instructions

### 1. Run the App
Launch the interactive demo on any connected emulator, physical device, or desktop:
```bash
flutter run
```

### 2. Format & Static Analysis
Check code quality and ensure zero lint warnings:
```bash
dart format .
flutter analyze
```

### 3. Run Automated Tests
Execute the unit and BLoC test suite:
```bash
flutter test
```
The test suite covers:
- `ProjectsApi` page range (pages 0–7) and empty list behavior for `page > 7`.
- `ProjectsBloc` first-page loading, error handling, infinite scroll pagination, deduplication, and non-destructive retry.
- `EarningsBloc` data loading, real-time stream event handling, and deduplication.
- Widget smoke tests ensuring navigation and rendering stability.

---

## 💡 Key Design Decisions & Assumptions

1. **Inline Footer Retry vs Modal Alert (Part 2):**  
   When a subsequent page fails due to the 1-in-5 API failure rate, the error is displayed directly in the `PaginationFooter` with a **Retry** button. Previously loaded items are preserved in memory without disturbance, keeping the browsing experience uninterrupted.
2. **Precomputed Formatting (Part 1):**  
   Locale parsing (~3ms) is performed once during model mapping/creation and memoized in `CurrencyFormatter`. This guarantees 60fps scrolling across 3,000 items on low-tier chipsets.
3. **Deduplication:**  
   Incoming real-time WebSocket wallet transactions are indexed against existing IDs before insertion. If an update matches an existing record (e.g., reconnection duplicate), it updates in place; otherwise, it is cleanly prepended.
