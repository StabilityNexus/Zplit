'use client';

import { useState, useEffect, useRef } from 'react';
import { useTheme } from 'next-themes';
import { Sun, Moon } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';

export default function Navbar() {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const [scrolled, setScrolled] = useState(false);
  const mobileMenuRef = useRef<HTMLDivElement>(null);
  const menuButtonRef = useRef<HTMLButtonElement>(null);
  const { setTheme, resolvedTheme } = useTheme();
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    // eslint-disable-next-line react-hooks/set-state-in-effect
    setMounted(true);
  }, []);

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


  const handleLinkClick = (e: React.MouseEvent<HTMLAnchorElement>, href: string) => {
    e.preventDefault();
    setMobileMenuOpen(false);
    const element = document.querySelector(href);
    if (element) {
      const y = element.getBoundingClientRect().top + window.scrollY - 80;
      window.scrollTo({ top: y, behavior: 'smooth' });
    }
  };

  return (
    <motion.nav 
      initial={{ y: -100 }}
      animate={{ y: 0 }}
      transition={{ duration: 0.5 }}
      className={`fixed top-0 z-50 w-full transition-all duration-300 ${scrolled || mobileMenuOpen
      ? 'border-b border-emerald-100/50 bg-white/90 py-3 shadow-lg shadow-emerald-500/5 backdrop-blur-xl dark:border-emerald-900/30 dark:bg-black/90 dark:shadow-emerald-500/10'
      : 'border-b border-transparent bg-white/60 py-4 backdrop-blur-md dark:bg-black/60'
      }`}
    >
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
          <motion.button
            whileHover={{ scale: 1.1, rotate: 180 }}
            transition={{ duration: 0.3 }}
            onClick={() => setTheme(resolvedTheme === 'dark' ? 'light' : 'dark')}
            className="group relative flex h-9 w-9 items-center justify-center rounded-full border border-zinc-200 bg-white/50 text-zinc-600 transition-colors hover:bg-zinc-100 hover:text-emerald-900 dark:border-zinc-700 dark:bg-zinc-900/50 dark:text-zinc-400 dark:hover:bg-zinc-800 dark:hover:text-emerald-400"
            aria-label="Toggle theme"
          >
            {mounted ? (resolvedTheme === 'dark' ? <Sun className="h-4 w-4" /> : <Moon className="h-4 w-4" />) : <span className="h-4 w-4" />}
          </motion.button>
          
          <a
            href="https://github.com/StabilityNexus/Zplit"
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
          <motion.button 
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
            className="group relative hidden overflow-hidden rounded-full bg-gradient-to-r from-emerald-600 to-teal-600 px-5 py-2 text-sm font-semibold text-white shadow-lg shadow-emerald-500/30 transition-all hover:shadow-xl hover:shadow-emerald-500/40 sm:block"
          >
            <span className="absolute inset-0 bg-gradient-to-r from-emerald-700 to-teal-700 opacity-0 transition-opacity group-hover:opacity-100"></span>
            <span className="relative">Download App</span>
          </motion.button>

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
      <AnimatePresence>
      {mobileMenuOpen && (
        <motion.div
          initial={{ height: 0, opacity: 0 }}
          animate={{ height: "auto", opacity: 1 }}
          exit={{ height: 0, opacity: 0 }}
          transition={{ duration: 0.3 }}
          id="mobile-menu"
          ref={mobileMenuRef}
          className="overflow-hidden md:hidden"
        >
          <div className="border-t border-emerald-100 bg-white/95 px-6 py-4 backdrop-blur-xl dark:border-emerald-900/30 dark:bg-black/95">
            <div className="flex flex-col gap-2">
              <a
                href="#features"
                onClick={(e) => handleLinkClick(e, '#features')}
                className="rounded-lg px-4 py-3 text-sm font-medium text-zinc-700 transition-colors hover:bg-emerald-50 hover:text-emerald-900 dark:text-zinc-300 dark:hover:bg-emerald-900/20 dark:hover:text-emerald-400"
              >
                Features
              </a>
              <a
                href="#tech"
                onClick={(e) => handleLinkClick(e, '#tech')}
                className="rounded-lg px-4 py-3 text-sm font-medium text-zinc-700 transition-colors hover:bg-emerald-50 hover:text-emerald-900 dark:text-zinc-300 dark:hover:bg-emerald-900/20 dark:hover:text-emerald-400"
              >
                Technology
              </a>
              <a
                href="#gallery"
                onClick={(e) => handleLinkClick(e, '#gallery')}
                className="rounded-lg px-4 py-3 text-sm font-medium text-zinc-700 transition-colors hover:bg-emerald-50 hover:text-emerald-900 dark:text-zinc-300 dark:hover:bg-emerald-900/20 dark:hover:text-emerald-400"
              >
                Gallery
              </a>
              <a
                href="#faq"
                onClick={(e) => handleLinkClick(e, '#faq')}
                className="rounded-lg px-4 py-3 text-sm font-medium text-zinc-700 transition-colors hover:bg-emerald-50 hover:text-emerald-900 dark:text-zinc-300 dark:hover:bg-emerald-900/20 dark:hover:text-emerald-400"
              >
                FAQ
              </a>
              <div className="mt-2 flex flex-col gap-2">
                <a
                  href="https://github.com/StabilityNexus/Zplit"
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
        </motion.div>
      )}
      </AnimatePresence>
    </motion.nav>
  );
}
