# ARAPS Mobile — App Store Submission Guide

## Prerequisites Checklist

Before opening Xcode on your Mac with Xcode installed:

### 1. Configure Environment Variables (Required)
Add these to your Xcode scheme (Product → Scheme → Edit Scheme → Run → Arguments → Environment Variables):

| Variable | Where to Get |
|----------|-------------|
| `WORKOS_CLIENT_ID` | WorkOS Dashboard → API Keys |
| `CONVEX_DEPLOYMENT_URL` | Convex Dashboard → Settings → Deployment URL |
| `OPENAI_API_KEY` | platform.openai.com → API Keys (for AskARA chat) |

### 2. Configure Code Signing (Required)
In Xcode, select the project → ARAPropertyServiceApp target → Signing & Capabilities:
- Set **Team** to your Apple Developer account team
- Bundle ID is currently `com.arapropertyservices.araps` — change if needed

### 3. Register Bundle ID (Required)
If this is your first build:
1. Go to developer.apple.com → Certificates, Identifiers & Profiles
2. Register `com.arapropertyservices.araps` (or your chosen ID)
3. Enable capabilities: **Sign in with Apple**, **Associated Domains**

### 4. Associated Domains (Required)
The app uses `araps.aliaslabs.ai` for universal links. You must either:
- Set up the AASA file at `https://araps.aliaslabs.ai/.well-known/apple-app-site-association`
- Or remove the associated domain entitlement from `ARAPSMobileApp.entitlements`

---

## Build Steps

### Step 1: Open project
```bash
open ARAPropertyServiceApp.xcodeproj
```

### Step 2: Resolve SPM dependencies
Xcode → File → Packages → Resolve Package Versions

### Step 3: Set team
Select ARAPropertyServiceApp target → Signing & Capabilities → Team → your team

### Step 4: Add scheme environment variables
Product → Scheme → Edit Scheme → Run → Arguments → Environment Variables:
- `WORKOS_CLIENT_ID` = your WorkOS client ID
- `CONVEX_DEPLOYMENT_URL` = your Convex URL
- `OPENAI_API_KEY` = your OpenAI API key

### Step 5: Run tests
Product → Test (⌘U)

### Step 6: Test on device
- Connect iPhone (iOS 18+)
- Select device in toolbar
- Product → Run (⌘R)
- Test: auth flow, QR scanner, biometrics, chat

### Step 7: Archive for App Store
1. Select "Any iOS Device (arm64)" as destination
2. Product → Archive
3. Xcode Organizer opens automatically

---

## App Store Connect Setup

### Create App Record
1. Go to appstoreconnect.apple.com
2. My Apps → + → New App
3. Fill in:
   - **Platform**: iOS
   - **Name**: ARAPS Mobile
   - **Primary Language**: English (Australia)
   - **Bundle ID**: com.arapropertyservices.araps
   - **SKU**: araps-mobile-v1

### App Information
```
Category: Business (Primary), Productivity (Secondary)
Age Rating: 4+ (no objectionable content)
Price: Free (internal enterprise app) or set pricing

Short Description (170 chars):
ARA Property Services field management app. Track tasks, report issues, manage facilities, and communicate with your team — all in one place.

Full Description:
ARAPS Mobile is the complete field management platform for ARA Property Services teams.

FEATURES:
• Executive Dashboard — Real-time KPIs, safety alerts, and team overview
• Task Management — View and update field tasks with priority tracking
• Issue Reporting — Report and track facility issues with photo documentation
• CleanOps — QR code scanning for location check-in and alert reporting
• Facility Management — Browse and manage your property portfolio
• Team Directory — Contact field workers, supervisors, and managers
• AskARA AI — AI-powered assistant for operational queries
• Reports — Compliance and performance analytics

AUTHENTICATION:
• WorkOS Enterprise SSO for corporate accounts
• Sign in with Apple for individual access
• Face ID / Touch ID for quick re-authentication

Keywords (100 chars):
facilities,cleaning,property,management,field service,compliance,tasks,issues,operations,commercial
```

### Screenshots Required
Take screenshots from Xcode Simulator for:
- **6.7" iPhone** (iPhone 15 Pro Max) — Required
- **6.5" iPhone** (iPhone 14 Plus) — Required  
- **5.5" iPhone** (iPhone 8 Plus) — Required
- **12.9" iPad Pro** — Required if supporting iPad

Recommended screens to capture:
1. Login screen
2. Executive Dashboard
3. Tasks list
4. Issue detail
5. CleanOps with QR scanner
6. AskARA chat

### Privacy Policy (Required)
You must host a privacy policy URL. Minimum content:
- What data is collected (email, name via WorkOS/Apple)
- How it's stored (local SwiftData, Convex cloud)
- Data retention policy
- Contact information

Host at: `https://araps.aliaslabs.ai/privacy` (or any stable URL)

### Support URL (Required)
`https://araps.aliaslabs.ai/support` (or email as URL: `mailto:support@ara.com.au`)

---

## App Review Notes

When submitting, add these notes for the App Store reviewer:

```
This is an enterprise field management application for ARA Property Services staff.

Login: This app uses WorkOS Enterprise SSO and Apple Sign In. 
For review, please use the Sign in with Apple option which will work 
without requiring our corporate SSO setup.

Test Apple Sign In: Use any valid Apple ID to sign in. 
The app will create a local account and show sample data.

Features requiring physical hardware:
- QR scanner requires camera (use a real device to test)
- Face ID requires a compatible device

All other features work on simulator with sample data loaded on first launch.
```

---

## Final Pre-Submission Checklist

- [ ] Set `DEVELOPMENT_TEAM` in Xcode (not in project.pbxproj)
- [ ] Update bundle ID if not using `com.arapropertyservices.araps`
- [ ] Configure all environment variables in scheme
- [ ] Test WorkOS login flow end-to-end
- [ ] Test Apple Sign-In
- [ ] Test on physical device (camera, Face ID)
- [ ] Test offline mode (SwiftData works without network)
- [ ] Confirm `CONVEX_DEPLOYMENT_URL` points to production Convex
- [ ] Confirm `WORKOS_CLIENT_ID` is production (not sandbox)
- [ ] Host privacy policy at your URL
- [ ] Create app record in App Store Connect
- [ ] Upload 1024x1024 app icon (already done: `Assets.xcassets/AppIcon.appiconset/icon.png`)
- [ ] Take screenshots for all required device sizes
- [ ] Archive and validate with Xcode Organizer
- [ ] Upload to App Store Connect
- [ ] Complete App Privacy questionnaire (collects email, name — linked to identity)
- [ ] Submit for review

---

## Post-Submission

- Review typically takes 1-3 business days
- Monitor for rejections at appstoreconnect.apple.com
- Common rejection reasons for this app:
  - Missing privacy policy URL → Add one before submitting
  - Sign in with Apple button styling → Already implemented correctly
  - Associated domains not working → Check AASA file setup

---

## Secrets Management for Production

For production builds, move secrets from environment variables to either:

**Option A: xcconfig files** (recommended)
```
# Config.xcconfig (gitignored)
WORKOS_CLIENT_ID = your_actual_client_id
CONVEX_DEPLOYMENT_URL = https://your-deployment.convex.cloud
OPENAI_API_KEY = sk-your-key
```

Add to `Info.plist`:
```xml
<key>WORKOS_CLIENT_ID</key>
<string>$(WORKOS_CLIENT_ID)</string>
```

**Option B: Keychain on first launch**
Store secrets in Keychain at first run (requires a configuration backend).
