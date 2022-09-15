# property

[![Lint](https://github.com/rnazmo/property/actions/workflows/lint.yml/badge.svg)](https://github.com/rnazmo/property/actions/workflows/lint.yml)
[![Integration Test](https://github.com/rnazmo/property/actions/workflows/integ-test.yml/badge.svg)](https://github.com/rnazmo/property/actions/workflows/integ-test.yml)

A tiny Bash script to get OS and other software version information.

TODO: GIF here

## TL;DR

TODO: Here's a summary you can read in 30 seconds.

## Documentation for users

NOTE: These are documents to my future self.

### Purpose of this project

- **For my own use**
- For learning bash script

NOTE: So, I will only support environments and software that I use frequently.

### Supported environment

Linux (especially Debian-Based Linux, but more specifically Ubuntu, Mint, and Kali)

TODO: Support more environment (OS) ...

### Supported softwares

zsh,tmux,

TODO:

### Installation

#### Using Script (recommended)

If you want to install property command under `${HOME}/bin/`,
run commands on your terminal like:

```console
DEST_DIR="${HOME}/bin"

cd /tmp && \
    curl -O https://raw.githubusercontent.com/rnazmo/property/main/install.sh && \
    chmod +x ./install.sh && \
    ./install.sh "$DEST_DIR"
```

To check that you installed it successfully:

```console
"${HOME}/bin/property"
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
$ DEST_DIR="${HOME}/bin"
$ cd /tmp && \
    curl -O https://raw.githubusercontent.com/rnazmo/property/main/install.sh && \
    chmod +x ./install.sh && \
    ./install.sh "$DEST_DIR"
```

## Documentation for developers

NOTE: These are documents to my future self.

### Policies

- Simple usage (≒ option)
- Simple code
  - Tiny code size
  - Fewer files
  - Minimum dependencies
- Simple documentation
  - 重要な情報は `README.md` (とソースコード中のコメント) に集約する。
  - 情報が散らばるのを避ける。
    - **Should not using 'Issues'**
    - **Should not using 'Pull Requests'**
    - Shall not using 'Wikis'
  - Shall not using wiki
- Easy to maintain
  - Support only environment/software that I use frequently

### Conventions

TODO: それぞれが "SHALL" なのか、"SHOULD" なのかを明記する。

#### Versioning

Follow semantic versioning.

#### Branch

- **管理が面倒なので、「main」だけとする。(SHOULD)**
- 「すぐに消すプルリク用の機能追加ブランチ」は作ってもよい。(SHOULD)

#### Commit message

- 原則として、てきとうにゆるくやる
  - ミスってもあまり気にせず。ゆるく
- For document only changes:
  - Add 'docs: ' as a prefix (SHALL)
- When you bump a version of 'property'
  - Like this: `Bump a version to v0.0.3` (SHOULD)
- When you bump a version of devel-tools
  - Like this: `Bump a version of shellcheck to v0.7.3` (SHOULD)
- When you bump a version of devel-tools
  - TODO:

#### Issues / Pull requests

**Avoid writing important information in Issues / Pull requests.**

Because it is difficult to search and maintain the information written there.

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

### How to bump a version of 'property' (versioning workflow)

0. (We edited `property` locally.)
1. Create a commit for the changes with any commit message.
2. Push the changes (like `$ git push`).
3. Ensure that the CI to the commit passes. (And if the CI falls, we go back to step 0.)
4. Run the script and bump the project version: `$ make bump-project`

MEMO: The script do following:

1. Edit and bump a version of `VERSION="v0.0.X"` in `property`, `install.sh`, and `/devel-tools/script/common.sh`. (Don't forget to follow semantic versioning!)
2. Create a commit for the change with the commit message (like `Bump a version to v0.0.3`).
3. Add a Git tag **to the commit** (like `$ git tag v0.0.3`).
4. Push the commit and tags (like `$ git push --atomic origin main v0.0.3` . ref: https://stackoverflow.com/a/3745250).

### Prerequisite

**Only the following machine are supported as development environments**:

- **'debian-based Linux' && 'x64'**

### How to setup your development environment

1. Check if your machine meet [the prerequisites](https://github.com/rnazmo/property#prerequisites)
2. Clone this repository under any directory on the machine. (`git clone git@github.com:rnazmo/property.git`)
3. [Install the dependencies using the scripts](https://github.com/rnazmo/property#how-to-install-devel-tools)

### How to install devel-tools

```console
make install-devel-tools
```

### How to bump a version of devel-tools

1. Edit and bump the versions in `/devel-tools/script/common.sh`. (like `SHELLCHECK_VERSION="v0.7.2"`, `SHFMT_VERSION="v3.3.0"`)
2. Create a commit for the change with the commit message (like `Bump a version of shellcheck to v0.7.3`).
3. Push the commit (like `$ git push`).

### How to upgrade a version of devel-tools

Same as the how to install devel-tools. (Just run `make install-devel-tools`).

### How to run lint

NOTE: Install devel-tools before running lint.

```console
make lint
```

### How to run format

NOTE: Install devel-tools before running format.

NOTE: This overwrite the files. Save it before running.

```console
make format
```

### How to run integration-test

```console
make integ-test
```

### TODO

#### Priority: ☆☆☆

- Create/Update commands for devel-tools management:
  - `check-devel-tools-versions.sh`:
    - Print following three versions of the devel-tools:
      - `Current version` : Expected version written in the `/devel-tools/script/common.sh`.
      - `Binary's version`: The actual version of the binaries under `/devel-tools/bin/`.
      - `Latest version`  : The latest release on GitHub.
  - `install-devel-tools.sh`:
    - Overwrite the `Binary's version` based on the `Current version`.
  - `upgrade-devel-tools.sh`:
    - Overwrite the `Current version` based on the `Latest version`, 
      and then overwrite the `Binary version` based on that `Current version`. 
    - Steps (idea):
      - 1. Run `check-devel-tools-versions.sh`
      - 2. Check if update is required
      - 3. (Get the latest version numbers)
      - 4. Overwrite devel-tools versions
      - 5. Install(Reinstall) devel-tools
    - including `func bump_devel_tools_versions()`
    - Ref: https://github.com/rnazmo/property#how-to-bump-a-version-of-devel-tools
  - (Do not forget to update Makefile.)
- Bump the versions of devel tools with the script
  - 上記で作ったスクリプト `upgrade-devel-tools.sh` を試すのも兼ねる。
  - Ref: https://github.com/rnazmo/property#how-to-bump-a-version-of-devel-tools
- Rename the app
  - このアプリ名("property")は非常に衝突しやすい。もう少しユニークな文字列にしたい。
    - かと言って、大きく変えたくない。
      - `proper7y` とかでどうか。

#### Priority: ☆☆

- devel-tools が最新かどうか、CI (github actions)でチェック？
  - Run the script `check-devel-tools-versions.sh` on CI ?
    - Trigger: weekly (Can I use https://docs.github.com/en/actions/reference/events-that-trigger-workflows#scheduled-events ?)
  - 自動で Pull Request 作成するところまでやる？ (dependabot みたいに)
    - 実装や権限管理面倒じゃない？大丈夫？
    - そもそも Pull Request はあまり使いたくないのでは？
    - でもあると便利だし、Bot に限れば Pull Request 使っても良いかも。
  - Add the badge to `README.md`. (The text is like `dependencies latest` ?)
- Add date information in the "property" log?
- Add unit test?
  - `ShellSpec` ?
    - [ShellSpec - シェルスクリプト用のフル機能のBDDユニットテストフレームワーク - Qiita](https://qiita.com/ko1nksm/items/2f01ff4f50e957ebf1de)
    - [シェルスクリプトのテスト、何を使ってる？shUnit2？Bats？ ShellSpec を使ってみませんか？ - Qiita](https://qiita.com/ko1nksm/items/556336797d7e49117842)
    - [ShellSpec - シェルスクリプト用のBDDテスティングフレームワークを作りました - Qiita](https://qiita.com/ko1nksm/items/77388d75b8c1f18c0058)
- Write supported OS/Software List
  - Example: [shellspec/shells.md at master · shellspec/shellspec](https://github.com/shellspec/shellspec/blob/f800240b606ed8d60f27ca687400836c0083e76a/docs/shells.md)

#### Priority: ☆

- New features:
  - Add support for following softwares
    - `<command_name>`のリストをオプションとして受け取る (like `--"go,nmap,gobuster"`) とか？
  - Add support for options
  - Add support for following OS
    - ~~Should I rewrite with Golang?~~
      - このアプリを作る＆メンテする目的の1つは `For learning bash script` である。よって、Bash script でやるべき。どうしても辛くなって Golang などで作り直したい場合は、アプリの目的も含めて見直すこと
    - Windows の対応は大変だしコードが複雑になる。対応したいなら、 'property4win とでも別リポジトリを作ってそっちでやる (powershell スクリプト？)
- docs only changes:
  - Refine README.md (内容が重複しているところとかある)
  - `install.sh` がある理由を書いておく
    - 「これを使うと常に同じコマンドで最新版をインストールできる。使わない場合、明示的にバージョンを指定しなければならなくて面倒。(特に、別のスクリプト中」
  - Add following texts to `README.md`
    - > In this document, `property` indicates the file, 'property' indicates the project (≒ the repository) and `$ property` indicates the command on your console.

- Add 'pre-commit' (lint)
  - Run shellcheck to /property (like `$ shellcheck ./property`)
  - Run shfmt /property (like `$ shfmt -l -w`)
で 'property' をインストールする場合、バージョン管理しなくてはならず面倒)
  - [ref](#do-not-download-install-property-without-specifying-the-version)
  - 書き方はここが参考になりそう：
    - https://github.com/golangci/golangci-lint/blob/3c795d8637855c813c7c22fb36a3521c726bcd87/docs/src/docs/usage/install/index.mdx#other-ci
    - https://github.com/golangci/golangci-lint/blob/3c795d8637855c813c7c22fb36a3521c726bcd87/docs/src/docs/usage/install/index.mdx#install-from-source

- Add GIF image to `README.md`
  - using `asciinema`?
    - [ターミナルでの入力の記録と再生、Webでの共有が可能なOSSツール – asciinema | DevelopersIO](https://dev.classmethod.jp/articles/intro-asciinema/)

- コマンドの exit status を整える。(正常終了で 0 を返す、など)

#### List of OS/software to be supported

##### OS

- [ ] Linux (debian-based)
- [x] Windows
  - -> Develop on another repo: github.com/rnazmo/property4win
- [ ] VM (VirtualBox)
- [ ] VM (Docker)
- [ ] VM (WSL2)

- [ ] Linux (redhat-based)
- [ ] Unix (macOS)
  - -> **Develop on another repo?(github.com/rnazmo/property4mac)**
- [ ] VFM (VMWare)

##### software

- vim: `vim --version`
- nvim: `nvim --version`

- curl: `curl --version`
- wget: `wget --version`
- nmap: `nmap --version`
- gobuster: `gobuster version`
- nikto: `nikto --version`
- Metasploit: `msfconsole: --version`
- hydra: `hydra --foo` => sed
- hashcat: `hashcat --version`
- john: `john` => sed
- wireshark: `wireshark --version`

- golang: `go version`
- python
  - `type python`
  - Python2: `python2 --version`
  - Python3: `python3 --version`
  - `type pip`
  - pip2: `pip2 --version`
  - pip3: `pip3 --version`
- ruby
  - RubyGems: `gem --version`
- nodejs/javascript/typescript
  - nodejs: `node --version`
  - (nvm: `nvm --version`)
  - npm: `npm --version`
  - yarn: `yarn --version`

- firefox: `firefox --version`
- chrome: `google-chrome --version`

## Memo

### Linting

#### Options of shfmt

- `-i` : Specify indent size
- `-d` : Error when the formatting differs

Ref:

- [Shell scripting standards and style guidelines | GitLab](https://docs.gitlab.com/ee/development/shell_scripting_guide/#formatting)
- [sh/shfmt.1.scd at f33507475241da6fc37b972d825c351b94300bab · mvdan/sh](https://github.com/mvdan/sh/blob/f33507475241da6fc37b972d825c351b94300bab/cmd/shfmt/shfmt.1.scd)

Example:

```console
shfmt -i 2 -d ./property ./install.sh
```

### Formatting

#### Options of shfmt

- `-w`: Write result to file instead of stdout.
