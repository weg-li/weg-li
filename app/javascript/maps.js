/* global google */
import MarkerClusterer from '@google/markerclustererplus';

let recentWindow;

function addInfoWindow(map, marker, notice) {
  if (!notice.token) {
    return;
  }
  google.maps.event.addListener(marker, 'click', () => {
    const content = `
    <div>
      <dl class="dl-horizontal">
        <dt>Datum</dt>
        <dd>${notice.date || '-'}</dd>
        <dt>Kennzeichen</dt>
        <dd>${notice.registration || '-'}</dd>
        <dt>Verstoß</dt>
        <dd>${notice.charge || '-'}</dd>
        <dt>Adresse</dt>
        <dd>${notice.full_address || '-'}</dd>
      </dl>
      <a href="/notices/${notice.token}" class="btn btn-default btn-sm pull-right">ansehen</a>
    </div>
    `;
    if (recentWindow) {
      recentWindow.close();
    }
    recentWindow = new google.maps.InfoWindow({ content });
    recentWindow.open(map, marker);
  });
}

class GMap {
  constructor(canvas) {
    this.canvas = canvas[0];
    this.notice = canvas.data('notice');
  }

  show() {
    const options = {
      zoom: 13,
      scrollwheel: false,
      streetViewControl: false,
      center: new google.maps.LatLng(this.notice.latitude, this.notice.longitude),
      mapTypeId: google.maps.MapTypeId.ROADMAP,
    };
    const map = new google.maps.Map(this.canvas, options);
    const position = new google.maps.LatLng(this.notice.latitude, this.notice.longitude);
    const marker = new google.maps.Marker({ position, map, title: this.notice.location });
    addInfoWindow(map, marker, this.notice);
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
    const options = {
      zoom: 18,
      scrollwheel: true,
      streetViewControl: false,
      disableDoubleClickZoom: true,
      center: new google.maps.LatLng(this.notice.latitude, this.notice.longitude),
      mapTypeId: google.maps.MapTypeId.ROADMAP,
    };
    const map = new google.maps.Map(this.canvas, options);

    const point = new google.maps.LatLng(this.notice.latitude, this.notice.longitude);
    const marker = new google.maps.Marker({
      point,
      map,
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
    const map = new google.maps.Map(this.canvas, {
      zoom: this.init.zoom,
      center: new google.maps.LatLng(this.init.latitude, this.init.longitude),

      scrollwheel: false,
      streetViewControl: false,
      mapTypeId: google.maps.MapTypeId.ROADMAP,
    });

    const bounds = new google.maps.LatLngBounds();
    this.notices.forEach((notice) => {
      const position = new google.maps.LatLng(notice.latitude, notice.longitude);
      bounds.extend(position);

      const options = { position, map, title: notice.charge };
      const marker = new google.maps.Marker(options);
      addInfoWindow(map, marker, notice);
    });

    if (!bounds.isEmpty()) {
      map.fitBounds(bounds);
      map.panToBounds(bounds);
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
    const options = {
      zoom: this.init.zoom,
      center: new google.maps.LatLng(this.init.latitude, this.init.longitude),
      scrollwheel: false,
      streetViewControl: false,
      mapTypeId: google.maps.MapTypeId.ROADMAP,
    };

    const bounds = new google.maps.LatLngBounds();
    const map = new google.maps.Map(this.canvas, options);
    const markers = this.notices.map((notice) => {
      const position = new google.maps.LatLng(notice.latitude, notice.longitude);
      bounds.extend(position);

      const marker = new google.maps.Marker({ position, title: notice.charge });
      addInfoWindow(map, marker, notice);
      return marker;
    });
    if (!bounds.isEmpty()) {
      map.fitBounds(bounds);
      map.panToBounds(bounds);
    }

    new MarkerClusterer(map, markers, { imagePath: '/img/map/m' });
  }
}

window.GMap = GMap;
window.GPickerMap = GPickerMap;
window.GMultiMap = GMultiMap;
window.GClusterMap = GClusterMap;
