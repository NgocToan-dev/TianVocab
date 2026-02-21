Dưới đây là Business Stack (tư duy sản phẩm) và Tech Stack (công nghệ triển khai) chuẩn cho app Flutter học từ vựng theo hướng ADHD-first.

⸻

I. 🧠 Business Stack (Thiết kế ở tầng sản phẩm)

1. Learning Model (Mô hình học)

Không phải EdTech truyền thống → mà là:

Behavioral Learning + Dopamine Loop

App hoạt động giống game casual hơn là khóa học.

Nguyên tắc:
	•	Session cực ngắn (5–20s)
	•	Không yêu cầu tập trung lâu
	•	Không ép nhớ → chỉ tạo “gặp lại nhiều lần”
	•	Reward ngẫu nhiên để duy trì mở app

⸻

2. Core Experience Units (Đơn vị trải nghiệm)

Mỗi lần user mở app = 1 micro-experience:

Unit	Mục tiêu
Quick Hit	Gặp 1 từ trong ngữ cảnh
Swipe	Phản xạ nhanh
Ambush	Gợi nhớ thụ động
Reward	Tạo dopamine
Resurface	Từ tự quay lại

Không có:
	•	Lesson
	•	Level
	•	Grammar path

⸻

3. Engagement Strategy

Không giữ user bằng streak → giữ bằng:

Variable Reward Psychology

App phải tạo cảm giác:
	•	Mở nhanh
	•	Không áp lực
	•	Lâu lâu có “bất ngờ vui”

⸻

4. Data Philosophy

Không track “đã học bao nhiêu”.

Chỉ track:

Reaction Speed
Familiarity Strength
Return Frequency

Đây là behavioral metric, không phải academic metric.

⸻

5. Monetization (nếu sau này cần)

Phù hợp nhất:
	•	Theme packs (visual dopamine)
	•	Extra word worlds (Travel / Office / Dating)
	•	Không nên paywall learning

⸻

II. ⚙️ Tech Stack (Triển khai bằng Flutter)

1. Frontend Framework

Flutter (Dart)

Vì:
	•	Render UI như game (60fps stable)
	•	Cross-platform thật sự
	•	Không bridge native nhiều

⸻

2. Architecture Pattern

Dùng:

Feature-First Clean Architecture (Lite)

Không cần Clean Architecture full nặng nề.

Structure:

lib/
 ├── feature/
 │    ├── quick_hit/
 │    ├── swipe/
 │    ├── reward/
 │
 ├── core/
 │    ├── engine/
 │    ├── database/
 │    ├── models/
 │
 ├── app/


⸻

3. State Management

Khuyên dùng:

Riverpod

Vì:
	•	Nhẹ
	•	Compile-safe
	•	Không boilerplate như Bloc
	•	Async handling rất sạch

⸻

4. Local Database

SQLite + Drift (ORM cho Flutter)

Tại sao Drift:
	•	Type-safe SQL
	•	Query mạnh (cần RANDOM + weight)
	•	Offline-first đúng nghĩa
	•	Không cần backend

⸻

5. Async Engine

Dùng:

Dart Isolates + Futures

Để:
	•	Tính toán word resurfacing
	•	Không block UI

⸻

6. Animation Layer (Rất quan trọng)

Lottie

Dùng cho:
	•	Reward animation
	•	Micro-feedback
	•	Tạo cảm giác “game feel”

⸻

7. Notification System

Firebase Cloud Messaging (FCM)

Chỉ dùng cho:
	•	Ambush Quiz
	•	Random re-engagement

Không dùng để spam reminder.

⸻

8. Dependency Set (pubspec.yaml)

dependencies:
  flutter:
    sdk: flutter

  flutter_riverpod: ^2.5.0
  drift: ^2.15.0
  sqlite3_flutter_libs: ^0.5.0
  path_provider: ^2.1.2

  lottie: ^3.1.0
  firebase_messaging: ^14.7.0


⸻

9. Core Engines cần build

WordEngine

Chọn từ tiếp theo bằng trọng số hành vi.

RewardEngine

Sinh reward theo xác suất.

FamiliarityEngine

Tính strength decay theo thời gian.

Ba engine này là “não” của app.

⸻

10. Không cần Backend (Phase 1)

Toàn bộ chạy local:

App = Engine + SQLite

Sau này nếu cần sync:
→ thêm lightweight API (không cần ngay).

⸻

III. Development Roadmap (Chuẩn để build)

Phase 1 (2 tuần MVP)
	•	SQLite + seed data
	•	QuickHit screen
	•	WordEngine
	•	Basic reward

Phase 2
	•	Swipe mode
	•	Strength adaptation
	•	Notification ambush

Phase 3
	•	Camera context
	•	AI sentence generation (optional)

⸻

Kết luận

Business model của app này là:

Behavioral product disguised as learning app

Tech stack tối ưu nhất:

Flutter
Riverpod
Drift (SQLite)
Lottie
FCM


⸻

Nếu bạn muốn, bước tiếp ta có thể:
	•	Scaffold sẵn project structure
	•	Viết WordEngine thật (thuật toán chọn từ)
	•	Tạo seed dataset chuẩn để import ngay.