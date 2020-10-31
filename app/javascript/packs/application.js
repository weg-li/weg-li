/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb


// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

// allow templates to use $
window.jQuery = window.$ = require('jquery');

// rails deps
require("@rails/ujs").start();
require("turbolinks").start();
require("@rails/activestorage").start();

// 3rdparty deps
require("lucia");
require("bootstrap");
require("select2");
require("jquery-zoom");
// allow templates to use Chartist
window.Chartist = require("chartist");

// own deps
require("appsignal");
require("custom");
require("direct_uploads");
require("maps");
require("styleguide");
