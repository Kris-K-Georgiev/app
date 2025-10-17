import { useState } from 'react'
import { Button, Card, Label, TextInput } from 'flowbite-react'
import { useNavigate } from 'react-router-dom'
import { useAuthState } from '../services/auth'

export default function Login() {
  const { signInEmail, signInGoogle } = useAuthState()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')
  const navigate = useNavigate()

  const submit = async e => {
    e.preventDefault()
    setError('')
    try {
      await signInEmail(email, password)
      navigate('/')
    } catch (err) {
      setError(err.message)
    }
  }

  return (
    <div className="flex items-center justify-center py-10">
      <Card className="w-full max-w-md">
        <h1 className="text-2xl font-semibold">Вход</h1>
        <form onSubmit={submit} className="space-y-4">
          <div>
            <Label htmlFor="email" value="Имейл" />
            <TextInput id="email" type="email" value={email} onChange={e=>setEmail(e.target.value)} required />
          </div>
          <div>
            <Label htmlFor="password" value="Парола" />
            <TextInput id="password" type="password" value={password} onChange={e=>setPassword(e.target.value)} required />
          </div>
          {error && <p className="text-red-500 text-sm">{error}</p>}
          <div className="flex gap-2">
            <Button type="submit" className="flex-1">Вход</Button>
            <Button color="light" type="button" className="flex-1" onClick={()=>signInGoogle().then(()=>navigate('/'))}>Google</Button>
          </div>
        </form>
      </Card>
    </div>
  )
}
