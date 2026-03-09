'use client';

import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';

export default function P2PMethods() {
  const [activeTab, setActiveTab] = useState('p2p');

  return (
    <section id="tech" className="bg-zinc-50 px-6 py-24 dark:bg-zinc-950">
      <div className="mx-auto max-w-7xl">
        <motion.div 
           initial={{ opacity: 0, y: 20 }}
           whileInView={{ opacity: 1, y: 0 }}
           viewport={{ once: true }}
           transition={{ duration: 0.6 }}
           className="mb-16 text-center"
        >
          <h2 className="mb-4 text-4xl font-bold text-zinc-900 dark:text-white">
            Truly Decentralized Architecture
          </h2>
          <p className="mx-auto max-w-2xl text-lg text-zinc-600 dark:text-zinc-400">
            Unlike Splitwise or other apps, Zplit doesn&apos;t rely on servers. Your data syncs directly between devices using multiple P2P protocols.
          </p>
        </motion.div>
        
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

        <AnimatePresence mode="wait">
        {activeTab === 'p2p' ? (
          <motion.div 
            key="p2p"
            initial={{ opacity: 0, scale: 0.95 }}
            animate={{ opacity: 1, scale: 1 }}
            exit={{ opacity: 0, scale: 0.95 }}
            transition={{ duration: 0.3 }}
            className="grid gap-6 md:grid-cols-2 lg:grid-cols-4"
          >
            <motion.div whileHover={{ y: -5 }} className="group rounded-2xl border border-emerald-100 bg-white p-6 transition-all hover:border-emerald-300 hover:shadow-xl dark:border-emerald-900/30 dark:bg-zinc-900 dark:hover:border-emerald-700">
              <div className="mb-4 flex h-12 w-12 items-center justify-center rounded-xl bg-emerald-100 text-2xl dark:bg-emerald-900/50">
                📡
              </div>
              <h3 className="mb-2 text-xl font-bold text-zinc-900 dark:text-white">WiFi Direct</h3>
              <p className="mb-4 text-sm text-zinc-600 dark:text-zinc-400">
                High-speed sync for large data transfers between nearby devices
              </p>
              <div className="text-xs font-semibold text-emerald-600 dark:text-emerald-400">Fast • Reliable</div>
            </motion.div>
            <motion.div whileHover={{ y: -5 }} className="group rounded-2xl border border-blue-100 bg-white p-6 transition-all hover:border-blue-300 hover:shadow-xl dark:border-blue-900/30 dark:bg-zinc-900 dark:hover:border-blue-700">
              <div className="mb-4 flex h-12 w-12 items-center justify-center rounded-xl bg-blue-100 text-2xl dark:bg-blue-900/50">
                🔵
              </div>
              <h3 className="mb-2 text-xl font-bold text-zinc-900 dark:text-white">Bluetooth</h3>
              <p className="mb-4 text-sm text-zinc-600 dark:text-zinc-400">
                Short-range sync for quick updates and expense sharing
              </p>
              <div className="text-xs font-semibold text-blue-600 dark:text-blue-400">Universal • Low Power</div>
            </motion.div>
            <motion.div whileHover={{ y: -5 }} className="group rounded-2xl border border-purple-100 bg-white p-6 transition-all hover:border-purple-300 hover:shadow-xl dark:border-purple-900/30 dark:bg-zinc-900 dark:hover:border-purple-700">
              <div className="mb-4 flex h-12 w-12 items-center justify-center rounded-xl bg-purple-100 text-2xl dark:bg-purple-900/50">
                📲
              </div>
              <h3 className="mb-2 text-xl font-bold text-zinc-900 dark:text-white">NFC</h3>
              <p className="mb-4 text-sm text-zinc-600 dark:text-zinc-400">
                Tap-to-share group invites or expenses instantly
              </p>
              <div className="text-xs font-semibold text-purple-600 dark:text-purple-400">Instant • Secure</div>
            </motion.div>
            <motion.div whileHover={{ y: -5 }} className="group rounded-2xl border border-teal-100 bg-white p-6 transition-all hover:border-teal-300 hover:shadow-xl dark:border-teal-900/30 dark:bg-zinc-900 dark:hover:border-teal-700">
              <div className="mb-4 flex h-12 w-12 items-center justify-center rounded-xl bg-teal-100 text-2xl dark:bg-teal-900/50">
                📱
              </div>
              <h3 className="mb-2 text-xl font-bold text-zinc-900 dark:text-white">QR / Deep Links</h3>
              <p className="mb-4 text-sm text-zinc-600 dark:text-zinc-400">
                Cross-device sharing via scannable codes and links
              </p>
              <div className="text-xs font-semibold text-teal-600 dark:text-teal-400">Cross-Platform</div>
            </motion.div>
          </motion.div>
        ) : (
          <motion.div 
            key="tech"
            initial={{ opacity: 0, scale: 0.95 }}
            animate={{ opacity: 1, scale: 1 }}
            exit={{ opacity: 0, scale: 0.95 }}
            transition={{ duration: 0.3 }}
            className="grid gap-6 md:grid-cols-2 lg:grid-cols-3"
          >
            <motion.div whileHover={{ scale: 1.02 }} className="rounded-2xl border border-zinc-200 bg-white p-6 dark:border-zinc-800 dark:bg-zinc-900">
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
            </motion.div>
            <motion.div whileHover={{ scale: 1.02 }} className="rounded-2xl border border-zinc-200 bg-white p-6 dark:border-zinc-800 dark:bg-zinc-900">
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
            </motion.div>
            <motion.div whileHover={{ scale: 1.02 }} className="rounded-2xl border border-zinc-200 bg-white p-6 dark:border-zinc-800 dark:bg-zinc-900">
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
            </motion.div>
            <motion.div whileHover={{ scale: 1.02 }} className="rounded-2xl border border-zinc-200 bg-white p-6 dark:border-zinc-800 dark:bg-zinc-900">
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
            </motion.div>
            <motion.div whileHover={{ scale: 1.02 }} className="rounded-2xl border border-zinc-200 bg-white p-6 dark:border-zinc-800 dark:bg-zinc-900">
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
            </motion.div>
             <motion.div whileHover={{ scale: 1.02 }} className="rounded-2xl border border-zinc-200 bg-white p-6 dark:border-zinc-800 dark:bg-zinc-900">
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
            </motion.div>
          </motion.div>
        )}
        </AnimatePresence>
      </div>
    </section>
  );
}
