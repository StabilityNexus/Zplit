import React, { useState } from 'react'

export default function AccountSetup(){
  const [username, setUsername] = useState('')
  const [name, setName] = useState('')
  const [avatar, setAvatar] = useState<File | null>(null)

  function chooseFile(e:any){ setAvatar(e.target.files[0]) }
  function save(e:any){ e.preventDefault(); alert('Saved (demo)') }

  return (
    <div className="container">
      <h2>Account Setup</h2>
      <form onSubmit={save} className="card">
        <label>Username</label>
        <input value={username} onChange={e=>setUsername(e.target.value)} />
        <label>Name</label>
        <input value={name} onChange={e=>setName(e.target.value)} />
        <label>Profile Picture</label>
        <input type="file" onChange={chooseFile} />
        <div style={{ marginTop: 12 }}>
          <button type="submit">Save</button>
        </div>
      </form>
    </div>
  )
}
