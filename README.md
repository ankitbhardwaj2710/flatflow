# FlatFlow 🏠

> A modern Flutter application for managing shared flats, expenses, bills, groceries, settlements, activity, insights, and notifications — all in one place.

<p align="center">
  <strong>Share. Manage. Settle.</strong>
</p>

<p align="center">
  Built with Flutter ❤️ Firebase
</p>

---

## 📌 About FlatFlow

**FlatFlow** is a shared-flat management application built with **Flutter, Dart, Firebase, Cloud Firestore, and Riverpod**.

It is designed for roommates and shared-flat communities who want to manage their everyday flat responsibilities from a single application instead of using multiple apps, notes, or spreadsheets.

FlatFlow brings **expenses, bills, groceries, settlements, activity, insights, notifications, exports, and appearance settings** together into one organized experience.

---

## ✨ Features

### 👥 Flat Management

- Create a shared flat
- Join a flat using an invite code
- Manage flat members
- Member roles and permissions
- Active/current flat management
- Secure flat access using Firestore Security Rules

### 💰 Expense Management

- Add shared expenses
- Select who paid
- Split expenses among multiple members
- Automatic equal split calculation
- Paise-level split precision
- Edit expenses
- Delete expenses
- Expense search
- Expense filtering
- Expense categories
- Expense notes
- Track who paid and how much each member owes

### 🧾 Bill Management

- Add bills
- Set bill due dates
- Bill categories
- Edit bills
- Delete bills
- Mark bills as paid/unpaid
- Local bill reminders
- Automatically cancel reminders when a bill is paid
- Automatically cancel reminders when a bill is deleted
- Bill activity and notifications

### 🛒 Grocery Management

- Add grocery items
- Add optional quantity
- Mark grocery items as bought
- Track who bought an item
- Creator/admin based delete permissions
- Realtime grocery updates
- Grocery activity
- Grocery notifications

### 🤝 Settlement Management

- Automatically calculate member balances
- See how much you owe
- See how much other members owe you
- Mark settlements as paid
- Settlement history
- Settlement-aware balance calculations
- Settlement activity

### 🔔 Notifications

FlatFlow provides both **in-app notifications** and **local scheduled notifications**.

- Realtime notification center
- Unread notification badge
- Mark individual notifications as read
- Mark all notifications as read
- Delete notifications
- Expense notifications
- Bill notifications
- Grocery notifications
- Settlement notifications
- Scheduled bill reminders
- Android notification channel
- Timezone-aware scheduling
- Automatic reminder cancellation

### 📊 Activity

FlatFlow provides a realtime activity feed for important events across the flat.

Activity includes:

- Expense activity
- Bill activity
- Grocery activity
- Settlement activity
- Other flat-related actions

### 📈 Insights

- Financial summaries
- Expense insights
- Spending analysis
- Visual charts
- Category-based financial information

Charts are powered by **FL Chart**.

### 📤 Export & Sharing

- Export supported data to PDF
- Export supported data to Excel
- Generate local files
- Share generated files using platform sharing

### 🎨 Theme & Appearance

- Material 3 design
- Light theme
- Dark theme
- System theme
- Persistent theme preference
- Theme preference remains after app restart
- Google Fonts integration

---

## 🛠️ Tech Stack

| Technology | Purpose |
|---|---|
| Flutter | Cross-platform application development |
| Dart | Programming language |
| Firebase Authentication | User authentication |
| Cloud Firestore | Realtime database |
| Riverpod | State management |
| GoRouter | Navigation and routing |
| Google Fonts | Application typography |
| Flutter Local Notifications | Local notifications and reminders |
| Timezone | Timezone-aware notification scheduling |
| FL Chart | Charts and data visualization |
| PDF | PDF generation |
| Printing | PDF generation and printing |
| Excel | Excel export |
| Share Plus | File sharing |
| Path Provider | Local file handling |
| Shared Preferences | Theme preference persistence |

---

## 🏗️ Project Architecture

FlatFlow follows a feature-based Flutter architecture.

lib/
├── core/
│   ├── constants/
│   ├── notifications/
│   ├── router/
│   └── theme/
│
├── features/
│   ├── activity/
│   ├── auth/
│   ├── bills/
│   ├── expenses/
│   ├── export/
│   ├── flat/
│   ├── grocery/
│   ├── home/
│   ├── insights/
│   ├── notifications/
│   ├── profile/
│   └── settlement/
│
└── main.dart

The application separates:

- Models
- Providers
- Repositories
- Services
- Screens
- Core utilities

This keeps the project modular and easier to maintain.

---

## 🔥 Firebase Architecture

FlatFlow uses **Firebase Authentication** for authentication and **Cloud Firestore** for realtime application data.

A simplified Firestore structure:

users/
└── {userId}
    ├── name
    ├── email
    └── currentFlatId

flatInvites/
└── {inviteCode}
    ├── flatId
    └── createdAt

flats/
└── {flatId}
    ├── name
    ├── inviteCode
    ├── createdBy
    ├── createdAt
    │
    ├── members/
    ├── expenses/
    ├── bills/
    ├── groceryItems/
    ├── settlements/
    ├── activity/
    └── notifications/

---

## 🔐 Firestore Security

FlatFlow uses **Firestore Security Rules** to protect application data.

The security model includes:

- Authenticated-user access
- User-specific document protection
- Flat-member based access
- Admin-only operations where required
- Creator/admin permissions for grocery deletion
- Protected expense deletion
- Protected bill deletion
- Protected member operations
- Protected settlement data
- Protected notifications
- Default-deny behavior for unspecified Firestore paths

The application does not rely only on client-side permission checks.

---

## 💡 Expense Splitting

FlatFlow automatically calculates equal expense splits.

Example:

Expense: ₹1000  
Members: 4

Member 1 → ₹250  
Member 2 → ₹250  
Member 3 → ₹250  
Member 4 → ₹250

The split calculation also handles **paise-level rounding** so the total split remains equal to the original expense amount.

---

## 🤝 Settlement Logic

FlatFlow calculates each member's balance based on:

Expenses  
+ Payments  
+ Settlements  
↓  
Member Balances

Example:

You paid: ₹1000  
Your share: ₹500

You should receive: ₹500

If another member owes you, FlatFlow displays the amount they need to pay.

If you owe another member, FlatFlow displays the amount you need to pay.

Once a settlement is marked as paid, it is stored in the settlement history and included in future balance calculations.

---

## 🔔 Notification Flow

Bill reminders use local scheduled notifications.

Bill Created  
↓  
Firestore Bill Saved  
↓  
Local Notification Scheduled  
↓  
Bill Due Date  
↓  
Bill Reminder

When a bill is paid:

Bill Paid  
↓  
Scheduled Reminder Cancelled

When a bill is deleted:

Bill Deleted  
↓  
Scheduled Reminder Cancelled

---

## 🚀 Getting Started

### Prerequisites

Make sure you have:

- Flutter SDK
- Dart SDK
- Android Studio
- Android SDK
- Git
- Firebase project

Check your Flutter installation:

    flutter doctor

### Installation

Clone the repository:

    git clone https://github.com/ankitbhardwaj2710/flatflow.git

Open the project:

    cd flatflow

Install dependencies:

    flutter pub get

### Firebase Setup

Create your own Firebase project and configure:

- Firebase Authentication
- Cloud Firestore
- Google Sign-In if required

Configure Firebase for your Flutter application using your own Firebase project.

> Do not commit private keys, service-account credentials, or other sensitive Firebase credentials to the repository.

---

## ▶️ Run the Application

    flutter run

Check connected devices:

    flutter devices

---

## 🧪 Analyze the Project

Run Flutter's analyzer:

    flutter analyze

---

## 📦 Build Release APK

Generate a release APK:

    flutter build apk --release

The generated APK will be available at:

    build/app/outputs/flutter-apk/app-release.apk

---

## 📱 Screenshots

Add application screenshots here.

### 🏠 Home Dashboard

_Add screenshot here_

### 💰 Expenses

_Add screenshot here_

### 🧾 Bills

_Add screenshot here_

### 🛒 Grocery

_Add screenshot here_

### 🤝 Settlement

_Add screenshot here_

### 📈 Insights

_Add screenshot here_

### 🔔 Notifications

_Add screenshot here_

### 🎨 Profile / Appearance

_Add screenshot here_

---

## 🗺️ Roadmap

Potential future improvements:

- Firebase Cloud Messaging push notifications
- Advanced recurring bills
- Custom percentage-based expense splitting
- Custom amount-based expense splitting
- Monthly financial reports
- Advanced spending analytics
- More granular member permissions
- Automatic settlement optimization
- Improved onboarding experience
- Multi-flat improvements
- Additional financial insights

---

## 🤝 Contributing

Contributions, suggestions, and improvements are welcome.

For major changes, please create an issue first to discuss the proposed change.

Example workflow:

    git checkout -b feature/new-feature
    git add .
    git commit -m "feat: add new feature"
    git push origin feature/new-feature

---

## 📄 License

This project is currently maintained as a personal/project portfolio application.

A formal open-source license can be added if the project is later released for public contribution or redistribution.

---

## 👨‍💻 Developer

### Ankit Bhardwaj

**BTech AI/ML Student**  
**Flutter Developer · Frontend Developer**

---

## ⭐ FlatFlow

FlatFlow is built to make shared-flat management:

**Simple. Organized. Transparent.**

Built with **Flutter ❤️ Firebase**.