document.copyToClipboard = function(hint, text) {
  window.prompt(hint, text);
}

$(document).on('ready page:load page:change turbolinks:load', function() {
  $('[data-toggle="popover"]').popover();
  $('[data-toggle="tooltip"]').tooltip();
  $('select').selectize();
  $('.datetimepicker').datetimepicker({locale: 'de', parseInputDate: (value) => { return moment(new Date(value)) }});
});
