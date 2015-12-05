# BONCE
[![Build Status](https://travis-ci.org/elidoran/node-bonce.svg?branch=master)](https://travis-ci.org/elidoran/node-bonce)
[![Dependency Status](https://gemnasium.com/elidoran/node-bonce.png)](https://gemnasium.com/elidoran/node-bonce)
[![npm version](https://badge.fury.io/js/bonce.svg)](http://badge.fury.io/js/bonce)

Browserify npm modules once for a Meteor package. Avoids a published package rebrowserifying a file which is always the same because the npm modules are set at a fixed version. It generates the file for the package and makes that one file part of the published package so it is never rebuilt.

When I made the Meteor build plugin *cosmos:browserify* I expected it to make the browserified file during package publishing and then just *use it* for an app. Instead, published packages retain their originals and build along with the app they're added to (there are benefits to this, just not for this use case).

This cli tool makes it easy to generate a browserified file for a package to use without rebuilds. When you want to update it, you use *npm* to update the modules and then rerun *bonce* to generate a new file. Then, publish a new version of your package which has the new file.

Although Meteor's 1.2 Build API provides a caching feature which avoids many browserify operations this cli makes it possible to avoid 100% of *rebrowserifying*. When a package is added to an app via `meteor add user:package` it will contain the already browserified file and will never be rebuilt.

Note: It's possible to learn to use the Browserify CLI directly and do all this, and more, with it. I'm making *bonce* function specifically for making a file for a Meteor package with reasonable (helpful) defaults. For common simple use it only requires you type *bonce* and then add the resulting file to your *package.js* file.

## Install

```sh
npm install -g bonce
```


## Usage: Basic

Minimal steps using defaults for common case:

1. install *bonce* globally
2. move into your meteor package's directory
3. install some npm modules into *node_modules*
4. use *bonce* to browserify the installed modules into a single file

To update the npm modules and generate a new browserified file repeat the same steps, except #1, of course.

```sh
npm install -g bonce
cd yourPackage
npm install some-module another-module
bonce
; same as:
bonce . package.browserified.js node_modules/options.json some-module#someModule another-module#anotherModule
```


## Command:

`bonce [-q | --quiet] [dir with node_modules] [*browserify.js] [*.js] [*.json] [not] [moduleName[/subpath][#varName]]*`

All options are optional and the order you specify them is irrelevant.


#### Command Options: Ordering

The order doesn't matter because it can figure them out by looking at them. Only one option is a directory, two are JS files, but, the input file should have *browserify.js* in its tail, one is a JSON file, and the others are module names (or the `not` inverter).


#### Command Options: Root Directory (basedir)

This is the directory with the *node_modules*.

By default, *bonce* uses the present working directory, '.', as the basedir.


#### Command Options: Input File

You can avoid providing an input file. Read on, and, read [Specifying Modules](#command-options-specifying-modules).

By default, *bonce* will look for an input file at *node_modules/browserify.js*. So, when the input file has that name it doesn't need to be specified on the command line or in the options file.

The *cosmos:browserify* build tool expects an input file where variables and require statements are specified. This is passed to Browserify as the *entry file*. Although this is possible with *bonce* it can be avoided.

1. by default each installed module will be required and assigned to a variable created from the module's name. It will remove invalid characters from the module name and convert to camel case. For example, module *upper-case* becomes `upperCase`.
2. you may specify the name of the variable by naming the module to require in the command, or the options file. Put a `#` symbol after the name of the module and then the name of the variable. For example, to require the *upper-case* module and assign it to a variable named `toUpperCase` use: `upper-case#toUpperCase`.

If you still want to specify an input file simply put the path to the file in the command, or options file, and ensure the name ends with 'browserify.js' (that can be the whole name). If you want the file to be in your Meteor package directory (makes sense) then it must be hidden from the Meteor build tool by placing the file inside the top of *node_modules* directory.


#### Command Options: Output File

This is the browserified result to add to your *package.js* file.

By default, the browserified result is written to a file at `<basedir>/package.browserified.js`.

Or, specify its name and where to put it in the command or the options file with a name ending with '.js' and *not* 'browserify.js' (that's the input file option's tail).


#### Command Options: Options File

To provide advanced options, and make the command easily repeatable as just *bonce*, you may specify an options file.

By default, *bonce* will look for an options file at `node_modules/options.json`.

Placing the options file in your package will cause Meteor's build tool to complain about its existence. A simple workaround for that is to place the options file in the root of the *node_modules* directory. Meteor ignores that directory and the file being there won't affect npm using the *node_modules* directory.

The options file is a JSON file. The *bonce* command assumes a path to a JSON file is the options file.


#### Command Options: Specifying Modules

By default, *bonce* will browserify all modules in the *node_modules* directory. It exports them to variables created from the module name as described below.

You can specify names to limit which modules are browserified. The name has 3 possible parts:

    <module name>/<subpath>#variableName

1. first, is the npm module name. it must match the name of the module installed into *node_modules*
2. second, you may optionally specify a subpath into the module, for example: `some-module/subpath`.
3. third, you may optionally specify the name of the variable to export the module to. by default it will convert the module name to a valid variable name, for example, 'upper-case' becomes 'upperCase'.

Instead of specifying the modules to include, you may specify the modules to *exclude* by putting `not` before the names of modules. For example:

```sh
bonce not some-module
```


#### Command Options: Quiet

bonce outputs the options it's using and a success message unless you specify `quiet` via the short or long option (-q, --quiet).


#### Command Options: Show Generated Input

When bonce generates an input file for Browserify you may want to see it. Specify the option (-g, --showgen) and bonce will print it out to the console for you.


#### Command Options: Directly passing options to Browserify cli

*bonce* will pass all arguments after *--* to the Browserify cli. For example, telling it to use transform *foo*:

```sh
bonce -- -r some-module -t some-transform
```


## Why name it bonce ?

I wanted something related to the phrase *browserify once* and `bonce` wasn't used in the npm registry.


### MIT License
