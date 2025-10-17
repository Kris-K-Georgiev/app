import { Button, Select, TextInput } from 'flowbite-react'
import { useContentStore } from '../stores/content'

export default function EventsFilters() {
  const { selectedCity, selectedType, setSelectedCity, setSelectedType, setSelectedDate } = useContentStore(s => ({
    selectedCity: s.selectedCity,
    selectedType: s.selectedType,
    setSelectedCity: s.setSelectedCity,
    setSelectedType: s.setSelectedType,
    setSelectedDate: s.setSelectedDate
  }))

  function clearFilters(){ setSelectedCity(null); setSelectedType(null); setSelectedDate(null) }

  return (
    <div className="flex flex-wrap gap-3 items-end">
      <div>
        <label className="block text-sm mb-1">Тип</label>
        <Select value={selectedType ?? ''} onChange={(e)=>setSelectedType(e.target.value || null)}>
          <option value="">Всички</option>
          <option value="open">Отворени</option>
          <option value="city">По град</option>
          <option value="limited">Ограничени</option>
        </Select>
      </div>
      <div>
        <label className="block text-sm mb-1">Град</label>
        <TextInput value={selectedCity ?? ''} onChange={(e)=>setSelectedCity(e.target.value || null)} placeholder="напр. Sofia" />
      </div>
      <Button color="light" onClick={clearFilters}>Изчисти</Button>
    </div>
  )
}
