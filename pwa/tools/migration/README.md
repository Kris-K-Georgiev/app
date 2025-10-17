# Миграция от Laravel (MySQL) към Firestore

Подходи:
- Експорт на таблици като CSV и импорт през Node скрипт (firebase-admin)
- Директна миграция с временен скрипт, който чете от старата БД (не е включено тук)

## CSV → Firestore (пример)
1. Експортирай `users, events, event_types, event_registrations, news, news_images, news_likes, news_comments, app_versions` като CSV.
2. Създай service account JSON от Firebase и постави пътя в `GOOGLE_APPLICATION_CREDENTIALS`.
3. Инсталирай зависимости и стартирай.

```powershell
cd tools/migration
npm init -y
npm install firebase-admin csv-parse
node migrate-csv.js --dir "path/to/csv"
```
