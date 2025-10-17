# Modern PWA (Vite + Tailwind + Flowbite)

Мултиплатформено PWA приложение без нужда от Flutter или Laravel. Поддържа офлайн, routing, теми, демо аутентикация, новини, събития и админ CRUD. По избор: интеграция с Firebase.

## Функционалности
- PWA с manifest и service worker (офлайн страница, cache strategies)
- Тема Light/Dark (оранжев/син акцент)
- Навигация: Bottom nav (мобилно) и Sidebar (десктоп)
- Auth: демо login/register, "биометричен" WebAuthn stub, email verification placeholder
- Home/News: карти + детайл с галерия
- Events: списък + мини-календар, детайл
- Profile: преглед и редакция
- Settings: тема, проверка за версия и обновяване
- Admin: CRUD за новини и събития (mock IndexedDB). Роли: director/admin (пълен контрол), worker (само преглед)

## Старт
1. Инсталиране на зависимости

```powershell
cd "c:\Users\kgeorgiev\OneDrive - taxbackunlimited.onmicrosoft.com\Desktop\app-1\pwa"; npm install
```

2. Dev сървър

```powershell
npm run dev
```

Отворете http://localhost:5173

3. Build

```powershell
npm run build; npm run preview
```

## Firebase (по избор)
- Копирайте `.env.example` като `.env` и попълнете Firebase параметрите. При наличие на `VITE_FIREBASE_API_KEY` ще се инициализира Firebase.
- Firestore структура (пример):
  - news: { id, title, cover, content, images[], createdAt }
  - events: { id, title, description, date, active, type, limit, photos[] }
  - users: { id, email, name, role, city, bio, phone, photoURL, emailVerified }

В демо режим се използва IndexedDB (idb).

## Google Drive (по избор)
- Не е включен UI по подразбиране. Може да добавите бутон за качване и да използвате Google Picker API (изисква OAuth клиент и API key). Вижте `.env.example`.

## Бележки
- Стиловете са Tailwind + Flowbite; компонентите са минимални, в духа на shadcn/ui.
- Router е hash-базиран без външни зависимости.
- Service Worker: network-first за навигации, cache-first за статични ресурси.

## Лиценз
MIT
