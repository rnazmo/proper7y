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

TODO:

### How to install

TODO:

1. Download from release page (or github's raw page)
2. Add the file to the PATH (optional)
3. Add execution permission (like `chmod +x ./property`)
4. Run (like `property`)

### Using without installation

<!--
```console
TODO: とりあえず https://brew.sh/ を参考にして書いたが、きちんと動くかわからないのできちんと試す
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/rnazmo/property/main/property.sh)"
```
-->

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
