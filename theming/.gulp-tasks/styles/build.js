'use strict';

const gulp = require('gulp'), // might be a different instance than the toplevel one
    // this uses the gulp you provide
    runSequence = require('run-sequence').use(gulp);

module.exports = function (gulp, callback) {
  return runSequence('styles:build-scss', 'styles:copy');
};
