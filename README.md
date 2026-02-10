## Create Mobile App With CC Workflow

### Setup Android Emulator (Optional) 

## 1) One-time setup (Android Studio / SDK / AVD)

1. Install **Android Studio**
2. Open Android Studio → **SDK Manager**

   * Install:

     * **Android SDK Platform** (pick at least one, e.g. API 34/35)
     * **Android SDK Platform-Tools** (gives you `adb`)
     * **Android Emulator**
3. Android Studio → **Device Manager** (or AVD Manager) → **Create device**

   * Pick a device (e.g. Pixel)
   * Pick a system image (download if needed)
   * Finish → you now have an **AVD** (emulator profile)

## 2) Start the emulator from VS Code

In VS Code → **Terminal**:

1. Instal `Android iOS Emulator` 
    Extension > search `Android iOS Emulator`

2. List available emulator profiles (AVDs):

```bash
emulator -list-avds
```

3. Start one:

```bash
emulator -avd <AVD_NAME>
```

Example:

```bash
emulator -avd Pixel_7_API_34
```

Optional helpful flags:

```bash
emulator -avd Pixel_7_API_34 -wipe-data
emulator -avd Pixel_7_API_34 -no-snapshot-load
```

### How to Start the Flutter App

#### Prerequisites

- Flutter SDK 3.38+ (stable channel) with Dart 3.10+
- A connected device or running emulator (`flutter devices` to verify)

#### Steps

1. **Install dependencies**

```bash
flutter pub get
```

2. **Run the app**

```bash
flutter run
```

To target a specific device (if multiple are connected):

```bash
flutter run -d <DEVICE_ID>
```

Use `flutter devices` to list available device IDs.

3. **Run tests**

```bash
flutter test
```

---

### **Project Setup To Build From Scratch**

1. Either Replace `/docs/PRD_AGENT_TEMPLATE.md`  with Already Generated `/docs/PRD.md`  or ask agent to create one for you using this template.
2. Install Skills  
- Flutter:  
```
npx skills add https://github.com/jeffallan/claude-skills --skill flutter-expert
```

3. Initialise Spec-kit

```
specify init .
```

4. Create Constitution

```
/speckit.constitution Update constitution with '/docs/PRD.md'
/speckit.constitution Update constitution with 'docs/brand-kit.md'
```

5. Run first cycle of spec-kit

```
/speckit.specify Impelement D0 '/docs/PRD.md'
```

6. Ask Agent to create a quickstart if not Created.
    - Usually consisits of:
        - Configure environment
        - Start the app

7. Run second cycle of spec-kit

```
/speckit.specify Impelement D1 from '/docs/PRD.md'
```

