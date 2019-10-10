addEventListener("direct-upload:initialize", event => {
  const { target, detail } = event;
  const { id, file } = detail;
  target.insertAdjacentHTML("beforebegin", `
    <p>${file.name} (${(file.size / 1048576).toFixed(2)} MB)</p>
    <div id="direct-upload-${id}" class="progress">
      <div id="direct-upload-progress-${id}" class="progress-bar progress-bar-success" style="width: 0%"></div>
    </div>
    <div id="direct-upload-error-${id}" class="alert alert-warning hidden">
      ERROR
    </div>
  `);
});

addEventListener("direct-upload:start", event => {
  const { id } = event.detail;
  const element = document.getElementById(`direct-upload-${id}`);
  element.classList.add("progress-striped");
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
  element.classList.add("progress-bar-warning");

  const errorEl = document.getElementById(`direct-upload-error-${id}`);
  errorEl.innerHTML = error;
  errorEl.classList.remove("hidden");
});

addEventListener("direct-upload:end", (event) => loadEdit(event));

async function loadEdit(event) {
  const { target, detail } = event;
  const { id } = event.detail;
  const signed_id = target.previousElementSibling.value;
  if (signed_id && fetch) {
    const url = target.attributes['analyze_url'].value;
    const data = { blob: { signed_id } };
    try {
      const response = await fetch(url, {
        method: 'POST', // *GET, POST, PUT, DELETE, etc.
        mode: 'cors', // no-cors, *cors, same-origin
        cache: 'no-cache', // *default, no-cache, reload, force-cache, only-if-cached
        credentials: 'same-origin', // include, *same-origin, omit
        headers: {
          'Content-Type': 'application/json'
          // 'Content-Type': 'application/x-www-form-urlencoded',
        },
        redirect: 'follow', // manual, *follow, error
        referrer: 'no-referrer', // no-referrer, *client
        body: JSON.stringify(data) // body data type must match "Content-Type" header
      });
      const result = await response.json(); // parses JSON response into native JavaScript objects
      console.log(result);
    } catch (e) {
      console.log(e);
    }
  }
  const element = document.getElementById(`direct-upload-${id}`);
  element.classList.add("active");
}
