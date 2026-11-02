'use client';

import { motion } from 'framer-motion';

export default function AppGallery() {
  return (
    <section id="gallery" className="bg-gradient-to-b from-zinc-50 to-white px-6 py-24 dark:from-zinc-950 dark:to-black">
      <div className="mx-auto max-w-7xl">
        <motion.div 
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6 }}
          className="mb-16 text-center"
        >
          <h2 className="mb-4 text-4xl font-bold text-zinc-900 dark:text-white">
            Experience Zplit
          </h2>
          <p className="mx-auto max-w-2xl text-lg text-zinc-600 dark:text-zinc-400">
            A glimpse into the intuitive interface designed for seamless expense management
          </p>
        </motion.div>
        
        <div className="grid gap-8 md:grid-cols-2 lg:grid-cols-3">
          {/* Screenshot 1 - Dashboard */}
          <motion.div 
            initial={{ opacity: 0, scale: 0.95 }}
            whileInView={{ opacity: 1, scale: 1 }}
            viewport={{ once: true }}
            transition={{ duration: 0.5, delay: 0.1 }}
            className="group relative overflow-hidden rounded-3xl bg-gradient-to-br from-emerald-500 to-teal-600 p-1 shadow-2xl transition-all hover:scale-105"
          >
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
          </motion.div>

          {/* Screenshot 2 - Add Expense */}
          <motion.div 
            initial={{ opacity: 0, scale: 0.95 }}
            whileInView={{ opacity: 1, scale: 1 }}
            viewport={{ once: true }}
            transition={{ duration: 0.5, delay: 0.2 }}
            className="group relative overflow-hidden rounded-3xl bg-gradient-to-br from-blue-500 to-indigo-600 p-1 shadow-2xl transition-all hover:scale-105"
          >
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
                        Exact
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </motion.div>

          {/* Screenshot 3 - Analytics */}
          <motion.div 
            initial={{ opacity: 0, scale: 0.95 }}
            whileInView={{ opacity: 1, scale: 1 }}
            viewport={{ once: true }}
            transition={{ duration: 0.5, delay: 0.3 }}
            className="group relative overflow-hidden rounded-3xl bg-gradient-to-br from-purple-500 to-pink-600 p-1 shadow-2xl transition-all hover:scale-105"
          >
             <div className="h-[600px] overflow-hidden rounded-[22px] bg-white dark:bg-zinc-900">
              <div className="flex h-full flex-col bg-gradient-to-br from-purple-50 to-pink-100 p-6 dark:from-purple-950 dark:to-pink-950">
                <div className="mb-6 flex items-center justify-between">
                  <div className="text-2xl font-bold text-purple-900 dark:text-purple-100">Analytics</div>
                  <div className="flex gap-2">
                    <div className="h-8 w-8 rounded-full bg-purple-200 dark:bg-purple-800"></div>
                  </div>
                </div>
                <div className="mb-6 flex h-48 items-end justify-between gap-2 rounded-2xl bg-white/60 p-6 shadow-lg dark:bg-black/20">
                    <div className="w-full rounded-t-lg bg-purple-300/50" style={{ height: '40%' }}></div>
                    <div className="w-full rounded-t-lg bg-purple-400/50" style={{ height: '70%' }}></div>
                    <div className="w-full rounded-t-lg bg-pink-400/50" style={{ height: '50%' }}></div>
                    <div className="w-full rounded-t-lg bg-purple-500" style={{ height: '85%' }}></div>
                    <div className="w-full rounded-t-lg bg-pink-300/50" style={{ height: '60%' }}></div>
                </div>
                <div className="space-y-3">
                    <div className="rounded-xl bg-white/60 p-4 shadow dark:bg-black/20">
                        <div className="mb-2 flex justify-between text-sm font-medium">
                            <span className="text-purple-900 dark:text-purple-100">Food & Dining</span>
                            <span className="text-zinc-600 dark:text-zinc-400">45%</span>
                        </div>
                        <div className="h-2 overflow-hidden rounded-full bg-purple-200">
                            <div className="h-full w-[45%] rounded-full bg-purple-600"></div>
                        </div>
                    </div>
                    <div className="rounded-xl bg-white/60 p-4 shadow dark:bg-black/20">
                        <div className="mb-2 flex justify-between text-sm font-medium">
                            <span className="text-purple-900 dark:text-purple-100">Travel</span>
                            <span className="text-zinc-600 dark:text-zinc-400">30%</span>
                        </div>
                        <div className="h-2 overflow-hidden rounded-full bg-pink-200">
                            <div className="h-full w-[30%] rounded-full bg-pink-600"></div>
                        </div>
                    </div>
                     <div className="rounded-xl bg-white/60 p-4 shadow dark:bg-black/20">
                        <div className="mb-2 flex justify-between text-sm font-medium">
                            <span className="text-purple-900 dark:text-purple-100">Utilities</span>
                            <span className="text-zinc-600 dark:text-zinc-400">25%</span>
                        </div>
                        <div className="h-2 overflow-hidden rounded-full bg-indigo-200">
                            <div className="h-full w-[25%] rounded-full bg-indigo-600"></div>
                        </div>
                    </div>
                </div>
              </div>
            </div>
          </motion.div>
        </div>
      </div>
    </section>
  );
}
