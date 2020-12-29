$(document).on('turbolinks:load', function() {
  $(document).on('change', '#fileupload', event => {
    const target = event.target;
    const files = Array.from(target.files);
    const accepts = target.accept.split(',') || ['image/jpeg'];
    if (files.some(file => !accepts.includes(file.type) )) {
      alert('Es werden nur Fotos im JPEG Format unterstützt!');
      target.value = '';
    } else {
      document.getElementById('photos-preview')?.remove();
      const items = files.map(file => `<li class="list-item"><img src="${window.URL.createObjectURL(file)}" class="index-photo"></li>`);
      target.insertAdjacentHTML("beforebegin", `<div id="photos-preview"><ul class="photo-list">${items.join(' ')}</ul></div>`);
    }
  });
});

addEventListener("direct-uploads:start", event => {
  console.log('removing');
  document.getElementById('photos-preview').remove();
});

addEventListener("direct-upload:initialize", event => {
  const { target, detail } = event;
  const { id, file } = detail;
  target.insertAdjacentHTML("beforebegin", `
    <p><img src="${window.URL.createObjectURL(file)}" class="index-photo" style="v-align:middle" /> ${file.name} (${(file.size / 1048576).toFixed(2)} MB)</p>
    <div id="direct-upload-${id}" class="progress progress-striped active">
      <div id="direct-upload-progress-${id}" class="progress-bar progress-bar-success" style="width: 0%"></div>
    </div>
    <div id="direct-upload-error-${id}" class="alert alert-warning hidden">
      ERROR
    </div>
  `);
});

addEventListener("direct-upload:progress", event => {
  const { id, progress } = event.detail;
  const progressElement = document.getElementById(`direct-upload-progress-${id}`);
  progressElement.style.width = `${progress}%`;
});

addEventListener("direct-upload:error", event => {
  event.preventDefault();
  const { id, error } = event.detail;
  const element = document.getElementById(`direct-upload-${id}`);
  element.classList.remove("progress-bar-success");
  element.classList.add("progress-bar-warning");

  const errorEl = document.getElementById(`direct-upload-error-${id}`);
  errorEl.innerHTML = error;
  errorEl.classList.remove("hidden");
});

addEventListener("direct-upload:end", event => {
  const { target } = event;

  target.scrollIntoView({block: "end", behavior: "smooth"});

  const signed_id = target.previousElementSibling.value;
  if (signed_id && fetch && target.hasAttribute('analyze_url')) {
    const url = target.attributes['analyze_url'].value;
    const data = { blob: { signed_id } };
    setTimeout(triggerAnalyzation, 50, url, data);
  }
});

// optimization, trigger async processing once its upoaded
async function triggerAnalyzation(url, data) {
    try {
      const response = await fetch(url, {
        method: 'POST', // *GET, POST, PUT, DELETE, etc.
        mode: 'cors', // no-cors, *cors, same-origin
        cache: 'no-cache', // *default, no-cache, reload, force-cache, only-if-cached
        credentials: 'same-origin', // include, *same-origin, omit
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(data) // body data type must match "Content-Type" header
      });
      const result = await response.json(); // parses JSON response into native JavaScript objects
      // console.log(result);
      return result
    } catch (e) {
      console.log(e);
    }
}
