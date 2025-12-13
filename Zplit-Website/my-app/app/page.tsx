'use client';

import { useState, useEffect, useRef } from 'react';

export default function Home() {
  const [activeTab, setActiveTab] = useState('p2p');
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const [scrolled, setScrolled] = useState(false);
  const mobileMenuRef = useRef<HTMLDivElement>(null);
  const menuButtonRef = useRef<HTMLButtonElement>(null);

  useEffect(() => {
    let ticking = false;

    const handleScroll = () => {
      if (!ticking) {
        window.requestAnimationFrame(() => {
          setScrolled(window.scrollY > 20);
          ticking = false;
        });
        ticking = true;
      }
    };

    window.addEventListener('scroll', handleScroll, { passive: true });
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  // Handle mobile menu accessibility
  useEffect(() => {
    if (mobileMenuOpen) {
      // Focus first focusable element when menu opens
      const firstFocusable = mobileMenuRef.current?.querySelector('a, button') as HTMLElement;
      firstFocusable?.focus();

      // Handle Escape key to close menu
      const handleEscape = (e: KeyboardEvent) => {
        if (e.key === 'Escape') {
          setMobileMenuOpen(false);
          menuButtonRef.current?.focus();
        }
      };

      document.addEventListener('keydown', handleEscape);
      return () => document.removeEventListener('keydown', handleEscape);
    } else if (menuButtonRef.current && document.activeElement !== menuButtonRef.current) {
      // Return focus to button when menu closes (if not already focused)
      const wasMenuFocused = mobileMenuRef.current?.contains(document.activeElement);
      if (wasMenuFocused) {
        menuButtonRef.current.focus();
      }
    }
  }, [mobileMenuOpen]);

  return (
    <div className="min-h-screen bg-white dark:bg-black">
      {/* Enhanced Navigation */}
      <nav className={`fixed top-0 z-50 w-full transition-all duration-300 ${scrolled
        ? 'border-b border-emerald-100/50 bg-white/90 py-3 shadow-lg shadow-emerald-500/5 backdrop-blur-xl dark:border-emerald-900/30 dark:bg-black/90 dark:shadow-emerald-500/10'
        : 'border-b border-transparent bg-white/60 py-4 backdrop-blur-md dark:bg-black/60'
        }`}>
        <div className="mx-auto flex max-w-7xl items-center justify-between px-6">
          {/* Logo */}
          <a href="#" className="group flex items-center gap-3">
            <div className="relative">
              <div className="absolute -inset-2 rounded-xl bg-gradient-to-r from-emerald-500 to-teal-500 opacity-0 blur transition-opacity group-hover:opacity-30"></div>
              <div className="relative flex h-10 w-10 items-center justify-center rounded-xl bg-gradient-to-br from-emerald-500 to-teal-600 text-xl font-bold text-white shadow-lg">
                Z
              </div>
            </div>
            <div className="flex items-center gap-2">
              <span className="text-2xl font-bold text-emerald-900 dark:text-emerald-400">Zplit</span>
              <span className="hidden rounded-full bg-gradient-to-r from-emerald-500 to-teal-500 px-2.5 py-0.5 text-xs font-bold text-white shadow-md sm:inline-block">
                Open Source
              </span>
            </div>
          </a>

          {/* Desktop Menu */}
          <div className="hidden items-center gap-1 md:flex">
            <a
              href="#features"
              className="group relative px-4 py-2 text-sm font-medium text-zinc-700 transition-colors hover:text-emerald-900 dark:text-zinc-300 dark:hover:text-emerald-400"
            >
              <span className="relative z-10">Features</span>
              <span className="absolute inset-0 scale-0 rounded-lg bg-emerald-50 transition-transform group-hover:scale-100 dark:bg-emerald-900/20"></span>
            </a>
            <a
              href="#tech"
              className="group relative px-4 py-2 text-sm font-medium text-zinc-700 transition-colors hover:text-emerald-900 dark:text-zinc-300 dark:hover:text-emerald-400"
            >
              <span className="relative z-10">Technology</span>
              <span className="absolute inset-0 scale-0 rounded-lg bg-emerald-50 transition-transform group-hover:scale-100 dark:bg-emerald-900/20"></span>
            </a>
            <a
              href="#gallery"
              className="group relative px-4 py-2 text-sm font-medium text-zinc-700 transition-colors hover:text-emerald-900 dark:text-zinc-300 dark:hover:text-emerald-400"
            >
              <span className="relative z-10">Gallery</span>
              <span className="absolute inset-0 scale-0 rounded-lg bg-emerald-50 transition-transform group-hover:scale-100 dark:bg-emerald-900/20"></span>
            </a>
            <a
              href="#faq"
              className="group relative px-4 py-2 text-sm font-medium text-zinc-700 transition-colors hover:text-emerald-900 dark:text-zinc-300 dark:hover:text-emerald-400"
            >
              <span className="relative z-10">FAQ</span>
              <span className="absolute inset-0 scale-0 rounded-lg bg-emerald-50 transition-transform group-hover:scale-100 dark:bg-emerald-900/20"></span>
            </a>
          </div>

          {/* CTA Buttons */}
          <div className="flex items-center gap-3">
            <a
              href="https://github.com"
              target="_blank"
              rel="noopener noreferrer"
              className="group relative hidden overflow-hidden rounded-full border-2 border-emerald-900 px-5 py-2 text-sm font-semibold text-emerald-900 transition-all hover:scale-105 hover:shadow-lg dark:border-emerald-600 dark:text-emerald-400 sm:block"
            >
              <span className="absolute inset-0 -translate-x-full bg-emerald-900 transition-transform group-hover:translate-x-0 dark:bg-emerald-600"></span>
              <span className="relative flex items-center gap-2 group-hover:text-white">
                <svg className="h-4 w-4" fill="currentColor" viewBox="0 0 24 24">
                  <path fillRule="evenodd" d="M12 2C6.477 2 2 6.484 2 12.017c0 4.425 2.865 8.18 6.839 9.504.5.092.682-.217.682-.483 0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 1.003.07 1.531 1.032 1.531 1.032.892 1.53 2.341 1.088 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 1.026A9.564 9.564 0 0112 6.844c.85.004 1.705.115 2.504.337 1.909-1.296 2.747-1.027 2.747-1.027.546 1.379.202 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.848-2.339 4.695-4.566 4.943.359.309.678.92.678 1.855 0 1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.019 10.019 0 0022 12.017C22 6.484 17.522 2 12 2z" clipRule="evenodd" />
                </svg>
                GitHub
              </span>
            </a>
            <button className="group relative hidden overflow-hidden rounded-full bg-gradient-to-r from-emerald-600 to-teal-600 px-5 py-2 text-sm font-semibold text-white shadow-lg shadow-emerald-500/30 transition-all hover:scale-105 hover:shadow-xl hover:shadow-emerald-500/40 sm:block">
              <span className="absolute inset-0 bg-gradient-to-r from-emerald-700 to-teal-700 opacity-0 transition-opacity group-hover:opacity-100"></span>
              <span className="relative">Download App</span>
            </button>

            {/* Mobile Menu Button */}
            <button
              ref={menuButtonRef}
              onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
              aria-label="Toggle menu"
              aria-expanded={mobileMenuOpen}
              aria-controls="mobile-menu"
              className="relative flex h-10 w-10 items-center justify-center rounded-lg border border-zinc-200 bg-white/50 transition-colors hover:bg-zinc-100 dark:border-zinc-700 dark:bg-zinc-900/50 dark:hover:bg-zinc-800 md:hidden"
            >
              <div className="flex h-5 w-5 flex-col items-center justify-center gap-1">
                <span className={`h-0.5 w-5 bg-zinc-900 transition-all dark:bg-white ${mobileMenuOpen ? 'translate-y-1.5 rotate-45' : ''}`}></span>
                <span className={`h-0.5 w-5 bg-zinc-900 transition-all dark:bg-white ${mobileMenuOpen ? 'opacity-0' : ''}`}></span>
                <span className={`h-0.5 w-5 bg-zinc-900 transition-all dark:bg-white ${mobileMenuOpen ? '-translate-y-1.5 -rotate-45' : ''}`}></span>
              </div>
            </button>
          </div>
        </div>

        {/* Mobile Menu */}
        {mobileMenuOpen && (
          <div
            id="mobile-menu"
            ref={mobileMenuRef}
            className="overflow-hidden transition-all duration-300 md:hidden"
          >
            <div className="border-t border-emerald-100 bg-white/95 px-6 py-4 backdrop-blur-xl dark:border-emerald-900/30 dark:bg-black/95">
              <div className="flex flex-col gap-2">
                <a
                  href="#features"
                  onClick={() => setMobileMenuOpen(false)}
                  className="rounded-lg px-4 py-3 text-sm font-medium text-zinc-700 transition-colors hover:bg-emerald-50 hover:text-emerald-900 dark:text-zinc-300 dark:hover:bg-emerald-900/20 dark:hover:text-emerald-400"
                >
                  Features
                </a>
                <a
                  href="#tech"
                  onClick={() => setMobileMenuOpen(false)}
                  className="rounded-lg px-4 py-3 text-sm font-medium text-zinc-700 transition-colors hover:bg-emerald-50 hover:text-emerald-900 dark:text-zinc-300 dark:hover:bg-emerald-900/20 dark:hover:text-emerald-400"
                >
                  Technology
                </a>
                <a
                  href="#gallery"
                  onClick={() => setMobileMenuOpen(false)}
                  className="rounded-lg px-4 py-3 text-sm font-medium text-zinc-700 transition-colors hover:bg-emerald-50 hover:text-emerald-900 dark:text-zinc-300 dark:hover:bg-emerald-900/20 dark:hover:text-emerald-400"
                >
                  Gallery
                </a>
                <a
                  href="#faq"
                  onClick={() => setMobileMenuOpen(false)}
                  className="rounded-lg px-4 py-3 text-sm font-medium text-zinc-700 transition-colors hover:bg-emerald-50 hover:text-emerald-900 dark:text-zinc-300 dark:hover:bg-emerald-900/20 dark:hover:text-emerald-400"
                >
                  FAQ
                </a>
                <div className="mt-2 flex flex-col gap-2">
                  <a
                    href="https://github.com"
                    target="_blank"
                    rel="noopener noreferrer"
                    className="flex items-center justify-center gap-2 rounded-lg border-2 border-emerald-900 px-4 py-3 text-sm font-semibold text-emerald-900 transition-colors hover:bg-emerald-900 hover:text-white dark:border-emerald-600 dark:text-emerald-400 dark:hover:bg-emerald-600 dark:hover:text-white"
                  >
                    <svg className="h-4 w-4" fill="currentColor" viewBox="0 0 24 24">
                      <path fillRule="evenodd" d="M12 2C6.477 2 2 6.484 2 12.017c0 4.425 2.865 8.18 6.839 9.504.5.092.682-.217.682-.483 0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 1.003.07 1.531 1.032 1.531 1.032.892 1.53 2.341 1.088 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 1.026A9.564 9.564 0 0112 6.844c.85.004 1.705.115 2.504.337 1.909-1.296 2.747-1.027 2.747-1.027.546 1.379.202 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.848-2.339 4.695-4.566 4.943.359.309.678.92.678 1.855 0 1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.019 10.019 0 0022 12.017C22 6.484 17.522 2 12 2z" clipRule="evenodd" />
                    </svg>
                    GitHub
                  </a>
                  <button className="rounded-lg bg-gradient-to-r from-emerald-600 to-teal-600 px-4 py-3 text-sm font-semibold text-white shadow-lg">
                    Download App
                  </button>
                </div>
              </div>
            </div>
          </div>
        )}
      </nav>

      {/* Hero Section */}
      <section className="relative overflow-hidden pt-24">
        <div className="absolute inset-0 bg-gradient-to-br from-emerald-50 via-green-50 to-teal-50 dark:from-emerald-950/20 dark:via-green-950/20 dark:to-teal-950/20"></div>
        <div className="relative mx-auto max-w-7xl px-6 py-32">
          <div className="grid items-center gap-12 lg:grid-cols-2">
            <div className="animate-[fadeInUp_0.8s_ease-out]">
              <div className="mb-4 inline-flex items-center gap-2 rounded-full border border-emerald-200 bg-emerald-50 px-4 py-1.5 text-sm font-medium text-emerald-900 dark:border-emerald-800 dark:bg-emerald-900/30 dark:text-emerald-300">
                <span className="relative flex h-2 w-2">
                  <span className="absolute inline-flex h-full w-full animate-ping rounded-full bg-emerald-400 opacity-75"></span>
                  <span className="relative inline-flex h-2 w-2 rounded-full bg-emerald-500"></span>
                </span>
                Decentralized • Privacy-First • Open Source
              </div>
              <h1 className="mb-6 text-5xl font-bold leading-tight tracking-tight text-zinc-900 dark:text-white sm:text-6xl lg:text-7xl">
                Split Expenses
                <br />
                <span className="bg-gradient-to-r from-emerald-600 to-teal-600 bg-clip-text text-transparent dark:from-emerald-400 dark:to-teal-400">
                  Without Servers
                </span>
              </h1>
              <p className="mb-8 text-lg leading-relaxed text-zinc-600 dark:text-zinc-400">
                The first truly decentralized expense-sharing app. No cloud, no servers, no tracking.
                Share expenses via WiFi Direct, Bluetooth, NFC, and QR codes. Your data stays on your device.
              </p>
              <div className="flex flex-wrap gap-4">
                <button className="flex items-center gap-2 rounded-full bg-emerald-900 px-6 py-3 font-semibold text-white shadow-lg transition-all hover:-translate-y-0.5 hover:bg-emerald-800 hover:shadow-xl dark:bg-emerald-600 dark:hover:bg-emerald-500">
                  <svg className="h-5 w-5" fill="currentColor" viewBox="0 0 24 24">
                    <path d="M17.05 20.28c-.98.95-2.05.8-3.08.35-1.09-.46-2.09-.48-3.24 0-1.44.62-2.2.44-3.06-.35C2.79 15.25 3.51 7.59 9.05 7.31c1.35.07 2.29.74 3.08.8 1.18-.24 2.31-.93 3.57-.84 1.51.12 2.65.72 3.4 1.8-3.12 1.87-2.38 5.98.48 7.13-.57 1.5-1.31 2.99-2.54 4.09l.01-.01zM12.03 7.25c-.15-2.23 1.66-4.07 3.74-4.25.29 2.58-2.34 4.5-3.74 4.25z" />
                  </svg>
                  Download on iOS
                </button>
                <button className="flex items-center gap-2 rounded-full border-2 border-emerald-900 px-6 py-3 font-semibold text-emerald-900 transition-all hover:bg-emerald-900 hover:text-white dark:border-emerald-600 dark:text-emerald-400 dark:hover:bg-emerald-600 dark:hover:text-white">
                  <svg className="h-5 w-5" fill="currentColor" viewBox="0 0 24 24">
                    <path d="M3.609 1.814L13.792 12 3.61 22.186a.996.996 0 0 1-.61-.92V2.734a1 1 0 0 1 .609-.92zm10.89 10.893l2.302 2.302-10.937 6.333 8.635-8.635zm3.199-3.198l2.807 1.626a1 1 0 0 1 0 1.73l-2.808 1.626L15.206 12l2.492-2.491zM5.864 2.658L16.802 8.99l-2.303 2.303-8.635-8.635z" />
                  </svg>
                  Get on Android
                </button>
              </div>
              <div className="mt-8 flex items-center gap-6 text-sm text-zinc-600 dark:text-zinc-400">
                <div className="flex items-center gap-2">
                  <svg className="h-5 w-5 text-emerald-600" fill="currentColor" viewBox="0 0 20 20">
                    <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
                  </svg>
                  100% Open Source
                </div>
                <div className="flex items-center gap-2">
                  <svg className="h-5 w-5 text-emerald-600" fill="currentColor" viewBox="0 0 20 20">
                    <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
                  </svg>
                  Offline-First
                </div>
                <div className="flex items-center gap-2">
                  <svg className="h-5 w-5 text-emerald-600" fill="currentColor" viewBox="0 0 20 20">
                    <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
                  </svg>
                  No Tracking
                </div>
              </div>
            </div>
            <div className="relative">
              <div className="absolute -inset-4 rounded-3xl bg-gradient-to-r from-emerald-400 to-teal-400 opacity-20 blur-2xl"></div>
              <div className="relative grid grid-cols-2 gap-4">
                <div className="space-y-4">
                  <div className="h-64 rounded-2xl bg-gradient-to-br from-emerald-100 to-green-200 p-6 shadow-xl dark:from-emerald-900 dark:to-green-900">
                    <div className="mb-4 flex items-center justify-between">
                      <div className="h-8 w-24 rounded-lg bg-white/40"></div>
                      <div className="h-8 w-8 rounded-full bg-white/40"></div>
                    </div>
                    <div className="space-y-3">
                      <div className="h-16 rounded-xl bg-white/30"></div>
                      <div className="h-16 rounded-xl bg-white/30"></div>
                      <div className="h-16 rounded-xl bg-white/30"></div>
                    </div>
                  </div>
                  <div className="h-48 rounded-2xl bg-gradient-to-br from-teal-100 to-cyan-200 p-6 shadow-xl dark:from-teal-900 dark:to-cyan-900">
                    <div className="mb-4 h-6 w-32 rounded-lg bg-white/40"></div>
                    <div className="space-y-2">
                      <div className="h-12 rounded-lg bg-white/30"></div>
                      <div className="h-12 rounded-lg bg-white/30"></div>
                    </div>
                  </div>
                </div>
                <div className="space-y-4 pt-8">
                  <div className="h-48 rounded-2xl bg-gradient-to-br from-green-100 to-emerald-200 p-6 shadow-xl dark:from-green-900 dark:to-emerald-900">
                    <div className="mb-4 flex justify-center">
                      <div className="h-24 w-24 rounded-full bg-white/40"></div>
                    </div>
                    <div className="space-y-2">
                      <div className="h-4 rounded bg-white/30"></div>
                      <div className="mx-auto h-4 w-3/4 rounded bg-white/30"></div>
                    </div>
                  </div>
                  <div className="h-64 rounded-2xl bg-gradient-to-br from-emerald-200 to-teal-300 p-6 shadow-xl dark:from-emerald-900 dark:to-teal-900">
                    <div className="mb-4 h-8 w-28 rounded-lg bg-white/40"></div>
                    <div className="space-y-3">
                      <div className="h-20 rounded-xl bg-white/30"></div>
                      <div className="h-20 rounded-xl bg-white/30"></div>
                      <div className="h-20 rounded-xl bg-white/30"></div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* P2P Technology Section */}
      <section id="tech" className="bg-zinc-50 px-6 py-24 dark:bg-zinc-950">
        <div className="mx-auto max-w-7xl">
          <div className="mb-16 text-center">
            <h2 className="mb-4 text-4xl font-bold text-zinc-900 dark:text-white">
              Truly Decentralized Architecture
            </h2>
            <p className="mx-auto max-w-2xl text-lg text-zinc-600 dark:text-zinc-400">
              Unlike Splitwise or other apps, Zplit doesn't rely on servers. Your data syncs directly between devices using multiple P2P protocols.
            </p>
          </div>
          <div className="mb-12 flex justify-center">
            <div className="inline-flex rounded-full bg-white p-1 shadow-lg dark:bg-zinc-900">
              <button
                onClick={() => setActiveTab('p2p')}
                className={`rounded-full px-6 py-2 text-sm font-semibold transition-all ${activeTab === 'p2p'
                  ? 'bg-emerald-900 text-white dark:bg-emerald-600'
                  : 'text-zinc-600 hover:text-zinc-900 dark:text-zinc-400 dark:hover:text-white'
                  }`}
              >
                P2P Methods
              </button>
              <button
                onClick={() => setActiveTab('tech')}
                className={`rounded-full px-6 py-2 text-sm font-semibold transition-all ${activeTab === 'tech'
                  ? 'bg-emerald-900 text-white dark:bg-emerald-600'
                  : 'text-zinc-600 hover:text-zinc-900 dark:text-zinc-400 dark:hover:text-white'
                  }`}
              >
                Tech Stack
              </button>
            </div>
          </div>
          {activeTab === 'p2p' ? (
            <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-4">
              <div className="group rounded-2xl border border-emerald-100 bg-white p-6 transition-all hover:border-emerald-300 hover:shadow-xl dark:border-emerald-900/30 dark:bg-zinc-900 dark:hover:border-emerald-700">
                <div className="mb-4 flex h-12 w-12 items-center justify-center rounded-xl bg-emerald-100 text-2xl dark:bg-emerald-900/50">
                  📡
                </div>
                <h3 className="mb-2 text-xl font-bold text-zinc-900 dark:text-white">WiFi Direct</h3>
                <p className="mb-4 text-sm text-zinc-600 dark:text-zinc-400">
                  High-speed sync for large data transfers between nearby devices
                </p>
                <div className="text-xs font-semibold text-emerald-600 dark:text-emerald-400">Fast • Reliable</div>
              </div>
              <div className="group rounded-2xl border border-blue-100 bg-white p-6 transition-all hover:border-blue-300 hover:shadow-xl dark:border-blue-900/30 dark:bg-zinc-900 dark:hover:border-blue-700">
                <div className="mb-4 flex h-12 w-12 items-center justify-center rounded-xl bg-blue-100 text-2xl dark:bg-blue-900/50">
                  🔵
                </div>
                <h3 className="mb-2 text-xl font-bold text-zinc-900 dark:text-white">Bluetooth</h3>
                <p className="mb-4 text-sm text-zinc-600 dark:text-zinc-400">
                  Short-range sync for quick updates and expense sharing
                </p>
                <div className="text-xs font-semibold text-blue-600 dark:text-blue-400">Universal • Low Power</div>
              </div>
              <div className="group rounded-2xl border border-purple-100 bg-white p-6 transition-all hover:border-purple-300 hover:shadow-xl dark:border-purple-900/30 dark:bg-zinc-900 dark:hover:border-purple-700">
                <div className="mb-4 flex h-12 w-12 items-center justify-center rounded-xl bg-purple-100 text-2xl dark:bg-purple-900/50">
                  📲
                </div>
                <h3 className="mb-2 text-xl font-bold text-zinc-900 dark:text-white">NFC</h3>
                <p className="mb-4 text-sm text-zinc-600 dark:text-zinc-400">
                  Tap-to-share group invites or expenses instantly
                </p>
                <div className="text-xs font-semibold text-purple-600 dark:text-purple-400">Instant • Secure</div>
              </div>
              <div className="group rounded-2xl border border-teal-100 bg-white p-6 transition-all hover:border-teal-300 hover:shadow-xl dark:border-teal-900/30 dark:bg-zinc-900 dark:hover:border-teal-700">
                <div className="mb-4 flex h-12 w-12 items-center justify-center rounded-xl bg-teal-100 text-2xl dark:bg-teal-900/50">
                  📱
                </div>
                <h3 className="mb-2 text-xl font-bold text-zinc-900 dark:text-white">QR / Deep Links</h3>
                <p className="mb-4 text-sm text-zinc-600 dark:text-zinc-400">
                  Cross-device sharing via scannable codes and links
                </p>
                <div className="text-xs font-semibold text-teal-600 dark:text-teal-400">Cross-Platform</div>
              </div>
            </div>
          ) : (
            <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
              <div className="rounded-2xl border border-zinc-200 bg-white p-6 dark:border-zinc-800 dark:bg-zinc-900">
                <div className="mb-3 text-sm font-semibold text-emerald-600 dark:text-emerald-400">Frontend</div>
                <div className="space-y-2">
                  <div className="flex items-center gap-2 text-zinc-700 dark:text-zinc-300">
                    <span className="text-lg">⚡</span>
                    <span>Flutter (Android, iOS, Web)</span>
                  </div>
                  <div className="flex items-center gap-2 text-zinc-700 dark:text-zinc-300">
                    <span className="text-lg">🎯</span>
                    <span>Riverpod State Management</span>
                  </div>
                </div>
              </div>
              <div className="rounded-2xl border border-zinc-200 bg-white p-6 dark:border-zinc-800 dark:bg-zinc-900">
                <div className="mb-3 text-sm font-semibold text-blue-600 dark:text-blue-400">Storage</div>
                <div className="space-y-2">
                  <div className="flex items-center gap-2 text-zinc-700 dark:text-zinc-300">
                    <span className="text-lg">💾</span>
                    <span>Hive / Drift (Local DB)</span>
                  </div>
                  <div className="flex items-center gap-2 text-zinc-700 dark:text-zinc-300">
                    <span className="text-lg">🔐</span>
                    <span>Encrypted Storage</span>
                  </div>
                </div>
              </div>
              <div className="rounded-2xl border border-zinc-200 bg-white p-6 dark:border-zinc-800 dark:bg-zinc-900">
                <div className="mb-3 text-sm font-semibold text-purple-600 dark:text-purple-400">AI/ML</div>
                <div className="space-y-2">
                  <div className="flex items-center gap-2 text-zinc-700 dark:text-zinc-300">
                    <span className="text-lg">🤖</span>
                    <span>ML Kit OCR</span>
                  </div>
                  <div className="flex items-center gap-2 text-zinc-700 dark:text-zinc-300">
                    <span className="text-lg">📸</span>
                    <span>TensorFlow Lite</span>
                  </div>
                </div>
              </div>
              <div className="rounded-2xl border border-zinc-200 bg-white p-6 dark:border-zinc-800 dark:bg-zinc-900">
                <div className="mb-3 text-sm font-semibold text-teal-600 dark:text-teal-400">Visualization</div>
                <div className="space-y-2">
                  <div className="flex items-center gap-2 text-zinc-700 dark:text-zinc-300">
                    <span className="text-lg">📊</span>
                    <span>fl_chart Library</span>
                  </div>
                  <div className="flex items-center gap-2 text-zinc-700 dark:text-zinc-300">
                    <span className="text-lg">📈</span>
                    <span>Real-time Analytics</span>
                  </div>
                </div>
              </div>
              <div className="rounded-2xl border border-zinc-200 bg-white p-6 dark:border-zinc-800 dark:bg-zinc-900">
                <div className="mb-3 text-sm font-semibold text-orange-600 dark:text-orange-400">Future: Web3</div>
                <div className="space-y-2">
                  <div className="flex items-center gap-2 text-zinc-700 dark:text-zinc-300">
                    <span className="text-lg">💰</span>
                    <span>USDC/DAI Settlements</span>
                  </div>
                  <div className="flex items-center gap-2 text-zinc-700 dark:text-zinc-300">
                    <span className="text-lg">🔗</span>
                    <span>Smart Contracts</span>
                  </div>
                </div>
              </div>
              <div className="rounded-2xl border border-zinc-200 bg-white p-6 dark:border-zinc-800 dark:bg-zinc-900">
                <div className="mb-3 text-sm font-semibold text-pink-600 dark:text-pink-400">Security</div>
                <div className="space-y-2">
                  <div className="flex items-center gap-2 text-zinc-700 dark:text-zinc-300">
                    <span className="text-lg">🔒</span>
                    <span>E2E Encryption</span>
                  </div>
                  <div className="flex items-center gap-2 text-zinc-700 dark:text-zinc-300">
                    <span className="text-lg">🛡️</span>
                    <span>Zero-Knowledge Sync</span>
                  </div>
                </div>
              </div>
            </div>
          )}
        </div>
      </section>

      {/* Core Features Section */}
      <section id="features" className="bg-white px-6 py-24 dark:bg-black">
        <div className="mx-auto max-w-7xl">
          <div className="mb-16 text-center">
            <h2 className="mb-4 text-4xl font-bold text-zinc-900 dark:text-white">
              Powerful Features, Zero Compromises
            </h2>
            <p className="mx-auto max-w-2xl text-lg text-zinc-600 dark:text-zinc-400">
              Everything you need to manage group expenses, without sacrificing privacy or requiring internet connectivity.
            </p>
          </div>
          <div className="grid gap-8 md:grid-cols-2 lg:grid-cols-3">
            <div className="group rounded-2xl border border-zinc-100 bg-gradient-to-br from-white to-zinc-50 p-8 transition-all hover:border-emerald-200 hover:shadow-2xl dark:border-zinc-800 dark:from-zinc-900 dark:to-zinc-900/50 dark:hover:border-emerald-800">
              <div className="mb-4 text-4xl">👥</div>
              <h3 className="mb-3 text-xl font-bold text-zinc-900 dark:text-white">Group Management</h3>
              <p className="mb-4 text-sm leading-relaxed text-zinc-600 dark:text-zinc-400">
                Create groups for trips, events, or roommates. Invite members via WiFi, Bluetooth, NFC, or QR codes. No accounts required.
              </p>
              <div className="flex flex-wrap gap-2">
                <span className="rounded-full bg-emerald-100 px-3 py-1 text-xs font-medium text-emerald-800 dark:bg-emerald-900/50 dark:text-emerald-300">
                  Multi-device
                </span>
                <span className="rounded-full bg-emerald-100 px-3 py-1 text-xs font-medium text-emerald-800 dark:bg-emerald-900/50 dark:text-emerald-300">
                  P2P Sync
                </span>
              </div>
            </div>
            <div className="group rounded-2xl border border-zinc-100 bg-gradient-to-br from-white to-zinc-50 p-8 transition-all hover:border-blue-200 hover:shadow-2xl dark:border-zinc-800 dark:from-zinc-900 dark:to-zinc-900/50 dark:hover:border-blue-800">
              <div className="mb-4 text-4xl">💰</div>
              <h3 className="mb-3 text-xl font-bold text-zinc-900 dark:text-white">Smart Expense Tracking</h3>
              <p className="mb-4 text-sm leading-relaxed text-zinc-600 dark:text-zinc-400">
                Add expenses with custom splits (equal, percentage, or custom amounts). Filter by date, category, or member. Real-time debt calculation.
              </p>
              <div className="flex flex-wrap gap-2">
                <span className="rounded-full bg-blue-100 px-3 py-1 text-xs font-medium text-blue-800 dark:bg-blue-900/50 dark:text-blue-300">
                  Custom Splits
                </span>
                <span className="rounded-full bg-blue-100 px-3 py-1 text-xs font-medium text-blue-800 dark:bg-blue-900/50 dark:text-blue-300">
                  Auto-Calculate
                </span>
              </div>
            </div>
            <div className="group rounded-2xl border border-zinc-100 bg-gradient-to-br from-white to-zinc-50 p-8 transition-all hover:border-purple-200 hover:shadow-2xl dark:border-zinc-800 dark:from-zinc-900 dark:to-zinc-900/50 dark:hover:border-purple-800">
              <div className="mb-4 text-4xl">📸</div>
              <h3 className="mb-3 text-xl font-bold text-zinc-900 dark:text-white">Receipt OCR</h3>
              <p className="mb-4 text-sm leading-relaxed text-zinc-600 dark:text-zinc-400">
                Snap a photo of any receipt. On-device ML automatically extracts merchant name, amount, and date. No cloud processing.
              </p>
              <div className="flex flex-wrap gap-2">
                <span className="rounded-full bg-purple-100 px-3 py-1 text-xs font-medium text-purple-800 dark:bg-purple-900/50 dark:text-purple-300">
                  ML Kit
                </span>
                <span className="rounded-full bg-purple-100 px-3 py-1 text-xs font-medium text-purple-800 dark:bg-purple-900/50 dark:text-purple-300">
                  On-Device
                </span>
              </div>
            </div>
            <div className="group rounded-2xl border border-zinc-100 bg-gradient-to-br from-white to-zinc-50 p-8 transition-all hover:border-teal-200 hover:shadow-2xl dark:border-zinc-800 dark:from-zinc-900 dark:to-zinc-900/50 dark:hover:border-teal-800">
              <div className="mb-4 text-4xl">📊</div>
              <h3 className="mb-3 text-xl font-bold text-zinc-900 dark:text-white">Visual Analytics</h3>
              <p className="mb-4 text-sm leading-relaxed text-zinc-600 dark:text-zinc-400">
                Beautiful charts and graphs show spending patterns, category breakdowns, and debt balances. Export reports anytime.
              </p>
              <div className="flex flex-wrap gap-2">
                <span className="rounded-full bg-teal-100 px-3 py-1 text-xs font-medium text-teal-800 dark:bg-teal-900/50 dark:text-teal-300">
                  fl_chart
                </span>
                <span className="rounded-full bg-teal-100 px-3 py-1 text-xs font-medium text-teal-800 dark:bg-teal-900/50 dark:text-teal-300">
                  Real-time
                </span>
              </div>
            </div>
            <div className="group rounded-2xl border border-zinc-100 bg-gradient-to-br from-white to-zinc-50 p-8 transition-all hover:border-orange-200 hover:shadow-2xl dark:border-zinc-800 dark:from-zinc-900 dark:to-zinc-900/50 dark:hover:border-orange-800">
              <div className="mb-4 text-4xl">🔒</div>
              <h3 className="mb-3 text-xl font-bold text-zinc-900 dark:text-white">Privacy First</h3>
              <p className="mb-4 text-sm leading-relaxed text-zinc-600 dark:text-zinc-400">
                All data stored locally with encryption. No servers, no tracking, no data collection. You own your financial data completely.
              </p>
              <div className="flex flex-wrap gap-2">
                <span className="rounded-full bg-orange-100 px-3 py-1 text-xs font-medium text-orange-800 dark:bg-orange-900/50 dark:text-orange-300">
                  Encrypted
                </span>
                <span className="rounded-full bg-orange-100 px-3 py-1 text-xs font-medium text-orange-800 dark:bg-orange-900/50 dark:text-orange-300">
                  Local-Only
                </span>
              </div>
            </div>
            <div className="group rounded-2xl border border-zinc-100 bg-gradient-to-br from-white to-zinc-50 p-8 transition-all hover:border-pink-200 hover:shadow-2xl dark:border-zinc-800 dark:from-zinc-900 dark:to-zinc-900/50 dark:hover:border-pink-800">
              <div className="mb-4 text-4xl">⚡</div>
              <h3 className="mb-3 text-xl font-bold text-zinc-900 dark:text-white">Offline-First</h3>
              <p className="mb-4 text-sm leading-relaxed text-zinc-600 dark:text-zinc-400">
                Works perfectly without internet. Sync when devices are nearby. Optional encrypted backups via QR codes or files.
              </p>
              <div className="flex flex-wrap gap-2">
                <span className="rounded-full bg-pink-100 px-3 py-1 text-xs font-medium text-pink-800 dark:bg-pink-900/50 dark:text-pink-300">
                  No Internet
                </span>
                <span className="rounded-full bg-pink-100 px-3 py-1 text-xs font-medium text-pink-800 dark:bg-pink-900/50 dark:text-pink-300">
                  P2P Sync
                </span>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* App Gallery Section */}
      <section id="gallery" className="bg-gradient-to-b from-zinc-50 to-white px-6 py-24 dark:from-zinc-950 dark:to-black">
        <div className="mx-auto max-w-7xl">
          <div className="mb-16 text-center">
            <h2 className="mb-4 text-4xl font-bold text-zinc-900 dark:text-white">
              Experience Zplit
            </h2>
            <p className="mx-auto max-w-2xl text-lg text-zinc-600 dark:text-zinc-400">
              A glimpse into the intuitive interface designed for seamless expense management
            </p>
          </div>
          <div className="grid gap-8 md:grid-cols-2 lg:grid-cols-3">
            {/* Screenshot 1 - Dashboard */}
            <div className="group relative overflow-hidden rounded-3xl bg-gradient-to-br from-emerald-500 to-teal-600 p-1 shadow-2xl transition-all hover:scale-105">
              <div className="h-[600px] overflow-hidden rounded-[22px] bg-white dark:bg-zinc-900">
                <div className="flex h-full flex-col bg-gradient-to-br from-emerald-50 to-green-100 p-6 dark:from-emerald-950 dark:to-green-950">
                  <div className="mb-6 flex items-center justify-between">
                    <div className="text-2xl font-bold text-emerald-900 dark:text-emerald-100">Dashboard</div>
                    <div className="flex gap-2">
                      <div className="h-8 w-8 rounded-full bg-emerald-200 dark:bg-emerald-800"></div>
                    </div>
                  </div>
                  <div className="mb-6 rounded-2xl bg-white/60 p-6 shadow-lg dark:bg-black/20">
                    <div className="mb-2 text-sm text-emerald-700 dark:text-emerald-300">Total Balance</div>
                    <div className="text-3xl font-bold text-emerald-900 dark:text-emerald-100">$1,234.56</div>
                  </div>
                  <div className="space-y-3">
                    <div className="flex items-center justify-between rounded-xl bg-white/60 p-4 shadow dark:bg-black/20">
                      <div className="flex items-center gap-3">
                        <div className="h-10 w-10 rounded-full bg-emerald-300 dark:bg-emerald-700"></div>
                        <div>
                          <div className="font-semibold text-zinc-900 dark:text-white">Trip to Goa</div>
                          <div className="text-xs text-zinc-600 dark:text-zinc-400">5 members</div>
                        </div>
                      </div>
                      <div className="text-right">
                        <div className="font-bold text-emerald-900 dark:text-emerald-100">$450</div>
                        <div className="text-xs text-zinc-600 dark:text-zinc-400">You owe</div>
                      </div>
                    </div>
                    <div className="flex items-center justify-between rounded-xl bg-white/60 p-4 shadow dark:bg-black/20">
                      <div className="flex items-center gap-3">
                        <div className="h-10 w-10 rounded-full bg-teal-300 dark:bg-teal-700"></div>
                        <div>
                          <div className="font-semibold text-zinc-900 dark:text-white">Roommates</div>
                          <div className="text-xs text-zinc-600 dark:text-zinc-400">3 members</div>
                        </div>
                      </div>
                      <div className="text-right">
                        <div className="font-bold text-teal-900 dark:text-teal-100">$120</div>
                        <div className="text-xs text-zinc-600 dark:text-zinc-400">Owed to you</div>
                      </div>
                    </div>
                    <div className="flex items-center justify-between rounded-xl bg-white/60 p-4 shadow dark:bg-black/20">
                      <div className="flex items-center gap-3">
                        <div className="h-10 w-10 rounded-full bg-green-300 dark:bg-green-700"></div>
                        <div>
                          <div className="font-semibold text-zinc-900 dark:text-white">Office Lunch</div>
                          <div className="text-xs text-zinc-600 dark:text-zinc-400">8 members</div>
                        </div>
                      </div>
                      <div className="text-right">
                        <div className="font-bold text-green-900 dark:text-green-100">$85</div>
                        <div className="text-xs text-zinc-600 dark:text-zinc-400">Settled</div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            {/* Screenshot 2 - Add Expense */}
            <div className="group relative overflow-hidden rounded-3xl bg-gradient-to-br from-blue-500 to-indigo-600 p-1 shadow-2xl transition-all hover:scale-105">
              <div className="h-[600px] overflow-hidden rounded-[22px] bg-white dark:bg-zinc-900">
                <div className="flex h-full flex-col bg-gradient-to-br from-blue-50 to-indigo-100 p-6 dark:from-blue-950 dark:to-indigo-950">
                  <div className="mb-6 flex items-center justify-between">
                    <div className="text-2xl font-bold text-blue-900 dark:text-blue-100">Add Expense</div>
                    <button className="rounded-full bg-blue-600 px-4 py-2 text-sm font-semibold text-white">Save</button>
                  </div>
                  <div className="space-y-4">
                    <div>
                      <div className="mb-2 text-sm font-medium text-blue-800 dark:text-blue-200">Amount</div>
                      <div className="rounded-xl bg-white/60 p-4 text-3xl font-bold text-blue-900 shadow dark:bg-black/20 dark:text-blue-100">
                        $250.00
                      </div>
                    </div>
                    <div>
                      <div className="mb-2 text-sm font-medium text-blue-800 dark:text-blue-200">Description</div>
                      <div className="rounded-xl bg-white/60 p-4 shadow dark:bg-black/20">
                        <div className="text-zinc-900 dark:text-white">Dinner at Restaurant</div>
                      </div>
                    </div>
                    <div>
                      <div className="mb-2 text-sm font-medium text-blue-800 dark:text-blue-200">Split Method</div>
                      <div className="flex gap-2">
                        <div className="flex-1 rounded-xl bg-blue-600 p-3 text-center text-sm font-semibold text-white shadow">
                          Equal
                        </div>
                        <div className="flex-1 rounded-xl bg-white/60 p-3 text-center text-sm font-semibold text-blue-900 shadow dark:bg-black/20 dark:text-blue-100">
                          Custom
                        </div>
                        <div className="flex-1 rounded-xl bg-white/60 p-3 text-center text-sm font-semibold text-blue-900 shadow dark:bg-black/20 dark:text-blue-100">
                          %
                        </div>
                      </div>
                    </div>
                    <div>
                      <div className="mb-2 text-sm font-medium text-blue-800 dark:text-blue-200">Participants (4)</div>
                      <div className="space-y-2">
                        <div className="flex items-center gap-3 rounded-xl bg-white/60 p-3 shadow dark:bg-black/20">
                          <div className="h-8 w-8 rounded-full bg-blue-300 dark:bg-blue-700"></div>
                          <div className="flex-1 text-sm font-medium text-zinc-900 dark:text-white">You</div>
                          <div className="text-sm font-bold text-blue-900 dark:text-blue-100">$62.50</div>
                        </div>
                        <div className="flex items-center gap-3 rounded-xl bg-white/60 p-3 shadow dark:bg-black/20">
                          <div className="h-8 w-8 rounded-full bg-indigo-300 dark:bg-indigo-700"></div>
                          <div className="flex-1 text-sm font-medium text-zinc-900 dark:text-white">Alice</div>
                          <div className="text-sm font-bold text-blue-900 dark:text-blue-100">$62.50</div>
                        </div>
                        <div className="flex items-center gap-3 rounded-xl bg-white/60 p-3 shadow dark:bg-black/20">
                          <div className="h-8 w-8 rounded-full bg-purple-300 dark:bg-purple-700"></div>
                          <div className="flex-1 text-sm font-medium text-zinc-900 dark:text-white">Bob</div>
                          <div className="text-sm font-bold text-blue-900 dark:text-blue-100">$62.50</div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            {/* Screenshot 3 - Analytics */}
            <div className="group relative overflow-hidden rounded-3xl bg-gradient-to-br from-purple-500 to-pink-600 p-1 shadow-2xl transition-all hover:scale-105">
              <div className="h-[600px] overflow-hidden rounded-[22px] bg-white dark:bg-zinc-900">
                <div className="flex h-full flex-col bg-gradient-to-br from-purple-50 to-pink-100 p-6 dark:from-purple-950 dark:to-pink-950">
                  <div className="mb-6">
                    <div className="text-2xl font-bold text-purple-900 dark:text-purple-100">Analytics</div>
                    <div className="text-sm text-purple-700 dark:text-purple-300">Last 30 days</div>
                  </div>
                  <div className="mb-6 rounded-2xl bg-white/60 p-4 shadow-lg dark:bg-black/20">
                    <div className="mb-4 flex justify-between">
                      <div>
                        <div className="text-xs text-purple-700 dark:text-purple-300">Total Spent</div>
                        <div className="text-2xl font-bold text-purple-900 dark:text-purple-100">$2,450</div>
                      </div>
                      <div className="text-right">
                        <div className="text-xs text-purple-700 dark:text-purple-300">Avg/Day</div>
                        <div className="text-2xl font-bold text-purple-900 dark:text-purple-100">$81.67</div>
                      </div>
                    </div>
                    <div className="flex h-32 items-end justify-between gap-1">
                      <div className="w-full rounded-t bg-purple-300 dark:bg-purple-700" style={{ height: '60%' }}></div>
                      <div className="w-full rounded-t bg-purple-300 dark:bg-purple-700" style={{ height: '80%' }}></div>
                      <div className="w-full rounded-t bg-purple-300 dark:bg-purple-700" style={{ height: '45%' }}></div>
                      <div className="w-full rounded-t bg-purple-300 dark:bg-purple-700" style={{ height: '90%' }}></div>
                      <div className="w-full rounded-t bg-purple-300 dark:bg-purple-700" style={{ height: '70%' }}></div>
                      <div className="w-full rounded-t bg-purple-300 dark:bg-purple-700" style={{ height: '55%' }}></div>
                      <div className="w-full rounded-t bg-purple-600 dark:bg-purple-500" style={{ height: '100%' }}></div>
                    </div>
                  </div>
                  <div className="space-y-3">
                    <div className="text-sm font-semibold text-purple-800 dark:text-purple-200">Top Categories</div>
                    <div className="flex items-center gap-3 rounded-xl bg-white/60 p-3 shadow dark:bg-black/20">
                      <div className="text-2xl">🍔</div>
                      <div className="flex-1">
                        <div className="text-sm font-medium text-zinc-900 dark:text-white">Food & Dining</div>
                        <div className="h-2 w-full rounded-full bg-purple-200 dark:bg-purple-800">
                          <div className="h-2 w-3/4 rounded-full bg-purple-600"></div>
                        </div>
                      </div>
                      <div className="text-sm font-bold text-purple-900 dark:text-purple-100">$890</div>
                    </div>
                    <div className="flex items-center gap-3 rounded-xl bg-white/60 p-3 shadow dark:bg-black/20">
                      <div className="text-2xl">🚗</div>
                      <div className="flex-1">
                        <div className="text-sm font-medium text-zinc-900 dark:text-white">Transport</div>
                        <div className="h-2 w-full rounded-full bg-pink-200 dark:bg-pink-800">
                          <div className="h-2 w-1/2 rounded-full bg-pink-600"></div>
                        </div>
                      </div>
                      <div className="text-sm font-bold text-purple-900 dark:text-purple-100">$560</div>
                    </div>
                    <div className="flex items-center gap-3 rounded-xl bg-white/60 p-3 shadow dark:bg-black/20">
                      <div className="text-2xl">🎬</div>
                      <div className="flex-1">
                        <div className="text-sm font-medium text-zinc-900 dark:text-white">Entertainment</div>
                        <div className="h-2 w-full rounded-full bg-purple-200 dark:bg-purple-800">
                          <div className="h-2 w-1/3 rounded-full bg-purple-600"></div>
                        </div>
                      </div>
                      <div className="text-sm font-bold text-purple-900 dark:text-purple-100">$340</div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Open Source CTA Section */}
      <section className="bg-gradient-to-br from-emerald-900 to-teal-900 px-6 py-24 dark:from-emerald-950 dark:to-teal-950">
        <div className="mx-auto max-w-4xl text-center">
          <div className="mb-6 inline-flex items-center gap-2 rounded-full border border-emerald-400/30 bg-emerald-800/30 px-4 py-2 text-sm font-medium text-emerald-200">
            <svg className="h-5 w-5" fill="currentColor" viewBox="0 0 24 24">
              <path fillRule="evenodd" d="M12 2C6.477 2 2 6.484 2 12.017c0 4.425 2.865 8.18 6.839 9.504.5.092.682-.217.682-.483 0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 1.003.07 1.531 1.032 1.531 1.032.892 1.53 2.341 1.088 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 1.026A9.564 9.564 0 0112 6.844c.85.004 1.705.115 2.504.337 1.909-1.296 2.747-1.027 2.747-1.027.546 1.379.202 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.848-2.339 4.695-4.566 4.943.359.309.678.92.678 1.855 0 1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.019 10.019 0 0022 12.017C22 6.484 17.522 2 12 2z" clipRule="evenodd" />
            </svg>
            100% Open Source
          </div>
          <h2 className="mb-6 text-4xl font-bold text-white sm:text-5xl">
            Built in Public, For Everyone
          </h2>
          <p className="mb-8 text-lg text-emerald-100">
            Zplit is completely open source. Contribute, fork, or self-host. No vendor lock-in, no hidden code, no surprises.
          </p>
          <div className="flex flex-wrap justify-center gap-4">
            <a
              href="https://github.com"
              target="_blank"
              rel="noopener noreferrer"
              className="flex items-center gap-2 rounded-full bg-white px-6 py-3 font-semibold text-emerald-900 shadow-lg transition-all hover:-translate-y-0.5 hover:shadow-xl"
            >
              <svg className="h-5 w-5" fill="currentColor" viewBox="0 0 24 24">
                <path fillRule="evenodd" d="M12 2C6.477 2 2 6.484 2 12.017c0 4.425 2.865 8.18 6.839 9.504.5.092.682-.217.682-.483 0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 1.003.07 1.531 1.032 1.531 1.032.892 1.53 2.341 1.088 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 1.026A9.564 9.564 0 0112 6.844c.85.004 1.705.115 2.504.337 1.909-1.296 2.747-1.027 2.747-1.027.546 1.379.202 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.848-2.339 4.695-4.566 4.943.359.309.678.92.678 1.855 0 1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.019 10.019 0 0022 12.017C22 6.484 17.522 2 12 2z" clipRule="evenodd" />
              </svg>
              View on GitHub
            </a>
            <a
              href="https://github.com"
              target="_blank"
              rel="noopener noreferrer"
              className="flex items-center gap-2 rounded-full border-2 border-white px-6 py-3 font-semibold text-white transition-all hover:bg-white hover:text-emerald-900"
            >
              ⭐ Star the Project
            </a>
          </div>
          <div className="mt-12 grid gap-6 text-left sm:grid-cols-3">
            <div className="rounded-2xl border border-emerald-400/20 bg-emerald-800/20 p-6 backdrop-blur">
              <div className="mb-2 text-3xl font-bold text-white">MIT</div>
              <div className="text-sm text-emerald-200">Licensed for commercial and personal use</div>
            </div>
            <div className="rounded-2xl border border-emerald-400/20 bg-emerald-800/20 p-6 backdrop-blur">
              <div className="mb-2 text-3xl font-bold text-white">Flutter</div>
              <div className="text-sm text-emerald-200">Cross-platform with native performance</div>
            </div>
            <div className="rounded-2xl border border-emerald-400/20 bg-emerald-800/20 p-6 backdrop-blur">
              <div className="mb-2 text-3xl font-bold text-white">Self-Host</div>
              <div className="text-sm text-emerald-200">Deploy your own sync server (optional)</div>
            </div>
          </div>
        </div>
      </section>

      {/* FAQ Section */}
      <section id="faq" className="bg-white px-6 py-24 dark:bg-black">
        <div className="mx-auto max-w-4xl">
          <div className="mb-16 text-center">
            <h2 className="mb-4 text-4xl font-bold text-zinc-900 dark:text-white">
              Frequently Asked Questions
            </h2>
            <p className="text-lg text-zinc-600 dark:text-zinc-400">
              Everything you need to know about Zplit
            </p>
          </div>
          <div className="space-y-6">
            <div className="rounded-2xl border border-zinc-200 bg-zinc-50 p-6 dark:border-zinc-800 dark:bg-zinc-900">
              <h3 className="mb-3 text-lg font-bold text-zinc-900 dark:text-white">
                How does Zplit work without servers?
              </h3>
              <p className="text-zinc-600 dark:text-zinc-400">
                Zplit uses peer-to-peer technologies like WiFi Direct, Bluetooth, and NFC to sync data directly between devices. All your expense data is stored locally on your device with encryption. When you're near friends, devices automatically sync changes.
              </p>
            </div>
            <div className="rounded-2xl border border-zinc-200 bg-zinc-50 p-6 dark:border-zinc-800 dark:bg-zinc-900">
              <h3 className="mb-3 text-lg font-bold text-zinc-900 dark:text-white">
                What if I'm not near my friends?
              </h3>
              <p className="text-zinc-600 dark:text-zinc-400">
                You can share expenses via QR codes or deep links that work over any messaging app. The data syncs when you scan the code or click the link. You can also export encrypted backups and share them manually.
              </p>
            </div>
            <div className="rounded-2xl border border-zinc-200 bg-zinc-50 p-6 dark:border-zinc-800 dark:bg-zinc-900">
              <h3 className="mb-3 text-lg font-bold text-zinc-900 dark:text-white">
                Is my financial data secure?
              </h3>
              <p className="text-zinc-600 dark:text-zinc-400">
                Absolutely. All data is encrypted and stored only on your device. We don't have servers, so there's nothing to hack. P2P transfers use end-to-end encryption. You have complete control over your data.
              </p>
            </div>
            <div className="rounded-2xl border border-zinc-200 bg-zinc-50 p-6 dark:border-zinc-800 dark:bg-zinc-900">
              <h3 className="mb-3 text-lg font-bold text-zinc-900 dark:text-white">
                Can I use Zplit for cryptocurrency settlements?
              </h3>
              <p className="text-zinc-600 dark:text-zinc-400">
                We're building Web3 integration for future releases. You'll be able to settle debts using USDC, DAI, or other stablecoins via smart contracts. Traditional payment methods will always be supported too.
              </p>
            </div>
            <div className="rounded-2xl border border-zinc-200 bg-zinc-50 p-6 dark:border-zinc-800 dark:bg-zinc-900">
              <h3 className="mb-3 text-lg font-bold text-zinc-900 dark:text-white">
                Is Zplit really free and open source?
              </h3>
              <p className="text-zinc-600 dark:text-zinc-400">
                Yes! Zplit is MIT licensed and completely free. No ads, no premium tiers, no hidden costs. The entire codebase is on GitHub. You can fork it, modify it, or self-host your own version.
              </p>
            </div>
            <div className="rounded-2xl border border-zinc-200 bg-zinc-50 p-6 dark:border-zinc-800 dark:bg-zinc-900">
              <h3 className="mb-3 text-lg font-bold text-zinc-900 dark:text-white">
                When will Zplit be available?
              </h3>
              <p className="text-zinc-600 dark:text-zinc-400">
                We're currently in active development. Follow us on GitHub to track progress. Beta testing will begin soon for early adopters. Star the repo to get notified when we launch!
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Final CTA Section */}
      <section className="bg-gradient-to-br from-emerald-50 via-green-50 to-teal-50 px-6 py-24 dark:from-emerald-950/20 dark:via-green-950/20 dark:to-teal-950/20">
        <div className="mx-auto max-w-4xl text-center">
          <h2 className="mb-6 text-4xl font-bold text-zinc-900 dark:text-white sm:text-5xl">
            Ready to Split Smarter?
          </h2>
          <p className="mb-8 text-lg text-zinc-600 dark:text-zinc-400">
            Join the waitlist and be among the first to experience truly decentralized expense sharing.
          </p>
          <form
            onSubmit={(e) => {
              e.preventDefault();
              // TODO: Implement waitlist submission
              alert('Waitlist feature coming soon! Follow us on GitHub for updates.');
            }}
            className="mb-8 flex flex-col items-center gap-4 sm:flex-row sm:justify-center"
          >
            <label htmlFor="waitlist-email" className="sr-only">
              Email address for waitlist
            </label>
            <input
              id="waitlist-email"
              type="email"
              placeholder="Enter your email"
              required
              aria-label="Email address for waitlist"
              className="w-full rounded-full border-2 border-emerald-200 bg-white px-6 py-3 text-zinc-900 placeholder-zinc-400 focus:border-emerald-500 focus:outline-none dark:border-emerald-800 dark:bg-zinc-900 dark:text-white sm:w-80"
            />
            <button
              type="submit"
              className="w-full rounded-full bg-emerald-900 px-8 py-3 font-semibold text-white shadow-lg transition-all hover:-translate-y-0.5 hover:bg-emerald-800 hover:shadow-xl dark:bg-emerald-600 dark:hover:bg-emerald-500 sm:w-auto"
            >
              Join Waitlist
            </button>
          </form>
          <p className="text-sm text-zinc-500 dark:text-zinc-500">
            No spam. We'll only notify you when Zplit launches. Unsubscribe anytime.
          </p>
        </div>
      </section>

      {/* Footer */}
      <footer className="border-t border-zinc-200 bg-white px-6 py-12 dark:border-zinc-800 dark:bg-black">
        <div className="mx-auto max-w-7xl">
          <div className="grid gap-8 md:grid-cols-4">
            <div>
              <div className="mb-4 text-2xl font-bold text-emerald-900 dark:text-emerald-400">Zplit</div>
              <p className="text-sm text-zinc-600 dark:text-zinc-400">
                Decentralized expense sharing for the privacy-conscious.
              </p>
            </div>
            <div>
              <div className="mb-4 text-sm font-semibold text-zinc-900 dark:text-white">Product</div>
              <ul className="space-y-2 text-sm text-zinc-600 dark:text-zinc-400">
                <li><a href="#features" className="hover:text-emerald-600 dark:hover:text-emerald-400">Features</a></li>
                <li><a href="#tech" className="hover:text-emerald-600 dark:hover:text-emerald-400">Technology</a></li>
                <li><a href="#gallery" className="hover:text-emerald-600 dark:hover:text-emerald-400">Gallery</a></li>
                <li><a href="https://github.com" className="hover:text-emerald-600 dark:hover:text-emerald-400">Roadmap</a></li>
              </ul>
            </div>
            <div>
              <div className="mb-4 text-sm font-semibold text-zinc-900 dark:text-white">Developers</div>
              <ul className="space-y-2 text-sm text-zinc-600 dark:text-zinc-400">
                <li><a href="https://github.com" className="hover:text-emerald-600 dark:hover:text-emerald-400">GitHub</a></li>
                <li><a href="https://github.com" className="hover:text-emerald-600 dark:hover:text-emerald-400">Documentation</a></li>
                <li><a href="https://github.com" className="hover:text-emerald-600 dark:hover:text-emerald-400">API Reference</a></li>
                <li><a href="https://github.com" className="hover:text-emerald-600 dark:hover:text-emerald-400">Contributing</a></li>
              </ul>
            </div>
            <div>
              <div className="mb-4 text-sm font-semibold text-zinc-900 dark:text-white">Community</div>
              <ul className="space-y-2 text-sm text-zinc-600 dark:text-zinc-400">
                <li><a href="https://twitter.com" className="hover:text-emerald-600 dark:hover:text-emerald-400">Twitter</a></li>
                <li><a href="https://discord.com" className="hover:text-emerald-600 dark:hover:text-emerald-400">Discord</a></li>
                <li><a href="https://reddit.com" className="hover:text-emerald-600 dark:hover:text-emerald-400">Reddit</a></li>
                <li><a href="mailto:hello@zplit.app" className="hover:text-emerald-600 dark:hover:text-emerald-400">Contact</a></li>
              </ul>
            </div>
          </div>
          <div className="mt-12 border-t border-zinc-200 pt-8 text-center dark:border-zinc-800">
            <p className="text-sm text-zinc-600 dark:text-zinc-400">
              © 2025 Zplit. Open source under MIT License. Built with ❤️ for privacy.
            </p>
          </div>
        </div>
      </footer>
    </div>
  );
}
