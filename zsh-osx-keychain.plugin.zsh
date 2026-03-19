### Functions for setting and getting environment variables from the macOS keychain ###
### Adapted from https://www.netmeister.org/blog/keychain-passwords.html ###
### and https://gist.github.com/bmhatfield/f613c10e360b4f27033761bbee4404fd ###
### ref: https://www.dssw.co.uk/reference/security/ ###

# Use: keychain-environment-variable SECRET_ENV_VAR
#   prints the value to stdout
function keychain-environment-variable() {
  if [[ -z "$1" ]]; then
    print "Missing environment variable name" >&2
    return 1
  fi

  # check that keychain item exists and what its "type"<uint32>="value" is
  # backwards compatibility: if "type" is not set, assume it's a text string
  local type
  type=$(security find-generic-password -a "${USER}" -D "environment variable" -s "$1" -g 2>&1 1>/dev/null |
    awk -F= '/"type"/{print $2}')

  case "$type" in
  '"txts"' | '""' | '"text"' | '<NULL>')
    security find-generic-password -w -a "${USER}" -D "environment variable" -s "$1"
    ;;
  '"hexs"')
    security find-generic-password -w -a "${USER}" -D "environment variable" -s "$1" | xxd -r -p
    ;;
  *)
    print "No environment variable found in keychain for $1" >&2
    return 1
    ;;
  esac
}

# Use: set-keychain-environment-variable [-m|--long] SECRET_ENV_VAR
#   prompts for or reads the value from stdin
function set-keychain-environment-variable() {
  local -a opts
  # delete recognized options, dont error, store options in $opts, recognize -m and --long
  # we simplify below and detect any options were added by checking the array length
  zparseopts -D -E -a opts m -long

  if [[ -z "$1" ]]; then
    print "Missing environment variable name" >&2
    return 1
  fi

  local value
  if [[ -t 0 ]]; then
    # if we are in a terminal, prompt
    if ((${#opts})); then
      print "Enter value for $1 (end with EOF / Ctrl-D):"
      value=$(cat)
    else
      read -rs "value?Enter value for $1: "
      print
    fi
  else
    # get from stdin
    value=$(cat)
  fi

  # if the string has newlines or is longer than 128 characters, or told multiline, use the hex encoding method
  if [[ "$value" == *$'\n'* ]] || ((${#value} > 128)) || ((${#opts})); then
    local hex
    hex=$(printf '%s' "$value" | xxd -p | tr -d '\n')
    security add-generic-password -U -a "${USER}" -D "environment variable" -s "$1" -X "$hex" -C "hexs"
  else
    security add-generic-password -U -a "${USER}" -D "environment variable" -s "$1" -w "$value" -C "txts"
  fi
}

# Use: delete-keychain-environment-variable SECRET_ENV_VAR
function delete-keychain-environment-variable() {
  if [[ -z "$1" ]]; then
    print "Missing environment variable name" >&2
    return 1
  fi

  security delete-generic-password -a "${USER}" -D "environment variable" -s "$1"
}
