# EternalOS

EternalOS is an experimental Android "overlay OS" built with Flutter. It provides a lightweight overlay on top of Android that continuously recognizes user context and enables AI-driven automations and suggestions. Think of it as an intelligent, extensible shell that observes what's happening on the device, interprets context, and helps automate repetitive tasks or surface relevant actions.

Status: Early-stage • Flutter-based prototype for Android overlays and accessibility-based context recognition.

---

## Key ideas

- Overlay UI that runs above other apps (draw-over + accessibility-based monitoring).
- Context recognition using a mix of heuristics, on-device models, and cloud LLMs / perception services.
- Rule-based and AI-driven automations (trigger -> condition -> action).
- Privacy-first: local processing where possible; opt-in cloud integrations.
- Extensible: plugin-like actions and custom automation scripting.

---

## Features

- Persistent overlay widget with compact UI for suggestions and quick automations.
- Context recognition:
  - App and screen title detection (via accessibility events).
  - Detected user intent (e.g., "reading", "shopping", "travel", "meeting").
  - On-device signals (location, time, battery) and optional sensors.
- Automation engine:
  - Rule-based automations (simple triggers and actions).
  - AI-curated suggestions (LLM suggests automations from detected context).
- Integration points:
  - Local actions (open app, toggle settings, create calendar event).
  - External services (webhooks, cloud LLMs, task managers).
- Developer-friendly: add new actions / context recognizers in a modular way.

---

## Architecture (high level)

- Flutter UI layer (overlay widgets)
- Android platform layer (permissions, AccessibilityService, window overlay)
- Context recognition layer
  - Accessibility event listener
  - Heuristics + classifiers (on-device / cloud)
- Automation engine
  - Trigger matcher
  - Action dispatcher
- Integrations / plugins
  - AI provider adapters
  - External service connectors
- Data & privacy layer
  - Local store (encrypted)
  - Consent manager & telemetry controls

---

## Quick start (development)

Prerequisites:
- Flutter SDK (stable channel recommended)
- Android SDK & platform tools
- Java/Kotlin toolchain for Android
- A physical Android device (recommended) or emulator supporting overlays and accessibility

Steps:
1. Clone repository
   ```bash
   git clone https://github.com/<your-org>/EternalOS.git
   cd EternalOS
   ```
2. Install dependencies
   ```bash
   flutter pub get
   ```
3. Enable required Android permissions (see Android setup below).
4. Run on device
   ```bash
   flutter run -d <device-id>
   ```
5. To build a release APK
   ```bash
   flutter build apk --release
   ```

Android setup (permissions & manifest)
- Required runtime permissions:
  - SYSTEM_ALERT_WINDOW (draw over other apps) — request via Settings overlay permission flow.
  - BIND_ACCESSIBILITY_SERVICE — declare AccessibilityService and prompt user to enable it in settings.
  - (Optional) LOCATION, NOTIFICATIONS, CONTACTS depending on enabled automations.
- Example manifest entries:
  ```xml
  <!-- AndroidManifest.xml: service declaration for AccessibilityService -->
  <service android:name=".platform.AndroidEternalAccessibilityService"
           android:permission="android.permission.BIND_ACCESSIBILITY_SERVICE">
    <intent-filter>
      <action android:name="android.accessibilityservice.AccessibilityService" />
    </intent-filter>

    <meta-data
        android:name="android.accessibilityservice"
        android:resource="@xml/accessibility_service_config" />
  </service>
  ```
- Request draw-over permission at runtime:
  - Use Settings.ACTION_MANAGE_OVERLAY_PERMISSION intent to open the system dialog.

Permissions and accessibility are sensitive. Make sure flows clearly explain to the user why permissions are needed.

---

## Usage

- After installation and permission granting, the overlay appears as a floating control.
- The overlay shows contextual suggestions (e.g., "Create meeting note", "Open shopping list") based on the current app and screen.
- Tap a suggestion to run the automation or to edit/confirm before execution.
- Manage automations from the main settings screen: enable/disable, edit triggers, view history.

Example automation (YAML-like pseudo rule)
```yaml
- id: save_receipt_to_drive
  trigger:
    app: "com.example.shopping"
    contains_text: ["Order confirmation", "Receipt"]
  condition:
    battery_level_above: 20
  action:
    - capture_screenshot
    - upload_to: "google-drive:/EternalOS/Receipts"
    - notify: "Saved receipt to Drive"
```

AI suggestion example:
- When EternalOS detects you are on a checkout screen, it may suggest: "Save receipt to Drive and set a calendar reminder for delivery date." The user confirms and EternalOS creates the automation.

---

## AI & Models

EternalOS is model-agnostic. Typical setups:
- On-device lightweight models:
  - TensorFlow Lite for fast classification / intent detection (recommended for privacy & offline).
- Cloud LLMs / APIs (optional):
  - OpenAI, Anthropic, or private LLM endpoints for complex intent extraction and suggestion generation.
  - Use cloud only by explicit user opt-in.
- Hybrid approach:
  - On-device model detects coarse intent; cloud LLM refines suggestions when consented.

Security & privacy:
- Strip/obfuscate PII before sending to cloud.
- Provide clear settings to disable cloud processing or delete logs.
- Use encrypted storage for local model outputs or automation history.

---

## Data flow & privacy summary

1. AccessibilityService observes screen events (titles, text).
2. Local context recognizer extracts signals and builds a context object.
3. If user has enabled cloud features, the context (minimized & anonymized) can be sent to an AI provider to generate suggestions.
4. Suggestions are shown on the overlay; automations run only with user confirmation (or if user enabled trusted automatic execution).
5. Logs and automation history are stored locally and can be cleared by the user.

Always show the user what is sent externally and provide toggles for telemetry & cloud AI usage.

---

## Developer guide

Project layout (example)
- /lib
  - /ui — overlay widgets & screens
  - /platform — Android-specific integrations (Accessibility, overlay)
  - /context — recognizers & signal processors
  - /automation — rule engine & actions
  - /ai — provider adapters (openai_adapter.dart, tflite_adapter.dart)
  - main.dart
- /android — Android manifests, services, Kotlin/Java helper code
- /assets — icons, models (TFLite)
- /test — unit and integration tests

Adding a new action
1. Implement an Action class in /lib/automation/actions.
2. Register action in the ActionRegistry.
3. Add UI in the automation editor to configure the action.

Adding a new context recognizer
1. Create a recognizer that subscribes to Accessibility events or sensors in /lib/context.
2. Return a structured context object.
3. Add tests to exercise recognizer edge cases.

Testing
- Unit tests for rule matching and action dispatch.
- Integration tests using emulator or physical device (be mindful of overlay permission flows).
- Use dependency injection to mock AI providers and system services.

---

## Roadmap

Planned short-term items
- Improved on-device intent classifier (TFLite).
- UI polish for the overlay and themeing.
- More built-in actions (calendar, clipboard, share, task managers).
- Rule templating & marketplace for community automations.

Planned long-term items
- Optional local LLM support for richer suggestions.
- Multi-device sync for automations.
- Plugin ecosystem for third-party actions and connectors.

---

## Contributing

Contributions are welcome. Suggested workflow:
1. Fork the repo
2. Create a topic branch
3. Open a PR with a clear description and tests
4. Follow code style (format with `flutter format`)

Please open issues for feature requests or bugs. Include device, Android version, and logs when relevant.

---

## Security & Ethics

- Explicit user consent required for cloud features.
- Make it easy for users to inspect and delete data.
- Default to privacy-preserving, on-device processing where possible.
- Provide a transparent privacy policy and telemetry opt-in/out.

---

## License

MIT License — see LICENSE file.

---

## Contact

Maintainer: Anish-2005
Project: EternalOS

