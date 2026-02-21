# TianVocab MVP Spec (Phase 1)

## Goal

- Deliver ADHD-first micro-learning loop in 5–20 seconds/session.
- Prioritize daily session frequency.
- Support Android + iOS with local-first data.

## Scope

- QuickHit mode only.
- Rule-based WordEngine and FamiliarityEngine.
- Lightweight reward feedback.
- Local notifications service baseline.
- Seed dataset from local JSON.

## Out of Scope

- Swipe mode.
- Ambush push via FCM.
- Backend sync and account system.
- Camera/AI generation.

## Session Flow

1. Show one word card.
2. User taps reveal.
3. User taps next.
4. Engine updates familiarity.
5. Optional reward appears.

## Success Metric

- Daily session frequency per local profile.
