# MyVault – Personal Utility & Advanced Secure Chat

MyVault is a professional, all-in-one personal dashboard designed for the modern citizen. It combines high-utility management tools (documents, bills, health) with a robust, real-time messaging ecosystem inspired by industry leaders like WhatsApp.

## 🚀 Core Personal Utilities
- **📄 Document Vault**: Securely upload, preview (PDF, Docx, Excel), and categorize essential identity and property documents.
- **💡 Bill Manager**: Track utilities and expenses with visual status indicators and "Mark as Paid" functionality.
- **💊 Medicine Tracker**: Manage daily dosages and healthcare schedules with a dedicated "Today's Schedule" view.
- **🔔 Smart Reminders**: Integrated reminder system for recurring tasks and critical deadlines.
- **📊 Budget Summary**: Real-time visualization of income vs. expenses for financial awareness.
- **🚗 Vehicle Management**: Track insurance, service dates, and vehicle details centrally.
- **📋 Notes & To-Dos**: Quick-access notes with pinning support to stay organized.

## 💬 Advanced Messaging & Group Ecosystem
MyVault features a distraction-free, real-time chat experience built for privacy and efficiency:

### 👤 Private Messaging
- **⚡ Real-Time Sync**: Instant message delivery and read receipts (✓✓) via Socket.IO.
- **📎 Rich Media**: Support for images (with preview) and various file attachments.
- **📌 Interactive Features**: Reply to messages, pin critical info, and express yourself with emoji reactions.
- **🚮 Message Control**: Advanced deletion options (Delete for me / Delete for everyone) and message editing.
- **🟢 Presence**: Real-time online/offline status and typing indicators.
- **🚫 Security**: Complete user blocking management to control your social circle.

### 👥 Group Collaboration
- **🛠️ Group Management**: Admins can create groups, update group info, and manage members.
- **👑 Admin Controls**: Dedicated roles for membership oversight and group name updates.
- **📈 Real-Time Sync**: Member counts and sidebar lists update instantly for all users.
- **📝 Activity Logs**: Automatic system messages for joins, leaves, name changes, and member additions/removals.

## 🔔 Notification Center
Stay informed across the entire ecosystem with a centralized alert hub:
- **📍 Real-Time Badge**: A dynamic notification bell in the header that updates instantly without refresh.
- **📫 Persistent History**: A dedicated Notifications Page to review all past alerts and group activities.
- **✔️ Smart Management**: Mark individual alerts as read or use "Mark All as Read" for quick cleanup.
- **🔗 Deep Linking**: Click any notification to navigate directly to the relevant chat or utility.

## 🛠️ Multi-Layer Tech Stack
- **Backend**: [Laravel 11](https://laravel.com) / Sanctum API Authentication
- **Frontend**: [Nuxt 3/4](https://nuxt.com) / [Vue 3](https://vuejs.org) (SPA Architecture)
- **Real-Time Engine**: Node.js [Socket.IO](https://socket.io) Sidecar
- **Communication**: Redis Pub/Sub (ioredis) for Laravel-to-Node bridging
- **Styling**: Vanilla CSS + [BootstrapVueNext](https://bootstrap-vue-next.github.io/bootstrap-vue-next/)
- **Database**: MySQL (optimized for Laragon/Local environments)

## 📦 Services & Setup

### 1. Prerequisites
- PHP ^8.2 (Laravel environment)
- Node.js ^18.x (Frontend & Socket Server)
- Redis Server (Running on default port 6379)

### 2. Backend Setup (Root)
```bash
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate --seed
php artisan serve
```

### 3. Socket Server Setup (`/socket-server`)
```bash
cd socket-server
npm install
node index.js
```

### 4. Frontend Setup (`/frontend`)
```bash
cd frontend
npm install
npm run dev
```

## 📂 Project Structure
- **/app**: Core API logic, Models, and Activity Controllers.
- **/socket-server**: Node.js engine handling Redis subscription and real-time client relay.
- **/frontend/app**: The SPA core, featuring modular Pinia stores and Vue components.
- **/database/migrations**: Optimized schema for Chat, Notifications, Groups, and Utilities.

---
*Built with ❤️ for a secure and organized digital life.*
