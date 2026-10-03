# VINCÓ

## Overview
Original dating app for iOS, Android and Web focused on safety, privacy and genuine compatibility. Every section talks to the user's own RPC backend; there is no mock data and no coming-soon screen.

## Built vs Coming Soon
- Auth: splash with session restore, welcome, signup, login (email or phone), forgot password, logout, delete account (confirm "DELETE"), guest mode
- Discover: listdiscovery (paged by offset) + reacttoprofile LIKE/PASS/SUPER_LIKE, match dialog opens the chat via conversationId
- Matches (listmatches/unmatch), Messages (conversations derived from listmatches; listmessages polled every 4 s, sendmessage)
- Activity: listnotifications + marknotificationread
- Profile: getme, updateprofile (all fields incl. preferences), photos upload/reorder/delete/set primary, public preview (approved photos only)
- Backend actions exist but are NOT wired yet (docs not provided): reportuser, blockuser, requestverification/verifyotp, listplans/listboosts/createcheckout (Stripe not configured), admin (role ADMIN)
- Not available: Google/Apple sign-in; OTP/reset codes are never delivered (no email/SMS provider)

## Tech Stack & Key Decisions
- Custom backend (NOT Supabase): POST https://vinco-server-production.up.railway.app/actions, body {"action","args"}; token inside args.token (ApiClient.sendAuthed)
- flutter_secure_storage holds token + expiresAt
- go_router; redirect is the single place deciding auth vs app routes
- image_picker for photos; bytes sent as pure base64, server returns data: URLs (ProfilePhoto decodes them and caches bytes)
- No realtime on the backend, so chat polls while open

## Architecture
- screens → providers → services → repositories → ApiClient
- Repositories receive a token getter from main.dart; session-scoped providers live in the shell route builder so they are recreated after each sign-in
- ChatProvider is route-scoped on /messages/chat/:conversationId and owns the poll timer
- Public profile cards are parsed once in repositories/profile_parser.dart (shared by discovery and matches)
- Backend errors: HTTP 200 {"data":{"ok":false,"error":CODE}} → ApiException; AuthService.messageFor maps codes to Spanish, unknown codes shown verbatim

## Conventions
- Provider actions return String? (null = success); screens show it in a SnackBar or inline
- Async providers guard notifyListeners after dispose (_notify)
- Main tabs use widgets/common/tab_page.dart; guests see SignInRequiredView
- openChat / confirmAndUnmatch live in screens/match_actions.dart

## Key Patterns & Gotchas
- listdiscovery excludes reacted profiles, so the next page offset = unreacted cards still in the deck
- reorderprofilephotos needs EVERY own photo id; setprimaryphoto only works on approved photos
- updateprofile requires all fields; optional ones are sent as ""; preferredGender "Todos" and distance unit (mi) are assumptions
- getme returns user fields at the top level plus settings; MyProfile reads preferences from either
- A failed reaction puts the card back in the deck; rewind is disabled (server has no undo)

## Design System
- "Barro" identity (warm, premium, Latin): terracotta primary, agave-green secondary/like, gold tertiary/Spark, cream light and charcoal dark surfaces; no pink or purple
- Sora (geometric) for headlines, DM Sans for body; cards radius 24, pill buttons 52 high, spacing 16/24
- Interlocking rings are the motif: Like button, swipe stamp, match celebration (rings slide together + gold sparks)
- Skeletons (widgets/common/skeleton.dart) for every list load; empty states use generated illustrations in assets/images/empty_*.png; onboarding (3 pages) lives in WelcomeScreen
- Errors: AuthService.messageFor never shows raw codes; unknown codes fall back to a friendly generic sentence
- Not built (needs backend fields): profile prompts, typing indicator, photos in chat. Matches "unread" dot = last message is from the other person (listmatches has no readAt)
