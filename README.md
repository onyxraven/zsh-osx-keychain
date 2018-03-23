# zsh-osx-keychain

OSX keychain utilities for secure environment vars

So you have some values you need in your shell, but you know you shouldn't keep then in plaintext on disk.

## Usage

### Set a variable

```sh
set-keychain-environment-variable MY_SECRET_ENV
```

You will be prompted for the value (and a confirmation)

```text
password data for new item:
retype password for new item:
```

### Read a variable

To just see the value

```sh
keychain-environment-variable MY_SECRET_ENV
```

The function prints the value to stdout

```text
mysecret
```

To assign to a variable

```sh
MYVAR=$(keychain-environment-variable MY_SECRET_ENV)
```

You can do this as an `export` in your .zshrc, but it's not as recommended, since those stick around as plaintext in your `env`. It is better to create an alias or function wrapper for your use cases that need these secrets.

### Remove a variable

```sh
delete-keychain-environment-variable MY_SECRET_ENV
```

## Installation

### [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh)

1. `cd ~/.oh-my-zsh/custom/plugins` (you may have to create the folder)
1. `git clone https://github.com/onyxraven/zsh-osx-keychain.git`
1. In your .zshrc, add `zsh-osx-keychain` to your oh-my-zsh plugins:

  ```sh
  plugins=(
    # [...snip...]
    zsh-osx-keychain
  )
  ```

1. restart your shell

### [zgen](https://github.com/tarjoilija/zgen)

1. add `zgen load onyxraven/zsh-osx-keychain` to your '!saved/save' block
1. `zgen update`
1. restart your shell

## How it works

OSX is able to programmatically access keychain values using the `security` command. You can also see these keychain items (on your default keychain) via `Keychain Access.app`

## Inspiration / Source

The commands here were copied pretty closely from [this gist](https://gist.github.com/bmhatfield/f613c10e360b4f27033761bbee4404fd), with some explanation in [this blog post](https://www.netmeister.org/blog/keychain-passwords.html)
