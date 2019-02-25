'use strict';

const clean = require('gulp-clean');

module.exports = function (gulp, callback) {
  return gulp.src(
    [
      '../public/img'
    ], {read: false})
    .pipe(clean({force: true}));
};
