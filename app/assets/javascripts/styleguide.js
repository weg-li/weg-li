$(document).on('ready page:load page:change turbolinks:load', function() {
  var cleanSource = function(html) {
    var lines = html.split(/\n/);
    lines.shift();
    lines.splice(-1, 1);
    var indentSize = lines[0].length - lines[0].trim().length;
    var re = new RegExp(' {' + indentSize + '}');
    lines = lines.map(function(line) {
      if (line.match(re)) { line = line.substring(indentSize); }
      return line;
    });
    lines = lines.join("\n");
    return lines;
  };
  var $button = $("<div id='source-button' class='btn btn-primary btn-xs'>&lt; &gt;</div>").click(function() {
    var html = $(this).parent().html();
    html = cleanSource(html);
    $("#source-modal pre").text(html);
    $("#source-modal").modal();
  });
  $(".bs-component").hover((function() {
    $(this).append($button);
    $button.show();
  }), function() {
    $button.hide();
  });
});
