#!/bin/bash
#
# A lot of this is based on options.bash by Daniel Mills.
# @see https://github.com/e36freak/tools/blob/master/options.bash

# Preamble {{{
version="$0 v0.1"

# Detect whether output is piped or not.
[[ -t 1 ]] && piped=0 || piped=1

# Defaults
force=0
quiet=0
verbose=0
interactive=0
files=()

# A list of all variables to prompt in interactive mode. These variables HAVE
# to be named exactly as the longname option definition in usage().
interactive_opts=(username password)


# Print usage
usage() {
  echo -n "$0 [OPTION]... [FILE]...

Description of this script.

 Options:
  -u, --username    Username for script
  -p, --password    Input user password, it's recommended to insert
                    this through the interactive option
  -f, --force       Skip all user interaction
  -i, --interactive Prompt for values
  -q, --quiet       Quiet (no output)
  -v, --verbose     Output more
  -h, --help        Display this help and exit
      --version     Output version information and exit
"
}

# }}}
# Helpers {{{

out() {
  ((quiet)) && return

  local message="$@"
  if ((piped)); then
    message=$(echo $message | sed '
      s/\\[0-9]\{3\}\[[0-9]\(;[0-9]\{2\}\)\?m//g;
      s/✖/Error:/g;
      s/✔/Success:/g;
    ')
  fi
  printf '%b\n' "$message";
}
die() { out "$@"; exit 1; } >&2
err() { out " \033[1;31m✖\033[0m  $@"; } >&2
success() { out " \033[1;32m✔\033[0m  $@"; }

# Verbose logging
log() { (($verbose)) && out "$@"; }

# Notify on function success
notify() { [[ $? == 0 ]] && success "$@" || err "$@"; }

# Escape a string
escape() { echo $@ | sed 's/\//\\\//g'; }

# Unless force is used, confirm with user
confirm() {
  (($force)) && return 1;

  read -p "$1 [Y/n] " -n 1;
  [[ $REPLY =~ ^[Yy]$ ]];
}

# }}}
# Boilerplate {{{

# Prompt the user to interactively enter desired variable values. 
prompt_options() {
  local desc=
  local val=
  for val in ${interactive_opts[@]}; do

    # Skip values which already are defined
    [[ $(eval echo "\$$val") ]] && continue

    # Parse the usage description for spefic option longname.
    desc=$(usage | awk -v val=$val '
      BEGIN {
        # Separate rows at option definitions and begin line right before
        # longname.
        RS="\n +-([a-zA-Z0-9], )|-";
        ORS=" ";
      }
      NR > 3 {
        # Check if the option longname equals the value requested and passed
        # into awk.
        if ($1 == val) {
          # Print all remaining fields, ie. the description.
          for (i=2; i <= NF; i++) print $i
        }
      }
    ')
    [[ ! "$desc" ]] && continue

    echo -n "$desc: "

    # In case this is a password field, hide the user input
    if [[ $val == "password" ]]; then
      stty -echo; read password; stty echo
      echo
    # Otherwise just read the input
    else
      eval "read $val"
    fi
  done
}

# Iterate over options breaking -ab into -a -b when needed and --foo=bar into
# --foo bar
optstring=h
unset options
while (($#)); do
  case $1 in
    # If option is of type -ab
    -[!-]?*)
      # Loop over each character starting with the second
      for ((i=1; i < ${#1}; i++)); do
        c=${1:i:1}

        # Add current char to options
        options+=("-$c")

        # If option takes a required argument, and it's not the last char make
        # the rest of the string its argument
        if [[ $optstring = *"$c:"* && ${1:i+1} ]]; then
          options+=("${1:i+1}")
          break
        fi
      done
      ;;
    # If option is of type --foo=bar
    --?*=*) options+=("${1%%=*}" "${1#*=}") ;;
    # add --endopts for --
    --) options+=(--endopts) ;;
    # Otherwise, nothing special
    *) options+=("$1") ;;
  esac
  shift
done
set -- "${options[@]}"
unset options

# }}}
# Main loop {{{

# Print help if no arguments were passed.
[[ $# -eq 0 ]] && set -- "--help"


# Read the options and set stuff
while [[ $1 = -?* ]]; do
  case $1 in
    -h|--help) usage >&2; exit 0 ;;
    -V|--version) out "$version"; exit 0 ;;
    -u|--username) shift; password=$1 ;;
    -p|--password) shift; password=$1 ;;
    -v|--verbose) verbose=1 ;;
    -q|--quiet) quiet=1 ;;
    -i|--interactive) interactive=1 ;;
    -f|--force) force=1 ;;
    --endopts) shift; break ;;
    *) die "invalid option: $1" ;;
  esac
  shift
done

# Append all arguments to the files array.
files+=("$@")

# }}}
# Let the logic begin! {{{

if ((interactive)); then
  prompt_options
fi

err "test"
success "oheo"

# }}}
