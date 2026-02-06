function cleanSource(html) {
  let lines = html.split(/\n/);
  lines.shift();
  lines.splice(-1, 1);
  const indentSize = lines[0].length - lines[0].trim().length;
  const re = new RegExp(` {${indentSize}}`);
  lines = lines.map((line) => {
    if (line.match(re)) {
      return line.substring(indentSize);
    }
    return line;
  });
  lines = lines.join("\n");
  return lines;
}

$(document).on("ready page:load page:change", () => {
  const $button = $("<div id='source-button' class='btn btn-primary btn-xs'>&lt; &gt;</div>").click(function handler() {
    let html = $(this).parent().html();
    html = cleanSource(html);
    $("#source-modal pre").text(html);
    $("#source-modal").modal();
  });
  $(".bs-component").hover(
    function action() {
      $(this).append($button);
      $button.show();
    },
    () => {
      $button.hide();
    },
  );
});
