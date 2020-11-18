const Lucia = require("lucia");

document.copyToClipboard = function(hint, text) {
  window.prompt(hint, text);
}

$(document).on('turbolinks:load', function() {
  $('[data-toggle="popover"]').popover();
  $('[data-toggle="tooltip"]').tooltip();
  $('select[data-select2-disabled!="true"]').select2({ theme: 'bootstrap' });
  $('.zoom').zoom();
});

$(document).on('turbolinks:load', function() {
  Lucia.init();
});

$(document).on("turbolinks:before-cache", function () {
  // destroy select2 before caching
  $('.select2-hidden-accessible').select2('destroy');
});

$(document).on("submit", function () {
  // https://github.com/weg-li/weg-li/issues/219
  // https://github.com/turbolinks/turbolinks/issues/238
  $('select').each(function () {
    const el = $(this);
    const selected = el.val();
    el.find('option').attr('selected', null);
    if (selected) {
      el.find(`option[value="${selected}"]`).attr('selected', true);
    }
  });
});
