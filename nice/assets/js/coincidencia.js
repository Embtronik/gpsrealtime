const searchInput = document.getElementById('searchInput');

searchInput.addEventListener('input', function () {
  if (typeof applyFilter === 'function') {
    applyFilter(this.value.trim().toLowerCase());
  }
});
