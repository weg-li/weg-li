document.copyToClipboard = function(hint, text) {
  window.prompt(hint, text);
}

$(document).on('turbolinks:load', function() {
  $('[data-toggle="popover"]').popover();
  $('[data-toggle="tooltip"]').tooltip();
  $('select').select2({ theme: 'bootstrap' });
  // disable it for now
  // $('input[type="file"]').fileinput({ language: 'de', maxFileCount: 5, browseOnZoneClick: true });
});

// destroy select2 before caching
$(document).on("turbolinks:before-cache", function () {
  $('.select2-hidden-accessible').select2('destroy');
});
