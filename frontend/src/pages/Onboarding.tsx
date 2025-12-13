import React from 'react'

export default function Onboarding(){
  const slides = [
    { title: 'Privacy-first', desc: 'Decentralized accounts. You control your data.' },
    { title: 'Simple Expense Splits', desc: 'Create groups, add expenses, and split costs.' },
    { title: 'Insightful Graphs', desc: 'Track spend patterns with clean visualizations.' }
  ]
  return (
    <div className="container onboarding">
      <h2>Welcome to Zplit</h2>
      <div className="onboarding-grid">
        {slides.map((s, idx) => (
          <div key={idx} className="card neon-glow">
            <h3 className="neon-text">{s.title}</h3>
            <p>{s.desc}</p>
          </div>
        ))}
      </div>
    </div>
  )
}
