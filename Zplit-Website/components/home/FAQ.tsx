'use client';

import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';

export default function FAQ() {
  const [showAll, setShowAll] = useState(false);

  const faqs = [
    {
      question: "How does Zplit work without servers?",
      answer: "Zplit uses peer-to-peer technologies like WiFi Direct, Bluetooth, and NFC to sync data directly between devices. All your expense data is stored locally on your device with encryption. When you're near friends, devices automatically sync changes."
    },
    {
      question: "What if I'm not near my friends?",
      answer: "You can share expenses via QR codes or deep links that work over any messaging app. The data syncs when you scan the code or click the link. You can also export encrypted backups and share them manually."
    },
    {
      question: "Is my financial data secure?",
      answer: "Absolutely. All data is encrypted and stored only on your device. We don't have servers, so there's nothing to hack. P2P transfers use end-to-end encryption. You have complete control over your data."
    },
    {
      question: "Can I use Zplit for cryptocurrency settlements?",
      answer: "We're building Web3 integration for future releases. You'll be able to settle debts using USDC, DAI, or other stablecoins via smart contracts. Traditional payment methods will always be supported too."
    },
    {
      question: "Is Zplit really free and open source?",
      answer: "Yes! Zplit is MIT licensed and completely free. No ads, no premium tiers, no hidden costs. The entire codebase is on GitHub. You can fork it, modify it, or self-host your own version."
    },
    {
      question: "When will Zplit be available?",
      answer: "We're currently in active development. Follow us on GitHub to track progress. Beta testing will begin soon for early adopters. Star the repo to get notified when we launch!"
    }
  ];

  const initialFaqs = faqs.slice(0, 3);
  const moreFaqs = faqs.slice(3);

  return (
    <section id="faq" className="bg-white px-6 py-24 dark:bg-black">
      <div className="mx-auto max-w-4xl">
        <motion.div 
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6 }}
          className="mb-16 text-center"
        >
          <h2 className="mb-4 text-4xl font-bold text-zinc-900 dark:text-white">
            Frequently Asked Questions
          </h2>
          <p className="text-lg text-zinc-600 dark:text-zinc-400">
            Everything you need to know about Zplit
          </p>
        </motion.div>
        
        <div>
          <div className="space-y-6">
            {initialFaqs.map((faq, index) => (
              <motion.div 
                key={index}
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.5, delay: index * 0.1 }}
                whileHover={{ scale: 1.02 }}
                className="rounded-2xl border border-zinc-200 bg-zinc-50 p-6 shadow-sm transition-all hover:shadow-md dark:border-zinc-800 dark:bg-zinc-900"
              >
                <h3 className="mb-3 text-lg font-bold text-zinc-900 dark:text-white">
                  {faq.question}
                </h3>
                <p className="text-zinc-600 dark:text-zinc-400">
                  {faq.answer}
                </p>
              </motion.div>
            ))}
          </div>

          <AnimatePresence>
            {showAll && (
              <motion.div
                initial={{ height: 0, opacity: 0 }}
                animate={{ height: 'auto', opacity: 1 }}
                exit={{ height: 0, opacity: 0 }}
                transition={{ duration: 0.3, ease: "easeInOut" }}
                className="overflow-hidden"
              >
                <div className="space-y-6 pt-6">
                  {moreFaqs.map((faq, index) => (
                    <motion.div 
                      key={index + 3} 
                      initial={{ opacity: 0, y: 20 }}
                      animate={{ opacity: 1, y: 0 }}
                      transition={{ duration: 0.5, delay: index * 0.1 }}
                      whileHover={{ scale: 1.02 }}
                      className="rounded-2xl border border-zinc-200 bg-zinc-50 p-6 shadow-sm transition-all hover:shadow-md dark:border-zinc-800 dark:bg-zinc-900"
                    >
                      <h3 className="mb-3 text-lg font-bold text-zinc-900 dark:text-white">
                        {faq.question}
                      </h3>
                      <p className="text-zinc-600 dark:text-zinc-400">
                        {faq.answer}
                      </p>
                    </motion.div>
                  ))}
                </div>
              </motion.div>
            )}
          </AnimatePresence>
        </div>

        <motion.div 
           initial={{ opacity: 0 }}
           whileInView={{ opacity: 1 }}
           viewport={{ once: true }}
           className="mt-8 text-center"
        >
          <button
            onClick={() => setShowAll(!showAll)}
            className="rounded-full border border-zinc-300 bg-white px-6 py-3 font-semibold text-zinc-900 transition-colors hover:bg-zinc-50 dark:border-zinc-700 dark:bg-zinc-900 dark:text-white dark:hover:bg-zinc-800"
          >
            {showAll ? 'Show Less' : 'Show More'}
          </button>
        </motion.div>
      </div>
    </section>
  );
}
