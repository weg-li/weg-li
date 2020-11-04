const { createApp } = require("lucia")

document.copyToClipboard = function(hint, text) {
  window.prompt(hint, text);
}

$(document).on('turbolinks:load', function() {
  $('[data-toggle="popover"]').popover();
  $('[data-toggle="tooltip"]').tooltip();
  $('select[data-select2-disabled!="true"]').select2({ theme: 'bootstrap' });
  $('.zoom').zoom();

  var elements = Array.from(document.querySelectorAll('[l-use]'));
  for (var _i = 0, _elements = elements; _i < _elements.length; _i++) {
    var el = _elements[_i];
    var options = el.getAttribute('l-use');
    if (options === null) return;
    var app = createApp(new Function("return (".concat(options, ")"))());
    var link = el.getAttribute('l-link');
    if (link) links[link] = app;
    app.mount(el);
  }
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
