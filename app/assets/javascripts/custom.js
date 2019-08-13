document.copyToClipboard = function(hint, text) {
  window.prompt(hint, text);
}

$(document).on('ready page:load page:change turbolinks:load', function() {
  $('[data-toggle="popover"]').popover();
  $('[data-toggle="tooltip"]').tooltip();
  $('select').selectize();
  $('input[type="file"]').fileinput({ language: 'de', maxFileCount: 5, browseOnZoneClick: true });
});
