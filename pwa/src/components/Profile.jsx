import { useEffect, useState } from 'react'
import { Button, Card, Label, TextInput, Avatar, Alert } from 'flowbite-react'
import { useAuthStore } from '../stores/auth'
import { db } from '../services/firebase'
import { doc, getDoc, setDoc } from 'firebase/firestore'

export default function Profile(){
  const user = useAuthStore(s => s.user)
  const [form, setForm] = useState({ name:'', city:'', bio:'', phone:'', avatar_path:'' })
  const [saving, setSaving] = useState(false)
  const [saved, setSaved] = useState(false)
  const [error, setError] = useState('')

  useEffect(()=>{
    if(!user) return
    (async()=>{
      try {
        const snap = await getDoc(doc(db,'users', user.uid))
        const d = snap.data() || {}
        setForm({
          name: d.name || user.displayName || '',
          city: d.city || '',
          bio: d.bio || '',
          phone: d.phone || '',
          avatar_path: d.avatar_path || d.photoURL || user.photoURL || ''
        })
      } catch (err) {
        setError('Грешка при зареждане на профила')
        console.error(err)
      }
    })()
  },[user])

  if(!user) {
    return (
      <div className="max-w-2xl mx-auto">
        <Card>
          <div className="text-center py-8">
            <h5 className="text-lg font-semibold text-gray-900 dark:text-white mb-2">
              Нужен е вход
            </h5>
            <p className="text-sm text-gray-500 dark:text-gray-400">
              Моля, влезте в профила си за да видите тази страница.
            </p>
          </div>
        </Card>
      </div>
    )
  }

  async function save(){
    setSaving(true)
    setError('')
    setSaved(false)
    try { 
      await setDoc(doc(db,'users', user.uid), form, { merge: true })
      setSaved(true)
      setTimeout(() => setSaved(false), 3000)
    } catch (err) {
      setError('Грешка при запазване на профила')
      console.error(err)
    } finally { 
      setSaving(false) 
    }
  }

  const updateForm = (field, value) => {
    setForm(f => ({ ...f, [field]: value }))
  }

  return (
    <div className="max-w-4xl mx-auto space-y-6">
      {/* Page header */}
      <div className="text-center">
        <h1 className="text-3xl font-bold text-gray-900 dark:text-white mb-2">
          Моят профил
        </h1>
        <p className="text-gray-600 dark:text-gray-400">
          Управлявайте информацията за вашия профил
        </p>
      </div>

      {/* Success/Error alerts */}
      {saved && (
        <Alert color="success" className="mb-4">
          Профилът е запазен успешно!
        </Alert>
      )}
      {error && (
        <Alert color="failure" className="mb-4">
          {error}
        </Alert>
      )}

      {/* Profile form */}
      <Card>
        <div className="space-y-6">
          {/* Avatar section */}
          <div className="flex items-center gap-6 pb-6 border-b border-gray-200 dark:border-gray-700">
            <Avatar 
              img={form.avatar_path} 
              rounded 
              size="xl"
              alt={form.name || 'Profile'}
            />
            <div className="flex-1">
              <h3 className="text-lg font-semibold text-gray-900 dark:text-white">
                Снимка на профила
              </h3>
              <p className="text-sm text-gray-500 dark:text-gray-400 mb-3">
                Добавете URL към изображение за вашия профил
              </p>
              <TextInput 
                placeholder="https://example.com/avatar.jpg"
                value={form.avatar_path} 
                onChange={e => updateForm('avatar_path', e.target.value)} 
              />
            </div>
          </div>

          {/* Basic information */}
          <div className="space-y-4">
            <h3 className="text-lg font-semibold text-gray-900 dark:text-white">
              Основна информация
            </h3>
            
            <div className="grid md:grid-cols-2 gap-4">
              <div>
                <Label htmlFor="name" value="Име" className="mb-2" />
                <TextInput 
                  id="name"
                  placeholder="Вашето име"
                  value={form.name} 
                  onChange={e => updateForm('name', e.target.value)} 
                />
              </div>
              <div>
                <Label htmlFor="city" value="Град" className="mb-2" />
                <TextInput 
                  id="city"
                  placeholder="София, Пловдив, Варна..."
                  value={form.city} 
                  onChange={e => updateForm('city', e.target.value)} 
                />
              </div>
              <div>
                <Label htmlFor="phone" value="Телефон" className="mb-2" />
                <TextInput 
                  id="phone"
                  placeholder="+359 XXX XXX XXX"
                  value={form.phone} 
                  onChange={e => updateForm('phone', e.target.value)} 
                />
              </div>
              <div>
                <Label htmlFor="email" value="Имейл" className="mb-2" />
                <TextInput 
                  id="email"
                  value={user.email || ''}
                  disabled
                  helperText="Имейлът не може да се променя"
                />
              </div>
            </div>

            <div>
              <Label htmlFor="bio" value="Биография" className="mb-2" />
              <TextInput 
                id="bio"
                placeholder="Разкажете малко за себе си..."
                value={form.bio} 
                onChange={e => updateForm('bio', e.target.value)} 
              />
            </div>
          </div>
        </div>

        {/* Save button */}
        <div className="flex justify-end pt-6 border-t border-gray-200 dark:border-gray-700">
          <Button 
            onClick={save} 
            isProcessing={saving}
            disabled={saving}
            color="blue"
            size="lg"
          >
            {saving ? 'Запазва...' : 'Запази промените'}
          </Button>
        </div>
      </Card>

      {/* Account information */}
      <Card>
        <div className="space-y-4">
          <h3 className="text-lg font-semibold text-gray-900 dark:text-white">
            Информация за акаунта
          </h3>
          <div className="grid md:grid-cols-2 gap-4 text-sm">
            <div className="flex justify-between">
              <span className="text-gray-500 dark:text-gray-400">User ID:</span>
              <span className="font-mono text-xs">{user.uid}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-500 dark:text-gray-400">Имейл:</span>
              <span>{user.email}</span>
            </div>
          </div>
        </div>
      </Card>
    </div>
  )
}
