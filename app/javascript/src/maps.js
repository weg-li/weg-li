const L = require('leaflet');
require('leaflet.markercluster');

L.Icon.Default.imagePath = '/img/map/';

function mapHTML(notice) {
  const date = notice.date ? new Date(Date.parse(notice.date)).toLocaleDateString() : '-';
  if (notice.token) {
    return `
      <dl>
        <dt>Datum</dt>
        <dd>${date}</dd>
        <dt>Kennzeichen</dt>
        <dd>${notice.registration || '-'}</dd>
        <dt>Verstoß</dt>
        <dd>${notice.charge || '-'}</dd>
        <dt>Adresse</dt>
        <dd>${notice.full_address || '-'}</dd>
        <dt><a href="/notices/${notice.token}">Details ansehen</a></dt>
      </dl>
    `;
  }
  return `
    <dl>
      <dt>Datum</dt>
      <dd>${date}</dd>
      <dt>Verstoß</dt>
      <dd>${notice.charge || '-'}</dd>
    </dl>
  `;
}

function initMap(canvas, coords, zoom = 13) {
  const map = L.map(canvas).setView(coords, zoom);

  L.tileLayer('https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}', {
    attribution: 'Map data &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, Imagery © <a href="https://www.mapbox.com/">Mapbox</a>',
    id: 'mapbox/outdoors-v11',
    accessToken: 'pk.eyJ1IjoicGhvZXQiLCJhIjoiY2s4b2Y3cGdqMDIzZDNkbnMwMzhlMnJpbiJ9.n2Fw_hniWAZ8T5-Qc0V0fA',
  }).addTo(map);
  return map;
}

class GMap {
  constructor(canvas) {
    this.canvas = canvas[0];
    this.notice = canvas.data('notice');
  }

  show() {
    const map = initMap(this.canvas, [this.notice.latitude, this.notice.longitude]);

    L.marker([this.notice.latitude, this.notice.longitude]).addTo(map).bindPopup(mapHTML(this.notice));
  }
}

async function geocode(latitude, longitude) {
  const result = await fetch('/notices/geocode', {
    method: 'POST', // *GET, POST, PUT, DELETE, etc.
    mode: 'cors', // no-cors, *cors, same-origin
    cache: 'no-cache', // *default, no-cache, reload, force-cache, only-if-cached
    credentials: 'same-origin', // include, *same-origin, omit
    headers: {
      'X-CSRF-Token': document.querySelector("[name='csrf-token']")?.content,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ latitude, longitude }), // body data type must match "Content-Type" header
  });

  return result.json();
}

class GPickerMap {
  constructor(canvas) {
    this.canvas = canvas[0];
    this.coordinates = canvas.data('coordinates');
    this.street = canvas.data('street');
    this.zip = canvas.data('zip');
    this.city = canvas.data('city');
    this.latitude = canvas.data('latitude');
    this.longitude = canvas.data('longitude');
    this.trigger = canvas.data('trigger');
    this.map = null;
  }

  rerender() {
    this.map.invalidateSize();
  }

  show() {
    const point = [this.coordinates.latitude, this.coordinates.longitude];
    this.map = initMap(this.canvas, point, 18);
    const marker = L.marker(point, { draggable: true }).addTo(this.map);

    const markerMoved = async (event) => {
      const latlng = event.latlng || event.target.getLatLng();
      marker.setLatLng(latlng);

      const data = await geocode(latlng.lat, latlng.lng);
      if (data.result) {
        $(this.street).val(data.result.street);
        $(this.zip).val(data.result.zip);
        $(this.city).val(data.result.city);
        $(this.latitude).val(latlng.lat);
        $(this.longitude).val(latlng.lng);
      } else {
        window.alert('Es konnten keine Ergebnisse gefunden werden.');
      }
    };

    marker.addEventListener('dragend', markerMoved);
    this.map.addEventListener('dblclick', markerMoved);

    $(window.document).on('click', this.trigger, () => {
      if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition((position) => {
          const latlng = {
            lat: position.coords.latitude,
            lng: position.coords.longitude,
          };

          this.map.flyTo(latlng);
          markerMoved({ latlng });
        }, (error) => {
          console.log('error getting current location', error);
        });
      } else {
        window.alert('Der Browser unterstützt keine Geolocation');
      }
    });
  }
}

class GMultiMap {
  constructor(canvas) {
    this.canvas = canvas[0];
    this.init = canvas.data('init');
    this.notices = canvas.data('notices');
  }

  show() {
    const map = initMap(this.canvas, [this.init.latitude, this.init.longitude], this.init.zoom);

    if (this.notices.length > 0) {
      const bounds = [];
      this.notices.forEach((notice) => {
        const coord = [notice.latitude, notice.longitude];
        bounds.push(coord);

        L.marker(coord).addTo(map).bindPopup(mapHTML(notice));
      });
      map.fitBounds(bounds);
    }
  }
}

class GClusterMap {
  constructor(canvas) {
    this.canvas = canvas[0];
    this.init = canvas.data('init');
    this.notices = canvas.data('notices');
  }

  show() {
    const map = initMap(this.canvas, [this.init.latitude, this.init.longitude], this.init.zoom);

    if (this.notices.length > 0) {
      const markers = L.markerClusterGroup();
      this.notices.forEach((notice) => {
        const marker = L.marker([notice.latitude, notice.longitude])
          .bindPopup(mapHTML(notice))
          .openPopup();
        markers.addLayer(marker);
      });
      map.addLayer(markers);
      map.fitBounds(markers.getBounds());
    }
  }
}

window.GMap = GMap;
window.GPickerMap = GPickerMap;
window.GMultiMap = GMultiMap;
window.GClusterMap = GClusterMap;
