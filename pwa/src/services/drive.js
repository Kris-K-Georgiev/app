// Lightweight Google Drive API wrapper using Google Identity Services (GIS) + gapi
// Scopes: drive.file, drive.readonly

const SCOPES = 'https://www.googleapis.com/auth/drive.file https://www.googleapis.com/auth/drive.readonly'
const DISCOVERY_DOC = 'https://www.googleapis.com/discovery/v1/apis/drive/v3/rest'

let gapiLoaded = false
let tokenClient

function loadScript(src) {
  return new Promise((resolve, reject) => {
    const el = document.createElement('script')
    el.src = src
    el.async = true
    el.onload = resolve
    el.onerror = reject
    document.head.appendChild(el)
  })
}

async function ensureGapi() {
  if (!gapiLoaded) {
    await loadScript('https://apis.google.com/js/api.js')
    await new Promise(resolve => window.gapi.load('client', resolve))
    await window.gapi.client.init({ discoveryDocs: [DISCOVERY_DOC] })
    gapiLoaded = true
  }
}

function ensureTokenClient() {
  if (!tokenClient) {
    if (!window.google) throw new Error('Google Identity Services not loaded')
    tokenClient = window.google.accounts.oauth2.initTokenClient({
      client_id: import.meta.env.VITE_GOOGLE_CLIENT_ID,
      scope: SCOPES,
      prompt: '',
      callback: () => {}
    })
  }
  return tokenClient
}

async function ensureGis() {
  if (!window.google) {
    await loadScript('https://accounts.google.com/gsi/client')
  }
}

async function ensureAccessToken() {
  await ensureGis()
  await ensureGapi()
  const client = ensureTokenClient()
  return new Promise((resolve, reject) => {
    client.callback = (resp) => {
      if (resp.error) reject(resp)
      else resolve(resp.access_token)
    }
    const stored = window.gapi.client.getToken?.()
    if (!stored) client.requestAccessToken({ prompt: 'consent' })
    else client.requestAccessToken({ prompt: '' })
  })
}

export async function listMyFiles() {
  await ensureAccessToken()
  const res = await window.gapi.client.drive.files.list({
    pageSize: 50,
    fields: 'files(id, name, mimeType, modifiedTime, webViewLink)',
    spaces: 'drive',
    q: "trashed = false"
  })
  return res.result.files || []
}

export async function uploadFile({ name, mimeType, data }) {
  await ensureAccessToken()
  const metadata = { name, mimeType }
  const boundary = '-------314159265358979323846'
  const delimiter = `\r\n--${boundary}\r\n`
  const closeDelim = `\r\n--${boundary}--`
  const base64Data = btoa(String.fromCharCode(...new Uint8Array(data)))
  const body =
    delimiter +
    'Content-Type: application/json; charset=UTF-8\r\n\r\n' +
    JSON.stringify(metadata) +
    delimiter +
    `Content-Type: ${mimeType || 'application/octet-stream'}\r\n` +
    'Content-Transfer-Encoding: base64\r\n\r\n' +
    base64Data +
    closeDelim

  const res = await window.gapi.client.request({
    path: '/upload/drive/v3/files?uploadType=multipart',
    method: 'POST',
    headers: { 'Content-Type': `multipart/related; boundary=${boundary}` },
    body
  })
  return res.result
}
// Lightweight Google Drive integration using Google Identity Services (GIS) + gapi
// Requires env vars: VITE_GOOGLE_CLIENT_ID

let gapiLoaded = false
let tokenClient

const SCOPES = 'https://www.googleapis.com/auth/drive.file https://www.googleapis.com/auth/drive.readonly'

function loadScript(src) {
  return new Promise((resolve, reject) => {
    const s = document.createElement('script')
    s.src = src
    s.async = true
    s.onload = resolve
    s.onerror = reject
    document.head.appendChild(s)
  })
}

export async function initDrive() {
  if (gapiLoaded) return
  await loadScript('https://apis.google.com/js/api.js')
  await loadScript('https://accounts.google.com/gsi/client')
  await new Promise(res => window.gapi.load('client', res))
  await window.gapi.client.init({})
  tokenClient = google.accounts.oauth2.initTokenClient({
    client_id: import.meta.env.VITE_GOOGLE_CLIENT_ID,
    scope: SCOPES,
    callback: () => {}
  })
  gapiLoaded = true
}

export async function ensureAccessToken() {
  await initDrive()
  return new Promise((resolve, reject) => {
    tokenClient.callback = resp => {
      if (resp.error) reject(resp)
      else resolve(resp.access_token)
    }
    tokenClient.requestAccessToken({ prompt: '' })
  })
}

export async function listMyFiles() {
  await ensureAccessToken()
  const res = await window.gapi.client.request({
    path: 'https://www.googleapis.com/drive/v3/files',
    params: { pageSize: 20, fields: 'files(id,name,mimeType,modifiedTime,thumbnailLink,webViewLink)' }
  })
  return res.result.files
}

export async function uploadFile({ name, mimeType, data }) {
  await ensureAccessToken()
  const metadata = { name, mimeType }
  const boundary = '-------314159265358979323846'
  const delimiter = `\r\n--${boundary}\r\n`
  const closeDelim = `\r\n--${boundary}--`
  const base64Data = btoa(
    new Uint8Array(data).reduce((d, b) => d + String.fromCharCode(b), '')
  )
  const body = 
    `${delimiter}Content-Type: application/json; charset=UTF-8\r\n\r\n` +
    `${JSON.stringify(metadata)}${delimiter}Content-Type: ${mimeType}\r\n` +
    `Content-Transfer-Encoding: base64\r\n\r\n${base64Data}${closeDelim}`
  const res = await fetch('https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart', {
    method: 'POST',
    headers: {
      'Content-Type': `multipart/related; boundary=${boundary}`,
      Authorization: `Bearer ${gapi.client.getToken().access_token}`
    },
    body
  })
  return res.json()
}
