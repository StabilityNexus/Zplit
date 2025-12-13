import React from 'react'
import { Link } from 'react-router-dom'
import { useTheme } from '../theme'

export default function NavBar(){
  const { theme, orientation, setTheme, setOrientation } = useTheme()

  return (
    <nav className="navbar">
      <div className="navbar-container">
        <div className="navbar-brand">Zplit</div>
        <div className="navbar-links">
          <Link to="/dashboard">Dashboard</Link>
          <Link to="/onboarding">Onboarding</Link>
          <Link to="/account">Account</Link>
          <Link to="/groups">Groups</Link>
          <Link to="/invite">Invite</Link>
          <Link to="/expenses/add">Expenses</Link>
          <Link to="/graphs">Graphs</Link>
        </div>
        <div className="navbar-controls">
          <div className="control-group">
            <span className="control-label">Theme</span>
            <button 
              className="toggle-btn"
              onClick={() => setTheme(theme === 'light' ? 'dark' : 'light')}
              title={`Switch to ${theme === 'light' ? 'dark' : 'light'} mode`}
              aria-label={`Switch to ${theme === 'light' ? 'dark' : 'light'} mode`}
            >
              {theme === 'light' ? '☀️' : '🌙'}
            </button>
          </div>
          <div className="control-group">
            <span className="control-label">Layout</span>
            <button 
              className="toggle-btn"
              onClick={() => setOrientation(orientation === 'portrait' ? 'landscape' : 'portrait')}
              title={`Switch to ${orientation === 'portrait' ? 'landscape' : 'portrait'} layout`}
              aria-label={`Switch to ${orientation === 'portrait' ? 'landscape' : 'portrait'} layout`}
            >
              {orientation === 'portrait' ? '📱' : '🖥️'}
            </button>
          </div>
        </div>
      </div>
    </nav>
  )
}
