require("select2")(window, window.jQuery);
require("jquery-zoom");

$(document).ready(() => {
  $('[data-toggle="popover"]').popover();
  $('[data-toggle="tooltip"]').tooltip();
});

$(document).ready(() => {
  $(".zoom").zoom();
});

$(document).ready(() => {
  $('select[data-select2-disabled!="true"]').select2({ theme: "bootstrap" });
});

$(document).ready(() => {
  $(".carousel").carousel();
});

// The navbar is fixed, so the expanded mobile menu would cover the page.
// Let the page start below the navbar instead, following its height.
$(document).ready(() => {
  const navbar = document.querySelector(".navbar-fixed-top");
  if (!navbar || !window.ResizeObserver) return;

  const basePadding = parseFloat(getComputedStyle(document.body).paddingTop);
  const baseHeight = navbar.offsetHeight;
  new ResizeObserver(() => {
    document.body.style.paddingTop = `${basePadding + navbar.offsetHeight - baseHeight}px`;
  }).observe(navbar);
});

$(document).on("shown.bs.dropdown", (event) => {
  $(event.relatedTarget).siblings().find("form").find("input[autofocus]").focus();
});
