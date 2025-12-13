import React from 'react'

const sample = [ {label:'Food', value: 120}, {label:'Transport', value: 60}, {label:'Rent', value: 400}, {label:'Utilities', value: 80} ]

function BarChart({ data }:{ data: {label:string; value:number}[] }){
  const max = Math.max(...data.map(d=>d.value))
  const colors = ['var(--primary)', 'var(--secondary)', 'var(--success)', 'var(--warning)']
  return (
    <svg width="100%" height={200} viewBox={`0 0 100 30`} preserveAspectRatio="none">
      {data.map((d, i) => {
        const w = (d.value / max) * 80
        const y = i * 6 + 2
        return (
          <g key={i} transform={`translate(10, ${y})`}>
            <rect x={0} y={0} width={w} height={4} fill={colors[i % colors.length]} rx={1} />
            <text x={w + 1} y={3} fontSize={1.6} fill='var(--muted)'>${d.value}</text>
            <text x={-9} y={3} fontSize={1.6} fill='var(--muted)' textAnchor='start'>{d.label}</text>
          </g>
        )
      })}
    </svg>
  )
}

export default function Graphs(){
  return (
    <div className="container">
      <h2>Spending Insights</h2>
      <div className="graphs-layout">
        <div className="card neon-glow">
        <h3 className="neon-text">Monthly Spend</h3>
        <BarChart data={sample} />
        </div>
        <div className="card neon-glow" style={{ marginTop: 12 }}>
        <h3 className="neon-text">Breakdown</h3>
        <div style={{ display: 'flex', gap: 8 }}>
          {sample.map((s, idx) => {
            const colors = ['var(--primary)', 'var(--secondary)', 'var(--success)', 'var(--warning)']
            return (
            <div key={s.label} style={{ flex: 1, background: colors[idx % colors.length], padding: 8, borderRadius: 6, color: 'white' }}>
              <div style={{ fontWeight: 600 }}>{s.label}</div>
              <div style={{ opacity: 0.9 }}>${s.value}</div>
            </div>
            )
          })}
        </div>
      </div>
    </div>
  </div>
  )
}
