function storageKey(room){ return `chatMessages:${room||'general'}` }
export function loadMessages(room='general'){
  try { return JSON.parse(localStorage.getItem(storageKey(room))||'[]') } catch { return [] }
}
export function saveMessages(room, list){ localStorage.setItem(storageKey(room), JSON.stringify(list)) }
export function loadRooms(){ try { return JSON.parse(localStorage.getItem('chatRooms')||'["general","events","support"]') } catch { return ['general','events','support'] } }
export function saveRooms(list){ localStorage.setItem('chatRooms', JSON.stringify(list)) }
