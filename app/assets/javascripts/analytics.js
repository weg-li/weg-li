$(document).on('page:change', function() {
  if (window._gaq != null) {
    _gaq.push(['_trackPageview']);
  } else if (window.pageTracker != null) {
    pageTracker._trackPageview();
  }
});
