import React from 'react'

interface Props {
  label?: string
  onClick?: (e?: any) => void
  disabled?: boolean
  className?: string
}

export default function SplitButton({ label = 'Split', onClick, disabled, className = '' }: Props){
  return (
    <button
      type="button"
      className={`split-button ${className}`}
      onClick={onClick}
      disabled={disabled}
      aria-label={label}
      aria-disabled={disabled}
    >
      <svg width="16" height="16" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" aria-hidden="true" focusable="false">
        <circle cx="7" cy="8" r="1.6" fill="currentColor" />
        <circle cx="12" cy="8" r="1.8" fill="currentColor" />
        <circle cx="17" cy="8" r="1.6" fill="currentColor" />
        <path d="M4 18c0-1.656 1.79-3 4-3h8c2.21 0 4 1.344 4 3v1H4v-1z" fill="currentColor"/>
      </svg>
      <span className="label">{label}</span>
    </button>
  )
}
