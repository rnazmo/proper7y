# TODO

## Milestone: v0.10.0 - セキュリティ修正 + 簡単な改善

- [ ] `install_shellcheck()` で `trap` を使ってtempディレクトリのクリーンアップを保証する
  - 現状は `curl` や `tar` が失敗したとき、`rm -rf "$TEMP_DIR"` が実行されずにゴミが残る
  - `trap "rm -rf '$TEMP_DIR'" EXIT` を使うことで、成功・失敗問わず必ずクリーンアップされる
- [ ] `curl` でのファイルダウンロード時にチェックサム検証を追加する
  - 対象: `install_shellcheck()` および `run-integ-test.linux-x64.bash`
  - ShellCheckのGitHubリリースには `.sha256` ファイルが提供されているので、`sha256sum -c` で検証する
- [ ] `verify_version_consistency()` の `grep` パターンを堅牢にする
  - 現状: `grep 'PROPER7Y_VERSION='` はコメント行の途中に文字列が現れた場合に誤マッチする
  - 修正案: `^PROPER7Y_VERSION=` のように行頭アンカーを付ける
- [ ] `print_os_version()` の `lsb_release` 依存を `/etc/os-release` に置き換える
  - `lsb_release` はDockerの最小イメージなど一部のDebian系環境に存在しない場合がある
  - `/etc/os-release` の `VERSION_ID` を使う方が堅牢: `grep VERSION_ID /etc/os-release | cut -d= -f2 | tr -d '"'`
- [ ] GitHub Actions の `actions/checkout` を `v2` から `v4` に更新する
  - `v2` はNode.js 16ベースでGitHubが非推奨化している
- [ ] `exit` と `return` の使い分け方針をコメントか ADR に明記する
  - `proper7y` の `identify_*()` は `exit 1`、`common.bash` のチェック関数は `return 1` を使っており、方針が不明確
  - **この検討は ADR で行うべき**
- [ ] `integ-tests` Makeターゲットの実行順序の意図をコメントに明記する
  - `run-integ-test-to-head` → `run-integ-test-to-latest` の順に実行されているが、その意図と副作用の有無が不明

## Milestone: v0.11.0 - TBD

*タスク未定。*

## Backlog（いつかやる）

### セキュリティ・バグ修正

*(無し)*

### コード・機能

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
  - `$SHELL` 環境変数を使う方法を検討する（ただし「デフォルトシェル」と「実行中のシェル」が異なる場合があるため、そのトレードオフをコメントかADRに明記する）
  - **この検討は ADR で行うべき**

### テスト・CI

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

### ドキュメント

- [ ] README.md を完成させる
  - TL;DR セクションを書く（30秒で読める概要）
  - GIF を追加する（asciinema での録画を検討）
    - ref: https://dev.classmethod.jp/articles/intro-asciinema/
  - 全体的に整理する（内容が重複しているところとかありそう？）
  - 使用例（Examples セクション）を書く
  - `install.bash` がある理由を書く
    - 「常に同じコマンドで最新版をインストールできる」という利点
        - > これを使うと常に同じコマンドで最新版をインストールできる。使わない場合、明示的にバージョンを指定しなければならなくて面倒。(特に、別のスクリプト中で 'property' をインストールする場合、バージョン管理しなくてはならず面倒)
    - ref: https://github.com/rnazmo/proper7y/blob/6b77aee0debf25f4d6f6a1aee8224c84470a765f/README.md#do-not-download-install-proper7y-without-specifying-the-version
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
