module.exports = {
  "(app|config|lib|test)/**/*.rb": (files) =>
    `bundle exec rubocop ${files.join(" ")}`,
  "./**/*.md": ["prettier -c"],
  "./**/*.js": ["prettier -c", "eslint"],
  "./**/*.scss": ["prettier -c"],
};
