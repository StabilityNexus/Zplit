import React, { useState } from 'react';
import api, { setAuthToken } from '../api';
import { useNavigate } from 'react-router-dom';

export default function Login() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const navigate = useNavigate();

  async function doLogin(e: any) {
    e.preventDefault();
    setError('');
    try {
      const res = await api.post('/auth/login', { email, password });
      const { token, role } = res.data;
      localStorage.setItem('token', token);
      localStorage.setItem('role', role);
      setAuthToken(token);
      navigate('/dashboard');
    } catch (err: any) {
      setError(err?.response?.data?.message || 'Login failed');
    }
  }

  return (
    <div className="container">
      <h2>Zplit Login</h2>
      <form onSubmit={doLogin}>
        <div className="input">
          <label>Email</label>
          <input value={email} onChange={e => setEmail(e.target.value)} />
        </div>
        <div className="input">
          <label>Password</label>
          <input type="password" value={password} onChange={e => setPassword(e.target.value)} />
        </div>
        <button type="submit">Login</button>
        {error && <p className="error">{error}</p>}
      </form>
    </div>
  );
}

