An example of a Meteor package using a provided input file.

Note:

1. I used `npm install upper-case' to install the module into a *node_modules* directory. This module will be included in the browserified file by default. Meteor's build tool ignores the *node_modules* directory.
2. There *is* an *entry file* for Browserify in the default location *node_modules/browserify.js*.
3. There is no options file because all the defaults are good enough.
4. The generated file is *package.browserified.js* and is added to the package in its *package.js* file.
5. The result only contains *upper-case* and not *reverse-string* because the input file doesn't require it.
