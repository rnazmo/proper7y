# TODO (proper7y)

## Milestone: v0.10.0 - 堅牢性の向上とコードの整理

### セキュリティ・バグ修正

- [x] `print_os_version()` が EndeavourOS 等のローリングリリース系ディストリビューションで空欄になるバグを修正する
  - 症状：ローカルで `./proper7y` を実行したときに、出力の OS VERSION が空欄になってしまっていた
  - 原因：`VERSION_ID` が `/etc/os-release` に存在しないディストリビューションがある
  - 修正：`VERSION_ID` が取れない場合に `BUILD_ID=rolling` を確認し、`"Rolling Release"` を表示するフォールバックを追加した
  - 詳細は ADR-015 を参照
- [x] macOSのinteg-testで使用されるBashのバージョンを明示的に指定する
  - `brew install bash` した後も `./proper7y` のshebang `#!/usr/bin/env bash` はPATHの先頭のbashを使うため、インストールしたbashが必ず使われるとは限らない
  - `/opt/homebrew/bin/bash ./proper7y` のように明示するか、PATHを先頭に追加する

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
- [x] `Makefile` の `static-tests` ターゲットから `format` を外すことを検討する
  - 現状：`static-tests: lint format validate` と定義されており、`pre-commit` 時にファイルが意図せず上書きされる可能性がある
  - `format` はファイルを上書きする副作用を持つため、差分チェックのみ行う `lint` とは役割が根本的に異なる
  - CI での `make static-tests` 実行にも適さない。実際に `static-test.yml` では `make static-tests` を使わず `make lint` と `make validate` を個別に呼んでいる
  - 修正案：`static-tests: lint validate` に変更する。`format` は明示的に `make format` で呼ぶ運用にするか、`pre-commit` などの別ターゲットにのみ含める
    - しかし、そうするとローカルでの確認の際に `make static-tests` だけで完結しなくなり不便。ローカルでの確認の際に楽をしたいので、コマンド一発で全部確認できると嬉しい
- [x] `common.bash` の `initialize_global_variables()` が2回呼ばれるとエラーになる問題を文書化または修正する
  - 現状：関数内で `readonly` 宣言しているため、2回呼ぶと readonly 変数への再代入でエラーになる。現状は1回しか呼ばれていないが、将来的な罠になる
  - 修正案：「1回しか呼んではいけない」という制約をコメントで明記する（最小コスト）か、冪等に動作するよう設計し直す
  - これ、common.bash やグローバル変数周りの根本的な設計に関わりそうなので、慎重に検討する必要がありそう。
  - → 今回の変更では「冪等設計」を採用せず、該当関数の上部にコメントを追加するに留めた。common.bash のグローバル変数設計自体をいずれ見直す予定なので、そのときに改めて「冪等設計」にするかどうかを検討する予定。
- [x] `install_shellcheck()` 内の `trap EXIT` がプロセス全体を上書きする問題について検討する
  - 現状：関数内で `trap 'rm -rf ...' EXIT` を設定しているが、**`trap EXIT` はプロセス全体に対して設定される**ため、後続の関数呼び出し（`install_shfmt` など）と干渉する可能性がある
    - 具体的には、install_shellcheck() が呼ばれた後に install_shfmt() が呼ばれると、shfmt のインストール中にも shellcheck の TEMP_DIR の trap が上書きされるか、あるいは意図しないタイミングで発火する可能性がある
  - 修正案：サブシェル `( )` に処理を閉じ込めて trap のスコープを関数内に限定する、または trap のスコープ管理方針を明示的に設計し直す
  - 対応：サブシェル `( )` に閉じ込める方法で修正した。`_recompose_shellcheck_binary_version` はグローバル変数を変更するためサブシェルの外に置いた
- [x] `run-integ-test.linux-x64.bash` の `main()` 内にも `trap EXIT` がある。これも、`install_shellcheck()` 内の `trap EXIT` と同様に「サブシェルで処理を閉じ込める」必要があるかどうか検討する。
  - 検討結果：**変更不要**。`main()` はスクリプトのトップレベルであり、後続で `trap EXIT` を上書きする処理が存在しないため、`install_shellcheck()` が抱えていた問題は発生しない。詳細は ADR-008 を参照。
- [x] コマンドの exit status を整える（正常終了で 0 を返す、など）
- [x] ファイル名のプラットフォーム縛り（`.linux-x64.bash`）と実態の不一致を解消する
  - `run-lint.linux-x64.bash` 等をLinux/x64専用と命名しているのに、CIのmatrixでmacOSからも呼ばれている
  - 命名を変えるか、macOS非対応であることをドキュメントに明記するか、方針を決める
  - この問題は、このプロジェクト自体の対応 OS の検討（macOS に対応するかどうか）と関連する
  - **この検討は ADR で行うべき**
  - `run-integ-test.bash` にリネームした。他のスクリプトは Linux/x64 専用のため維持 (ADR-009)
- [x] 最初に OS を特定し、未対応 OS の場合はエラーを返して終了させる
  - `main` 関数の最初で OS を特定し、その情報を変数に保存しておく（現状は `init` で行っているが、整理が必要）
  - "prerequisites exists?", "the os is supported os?" みたいな。
- [x] `curl` でのファイルダウンロード時にチェックサム検証を追加することを検討する
  - 対象: shellcheck および shfmt をダウンロードする際。
  - `.sha256` ファイルの入手方法は要調査。
    - [shfmt v3.13.0 のリリースページ](https://github.com/mvdan/sh/releases/tag/v3.13.0)の説明によれば、 `Note that this release no longer includes a sha256sums.txt asset; GitHub now provide digests natively.` らしい。
    - Ref: [Releases now expose digests for release assets - GitHub Changelog](https://github.blog/changelog/2025-06-03-releases-now-expose-digests-for-release-assets/)
      - GitHub のリリースにアップロードされるアセットに対して、自動で SHA‑256 ダイジェスト（チェックサム）が付くようになった
      - GitHub のリリースページ（UI）で、各アセットの横に SHA‑256 の digest が表示される
      - REST API や GraphQL API、gh CLI からも .digest というフィールドで取得できる
    - -> 検討の結果、実装しないことにした (ADR-014)
- [ ] `identify_current_shell_id()` の実装を見直す
  - 現状は `ps` で親プロセスを辿る実装で、macOSとLinuxで挙動が異なり壊れやすい
  - ps で親プロセスを辿る方法は、CI 環境・Docker・`make` 経由での実行など、実行コンテキストが変わると容易に壊れる
  - `$SHELL` 環境変数を使う方法を検討する（ただし「デフォルトシェル」と「実行中のシェル」が異なる場合があるため、そのトレードオフをコメントかADRに明記する）
    - そもそも、ここで表示したい・すべきなのは「デフォルトシェル」なのか「実行中のシェル」なのかの検討から。→ 必要なのは「その proper7y コマンドが実行されたシェル」（つまり「実行中のシェル」）では？
  - 早めの対応が必要だが、検討事項が多くて対応が難しそう
  - **この検討は ADR で行うべき**
  - **この関数はスクリプトの中核機能に近いため、早急に行うべき**
- [ ] グローバル変数への依存を減らす（`common.bash` のグローバル変数設計の再考）
  - `common.bash` の関数群がグローバル変数に強く依存しており、依存関係の理解・関数単体でのテストが困難
    - 例えば install_shellcheck() は $SHELLCHECK_CURRENT_VERSION、$SHELLCHECK_CMD_PATH、$PROJECT_ROOT などを暗黙に参照している
  - 関数が必要な値を引数で受け取る形にすることで、再利用性とテスト可能性が上がる
  - 大規模リファクタリングになるため、長期的な改善として扱う
  - ユニットテストを行うかどうかはまた別の検討事項だが、ユニットテストの有無に関わらずコードの可読性・安全性を高めるために、グローバル変数への依存を減らすべき
  - また、現状 `common.bash` の `initialize_global_variables()` が2回呼ばれるとエラーになる設計になっている（関数内で `readonly` 宣言している）ので、それも考慮すること。具体的には、冪等に動作するよう設計し直すことを検討。
- [ ] Manjaro Linux をサポートする
  - 開発環境として Manjaro Linux を対応させる
  - CI のテスト環境に Manjaro (Arch-based) を追加する
- [x] ADR-015 にてローリングリリース系ディストリビューションでは、`OS VERSION` として `Rolling Release` を表示することを決定したが、この判断が適切かどうかを再検討する
  - 例えば、Arch Linux は常に最新の状態を維持することが推奨されているため、`Rolling Release` と表示するのは適切な気もする
  - 一方で、Arch Linux ユーザーは自分の環境がローリングリリースであることを当然知っている
  - また、それだけでは proper7y が出力すべき「環境情報」としては不足しているのではないか
  - より具体的なバージョン情報を表示した方が有用な気もする。例えば、Linux カーネルや主要なパッケージのバージョン情報
    - uname -r や pacman -Q の結果などで取得できるような情報
  - **この検討は ADR で行うべき**
  - ADR-022 にて、すべての Linux 環境で `KERNEL VERSION` フィールドを追加することを決定した
  - 主要パッケージ情報の表示は効果が不明確なため見送り、将来バックログで再検討する
- [ ] `print_chassis()` を実装して出力に追加することを検討する
  - シャーシ情報（desktop / laptop / server 等）を表示する機能
  - `hostnamectl status | grep "Chassis:"` で取得できる
  - 削除時の実装: `CHASSIS=$(hostnamectl status | grep "Chassis:" | sed "s/ *Chassis: //")`
- [x] サポート環境の明文化
  - [x] ADR を書く: サポート環境の定義（利用者環境・開発者環境）
    - 利用者環境: Linux (Arch系・Debian系) は正式サポート。macOS はベストエフォート
    - 開発者環境 (devel-tools): Linux x64 のみ正式サポート
    - macOS は手元マシンがなく完全な動作保証ができない。CI での確認のみ行う
    - devel-tools のファイル名 (.linux-x64.bash) と実態・ドキュメントの不一致を解消する
  - [x] README.md を更新する: 利用者環境のサポート対象を明記する
    - macOS は "best-effort" 扱いであることを明記する
    - Linux は Arch系・Debian系が正式サポートであることを明記する
    - 対象箇所: `### Supported softwares` セクション
  - [x] README.md を更新する: 開発者環境のサポート対象を明記する
    - 対象箇所: `### Prerequisite` セクション
    - 現状「debian-based Linux && x64」とあるが「Linux x64」に修正する
- [x] 表示スコープと設計方向性の明文化
  - [ ] ADR を書く: proper7y の表示スコープと将来の設計方向性
    - proper7y が表示する情報のスコープを「マシングローバルな環境情報」に限定すると定義する
    - 方向性B（選択的表示機能）を将来の検討事項とした理由を記録する
    - 方向性C（用途別スクリプト群）を将来の検討事項とした理由を記録する
  - [ ] README.md を更新する: proper7y の表示スコープを明記する
    - 対象箇所: `### Purpose of this project` セクション付近
    - 「マシングローバルな環境情報を出力するツール」という定義を追加する

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
- [x] integ-testのアサーションをレベル2に強化する (Ref: ADR-005)
  - レベル2: 各フィールドの値が `Unknown` や空でないことを確認する
  - **優先度を上げること。** `OS VERSION` が空欄になるバグ（ADR-015）が長期間気づかれなかった直接の原因が、レベル2のアサーションが未実装であることだった。このタスクはバグの早期検出に直結する。
- [x] CIトリガーに `pull_request` と `schedule` を追加することを検討する
  - 現状は `push` のみ
  - 将来ブランチ運用を始めた場合に困る
  - 外部サービス（GitHubのURL、brewパッケージ等）の変化を週次で検知する `schedule` トリガーも有用
  - **この検討は ADR で行うべき**
  - → `pull_request` は追加しない。`schedule` (weekly) を `integ-test.yml` に追加した。詳細は ADR-015 参照。

### ドキュメント

- [x] `README.md` に `install.bash` がある理由を書く
  - 「常に同じコマンドで最新版をインストールできる」という利点
  - 案：これを使うと常に同じコマンドで最新版をインストールできる。使わない場合、明示的にバージョンを指定しなければならなくて面倒。(特に、別のスクリプト中で 'property' をインストールする場合、バージョン管理しなくてはならず面倒)
  - ADR-004 を書いたので、これをもって対応済みとする
- [x] `README.md` に `make integ-test` という記載が存在するが正しいターゲット名は `integ-tests`（複数形）なので修正する
  - 具体的には `README.md` の `### How to run integration-test` セクション内の記述
- [x] ChangeLog を追加することを検討
  - TODO.md の Milestone セクションの内容をそのまま流用する運用を検討する。（それなら楽そう）
  - そもそも必要？
- [x] `exit` と `return` の使い分け方針をコメントか ADR に明記する
  - `proper7y` の `identify_*()` は `exit 1`、`common.bash` のチェック関数は `return 1` を使っており、方針が不明確
  - 既存コードで混在が発生している。早急に行うべき。
  - **この検討は ADR で行うべき**
- [x] Conventional Commits の採用可否を ADR に記録する
  - ~~Conventional Commits を導入するか検討する~~ 既に導入している。
  - 運用を始めているなら、決定を ADR に明文化すべき
  - **この検討は ADR で行うべき**
- [x] `bump-project.linux-x64.bash` と `check-devel-tools-versions.linux-x64.bash` のハードコードされたコミットメッセージを Conventional Commits 形式に修正する
  - `bump-project.linux-x64.bash`: `"Bump project version: ..."` → `"chore: bump version to ..."`
  - `check-devel-tools-versions.linux-x64.bash`: `"Bump devel-tool version ($TOOL_NAME): ..."` → `"chore($TOOL_NAME): bump version ..."`
  - ADR-009 にて、既存のハードコード文字列は今回変更しないと決定した。この作業はその持ち越し分。
- [x] README.md の未完成セクション `TL;DR` を埋める
  - 30秒で読める概要
- [x] README.md の未完成セクション `Examples` を埋める
  - サンプル出力ログ。使用例。
  - ref: <https://github.com/rnazmo/proper7y/blob/6b77aee0debf25f4d6f6a1aee8224c84470a765f/README.md#do-not-download-install-proper7y-without-specifying-the-version>
  - 書き方の参考:
    - <https://github.com/golangci/golangci-lint/blob/3c795d8637855c813c7c22fb36a3521c726bcd87/docs/src/docs/usage/install/index.mdx#other-ci>
    - <https://github.com/golangci/golangci-lint/blob/3c795d8637855c813c7c22fb36a3521c726bcd87/docs/src/docs/usage/install/index.mdx#install-from-source>
- [ ] README.md に GIF 動画を追加する
  - [ ] フェーズ1: 意思決定
    - [ ] 録画ツールを選定する（候補: charmbracelet/vhs, asciinema）
      - ref: <https://dev.classmethod.jp/articles/intro-asciinema/）>
  - [ ] フェーズ2: 準備
    - [ ] 選定ツールをインストールし、試し録りして品質・操作感を確認する
  - [ ] フェーズ3: 本番作業
    - [ ] 録画シナリオを書く
    - [ ] 本番録画してGIFを生成する
    - [ ] GIFの配置先を決め、README.md に埋め込む
  - [ ] フェーズ4: 後処理
    - [ ] 録画・更新手順をドキュメント化する（将来のメンテコスト削減のため）
    - [ ] インストールスクリプト化の要否を判断し、必要なら実施する
    - [ ] ADR.md に意思決定を記録する
- [x] README.md のどこかに以下のようなテキストを追加する:
  - > In this document, `proper7y` indicates the file, 'proper7y' indicates the project (≒ the repository) and `$ proper7y` indicates the command on your console.
- [x] README.md の Notes セクション内にある冗長な括弧書き（`(this indicates 'proper7y' as the file)` など）を削除する
  - 一つ上のタスクにて README.md の冒頭に用語の凡例を追加したことで、これらの括弧書きは不要になった
- [ ] このプロジェクトが対応する環境・対象とするソフトウェアを、どこかで明確に記述する（README.md? ADR?）
- [ ] コード内コメント・コミットメッセージ・ADR・README・TODO などのドキュメントの言語を明示的にする。どこかに書いておく
- [x] README.md のコーディング規約を更新する
  - 各ルールが SHALL か SHOULD かを明記する
  - Google Shell Style Guide を参照して整備する
  - ブランチ運用の方針を改定することを検討
    - やっぱり、変更が大きいときは branch 使いたいから。main だけだと厳しい場面がある
      - 「なるべく `main` だけ」を維持しつつ、一時的なブランチを許容する？
      - この検討・決定内容はADR に書くべき
    - 変更するなら、README.md の規約の branch セクションも更新を忘れないこと
      - README に明記する新規約の記述案：「**なるべく `main` だけ**の状態を維持することが望ましい。ただし、機能追加などで**一時的な**ブランチを作るのは全く構わない」
  - アイデアメモ：例えば、次のような内容を書きたい：
    - シェルスクリプトはshellcheck（--exclude SC1091）とshfmt（-i 2）に準拠する
    - インデントはスペース2つ
    - 関数名はスネークケース
- [ ] README.md のコーディング規約を再考する
  - 具体的に何を追加すべきかは、まだ不明確
  - 現在の規約セクションを見直し、不足している項目（例: シェルスクリプトの命名規則、関数のドキュメントコメント形式など）をリストアップする
  - それをもとにタスクを具体化する
- [ ] CHANGELOG.md の初回作成（ADR-007 関連）
  - v0.10.0 のリリース前に CHANGELOG の下書きを作成する
  - ADR-007 に記載されているワークフローに従って作業する

### プロジェクト管理

- [x] TODO.md の `Milestone: v0.10.0` のタイトルを考える
- [ ] TODO.md の `Milestone: v0.11.0` を策定
- [x] Golang での全面書き換えの検討
  - 様々な環境への対応が用意になる
  - このアプリを作る＆メンテする目的の 1 つは `For learning bash script` である。よって、Bash script でやるべき。どうしても辛くなって Golang などで作り直したい場合は、アプリの目的も含めて見直すこと
  - **この検討は ADR で行うべき**
- [x] Windows 対応の検討
  - Windows の対応は大変だしコードが複雑になる。対応したいなら、別リポジトリ `proper7y4win` として切り出すべき（PowerShell スクリプトで実装する）
  - **この検討は ADR で行うべき**

## Milestone: v0.11.0 - テスト戦略の再設計

### テスト・CI

- [ ] ユニットテストを追加することを検討する
  - ShellSpec を検討する
    - ref: [ShellSpec - シェルスクリプト用のフル機能の BDD ユニットテストフレームワーク - Qiita](https://qiita.com/ko1nksm/items/2f01ff4f50e957ebf1de)
    - ref: [シェルスクリプトのテスト、何を使ってる？shUnit2？Bats？ ShellSpec を使ってみませんか？ - Qiita](https://qiita.com/ko1nksm/items/556336797d7e49117842)
    - ref: [ShellSpec - シェルスクリプト用の BDD テスティングフレームワークを作りました - Qiita](https://qiita.com/ko1nksm/items/77388d75b8c1f18c0058)
  - スクリプトの特性上、ユニットテストでテストできる範囲は狭い可能性がある
  - このプロジェクトにおいて、ユニットテストを導入するのは果たしてどうなのか。Bash のユニットテストは、手間に対してリターンが見合わない可能性が高そう。それよりも、インテグレーションテストを厚くした方が良いのではないか？
  - **この検討は ADR で行うべき**
- [ ] integ-testのアサーションをレベル3に強化する (Ref: ADR-005)
  - レベル3: より多くのフィールドの値の形式を確認する（現状はCURRENT DATEとBASH VERSIONのみ）
  - 候補: CPU ARCH（英数字・アンダースコア形式）、OS VERSION（数字ドット形式）
  - CURRENT SHELL の Unknown チェック対象への包含可否も合わせて検討する
  - CI環境への依存度が高くなるため、環境ごとの期待値の管理方法を先に設計すること
- [ ] `run-format.linux-x64.bash` の `confirm_continue` がCI環境で使えない問題を解消する
  - 対話的な確認を求めるため、CI環境でハングする可能性がある
  - `-y` フラグや `FORCE=true` 環境変数でスキップできるようにすることを検討する
  - この問題が解消されたら、CIのstatic-test.ymlを `make lint` + `make validate` の個別呼び出しから `make static-tests` への一本化も検討すること
    - 現状は `format` の副作用があるため個別呼び出しにしている
- [ ] CI でのテスト環境に Arch Linux, EndeavourOS, Manjaro Linux などを追加する

### ドキュメント

## Backlog（いつかやる）

### セキュリティ・バグ修正

### コード・機能

- [ ] 表示スコープと設計方向性の検討
  - [ ] 選択的表示機能の検討
    - 背景: proper7y は現在「実行すれば全情報が出る」設計だが、
      用途（フロントエンド記事・Go記事など）によって必要な情報が異なるという課題がある
    - 案: `proper7y --frontend` や `proper7y --with node,react` のようなフラグ指定で
      表示するツールを選べるようにする
    - 保留理由: proper7y のスコープ（マシングローバルな環境情報）と
      プロジェクトローカルな情報（React, Vite 等）の混在問題が未解決
    - 実装前に必ず ADR で設計を議論すること
  - [ ] 用途別スクリプト群の検討
    - 背景: 上記の選択的表示機能と同じ課題への別アプローチ
    - 案: proper7y 本体はコア情報のみ出力し、用途別の環境情報は
      別スクリプト（例: proper7y-frontend）として切り出す
    - 未決定事項: このプロジェクトの管轄とするかどうか含めて未決定
    - 実装前に必ず ADR で設計を議論すること
  - [ ] ワンライナー集ドキュメントの作成
    - 背景: 上記2案と同じ課題への別アプローチ（スクリプト化せずドキュメント化する案）
    - 案: 各ツールのバージョン情報を取得するワンライナーをまとめた Markdown を作成する
    - proper7y とは独立したドキュメントとして管理することを想定
    - 着手前にスコープ（どのツールを対象とするか）を決めること
- [ ] オプション機能を作るかどうかを決める（→ ADR に検討内容と決定を書くこと）

### テスト・CI

- [ ] `run-integ-test-to-head` には出力内容のアサーションがない (Ref: ADR-005)
- [ ] CI の `run-head-proper7y` Job と `run-integ-test-to-head` が重複している問題を解消する (Ref: ADR-005)
  - 両者はどちらも `./proper7y` を直接実行するだけで、同じことをしている
  - どちらかを削除するか、役割を明確に分けるかを検討する

### ドキュメント

- [ ] README.md を完成させる
  - 今あるセクションが妥当かどうか検討（不足・重複しているセクションがないか）
  - 既存のセクションの内容が妥当かどうか検討（更新すべき記述多そう）
    - ポリシーのセクションの内容は妥当？
  - 全体的に整理する（内容の重複とか、色々整えるとか）

### プロジェクト管理

- [ ] v1.0.0 までに必要なものを考える・整理する
  - 対応する環境・対象とするソフトウェアをはっきりさせる
  - README.md を最低限完成させる

### 将来検討
