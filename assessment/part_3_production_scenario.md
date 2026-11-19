# Part 3: Production Release Scenario (v6.4.0 Crash Spike)

## 1. Message to the Founder (Slack / Chat)

> **Hey Anik,**  
> I've just **halted the 20% rollout** of v6.4.0 on the Play Store Console.  
> 
> Here's why: A drop from 99.6% to 98.1% crash-free users means ~15,000 crashes per million sessions. Because this crash occurs on **app resume**, teenagers returning to the app are getting kicked out repeatedly. Crashing on resume not only destroys ad revenue for those users entirely, but also triggers an avalanche of 1-star Play Store reviews and permanent uninstalls on budget devices.  
> 
> The other 80% of our user base is safe on v6.3.x earning revenue normally. I'm actively profiling the native ad bridge logs and will share root-cause diagnostics and an ETA for a v6.4.1 hotfix within the next 90 minutes.

---

## 2. Day-1 Investigation Plan

### Step 1: Crashlytics Deep-Dive
1. **Analyze Crash Velocity & Issue Grouping:**
   - Check if this `PlatformException` is consolidated into a single issue cluster or spread across multiple ad formats (e.g., Banner vs. Interstitial vs. Rewarded video).
   - Inspect the exact exception message, error code, and method channel details (e.g., `PlatformException(ad_load_error, Cannot load ad when activity is destroyed, null)` or `Texture not found for surface ID`).
2. **Breadcrumbs & User Timeline:**
   - Inspect the last 5 breadcrumb events prior to the crash:
     - Did the user navigate to a specific screen (e.g., Earnings or Projects)?
     - Was an ad currently visible or being refreshed when the app moved to background?
     - Did the crash occur inside `AppLifecycleState.resumed` or during an ad completion callback?
3. **Rollout Cohort Comparison:**
   - Filter Crashlytics logs by custom keys (e.g., `user_tier`, `device_ram`, `ad_network_source`).

---

### Step 2: Device & Android OS Pattern Analysis
Target audience context: Funngro runs heavily on ₹8,000 Indian budget devices (2GB–3GB RAM, Android Go / entry-level chipsets).

1. **Android OS Distribution:**
   - Check if the crash correlates with **Android 13 / 14 / 15** background execution restrictions or changes in `Activity` lifecycle management.
2. **OEM Custom Skin Vulnerabilities:**
   - Low-end devices from Xiaomi (MIUI / HyperOS), Realme, and Samsung (OneUI Core) enforce aggressive background process killing (`LowMemoryKiller`).
   - When the app is backgrounded, the OS often terminates the underlying native `WebView` render process or invalidates the OpenGL/Vulkan `SurfaceTexture` used by Flutter's hybrid composition / platform views.
   - Upon app resume, Flutter attempts to rebind to a dead surface or disposed texture handle, throwing an unhandled native `PlatformException`.
3. **RAM & Hardware Profile:**
   - Verify if crashes are skewed toward devices with `< 3GB RAM` under memory pressure where the native ad view was silently destroyed while the Dart VM survived.

---

### Step 3: Code Diff & Lifecycle Investigation (v6.3.x vs v6.4.0)
Even though the Ad SDK dependency was not updated in this release, our own Flutter code changed:
1. **Lifecycle Observers:**
   - Check Git diff for any modifications to `WidgetsBindingObserver.didChangeAppLifecycleState`, deep link handlers, or splash/resumption logic that triggers ad reloads before the Flutter engine view is re-attached.
2. **Navigation Stack / Route Changes:**
   - Did v6.4.0 introduce a route observer or modal bottom sheet that steals focus or rebuilds screens holding active banner listeners?
3. **Flutter Engine / Dependency Sub-versions:**
   - Check if a transient dependency or Gradle build update changed Flutter's `surface_producer` or Android embedding lifecycle hooks.

---

### Step 4: Decision Framework (Halt vs. Hold vs. Fix-Forward)

| Decision | When to Choose | Decision for Current Situation |
| :--- | :--- | :--- |
| **Halt Rollout** | Drop below 99.0% crash-free sessions; crash impacts primary user loop (e.g., app launch, app resume); risk of store rating collapse. | **CHOSEN IMMEDIATELY:** A 98.1% crash-free rate is unacceptable in production. Halting freezes the issue at 20% while 80% remain rock-solid. |
| **Hold at 20%** | Crash is non-fatal or isolated to an obscure edge case (e.g., custom ROMs with <0.02% traffic); core loop unaffected; business cost of halting exceeds user dissatisfaction. | **REJECTED:** Resume crashes destroy user retention and prevent the very ad impressions we seek to monetize. |
| **Fix-Forward** | Root cause is clearly identified, reproducible in under 30 minutes, and a verified patch can be shipped and approved within hours. | **PURSUING NOW:** Prepare v6.4.1 hotfix with guarded resume handlers, test on low-end test device, and request Google Play expedited review. |

---

## 3. Remote Config & Feature Flag Strategy

### The Lever We Wish We Had:
If we had implemented a **dynamic Remote Config ad kill-switch**, we would not need to halt the rollout or wait hours for Google Play review. Within 3 minutes of detecting the crash spike, we could update Firebase Remote Config:
```json
{
  "ad_sdk_enabled": true,
  "ad_reload_on_resume_enabled": false,
  "ad_surface_fallback_mode": "static_banner"
}
```
This would instantly stop the offending resume-ad callback across all 20% active rollout devices worldwide, keeping the v6.4.0 release in the field and preserving all other non-resume ad impressions.

### Production Rule:
**Would we have shipped one?**
**Yes, absolutely.** Ad SDKs and third-party native SDKs are historically the #1 source of uncatchable native crashes on fragmented Android ecosystems. Every third-party SDK integration in Funngro must have:
1. **Master Kill-Switch:** `remote_config.getBool('enable_ad_sdk')`
2. **Granular Feature Flags:** Per-placement toggles (e.g., `resume_ad_enabled`, `interstitial_payout_enabled`).
3. **Defensive Error Handling:** Native platform channel calls wrapped in `try/catch (PlatformException)` with fallback to a lightweight local asset or graceful silence rather than an uncaught exception.
