document.copyToClipboard = function(hint, text) {
  window.prompt(hint, text);
}

$(document).on('ready page:load page:change turbolinks:load', function() {
  $('[data-toggle="popover"]').popover();
  $('[data-toggle="tooltip"]').tooltip();
});
