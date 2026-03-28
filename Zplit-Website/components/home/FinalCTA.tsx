'use client';

import { motion } from 'framer-motion';

export default function FinalCTA() {
  return (
    <section className="bg-gradient-to-br from-emerald-50 via-green-50 to-teal-50 px-6 py-24 dark:from-emerald-950/20 dark:via-green-950/20 dark:to-teal-950/20">
      <div className="mx-auto max-w-4xl text-center">
        <motion.div
           initial={{ opacity: 0, scale: 0.9 }}
           whileInView={{ opacity: 1, scale: 1 }}
           viewport={{ once: true }}
           transition={{ duration: 0.6 }}
        >
          <h2 className="mb-6 text-4xl font-bold text-zinc-900 dark:text-white sm:text-5xl">
            Ready to Split Smarter?
          </h2>
          <p className="mb-8 text-lg text-zinc-600 dark:text-zinc-400">
            Join the waitlist and be among the first to experience truly decentralized expense sharing.
          </p>
        </motion.div>
        
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
          <motion.input
            initial={{ opacity: 0, x: -20 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true }}
            transition={{ delay: 0.2 }}
            id="waitlist-email"
            type="email"
            placeholder="Enter your email"
            required
            aria-label="Email address for waitlist"
            className="w-full rounded-full border-2 border-emerald-200 bg-white px-6 py-3 text-zinc-900 placeholder-zinc-400 focus:border-emerald-500 focus:outline-none dark:border-emerald-800 dark:bg-zinc-900 dark:text-white sm:w-80"
          />
          <motion.button
            initial={{ opacity: 0, x: 20 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true }}
            transition={{ delay: 0.2 }}
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
            type="submit"
            className="w-full rounded-full bg-emerald-900 px-8 py-3 font-semibold text-white shadow-lg transition-all hover:bg-emerald-800 hover:shadow-xl dark:bg-emerald-600 dark:hover:bg-emerald-500 sm:w-auto"
          >
            Join Waitlist
          </motion.button>
        </form>
        <motion.p 
          initial={{ opacity: 0 }}
          whileInView={{ opacity: 1 }}
          viewport={{ once: true }}
          transition={{ delay: 0.4 }}
          className="text-sm text-zinc-500 dark:text-zinc-500"
        >
          No spam. We&apos;ll only notify you when Zplit launches. Unsubscribe anytime.
        </motion.p>
      </div>
    </section>
  );
}
