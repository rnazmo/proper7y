# proper7y

[![Static Test](https://github.com/rnazmo/proper7y/actions/workflows/static-test.yml/badge.svg)](https://github.com/rnazmo/proper7y/actions/workflows/static-test.yml)
[![Integration Test](https://github.com/rnazmo/proper7y/actions/workflows/integ-test.yml/badge.svg)](https://github.com/rnazmo/proper7y/actions/workflows/integ-test.yml)

Tiny Bash script to print basic system information in consistent format.

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

#### Using Script (recommended) - Install the latest release version

If you want to install proper7y command under `${HOME}/bin/`,
run commands on your terminal like:

```console
DEST_DIR="${HOME}/bin"

cd "$(mktemp -d)" && \
    curl -O https://raw.githubusercontent.com/rnazmo/proper7y/main/install.sh && \
    chmod +x install.sh && \
    ./install.sh "$DEST_DIR"
```

To check that you installed it successfully:

```console
"${HOME}/bin/proper7y"
```

#### Manually - Install the specified release version

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
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/rnazmo/proper7y/v0.3.0/proper7y)"
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
2. Create a commit for the change with the commit message (like `Bump devel-tool version (shfmt): v3.5.1 -> v3.6.3`).
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

### TODO

#### Priority: ☆☆☆

- Check "prerequisites exists?", "the os is supported os?":
  - proper7y: 最初に OS を特定し、未対応の OS の場合にはエラーを返して終了させる
    - main 関数の最初で OS を特定し、その情報を変数に保存しておく
  - 対応する Bash の最小バージョンを決める
    - スクリプトの最初に Bash のバージョンを確認して、対応外のバージョンならエラーメッセージを出力して終了させる
  - コマンドの exit status を整える。(正常終了で 0 を返す、など)
  - Do not use `exit` command in `common.sh`. Use `return` instead.
    - 関数の終わりに `exit` を使うべきではない。その場で強制終了させてしまうから。途中で強制終了することで、終了プロセスが複雑になってしまう
    - 「`exit`使って良いのは `main()` 関数からのみ」みたいなルールを決めておくべき
- testing, ci:
  - Support Manjaro Linux
    - Support Manjaro Linux as development environment
    - CI のテスト環境に Manjaro (Arch Linux) を追加
  - Add unit test?
    - `ShellSpec` ?
      - [ShellSpec - シェルスクリプト用のフル機能の BDD ユニットテストフレームワーク - Qiita](https://qiita.com/ko1nksm/items/2f01ff4f50e957ebf1de)
      - [シェルスクリプトのテスト、何を使ってる？shUnit2？Bats？ ShellSpec を使ってみませんか？ - Qiita](https://qiita.com/ko1nksm/items/556336797d7e49117842)
      - [ShellSpec - シェルスクリプト用の BDD テスティングフレームワークを作りました - Qiita](https://qiita.com/ko1nksm/items/77388d75b8c1f18c0058)
    - スクリプトの特性上、ユニットテストでテストできる範囲狭そう
- docs:
  - Update the convention
    - Scope:
      - https://github.com/rnazmo/proper7y/blob/5d25e105ac879c5787945b333f13327e33cdb562/README.md?plain=1#L163-L166
    - やっぱり、変更が大きいときは branch 使いたいかも。
    - 「**なるべく `main` だけ**の状態を維持することが望ましい。ただし、機能追加などで**一時的な**ブランチを作るのは全く構わない」などと改定する？
    - Google Style Guide
    - Conventional Commits

#### Priority: ☆

- `v1.0.0` までに実装すべきもの(足りないもの)を列挙しておく
  - 対応する環境・対象とするソフトウェアをはっきりさせる
    - 対応する環境は？:
      - OS: ubuntu, kali, macos, ...
      - shell: bash, zsh
  - オプション機能は作る？どうする？
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
        - [ターミナルでの入力の記録と再生、Web での共有が可能な OSS ツール – asciinema | DevelopersIO](https://dev.classmethod.jp/articles/intro-asciinema/)
    - About supported OS (?)
      - ~~Should I rewrite with Golang?~~
        - このアプリを作る＆メンテする目的の 1 つは `For learning bash script` である。よって、Bash script でやるべき。どうしても辛くなって Golang などで作り直したい場合は、アプリの目的も含めて見直すこと
      - Windows の対応は大変だしコードが複雑になる。対応したいなら、 'proper7y4win とでも別リポジトリを作ってそっちでやる (powershell スクリプト？)
- devel-tools が最新かどうか、CI (github actions)でチェック？
  - Run the script `check-devel-tools-versions.sh` on CI ?
    - Trigger: weekly (Can I use https://docs.github.com/en/actions/reference/events-that-trigger-workflows#scheduled-events ?)
  - 自動で Pull Request 作成するところまでやる？ (dependabot みたいに)
    - 実装や権限管理面倒じゃない？大丈夫？
    - そもそも Pull Request はあまり使いたくないのでは？
    - でもあると便利だし、Bot に限れば Pull Request 使っても良いかも。
  - Add the badge to `README.md`. (The text is like `dependencies latest` ?)
- Add ChangeLog

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
