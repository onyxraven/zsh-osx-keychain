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
    # sentinel newline is always appended during encode to force security -w to return hex.
    security find-generic-password -w -a "${USER}" -D "environment variable" -s "$1" | perl -e 'local $/; my $h = <STDIN>; $h =~ s/\s+\z//; my $d = pack("H*", $h); $d =~ s/\n\z//; print $d'
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
  # remove recognized options from $@; errors on unknown flags. though, flags following the name are not handled well.
  zparseopts -D -F -a opts m -long || {
    print "Usage: set-keychain-environment-variable [-m|--long] NAME" >&2
    return 1
  }

  if [[ -z "$1" ]]; then
    print "Usage: set-keychain-environment-variable [-m|--long] NAME" >&2
    return 1
  fi

  local value
  if [[ -t 0 ]]; then
    # if we are in a terminal, prompt
    if ((${#opts})); then
      print "Enter value for $1 (end with EOF / Ctrl-D):"
      value=$(
        cat
        printf .
      )
      value=${value%.}
    else
      read -rs "value?Enter value for $1: "
      print
    fi
  else
    # get from stdin
    value=$(
      cat
      printf .
    )
    value=${value%.}
  fi

  # if the string is longer than 1m characters, it doesn't work with this
  if ((${#value} > 1000000)); then
    print "Value is too longfor this utility" >&2
    exit 1
  fi

  # if the string has newlines or told multiline, use the hex encoding method
  # always append a sentinel newline so security -w returns hex (it decodes clean text otherwise)
  if [[ "$value" == *$'\n'* ]] || ((${#opts})); then
    local hex
    hex=$(printf '%s\n' "$value" | perl -e 'local $/; print unpack("H*", <STDIN>)')
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
