# property

A tiny Bash script to get OS and other software version information.

TODO: GIF here

## TOC

TODO: Add TOC here

## TL;DR

TODO: Here's a summary you can read in 30 seconds.

## Documentation for user

NOTE: These are documents to my future self.

### Purpose of this project

**For my own use**

NOTE: So, I will only support environments and software that I use frequently.

### Supported environment

Linux (especially Debian-Based Linux, but more specifically Ubuntu, Mint, and Kali)

TODO: Support more environment (OS) ...

### Supported softwares

zsh,tmux,

TODO:

### Installation

#### Using Script (recommended)

If you want to install property command under `~/bin/`,
run commands on your terminal like:

```console
$ DEST_DIR="~/bin"

$ cd /tmp && \
    curl -O https://raw.githubusercontent.com/rnazmo/property/main/install.sh && \
    chmod +x ./install.sh && \
    ./install.sh "$DEST_DIR"
```

#### Manually

1. Download `property` file from GitHub's raw page, **specifying any version** (Use a link like [this](https://raw.githubusercontent.com/rnazmo/property/v0.0.1/property) one.)
2. Add the file to the environment PATH (optional)
3. Add execute permission (like `chmod +x ./property`)
4. Run (like `./property`)

```console
$ DEST_DIR="${HOME}/bin"

$ VERSION="v0.0.1"

$ cd "$DEST_DIR" && \
    curl -O https://raw.githubusercontent.com/rnazmo/property/"$VERSION"/property && \
    chmod +x ./property

$ ./property
property v0.0.1 - A tiny Bash script to get OS and other
software version info. https://github.com/rnazmo/property
============================================================
OS NAME     : Kali GNU/Linux Rolling
OS VERSION  : 2021.1
Bash VERSION: 5.1.4(1)-release (x86_64-pc-linux-gnu)
CPU ARCH    : x86-64
KERNEL      : Linux 5.10.0-kali4-amd64
CHASSIS     : vm
============================================================
```

### Using without installation

Just run commands like the following in your terminal.

```console
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/rnazmo/property/v0.0.1/property)"
```

### How to bump a version of my 'property'

1. Delete you old `property` file.
2. Install a new version of 'property'. (See [Installation](https://github.com/rnazmo/property#installation) section.)

### Examples

TODO:

### Notes

#### Do not download (install) 'property' without specifying the version

TL;DR: **Use `install.sh`**. Or Download `property` file directly **with specifying a version**

Don't download 'property' (this indicates 'property' as the file) directly from the `main` branch,
but download it directly using a tag such as "v0.0.1".

Or, I highly recommend you to download 'property' (this indicates 'property' as the file) via `install.sh`.
If you download `install.sh`, it is also allowed from the `main` branch.

If you do not specify the version (for example, if you download 'property' (this indicates 'property' as the file) directly from `main` branch),
the version information of 'property' (this indicates 'property' as the project) itself in the output of the `property` (this 'property' means as the file) command can be incorrect.

e.g.,

```console
# BAD:
$ curl -O "https://raw.githubusercontent.com/rnazmo/property/main/property"
```

```console
# GOOD:
$ curl -O "https://raw.githubusercontent.com/rnazmo/property/v0.0.1/property"
```

I highly recommend you to use `install.sh` to avoid these mistakes.

```console
# GOOD (Recommend)
$ DEST_DIR="~/bin"
$ cd /tmp && \
    curl -O https://raw.githubusercontent.com/rnazmo/property/main/install.sh && \
    chmod +x ./install.sh && \
    ./install.sh "$DEST_DIR"
```

## Documentation for developer

NOTE: These are documents to my future self.

### Policies

- Simple usage (≒ option)
- Simple code
  - Tiny size
  - Minimum dependencies
- Simple documentation
  - Avoid writing important information in Issues / Pull requests. (Because it is difficult to search/maintain).
- Easy to maintain
  - Support only environment/software that I use frequently

### Conventions

TODO: それぞれが "SHALL" なのか、"SHOULD" なのかを明記する。

#### Versioning

Follow semantic versioning.

#### Branch

- 管理が面倒なので、「main」だけとする。(SHOULD)
- 「すぐに消すプルリク用の機能追加ブランチ」は作ってもよい。(SHOULD)

#### Commit message

特にルールは設けない。てきとうに。

#### Issues / Pull requests

Avoid writing important information in Issues / Pull requests. (Because it is difficult to search/maintain).

#### Issue / Pull request title

特にルールは設けない。てきとうに。

#### Documentation

Although not preferred, it is okay to have a mixture of English and Japanese
(since the target reader of this document is my future self)

#### Code Style for Bash Script (Lint, Format)

shellcheck, shfmt に従う。

Ref:

[Shell scripting standards and style guidelines | GitLab](https://docs.gitlab.com/ee/development/shell_scripting_guide/#code-style-and-format)

[styleguide | Style guides for Google-originated open-source projects](https://google.github.io/styleguide/shellguide.html)

[koalaman/shellcheck: ShellCheck, a static analysis tool for shell scripts](https://github.com/koalaman/shellcheck)

[mvdan/sh: A shell parser, formatter, and interpreter with bash support; includes shfmt](https://github.com/mvdan/sh)

#### Force push to the remote repo

すべきではないが、(どうしても仕方がない場合のみ) 許可する。(対象ユーザーが自分のみなので)

### How to bump a version (versioning workflow)

0. (We edited `property` locally)
1. Create a commit for the changes with any commit message.
2. Bump a version of `VERSION="v0.0.X"` in `property` and `install.sh`. (Don't forget to follow semantic versioning!)
3. Create a commit for the change with the commit message (like `Bump a version to v0.0.3`)
4. Tag the commit (like `$ git tag v0.0.3`)
5. Push the changes (like `$ git push`)
6. Push the tag changes (like `$ git push --tags` or `$ git push origin v0.0.3`)

### TODO

- Add `Makefile`
- Add support for following softwares
  - `<command_name>:<print_version_command>, ...`のようなリストを作っておき(bash script 内に直接書いてしまう？でも Bash は Map をサポートしてないから面倒かも？toml で書けたら楽なのだけど...)、`<command_name>`のリストをオプションとして受け取る (like `--"go,nmap,gobuster"`) とか。
- Add support for options
- Add support for following OS
  - Should I rewrite with Golang?
- Add 'pre-commit' (lint)
  - Run shellcheck to /property (like `$ shellcheck ./property`)
  - Run shfmt /property (like `$ shfmt -l -w`)
  - Use GitHub Action CI and run lint
- Refine README.md (内容が重複しているところとかある)
- `install.sh` がある理由を書いておく
  - これを使うと常に同じコマンドで最新版をインストールできる。使わない場合、明示的にバージョンを指定しなければならなくて面倒。(特に、別のスクリプト中で 'property' をインストールする場合、バージョン管理しなくてはならず面倒)
  - [ref](#do-not-download-install-property-without-specifying-the-version)

#### List of OS to be supported

Unix (macOS), **Windows**, VM (WSL2), VM (Docker), ...

#### List of software to be supported

vim: vim --version

nvim: nvim --version

curl:

wget

nmap

hydra

golang, python, ruby

etc...
