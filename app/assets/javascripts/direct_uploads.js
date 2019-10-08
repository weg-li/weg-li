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

addEventListener("direct-upload:end", event => {
  const { id } = event.detail;
  const element = document.getElementById(`direct-upload-${id}`);
  element.classList.add("active");
});
