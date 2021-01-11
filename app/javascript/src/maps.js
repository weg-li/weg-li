/* global google, L */
import MarkerClusterer from '@google/markerclustererplus';

let recentWindow;

function mapHTML(notice) {
  return `
    <dl>
      <dt>Datum</dt>
      <dd>${notice.date || '-'}</dd>
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

function addInfoWindow(map, marker, notice) {
  if (!notice.token) {
    return;
  }
  google.maps.event.addListener(marker, 'click', () => {
    const content = mapHTML(notice);
    if (recentWindow) {
      recentWindow.close();
    }
    recentWindow = new google.maps.InfoWindow({ content });
    recentWindow.open(map, marker);
  });
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

    L.marker([this.notice.latitude, this.notice.longitude]).addTo(map)
      .bindPopup(mapHTML(this.notice))
      .openPopup();
  }
}

class GPickerMap {
  constructor(canvas) {
    this.canvas = canvas[0];
    this.notice = canvas.data('notice');
    this.street = canvas.data('street');
    this.zip = canvas.data('zip');
    this.city = canvas.data('city');
    this.latitude = canvas.data('latitude');
    this.longitude = canvas.data('longitude');
    this.trigger = canvas.data('trigger');
  }

  show() {
    const point = new google.maps.LatLng(this.notice.latitude, this.notice.longitude);
    const map = new google.maps.Map(this.canvas, {
      zoom: 18,
      scrollwheel: true,
      streetViewControl: false,
      disableDoubleClickZoom: true,
      center: point,
      mapTypeId: google.maps.MapTypeId.ROADMAP,
    });

    const marker = new google.maps.Marker({
      map,
      position: point,
      draggable: true,
      title: this.notice.location,
    });

    const markerMoved = (event) => {
      const lat = event.latLng.lat();
      const lng = event.latLng.lng();

      const geocoder = new google.maps.Geocoder();
      geocoder.geocode({ location: { lat, lng } }, (results, status) => {
        if (status === 'OK') {
          if (results.length > 0) {
            const result = results.find((entry) => entry.types.includes('street_address')) || results.find((entry) => entry.address_components);
            if (result) {
              const location = Object.fromEntries(result.address_components.map((comp) => [comp.types[0], comp.long_name]));
              $(this.street).val(`${location.route || ''} ${location.street_number || ''}`.trim());
              $(this.zip).val(location.postal_code || '');
              $(this.city).val(location.locality || location.administrative_area_level_1 || location.political || '');
              $(this.latitude).val(lat);
              $(this.longitude).val(lng);
            } else {
              window.alert('Es konnten keine Ergebnisse gefunden werden.');
            }
          } else {
            window.alert('Es konnten keine Ergebnisse gefunden werden.');
          }
        } else {
          window.alert(`Es ist ein Fehler aufgetreten: ${status}`);
        }
      });
    };

    google.maps.event.addListener(map, 'dblclick', (event) => {
      marker.setPosition(event.latLng);
      markerMoved(event);
    });

    google.maps.event.addListener(marker, 'dragend', markerMoved);

    $(window.document).on('click', this.trigger, () => {
      if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition((position) => {
          const pos = {
            lat: position.coords.latitude,
            lng: position.coords.longitude,
          };

          map.setCenter(pos);
          marker.setPosition(pos);
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

    const bounds = [];
    this.notices.forEach((notice) => {
      const coord = [notice.latitude, notice.longitude];
      bounds.push(coord);

      L.marker(coord).addTo(map)
        .bindPopup(mapHTML(notice))
        .openPopup();
    });
    map.fitBounds(bounds);
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

window.GMap = GMap;
window.GPickerMap = GPickerMap;
window.GMultiMap = GMultiMap;
window.GClusterMap = GClusterMap;
