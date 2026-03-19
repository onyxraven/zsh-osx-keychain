# zsh-osx-keychain

macOS keychain utilities for secure environment vars

So you have some values you need in your shell, but you know you shouldn't keep them in plaintext on disk.

## Usage

### Set a variable

```sh
set-keychain-environment-variable MY_SECRET_ENV
```

You will be prompted for the value (input is hidden).

```text
Enter value for MY_SECRET_ENV:
```

#### Long or multiline values

Use `-m` (or `--long`) to enter multiline values interactively, terminated by EOF (Ctrl-D):

```sh
set-keychain-environment-variable -m MY_LONG_SECRET
```

#### Pipe from stdin

You can also pipe a value directly:

```sh
echo "my-secret-value" | set-keychain-environment-variable MY_SECRET_ENV
cat cert.pem | set-keychain-environment-variable MY_CERT
```

#### Hex encoding

Values are stored as plain text by default. If the value contains newlines, is longer than 128 characters, or the `-m`/`--long` flag is used, the value is automatically hex-encoded in the keychain. Reading transparently handles both formats. (It uses the "type" attribute in keychain to determine how to decode the value on read.)

### Read a variable

To just see the value, the `keychain-environment-variable` function reads the value from the keychain and prints it to stdout.

```sh
keychain-environment-variable MY_SECRET_ENV
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

### [zinit](https://github.com/zdharma-continuum/zinit)

Use it like other oh-my-zsh plugins.

```bash
zinit snippet https://github.com/onyxraven/zsh-osx-keychain/blob/main/zsh-osx-keychain.plugin.zsh
```

## How it works

macOS is able to programmatically access keychain values using the `security` command. You can also see these keychain items (on your default keychain) via `Keychain Access.app`.

Short values (≤128 chars, no newlines) are stored as plain text (`-w` flag, type `txts`). Longer or multiline values are hex-encoded (`-X` flag, type `hexs`) and decoded transparently on read via `xxd`.

## Inspiration / Source

The commands here were copied pretty closely from [this gist](https://gist.github.com/bmhatfield/f613c10e360b4f27033761bbee4404fd), with some explanation in [this blog post](https://www.netmeister.org/blog/keychain-passwords.html)
