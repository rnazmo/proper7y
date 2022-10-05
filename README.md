# proper7y

[![Static Test](https://github.com/rnazmo/proper7y/actions/workflows/static-test.yml/badge.svg)](https://github.com/rnazmo/proper7y/actions/workflows/static-test.yml)
[![Integration Test](https://github.com/rnazmo/proper7y/actions/workflows/integ-test.yml/badge.svg)](https://github.com/rnazmo/proper7y/actions/workflows/integ-test.yml)

A tiny Bash script to get OS and other software version information in consistent format.

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

If you want to install proper7y command under `${HOME}/bin/`,
run commands on your terminal like:

```console
DEST_DIR="${HOME}/bin"

cd /tmp && \
    curl -O https://raw.githubusercontent.com/rnazmo/proper7y/main/install.sh && \
    chmod +x ./install.sh && \
    ./install.sh "$DEST_DIR"
```

To check that you installed it successfully:

```console
"${HOME}/bin/proper7y"
```

#### Manually

1. Download `proper7y` file from GitHub's raw page, **specifying any version** (Use a link like [this](https://raw.githubusercontent.com/rnazmo/proper7y/v0.0.1/proper7y) one.)
2. Add the file to the environment PATH (optional)
3. Add execute permission (like `chmod +x ./proper7y`)
4. Run (like `./proper7y`)

```console
$ DEST_DIR="${HOME}/bin"

$ VERSION="v0.0.1"

$ cd "$DEST_DIR" && \
    curl -O https://raw.githubusercontent.com/rnazmo/proper7y/"$VERSION"/proper7y && \
    chmod +x ./proper7y

$ ./proper7y
TODO: Example result log here
```

### Using without installation

Just run commands like the following in your terminal.

```console
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/rnazmo/proper7y/v0.0.1/proper7y)"
```

### How to bump a version of my 'proper7y'

1. Delete you old `proper7y` file.
2. Install a new version of 'proper7y'. (See [Installation](https://github.com/rnazmo/proper7y#installation) section.)

### Examples

TODO:

### Notes

#### Do not download (install) 'proper7y' without specifying the version

TL;DR: **Use `install.sh`**. Or Download `proper7y` file directly **with specifying a version**

Don't download 'proper7y' (this indicates 'proper7y' as the file) directly from the `main` branch,
but download it directly using a tag such as "v0.0.1".

Or, I highly recommend you to download 'proper7y' (this indicates 'proper7y' as the file) via `install.sh`.
If you download `install.sh`, it is also allowed from the `main` branch.

If you do not specify the version (for example, if you download 'proper7y' (this indicates 'proper7y' as the file) directly from `main` branch),
the version information of 'proper7y' (this indicates 'proper7y' as the project) itself in the output of the `proper7y` (this 'proper7y' means as the file) command can be incorrect.

e.g.,

```console
# BAD:
$ curl -O "https://raw.githubusercontent.com/rnazmo/proper7y/main/proper7y"
```

```console
# GOOD:
$ curl -O "https://raw.githubusercontent.com/rnazmo/proper7y/v0.0.1/proper7y"
```

I highly recommend you to use `install.sh` to avoid these mistakes.

```console
# GOOD (Recommend)
$ DEST_DIR="${HOME}/bin"
$ cd /tmp && \
    curl -O https://raw.githubusercontent.com/rnazmo/proper7y/main/install.sh && \
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
- When you bump a version of 'proper7y'
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

### How to bump a version of 'proper7y' (versioning workflow)

0. (We edited `proper7y` locally.)
1. Create a commit for the changes with any commit message.
2. Push the changes (like `$ git push`).
3. Ensure that the CI to the commit passes. (And if the CI falls, we go back to step 0.)
4. Run the script and bump the project version: `$ make bump-project`

MEMO: The script do following:

1. Edit and bump a version of `VERSION="v0.0.X"` in `proper7y`, `install.sh`, and `/devel-tools/script/common.sh`. (Don't forget to follow semantic versioning!)
2. Create a commit for the change with the commit message (like `Bump a version to v0.0.3`).
3. Add a Git tag **to the commit** (like `$ git tag v0.0.3`).
4. Push the commit and tags (like `$ git push --atomic origin main v0.0.3` . ref: https://stackoverflow.com/a/3745250).

### Prerequisite

**Only the following machine are supported as development environments**:

- **'debian-based Linux' && 'x64'**

### How to setup your development environment

1. Check if your machine meet [the prerequisites](https://github.com/rnazmo/proper7y#prerequisites)
2. Clone this repository under any directory on the machine. (`git clone git@github.com:rnazmo/proper7y.git`)
3. [Install the dependencies using the scripts](https://github.com/rnazmo/proper7y#how-to-install-devel-tools)

### How to install devel-tools

```console
make install-devel-tools
```

### How to bump a version of devel-tools

#### Using script

Just run:

```console
make check-devel-tools-versions
```

#### Manually

1. Edit and bump the versions in `/devel-tools/script/common.sh`. (like `SHELLCHECK_CURRENT_VERSION="v0.7.2"`, `SHFMT_CURRENT_VERSION="v3.3.0"`)
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

- Update the convention
  - Scope:
    - https://github.com/rnazmo/proper7y/blob/5d25e105ac879c5787945b333f13327e33cdb562/README.md?plain=1#L163-L166
  - やっぱり、変更が大きいときは branch 使いたいかも。
  - 「**なるべく `main` だけ**の状態を維持することが望ましい。ただし、機能追加などで**一時的な**ブランチを作るのは全く構わない」などと改定する？ 
- Add support for command line options
  - `--add`
    - Example: `$ proper7y --add=ruby`
  - `--template` (or 'custom'?)
    - Example: `$ proper7y --template=os_name,os_version,ruby`
  - `--version`
    - Example: `$ proper7y --version`
  - `--help`
    - Example: `$ proper7y --help`
  - `--verbose` (or 'long'?)
    - Example: `$ proper7y --verbose`
    - これ実装しようとすると、「`--add`, `--template` とは共存できるが、`--version`, `--help` とは共存できない」という validation をしなければならず、面倒。よってとりあえず保留。上記4つの実装が先。
  - イメージ：
    ```
    SYNOPSIS:
      proper7y [--add=<params> | --template=<params>] [--verbose]
      proper7y [--version | --help]

    DESCRIPTION:
      TODO:

    OPTIONS:
      TODO:
    ```
- `v1.0.0` までに実装すべきもの(足りないもの)を列挙しておく
  - 対応する環境・対象とするソフトウェアをはっきりさせる
    - 対応する環境は？:
      - OS: ubuntu, kali, macos
      - shell: bash, zsh
    - 対象とするソフトウェアは？:
      - shell: bash, zsh
      - programming lang: golang, python(pip), ruby(gem), js/ts(node,npm,yarn,)
      - cli: awk, sed, grep, curl,...
      - editor: vim, neovim, vscode
    - Example: [shellspec/shells.md at master · shellspec/shellspec](https://github.com/shellspec/shellspec/blob/f800240b606ed8d60f27ca687400836c0083e76a/docs/shells.md)
  - 「基本情報」に加え、「指定したソフトウェアの情報」を出力する方法を考える
    - 良い感じに指定したい
      - コマンドラインオプション？
        - でも利用方法をあまり複雑にしたくない
        - like `proper7y --add=ruby,gem,curl,nmap` みたいな？
          - いや、template を自分で指定できると良いかも
            - `$ proper7y --template=os_name,os_version,current_shell,bash_version,zsh_version,cpu_arch,ruby,gem` みたいな
            - (`$ proper7y` == `$ proper7y --template=os_name,os_version,current_shell,bash_version,zsh_version,cpu_arch`)
            - 実装がだいぶ面倒そう
      - ~~インタラクティブ？~~
        - ログから操作を再現しにくくなる
    - 割り切って「サポートしない」と決めるのもあり
  - オプション周りを考える
    - `--template`: 上述
    - `--verbose`: 各バージョン情報について、より詳細に出力する
      - `v1.22.34` に加え、ハッシュ値とかビルド時間とか。(ある場合のみ)
  - README.md の内容を整える
    - Refine README.md (内容が重複しているところとかある)
    - `install.sh` がある理由を書いておく
      - これを使うと常に同じコマンドで最新版をインストールできる。使わない場合、明示的にバージョンを指定しなければならなくて面倒。(特に、別のスクリプト中で 'property' をインストールする場合、バージョン管理しなくてはならず面倒)
      - ref: https://github.com/rnazmo/proper7y/blob/6b77aee0debf25f4d6f6a1aee8224c84470a765f/README.md#do-not-download-install-proper7y-without-specifying-the-version
      - 書き方はここが参考になりそう：
          - https://github.com/golangci/golangci-lint/blob/3c795d8637855c813c7c22fb36a3521c726bcd87/docs/src/docs/usage/install/index.mdx#other-ci
          - https://github.com/golangci/golangci-lint/blob/3c795d8637855c813c7c22fb36a3521c726bcd87/docs/src/docs/usage/install/index.mdx#install-from-source
    - Add following texts to `README.md`
      - > In this document, `proper7y` indicates the file, 'proper7y' indicates the project (≒ the repository) and `$ proper7y` indicates the command on your console.
    - Add GIF image to `README.md`
      - using `asciinema`?
        - [ターミナルでの入力の記録と再生、Webでの共有が可能なOSSツール – asciinema | DevelopersIO](https://dev.classmethod.jp/articles/intro-asciinema/)

#### Priority: ☆☆

- devel-tools が最新かどうか、CI (github actions)でチェック？
  - Run the script `check-devel-tools-versions.sh` on CI ?
    - Trigger: weekly (Can I use https://docs.github.com/en/actions/reference/events-that-trigger-workflows#scheduled-events ?)
  - 自動で Pull Request 作成するところまでやる？ (dependabot みたいに)
    - 実装や権限管理面倒じゃない？大丈夫？
    - そもそも Pull Request はあまり使いたくないのでは？
    - でもあると便利だし、Bot に限れば Pull Request 使っても良いかも。
  - Add the badge to `README.md`. (The text is like `dependencies latest` ?)
- Add unit test?
  - `ShellSpec` ?
    - [ShellSpec - シェルスクリプト用のフル機能のBDDユニットテストフレームワーク - Qiita](https://qiita.com/ko1nksm/items/2f01ff4f50e957ebf1de)
    - [シェルスクリプトのテスト、何を使ってる？shUnit2？Bats？ ShellSpec を使ってみませんか？ - Qiita](https://qiita.com/ko1nksm/items/556336797d7e49117842)
    - [ShellSpec - シェルスクリプト用のBDDテスティングフレームワークを作りました - Qiita](https://qiita.com/ko1nksm/items/77388d75b8c1f18c0058)
  - スクリプトの特性上、ユニットテストでテストできる範囲狭そう
- Add date information in the "proper7y" log?

#### Priority: ☆

- Add support for options?
  - Using [ko1nksm/getoptions: An elegant option/argument parser for shell scripts (full support for bash and all POSIX shells)](https://github.com/ko1nksm/getoptions) ?
- Add support for following OS?
  - ~~Should I rewrite with Golang?~~
    - このアプリを作る＆メンテする目的の1つは `For learning bash script` である。よって、Bash script でやるべき。どうしても辛くなって Golang などで作り直したい場合は、アプリの目的も含めて見直すこと
  - Windows の対応は大変だしコードが複雑になる。対応したいなら、 'proper7y4win とでも別リポジトリを作ってそっちでやる (powershell スクリプト？)
- コマンドの exit status を整える。(正常終了で 0 を返す、など)

#### Environment which should be supported

- [ ] ubuntu
- [ ] kali
- [ ] macos (-> Develop on another repo?(github.com/rnazmo/proper7y4mac))
- [x] ~~windows~~ -> Develop on another repo: github.com/rnazmo/proper7y4win
- [ ] virtualbox
- [ ] docker
- [ ] wsl2

(memo: debian-based linux, redhat-based linux)

#### Commands to print the software version (on debian-based linux)

##### bash

```console
$ bash --version | head -n 1 | sed "s/GNU bash, version //"
5.1.4(1)-release (x86_64-pc-linux-gnu)
```

##### zsh

```console
$ zsh --version | sed "s/zsh //"
5.9 (x86_64-debian-linux-gnu)
```

##### golang


```console
$ go version | sed "s/go version go//"
1.16.5 linux/amd64
```

##### python

```console
TODO: python, pip
```

##### ruby

```console
TODO: ruby, gem
```

##### js/ts

```console
TODO: npm, nvm, node, yarn
```

##### awk

```console
TODO:
```

##### sed

```console
TODO:
```

##### grep

```console
TODO:
```

##### curl

```console
TODO:
```

##### tmux

```console
TODO:
```

##### vim

```console
$ vim --version | head -1 | sed "s/VIM - Vi IMproved //"
8.2 (2019 Dec 12, compiled Mar 02 2021 02:58:09)
```

##### neovim

```console
TODO:
```

##### vscode

```console
TODO:
```

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
shfmt -i 2 -d ./proper7y ./install.sh
```

### Formatting

#### Options of shfmt

- `-w`: Write result to file instead of stdout.

### Pre-commit

```console
make lint
make format
```

### Pre-push

```console
make lint
make format
make integ-test
```

### Version commands

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
