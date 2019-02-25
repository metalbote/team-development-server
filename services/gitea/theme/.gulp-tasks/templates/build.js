'use strict';

module.exports = function (gulp, callback) {
  return gulp.src(['templates/**/**.tmpl'])
      .pipe(gulp.dest('../templates'));
};
