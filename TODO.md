# TODO

## Milestone: v0.10.0 - 簡単にできる様々な改善

### セキュリティ・バグ修正

無し。

### コード・機能

- [x] `install_shellcheck()` および `run-integ-test.linux-x64.bash` で `trap` を使ってtempディレクトリのクリーンアップを保証する
  - 現状：`curl` や `tar` が失敗したとき、`rm -rf "$TEMP_DIR"` が実行されずにゴミが残る
  - 修正案：`trap "rm -rf '{$TEMP_DIR:-}'" EXIT` を使うことで、成功・失敗問わず必ずクリーンアップされる
  - 備考：`run-integ-test.linux-x64.bash` は `mktemp -d` の結果を変数に受けていなかったため、変数への代入も同時に修正した
- [x] `verify_version_consistency()` の `grep` パターンを堅牢にする
  - 現状: `grep 'PROPER7Y_VERSION='` はコメント行の途中に文字列が現れた場合に誤マッチする可能性がある
    - 例：`# OLD: PROPER7Y_VERSION="v0.8.0"` のようなコメント行もマッチしてしまう。それは望ましくない
  - 修正案：`^PROPER7Y_VERSION=` のように行頭アンカーを付ける。正確には `^readonly PROPER7Y_VERSION=` にする
  - **追記（~~未対応~~）**: 修正が漏れていた。同関数内にて、修正できていない grep 処理がある。同様の修正が必要
    - → 上記の未対応箇所は以下のタスク「`common.bash` の `verify_version_consistency()` の `grep` に行頭アンカーを付ける」として追加済み
- [x] `print_os_version()` の `lsb_release` 依存を `/etc/os-release` に置き換える
  - 現状：`lsb_release` はDockerの最小イメージなど一部のDebian系環境に存在しない場合がある
  - 修正案：`/etc/os-release` の `VERSION_ID` を使う方が堅牢: `grep VERSION_ID /etc/os-release | cut -d= -f2 | tr -d '"'`
- [x] `SUPPORTED_OS_IDS` 等の配列チェックを完全一致に変更する
  - 現状：`[[ "${SUPPORTED_OS_IDS[*]}" =~ ${OS_ID} ]]` は部分一致のため、例えば `OS_ID="arch"` が `"archlinux"` にマッチしてしまう
  - 修正案：ループによる完全一致チェック関数 `is_supported()` を実装して置き換える
- [x] `install.bash` の `log_warn` が未使用である
  - 現状：定義されているが一度も呼ばれていない
  - 修正案：削除するか、適切な箇所で使用する
- [x] `print_cpu_arch()` の冗長な初期化を整理する
  - 修正案：`local CPU_ARCH="Unknown"` の直後に必ず上書きされるため、`local -r CPU_ARCH="$UNAME_CACHE_MACHINE"` で十分
- [x] `common.bash` の `verify_version_consistency()` の `grep` に行頭アンカーを付ける
  - 現状：関数内で 3 箇所使われている grep のうち、1 箇所だけ修正済みだが 2 箇所の修正が漏れている
  - 修正案：`grep 'PROPER7Y_VERSION='` を `grep '^readonly PROPER7Y_VERSION='` にする
- [ ] `Makefile` の `static-tests` ターゲットから `format` を外すことを検討する
  - 現状：`static-tests: lint format validate` と定義されており、`pre-commit` 時にファイルが意図せず上書きされる可能性がある
  - `format` はファイルを上書きする副作用を持つため、差分チェックのみ行う `lint` とは役割が根本的に異なる
  - CI での `make static-tests` 実行にも適さない。実際に `static-test.yml` では `make static-tests` を使わず `make lint` と `make validate` を個別に呼んでいる
  - 修正案：`static-tests: lint validate` に変更する。`format` は明示的に `make format` で呼ぶ運用にするか、`pre-commit` などの別ターゲットにのみ含める
    - しかし、そうするとローカルでの確認の際に `make static-tests` だけで完結しなくなり不便。ローカルでの確認の際に楽をしたいので、コマンド一発で全部確認できると嬉しい
  - 合わせて、TODO.md の「`run-format.linux-x64.bash` の `confirm_continue` がCI環境で使えない問題」タスクとの関係も確認すること
- [ ] `install_shellcheck()` 内の `trap EXIT` がプロセス全体を上書きする問題について検討する
  - 現状：関数内で `trap 'rm -rf ...' EXIT` を設定しているが、**`trap EXIT` はプロセス全体に対して設定される**ため、後続の関数呼び出し（`install_shfmt` など）と干渉する可能性がある
    - 具体的には、install_shellcheck() が呼ばれた後に install_shfmt() が呼ばれると、shfmt のインストール中にも shellcheck の TEMP_DIR の trap が上書きされるか、あるいは意図しないタイミングで発火する可能性がある
  - 修正案：サブシェル `( )` に処理を閉じ込めて trap のスコープを関数内に限定する、または trap のスコープ管理方針を明示的に設計し直す
- [ ] `common.bash` の `initialize_global_variables()` が2回呼ばれるとエラーになる問題を文書化または修正する
  - 現状：関数内で `readonly` 宣言しているため、2回呼ぶと readonly 変数への再代入でエラーになる。現状は1回しか呼ばれていないが、将来的な罠になる
  - 修正案：「1回しか呼んではいけない」という制約をコメントで明記する（最小コスト）か、冪等に動作するよう設計し直す
  - これ、common.bash やグローバル変数周りの根本的な設計に関わりそうなので、慎重に検討する必要がありそう。

### テスト・CI

- [x] GitHub Actions の `actions/checkout` を `v2` から `v4` に更新する
  - `v2` はNode.js 16ベースでGitHubが非推奨化している
- [x] CIでバージョン整合性チェックを自動化する
  - 信頼性を高めるためには、CIでも自動で確認すべき
  - 現状：`verify_version_consistency()` はローカルの `bump-project` 実行時にしか走らない
  - 修正案：`static-test.yml` に「3ファイルの `PROPER7Y_VERSION` が一致するかチェックする処理」を追加する
    - 上記の処理は既に `make validate`（`check-project-version-consistency.linux-x64.bash`）にて実装済み。それを流用できそう。
    - いっそ、静的テストの CI を丸ごと `make static-tests` で行うのではダメなのか？
- [x] `integ-tests` Makeターゲットの実行順序の意図をコメントに明記する
  - `run-integ-test-to-head` → `run-integ-test-to-latest` の順に実行されているが、その意図と副作用の有無が不明
- [x] integ-testに出力内容のアサーションを追加する
  - 現状：「スクリプトがエラーなく完走するか」しか確認していない
    - 出力が空でも、デタラメな内容でも通過してしまう。
  - 修正案：最低限、バージョンヘッダ行・区切り線・OS NAME行などの存在を `grep` でチェックすべき
- [x] `run-integ-test.linux-x64.bash` が `main` ブランチから `install.bash` を取得している意図を明記する
  - 現状：「stable版のテスト」のはずなのに、インストーラー自体は `main` (開発版) から取得している
  - 修正案：意図的であればコメントで明記し、意図的でなければ修正する
  - 各テストにおいて、「stable版（リモート）」「`main` (開発版)（リモート）」「`main` (開発版)（ローカル）」の、どのテストなのかを明確にする
- [ ] `run-format.linux-x64.bash` の `confirm_continue` がCI環境で使えない問題を解消する
  - 対話的な確認を求めるため、CI環境でハングする可能性がある
  - `-y` フラグや `FORCE=true` 環境変数でスキップできるようにすることを検討する
  - この問題が解消されたら、CIのstatic-test.ymlを `make lint` + `make validate` の個別呼び出しから `make static-tests` への一本化も検討すること
    - 現状は `format` の副作用があるため個別呼び出しにしている

### ドキュメント

- [x] `README.md` に `install.bash` がある理由を書く
  - 「常に同じコマンドで最新版をインストールできる」という利点
  - 案：これを使うと常に同じコマンドで最新版をインストールできる。使わない場合、明示的にバージョンを指定しなければならなくて面倒。(特に、別のスクリプト中で 'property' をインストールする場合、バージョン管理しなくてはならず面倒)
  - ADR-004 を書いたので、これをもって対応済みとする
- [ ] `README.md` に `make integ-test` という記載が存在するが正しいターゲット名は `integ-tests`（複数形）なので修正する
  - 具体的には `README.md` の `### How to run integration-test` セクション内の記述
- [ ] `exit` と `return` の使い分け方針をコメントか ADR に明記する
  - `proper7y` の `identify_*()` は `exit 1`、`common.bash` のチェック関数は `return 1` を使っており、方針が不明確
  - **この検討は ADR で行うべき**
- [ ] ChangeLog の書き方を検討する
  - TODO.md の Milestone 流用すれば楽ではないか

### プロジェクト管理

無し。

## Milestone: v0.11.0 - TBD

_タスク未定。_

## Backlog（いつかやる）

### セキュリティ・バグ修正

- [ ] macOSのinteg-testで使用されるBashのバージョンを明示的に指定する
  - `brew install bash` した後も `./proper7y` のshebang `#!/usr/bin/env bash` はPATHの先頭のbashを使うため、インストールしたbashが必ず使われるとは限らない
  - `/opt/homebrew/bin/bash ./proper7y` のように明示するか、PATHを先頭に追加する

### コード・機能

- [ ] `curl` でのファイルダウンロード時にチェックサム検証を追加する
  - 対象: shellcheck および shfmt をダウンロードする際。
  - `.sha256` ファイルの入手方法は要調査。
    - [shfmt v3.13.0 のリリースページ](https://github.com/mvdan/sh/releases/tag/v3.13.0)の説明によれば、 `Note that this release no longer includes a sha256sums.txt asset; GitHub now provide digests natively.` らしい。
    - Ref: [Releases now expose digests for release assets - GitHub Changelog](https://github.blog/changelog/2025-06-03-releases-now-expose-digests-for-release-assets/)
      - GitHub のリリースにアップロードされるアセットに対して、自動で SHA‑256 ダイジェスト（チェックサム）が付くようになった
      - GitHub のリリースページ（UI）で、各アセットの横に SHA‑256 の digest が表示される
      - REST API や GraphQL API、gh CLI からも .digest というフィールドで取得できる
- [ ] コマンドの exit status を整える（正常終了で 0 を返す、など）
- [ ] 最初に OS を特定し、未対応 OS の場合はエラーを返して終了させる
  - `main` 関数の最初で OS を特定し、その情報を変数に保存しておく（現状は `init` で行っているが、整理が必要）
  - "prerequisites exists?", "the os is supported os?" みたいな。
- [ ] 対応する環境・対象とするソフトウェアを明確にする
  - サポートする環境は？（利用者環境/開発者環境それぞれで。）
    - 対応 OS・シェルなど
  - ドキュメント化も忘れずに
- [ ] オプション機能を作るかどうかを決める（→ ADR に検討内容と決定を書くこと）
- [ ] `identify_current_shell_id()` の実装を見直す
  - 現状は `ps` で親プロセスを辿る実装で、macOSとLinuxで挙動が異なり壊れやすい
  - ps で親プロセスを辿る方法は、CI 環境・Docker・`make` 経由での実行など、実行コンテキストが変わると容易に壊れる
  - `$SHELL` 環境変数を使う方法を検討する（ただし「デフォルトシェル」と「実行中のシェル」が異なる場合があるため、そのトレードオフをコメントかADRに明記する）
    - そもそも、ここで表示したい・すべきなのは「デフォルトシェル」なのか「実行中のシェル」なのかの検討から。→ 必要なのは「その proper7y コマンドが実行されたシェル」（つまり「実行中のシェル」）では？
  - 早めの対応が必要だが、検討事項が多くて対応が難しそう
  - **この検討は ADR で行うべき**
- [ ] グローバル変数への依存を減らす
  - `common.bash` の関数群がグローバル変数に強く依存しており、依存関係の理解・関数単体でのテストが困難
    - 例えば install_shellcheck() は $SHELLCHECK_CURRENT_VERSION、$SHELLCHECK_CMD_PATH、$PROJECT_ROOT などを暗黙に参照している
  - 関数が必要な値を引数で受け取る形にすることで、再利用性とテスト可能性が上がる
  - 大規模リファクタリングになるため、長期的な改善として扱う
  - ユニットテストを行うかどうかはまた別の検討事項だが、ユニットテストの有無に関わらずコードの可読性・安全性を高めるために、グローバル変数への依存を減らすべき
- [ ] ファイル名のプラットフォーム縛り（`.linux-x64.bash`）と実態の不一致を解消する
  - `run-lint.linux-x64.bash` 等をLinux/x64専用と命名しているのに、CIのmatrixでmacOSからも呼ばれている
  - 命名を変えるか、macOS非対応であることをドキュメントに明記するか、方針を決める
  - この問題は、このプロジェクト自体の対応 OS の検討（macOS に対応するかどうか）と関連する

### テスト・CI

- [ ] integ-testのアサーションをレベル2・3に強化する (Ref: ADR-005)
  - レベル2: 各フィールドの値が `Unknown` や空でないことを確認する
  - レベル3: より多くのフィールドの値の形式を確認する（現状はCURRENT DATEとBASH VERSIONのみ）
  - CI環境への依存度が高くなるため、環境ごとの期待値の管理方法を先に設計すること
- [ ] `run-integ-test-to-head` には出力内容のアサーションがない (Ref: ADR-005)
- [ ] CI の `run-head-proper7y` Job と `run-integ-test-to-head` が重複している問題を解消する (Ref: ADR-005)
  - 両者はどちらも `./proper7y` を直接実行するだけで、同じことをしている
  - どちらかを削除するか、役割を明確に分けるかを検討する
- [ ] Manjaro Linux をサポートする
  - 開発環境として Manjaro Linux を対応させる
  - CI のテスト環境に Manjaro (Arch-based) を追加する
- [ ] ユニットテストを追加する
  - ShellSpec を検討する
    - ref: [ShellSpec - シェルスクリプト用のフル機能の BDD ユニットテストフレームワーク - Qiita](https://qiita.com/ko1nksm/items/2f01ff4f50e957ebf1de)
    - ref: [シェルスクリプトのテスト、何を使ってる？shUnit2？Bats？ ShellSpec を使ってみませんか？ - Qiita](https://qiita.com/ko1nksm/items/556336797d7e49117842)
    - ref: [ShellSpec - シェルスクリプト用の BDD テスティングフレームワークを作りました - Qiita](https://qiita.com/ko1nksm/items/77388d75b8c1f18c0058)
  - スクリプトの特性上、ユニットテストでテストできる範囲は狭い可能性がある
  - このプロジェクトにおいて、ユニットテストを導入するのは果たしてどうなのか。Bash のユニットテストは、手間に対してリターンが見合わない可能性が高そう。それよりも、インテグレーションテストを厚くした方が良いのではないか？
  - **この検討は ADR で行うべき**
- [ ] CI で devel-tools が最新かどうかを定期チェックする（weekly trigger など）
  - `check-devel-tools-versions.bash` を CI で実行することを検討する
  - 自動で Pull Request を作成するかどうかも検討する（dependabot 的な運用）
    - 実装や権限管理面倒じゃない？大丈夫？
    - そもそも Pull Request はあまり使いたくないのでは？
    - でもあると便利だし、Bot に限れば Pull Request 使っても良いかも。
  - README.md に `dependencies latest` のようなバッジを追加することを検討
  - これ、セキュリティ管理・関連コードのメンテナンスコストが見合わなくない？現状の依存ツール（devel-tools）である 2 つの CLI、shellcheck と shfmt は、バージョン更新が頻繁ではない。ならば現状のまま、手動更新でも良いのではないか？現状の手動更新でも、作業はほぼ全部スクリプト化しているので、手間としてはかなり少ない。下手に GitHub Actions を導入することによるセキュリティリスクの管理などの方が、コストとしては重いのではないか。
    - こういうことは、ADR にて行い、ログを残すべき
- [ ] CIトリガーに `pull_request` と `schedule` を追加することを検討する
  - 現状は `push` のみ
  - 将来ブランチ運用を始めた場合に困る
  - 外部サービス（GitHubのURL、brewパッケージ等）の変化を週次で検知する `schedule` トリガーも有用
  - **この検討は ADR で行うべき**

### ドキュメント

- [ ] README.md を完成させる
  - TL;DR セクションを書く（30秒で読める概要）
  - GIF を追加する（asciinema での録画を検討）
    - ref: <https://dev.classmethod.jp/articles/intro-asciinema/>
  - 全体的に整理する（内容が重複しているところとかありそう？）
  - 使用例（Examples セクション）を書く
    - ref: <https://github.com/rnazmo/proper7y/blob/6b77aee0debf25f4d6f6a1aee8224c84470a765f/README.md#do-not-download-install-proper7y-without-specifying-the-version>
    - 書き方の参考:
      - <https://github.com/golangci/golangci-lint/blob/3c795d8637855c813c7c22fb36a3521c726bcd87/docs/src/docs/usage/install/index.mdx#other-ci>
      - <https://github.com/golangci/golangci-lint/blob/3c795d8637855c813c7c22fb36a3521c726bcd87/docs/src/docs/usage/install/index.mdx#install-from-source>
  - 以下のテキストを追加する:
    - > In this document, `proper7y` indicates the file, 'proper7y' indicates the project (≒ the repository) and `$ proper7y` indicates the command on your console.
- [ ] 対応する環境・対象とするソフトウェアを、README に明確に記述する
- [ ] コーディング規約を更新する
  - 各ルールが SHALL か SHOULD かを明記する
  - Google Shell Style Guide を参照して整備する
  - Conventional Commits を導入するか検討する
    - そして、その検討・決定内容はADR に書くべき
  - ブランチ運用の方針を改定することを検討
    - やっぱり、変更が大きいときは branch 使いたいから。main だけだと厳しい場面がある
      - 「なるべく `main` だけ」を維持しつつ、一時的なブランチを許容する？
      - この検討・決定内容はADR に書くべき
    - 変更するなら、README.md の規約の branch セクションも更新を忘れないこと
      - README に明記する新規約の記述案：「**なるべく `main` だけ**の状態を維持することが望ましい。ただし、機能追加などで**一時的な**ブランチを作るのは全く構わない」
- [ ] ChangeLog を追加することを検討
  - TODO.md の Milestone をそのままコピペする運用ならば、運用負荷は少ないのではないか。
  - そもそも必要？
  - **この検討は ADR で行うべき**

### プロジェクト管理

- [ ] v1.0.0 までに必要なものを考える・整理する
  - 対応する環境・対象とするソフトウェアをはっきりさせる
  - README.md を最低限完成させる

### 将来検討

- [ ] Golang での全面書き換えの検討
  - 様々な環境への対応が用意になる
  - このアプリを作る＆メンテする目的の 1 つは `For learning bash script` である。よって、Bash script でやるべき。どうしても辛くなって Golang などで作り直したい場合は、アプリの目的も含めて見直すこと
  - **この検討は ADR で行うべき**
- [ ] Windows 対応の検討
  - Windows の対応は大変だしコードが複雑になる。対応したいなら、別リポジトリ `proper7y4win` として切り出すべき（PowerShell スクリプトで実装する）
  - **この検討は ADR で行うべき**
