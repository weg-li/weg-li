/* eslint no-console:0 */

// allow templates to use $
window.$ = require("jquery");
window.jQuery = window.$;

// rails deps
require("@rails/ujs").start();
require("@rails/activestorage").start();
// require("@hotwired/turbo-rails");

// 3rdparty deps
require("bootstrap");
require("alpinejs");

// allow templates to use billboard
window.bb = require("billboard.js/dist/billboard.js").bb;

// own sources
// require("./src/appsignal");
require("./src/custom");
require("./src/direct_uploads");
require("./src/maps");
require("./src/styleguide");
