#!/usr/bin/env node
import fs from 'fs'
import path from 'path'
import { parse } from 'csv-parse'
import admin from 'firebase-admin'

const dirIdx = process.argv.findIndex(a => a === '--dir')
const dir = dirIdx > -1 ? process.argv[dirIdx + 1] : './csv'

if (!process.env.GOOGLE_APPLICATION_CREDENTIALS) {
  console.error('Set GOOGLE_APPLICATION_CREDENTIALS to your service account JSON path')
  process.exit(1)
}

admin.initializeApp({ credential: admin.credential.applicationDefault() })
const db = admin.firestore()

async function importCsv(file, handler) {
  const records = []
  await new Promise((resolve, reject) => {
    fs.createReadStream(file)
      .pipe(parse({ columns: true, skip_empty_lines: true }))
      .on('data', r => records.push(r))
      .on('end', resolve)
      .on('error', reject)
  })
  for (const r of records) await handler(r)
}

async function main() {
  const usersCsv = path.join(dir, 'users.csv')
  if (fs.existsSync(usersCsv)) {
    console.log('Import users...')
    await importCsv(usersCsv, async r => {
      const uid = r.id || r.uid || r.email
      const docRef = db.collection('users').doc(String(uid))
      await docRef.set({
        name: r.name,
        email: r.email,
        role: r.role || 'user',
        city: r.city || null,
        avatar_path: r.avatar_path || null,
        bio: r.bio || null,
        phone: r.phone || null,
        status: r.status || 'active'
      }, { merge: true })
    })
  }

  const etCsv = path.join(dir, 'event_types.csv')
  if (fs.existsSync(etCsv)) {
    console.log('Import event_types...')
    await importCsv(etCsv, async r => {
      await db.collection('event_types').doc(String(r.id)).set({ slug: r.slug, name: r.name, color: r.color })
    })
  }

  const eventsCsv = path.join(dir, 'events.csv')
  if (fs.existsSync(eventsCsv)) {
    console.log('Import events...')
    await importCsv(eventsCsv, async r => {
      await db.collection('events').doc(String(r.id)).set({
        title: r.title,
        description: r.description,
        location: r.location,
        start_date: r.start_date,
        end_date: r.end_date,
        start_time: r.start_time,
        images: r.images ? JSON.parse(r.images) : [],
        cover: r.cover || null,
        city: r.city || null,
        audience: r.audience || null,
        limit: r.limit ? Number(r.limit) : null,
        registrations_count: r.registrations_count ? Number(r.registrations_count) : 0,
        event_type_id: r.event_type_id ? String(r.event_type_id) : null,
        status: r.status || 'active',
        created_by: r.created_by ? String(r.created_by) : null
      })
    })
  }

  const regsCsv = path.join(dir, 'event_registrations.csv')
  if (fs.existsSync(regsCsv)) {
    console.log('Import event_registrations...')
    await importCsv(regsCsv, async r => {
      await db.collection('events').doc(String(r.event_id))
        .collection('registrations').doc()
        .set({ uid: String(r.user_id), status: r.status || 'registered' })
    })
  }

  const newsCsv = path.join(dir, 'news.csv')
  if (fs.existsSync(newsCsv)) {
    console.log('Import news...')
    await importCsv(newsCsv, async r => {
      await db.collection('news').doc(String(r.id)).set({
        title: r.title,
        content: r.content,
        image: r.image || null,
        cover: r.cover || null,
        status: r.status || 'published',
        created_by: r.created_by ? String(r.created_by) : null
      })
    })
  }

  const imgsCsv = path.join(dir, 'news_images.csv')
  if (fs.existsSync(imgsCsv)) {
    console.log('Import news_images...')
    await importCsv(imgsCsv, async r => {
      await db.collection('news').doc(String(r.news_id))
        .collection('images').doc(String(r.id)).set({ path: r.path, position: Number(r.position || 0) })
    })
  }

  const likesCsv = path.join(dir, 'news_likes.csv')
  if (fs.existsSync(likesCsv)) {
    console.log('Import news_likes...')
    await importCsv(likesCsv, async r => {
      await db.collection('news').doc(String(r.news_id))
        .collection('likes').doc(String(r.user_id)).set({ liked: true })
    })
  }

  const commentsCsv = path.join(dir, 'news_comments.csv')
  if (fs.existsSync(commentsCsv)) {
    console.log('Import news_comments...')
    await importCsv(commentsCsv, async r => {
      await db.collection('news').doc(String(r.news_id))
        .collection('comments').doc(String(r.id)).set({ user_id: String(r.user_id), content: r.content })
    })
  }

  const verCsv = path.join(dir, 'app_versions.csv')
  if (fs.existsSync(verCsv)) {
    console.log('Import app_versions...')
    await importCsv(verCsv, async r => {
      await db.collection('app_versions').doc(String(r.id)).set({
        version_code: r.version_code,
        version_name: r.version_name,
        release_notes: r.release_notes,
        is_mandatory: r.is_mandatory === '1' || r.is_mandatory === 'true',
        download_url: r.download_url
      })
    })
  }

  console.log('Done.')
}

main().catch(e => { console.error(e); process.exit(1) })
