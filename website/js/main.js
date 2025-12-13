/**
 * Zplit Website - Main JavaScript
 * Handles smooth scrolling, animations, and interactive elements
 */

// ===================================
// SMOOTH SCROLL FOR NAVIGATION LINKS
// ===================================
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        const href = this.getAttribute('href');

        // Skip if href is just "#"
        if (href === '#') {
            e.preventDefault();
            return;
        }

        const targetElement = document.querySelector(href);

        if (targetElement) {
            e.preventDefault();
            targetElement.scrollIntoView({
                behavior: 'smooth',
                block: 'start'
            });
        }
    });
});

// ===================================
// INTERSECTION OBSERVER FOR FADE-IN ANIMATIONS
// ===================================
const observerOptions = {
    threshold: 0.1,
    rootMargin: '0px 0px -50px 0px'
};

const fadeInObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.classList.add('fade-in-visible');
        }
    });
}, observerOptions);

// Observe all feature cards, step cards, and sections
document.addEventListener('DOMContentLoaded', () => {
    const elementsToAnimate = document.querySelectorAll(
        '.feature-card, .step-card, .tech-item, .community-btn'
    );

    elementsToAnimate.forEach(el => {
        el.classList.add('fade-in');
        fadeInObserver.observe(el);
    });
});

// ===================================
// NAVBAR SCROLL EFFECT
// ===================================
let lastScrollTop = 0;
const nav = document.querySelector('.nav');

window.addEventListener('scroll', () => {
    const scrollTop = window.pageYOffset || document.documentElement.scrollTop;

    // Add shadow when scrolled
    if (scrollTop > 50) {
        nav.style.boxShadow = '0 2px 8px rgba(0, 0, 0, 0.1)';
    } else {
        nav.style.boxShadow = 'none';
    }

    lastScrollTop = scrollTop;
});

// ===================================
// MOBILE MENU TOGGLE (if needed in future)
// ===================================
// Placeholder for mobile menu functionality
// Can be expanded when hamburger menu is added

// ===================================
// COPY DEEP LINK FUNCTIONALITY (Future)
// ===================================
// Placeholder for deep link sharing functionality

// ===================================
// ANALYTICS / TRACKING (Optional)
// ===================================
// Add analytics tracking here if needed
// Example: Google Analytics, Plausible, etc.

console.log('Zplit website loaded successfully! 🚀');
