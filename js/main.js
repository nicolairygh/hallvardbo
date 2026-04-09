document.addEventListener('DOMContentLoaded', () => {

  /* ---- Mobile menu ---- */
  const hamburger = document.querySelector('.hamburger');
  const mobileNav = document.querySelector('.mobile-nav');
  if (hamburger && mobileNav) {
    hamburger.addEventListener('click', () => {
      hamburger.classList.toggle('open');
      mobileNav.classList.toggle('open');
    });
    mobileNav.querySelectorAll('a').forEach(a => {
      a.addEventListener('click', () => {
        hamburger.classList.remove('open');
        mobileNav.classList.remove('open');
      });
    });
  }

  /* ---- Header scroll shadow ---- */
  const header = document.querySelector('.header');
  if (header) {
    window.addEventListener('scroll', () => {
      header.classList.toggle('scrolled', window.scrollY > 20);
    }, { passive: true });
  }

  /* ---- Scroll reveal ---- */
  const reveals = document.querySelectorAll('.fade-up');
  if (reveals.length) {
    const io = new IntersectionObserver((entries) => {
      entries.forEach(e => { if (e.isIntersecting) { e.target.classList.add('visible'); io.unobserve(e.target); } });
    }, { threshold: 0.15 });
    reveals.forEach(el => io.observe(el));
  }

  /* ---- Gallery lightbox ---- */
  const lightbox = document.querySelector('.lightbox');
  const galleryItems = document.querySelectorAll('.gallery-item');
  if (lightbox && galleryItems.length) {
    const lbImg = lightbox.querySelector('img');
    const lbCaption = lightbox.querySelector('.lightbox__caption');
    let current = 0;

    function openLightbox(i) {
      current = i;
      const item = galleryItems[i];
      lbImg.src = item.querySelector('img').src;
      lbCaption.textContent = item.dataset.caption || '';
      lightbox.classList.add('open');
      document.body.style.overflow = 'hidden';
    }
    function closeLightbox() {
      lightbox.classList.remove('open');
      document.body.style.overflow = '';
    }
    function navigate(dir) {
      current = (current + dir + galleryItems.length) % galleryItems.length;
      const item = galleryItems[current];
      lbImg.src = item.querySelector('img').src;
      lbCaption.textContent = item.dataset.caption || '';
    }

    galleryItems.forEach((item, i) => item.addEventListener('click', () => openLightbox(i)));
    lightbox.querySelector('.lightbox__close').addEventListener('click', closeLightbox);
    lightbox.querySelector('.lightbox__nav--prev').addEventListener('click', () => navigate(-1));
    lightbox.querySelector('.lightbox__nav--next').addEventListener('click', () => navigate(1));
    lightbox.addEventListener('click', (e) => { if (e.target === lightbox) closeLightbox(); });

    document.addEventListener('keydown', (e) => {
      if (!lightbox.classList.contains('open')) return;
      if (e.key === 'Escape') closeLightbox();
      if (e.key === 'ArrowLeft') navigate(-1);
      if (e.key === 'ArrowRight') navigate(1);
    });
  }
});
