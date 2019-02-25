'use strict';

module.exports = function (gulp, callback) {
  return gulp.watch('templates/**/*.tmpl', ['templates:build']);
};
