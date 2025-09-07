import React from 'react';
import { useState } from 'react';
import Header from './components/Header';
import Hero from './components/Hero';
import FeaturedTools from './components/FeaturedTools';
import BlogSection from './components/BlogSection';
import CoursesSection from './components/CoursesSection';
import SolutionsSection from './components/SolutionsSection';
import Testimonials from './components/Testimonials';
import Newsletter from './components/Newsletter';
import Footer from './components/Footer';
import CRMDashboard from './components/CRM/CRMDashboard';

function App() {
  const [showCRM, setShowCRM] = useState(false);

  if (showCRM) {
    return <CRMDashboard onClose={() => setShowCRM(false)} />;
  }

  return (
    <div className="min-h-screen bg-white">
      <Header onCRMClick={() => setShowCRM(true)} />
      <main>
        <Hero />
        <FeaturedTools />
        <BlogSection />
        <CoursesSection />
        <SolutionsSection />
        <Testimonials />
        <Newsletter />
      </main>
      <Footer />
    </div>
  );
}

export default App;