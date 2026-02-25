# App Store Connect — Complete Submission Guide
# ARAPS Mobile v1.0.0

> All field values are ready to copy-paste. Complete these steps IN ORDER.
> Estimated time: 2-3 hours (mostly waiting for build processing).

---

## STEP 0: Before Opening App Store Connect

Complete these in Xcode FIRST on your Mac with Xcode installed.

### 0a. Set Your Developer Team
1. Open `ARAPropertyServiceApp.xcodeproj` in Xcode
2. Click the project in the navigator → select `ARAPropertyServiceApp` target
3. Signing & Capabilities → Team → select your Apple Developer account
4. Xcode will automatically create a provisioning profile

### 0b. Add Environment Variables
Product → Scheme → Edit Scheme → Run → Arguments → Environment Variables:
- `WORKOS_CLIENT_ID` = `[your WorkOS client ID]`
- `CONVEX_DEPLOYMENT_URL` = `[your Convex deployment URL]`
- `OPENAI_API_KEY` = `[your OpenAI API key]`

**For Release builds** (so secrets work in TestFlight/App Store):
Add these same values to the **Run** AND **Archive** scheme configurations.

### 0c. Verify Build Number
Project → ARAPropertyServiceApp target → General:
- Marketing Version: `1.0`
- Build: `1`

### 0d. Test Demo Mode
Run on a physical iPhone. Tap "View Demo" on the login screen.
Verify all 9 tabs load with sample data. This is what App Review will see.

### 0e. Archive
1. Select `Any iOS Device (arm64)` as destination
2. Product → Archive
3. Organizer opens when complete
4. Click **Distribute App → App Store Connect → Upload**

---

## STEP 1: Create App Record in App Store Connect

Go to → **appstoreconnect.apple.com → My Apps → + → New App**

| Field | Value |
|-------|-------|
| Platform | iOS |
| Name | `ARAPS Mobile` |
| Primary Language | `English (Australia)` |
| Bundle ID | `com.arapropertyservices.araps` |
| SKU | `araps-mobile-v1-0` |
| User Access | Limited Access (keep private during review) |

Click **Create**.

---

## STEP 2: App Information

Go to → **App Information** (left sidebar)

| Field | Value |
|-------|-------|
| Name | `ARAPS Mobile` |
| Subtitle | `Property Services Field Manager` |
| Category (Primary) | **Business** |
| Category (Secondary) | **Productivity** |
| Content Rights | ☑ Does not use third-party content |
| Age Rating | Set in Step 5 |

**Privacy Policy URL:**
```
https://danmarauda.github.io/araps-mobile-app/privacy.html
```

Click **Save**.

---

## STEP 3: Version Information (1.0 Prepare for Submission)

Go to → **iOS App → 1.0 Prepare for Submission**

### Description (copy exactly — max 4000 chars)
```
ARAPS Mobile is the complete field management platform for ARA Property Services teams — built for field workers, site supervisors, and executives.

FEATURES

Executive Dashboard
Real-time operations overview with KPI tracking, safety alert monitoring, team status, and facility compliance scores — all in one glanceable dashboard.

Task Management
View and update your field tasks in real time. Filter by status and priority, see scheduled times, and mark tasks complete as you work.

Issue Reporting
Report facility issues directly from the field. Set priority and category, assign location, and track resolution status through the full lifecycle.

CleanOps
Scan QR codes at any location to check in, log visits, or immediately report a cleaning alert. Pre-fills location data from the scanned code.

Facility Portfolio
Browse all managed facilities with compliance ratings, service schedules, access instructions, and client information.

Team Directory
Full contact directory for field workers, supervisors, and managers. Tap to call, message, or email directly from the contact card.

AskARA — AI Assistant
Ask questions about your operations in natural language. Get instant answers about tasks, issues, facilities, and compliance.

Reports & Analytics
View compliance rates, task completion statistics, and safety alert trends across your portfolio.

AUTHENTICATION
• Sign in with WorkOS AuthKit for enterprise SSO
• Sign in with Apple for quick personal access
• Face ID / Touch ID for fast re-authentication
• Demo Mode — explore with pre-loaded sample data

DESIGNED FOR THE FIELD
• Works offline with local SwiftData storage
• Dark mode interface optimised for outdoor use
• Pull-to-refresh for real-time data sync
• Deep link support for quick navigation
```

### Promotional Text (max 170 chars — editable without new build)
```
The complete field operations platform for ARA Property Services. Dashboard, tasks, issues, CleanOps, and AI assistant in one app.
```

### Keywords (max 100 bytes — no spaces after commas)
```
facilities,cleaning,property,field service,compliance,tasks,issues,operations,commercial,inspection
```

### Support URL
```
https://danmarauda.github.io/araps-mobile-app/support.html
```

### Marketing URL (optional)
```
https://danmarauda.github.io/araps-mobile-app/
```

### What's New (first version — leave blank or write)
```
Initial release of ARAPS Mobile — the field management platform for ARA Property Services teams.
```

### Version: `1.0`
### Copyright: `© 2026 ARA Property Services`
### Routing App Coverage File: Leave blank

---

## STEP 4: App Review Information

Go to → **App Review Information** section

| Field | Value |
|-------|-------|
| First Name | [your first name] |
| Last Name | [your last name] |
| Phone Number | [your phone with country code, e.g. +61412345678] |
| Email | [your email — must be monitored during review] |
| Demo Account Username | (leave blank — using Demo Mode instead) |
| Demo Account Password | (leave blank) |

**Notes for Review (copy exactly):**
```
ARAPS Mobile is an enterprise field management app for ARA Property Services staff.

HOW TO ACCESS THE APP:
Tap the "View Demo" button on the login screen, then tap "Continue to Demo".
This opens a guest session with pre-loaded sample data — no WorkOS account required.

WHAT TO EXPECT:
• Demo Mode auto-loads sample facilities, tasks, issues, contacts, and cleaning alerts
• All 9 tabs are fully functional with the sample data
• The AI chat (AskARA) requires an OpenAI API key — responses will show a "not configured" message in the review build

FEATURES REQUIRING HARDWARE:
• QR scanner (CleanOps tab) requires camera — best tested on physical device
• Face ID / Touch ID login requires a compatible device (appears only after first sign-in)

ACCOUNT DELETION:
To test account deletion, sign in with Apple Sign-In first, then go to Settings → Delete Account. The two-step confirmation will delete all local data and sign out.

DEEP LINKS (optional testing):
• araps://tasks — navigates to Tasks tab
• araps://issues — navigates to Issues tab
• araps://cleanops — navigates to CleanOps tab
```

---

## STEP 5: Age Rating Questionnaire

Go to → **Age Rating** → Edit

Answer each question:

| Question | Answer |
|----------|--------|
| Cartoon or Fantasy Violence | **None** |
| Realistic Violence | **None** |
| Prolonged Graphic or Sadistic Violence | **None** |
| Sexual Content and Nudity | **None** |
| Profanity and Crude Humor | **None** |
| Mature/Suggestive Themes | **None** |
| Horror or Fear Themes | **None** |
| Medical/Treatment Information | **None** |
| Alcohol, Tobacco, or Drug Use or References | **None** |
| Simulated Gambling | **None** |
| Unrestricted Web Access | **No** |

**Capability Declarations (new in 2026 — MUST complete):**

| Capability | Answer |
|------------|--------|
| Messaging or Chat | **Yes** ← ChatView (AskARA) is one-on-one AI messaging |
| User-Generated Content visible to others | **No** — content is org-private |
| Advertising | **No** |
| Parental Controls | **No** |
| Age Assurance | **No** |

**Result: 4+** (the messaging/chat declaration does NOT increase the rating — it's internal AI chat, not social UGC)

Click **Done**.

---

## STEP 6: Privacy Nutrition Labels

Go to → **App Privacy** → Get Started

### Question 1: Does your app collect data?
**Yes**

### Question 2: Is any of the data linked to the user's identity?
**Yes**

### Data Types to declare:

**Contact Info**
- Email Address ✓
  - Used for: App Functionality
  - Linked to identity: Yes
  - Used for tracking: No

**Identifiers**
- User ID ✓
  - Used for: App Functionality
  - Linked to identity: Yes
  - Used for tracking: No

**User Content**
- Customer Support / Chat Messages ✓ (AskARA chat)
  - Used for: App Functionality
  - Linked to identity: No
  - Used for tracking: No

**Data Not Collected:**
- Do NOT declare: Name separately (it's part of authentication, same as email)
- Do NOT declare: Location (no location features)
- Do NOT declare: Photos/Camera (QR scan doesn't capture images)
- Do NOT declare: Health, Finance, Contacts, Browsing History, etc.

Click **Publish** when satisfied.

---

## STEP 7: Pricing and Availability

Go to → **Pricing and Availability**

| Field | Value |
|-------|-------|
| Price | **Free** |
| Availability | **All Countries and Regions** (or restrict to Australia if preferred) |
| Pre-Order | No |

---

## STEP 8: EU Trader Status (REQUIRED if distributing in EU)

Go to → **Users and Access → Developer Profile → Trader Status**

- Declare your trader status (professional/commercial use = Trader)
- Verify email via 2FA
- Verify phone via 2FA
- Enter: Legal name, address, phone, email

**If you do NOT want EU distribution:** Go to Pricing and Availability → deselect all EU countries (Belgium, France, Germany, Italy, Spain, etc.)

---

## STEP 9: Screenshots

### Take Screenshots (automated):
```bash
cd /path/to/ios-araps-mobile-app-main
fastlane screenshots
```

This runs on iPhone 16 Pro Max (6.9"), iPhone 15 Plus (6.7"), and iPhone 8 Plus (5.5") automatically.

Screenshots save to `./fastlane/screenshots/en-AU/`

### Upload to App Store Connect:
Go to → **1.0 Prepare for Submission → iPhone Screenshots**

Upload for each device size from `./fastlane/screenshots/en-AU/`:
- **6.9" (iPhone 16 Pro Max)** — required for new apps
- **6.7" (iPhone 15 Plus)** — required
- **5.5" (iPhone 8 Plus)** — required

Drag files in this order for best App Store presentation:
1. `02_Dashboard_*.png` — Executive Dashboard
2. `03_Tasks_*.png` — Task management
3. `04_Issues_*.png` — Issue tracking
4. `05_CleanOps_*.png` — CleanOps QR
5. `06_Facilities_*.png` or `07_Contacts_*.png`

---

## STEP 10: Select Build and Submit

1. Wait for Xcode build to finish processing in ASC (15-60 min after upload)
2. You'll receive an email: "Your submission was accepted" or "Your submission has an issue"
3. Go to **1.0 Prepare for Submission → Build** → click **+** → select your build
4. Review all sections — any orange warnings must be resolved

### Final pre-submit check:
- [ ] Description filled in ✓
- [ ] Screenshots uploaded for all 3 sizes ✓
- [ ] Support URL accessible ✓
- [ ] Privacy Policy URL returns 200 OK ✓ (test: open in browser)
- [ ] Age Rating set ✓
- [ ] Privacy Nutrition Labels published ✓
- [ ] App Review notes filled in ✓
- [ ] Build selected ✓

5. Click **Submit for Review**
6. Answer encryption question: **No, this app does not use non-exempt encryption** ✓
7. Confirm submission

---

## STEP 11: After Submission

| What | When |
|------|------|
| Status: "Waiting for Review" | Immediately |
| Status: "In Review" | Usually within 24 hours |
| Decision | 90% of apps reviewed in under 24 hours |
| Check for messages | ASC → Resolution Center (check daily) |

**If rejected:** Read the FULL rejection text. Fix ALL cited issues. Run the Axiom pre-flight checklist again before resubmitting. Do not resubmit without addressing every cited guideline.

**If approved:** The app will appear as "Pending Developer Release" — click **Release This Version** to go live immediately, or set a scheduled release date.

---

## Useful URLs After Live

| Resource | URL |
|----------|-----|
| App Store Connect | https://appstoreconnect.apple.com |
| Privacy Policy | https://danmarauda.github.io/araps-mobile-app/privacy.html |
| Terms of Service | https://danmarauda.github.io/araps-mobile-app/terms.html |
| Support | https://danmarauda.github.io/araps-mobile-app/support.html |
| GitHub Repo | https://github.com/danmarauda/araps-mobile-app |
| Resolution Center | ASC → My Apps → App Name → Resolution Center |

---

*Generated using Axiom iOS App Store submission skills — axiom-app-store-submission + axiom-app-store-ref*
