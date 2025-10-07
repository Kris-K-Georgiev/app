# BHSS Connect (Version 1 Skeleton)

Mono-repo containing:
- `backend/` Laravel 12 REST API (Sanctum auth) + future admin panel
- `frontend/` Flutter multi-platform app
- `DB.sql` MySQL schema & seed for versions
- `STEPS.md` setup instructions

Implemented (initial):
- Core database tables (users, news, events, app_versions)
- API endpoints: auth register/login/logout/me, list/show news & events, latest version
- Flutter skeleton: splash, onboarding, placeholder home

Next steps:
- Implement full auth flows (UI)
- Version check & update dialog
- News/events UI + caching
- Profile & settings screens
- Admin CRUD (Blade or Filament)
- Add Sanctum SPA / mobile token expiration policies

# BHSS App - Multi-Platform Application

## 📱 Overview
BHSS App е мултиплатформено приложение, създадено с Flutter frontend и Laravel backend. Поддържа iOS, Android, Windows, macOS и включва система за принудителни обновления и админ панел.

## 🏗️ Architecture

### Frontend (Flutter)
- **Framework**: Flutter 3.8.1+
- **State Management**: Riverpod
- **Platforms**: iOS, Android, Windows, macOS
- **Authentication**: Laravel Sanctum (JWT)

### Backend (Laravel)
- **Framework**: Laravel 12.x
- **PHP Version**: 8.2+
- **Authentication**: Laravel Sanctum
- **Admin Panel**: Blade Templates

### Database
- **Engine**: MySQL 8.0+
- **Host**: Local (XAMPP)
- **Environments**: Production & Test

## 🚀 Features

### Core Features
- ✅ Multi-platform support (iOS, Android, Windows, macOS)
- ✅ JWT Authentication via Laravel Sanctum
- ✅ Role-based access control (Admin/User)
- ✅ Force update mechanism
- ✅ Admin panel with CRUD operations
- ✅ Dual environment setup (Production/Test)
- ✅ Real-time notifications
- ✅ API rate limiting
- ✅ Maintenance mode

### Force Update System
Приложението автоматично проверява за нови версии и принуждава потребителите да обновят ако:
- Текущата версия на приложението < Production версията в базата данни
- Админ е задал `is_force_update = TRUE` за определена версия

### Admin Panel Features
- Dashboard с статистики
- Управление на потребители
- Управление на версии на приложението
- Системни настройки
- Нотификации
- Audit logs

## 📂 Project Structure

```
BHSS/
├── backend/                 # Laravel API & Admin Panel
│   ├── app/
│   │   ├── Http/Controllers/
│   │   ├── Models/
│   │   └── ...
│   ├── database/
│   ├── resources/views/     # Admin Panel (Blade)
│   └── routes/
├── frontend/                # Flutter App
│   ├── lib/
│   │   ├── models/
│   │   ├── providers/
│   │   ├── screens/
│   │   ├── services/
│   │   └── widgets/
│   └── ...
├── DB.sql                   # Database Schema
├── STEPS.md                 # Setup Instructions
└── README.md               # This file
```

## 🔧 Technology Stack

| Component | Technology | Version |
|-----------|------------|---------|
| Frontend | Flutter | 3.8.1+ |
| State Management | Riverpod | Latest |
| Backend | Laravel | 12.x |
| Database | MySQL | 8.0+ |
| Authentication | Laravel Sanctum | Latest |
| Local Server | XAMPP | Latest |

## 🌍 Environments

### Production Environment
- **URL**: `http://localhost:8000`
- **Database**: `bhss_app`
- **Admin Panel**: `http://localhost:8000/admin`

### Test Environment  
- **URL**: `http://localhost:8001`
- **Database**: `bhss_app_test`
- **Admin Panel**: `http://localhost:8001/admin`

## 📡 API Endpoints

### Authentication
- `POST /api/register` - User registration
- `POST /api/login` - User login
- `POST /api/logout` - User logout
- `GET /api/user` - Get current user

### App Management
- `GET /api/version/check` - Check app version
- `GET /api/settings` - Get public settings
- `GET /api/notifications` - Get user notifications

### Admin (Protected)
- `GET /api/admin/users` - Manage users
- `POST /api/admin/versions` - Manage app versions
- `GET /api/admin/settings` - System settings

## 🔐 Security Features

- JWT token authentication
- API rate limiting (60 req/min)
- Role-based access control
- Password hashing (bcrypt)
- CSRF protection
- SQL injection prevention
- XSS protection

## 📱 App Features

### For Users
- Secure login/registration
- Profile management
- Real-time notifications
- Auto-update checks
- Cross-platform sync

### For Admins
- User management dashboard
- Version control system
- System settings configuration
- Analytics and reporting
- Notification broadcasting

## 🔄 Update Mechanism

1. App проверява версията при стартиране
2. Сравнява с `force_update_version` в настройките
3. Ако версията е по-ниска:
   - Блокира достъп до приложението
   - Показва update диалог
   - Пренасочва към download URL

## 🎨 UI/UX

- Material Design 3 (Android)
- Cupertino Design (iOS)  
- Fluent Design (Windows)
- macOS Human Interface Guidelines
- Responsive design
- Dark/Light theme support

## 🧪 Testing

- Unit tests (Flutter)
- Widget tests (Flutter)
- Integration tests
- API testing (Postman/Insomnia)
- Database testing

## 📊 Performance

- Lazy loading
- Image caching
- API response caching
- Database indexing
- Query optimization

## 📝 Documentation

- API documentation (auto-generated)
- Code comments
- Setup guides
- Deployment instructions

## 👥 Team

- **Backend Developer**: Laravel + MySQL expert
- **Frontend Developer**: Flutter + Dart expert
- **DevOps**: Local hosting setup

## 📞 Support

За въпроси и поддръжка:
- Email: support@бхсс.бг
- Documentation: `/docs`
- Admin Panel: `http://localhost:8000/admin`

## 📄 License

This project is proprietary software. All rights reserved.

---

**Version**: 1.0.0  
**Last Updated**: September 2025  
**Environment**: Local Development