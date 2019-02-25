'use strict';

const imagemin = require('gulp-imagemin'),
  flatten = require('gulp-flatten');

module.exports = function (gulp, options) {

  return gulp.src('img/**/*.{jpg,jpeg,gif,png,svg}')
    .pipe(imagemin({
      progressive: true,
      interlaced: true,
      svgoPlugins: [{
        cleanupIDs: false,
        removeViewBox: false,
        removeUselessStrokeAndFill: false,
        removeXMLProcInst: false
      }]
    }))
    .pipe(flatten())
    .pipe(gulp.dest('../public/img'))
};
