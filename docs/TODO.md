# Future Features

1. add command option to save the info provided to the cli in an options file (essentially generate an options file so calling `bonce` will repeat the same command)
2. add command option to save the generated input to a file
3. add command option to run `npm install` to install the specified modules into `node_modules` (avoid having to call `npm install` yourself before calling bonce). Should work for modules specified in an options file. (To avoid requiring the `npm` module I'll likely make a system call to use the already installed `npm` command)
4. ensure the above npm install stuff allows a dev to easily install the npm modules after pulling down a project's source
