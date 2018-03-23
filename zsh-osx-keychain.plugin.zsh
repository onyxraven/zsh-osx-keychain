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

# Use: set-keychain-environment-variable SECRET_ENV_VAR
#   security will prompt for the value
function set-keychain-environment-variable() {
  if [ -z "$1" ]; then
    print "Missing environment variable name"
    return 1
  fi

  security add-generic-password -U -a ${USER} -D "environment variable" -s "${1}" -w
}

# Use: delete-keychain-environment-variable SECRET_ENV_VAR
function delete-keychain-environment-variable() {
  if [ -z "$1" ]; then
    print "Missing environment variable name"
    return 1
  fi

  security delete-generic-password -a ${USER} -D "environment variable" -s "${1}"
}
