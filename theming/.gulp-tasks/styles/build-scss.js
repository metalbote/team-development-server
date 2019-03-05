'use strict';

const autoprefixer = require('gulp-autoprefixer'),
    cssmin = require('gulp-clean-css'),
    gulpif = require('gulp-if'),
    flatten = require('gulp-flatten'),
    plumber = require('gulp-plumber'),
    sass = require('gulp-sass'),
    sourcemaps = require('gulp-sourcemaps'),
    stripCssComments = require('gulp-strip-css-comments'),
    tildeImporter = require('node-sass-tilde-importer');

const buildSourceMaps = true;

module.exports = function (gulp, callback) {
  return gulp.src(['scss/**/**.scss'])
      .pipe(plumber())
      .pipe(gulpif(buildSourceMaps, sourcemaps.init()))
      .pipe(gulpif(buildSourceMaps, sourcemaps.identityMap()))
      .pipe(
          sass({
            includePaths: ['node_modules'],
            importer: tildeImporter,
            outputStyle: 'compressed',
            precision: 10,
          }).on('error', sass.logError))
      .pipe(autoprefixer({
        browsers: ['last 2 versions', 'ie >= 9'],
        cascade: true
      }))
      .pipe(cssmin())
      .pipe(gulpif(buildSourceMaps, sourcemaps.write()))
      .pipe(flatten())
      .pipe(gulp.dest('css'));
};
