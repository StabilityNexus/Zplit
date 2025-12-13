import React from 'react'
import { createRoot } from 'react-dom/client'
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'
import Login from './pages/Login'
import Dashboard from './pages/Dashboard'
import DeepLinkAdmin from './pages/DeepLinkAdmin'
import Onboarding from './pages/Onboarding'
import AccountSetup from './pages/AccountSetup'
import Groups from './pages/Groups'
import InviteUsers from './pages/InviteUsers'
import AddExpenses from './pages/AddExpenses'
import Graphs from './pages/Graphs'
import { ThemeProvider } from './theme'
import NavBar from './components/NavBar'
import './styles.css'

function App() {
  return (
    <ThemeProvider>
      <BrowserRouter>
        <NavBar />
        <Routes>
          <Route path="/onboarding" element={<Onboarding />} />
          <Route path="/account" element={<AccountSetup />} />
          <Route path="/groups" element={<Groups />} />
          <Route path="/invite" element={<InviteUsers />} />
          <Route path="/expenses/add" element={<AddExpenses />} />
          <Route path="/graphs" element={<Graphs />} />
          <Route path="/login" element={<Login />} />
          <Route path="/dashboard" element={<Dashboard />} />
          <Route path="/deep-links" element={<DeepLinkAdmin />} />
          <Route path="/" element={<Navigate to="/dashboard" />} />
        </Routes>
      </BrowserRouter>
    </ThemeProvider>
  )
}

createRoot(document.getElementById('root')!).render(<App />)
