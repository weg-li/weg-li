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
window.GMultiMap = GMultiMap;
