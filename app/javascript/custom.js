require('select2');
require('jquery-zoom');

$(document).on('turbolinks:load', () => {
  $('[data-toggle="popover"]').popover();
  $('[data-toggle="tooltip"]').tooltip();
});

$(document).on('turbolinks:load', () => {
  $('.zoom').zoom();
});

$(document).on('turbolinks:load', () => {
  $('select[data-select2-disabled!="true"]').select2({ theme: 'bootstrap' });
});

$(document).on('turbolinks:before-cache', () => {
  // destroy select2 before caching
  $('.select2-hidden-accessible').select2('destroy');
});

$(document).on('submit', () => {
  // https://github.com/weg-li/weg-li/issues/219
  // https://github.com/turbolinks/turbolinks/issues/238
  $('select').each(function hack() {
    const el = $(this);
    const selected = el.val();
    el.find('option').attr('selected', null);
    if (selected) {
      el.find(`option[value="${selected}"]`).attr('selected', true);
    }
  });
});
