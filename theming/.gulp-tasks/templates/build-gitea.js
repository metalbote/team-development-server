'use strict';

module.exports = function (gulp, callback) {
  return gulp.src(['templates/gitea/**/**.tmpl'])
      .pipe(gulp.dest('../services/gitea/templates'));
};
