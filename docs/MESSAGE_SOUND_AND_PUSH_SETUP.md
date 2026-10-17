# VINCÓ message sound and remote push rollout

## Changes in this branch
- Explicitly enables sound for Android and iOS local notifications.
- Detects newly received messages while a conversation is open and shows a sound-bearing notification. The first fetch is only a baseline, so opening an existing conversation does not alert for its old messages.
- Preserves existing polling, chat, and notification-tap routing.

## Important limitation
These app-side changes do **not** provide alerts when VINCÓ is backgrounded or terminated. The current backend documentation says there is no realtime/push service; local polling cannot run reliably after the operating system suspends or kills the app. Do not describe this as complete until remote push is wired and tested.

## Requirements to enable real push (FCM/APNs)
1. Create/select a Firebase project and register the exact Android application ID and iOS bundle ID.
2. Add the generated Android `google-services.json` and iOS `GoogleService-Info.plist`; configure Firebase for the current FlutterFire setup. These project-specific files and IDs cannot be generated safely from this repository alone.
3. Add and initialize `firebase_core` and `firebase_messaging`; request notification permission on iOS and Android 13+; retrieve FCM tokens, refresh them, and remove/revoke them on logout.
4. Extend the Railway API with authenticated actions to register/unregister device tokens. Store tokens per user/device, never accept a user ID as authorization by itself, and avoid logging tokens.
5. When `sendmessage` commits a message, the backend must enqueue an FCM notification for the recipient's active device tokens. Use a notification payload with a stable message/conversation ID and generic title/body; handle token expiry and invalid-token cleanup. Do not send the sender a push.
6. Configure APNs credentials in Firebase for iOS. The OS can display notification payloads while the app is backgrounded/terminated; foreground messages should use the same in-app sound/notification path without duplicate alerts.
7. Add tests for token registration authorization, recipient-only delivery, duplicate suppression, logout/unregister, invalid tokens, and message delivery while foreground/background/terminated.

## Verification checklist before release
- Flutter analyze and tests pass on a clean checkout.
- Fresh install requests permission and receives a test notification on physical iOS and Android devices.
- Verify foreground, background, force-quit, logged-out, permission-denied, and token-refresh scenarios.
- Verify tapping a push opens the correct conversation.
- Confirm existing matches, chat polling, read-state behavior, and activity notifications remain intact.
- Do not deploy the backend or publish app builds until credentials are configured and end-to-end tests pass.
