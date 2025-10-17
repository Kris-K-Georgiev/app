# App PWA (React + Firebase + Flowbite)

Модерна PWA версия на приложението, изградена с React + Vite, TailwindCSS/Flowbite, Firebase (Auth/Firestore/Hosting) и Google Drive API.

## Функционалности
- PWA: инсталация, офлайн кеширане (App Shell), auto update
- Аутентикация: Firebase Auth (email/парола + Google)
- Данни: Firestore (users, events, news, comments, likes и др.)
- Файлове: Google Drive API (OAuth 2.0 чрез Google Identity Services)
- UI: TailwindCSS + Flowbite компоненти, dark/light режим

## Бърз старт
1. Копирай `.env.example` → `.env` и попълни стойностите.
2. Инсталирай зависимостите.
3. Стартирай разработка.

```powershell
# в папката pwa/
Copy-Item .env.example .env
npm install
npm run dev
```

Отвори http://localhost:5173

## Настройка на Firebase
1. Създай Firebase проект.
2. Активирай Authentication (Email/Password и Google) и Firestore (Native/Production mode по избор).
3. В Web App настройките копирай ключовете в `.env`:
   - VITE_FIREBASE_API_KEY
   - VITE_FIREBASE_AUTH_DOMAIN
   - VITE_FIREBASE_PROJECT_ID
   - VITE_FIREBASE_STORAGE_BUCKET
   - VITE_FIREBASE_MESSAGING_SENDER_ID
   - VITE_FIREBASE_APP_ID
4. (По избор) Активирай Firebase Hosting.

### Правила за сигурност (пример, адаптирай според нуждите)
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{uid} {
      allow read: if request.auth != null;
      allow create, update: if request.auth != null && request.auth.uid == uid;
    }
    match /events/{eventId} {
      allow read: if true;
      allow create, update, delete: if request.auth != null && request.auth.token.admin == true;
      match /registrations/{regId} {
        allow read, create: if request.auth != null;
      }
    }
    match /news/{newsId} {
      allow read: if true;
      allow create, update, delete: if request.auth != null && request.auth.token.admin == true;
      match /comments/{commentId} { allow read: if true; allow create: if request.auth != null; }
      match /likes/{likeId} { allow read, create: if request.auth != null; }
    }
  }
}
```

## Google Drive API (OAuth 2.0)
1. Отиди в Google Cloud Console → Credentials → Create OAuth client ID → Web application.
2. Добави Authorized JavaScript origins: http://localhost:5173 и продукционния домейн (Firebase Hosting).
3. За GIS Token Client redirect URI не е нужен. Попълни `VITE_GOOGLE_CLIENT_ID` в `.env`.
4. Активирай Drive API за проекта.

Забележка: Използваме минимален обхват `drive.file` и `drive.readonly`.

## PWA
- Конфигурирано с `vite-plugin-pwa`.
- Manifest и икони са в `public/`.
- Service worker: auto update, кеширане на shell + мрежови заявки.

## Структура
- `src/services/firebase.js` – инициализация на Firebase
- `src/services/auth.js` – hook за аутентикация
- `src/services/firestore.js` – примери за заявки към Firestore
- `src/services/drive.js` – интеграция с Google Drive API
- `src/components/*` – Login, Dashboard, FileManager

## Миграция на данни от Laravel към Firestore
На база на моделите:
- users → Firebase Auth + документ в `users/{uid}`: { name, email, role, city, avatar_path, bio, phone, status }
- events → `events/{id}`: { title, description, location, start_date, end_date, start_time, images[], cover, city, audience, limit, registrations_count, event_type_id, status, created_by }
  - регистрации → `events/{eventId}/registrations/{uid}`: { uid, status, createdAt }
  - типове → `event_types/{id}`: { slug, name, color }
- news → `news/{id}`: { title, content, image, cover, status, created_by }
  - images → `news/{newsId}/images/{imgId}`: { path, position }
  - likes → `news/{newsId}/likes/{uid}`
  - comments → `news/{newsId}/comments/{commentId}`: { user_id, content, createdAt }
- app_versions → `app_versions/{id}`: { version_code, version_name, release_notes, is_mandatory, download_url }

Минимален подход: експортирай MySQL таблиците като CSV и импортирай с малък Node скрипт (виж `tools/migration`).

## Деплой на Firebase Hosting
```powershell
npm run build
# инсталирай Firebase CLI ако е нужно
# npm install -g firebase-tools
firebase login
firebase init hosting
# изберете папка dist за публична директория
firebase deploy
```

## Тунинг и следващи стъпки
- Роутове: профили, новини, детайли на събитие, регистрация и модериране.
- Стейт мениджмънт (Zustand/Redux) ако мащаба нарасне.
- По-строги Firestore правила + Cloud Functions за броячи.
- Unit/интеграционни тестове.
