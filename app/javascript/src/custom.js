require('select2');
require('jquery-zoom');

$(document).ready(() => {
  $('[data-toggle="popover"]').popover();
  $('[data-toggle="tooltip"]').tooltip();
});

$(document).ready(() => {
  $('.zoom').zoom();
});

$(document).ready(() => {
  $('select[data-select2-disabled!="true"]').select2({ theme: 'bootstrap' });
});
