# Part 4: Walkthrough Recording Guide (5-Minute Video Blueprint)

> **Important Note:** This document provides the structured guide, timing cues, and discussion points for you to record your own 5-minute Loom / camera video. No pre-recorded file is fabricated; use this blueprint to speak naturally and collegially.

---

## Video Outline & Timing Breakdown (Max 5 Minutes)

| Section | Time Target | Core Focus |
| :--- | :--- | :--- |
| **1. Introduction & Setup** | 0:00 – 0:30 (30s) | Quick colleague-to-colleague greeting, app running on emulator/device. |
| **2. Part 2 Live Demo: Flaky API & Pagination** | 0:30 – 2:30 (2m 00s) | First load, infinite scroll, footer loading, error + retry demo, pull-to-refresh, end of list. |
| **3. Part 1 Deep-Dive: The #1 Worst Bug** | 2:30 – 3:45 (1m 15s) | Explain why the infinite `build()` network loop ranks worst on ₹8,000 Android phones. |
| **4. Architectural Assumptions & Questions for Team** | 3:45 – 4:45 (1m 00s) | One key trade-off/decision made and the exact question you'd ask the Funngro team. |
| **5. Wrap-up** | 4:45 – 5:00 (15s) | Clean sign-off. |

---

## Talking Points & Demonstration Steps

### 1. Introduction (0:00 – 0:30)
- *"Hi Anik and Funngro team, I'm walking through my submission for the Funngro Mobile Engineering Assessment. We're running on a local device showing both the Part 1 rewritten earnings flow and Part 2's infinite scroll projects list."*
- Open the app to the **Home Screen** and tap into **"Explore Projects"**.

---

### 2. Live Demo of Part 2: Projects Screen (0:30 – 2:30)
Demonstrate the core requirements live against the fake API:
1. **Initial Load:**
   - Point out the clean initial centered loading indicator.
   - Show how page 0 populates with the first 20 projects.
2. **Infinite Scroll Pagination:**
   - Scroll down to project #18–20.
   - Show how the `ScrollController` triggers page 1 automatically when within 250px of the bottom.
   - Point out the distinct footer: `Loading more projects...` with the spinner.
3. **Flaky API Handling (The Error & Retry Path):**
   - Continue scrolling until one of the pages hits the 1-in-5 simulated `ApiException('server error')`.
   - **Crucial point to highlight on camera:** *"Notice that when the page fails, we did NOT lose the 20 or 40 projects already loaded above. The list stays stable, and our footer turns into a red error banner with a Retry button."*
   - Tap the **Retry** button. Show how the same page is re-requested without corrupting list order or losing state.
4. **Pull-to-Refresh:**
   - Pull down from the top of the list.
   - Show how `RefreshIndicator` resets the dataset back to page 0.
5. **End-of-List State:**
   - Scroll through page 7. When page 8 returns empty `[]`, point out the distinct end-of-list banner: *"✓ You have reached the end (160 projects)"*. No more network requests are made.

---

### 3. Part 1: The Worst Bug & Why It Ranked First (2:30 – 3:45)
- *"Turning to Part 1's code review: in our review document, we identified 8 distinct bugs, but I ranked the **Infinite Rebuild-Fetch Loop inside build()** as the absolute worst."*
- **Explain the framework mechanics clearly:**
  - *"In the original code, `api.fetchEarnings()` was called directly inside `build()`. When that Future completed, it called `setState()`. In Flutter, `setState()` marks the Element dirty and schedules another build. That next build immediately called `api.fetchEarnings()` again, causing an infinite loop."*
- **Why it matters specifically on an ₹8,000 phone:**
  - *"On a budget 2GB Android device with a MediaTek or Unisoc SoC, this infinite network storm burns through mobile data, heats the phone up within 60 seconds, and triggers an unrecoverable Out-Of-Memory (OOM) crash or OS ANR before the teen user can even read their earnings. Moving it to `initState()` solves the root cause."*
- Briefly mention Bug #2 (leaking stream listeners multiplying duplicate entries) and Bug #3 (lack of `ListView.builder` virtualization for 3,000 items).

---

### 4. Technical Decision & Question for the Funngro Team (3:45 – 4:45)
- **The Decision / Assumption:**
  - *"In Part 2, when designing the pagination error recovery, I chose an inline footer retry button rather than a floating SnackBar or a full-screen error blocking the screen. I assumed that teen users browsing gigs on unstable 4G networks value uninterrupted viewing of existing jobs over an intrusive modal error."*
- **The Question for the Funngro Team:**
  - *"The question I would have asked you before building: **'What is Funngro's offline and caching strategy for gig listings? Specifically, should page results be cached locally in SQLite/Hive so teens in low-connectivity areas can view cached gigs offline, and should we support optimistic updates when teens apply for projects?'**"*

---

### 5. Wrap-Up (4:45 – 5:00)
- *"Thank you for reviewing my code, write-ups, and demo. Looking forward to discussing the architecture and extending this live in the next round!"*
