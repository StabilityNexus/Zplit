'use client';

import { motion } from 'framer-motion';

export default function Hero() {
  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.1,
        delayChildren: 0.2
      }
    }
  };

  const itemVariants = {
    hidden: { opacity: 0, y: 20 },
    visible: {
      opacity: 1,
      y: 0,
      transition: { duration: 0.5 }
    }
  };

  return (
    <section className="relative overflow-hidden pt-24">
      <div className="absolute inset-0 bg-gradient-to-br from-emerald-50 via-green-50 to-teal-50 dark:from-emerald-950/20 dark:via-green-950/20 dark:to-teal-950/20"></div>
      <div className="relative mx-auto max-w-7xl px-6 py-32">
        <div className="grid items-center gap-12 lg:grid-cols-2">
          <motion.div 
            className="relative z-10"
            variants={containerVariants}
            initial="hidden"
            animate="visible"
          >
            <motion.div variants={itemVariants} className="mb-4 inline-flex items-center gap-2 rounded-full border border-emerald-200 bg-emerald-50 px-4 py-1.5 text-sm font-medium text-emerald-900 dark:border-emerald-800 dark:bg-emerald-900/30 dark:text-emerald-300">
              <span className="relative flex h-2 w-2">
                <span className="absolute inline-flex h-full w-full animate-ping rounded-full bg-emerald-400 opacity-75"></span>
                <span className="relative inline-flex h-2 w-2 rounded-full bg-emerald-500"></span>
              </span>
              Decentralized • Privacy-First • Open Source
            </motion.div>
            <motion.h1 variants={itemVariants} className="mb-6 text-5xl font-bold leading-tight tracking-tight text-zinc-900 dark:text-white sm:text-6xl lg:text-7xl">
              Split Expenses
              <br />
              <span className="bg-gradient-to-r from-emerald-600 to-teal-600 bg-clip-text text-transparent dark:from-emerald-400 dark:to-teal-400">
                Without Servers
              </span>
            </motion.h1>
            <motion.p variants={itemVariants} className="mb-8 text-lg leading-relaxed text-zinc-600 dark:text-zinc-400">
              The first truly decentralized expense-sharing app. No cloud, no servers, no tracking.
              Share expenses via WiFi Direct, Bluetooth, NFC, and QR codes. Your data stays on your device.
            </motion.p>
            <motion.div variants={itemVariants} className="flex flex-wrap gap-4">
              <motion.button 
                whileHover={{ scale: 1.05, translateY: -2 }}
                whileTap={{ scale: 0.95 }}
                className="flex items-center gap-2 rounded-full bg-emerald-900 px-6 py-3 font-semibold text-white shadow-lg transition-all hover:bg-emerald-800 hover:shadow-xl dark:bg-emerald-600 dark:hover:bg-emerald-500"
              >
                <svg className="h-5 w-5" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M17.05 20.28c-.98.95-2.05.8-3.08.35-1.09-.46-2.09-.48-3.24 0-1.44.62-2.2.44-3.06-.35C2.79 15.25 3.51 7.59 9.05 7.31c1.35.07 2.29.74 3.08.8 1.18-.24 2.31-.93 3.57-.84 1.51.12 2.65.72 3.4 1.8-3.12 1.87-2.38 5.98.48 7.13-.57 1.5-1.31 2.99-2.54 4.09l.01-.01zM12.03 7.25c-.15-2.23 1.66-4.07 3.74-4.25.29 2.58-2.34 4.5-3.74 4.25z" />
                </svg>
                Download on iOS
              </motion.button>
              <motion.button 
                whileHover={{ scale: 1.05, translateY: -2 }}
                whileTap={{ scale: 0.95 }}
                className="flex items-center gap-2 rounded-full border-2 border-emerald-900 px-6 py-3 font-semibold text-emerald-900 transition-all hover:bg-emerald-900 hover:text-white dark:border-emerald-600 dark:text-emerald-400 dark:hover:bg-emerald-600 dark:hover:text-white"
              >
                <svg className="h-5 w-5" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M3.609 1.814L13.792 12 3.61 22.186a.996.996 0 0 1-.61-.92V2.734a1 1 0 0 1 .609-.92zm10.89 10.893l2.302 2.302-10.937 6.333 8.635-8.635zm3.199-3.198l2.807 1.626a1 1 0 0 1 0 1.73l-2.808 1.626L15.206 12l2.492-2.491zM5.864 2.658L16.802 8.99l-2.303 2.303-8.635-8.635z" />
                </svg>
                Get on Android
              </motion.button>
            </motion.div>
            <motion.div variants={itemVariants} className="mt-8 flex items-center gap-6 text-sm text-zinc-600 dark:text-zinc-400">
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
            </motion.div>
          </motion.div>
          <motion.div 
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.8, delay: 0.5 }}
            className="relative"
          >
            <div className="absolute -inset-4 rounded-3xl bg-gradient-to-r from-emerald-400 to-teal-400 opacity-20 blur-2xl"></div>
            <div className="relative grid grid-cols-2 gap-4">
              <div className="space-y-4">
                <motion.div 
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: 0.6 }}
                  className="h-64 rounded-2xl bg-gradient-to-br from-emerald-100 to-green-200 p-6 shadow-xl dark:from-emerald-900 dark:to-green-900"
                >
                  <div className="mb-4 flex items-center justify-between">
                    <div className="h-8 w-24 rounded-lg bg-white/40"></div>
                    <div className="h-8 w-8 rounded-full bg-white/40"></div>
                  </div>
                  <div className="space-y-3">
                    <div className="h-16 rounded-xl bg-white/30"></div>
                    <div className="h-16 rounded-xl bg-white/30"></div>
                    <div className="h-16 rounded-xl bg-white/30"></div>
                  </div>
                </motion.div>
                <motion.div 
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: 0.7 }}
                  className="h-48 rounded-2xl bg-gradient-to-br from-teal-100 to-cyan-200 p-6 shadow-xl dark:from-teal-900 dark:to-cyan-900"
                >
                  <div className="mb-4 h-6 w-32 rounded-lg bg-white/40"></div>
                  <div className="space-y-2">
                    <div className="h-12 rounded-lg bg-white/30"></div>
                    <div className="h-12 rounded-lg bg-white/30"></div>
                  </div>
                </motion.div>
              </div>
              <div className="space-y-4 pt-8">
                <motion.div 
                   initial={{ opacity: 0, y: 20 }}
                   animate={{ opacity: 1, y: 0 }}
                   transition={{ delay: 0.8 }}
                   className="h-48 rounded-2xl bg-gradient-to-br from-green-100 to-emerald-200 p-6 shadow-xl dark:from-green-900 dark:to-emerald-900"
                >
                  <div className="mb-4 flex justify-center">
                    <div className="h-24 w-24 rounded-full bg-white/40"></div>
                  </div>
                  <div className="space-y-2">
                    <div className="h-4 rounded bg-white/30"></div>
                    <div className="mx-auto h-4 w-3/4 rounded bg-white/30"></div>
                  </div>
                </motion.div>
                <motion.div 
                   initial={{ opacity: 0, y: 20 }}
                   animate={{ opacity: 1, y: 0 }}
                   transition={{ delay: 0.9 }}
                   className="h-64 rounded-2xl bg-gradient-to-br from-emerald-200 to-teal-300 p-6 shadow-xl dark:from-emerald-900 dark:to-teal-900"
                >
                  <div className="mb-4 h-8 w-28 rounded-lg bg-white/40"></div>
                  <div className="space-y-3">
                    <div className="h-20 rounded-xl bg-white/30"></div>
                    <div className="h-20 rounded-xl bg-white/30"></div>
                    <div className="h-20 rounded-xl bg-white/30"></div>
                  </div>
                </motion.div>
              </div>
            </div>
          </motion.div>
        </div>
      </div>
    </section>
  );
}
