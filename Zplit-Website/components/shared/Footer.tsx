'use client';
import { motion } from 'framer-motion';
import Image from 'next/image';

export default function Footer() {
  return (
    <footer className="border-t border-zinc-200 bg-white px-6 py-12 dark:border-zinc-800 dark:bg-black">
      <div className="mx-auto max-w-7xl">
        <motion.div 
           initial={{ opacity: 0, y: 20 }}
           whileInView={{ opacity: 1, y: 0 }}
           viewport={{ once: true }}
           transition={{ duration: 0.6 }}
           className="grid gap-8 md:grid-cols-4"
        >
          <div>
            <div className="mb-4 text-2xl font-bold text-emerald-900 dark:text-emerald-400">Zplit</div>
            <p className="mb-6 text-sm text-zinc-600 dark:text-zinc-400">
              Decentralized expense sharing for the privacy-conscious.
            </p>
            <div className="flex flex-col gap-3">
              <a href="https://aossie.org" target="_blank" rel="noopener noreferrer" className="flex items-center gap-2">
                <Image src="https://aossie.org/logo1.png" alt="AOSSIE Logo" width={32} height={32} className="h-8 w-auto" />
                <span className="text-lg font-bold text-emerald-900 dark:text-emerald-400">AOSSIE</span>
              </a>
              <p className="text-xs text-zinc-500 dark:text-zinc-500">
                Australian not-for-profit umbrella organization for open-source projects.
              </p>
            </div>
          </div>
          <div>
            <div className="mb-4 text-sm font-semibold text-zinc-900 dark:text-white">Product</div>
            <ul className="space-y-2 text-sm text-zinc-600 dark:text-zinc-400">
              <li><a href="#features" className="hover:text-emerald-600 dark:hover:text-emerald-400">Features</a></li>
              <li><a href="#tech" className="hover:text-emerald-600 dark:hover:text-emerald-400">Technology</a></li>
              <li><a href="#gallery" className="hover:text-emerald-600 dark:hover:text-emerald-400">Gallery</a></li>
              <li><a href="https://github.com/StabilityNexus/Zplit" className="hover:text-emerald-600 dark:hover:text-emerald-400">Roadmap</a></li>
            </ul>
          </div>
          <div>
            <div className="mb-4 text-sm font-semibold text-zinc-900 dark:text-white">Developers</div>
            <ul className="space-y-2 text-sm text-zinc-600 dark:text-zinc-400">
              <li><a href="https://github.com/StabilityNexus/Zplit" className="hover:text-emerald-600 dark:hover:text-emerald-400">GitHub</a></li>
              <li><a href="https://github.com/StabilityNexus/Zplit" className="hover:text-emerald-600 dark:hover:text-emerald-400">Documentation</a></li>
              <li><a href="https://github.com/StabilityNexus/Zplit" className="hover:text-emerald-600 dark:hover:text-emerald-400">API Reference</a></li>
              <li><a href="https://github.com/StabilityNexus/Zplit" className="hover:text-emerald-600 dark:hover:text-emerald-400">Contributing</a></li>
            </ul>
          </div>
          <div>
            <div className="mb-4 text-sm font-semibold text-zinc-900 dark:text-white">Community</div>
            <ul className="space-y-2 text-sm text-zinc-600 dark:text-zinc-400">
              <li><a href="https://twitter.com/aossie_org" className="hover:text-emerald-600 dark:hover:text-emerald-400">Twitter</a></li>
              <li><a href="https://discord.gg/6ExGjTBe" className="hover:text-emerald-600 dark:hover:text-emerald-400">Discord</a></li>
              <li><a href="mailto:aossie.oss@gmail.com" className="hover:text-emerald-600 dark:hover:text-emerald-400">Contact</a></li>
            </ul>
          </div>
        </motion.div>
        <motion.div 
           initial={{ opacity: 0 }}
           whileInView={{ opacity: 1 }}
           viewport={{ once: true }}
           transition={{ delay: 0.2 }}
           className="mt-12 border-t border-zinc-200 pt-8 text-center dark:border-zinc-800"
        >
          <p className="text-sm text-zinc-600 dark:text-zinc-400">
            © 2025 Zplit. Open source under MIT License. Built with ❤️ for privacy.
          </p>
        </motion.div>
      </div>
    </footer>
  );
}
