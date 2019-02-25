'use strict';

const gulp = require('gulp'),
    fs = require('fs'),
    runSequence = require('run-sequence').use(gulp),
    gulpRequireTasks = require('gulp-require-tasks');

gulpRequireTasks({
  path: process.cwd() + '/.gulp-tasks'
});


gulp.task('default', ['watch']);

gulp.task(
    'watch', [
      'images:watch',
      'styles:watch',
    ]
);

gulp.task('clean', function (callback) {
  runSequence(
      [
        'images:clean',
        'styles:clean',
      ],
      callback);
});

gulp.task('build', function (callback) {
  runSequence('clean',
      [
        'images:build',
        'styles:build',
      ],
      callback);
});
