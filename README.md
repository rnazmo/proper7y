# proper7y

[![Static Test](https://github.com/rnazmo/proper7y/actions/workflows/static-test.yml/badge.svg)](https://github.com/rnazmo/proper7y/actions/workflows/static-test.yml)
[![Integration Test](https://github.com/rnazmo/proper7y/actions/workflows/integ-test.yml/badge.svg)](https://github.com/rnazmo/proper7y/actions/workflows/integ-test.yml)

Tiny Bash script to print basic system information in consistent format.

> **Note on terminology used in this document:**
> `proper7y` refers to the file (the script itself),
> 'proper7y' refers to the project (≒ the repository), and
> `$ proper7y` refers to the command on your console.

<!-- TODO: GIF here -->

## TL;DR

`proper7y` is a tiny Bash script that prints basic system information
in a consistent, easy-to-copy format. Useful for attaching environment
details to technical articles or bug reports.

```console
$ ./proper7y
proper7y v0.9.3 - Tiny Bash script to print basic system
information. See: https://github.com/rnazmo/proper7y
============================================================
CURRENT DATE  : 2026-04-19
VIRTUALIZATION: Hyper-V
CPU ARCH      : x86_64
OS NAME       : Ubuntu
OS VERSION    : 24.04
CURRENT SHELL : Bash
BASH VERSION  : 5.2.21
============================================================
```

## Documentation for users

NOTE: These are documents to my future self.

### Purpose of this project

- **For my own use**
- For learning bash script

NOTE: So, I will only support environments and software that I use frequently.

#### Scope of displayed information

proper7y outputs **machine-global environment information** only.
This means information that is tied to the machine itself, such as OS, CPU architecture,
shell, and virtualization environment.

Project-local information (e.g. React version, Vite version) is out of scope,
as it varies per project rather than per machine. (Ref: ADR-021)

### Supported softwares

See: [`Supported Software:` section in proper7y](https://github.com/rnazmo/proper7y/blob/main/proper7y#L13)

#### Support policy

| Environment           | Target                           | Support level                                 |
| --------------------- | -------------------------------- | --------------------------------------------- |
| User environment      | Linux (Arch-based, Debian-based) | Full support                                  |
| User environment      | macOS                            | Best-effort (works in CI, but not guaranteed) |
| User environment      | Shell: Bash (>= 4.0), Zsh        | Full support                                  |
| Developer environment | Linux x64                        | Full support                                  |
| Developer environment | macOS                            | Not supported                                 |

### Installation

#### Using Script (recommended) - Install the latest release version

If you want to install proper7y command under `${HOME}/.bin/`,
run commands on your terminal like:

```console
DEST_DIR="${HOME}/.bin"

cd "$(mktemp -d)" && \
    curl -O https://raw.githubusercontent.com/rnazmo/proper7y/main/install.bash && \
    chmod +x install.bash && \
    ./install.bash "$DEST_DIR"
```

To check that you installed it successfully:

```console
"${HOME}/.bin/proper7y"
```

#### Manually - Install the specified release version

1. Download `proper7y` file from GitHub's raw page, **specifying any version** (Use a link like [this](https://raw.githubusercontent.com/rnazmo/proper7y/v0.0.1/proper7y) one.)
2. Add the file to the environment PATH (optional)
3. Add execute permission (like `chmod +x ./proper7y`)
4. Run (like `./proper7y`)

```console
$ DEST_DIR="${HOME}/.bin"

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

```console
$ ./proper7y
proper7y v0.9.3 - Tiny Bash script to print basic system
information. See: https://github.com/rnazmo/proper7y
============================================================
CURRENT DATE  : 2026-04-18
VIRTUALIZATION: Physical
CPU ARCH      : x86_64
OS NAME       : Ubuntu
OS VERSION    : 24.04
CURRENT SHELL : Bash
BASH VERSION  : 5.2.21
============================================================
```

```console
$ ./proper7y
proper7y v0.9.3 - Tiny Bash script to print basic system
information. See: https://github.com/rnazmo/proper7y
============================================================
CURRENT DATE  : 2026-04-18
VIRTUALIZATION: Docker
CPU ARCH      : x86_64
OS NAME       : Debian
OS VERSION    : 12
CURRENT SHELL : Bash
BASH VERSION  : 5.2.15
============================================================
```

### Notes

#### Do not download (install) 'proper7y' without specifying the version

TL;DR: **Use `install.bash`**. Or Download `proper7y` file directly **with specifying a version**

Don't download `proper7y` directly from the `main` branch,
but download it directly using a tag such as "v0.0.1".

Or, I highly recommend you to download `proper7y` via `install.bash`.
If you download `install.bash`, it is also allowed from the `main` branch.

If you do not specify the version (for example, if you download `proper7y` directly from the `main` branch),
the version information of 'proper7y' itself in the output of `proper7y` can be incorrect.

e.g.,

```console
# BAD:
$ curl -O "https://raw.githubusercontent.com/rnazmo/proper7y/main/proper7y"
```

```console
# GOOD:
$ curl -O "https://raw.githubusercontent.com/rnazmo/proper7y/v0.0.1/proper7y"
```

I highly recommend you to use `install.bash` to avoid these mistakes.

```console
# GOOD (Recommend)
$ DEST_DIR="${HOME}/.bin"
$ cd /tmp && \
    curl -O https://raw.githubusercontent.com/rnazmo/proper7y/main/install.bash && \
    chmod +x ./install.bash && \
    ./install.bash "$DEST_DIR"
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
  - 重要なドキュメントは `README.md`、`TODO.md`、`ADR.md`、およびソースコード中のコメントに集約する。
  - 情報が散らばるのを避ける。
    - **Should not using 'Issue'**
    - **Should not using 'Pull Request'**
    - Shall not using 'Wiki'
- Easy to maintain
  - Support only environment/software that I use frequently

### Conventions

- **SHALL**: 必ず守るルール。例外なし。
- **SHOULD**: 原則として守るルール。合理的な理由があれば例外を認める。

#### Versioning

Follow semantic versioning. (SHALL)

#### Branch

- **なるべく `main` だけの状態を維持することが望ましい。(SHOULD)**
- ただし、機能追加など変更が大きい場合に一時的なブランチを作るのは全く構わない。(SHOULD)
- 一時ブランチはマージ後すみやかに削除する。(SHOULD)

#### Commit message

Follow [Conventional Commits](https://www.conventionalcommits.org/ja/v1.0.0/). (SHOULD)
See ADR-009 for the rationale and detailed rules.

This project is personal, so strict enforcement is not required. Continuing to commit matters more than writing a perfect message.

**Commit types used in this project:**

- `feat`: new feature
- `fix`: bug fix
- `docs`: documentation only
- `style`: formatting, no logic change
- `refactor`: neither fix nor feature
- `test`: adding or updating tests
- `chore`: build process or tooling changes (e.g. bumping devel-tools versions)

**Scope** (optional): Use when the target is clear (e.g. `feat(install): ...`, `chore(shfmt): ...`, `docs(ADR): ...`).

**Examples:**

- `chore: bump project version: v0.9.3 -> v0.10.0`
- `chore(shellcheck): bump devel-tool version: v0.10.0 -> v0.11.0`
- `docs(README): add TL;DR section`
- `refactor(proper7y): split init() into check_prerequisites() and identify_environment() (ADR-013)`

#### Issues / Pull requests

**Avoid writing important information in Issues / Pull requests. (SHALL)**

Because it is difficult to search and maintain the information written there.

#### Issue / Pull request title

特にルールは設けない。てきとうに。

#### Documentation

Although not preferred, it is okay to have a mixture of English and Japanese. (SHOULD)
(The target reader of these documents is my future self.)

#### Code Style for Bash Script (Lint, Format)

Follow shellcheck and shfmt. (SHALL)

Also follow [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html) for rules not covered by the above tools. Key rules adopted in this project:

**Naming**

- Function names: `lowercase_with_underscores` (SHALL)
- Constants and readonly globals: `UPPER_SNAKE_CASE` with `readonly` (SHALL)
- Local variables: `lowercase_with_underscores` with `local` (SHALL)

**Functions**

- Always declare function-scoped variables with `local` or `local -r`. (SHALL)
- Functions that are internal (not intended to be called from outside the file) should be prefixed with `_`. (SHOULD)

**Error handling**

- Always use `set -eu` at the top of every script. (SHALL)
- Use `exit 1` in top-level scripts and `return 1` in library functions (`common.bash`). See ADR-010. (SHALL)

**Quoting**

- Always double-quote variables: `"$VAR"` not `$VAR`. (SHALL)
- Exception: inside `[[ ]]`, quoting is optional but still preferred. (SHOULD)

**Misc**

- Use `[[ ]]` instead of `[ ]` for conditionals. (SHALL)
- Use `$(...)` instead of backticks for command substitution. (SHALL)
- Always add `exit 0` at the end of top-level scripts. See ADR-011. (SHALL)

Ref:

- [Shell scripting standards and style guidelines | GitLab](https://docs.gitlab.com/ee/development/shell_scripting_guide/#code-style-and-format)
- [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- [ShellCheck](https://github.com/koalaman/shellcheck)
- [shfmt](https://github.com/mvdan/sh)

#### Force push to the remote repo

すべきではないが、(どうしても仕方がない場合のみ) 許可する。(対象ユーザーが自分のみなので)

### Prerequisite

**Only the following machine are supported as development environments**:

- **Linux x64**

Note: `devel-tools` scripts (lint, format, install, bump, etc.) depend on
Linux/x64 binaries (shellcheck, shfmt) and `GNU sed`, so they only work on
Linux/x64. The exception is `run-integ-test.bash`, which has no such
dependency and works on both Linux and macOS. (Ref: ADR-012, ADR-020)
(Unlike the other devel-tools scripts, which are Linux/x64-only.)

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

1. Edit and bump the versions in `/devel-tools/script/common.bash`. (like `SHELLCHECK_CURRENT_VERSION="v0.7.2"`, `SHFMT_CURRENT_VERSION="v3.3.0"`)
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
make integ-tests
```

### How to bump a version of 'proper7y' (versioning workflow)

0. (We edited `proper7y` locally.)
1. Create a commit for the changes with any commit message.
2. Push the changes (like `$ git push`).
3. Ensure that the CI to the commit passes. (And if the CI falls, we go back to step 0.)
4. Run the script and bump the project version: `$ make bump-project`

MEMO: The script do following:

1. Edit and bump a version of `VERSION="v0.0.X"` in `proper7y`, `install.bash`, and `/devel-tools/script/common.bash`. (Don't forget to follow semantic versioning!)
2. Create a commit for the change with the commit message (like `Bump a version to v0.0.3`).
3. Add a Git tag **to the commit** (like `$ git tag v0.0.3`).
4. Push the commit and tags (like `$ git push --atomic origin main v0.0.3` . ref: <https://stackoverflow.com/a/3745250>).

### ADR

See: [ADR.md](./ADR.md)

### TODO

See: [TODO.md](./TODO.md)

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
shfmt -i 2 -d ./proper7y ./install.bash
```

### Formatting

#### Options of shfmt

- `-w`: Write result to file instead of stdout.

### Pre-commit

```console
make pre-commit
```

### Pre-push

```console
make pre-push
```
