/* eslint no-restricted-globals: "off" */

$(document).ready(() => {
  $(document).on('change', '#fileupload', (event) => {
    const { target } = event;
    const uploadLimit = target.attributes.upload_limit.value;
    const files = Array.from(target.files);
    const accepts = target.accept.split(',') || ['image/jpeg'];

    document.getElementById('direct-upload-error-size')?.remove();
    document.getElementById('photos-preview')?.remove();
    if (files.some((file) => !accepts.includes(file.type))) {
      target.insertAdjacentHTML('beforebegin', '<div id="direct-upload-error-size" class="alert alert-warning">Es werden nur Fotos im JPEG Format unterstützt!</div>');
      target.value = '';
    } else if (files.some((file) => file.size > uploadLimit)) {
      target.insertAdjacentHTML('beforebegin', `<div id="direct-upload-error-size" class="alert alert-warning">Es können nur Fotos bis ${uploadLimit / 1048576} MB hochgeladen werden!</div>`);
      target.value = '';
    } else {
      document.getElementById('photos-preview')?.remove();
      const items = files.map((file) => `<li class="list-item"><img src="${window.URL.createObjectURL(file)}" class="index-photo"></li>`);
      target.insertAdjacentHTML('beforebegin', `<div id="photos-preview"><ul class="photo-list">${items.join(' ')}</ul></div>`);
    }
  });
});

addEventListener('direct-uploads:start', () => {
  document.getElementById('photos-preview')?.remove();
});

addEventListener('direct-upload:initialize', (event) => {
  const { target, detail } = event;
  const { id, file } = detail;
  target.insertAdjacentHTML('beforebegin', `
    <p><img src="${window.URL.createObjectURL(file)}" class="index-photo" style="v-align:middle" /> ${file.name} (${(file.size / 1048576).toFixed(2)} MB)</p>
    <div id="direct-upload-${id}" class="progress progress-striped active">
      <div id="direct-upload-progress-${id}" class="progress-bar progress-bar-success" style="width: 0%"></div>
    </div>
    <div id="direct-upload-error-${id}" class="alert alert-warning hidden">
      ERROR
    </div>
  `);
});

addEventListener('direct-upload:progress', (event) => {
  const { id, progress } = event.detail;
  const progressElement = document.getElementById(`direct-upload-progress-${id}`);
  progressElement.style.width = `${progress}%`;
});

addEventListener('direct-upload:error', (event) => {
  event.preventDefault();
  const { id, error } = event.detail;
  const element = document.getElementById(`direct-upload-${id}`);
  element.classList.remove('progress-bar-success');
  element.classList.add('progress-bar-warning');

  const errorEl = document.getElementById(`direct-upload-error-${id}`);
  errorEl.innerHTML = error;
  errorEl.classList.remove('hidden');
});

async function triggerAnalyzation(url, data) {
  try {
    const response = await fetch(url, {
      method: 'POST',
      mode: 'cors',
      cache: 'no-cache',
      credentials: 'same-origin',
      headers: {
        'X-CSRF-Token': document.querySelector("[name='csrf-token']")?.content,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(data),
    });
    if (!response.ok) {
      throw new Error(response.statusText);
    }
    return response.json();
  } catch (err) {
    throw new Error(err.message);
  }
}

addEventListener('direct-upload:end', (event) => {
  const { target } = event;

  target.scrollIntoView({ block: 'end', behavior: 'smooth' });

  const signedID = target.previousElementSibling.value;
  if (signedID && target.hasAttribute('analyze_url')) {
    const url = target.attributes.analyze_url.value;
    const data = { blob: { signed_id: signedID } };
    setTimeout(triggerAnalyzation, 50, url, data);
  }
});
