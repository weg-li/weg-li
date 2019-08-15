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
  }

  show() {
    const options = {
      zoom: 18,
      scrollwheel: true,
      streetViewControl: false,
      center: new google.maps.LatLng(this.notice.latitude, this.notice.longitude),
      mapTypeId: google.maps.MapTypeId.ROADMAP,
    }
    const map = new google.maps.Map(this.canvas, options);
    const position = new google.maps.LatLng(this.notice.latitude, this.notice.longitude);
    const marker = new google.maps.Marker({
      position,
      map,
      draggable: true,
      title: this.notice.location,
    });
    google.maps.event.addListener(marker, 'dragend', (event) => {
      const lat = event.latLng.lat();
      const lng = event.latLng.lng();
      console.log(lat, lng);
      var geocoder = new google.maps.Geocoder;
      geocoder.geocode({'location': { lat, lng }}, (results, status) => {
        if (status === 'OK') {
          if (results[0]) {
            const address = results[0].formatted_address;
            $(this.target).val(address);
          } else {
            window.alert('Es konnten keine Ergebnisse gefunden werden.');
          }
        } else {
          window.alert('Es ist ein Fehler aufgetreten: ' + status);
        }
      });
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
      zoom: this.init.zoom,
      scrollwheel: false,
      streetViewControl: false,
      center: new google.maps.LatLng(this.init.latitude, this.init.longitude),
      mapTypeId: google.maps.MapTypeId.ROADMAP,
    }
    const map = new google.maps.Map(this.canvas, options);
    this.notices.forEach((notice) => {
      const position = new google.maps.LatLng(notice.latitude, notice.longitude);
      new google.maps.Marker({position, map, title: notice.location});
    });
  }
}

window.GMap = GMap;
window.GPickerMap = GPickerMap;
window.GMultiMap = GMultiMap;
