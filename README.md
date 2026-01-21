# zsh-osx-keychain

OSX keychain utilities for secure environment vars

So you have some values you need in your shell, but you know you shouldn't keep then in plaintext on disk.

## Usage

### Set a variable

```sh
set-keychain-environment-variable MY_SECRET_ENV
```

You will be prompted to paste your secret and press Enter. The secret can be any length (no 128-character limit):

```text
Paste your secret and press Enter:
Secret stored successfully!

✓ Added to .zshrc: export MY_SECRET_ENV="$(get-secret MY_SECRET_ENV)"
  Run: source ~/.zshrc (or open a new terminal)
```

**New secrets are automatically added to your `.zshrc`** so they're available as environment variables after reloading your shell. When you update an existing secret, only the keychain value is updated - no `.zshrc` changes needed.

#### Multi-line secrets

For secrets containing newlines (like private keys or certificates), use the `-m` flag:

```sh
set-keychain-environment-variable -m MY_PRIVATE_KEY
```

You'll be prompted to paste your multi-line secret and press Ctrl+D when done:

```text
Paste your multi-line secret, then press Ctrl+D on a new line:
[paste your multi-line secret]
^D
Secret stored successfully!
```

#### Skip auto-adding to .zshrc

If you don't want a secret automatically added to your `.zshrc`, use the `--no-env` flag:

```sh
set-keychain-environment-variable --no-env TEMP_SECRET
```

This is useful for temporary secrets or values you'll access manually.

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

### [zinit](https://github.com/zdharma-continuum/zinit)

Use it like other oh-my-zsh plugins.

```bash
zinit snippet https://github.com/onyxraven/zsh-osx-keychain/blob/main/zsh-osx-keychain.plugin.zsh
```

## How it works

OSX is able to programmatically access keychain values using the `security` command. You can also see these keychain items (on your default keychain) via `Keychain Access.app`

### Technical improvements

**Hex encoding for unlimited length:** The original macOS `security` command has a 128-character limit when using the `-w` prompt flag. This implementation uses hex encoding (via the `-X` flag) to bypass this limitation, allowing secrets of any length (tested up to 10,000+ characters). The hex encoding is transparent - retrieval automatically decodes the value.

**Auto-environment setup:** When setting a new secret, the plugin automatically adds an export statement to your `.zshrc` (or `$ZDOTDIR/.zshrc` if using XDG-style configuration). This means:
- New secrets are immediately available as environment variables after reloading your shell
- Rotating keys is simple: just run `set-keychain-environment-variable` again with the new value
- No manual editing of config files required

**Flexible input modes:** Single-line mode (press Enter) for most secrets, multi-line mode (`-m` flag, press Ctrl+D) for keys/certificates with newlines.

## Inspiration / Source

The commands here were copied pretty closely from [this gist](https://gist.github.com/bmhatfield/f613c10e360b4f27033761bbee4404fd), with some explanation in [this blog post](https://www.netmeister.org/blog/keychain-passwords.html)
