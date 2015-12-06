Package.describe({
  name: 'with-options',
  version: '1.0.0',
  summary: 'Sample package using bonce to make its browserified file.',
  git: '',
  documentation: 'README.md'
});

// Note:
//  there's no Npm.depends() because we don't want Meteor to get the modules
//  because we don't want them in the published package.

Package.onUse(function(api) {
  api.versionsFrom('1');
  api.addFiles([
    'package.browserified.js'  // this is the file created by bonce
  ], 'client');

  api.export('upperCase', 'client');
});

Package.onTest(function(api) {
  api.use('tinytest');
  api.use('with-options');
});
