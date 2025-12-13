import React, { createContext, useContext, useEffect, useState } from 'react'

type Theme = 'light' | 'dark'
type Orientation = 'portrait' | 'landscape'

const ThemeContext = createContext({ theme: 'light' as Theme, orientation: 'portrait' as Orientation, setTheme: (t: Theme) => {}, setOrientation: (o: Orientation) => {} })

export function useTheme(){ return useContext(ThemeContext) }

export function ThemeProvider({ children }:{ children: React.ReactNode }){
  const [theme, setTheme] = useState<Theme>('light')
  const [orientation, setOrientation] = useState<Orientation>('portrait')

  useEffect(()=>{
    const root = document.documentElement
    root.setAttribute('data-theme', theme)
    root.setAttribute('data-orientation', orientation)
  },[theme, orientation])

  return <ThemeContext.Provider value={{ theme, orientation, setTheme, setOrientation }}>{children}</ThemeContext.Provider>
}
