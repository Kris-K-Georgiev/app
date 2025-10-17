import { useEffect, useState } from 'react'
import { Button, Card, Label, TextInput, Avatar } from 'flowbite-react'
import { useAuthStore } from '../stores/auth'
import { db } from '../services/firebase'
import { doc, getDoc, setDoc } from 'firebase/firestore'

export default function Profile(){
  const user = useAuthStore(s => s.user)
  const [form, setForm] = useState({ name:'', city:'', bio:'', phone:'', avatar_path:'' })
  const [saving, setSaving] = useState(false)

  useEffect(()=>{
    if(!user) return
    (async()=>{
      const snap = await getDoc(doc(db,'users', user.uid))
      const d = snap.data() || {}
      setForm({
        name: d.name || user.displayName || '',
        city: d.city || '',
        bio: d.bio || '',
        phone: d.phone || '',
        avatar_path: d.avatar_path || d.photoURL || user.photoURL || ''
      })
    })()
  },[user])

  if(!user) return <div>Нужен е вход.</div>

  async function save(){
    setSaving(true)
    try { await setDoc(doc(db,'users', user.uid), form, { merge: true }) } finally { setSaving(false) }
  }

  return (
    <div className="max-w-2xl">
      <Card>
        <div className="flex items-center gap-4">
          <Avatar img={form.avatar_path} rounded />
          <div className="flex-1">
            <div className="grid md:grid-cols-2 gap-3">
              <div>
                <Label value="Име" />
                <TextInput value={form.name} onChange={e=>setForm(f=>({...f,name:e.target.value}))} />
              </div>
              <div>
                <Label value="Град" />
                <TextInput value={form.city} onChange={e=>setForm(f=>({...f,city:e.target.value}))} />
              </div>
              <div>
                <Label value="Телефон" />
                <TextInput value={form.phone} onChange={e=>setForm(f=>({...f,phone:e.target.value}))} />
              </div>
              <div>
                <Label value="Avatar URL (Drive/външен)" />
                <TextInput value={form.avatar_path} onChange={e=>setForm(f=>({...f,avatar_path:e.target.value}))} />
              </div>
              <div className="md:col-span-2">
                <Label value="Био" />
                <TextInput value={form.bio} onChange={e=>setForm(f=>({...f,bio:e.target.value}))} />
              </div>
            </div>
          </div>
        </div>
        <div className="flex justify-end">
          <Button onClick={save} isProcessing={saving}>Запази</Button>
        </div>
      </Card>
    </div>
  )
}
