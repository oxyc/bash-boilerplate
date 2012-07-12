# Bash boilerplate

## Features

* Interactive mode
* CLI options parser supporting `-n --name --name=Oxy --name Oxy`
* Also supports bundling of flags. ie. `-vf` instead of `-v -f`
* Helper functions for printing messages.
* Colorized notify output if file descriptor is stdin.

## Functions

### Print functions

* `die()` Output message to stderr and exit with error code 1.
* `out()` Output message as a string.
* `err()` Output message to stderr but continue running.
* `success()` Output message as a string. Both `success` and `err` will output message with a colorized symbol, as long as the script isn't piped.
* `log()` Will only output message if user has activated verbose flag.
* `notify()` Delegate the message to either `err` or `success` depending on the last return code. *Remember this function needs to be called once a return code is available.* Eg.

  ```bash
  foobar; notify "foobar copied files"

  notify "foobar copied files" $(foobar)
  ```

### Misc helpers

* `escape()` Escape slashes in a string
* `confirm()` Prompt the user to answer Yes or No. *This will automatically return true if --force is used.* Eg.

  ```bash
  if ! confirm "Delete file"; then
    continue;
  fi
  ```

### Interactive mode

With this script comes a wtfmagic interactive mode which prompts the user to enter variables through stdin instead of the command line.

1. This works by first defining which variables should be prompted for in the `$interactive_opts` variable.

2. Making sure `usage` outputs valid information, where an options longname (eg. --password) has the same name as the variable in `interactive_opts`.

3. Once the script has parsed all variables supplied through the command line, it will iterate through the `interactive_opts` array and parse the usage file for the description (also supports multiline).

4. Now the user will be prompted and can enter the value through stdin. Note, if the variable is named password, interactive mode will automatically hide the input from prying eyes.

Once a script has many CLI options it becomes annoying to remember them all and this is when interactive mode shines. You can support both the scriptable CLI as well as a user friendly alternative for that one time per year when you actually need the script.

## Acknowledgment

* Daniel Mills, [options.bash](https://github.com/e36freak/tools/blob/master/options.bash)
