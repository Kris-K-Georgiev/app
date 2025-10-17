export function renderSparkline(values = [], { width = 180, height = 36, stroke = '#3b82f6', fill = 'none' } = {}){
  if (!values.length) return `<svg width="${width}" height="${height}"></svg>`
  const max = Math.max(...values, 1)
  const step = width / (values.length - 1)
  const points = values.map((v, i) => [i * step, height - (v / max) * (height - 4) - 2])
  const d = points.map((p, i) => (i === 0 ? `M ${p[0]},${p[1]}` : `L ${p[0]},${p[1]}`)).join(' ')
  return `<svg width="${width}" height="${height}" viewBox="0 0 ${width} ${height}"><path d="${d}" stroke="${stroke}" stroke-width="2" fill="${fill}" stroke-linecap="round" stroke-linejoin="round"/></svg>`
}

export function lastNDaysCounts(posts = [], days = 30){
  const byDay = Array.from({ length: days }, () => 0)
  const now = Date.now()
  const one = 86400000
  posts.forEach(p => {
    const d = Math.floor((now - p.createdAt) / one)
    if (d >= 0 && d < days) byDay[days - 1 - d]++
  })
  return byDay
}