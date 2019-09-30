//= require @google/markerclusterer/src/markerclusterer

class GMap {
  constructor(canvas) {
    this.canvas = canvas[0];
    this.notice = canvas.data("notice");
  }

  show() {
    const options = {
      zoom: 13,
      scrollwheel: false,
      streetViewControl: false,
      center: new google.maps.LatLng(this.notice.latitude, this.notice.longitude),
      mapTypeId: google.maps.MapTypeId.ROADMAP,
    }
    const map = new google.maps.Map(this.canvas, options);
    const position = new google.maps.LatLng(this.notice.latitude, this.notice.longitude);
    new google.maps.Marker({position, map, title: this.notice.location});
  }
}

class GPickerMap {
  constructor(canvas) {
    this.canvas = canvas[0];
    this.notice = canvas.data("notice");
    this.target = canvas.data("target");
    this.trigger = canvas.data("trigger");
    this.map = null;
    this.marker = null;
  }

  show() {
    const options = {
      zoom: 18,
      scrollwheel: true,
      streetViewControl: false,
      center: new google.maps.LatLng(this.notice.latitude, this.notice.longitude),
      mapTypeId: google.maps.MapTypeId.ROADMAP,
    }
    this.map = new google.maps.Map(this.canvas, options);
    const position = new google.maps.LatLng(this.notice.latitude, this.notice.longitude);
    this.marker = new google.maps.Marker({
      position,
      map: this.map,
      draggable: true,
      title: this.notice.location,
    });
    google.maps.event.addListener(this.marker, 'dragend', (event) => {
      const lat = event.latLng.lat();
      const lng = event.latLng.lng();
      console.log(lat, lng);
      var geocoder = new google.maps.Geocoder;
      geocoder.geocode({'location': { lat, lng }}, (results, status) => {
        if (status === 'OK') {
          if (results.length > 0) {
            const result = (results.filter(result => result.types.includes('street_address')) || results)[0];
            $(this.target).val(result.formatted_address);
          } else {
            window.alert('Es konnten keine Ergebnisse gefunden werden.');
          }
        } else {
          window.alert('Es ist ein Fehler aufgetreten: ' + status);
        }
      });
    });
    $(window.document).on('click', this.trigger, () => {
      if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition((position) => {
          var pos = {
            lat: position.coords.latitude,
            lng: position.coords.longitude
          };

          this.map.setCenter(pos);
          this.marker.setPosition(pos);
        }, (error) => {
          console.log('error getting current location', error);
        });
      } else {
        window.alert('Der Browser unterstützt keine Geolocation')
      }
    });
  }
}

class GMultiMap {
  constructor(canvas) {
    this.canvas = canvas[0];
    this.init = canvas.data("init");
    this.notices = canvas.data("notices");
  }

  show() {
    const options = {
      scrollwheel: false,
      streetViewControl: false,
      mapTypeId: google.maps.MapTypeId.ROADMAP,
    }

    const bounds  = new google.maps.LatLngBounds();
    const map = new google.maps.Map(this.canvas, options);
    this.notices.forEach((notice) => {
      const position = new google.maps.LatLng(notice.latitude, notice.longitude);
      bounds.extend(position);

      new google.maps.Marker({ position, map, title: notice.charge });
    });
    if (bounds.length > 0) {
      map.fitBounds(bounds);
      map.panToBounds(bounds);
    } else {
      map.setCenter(new google.maps.LatLng(this.init.latitude, this.init.longitude));
      map.setZoom(this.init.zoom);
    }
  }
}

class GClusterMap {
  constructor(canvas) {
    this.canvas = canvas[0];
    this.init = canvas.data("init");
    this.notices = canvas.data("notices");
  }

  show() {
    const options = {
      scrollwheel: false,
      streetViewControl: false,
      mapTypeId: google.maps.MapTypeId.ROADMAP,
    }

    const bounds  = new google.maps.LatLngBounds();
    const map = new google.maps.Map(this.canvas, options);
    const markers = this.notices.map((notice, i) => {
      const position = new google.maps.LatLng(notice.latitude, notice.longitude);
      bounds.extend(position);

      return new google.maps.Marker({ position, title: notice.charge });
    });
    if (bounds.length > 0) {
      map.fitBounds(bounds);
      map.panToBounds(bounds);
    } else {
      map.setCenter(new google.maps.LatLng(this.init.latitude, this.init.longitude));
      map.setZoom(this.init.zoom);
    }

    new MarkerClusterer(map, markers, {imagePath: '/img/map/m'});
  }
}

window.GMap = GMap;
window.GPickerMap = GPickerMap;
window.GMultiMap = GMultiMap;
window.GClusterMap = GClusterMap;
