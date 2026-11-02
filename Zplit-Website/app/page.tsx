'use client';

import Navbar from '@/components/shared/Navbar';
import Hero from '@/components/home/Hero';
import P2PMethods from '@/components/home/P2PMethods';
import Features from '@/components/home/Features';
import AppGallery from '@/components/home/AppGallery';
import OpenSourceCTA from '@/components/home/OpenSourceCTA';
import FAQ from '@/components/home/FAQ';
import FinalCTA from '@/components/home/FinalCTA';
import Footer from '@/components/shared/Footer';

export default function Home() {
  return (
    <div className="min-h-screen bg-white dark:bg-black">
      <Navbar />
      <Hero />
      <P2PMethods />
      <Features />
      <AppGallery />
      <OpenSourceCTA />
      <FAQ />
      <FinalCTA />
      <Footer />
    </div>
  );
}
