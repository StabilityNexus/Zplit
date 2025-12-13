import React, { useState } from 'react'

interface Group { id: number; name: string; members: string[] }

export default function Groups(){
  const [groups, setGroups] = useState<Group[]>([{ id: 1, name: 'Trip', members: ['Alice', 'Bob'] }])
  const [name, setName] = useState('')

  function create(e:any){ e.preventDefault(); setGroups([...groups, { id: Date.now(), name, members: [] }]); setName('') }

  return (
    <div className="container">
      <h2>Groups</h2>
      <div className="card">
        <form onSubmit={create} style={{ display: 'flex', gap: 8 }}>
          <input placeholder="New group name" value={name} onChange={e=>setName(e.target.value)} />
          <button type="submit">Create</button>
        </form>
      </div>

      <div style={{ marginTop: 12 }}>
        {groups.map(g => (
          <div key={g.id} className="card small neon-glow">
            <div style={{display:'flex', justifyContent:'space-between', alignItems:'center'}}>
              <div>
                <b className="neon-text">{g.name}</b>
                <div style={{ fontSize: 12, color: 'var(--muted)' }}>{g.members.length} members</div>
              </div>
              <button>Open</button>
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}
