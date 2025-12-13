import React, { useEffect, useState } from 'react'
import api, { setAuthToken } from '../api'

export default function DeepLinkAdmin(){
  const [items, setItems] = useState<any[]>([])
  const [content, setContent] = useState('{}')
  const [platform, setPlatform] = useState('ANDROID')

  useEffect(()=>{ const t = localStorage.getItem('token'); if(t) setAuthToken(t); fetchData(); }, [])

  async function fetchData(){
    try{ const res = await api.get('/admin/deeplink'); setItems(res.data); }catch(err){ console.error(err) }
  }

  async function create(){
    try{
      const parsed = JSON.parse(content)
      await api.post('/admin/deeplink', { platform, content: parsed });
      setContent('{}'); fetchData();
    }catch(err:any){ alert(err?.response?.data?.message || 'Error') }
  }

  async function update(id:number){
    try{ const parsed = JSON.parse(content); await api.put(`/admin/deeplink/${id}`, { content: parsed }); fetchData(); }catch(err:any){ alert(err?.response?.data?.message || 'Error') }
  }

  return (
    <div className="container">
      <h2>Deep Link Admin</h2>
      <div style={{display:'flex', gap:8}}>
        <select value={platform} onChange={e=>setPlatform(e.target.value)}><option value="ANDROID">Android</option><option value="IOS">iOS</option></select>
        <textarea value={content} onChange={e=>setContent(e.target.value)} rows={8} cols={60} />
      </div>
      <div style={{marginTop: 8}}>
        <button onClick={create}>Create</button>
      </div>

      <h3>Existing</h3>
      <ul>
        {items.map(i=> (
          <li key={i.id}>
            <b>{i.platform}</b> id: {i.id} updated: {new Date(i.updatedAt).toLocaleString()}
            <button onClick={()=> setContent(JSON.stringify(i.content, null, 2)) }>Load</button>
            <button onClick={()=> update(i.id)}>Update with current</button>
          </li>
        ))}
      </ul>
    </div>
  )
}
