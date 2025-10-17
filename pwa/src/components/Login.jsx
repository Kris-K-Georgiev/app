import { useState } from 'react'
import { Button, Card, Label, TextInput, Alert } from 'flowbite-react'
import { useNavigate, Link } from 'react-router-dom'
import { useAuthState } from '../services/auth'

export default function Login() {
  const { signInEmail, signInGoogle } = useAuthState()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)
  const navigate = useNavigate()

  const submit = async e => {
    e.preventDefault()
    setError('')
    setLoading(true)
    
    try {
      await signInEmail(email, password)
      navigate('/')
    } catch (err) {
      setError('Грешка при влизане: ' + (err.message || 'Неизвестна грешка'))
    } finally {
      setLoading(false)
    }
  }

  const signInWithGoogle = async () => {
    setError('')
    setLoading(true)
    
    try {
      await signInGoogle()
      navigate('/')
    } catch (err) {
      setError('Грешка при влизане с Google: ' + (err.message || 'Неизвестна грешка'))
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-md w-full space-y-8">
        {/* Header */}
        <div className="text-center">
          <h1 className="text-3xl font-bold text-gray-900 dark:text-white mb-2">
            Добре дошли
          </h1>
          <p className="text-gray-600 dark:text-gray-400">
            Влезте в профила си за да продължите
          </p>
        </div>

        <Card className="w-full">
          <form onSubmit={submit} className="space-y-6">
            <div>
              <Label htmlFor="email" value="Имейл адрес" className="mb-2" />
              <TextInput 
                id="email" 
                type="email" 
                placeholder="example@domain.com"
                value={email} 
                onChange={e => setEmail(e.target.value)} 
                required 
                disabled={loading}
              />
            </div>
            
            <div>
              <Label htmlFor="password" value="Парола" className="mb-2" />
              <TextInput 
                id="password" 
                type="password" 
                placeholder="Въведете вашата парола"
                value={password} 
                onChange={e => setPassword(e.target.value)} 
                required 
                disabled={loading}
              />
            </div>

            {error && (
              <Alert color="failure">
                {error}
              </Alert>
            )}

            <div className="space-y-3">
              <Button 
                type="submit" 
                className="w-full" 
                isProcessing={loading}
                disabled={loading}
              >
                {loading ? 'Влизане...' : 'Влизане'}
              </Button>
              
              <div className="relative">
                <div className="absolute inset-0 flex items-center">
                  <div className="w-full border-t border-gray-300 dark:border-gray-600" />
                </div>
                <div className="relative flex justify-center text-sm">
                  <span className="px-2 bg-white dark:bg-gray-800 text-gray-500 dark:text-gray-400">
                    или
                  </span>
                </div>
              </div>
              
              <Button 
                type="button" 
                color="light" 
                className="w-full"
                onClick={signInWithGoogle}
                disabled={loading}
              >
                <svg className="w-5 h-5 mr-2" viewBox="0 0 24 24">
                  <path fill="currentColor" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
                  <path fill="currentColor" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
                  <path fill="currentColor" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
                  <path fill="currentColor" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
                </svg>
                Влизане с Google
              </Button>
            </div>
          </form>

          {/* Footer links */}
          <div className="text-center pt-4 border-t border-gray-200 dark:border-gray-700">
            <p className="text-sm text-gray-500 dark:text-gray-400">
              Нямате акаунт?{' '}
              <a href="#" className="text-blue-600 hover:text-blue-500 dark:text-blue-400">
                Регистрирайте се
              </a>
            </p>
            <p className="text-xs text-gray-400 dark:text-gray-500 mt-2">
              <a href="#" className="hover:text-gray-600 dark:hover:text-gray-300">
                Забравена парола?
              </a>
            </p>
          </div>
        </Card>
      </div>
    </div>
  )
}
