import React, { useEffect, useState } from 'react'
import api, { setAuthToken } from '../api'

interface Ad {
  id: number
  ad_name: string
  target_url: string
  start_date: string
  end_date: string
  status: string
  clientId: number
}

export default function Dashboard() {
  const [ads, setAds] = useState<Ad[]>([])
  const [tokenLoaded, setTokenLoaded] = useState(false)
  const [search, setSearch] = useState('')
  const [status, setStatus] = useState('')
  const [editing, setEditing] = useState<Ad | null>(null)

  useEffect(() => {
    const token = localStorage.getItem('token')
    if (token) setAuthToken(token)
    setTokenLoaded(true)
  }, [])

  useEffect(() => { if (tokenLoaded) fetchAds() }, [tokenLoaded, search, status])

  async function fetchAds(){
    try{
      const q: any = {}
      if (search) q.search = search
      if (status) q.status = status
      const res = await api.get('/ads', { params: q })
      setAds(res.data)
    }catch(err){ console.error(err) }
  }

  function startEdit(ad: Ad){ setEditing(ad) }
  function cancelEdit(){ setEditing(null) }

  async function saveEdit(e: any){
    e.preventDefault()
    if (!editing) return
    try{
      const data = { ad_name: editing.ad_name, target_url: editing.target_url, start_date: editing.start_date, end_date: editing.end_date, status: editing.status }
      if (editing.id) await api.put(`/ads/${editing.id}`, data)
      else await api.post('/ads', data)
      setEditing(null)
      fetchAds()
    }catch(err){ console.error(err) }
  }

  async function doDelete(id:number){ if(!confirm('Delete?')) return; await api.delete(`/ads/${id}`); fetchAds(); }

  return (
    <div className="container">
      <div className="dashboard-header">
        <h2 className="neon-green-text">Dashboard</h2>
        <p>Manage your ads and campaigns</p>
      </div>
      <div style={{ display: 'flex', gap: 8 }}>
        <input placeholder="Search" value={search} onChange={e => setSearch(e.target.value)} />
        <select value={status} onChange={e => setStatus(e.target.value)}>
          <option value="">All</option>
          <option value="active">Active</option>
          <option value="paused">Paused</option>
          <option value="archived">Archived</option>
        </select>
        <button onClick={() => setEditing({ id: 0, ad_name: '', target_url: '', start_date: new Date().toISOString(), end_date: new Date().toISOString(), status: 'ACTIVE', clientId: 0})} style={{ color: '#00ff00' }}>New</button>
      </div>
      <table>
        <thead><tr style={{ background: 'var(--primary)', color: 'white' }}><th>ID</th><th>Name</th><th>URL</th><th>Status</th><th>Actions</th></tr></thead>
        <tbody>
          {ads.map(a => (
            <tr key={a.id}><td>{a.id}</td><td>{a.ad_name}</td><td>{a.target_url}</td><td>{a.status}</td><td>
              <button onClick={() => startEdit(a)}>Edit</button>
              <button onClick={() => doDelete(a.id)}>Delete</button>
            </td></tr>
          ))}
        </tbody>
      </table>

      {editing && (
        <div className="modal">
          <form onSubmit={saveEdit}>
            <h3>{editing.id ? 'Edit Ad' : 'Create Ad'}</h3>
            <label>Name</label>
            <input value={editing.ad_name} onChange={e => setEditing({...editing, ad_name: e.target.value})} />
            <label>URL</label>
            <input value={editing.target_url} onChange={e => setEditing({...editing, target_url: e.target.value})} />
            <label>Start</label>
            <input type="datetime-local" value={(new Date(editing.start_date)).toISOString().slice(0,16)} onChange={e => setEditing({...editing, start_date: new Date(e.target.value).toISOString()})} />
            <label>End</label>
            <input type="datetime-local" value={(new Date(editing.end_date)).toISOString().slice(0,16)} onChange={e => setEditing({...editing, end_date: new Date(e.target.value).toISOString()})} />
            <label>Status</label>
            <select value={editing.status} onChange={e => setEditing({...editing, status: e.target.value})}>
              <option value="ACTIVE">Active</option>
              <option value="PAUSED">Paused</option>
              <option value="ARCHIVED">Archived</option>
            </select>
            <div style={{ marginTop: 8 }}>
              <button type="submit">Save</button>
              <button type="button" className="btn-secondary" onClick={cancelEdit}>Cancel</button>
            </div>
          </form>
        </div>
      )}
    </div>
  )
}
