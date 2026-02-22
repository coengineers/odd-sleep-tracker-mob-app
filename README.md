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

