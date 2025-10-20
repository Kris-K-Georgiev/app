import { h } from 'htm/preact';import { h } from 'htm/preact'

export default function Home() {import NewsCard from '../components/NewsCard.js'

  return h('div', {class:'p-8 text-center'}, 'Добре дошли във Feed/Home!');

}const sampleNews = [

  {id:'1',title:'Новина 1',cover:'/icons/icon-192.png',excerpt:'Кратко описание'},
  {id:'2',title:'Новина 2',cover:'/icons/icon-192.png',excerpt:'Кратко описание 2'}
]

export default function Home(){
  return h('div',{},[
    h('h1',{class:'text-2xl font-bold mb-4'}, 'Новини'),
    h('div',{class:'grid grid-cols-1 sm:grid-cols-2 gap-4'}, sampleNews.map(n=>h(NewsCard,{news:n})))
  ])
}
