БХСС – Стъпки за настройка (Версия 1)
=====================================

Backend (Laravel + MySQL via XAMPP)
-----------------------------------
1. Install XAMPP and start Apache + MySQL.
2. Създайте база данни (например `bhss_connect`).
3. Import `DB.sql` via phpMyAdmin or MySQL CLI.
4. Copy `.env.example` to `.env` inside `backend/` if not already.
5. In `backend/.env` set:
   - `DB_CONNECTION=mysql`
   - `DB_HOST=127.0.0.1`
   - `DB_PORT=3306`
   - `DB_DATABASE=bhss_connect`
   - `DB_USERNAME=root`
   - `DB_PASSWORD=` (empty if default XAMPP)
   - Mail (for password reset & verification):
     - `MAIL_MAILER=smtp`
     - `MAIL_HOST=smtp.gmail.com`
     - `MAIL_PORT=587`
     - `MAIL_USERNAME=your@gmail.com`
     - `MAIL_PASSWORD=app_password`
     - `MAIL_ENCRYPTION=tls`
     - `MAIL_FROM_ADDRESS=your@gmail.com`
   - `MAIL_FROM_NAME="БХСС"`
6. From `backend/` run:
   - `composer install`
   - `php artisan key:generate`
   - `php artisan migrate` (if using migrations instead of raw SQL)
   - `php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"`
7. Run server: `php artisan serve` (default http://127.0.0.1:8000)

API Base URL: `http://127.0.0.1:8000/api`

Frontend (Flutter)
------------------
Requirements: Flutter SDK (3.8+), Android Studio or Xcode.

1. From `frontend/` run `flutter pub get`.
2. Configure base API URL (later will be in `lib/core/config.dart`).
3. Run app: `flutter run` (choose device).

Auto-Update Flow
----------------
1. App calls `GET /api/version/latest` on splash.
2. Compare `version_code` with local `int.fromEnvironment('BUILD_NUMBER')` or parsed from `package_info_plus`.
3. If newer:
   - If `is_mandatory = 1`: force update dialog (no dismiss).
   - Else: optional update dialog.
4. Download APK via `download_url` (Android) and prompt install (requires enabling unknown sources during testing).

Planned Screens (Implemented Skeleton Soon)
------------------------------------------
1. Splash – logo + version check.
2. Onboarding – 3 slides with skip / continue.
3. Auth – login/register/forgot.
4. Home – latest news, upcoming events, info link.
5. Info – static content.
6. Calendar – list or calendar widget of events.
7. Profile & Settings – account data, theme toggle, update check, logout.

Admin Panel (Phase 1 Minimal)
-----------------------------
Use default Laravel Blade or add simple Breeze/Inertia in future. For now you can manage data via:
 - Tinker / phpMyAdmin / basic CRUD routes (to be added later) or create a simple Blade layout.

Deployment Notes
----------------
Production build steps:
1. Backend: `php artisan config:cache && php artisan route:cache`.
2. Frontend Android APK: `flutter build apk --release`.
3. Host APK at a URL (e.g. `public/downloads/app.apk`) and update `app_versions.download_url`.
4. Increment `app_versions.version_code` and `version_name` for each release.

Next Enhancements (Roadmap)
---------------------------
- Email verification endpoint handling in mobile app.
- Biometric login (using `local_auth`).
- Persistent dark/light theme (using `shared_preferences`).
- Push notifications (Firebase Cloud Messaging).
- Admin Blade CRUD scaffolding.

# БХСС App - Инструкции за настройка

## 🔧 Prerequisites

### Required Software
1. **XAMPP** (Apache + MySQL + PHP 8.2+)
   - Download: https://www.apachefriends.org/
   - Install и стартирай Apache + MySQL

2. **Composer** (PHP Dependency Manager)
   - Download: https://getcomposer.org/
   - Add to PATH

3. **Node.js** (18+) and npm
   - Download: https://nodejs.org/

4. **Flutter SDK** (3.8.1+)
   - Download: https://flutter.dev/docs/get-started/install
   - Add to PATH

5. **Git** 
   - Download: https://git-scm.com/

### IDE Setup
- **VS Code** с extensions:
  - Flutter
  - Dart
  - PHP Intelephense
  - Laravel Extension Pack

---

## 📋 Step-by-Step Setup

### Step 1: Database Setup

1. **Start XAMPP**
   ```powershell
   # Стартирай XAMPP Control Panel
   # Enable Apache и MySQL services
   ```

2. **Create Database**
   ```powershell
   # Отвори phpMyAdmin: http://localhost/phpmyadmin
   # Или използвай MySQL command line:
   mysql -u root -p
   ```

3. **Import Database Schema**
   ```powershell
   # В phpMyAdmin import DB.sql файла
   # Или през command line:
   mysql -u root -p < DB.sql
   ```

### Step 2: Backend Setup (Laravel)

1. **Navigate to backend folder**
   ```powershell
   cd backend
   ```

2. **Install PHP Dependencies**
   ```powershell
   composer install
   ```

3. **Setup Environment**
   ```powershell
   # Copy environment file
   cp .env.example .env
   
   # Generate app key
   php artisan key:generate
   ```

4. **Configure .env file**
   ```env
   APP_NAME="БХСС App"
   APP_ENV=local
   APP_KEY=base64:your-generated-key
   APP_DEBUG=true
   APP_URL=http://localhost:8000
   
   DB_CONNECTION=mysql
   DB_HOST=127.0.0.1
   DB_PORT=3306
   DB_DATABASE=bhss_app
   DB_USERNAME=root
   DB_PASSWORD=
   
   SANCTUM_STATEFUL_DOMAINS=localhost:8000,127.0.0.1:8000
   ```

5. **Install Sanctum**
   ```powershell
   composer require laravel/sanctum
   php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
   ```

6. **Run Migrations**
   ```powershell
   php artisan migrate:fresh --seed
   ```

7. **Install Frontend Dependencies**
   ```powershell
   npm install
   npm run build
   ```

8. **Start Laravel Server**
   ```powershell
   php artisan serve --port=8000
   ```

### Step 3: Test Environment Setup

1. **Create Test Environment**
   ```powershell
   # Copy .env to .env.testing
   cp .env .env.testing
   ```

2. **Configure Test Environment**
   ```env
   # .env.testing
   APP_ENV=testing
   APP_URL=http://localhost:8001
   DB_DATABASE=bhss_app_test
   ```

3. **Setup Test Database**
   ```powershell
   php artisan migrate:fresh --seed --env=testing
   ```

4. **Start Test Server**
   ```powershell
   php artisan serve --port=8001 --env=testing
   ```

### Step 4: Frontend Setup (Flutter)

1. **Navigate to frontend folder**
   ```powershell
   cd ..\frontend
   ```

2. **Get Flutter Dependencies**
   ```powershell
   flutter pub get
   ```

3. **Check Flutter Doctor**
   ```powershell
   flutter doctor
   ```

4. **Enable Desktop Platforms**
   ```powershell
   flutter config --enable-windows-desktop
   flutter config --enable-macos-desktop
   flutter config --enable-linux-desktop
   ```

### Step 5: Testing the Setup

1. **Test Backend API**
   ```powershell
   # Test production environment
   curl http://localhost:8000/api/version/check
   
   # Test test environment  
   curl http://localhost:8001/api/version/check
   ```

2. **Test Admin Panel**
   ```
   # Production: http://localhost:8000/admin
   # Test: http://localhost:8001/admin
   # Default credentials: admin@бхсс.бг / password
   ```

3. **Test Flutter App**
   ```powershell
   cd frontend
   
   # Test on different platforms
   flutter run -d windows
   flutter run -d chrome
   flutter run # for connected mobile devices
   ```

---

## 🔄 Development Workflow

### Daily Development

1. **Start Services**
   ```powershell
   # Start XAMPP (Apache + MySQL)
   
   # Start Laravel (Production)
   cd backend
   php artisan serve --port=8000
   
   # Start Laravel (Test) - in new terminal
   php artisan serve --port=8001 --env=testing
   
   # Start Flutter - in new terminal
   cd frontend
   flutter run
   ```

### Database Changes

1. **Create Migration**
   ```powershell
   cd backend
   php artisan make:migration create_table_name
   ```

2. **Run Migration**
   ```powershell
   # Production
   php artisan migrate
   
   # Test
   php artisan migrate --env=testing
   ```

3. **Update DB.sql**
   ```powershell
   # Export updated schema to DB.sql
   mysqldump -u root -p bhss_app > ..\DB.sql
   ```

### API Development

1. **Create Controller**
   ```powershell
   php artisan make:controller API\YourController
   ```

2. **Create Model**
   ```powershell
   php artisan make:model YourModel -m
   ```

3. **Update Routes**
   ```php
   // routes/api.php
   Route::middleware('auth:sanctum')->group(function () {
       Route::get('/your-endpoint', [YourController::class, 'index']);
   });
   ```

---

## 🚀 Production Deployment

### Prepare for Production

1. **Optimize Laravel**
   ```powershell
   cd backend
   composer install --optimize-autoloader --no-dev
   php artisan config:cache
   php artisan route:cache
   php artisan view:cache
   ```

2. **Build Flutter for Production**
   ```powershell
   cd frontend
   
   # Build for different platforms
   flutter build windows --release
   flutter build apk --release
   flutter build ios --release
   flutter build macos --release
   ```

### Environment Configuration

1. **Production .env**
   ```env
   APP_ENV=production
   APP_DEBUG=false
   APP_URL=http://your-domain.com
   
   # Use strong passwords in production
   DB_PASSWORD=your-strong-password
   ```

---

## 🔧 Troubleshooting

### Common Issues

1. **Database Connection Error**
   ```powershell
   # Check XAMPP MySQL is running
   # Verify DB credentials in .env
   # Test connection: php artisan tinker -> DB::connection()->getPdo()
   ```

2. **Sanctum Authentication Issues**
   ```powershell
   # Clear config cache
   php artisan config:clear
   
   # Re-publish Sanctum
   php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider" --force
   ```

3. **Flutter Build Issues**
   ```powershell
   # Clean and rebuild
   flutter clean
   flutter pub get
   flutter pub upgrade
   ```

4. **Port Already in Use**
   ```powershell
   # Find process using port
   netstat -ano | findstr :8000
   
   # Kill process by PID
   taskkill /PID <process-id> /F
   
   # Or use different port
   php artisan serve --port=8002
   ```

### Performance Issues

1. **Slow API Response**
   ```powershell
   # Enable query logging
   php artisan tinker
   DB::enableQueryLog();
   
   # Check slow queries
   # Add database indexes
   # Use eager loading
   ```

2. **Flutter Performance**
   ```powershell
   # Profile app performance
   flutter run --profile
   
   # Build release version
   flutter build windows --release
   ```

---

## 📊 Monitoring & Maintenance

### Log Files

1. **Laravel Logs**
   ```
   backend/storage/logs/laravel.log
   ```

2. **Apache Logs** (XAMPP)
   ```
   xampp/apache/logs/error.log
   xampp/apache/logs/access.log
   ```

3. **MySQL Logs** (XAMPP)
   ```
   xampp/mysql/data/*.err
   ```

### Backup Strategy

1. **Database Backup**
   ```powershell
   # Daily backup
   mysqldump -u root -p bhss_app > backup_$(date +%Y%m%d).sql
   ```

2. **Code Backup**
   ```powershell
   # Git backup
   git add .
   git commit -m "Daily backup"
   git push origin main
   ```

---

## 🆘 Support Commands

### Laravel Artisan Commands
```powershell
php artisan list                    # All available commands
php artisan route:list             # List all routes  
php artisan migrate:status         # Migration status
php artisan queue:work             # Start queue worker
php artisan schedule:run           # Run scheduled tasks
```

### Flutter Commands
```powershell
flutter devices                    # List connected devices
flutter analyze                    # Analyze code
flutter test                       # Run tests
flutter build --help              # Build options
```

### Database Commands
```powershell
mysql -u root -p                   # Connect to MySQL
SHOW DATABASES;                    # List databases
USE bhss_app;                      # Смяна на база данни
SHOW TABLES;                       # List tables
```

---

**Note**: Винаги прави backup преди major промени!
**Support**: При проблеми, провери log файловете първо.