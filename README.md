# MyVault – Personal Document & Reminder Manager

MyVault is a secure, personal dashboard designed to help citizens manage their life utilities in one place. From document storage and reminder tracking to medicine schedules and bill management, MyVault keeps your essential information organized and accessible.

## 🚀 Features

-   **📄 Document Vault**: Securely upload and categorize your essential identity and property documents.
-   **🔔 Smart Reminders**: Track recurring tasks and get notified about upcoming deadlines.
-   **💊 Medicine Tracker**: Manage your daily dosages and health schedules.
-   **💡 Bill Manager**: Track utilities and expenses with status indicators (Pending/Paid).
-   **🚗 Vehicle Management**: Keep track of your vehicles, insurance details, and service dates.
-   **📊 Budget Tracker**: Manage your income and expenses with visual summaries.
-   **📋 Notes & To-Dos**: Quick notes and checklist management with pinning support.

## 🛠️ Tech Stack

-   **Backend**: [Laravel 12](https://laravel.com) (PHP API)
-   **Frontend**: [Nuxt 4](https://nuxt.com) / [Vue 3](https://vuejs.org) SPA
-   **Styling**: [Bootstrap 5](https://getbootstrap.com) with [BootstrapVueNext](https://bootstrap-vue-next.github.io/bootstrap-vue-next/)
-   **State Management**: [Pinia](https://pinia.vuejs.org)
-   **Database**: SQLite (default) or MySQL
-   **Icons**: [Lucide Vue Next](https://lucide.dev)

## 📦 Installation & Setup

### Prerequisites

-   **PHP**: ^8.2
-   **Node.js**: ^18.x or latest LTS
-   **Composer**: Latest version

### 1. Backend Setup

From the project root:

```bash
# Install dependencies
composer install

# Create environment file
cp .env.example .env

# Generate application key
php artisan key:generate

# Setup database (SQLite)
touch database/database.sqlite
php artisan migrate --seed
```

### 2. Frontend Setup

From the `frontend` directory:

```bash
cd frontend

# Install dependencies
npm install

# Prepare Nuxt
npm run postinstall
```

## 🏃 Running the Application

You can run both the backend and frontend concurrently from the root directory:

```bash
# From the root directory
npm run dev
```

Alternatively, run them separately:

-   **Backend**: `php artisan serve` (Root)
-   **Frontend**: `cd frontend && npm run dev`

The frontend will be available at `http://localhost:3000`.

## 👤 Default Test Account

The database seeder creates a default account for testing:

-   **Email**: `test@example.com`
-   **Password**: `password`

## 📂 Project Structure

-   `/app`: Laravel controllers and business logic.
-   `/database`: Migrations, seeders, and SQLite database file.
-   `/routes/api.php`: API endpoint definitions.
-   `/frontend/app/pages`: Nuxt page components (Reminders, Documents, etc.).
-   `/frontend/app/layouts`: Main application layout.
-   `/frontend/stores`: Pinia stores for Auth and State management.

---

Made with ❤️ by Antigravity.
