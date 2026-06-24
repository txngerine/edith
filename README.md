# EDITH
### Even Dead Im The Hero

> A privacy-first ephemeral messaging app built with Flutter + Supabase.
> No accounts. No traces. No permanence.

---

## Philosophy

EDITH is built on three principles:

- **Private by default** — anonymous identity, no email, no phone number required
- **Temporary by nature** — messages expire, media self-destructs, identities rotate
- **Secure by design** — vault protection, secret codes, ghost mode, emergency wipe

---

## Features

| Feature | Description |
|---|---|
| Anonymous auth | Sign in with zero personal information |
| Daily identity rotation | Handle changes every 24 hours automatically |
| Ephemeral messages | Every message has a configurable expiry |
| Secure media transmission | Images and videos expire after viewing |
| Vault | Save media permanently using secret codes |
| QR connect | Add contacts by scanning a QR code |
| Invite tokens | One-time tokens that expire in 24 hours |
| Ghost mode | Hide activity, read receipts, typing indicators |
| Screenshot detection | Get notified when someone screenshots |
| Burn chat | Permanently destroy an entire conversation |
| Emergency wipe | Delete everything from the device instantly |
| Data purity dashboard | Track how much data has been destroyed |
| Storage health | Monitor vault and media usage |

---

## Screens

```
1.  Splash Screen
2.  Onboarding
3.  Identity Dashboard
4.  Messages List
5.  Terminal Chat
6.  Media Send (Image)
7.  Image Viewer
8.  Video Viewer
9.  Secret Code Unlock
10. Vault
11. Discover / Scan
12. Privacy Command Center
13. Burn Chat Confirmation
14. Emergency Wipe
15. Data Purity Dashboard
16. Storage Health
17. Settings
```

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x |
| Backend | Supabase (Auth, Database, Realtime, Storage) |
| State | setState + Supabase streams |
| Auth | Anonymous sign-in (no credentials required) |
| Database | PostgreSQL with Row Level Security |
| Realtime | Supabase Realtime (message subscriptions) |
| Local storage | shared_preferences + flutter_secure_storage |
| Video | video_player |
| Camera / QR | image_picker, mobile_scanner |
| Fonts | Space Mono via google_fonts |
| Animations | flutter_animate |

---

## Design System

```
Background        #080808
Surface           #111111
Card              #161616
Border            #222222
Accent green      #2ECC71
Accent dim        #1A7A43
Danger red        #E74C3C
Danger dim        #7A1E16
Text primary      #EEEEEE
Text secondary    #888888
Text dim          #444444

Font              Space Mono (monospace)
Border radius     4px (sharp, terminal aesthetic)
```

---

## Project Structure

```
edith/
├── lib/
│   ├── main.dart                        # App entry, Supabase init
│   ├── theme/
│   │   └── app_theme.dart               # Colors, typography, component themes
│   ├── services/
│   │   └── supabase_service.dart        # All Supabase calls
│   ├── widgets/
│   │   └── common_widgets.dart          # Shared UI components
│   └── screens/
│       ├── splash_screen.dart
│       ├── onboarding_screen.dart
│       ├── home_screen.dart             # Bottom nav shell
│       ├── identity_dashboard_screen.dart
│       ├── messages_list_screen.dart
│       ├── chat_screen.dart             # Terminal-style chat
│       ├── media_send_screen.dart
│       ├── image_viewer_screen.dart
│       ├── video_viewer_screen.dart
│       ├── secret_code_screen.dart
│       ├── vault_screen.dart
│       ├── scan_screen.dart
│       ├── privacy_screen.dart
│       ├── burn_chat_screen.dart
│       ├── emergency_wipe_screen.dart
│       ├── data_purity_screen.dart
│       ├── storage_health_screen.dart
│       └── settings_screen.dart
├── supabase_schema.sql                  # Full DB schema
├── rls_policies.sql                     # Row Level Security policies
└── pubspec.yaml
```

---

## Setup

### 1. Supabase project

1. Create a project at [supabase.com](https://supabase.com)
2. Go to **SQL Editor** and run `supabase_schema.sql`
3. Then run `rls_policies.sql`
4. Go to **Authentication → Sign In / Providers** and enable **Anonymous sign-ins**

### 2. Flutter

```bash
# Clone or unzip the project
cd edith

# Install dependencies
flutter pub get
```

### 3. Add credentials

Open `lib/main.dart` and replace:

```dart
const _supabaseUrl = 'YOUR_SUPABASE_URL';
const _supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

Find these under **Supabase Dashboard → Project Settings → API**.

### 4. Android permissions

In `android/app/src/main/AndroidManifest.xml`, add inside `<manifest>`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO"/>
```

### 5. iOS permissions

In `ios/Runner/Info.plist`, add:

```xml
<key>NSCameraUsageDescription</key>
<string>EDITH needs camera access for QR scanning and media capture</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>EDITH needs photo library access to send secure media</string>
<key>NSMicrophoneUsageDescription</key>
<string>EDITH needs microphone access for voice messages</string>
```

### 6. Run

```bash
flutter run
```

---

## Supabase Schema Overview

```
auth.users          ← managed by Supabase Auth
    │
    ├── identities          user handles, rotated daily
    ├── channel_members     which channels a user belongs to
    ├── messages            ephemeral messages with expires_at
    ├── vault_items         permanently saved media (secret code protected)
    ├── user_stats          purity score, destruction counts
    └── invite_tokens       one-time connect tokens (24h expiry)

channels            conversation rooms
    └── messages    belong to a channel
```

All tables use **Row Level Security**. Anonymous users get the `authenticated` role in Supabase and pass through all RLS policies identically to registered users.

---

## How Anonymous Auth Works

1. User opens app → taps Continue on onboarding
2. `supabase.auth.signInAnonymously()` is called
3. Supabase creates a real user row in `auth.users` with a UUID, no email
4. A JWT session is issued and persisted to device storage
5. All RLS policies use `auth.uid()` — works identically for anonymous users
6. On next app launch, session is restored from storage automatically

**Limitation:** if the user clears app data or uninstalls, the session is gone with no recovery path. This is intentional — EDITH is ephemeral by design.

**Optional upgrade path:** if a user later wants to claim their account:
```dart
await supabase.auth.updateUser(
  UserAttributes(email: 'email@example.com', password: 'password'),
);
```
This converts the anonymous user to a permanent account without losing any data.

---

## Cleanup Edge Function

Deploy this as a Supabase Edge Function on a schedule to purge expired messages:

```typescript
// supabase/functions/cleanup/index.ts
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

Deno.serve(async () => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  )

  const { count } = await supabase
    .from('messages')
    .delete()
    .lt('expires_at', new Date().toISOString())
    .select('*', { count: 'exact', head: true })

  return new Response(JSON.stringify({ deleted: count ?? 0 }))
})
```

Schedule it via **Supabase Dashboard → Edge Functions → Schedule**.

---

## Known Issues

| Issue | Status | Notes |
|---|---|---|
| Anonymous toggle resets visually on dashboard refresh | Supabase dashboard bug | Setting is saved, ignore it |
| Video player requires valid network URL | By design | Local video preview not supported |
| Vault grid shows placeholder without Supabase Storage | Expected | Wire up storage bucket for real media |

---

## Roadmap

- [ ] Push notifications via FCM + Supabase webhooks
- [ ] Biometric lock for vault
- [ ] Voice messages
- [ ] Disappearing media (view-once enforcement)
- [ ] Nearby discovery via geolocation
- [ ] Identity QR code generation
- [ ] End-to-end encryption layer

---

## License

Private. All rights reserved.

---

*EDITH — Even Dead Im The Hero*
*Private by default. Temporary by nature. Secure by design. Yours by choice.*