# MyVault – Personal Utility & Advanced Secure Chat

MyVault is a premium, all-in-one personal dashboard designed for the modern citizen. It combines rigorous utility management (documents, bills, health) with a powerful, real-time messaging ecosystem that rivals professional chat platforms.

## 🚀 Core Personal Utilities

-   **📄 Document Vault**: Securely upload, preview, and categorize essential identity and property documents.
-   **💡 Bill Manager**: Track utilities and expenses with visual status indicators and "Mark as Paid" functionality.
-   **💊 Medicine Tracker**: Manage daily dosages and healthcare schedules with a dedicated "Today's Schedule" view.
-   **🔔 Smart Reminders**: Integrated reminder system for recurring tasks and critical deadlines.
-   **📊 Budget Summary**: Real-time visualization of income vs. expenses.
-   **🚗 Vehicle Management**: Track insurance, service dates, and vehicle details.
-   **📋 Notes & To-Dos**: Quick-access notes with pinning support.

## 💬 Advanced Messaging System (WhatsApp Style)

MyVault features a distraction-free, real-time chat experience built for privacy and efficiency:

-   **⚡ Real-Time Sync**: Instant message delivery and read receipts (✓✓) via Socket.IO.
-   **📎 Rich Media Sharing**: Support for images (with preview) and various file attachments (PDF, DOCX, Excel).
-   **📌 Message Pinning**: Pin important messages to the top of the conversation for quick reference.
-   **🎭 Emoji Reactions**: React to messages with expressive emojis.
-   **🚮 Message Deletion**: Pro-level deletion options:
    *   *Delete for me*: Removes the message from your local view.
    *   *Delete for everyone*: Globally replaces the message with a placeholder for relative privacy.
-   **🟢 Presence & Typing**: Real-time online/offline status and typing indicators.
-   **🚫 User Blocking**: Complete control over your social circle with individual block/unblock management.

## 🛠️ Multi-Layer Tech Stack

-   **Backend**: [Laravel 12](https://laravel.com) (PHP 8.2+) / Sanctum JWT Auth
-   **Frontend**: [Nuxt 4](https://nuxt.com) / [Vue 3](https://vuejs.org) (SPA Mode)
-   **Real-Time Engine**: Node.js [Socket.IO](https://socket.io) Server
-   **Communication Layer**: Redis Pub/Sub (Predis/ioredis)
-   **Styling**: Vanilla CSS + [BootstrapVueNext](https://bootstrap-vue-next.github.io/bootstrap-vue-next/)
-   **Database**: MySQL (optimized for Laragon environments)

## 📦 Services & Setup

### 1. Prerequisites
- PHP ^8.2
- Node.js ^18.x
- Redis Server (Running on port 6379)

### 2. Backend (Root)
```bash
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate --seed
php artisan serve --host 0.0.0.0 # Accessible via machine IP
```

### 3. Socket Server (`/socket-server`)
```bash
cd socket-server
npm install
node index.js
```

### 4. Frontend (`/frontend`)
```bash
cd frontend
npm install
npx nuxi dev --host <YOUR_IP>
```

## 📂 Project Structure

-   `/app`: Laravel API logic, Controllers, and Activity Logs.
-   `/socket-server`: Node.js engine for real-time Redis events and Socket.IO.
-   `/frontend/app`: The SPA core. Built with a modular folder structure for pages and Pinia stores.
-   `/database/migrations`: Specialized schema for Chat, Blocks, and Utility tables.

---
*Built with ❤️ for a distraction-free digital life.*
