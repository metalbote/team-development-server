'use strict';

module.exports = function (gulp, callback) {
  return gulp.watch(['scss/**/*.scss'], ['styles:build-scss'], function () {
  });
};
