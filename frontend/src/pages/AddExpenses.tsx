import React, { useState } from 'react'
import SplitButton from '../components/SplitButton'
import SplitModal from '../components/SplitModal'

export default function AddExpenses(){
  const [items, setItems] = useState<{ id: number; label: string; amount: number }[]>([])
  const [label, setLabel] = useState('')
  const [amount, setAmount] = useState<number | ''>('')

  function add(e:any){ e.preventDefault(); setItems([...items, { id: Date.now(), label, amount: Number(amount) }]); setLabel(''); setAmount('') }

  const [open, setOpen] = useState(false)
  const [splitResult, setSplitResult] = useState<{ [member:string]: number } | null>(null)

  function handleSplit(result: { [id:number]: number }){
    setSplitResult(result as any)
  }

  return (
    <div className="container">
      <h2>Add Expense</h2>
      <div className="card">
        <form onSubmit={add} style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
          <input placeholder="Label" value={label} onChange={e=>setLabel(e.target.value)} />
          <input placeholder="Amount" type="number" value={amount as any} onChange={e=>setAmount(Number(e.target.value))} />
          <button type="submit">Add</button>
          <SplitButton label="Split Bill" onClick={() => setOpen(true)} />
        </form>
      </div>

      {splitResult && (
        <div style={{ marginTop: 12 }} className="card neon-glow">
          <h4 className="neon-text">Split Result</h4>
          <ul>
            {Object.keys(splitResult).map(k => (
              <li key={k}><span className="neon-text">{k}:</span> ${splitResult[k].toFixed(2)}</li>
            ))}
          </ul>
        </div>
      )}

      {open && <SplitModal items={items} onClose={() => setOpen(false)} onSplit={(s) => handleSplit(s as any)} />}

      <div style={{ marginTop: 12 }}>
        <table>
          <thead><tr><th>Label</th><th>Amount</th><th></th></tr></thead>
          <tbody>
            {items.map(i => (
              <tr key={i.id}><td>{i.label}</td><td>${i.amount.toFixed(2)}</td><td><button className="btn-secondary" onClick={()=>setItems(items.filter(x => x.id !== i.id))}>Remove</button></td></tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  )
}
