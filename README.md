# FlatFlow 🏠

> A modern Flutter app for managing shared flats, expenses, bills, groceries, settlements, activity, insights, and notifications — all in one place.

<p align="center">
  <strong>Flat management made simple.</strong>
</p>

---

## 📌 About FlatFlow

FlatFlow is a shared-flat management application built with **Flutter, Firebase, and Riverpod**.

It is designed for roommates and shared-flat communities who want to manage their daily expenses, bills, groceries, settlements, and other flat-related activities without relying on multiple apps or spreadsheets.

---

## ✨ Features

### 👥 Flat Management

- Create a shared flat
- Join a flat using an invite code
- Manage flat members
- Member roles and permissions
- Active/current flat management

### 💰 Expense Management

- Add shared expenses
- Select who paid
- Split expenses among members
- Automatic equal split calculation
- Precise paise-level split handling
- Edit expenses
- Delete expenses
- Expense search
- Expense filtering
- Expense notes and categories

### 🧾 Bill Management

- Add bills
- Set due dates
- Edit bills
- Delete bills
- Mark bills as paid/unpaid
- Bill categories
- Local bill reminders
- Automatic reminder cancellation after payment
- Automatic reminder cancellation after deletion

### 🛒 Grocery Management

- Add grocery items
- Add optional quantity
- Mark groceries as bought
- Track who bought an item
- Delete grocery items
- Creator/admin based permissions
- Realtime grocery updates

### 🤝 Settlement System

- Automatically calculate member balances
- See how much you owe
- See how much others owe you
- Mark settlements as paid
- Settlement history
- Settlement-aware balance calculations

### 📊 Activity

FlatFlow maintains a realtime activity feed for important flat events such as:

- Expenses
- Bills
- Grocery activity
- Settlements
- Other shared-flat actions

### 📈 Insights

- Financial summaries
- Expense insights
- Visual charts
- Spending analysis

Charts are powered by `fl_chart`.

### 🔔 Notifications

FlatFlow includes both **in-app notifications** and **local scheduled notifications**.

#### In-app notifications

- Realtime notification center
- Unread notification badge
- Mark notification as read
- Mark all notifications as read
- Delete notifications
- Expense notifications
- Bill notifications
- Grocery notifications
- Settlement notifications

#### Local notifications

- Scheduled bill reminders
- Bill reminder cancellation when paid
- Bill reminder cancellation when deleted
- Android notification channel
- Timezone-aware scheduling

### 📤 Export

FlatFlow supports exporting application data using:

- PDF
- Excel

Generated files can also be shared using platform sharing functionality.

### 🎨 Theme & Appearance

- Material 3 UI
- Light theme
- Dark theme
- System default theme
- Persistent theme preference
- Theme preference survives app restart

---

# 🛠️ Tech Stack

| Technology | Usage |
|---|---|
| Flutter | Cross-platform application development |
| Dart | Programming language |
| Firebase Authentication | User authentication |
| Cloud Firestore | Realtime database |
| Riverpod | State management |
| GoRouter | Navigation and routing |
| Google Fonts | Typography |
| Flutter Local Notifications | Local reminders |
| Timezone | Notification scheduling |
| FL Chart | Charts and insights |
| PDF | PDF generation |
| Printing | PDF printing |
| Excel | Excel export |
| Share Plus | File sharing |
| Path Provider | Local file handling |
| Shared Preferences | Theme preference persistence |

---

# 🏗️ Project Architecture

FlatFlow follows a **feature-based Flutter architecture**.

```text
lib/
│
├── core/
│   ├── constants/
│   ├── notifications/
│   ├── router/
│   └── theme/
│
├── features/
│   │
│   ├── activity/
│   │   ├── models/
│   │   ├── providers/
│   │   ├── repository/
│   │   └── screens/
│   │
│   ├── auth/
│   │   ├── models/
│   │   ├── providers/
│   │   ├── repository/
│   │   └── screens/
│   │
│   ├── bills/
│   │   ├── models/
│   │   ├── providers/
│   │   ├── repository/
│   │   └── screens/
│   │
│   ├── expenses/
│   │   ├── models/
│   │   ├── providers/
│   │   ├── repository/
│   │   └── screens/
│   │
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



users/
│
└── {userId}
    ├── name
    ├── email
    └── currentFlatId


flats/
│
└── {flatId}
    │
    ├── name
    ├── inviteCode
    ├── createdBy
    ├── createdAt
    │
    ├── members/
    │
    ├── expenses/
    │
    ├── bills/
    │
    ├── groceryItems/
    │
    ├── settlements/
    │
    ├── activity/
    │
    └── notifications/


