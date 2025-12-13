// Minimal theme toggle: cycles between auto, light, dark
(function () {
  const root = document.documentElement;
  const btn = document.getElementById('themeToggle');

  const getStored = () => localStorage.getItem('zplit-theme') || 'auto';
  const setTheme = (mode) => {
    root.setAttribute('data-theme', mode);
    localStorage.setItem('zplit-theme', mode);
    btn.textContent = mode === 'dark' ? '🌙' : mode === 'light' ? '🌞' : '🌗';
  };

  // initialize
  setTheme(getStored());

  btn?.addEventListener('click', () => {
    const current = getStored();
    const next = current === 'auto' ? 'light' : current === 'light' ? 'dark' : 'auto';
    setTheme(next);
  });
})();