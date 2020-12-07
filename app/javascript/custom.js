require("select2");
require("jquery-zoom");
const Lucia = require("lucia");

$(document).on('turbolinks:load', function() {
  $('[data-toggle="popover"]').popover();
  $('[data-toggle="tooltip"]').tooltip();
});

$(document).on('turbolinks:load', function() {
  $('.zoom').zoom();
});

$(document).on('turbolinks:load', function() {
  Lucia.init();
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
