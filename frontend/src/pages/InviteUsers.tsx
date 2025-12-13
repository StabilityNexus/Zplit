import React, { useState } from 'react'

export default function InviteUsers(){
  const [method, setMethod] = useState<'link'|'email'>('link')
  const [address, setAddress] = useState('')

  function send(e:any){ e.preventDefault(); alert('Invited: ' + address) }

  return (
    <div className="container">
      <h2>Invite Users</h2>
      <div className="card">
        <div style={{ display: 'flex', gap: 8 }}>
          <select value={method} onChange={e=>setMethod(e.target.value as any)}>
            <option value="link">Invite Link</option>
            <option value="email">Email</option>
          </select>
          {method === 'email' && <input placeholder="Email address" value={address} onChange={e=>setAddress(e.target.value)} />}
          <button onClick={send}>Send</button>
        </div>
        {method === 'link' && <div style={{ marginTop: 8 }}><input readOnly value={window.location.href + 'invite?code=' + Math.random().toString(36).slice(2,8)} /></div>}
      </div>
    </div>
  )
}
