document.copyToClipboard = function(hint, text) {
  window.prompt(hint, text);
}

$(document).on('turbolinks:load', function() {
  $('[data-toggle="popover"]').popover();
  $('[data-toggle="tooltip"]').tooltip();
  $('select').select2({ theme: 'bootstrap' });
  $('.zoom').zoom();
});

// destroy select2 before caching
$(document).on("turbolinks:before-cache", function () {
  $('.select2-hidden-accessible').select2('destroy');
});
