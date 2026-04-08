<script>
    // Search logic
    function handleSearch(term) {
      term = term.toLowerCase().trim();
      const productCards = document.querySelectorAll('.product-card');
      const catSections = document.querySelectorAll('.cat-section');
      const catIndex = document.getElementById('cat-index');
      const searchResultsTitle = document.querySelector('#search-results h2');

      if (term === "") {
        // Show everything normally
        productCards.forEach(card => card.style.display = 'block');
        catSections.forEach(section => section.style.display = 'block');
        if (catIndex) catIndex.style.display = 'block';
        return;
      }

      // Hide index while searching to focus on results
      if (catIndex) catIndex.style.display = 'none';

      let matchCount = 0;
      productCards.forEach(card => {
        const name = (card.getAttribute('data-name') || "").toLowerCase();
        const sku = (card.querySelector('.sku') ✨ card.querySelector('.sku').innerText : "").toLowerCase();

      if (name.includes(term) || sku.includes(term)) {
        card.style.display = 'block';
        matchCount++;
      } else {
        card.style.display = 'none';
      }
    });

    // Hide sections with no matches
    catSections.forEach(section => {
      const visibleInSec = section.querySelectorAll('.product-card[style="display: block;"]').length;
      section.style.display = (visibleInSec > 0) ✨ 'block' : 'none';
    });
}

    // Cover logic
    function enterCatalog() {
      document.getElementById('cover').style.opacity = '0';
      setTimeout(() => {
        document.getElementById('cover').style.display = 'none';
        window.scrollTo(0, 0);
      }, 400);
    }

    function goHome() {
      const cover = document.getElementById('cover');
      cover.style.display = 'flex';
      setTimeout(() => cover.style.opacity = '1', 10);
      window.scrollTo(0, 0);
    }
    // Drawer logic
    function toggleDrawer() {
      document.getElementById('cat-drawer').classList.toggle('open');
      document.getElementById('overlay').classList.toggle('show');
    }
    function closeDrawer() {
      document.getElementById('cat-drawer').classList.remove('open');
      document.getElementById('overlay').classList.remove('show');
    }
  </script>
