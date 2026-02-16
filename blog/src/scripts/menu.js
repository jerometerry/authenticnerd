const menuBtn = document.getElementById('menu-btn');
const navLinks = document.getElementById('nav-links');

menuBtn?.addEventListener('click', () => {
	navLinks?.classList?.toggle('hidden');

	const isExpanded = navLinks?.classList?.contains('hidden') ? 'false' : 'true';
    menuBtn?.setAttribute('aria-expanded', isExpanded);
});
