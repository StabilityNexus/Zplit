'use client';

import { motion } from 'framer-motion';

export default function Features() {
  const container = {
    hidden: { opacity: 0 },
    show: {
      opacity: 1,
      transition: {
        staggerChildren: 0.1
      }
    }
  };

  const item = {
    hidden: { opacity: 0, y: 20 },
    show: { opacity: 1, y: 0, transition: { duration: 0.5 } }
  };

  return (
    <section id="features" className="bg-white px-6 py-24 dark:bg-black">
      <div className="mx-auto max-w-7xl">
        <motion.div 
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6 }}
          className="mb-16 text-center"
        >
          <h2 className="mb-4 text-4xl font-bold text-zinc-900 dark:text-white">
            Powerful Features, Zero Compromises
          </h2>
          <p className="mx-auto max-w-2xl text-lg text-zinc-600 dark:text-zinc-400">
            Everything you need to manage group expenses, without sacrificing privacy or requiring internet connectivity.
          </p>
        </motion.div>
        
        <motion.div 
          variants={container}
          initial="hidden"
          whileInView="show"
          viewport={{ once: true, margin: "-50px" }}
          className="grid gap-8 md:grid-cols-2 lg:grid-cols-3"
        >
          <motion.div variants={item} className="group rounded-2xl border border-zinc-100 bg-gradient-to-br from-white to-zinc-50 p-8 transition-all hover:border-emerald-200 hover:shadow-2xl dark:border-zinc-800 dark:from-zinc-900 dark:to-zinc-900/50 dark:hover:border-emerald-800">
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
          </motion.div>
          <motion.div variants={item} className="group rounded-2xl border border-zinc-100 bg-gradient-to-br from-white to-zinc-50 p-8 transition-all hover:border-blue-200 hover:shadow-2xl dark:border-zinc-800 dark:from-zinc-900 dark:to-zinc-900/50 dark:hover:border-blue-800">
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
          </motion.div>
          <motion.div variants={item} className="group rounded-2xl border border-zinc-100 bg-gradient-to-br from-white to-zinc-50 p-8 transition-all hover:border-purple-200 hover:shadow-2xl dark:border-zinc-800 dark:from-zinc-900 dark:to-zinc-900/50 dark:hover:border-purple-800">
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
          </motion.div>
          <motion.div variants={item} className="group rounded-2xl border border-zinc-100 bg-gradient-to-br from-white to-zinc-50 p-8 transition-all hover:border-teal-200 hover:shadow-2xl dark:border-zinc-800 dark:from-zinc-900 dark:to-zinc-900/50 dark:hover:border-teal-800">
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
          </motion.div>
          <motion.div variants={item} className="group rounded-2xl border border-zinc-100 bg-gradient-to-br from-white to-zinc-50 p-8 transition-all hover:border-orange-200 hover:shadow-2xl dark:border-zinc-800 dark:from-zinc-900 dark:to-zinc-900/50 dark:hover:border-orange-800">
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
          </motion.div>
          <motion.div variants={item} className="group rounded-2xl border border-zinc-100 bg-gradient-to-br from-white to-zinc-50 p-8 transition-all hover:border-pink-200 hover:shadow-2xl dark:border-zinc-800 dark:from-zinc-900 dark:to-zinc-900/50 dark:hover:border-pink-800">
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
          </motion.div>
        </motion.div>
      </div>
    </section>
  );
}
