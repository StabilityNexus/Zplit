import React, { useEffect, useRef, useState } from 'react'

interface Item { id: number; label: string; amount: number }

interface Props { items: Item[]; onClose: () => void; onSplit: (result: { [id:number]: number }) => void }

export default function SplitModal({ items, onClose, onSplit }: Props){
  const [members, setMembers] = useState<string[]>(['Alice','Bob','You'])
  const [selected, setSelected] = useState<Record<string, boolean>>({ 'Alice': true, 'Bob': true, 'You': true })
  const modalRef = useRef<HTMLDivElement | null>(null)
  const firstInputRef = useRef<HTMLInputElement | null>(null)

  useEffect(()=>{ firstInputRef.current?.focus(); function onKey(e: KeyboardEvent){ if(e.key === 'Escape') onClose() } window.addEventListener('keydown', onKey); return ()=> window.removeEventListener('keydown', onKey) }, [onClose])

  useEffect(()=>{ const prev = document.body.style.overflow; document.body.style.overflow = 'hidden'; return ()=> { document.body.style.overflow = prev } }, [])

  function toggle(name: string){ setSelected(s => ({ ...s, [name]: !s[name] })) }

  function doSplit(){
    const chosen = members.filter(m => selected[m])
    if (!chosen.length) return alert('Select at least one participant')
    // split each item equally among chosen participants and sum per participant
    const totals: Record<string, number> = {}
    for(const m of chosen) totals[m] = 0
    for(const it of items){
      const share = it.amount / chosen.length
      for(const m of chosen) totals[m] += share
    }
    onSplit(totals as any)
    onClose()
  }

  return (
    <div className="modal-overlay" role="dialog" aria-modal="true" aria-label="Split bill dialog">
      <div className="modal" ref={modalRef} style={{ width: 520, maxWidth: '94vw' }}>
        <h3>Split Bill</h3>
        <p style={{ color: 'var(--muted)', marginTop: 4 }}>Choose participants to split the selected expenses equally.</p>
        <div style={{ marginTop: 12 }}>
          <div style={{ display:'flex', gap:8, flexWrap:'wrap' }}>
            {members.map((m, i) => (
              <label key={m} style={{ display:'inline-flex', alignItems:'center', gap:8 }}>
                <input ref={i===0 ? firstInputRef : undefined} type="checkbox" checked={!!selected[m]} onChange={() => toggle(m)} />
                <span>{m}</span>
              </label>
            ))}
          </div>
        </div>

        <div style={{ marginTop: 12 }}>
          <h4 style={{ margin: '6px 0' }}>Selected items</h4>
          <ul>
            {items.map(it => (
              <li key={it.id}>{it.label}: ${it.amount.toFixed(2)}</li>
            ))}
          </ul>
        </div>

        <div style={{ marginTop: 12, display:'flex', gap: 8, justifyContent: 'flex-end' }}>
          <button className="btn-secondary" onClick={onClose}>Cancel</button>
          <button onClick={doSplit}>Split</button>
        </div>
      </div>
    </div>
  )
}
