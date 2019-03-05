'use strict';

module.exports = function (gulp, callback) {
  return gulp.src(['css/**/**.css'])
      .pipe(gulp.dest('../services/gitea/public/css'));
};
