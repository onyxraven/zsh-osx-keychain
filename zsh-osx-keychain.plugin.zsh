### Functions for setting and getting environment variables from the OSX keychain ###
### Adapted from https://www.netmeister.org/blog/keychain-passwords.html ###
### and https://gist.github.com/bmhatfield/f613c10e360b4f27033761bbee4404fd ###

# Use: keychain-environment-variable SECRET_ENV_VAR
#   echos the value
function keychain-environment-variable() {
  if [ -z "$1" ]; then
    print "Missing environment variable name"
    return 1
  fi

  security find-generic-password -w -a ${USER} -D "environment variable" -s "${1}"
}

# Use: set-keychain-environment-variable [-m] [--no-env] SECRET_ENV_VAR
#   -m: multi-line mode (press Ctrl+D when done)
#   --no-env: don't add to .zshrc
#   default: single-line mode (press Enter when done), auto-add to .zshrc if new
#   uses hex encoding to bypass the 128-character limit
function set-keychain-environment-variable() {
  local multiline=false
  local add_to_env=true
  local name=""

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -m|--multiline)
        multiline=true
        shift
        ;;
      --no-env)
        add_to_env=false
        shift
        ;;
      *)
        name="$1"
        shift
        ;;
    esac
  done

  if [ -z "$name" ]; then
    print "Usage: set-keychain-environment-variable [-m] [--no-env] SECRET_ENV_VAR" >&2
    print "  -m: multi-line mode (for secrets with newlines)" >&2
    print "  --no-env: don't add to .zshrc" >&2
    return 1
  fi

  # Check if this is a new secret
  local is_new=false
  security find-generic-password -a ${USER} -D "environment variable" -s "${name}" >/dev/null 2>&1
  if [ $? -ne 0 ]; then
    is_new=true
  fi

  local secret
  if [ "$multiline" = true ]; then
    print "Paste your multi-line secret, then press Ctrl+D on a new line:" >&2
    secret=$(cat)
  else
    print "Paste your secret and press Enter:" >&2
    read -r secret
  fi

  local hex=$(echo -n "$secret" | xxd -p | tr -d '\n')
  security add-generic-password -U -a ${USER} -D "environment variable" -s "${name}" -X "${hex}"
  print "Secret stored successfully!" >&2

  # If new secret and add_to_env is true, add export to .zshrc
  if [ "$is_new" = true ] && [ "$add_to_env" = true ]; then
    local export_line="export ${name}=\"\$(get-secret ${name})\""
    local zshrc="${ZDOTDIR:-$HOME}/.zshrc"

    # Check if already in .zshrc
    if ! grep -q "export ${name}=" "$zshrc" 2>/dev/null; then
      echo "" >> "$zshrc"
      echo "# Auto-added by set-secret" >> "$zshrc"
      echo "$export_line" >> "$zshrc"
      print "\n✓ Added to .zshrc: $export_line" >&2
      print "  Run: source ~/.zshrc (or open a new terminal)" >&2
    fi
  fi
}

# Use: delete-keychain-environment-variable SECRET_ENV_VAR
function delete-keychain-environment-variable() {
  if [ -z "$1" ]; then
    print "Missing environment variable name"
    return 1
  fi

  security delete-generic-password -a ${USER} -D "environment variable" -s "${1}"
}
