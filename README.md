# property

A tiny Bash script to get OS and other software version information.

## TOC

TODO: Add TOC here

## TL;DR

TODO: Here's a summary you can read in 30 seconds.

## Documentation for user

Note: These are notes to my future self.

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

1. Download latest from the [github's raw page](https://github.com/rnazmo/property/blob/main/property) (or, release page for specific version)
2. Add the file to the environment PATH (optional)
3. Add execute permission (like `chmod +x ./property`)
4. Run (like `property`)

#### Example commands

```console
$ DEST_DIR="${HOME}/bin" # The directory you want to download the file
$ cd "$DEST_DIR"

$ curl -O "https://raw.githubusercontent.com/rnazmo/property/main/property"

$ chmod +x ./property

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

```console
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/rnazmo/property/main/property)"                     
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

### How to bump a version of my 'property'

TODO: delete old version and re-install it?

### Examples

TODO:

## Documentation for developper

Note: These are notes to my future self.

### Policies

- Since this only provide a very simple function, I want to keep the code, usage (≒ option), and documentation very simple.
- Avoid writing important information in Issues / Pull requests. (Because it is difficult to search).

### Conventions

#### Versioning

Follow semantic versioning.

#### Branch management

管理が面倒なので、「main」と「すぐに消すプルリク用の機能追加ブランチ」以外は作らない

#### Commit message

特にルールは設けない。てきとうに。

#### Issue / Pull request title

特にルールは設けない。てきとうに。

#### Documentation

Although not preferred, it is okay to have a mixture of English and Japanese
(since the target reader of this document is my future self)

#### Code (Bash Script)

shellcheck, shfmt に従うものとする。

#### Force push to the remote repo

(どうしても仕方がない場合のみ) 許可する。(対象ユーザーが自分のみなので)

### How to bump a version (versioning workflow)

TODO:

### Todo

- Add .editorconfig
- Add Makefile
- Add support for following softwares
  - `<command_name>:<print_version_command>, ...`のようなリストを作っておき(bash script 内に直接書いてしまう？でも Bash は Map をサポートしてないから面倒かも？toml で書けたら楽なのだけど...)、`<command_name>`のリストをオプションとして受け取る (like `--"go,nmap,gobuster"`) とか。
- Add support for options
- Add support for following OS
  - Should I rewrite with Golang?
- Add 'pre-commit' (lint)
  - Run shellcheck to /property (like `$ shellcheck ./property`)
  - Run shfmt /property (like `$ shfmt -l -w`)
  - Use GitHub Action CI and run lint

#### List of OS to be supported

Unix (macOS), Windows, VM (WSL2), VM (Docker), ...

#### List of software to be supported

vim: vim --version

nvim: nvim --version

curl:

wget

nmap

hydra

golang, python, ruby

etc...
