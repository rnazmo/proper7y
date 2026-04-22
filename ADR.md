# ADR (proper7y)

## ADR-020: サポート環境の定義（利用者環境・開発者環境）

- **日付:** 2026-04-22
- **状況:**
  - proper7y がサポートする環境について、コード上は一定の実装があるものの、
    「どの環境を正式にサポートするか」がドキュメントとして明文化されていなかった。
  - 特に以下の2点が不明確だった。
    - macOS: コード上は対応しており CI (GitHub Actions) でも動作確認しているが、
      開発者が手元に macOS マシンを持っていないため、完全な動作保証ができない。
    - 開発者環境: `devel-tools/script/` 以下のスクリプトのファイル名に
      `.linux-x64.bash` というサフィックスがついているが、
      README.md の Prerequisite セクションには「debian-based Linux && x64」と
      書かれており、ファイル名・コード・ドキュメントの間で表記が統一されていなかった。
- **決定:**
  - **利用者環境**（`proper7y` コマンドが動く環境）:
    - Linux (Arch系・Debian系): 正式サポート
    - macOS: ベストエフォート（「動作する可能性が高いが完全な動作保証はしない」）
    - Shell: Bash (>= 4.0), Zsh
  - **開発者環境**（`devel-tools` が動く環境）:
    - Linux x64 のみを正式サポート対象とする
    - macOS では `devel-tools` は動作しない（shellcheck・shfmt のバイナリ取得 URL が
      linux.x86_64 固定であること、`sed -i` が GNU sed 構文であることが理由）
- **理由:**
  - **利用者環境における macOS のベストエフォート扱い:**
    - macOS 対応のコード自体はすでに存在しており、CI の `macos-latest` ランナーでも
      動作確認している。完全に対象外にする理由はない。
    - 一方、手元マシンがないため macOS 固有のバグが出たときにデバッグできない。
      「正式サポート」と宣言するのは誠実ではない。
    - よって「ベストエフォート」という中間的な位置づけが実態に最も合っている。
  - **開発者環境を Linux x64 に限定する理由:**
    - devel-tools は開発者自身（≒ 将来の自分）だけが使うものであり、
      自分が実際に使う環境だけをサポートすれば十分である。
    - macOS 対応を広げると devel-tools のバイナリ管理が複雑化する。
      このプロジェクトのポリシー（Simple code, Minimum dependencies）に反する。
    - ファイル名の `.linux-x64.bash` サフィックスはこの方針を正しく表現しており、
      ドキュメントをファイル名の実態に合わせる形で統一する。
- **影響:**
  - README.md の `### Supported softwares` セクションに利用者環境の定義を追記する。
  - README.md の `### Prerequisite` セクションを
    「debian-based Linux && x64」から「Linux x64」に修正する。

## ADR-019: CIトリガーへの `schedule` 追加方針

- **日付:** 2026-04-22
- **状況:**
  - CIのトリガーは `push` のみであり、外部依存（GitHub の raw URL からの `install.bash` 取得、
    proper7y の実行）が時間経過によって壊れても自動では検知できない状態だった。
  - TODO.md のバックログに「CIトリガーに `pull_request` と `schedule` を追加することを検討する」
    というタスクが存在していた。
- **決定:**
  - `schedule` (weekly) を `integ-test.yml` に追加する。
  - `pull_request` トリガーは追加しない。
  - `static-test.yml` への `schedule` 追加も行わない。
- **理由:**
  - **`schedule` を追加する理由:** 外部URL（`https://raw.githubusercontent.com/rnazmo/proper7y/main/install.bash`）
    からのダウンロードや proper7y の実行が、コードの変更なしに時間経過で壊れるケースがある。
    weekly で `make integ-tests` を走らせることでそれを自動検知できる。実装コストは `.yml` への
    数行追加のみであり、コストに対して得られる価値が十分ある。
  - **`pull_request` を追加しない理由:** 現在のブランチ運用方針（README.md）は「なるべく `main` だけ」
    であり、Pull Request を常態的に使う運用ではない。トリガーを追加しても現状の開発フローでは
    恩恵がない。将来ブランチ運用を始める際に改めて追加すれば十分である。
  - **`static-test.yml` に `schedule` を追加しない理由:** 静的テスト（lint, validate）はコードが
    変わらなければ結果も変わらないため、定期実行に意味がない。
- **補足:**
  - GitHub Actions の `schedule` トリガーはリポジトリが一定期間（約60日）無操作だと自動で
    無効化される仕様がある。長期間コードを触らない場合は手動で再有効化が必要になる点に注意。

## ADR-018: CI での devel-tools 定期バージョンチェックを導入しない

- **日付:** 2026-04-22
- **状況:**
  - TODO.md のバックログに「CI で devel-tools が最新かどうかを定期チェックする（weekly trigger など）ことを検討する」というタスクが存在していた。
  - 対象は shellcheck および shfmt の2つのツール。`check-devel-tools-versions.linux-x64.bash` が既に実装済みであり、技術的には流用可能な状態だった。
- **決定:** 導入しない。タスクをバックログから削除する。
- **理由:**
  - **更新頻度が低い:** shellcheck・shfmt はバージョン更新が頻繁ではなく、週次チェックを自動化するほどの必要性がない。
  - **手動更新コストが既に低い:** `make check-devel-tools-versions` でほぼ全作業がスクリプト化されており、手動更新の手間は現状でも十分に小さい。
  - **GitHub Actions 導入によるコストが見合わない:** schedule トリガーの追加・権限管理・ワークフローのメンテナンスといった運用コストが、得られる恩恵を上回ると判断した。
  - **自動 PR はポリシーに反する:** このプロジェクトは「Pull Request をなるべく使わない」方針を持っており（README.md 参照）、Bot による自動 PR 作成もその精神に反する。
  - **利用者が自分のみ:** 外部に配布するプロダクションシステムではなく、依存ツールの陳腐化による実害は限定的である。

## ADR-017: shellcheck SC2329 への対応方針

- **日付:** 2026-04-22
- **状況:**
  - shellcheck を v0.10.0 から v0.11.0 にアップグレード後、`proper7y` などのトップレベルスクリプトに
    `exit 0` を追加したタイミングで `make static-tests` が失敗するようになった。
    - [Bump devel-tool version (shellcheck): v0.10.0 -> v0.11.0 · rnazmo／proper7y@e8f3095](https://github.com/rnazmo/proper7y/commit/e8f309521e676170437d9e6259dd81d2ba7d314e)
    - [docs(ADR): add ADR-011 for explicit exit 0 policy · rnazmo／proper7y@77f7168](https://github.com/rnazmo/proper7y/commit/77f7168c684394395e5fbc88f9a194e661156c99)
    - [feat: explicitly exit 0 on success in proper7y and install.bash (ADR-… · rnazmo／proper7y@d2a6175](https://github.com/rnazmo/proper7y/commit/d2a61752fa51caef25473515fe1f48b59b0c5c56)
    - [feat: explicitly exit 0 on success in devel-tools scripts (ADR-011) · rnazmo／proper7y@c473df2](https://github.com/rnazmo/proper7y/commit/c473df2cee9daed8654b4455ec5d9c98997ab1b2)
  - エラーの内容は SC2329（未使用関数の警告）で、対象は
    - `proper7y`: `print_chassis()`、`log_info()`、`log_warn()` の3関数
    - `check-devel-tools-versions.linux-x64.bash`: `bump_shellcheck_version()`, `bump_shfmt_version()` の2関数
  - SC2329 は v0.11.0 で新設されたルールであり、v0.10.0 では存在しなかった。
  - 問題が表面化した直接的なトリガーは `exit 0` の追加（ADR-011 に基づくコミット）だった。
    公式 [ShellCheck: SC2329 – This function is never invoked. Check usage (or ignored if invoked indirectly).](https://www.shellcheck.net/wiki/SC2329)
    を読むと、次のように書いてある：
    - > Note that if the example script did not end in exit, this warning would not be emitted. This is because the function could be invoked by another script that sources it.
  - つまり「v0.11.0 へのアップグレード」と「`exit 0` の追加」という2つの変更が
    組み合わさって初めて問題が表面化した。
- **検討した対応策:**
  - **案A:** 未使用関数を削除する
  - **案B:** `--exclude SC2329` で警告を抑制する
  - **案C:** `# shellcheck disable=SC2329` でインラインに抑制する
  - **案D:** このトラブルの記録としてインシデントレポート用の新ファイルを追加する
- **決定:**
  - `proper7y` の3関数については案Aを採用する
  - `check-devel-tools-versions.linux-x64.bash` の2関数については案Cを採用する
  - 案Dは採用しない
- **理由:**
  - 案Bと案Cは根本解決ではなく、未使用コードを残すことを正当化する理由がない。
  - 案Aが最もシンプルで、コードの健全性を保てる。
  - ただし、`check-devel-tools-versions.linux-x64.bash` の2関数については、他の関数に引数として渡すという形で間接的に呼ばれている。そのため削除できない。インラインで警告を抑制する案Cが妥当。
  - 案Dは、README.md の "Fewer files" ポリシーに反することと、
    同様のトラブルが継続的に発生する見込みが現時点では薄く、
    ファイルを作っても放置されるリスクが高いため採用しない。
    今後同様のトラブルが頻発するようであれば再検討する。
- **対応内容:**
  - `print_chassis()` : 将来の機能追加で使う可能性があるため、実装内容を
    TODO.md のバックログに残したうえで削除する。
  - `log_info()`, `log_warn()` : 再実装が容易なため、そのまま削除する。
    - bump_shellcheck_version()`,`bump_shfmt_version()` : 関数の上部にディレクティブを追加する
- **教訓:**
  - 複数の変更が組み合わさって初めて問題が表面化するケースがある。
    今回は「新ルールを含む shellcheck へのアップグレード」と
    「`exit 0` の追加」という独立した2つの変更が原因だった。
  - devel-tools をアップグレードした後は、静的テストをその場で実行して
    確認する習慣をつけるとこのようなケースを早期に発見できる。

## ADR-016: Golang への全面書き換えを行わない

- **日付:** 2026-04-22
- **状況:**
  - TODO.md のバックログに「Golang での全面書き換えの検討」というタスクが存在していた。
  - Golang で書き換えると、クロスプラットフォーム対応やテストの容易さなどの技術的メリットがある。
- **決定:** 書き換えない。現状の Bash スクリプトを維持する。
- **理由:**
  - このプロジェクトの目的の一つは「For learning bash script」である。Golang に書き換えると、この目的が達成できなくなる。
  - 「システム情報を取得して表示する」という機能要件に対して、Bash で対応困難な理由がない。むしろ、Bash で書くことで「シンプルなコードで、少ないファイルと依存関係で動くツール」を実現できている。
  - 対応対象の環境は「自分が頻繁に使う環境のみ」（README.md の方針）であり、その範囲では Bash で対応困難な理由がない。
  - Golang のビルド成果物の配布は `curl` でファイル1つを取得する現在の方法より複雑になり、「Simple code / Fewer files / Minimum dependencies」というプロジェクトのポリシーに反する。
  - 将来、どうしても辛くなった場合は、書き換えではなくプロジェクトの目的ごと見直すこと。
- **Windows 対応について:**
  - 同様の理由から、Windows 対応（`proper7y4win` として PowerShell スクリプトで実装する案）も現時点では行わない。
  - Windows は自分が頻繁に使う環境ではなく、対応コストがプロジェクトの規模・目的に見合わない。
  - 正確に言うと `property4win` のリポジトリは既に存在していて、PowerShell での実装も一部進んでいるが、開発途中で私が Windows に触れなくなったため、基本機能の実装途中で放棄されている。開発の再開予定もない。
  - [rnazmo／property4win: PowerShell version of the 'property' for Windows machine.](https://github.com/rnazmo/property4win)

## ADR-015: ローリングリリース系ディストリビューションでの OS VERSION 表示方針

- **日付:** 2026-04-22
- **状況:**
  - EndeavourOS 上で `./proper7y` を実行すると、`OS VERSION` フィールドが空欄になるバグが発覚した。
  - 原因は `print_os_version()` が `/etc/os-release` の `VERSION_ID` フィールドを参照しているが、
    EndeavourOS を含む Arch 系ローリングリリースディストリビューションはこのフィールドを持たないことにある。
  - EndeavourOS の `/etc/os-release` には `VERSION_ID` の代わりに `BUILD_ID=rolling` が存在する。
- **検討した案:**
  - **案1:** `"Unknown"` のまま表示する（現状維持）
    - バグが残り、ユーザーに意図が伝わらない
  - **案2:** `"N/A (Rolling Release)"` などの固定文字列を表示する
    - シンプルだが、`BUILD_ID` の情報を活用していない
  - **案2':** `BUILD_ID` の値（`rolling`）をそのまま表示する
    - `BUILD_ID` の意味はディストリビューションによって異なるため汎用性に欠ける
  - **案2''（採用）:** `VERSION_ID` が取れず `BUILD_ID=rolling` の場合に `"Rolling Release"` を表示する
- **決定:** 案2'' を採用する。
- **理由:**
  - `BUILD_ID=rolling` という機械的な値をそのまま出力するより、`"Rolling Release"` という
    人間が読みやすい文字列に変換する方が、このツールの出力としてふさわしい。
  - Arch Linux 本体・EndeavourOS・Manjaro など、Arch 系全般で同様に動作することが期待できる。
  - 実装がシンプルで、既存の `print_os_version()` の構造を大きく変えずに済む。
- **実装:**
  - `VERSION_ID` が空の場合に `BUILD_ID=rolling` の有無を確認するフォールバック処理を
    `print_os_version()` 内の Linux ブランチに追加した。

## ADR-014: `curl` ダウンロード時のチェックサム検証を実装しない

- **日付:** 2026-04-20
- **状況:**
  - TODO.md のバックログに「`curl` でのファイルダウンロード時にチェックサム検証を追加する」というタスクが存在していた。
  - 対象は `install_shellcheck()` および `install_shfmt()` 内の GitHub Releases からのバイナリダウンロード処理。
- **決定:** 実装しない。タスクをバックログから削除する。
- **理由:**
  - **shfmt のチェックサム取得が煩雑:** shfmt は v3.13.0 以降 `sha256sums.txt` アセットを廃止しており、GitHub の API 経由で digest を取得する必要がある。これには `jq` への依存追加、またはJSONを脆弱な方法で手動パースするコードが必要になる。
  - **プロジェクトのポリシーに反する:** README.md に "Minimum dependencies" の方針が明記されており、`jq` への依存追加はこれに反する。
  - **脅威モデルとして効果が限定的:** チェックサムファイルもバイナリも同じ GitHub から取得するため、GitHub 自体が侵害された場合には検証の意味がない。強い保証が必要なら GPG 署名の検証が必要になるが、それはこのプロジェクトの規模・目的に対して過剰である。
  - **利用者が自分のみ:** このプロジェクトは個人利用を前提としており、外部に配布するプロダクションシステムではない。リスクの現実的な大きさに対して実装コストが見合わない。

## ADR-013: `init()` の責務分割方針

- **日付:** 2026-04-20
- **状況:**
  - TODO.md に「最初に OS を特定し、未対応 OS の場合はエラーを返して終了させる」というタスクがあった。
  - 調査の結果、未対応 OS でのエラー終了は `identify_os_family_id()` と `identify_os_id()` が既に `exit 1` しており、**動作としては既に正しかった**。
  - 問題は設計の明確さにあった。`init()` は以下をすべて一括で行っており、関数名からは何をしているか分からない状態だった：
    - Bash バージョンチェック（前提条件の確認）
    - `uname` のキャッシュ
    - OS family / OS ID の特定
    - 仮想化環境の特定
    - 現在のシェルの特定
  - `main()` から `init` と呼ばれるだけでは、「OS判定もここで行われている」ことが読み取れない。
- **検討した解決策:**
  - **案1:** `init()` を廃止し、`check_prerequisites()` と `identify_environment()` を `main()` の冒頭で直接呼ぶ
  - **案2:** `init()` を残し、`check_prerequisites()` と `identify_environment()` への委譲ラッパーにする
- **却下した理由（案1）:**
  - `init()` には「これらは冒頭で必ず呼ぶべき処理である」というまとめ役の意図があった。
  - `init()` を廃止すると、将来コードを追加する人が「`check_prerequisites()` と `identify_environment()` は必ずセットで冒頭に呼ぶべき」という制約を読み取りにくくなる。
- **決定（案2）:**
  - `init()` は残す。ただし中身を `check_prerequisites()` と `identify_environment()` に委譲するラッパーとする。
  - `init()` のコメントに `Must be called once at the very beginning of the script` と明記し、役割を文書化する。
  - `check_prerequisites()` : Bash バージョンチェックのみ担う。
  - `identify_environment()` : `cache_uname()` の呼び出しと、OS / 仮想化 / シェルの特定を担う。**未対応環境では `exit 1` する。**
- **結果:**
  - `init()` が「冒頭で必ず呼ぶべきまとめ役」という役割を保持したまま、中身が何をしているかを関数名で表現できるようになった。
  - `main()` から読んだときに「OS が未対応なら `identify_environment()` の中で終了する」という流れが明確になった。

## ADR-012: devel-tools スクリプトのファイル名サフィックス方針

- **日付:** 2026-04-20
- **状況:**
  - `devel-tools/script/` 以下のスクリプトは `.linux-x64.bash` というサフィックスを持つが、
    CI (`integ-test.yml`) では macOS 上でも `make integ-tests` が呼ばれており、
    `run-integ-test.linux-x64.bash` が macOS 上で実際に実行されていた。
  - 命名と実態が乖離しており、TODO.md にて「この検討は ADR で行うべき」と記録されていた。
- **調査結果:**
  - `install-devel-tools`・`run-lint`・`run-format`・`bump-project`・`check-devel-tools-versions`・`check-project-version-consistency` の各スクリプトは、以下の理由により Linux/x64 専用である。
    - shellcheck・shfmt のバイナリ取得 URL が `linux.x86_64` 固定
    - `sed -i` を GNU sed の構文で使用しており、macOS の BSD sed では動作しない
  - `run-integ-test` スクリプトは `curl` と `bash` のみを使用しており、Linux/macOS 両方で動作する。
- **決定:**
  - Linux/x64 専用スクリプトは `.linux-x64.bash` サフィックスを維持する。
  - `run-integ-test.linux-x64.bash` は実態に合わせて `run-integ-test.bash` にリネームする。
  - 「開発者環境は Linux/x64 のみ」という方針は変更しない（README.md の Prerequisite セクションに既に明記されている）。ただし `run-integ-test.bash` の例外についてはコメントで補足する。
- **採用しなかった案:**
  - すべてのスクリプトから `.linux-x64.bash` サフィックスを除去する案は、Linux/x64 専用スクリプトに対して誤解を招くため採用しない。
  - macOS 対応を全スクリプトに広げる案は、devel-tools のバイナリ管理の複雑化を招くため現時点では採用しない。

## ADR-011: 正常終了時の `exit 0` 明示方針

- **日付:** 2026-04-20
- **状況:**
  - `proper7y`、`install.bash`、および `devel-tools/script/` 配下の全スクリプトにおいて、
    その終了ステータスを意識できていなかった。具体的に言うと、正常終了時に `exit 0` を明示していなかった。
  - Bash ではスクリプト末尾の最後のコマンドの終了ステータスがそのままスクリプト全体の
    終了ステータスになる。通常は問題ないが、意図が明示されておらず読みにくい。
- **決定:**
  - トップレベルで実行されることを意図したスクリプト（`proper7y`、`install.bash`、
    `devel-tools/script/*.bash`）の末尾に `exit 0` を明示する。
  - `common.bash` は `source` して使うライブラリであり、トップレベルで実行されることを
    意図していないため、対象外とする。
- **理由:**
  - 「正常終了したら 0 を返す」という意図をコードで明示することで、
    読み手が終了ステータスを意識して確認する手間を省ける。
  - 将来スクリプト末尾のコードが変更された際に、意図せず非ゼロで終了するリスクを減らせる。
- **ルール（まとめ）:**
  - トップレベルスクリプト → 末尾に `exit 0` を明示する
  - ライブラリ（`common.bash`）→ `exit 0` は追加しない

## ADR-010: `exit` と `return` の使い分け方針

- **日付:** 2026-04-19
- **状況:**
  - `proper7y` の `identify_*()` 系関数は `exit 1` を使っており、
    `common.bash` のチェック系関数は `return 1` を使っている。
  - この使い分けが意図的なのか偶然なのかが、コードを読むだけでは判断できなかった。
  - TODO.md に「方針を ADR に明記する」というタスクが残っていたため、記録する。
- **決定:** スクリプトの役割に応じて以下のように使い分ける。
  - **`exit`** : エンドユーザー向けのトップレベルスクリプト（`proper7y`、`install.bash`、各 `*.bash` スクリプト）内で、処理続行が不可能なエラーが発生したとき。プロセスそのものを終了させる。
  - **`return`** : `common.bash` のライブラリ関数内で、エラーを呼び出し元に通知するとき。関数の責務はエラーを報告することまでであり、プロセスを終了させるかどうかの判断は呼び出し元に委ねる。
- **理由:**
  - `common.bash` の関数は複数のスクリプトから `source` して使う汎用ライブラリである。ライブラリ関数が勝手に `exit` すると、呼び出し元がエラーハンドリングできなくなる。テスト時や将来の拡張時にも困る。よって、ライブラリ関数は `return 1` でエラーを返すべきである。
  - 一方、`proper7y` 本体の `identify_*()` 関数が失敗した場合、正確なシステム情報を出力できないため処理を続行する意味がない。また `proper7y` は単体で動作するスクリプトであり、呼び出し元に判断を委ねる設計になっていない。よって `exit 1` が適切である。
- **ルール（まとめ）:**
  - ライブラリ関数（`common.bash` 内）→ `return 1`
  - トップレベルスクリプト内の関数（`proper7y`、`install.bash` 内）→ `exit 1`
- **既存コードとの整合性:**
  - 現状のコードはすでにこの方針に従っている。このADRは方針を後付けで文書化するものである。
- **補足:**
  - `set -e` があるため、`return 1` したライブラリ関数の呼び出し元が戻り値を明示的にハンドルしない場合、スクリプトはそこで自動的に終了する。つまり、「ライブラリ関数は `return 1` するが、結果的にスクリプトが終了する」という動作は `set -e` によって担保される。

## ADR-009: Conventional Commits の採用

- **日付:** 2026-04-19
- **状況:**
  - コミットメッセージのフォーマットに関する明示的な方針が存在しなかった。
  - README.md の「Commit message」セクションには「てきとうにゆるくやる」と書かれており、
    一部のコミットでは既に `docs:` プレフィックスを使うルールが記載されていたが、
    Conventional Commits を正式に採用するかどうかは明文化されていなかった。
  - 実際には `docs:` プレフィックスの使用や `Bump ...` 形式のメッセージなど、
    Conventional Commits に近い運用がすでに始まっていた。
- **決定:**
  - Conventional Commits (<https://www.conventionalcommits.org/ja/v1.0.0/>) を正式に採用する。
  - ただし、個人プロジェクトであるため、厳格な運用は求めない。
    ミスがあっても気にしすぎず、ゆるく継続することを優先する。
- **採用する主なコミットタイプ:**
  - `feat` : 新機能の追加
  - `fix` : バグ修正
  - `docs` : ドキュメントのみの変更
  - `style` : コードの意味に影響しない変更（フォーマット等）
  - `refactor` : バグ修正でも機能追加でもないコードの変更
  - `test` : テストの追加・修正
  - `chore` : ビルドプロセスや補助ツールの変更（devel-tools のバージョン更新等）
- **スコープの運用:**
  - スコープ（例: `feat(install): ...`）は任意とする。
  - 変更対象が明確な場合（例: `proper7y`、`install.bash`、`common.bash`、`ci`）は
    付けると読みやすい。付けなくても構わない。
- **既存ルールとの統合:**
  - README.md の「Commit message」セクションに記載されていた個別ルールは、
    Conventional Commits の表現に統合する。
    - `docs:` プレフィックス → そのまま `docs:` として継続
    - `Bump project version: vX.X.X -> vX.X.X` → `chore: Bump project version: vX.X.X -> vX.X.X`
    - `Bump devel-tool version (shfmt): vX.X.X -> vX.X.X` → `chore(shfmt): Bump devel-tool version: vX.X.X -> vX.X.X`
  - ただし、`bump-project.linux-x64.bash` および `check-devel-tools-versions.linux-x64.bash`
    内でハードコードされているコミットメッセージ文字列は、今回は変更しない。
    将来リファクタリングの機会があれば合わせて修正すること。
    - → TDOO へ記述済み
    - → 修正済み
- **理由:**
  - 既に近い運用をしているなら、正式に採用してルールを明文化した方が、
    将来の自分がコミット履歴を読むときに迷わなくて済む。
  - CHANGELOG.md の自動生成ツール（git-cliff 等）を将来導入する場合にも、
    Conventional Commits に準拠していると都合がよい。
- **注意:**
  - コミットメッセージの自動検証（commitlint 等）は導入しない。
    ツール管理のコストが目的に見合わないと判断した。
  - 「ゆるく運用する」という方針は維持する。完璧なメッセージを書くことより、
    コミットすること自体を継続することを優先する。

## ADR-008: 一時ディレクトリ処理における `trap EXIT` のスコープ管理方針

- **日付:** 2026-04-17
- **状況:**
  - `install_shellcheck()` 内で `trap 'rm -rf "${TEMP_DIR:-}"' EXIT` を設定していたが、
    Bash の `trap` はプロセス全体に影響するため、関数スコープに閉じない。
  - 将来別の関数が同じパターンで `trap EXIT` を設定した場合、後から設定した trap が
    前の trap を上書きし、最初の関数の一時ディレクトリが削除されなくなる。
    エラーも警告も出ないためサイレントに壊れる。
  - TODO.md にて既知の問題として記録されていた。
- **決定:**
  - 一時ディレクトリを使う処理全体をサブシェル `( )` に閉じ込める。
  - サブシェル内での `trap EXIT` はそのサブシェルにしか影響せず、
    親シェルの trap を汚染しない。
- **理由:**
  - サブシェルは Bash 組み込みの機能であり、外部ツール不要・依存ゼロで使える。
  - `cd` の影響もサブシェルに閉じるため、処理後に `cd "$PROJECT_ROOT"` で戻る
    コードが不要になり、コードが簡潔になる。
- **制約・注意点:**
  - サブシェル内の変数変更は親シェルに伝わらない。
    グローバル変数を更新する処理（`_recompose_shellcheck_binary_version` など）は
    サブシェルの外に置く必要がある。
- **適用範囲:**
  - 今回は `install_shellcheck()` のみ修正した。
  - `install_shfmt()` は現在 `mktemp` を使っていないため対象外。
    将来 `install_shfmt()` に一時ディレクトリが必要になった場合は同じパターンを適用すること。
- **課題:**
  - `run-integ-test.linux-x64.bash` の `main()` 内にも `trap EXIT` があるが、**サブシェル化は不要**と判断した。
    - `main()` はこのスクリプトのトップレベルであり、その後に別の `trap EXIT` を上書きする処理が呼ばれない。
    - `install_shellcheck()` が問題だったのは「関数呼び出し連鎖の途中」に置かれており、後続の関数が `trap EXIT` を上書きする危険があったから。`main()` にはその条件が当てはまらない。
    - サブシェルに閉じ込めると、assert_output や assert_line_exists への参照が切れるなどの複雑性が増す（実際には同ファイル内なので問題ないが、得られるものが少ない）
    - よって、現状の実装（`trap 'rm -rf "${TEMP_DIR:-}"' EXIT` を直接 `main()` 内に書く）は正しく、変更不要である。
- 備考：
  - trap EXIT のサブシェル化をするかどうかの判断基準
    - 「その関数の後に、別の trap EXIT を設定する処理が呼ばれる可能性がある」ならサブシェル化すべき。
    - サブシェルには「変数が親シェルに伝わらない」という制約コストが伴うので、必要な場合にのみ適用すること

## ADR-007: CHANGELOG.md の導入と運用方針

- **日付:** 2026-04-16
- **状況:**
  - TODO.md のバックログに「ChangeLog を追加することを検討する」というタスクが存在していた。
  - 現在 TODO.md 内にあるマイルストーンがこれと近い役割を持っている。しかし、このマイルストーンはリリース時に TODO.md から削除する運用のため、記録として残らない。また、このマイルストーンに書いてある TODO と、実際に「やったこと」は乖離がある可能性がある。マイルストーンはあくまでタスクリストであるため、そこに書かれていない作業が行われているかもしれない。
  - git log だけだと「何をやったか」が分かりづらい。
  - リリース毎に ChangeLog がある残しておくと、数ヶ月後の自分が助かる場面がありそう。
  - あとは単純に、ChangeLog の運用を試してみたい。書く側、読む側の両方をやってみたい。
  - 一方、ChangeLog のメンテナンスが負担になるようなら廃止する、という軽い気持ちで始めることにした。
- **決定:**
  - `CHANGELOG.md` を導入する。
  - `v0.9.3` 以前の履歴は書かない。`v0.10.0` のリリース時から書き始める。
  - フォーマットは Keep a Changelog (<https://keepachangelog.com/ja/1.1.0/>) を参考にしつつ、簡素に運用する。
  - ChangeLog の下書きは AI (Claude 等) を使って生成し、自分で軽く手直しするワークフローをとる。
  - 運用が負担になった場合は、気軽に廃止する。

### CHANGELOG.md のフォーマット

Keep a Changelog の形式をベースに、以下の点を簡素化する。

- セクションは `Added / Changed / Fixed / Removed` の4種類のみ使う
  - `Added` : 新機能の追加
  - `Changed` : 既存の機能・コードの変更
  - `Fixed` : バグ修正
  - `Removed` : 機能・コードの削除
- 該当するセクションが空の場合はそのセクションごと省略する
- 各エントリは1行で書く（長い説明は書かない）
- 詳細が必要な場合は git log や TODO.md の履歴を参照すればよいので、
  CHANGELOG.md 自体には概要だけ書けば十分とする

フォーマット例:

```markdown
## v0.10.0 - 2026-XX-XX

### Added

- `is_supported()` 関数を実装し、配列チェックを完全一致に変更した

### Changed

- `print_os_version()` の `lsb_release` 依存を `/etc/os-release` に置き換えた

### Fixed

- `install.bash` の未使用 `log_warn` 関数を削除した
```

### ChangeLog 作成のワークフロー

リリース時（`make bump-project` を実行する前）に以下の手順で作業する。

**Step 1: 素材を収集する**

以下のコマンドで、前回リリースタグから現在までの git log を取得する。

```bash
# LAST_TAG は直前のリリースタグに置き換える（例: v0.9.3）
git log LAST_TAG..HEAD --oneline
```

TODO.md の完了済みマイルストーンの内容も合わせて素材にする。

**Step 2: AI に下書きを生成させる**

以下のプロンプトを Claude に渡す。

```md
以下は Bash スクリプトプロジェクト "proper7y" の次バージョンリリース用の素材です。
これをもとに CHANGELOG.md のエントリの下書きを作成してください。

フォーマットのルール:

- セクションは `Added / Changed / Fixed / Removed` の4種類のみ使う
- 該当するセクションが空の場合はそのセクションごと省略する
- 各エントリは1行で書く（長い説明は不要）
- 日本語で書く

【git log】(ここに `git log LAST_TAG..HEAD --oneline` の出力を貼る)

XXX

【完了したマイルストーンのタスク】(ここに TODO.md の完了済みマイルストーン内容を貼る)

XXX
```

**Step 3: 手直しして CHANGELOG.md に追記する**

AI の出力を軽く確認・修正し、`CHANGELOG.md` の先頭に追記する。

**Step 4: bump-project を実行する**

通常通り `make bump-project` を実行してリリースする。

### 備考

- 上記の CHANGELOG のフォーマットやプロンプトは、試作段階である。必要に応じて改善していくこと。

## ADR-006: `static-tests` Makeターゲットから `format` を除外する

- **日付:** 2026-04-14
- **状況:**
  - 開発中に多用しているコマンドである `make static-tests` が、`static-tests: lint format validate` と定義されており、
    `format` が `lint` と同じターゲットに混在していた。
  - `format` はファイルを上書きする副作用を持つため、差分チェックのみ行う `lint` とは役割が根本的に異なるので分けるべき
  - CI での make static-tests 実行にも適さない。実際に、`static-test.yml` では `make static-tests` を使わず `make lint` と `make validate`
    を個別に呼び出すことで問題を回避していた（CIとローカルで異なる手順を使う状態）。
- **決定:** `static-tests` から `format` を除外する。代わりに、`pre-commit` のターゲットに含める。
  - Before:
    - `static-tests: lint format validate`
    - `pre-commit: static-tests`
  - After:
    - `static-tests: lint validate`
    - `pre-commit: static-tests format`
- **理由:**
  - `lint` と `format` は根本的に役割が異なる。`lint` は「問題を報告する」、`format` は「ファイルを書き換える」。副作用を持つ処理を検証系のターゲットに混ぜるべきではない。
  - CIとローカルで同じターゲット（`make static-tests`）を使えるようにすることで、「CIが通るのにローカルの手順と違う」という状況を解消する。
  - `make pre-commit` に `format` を含めれば、「コミット前に整形してから静的テストを通す」というユースケースは引き続きカバーされる。
- **影響:**
  - `static-test.yml` を `make lint` + `make validate` の個別呼び出しから `make static-tests` に統一できる。
  - ローカルで `make static-tests` だけでは整形されなくなる。整形が必要な場合は `make format` か `make pre-commit` を明示的に実行する。
  - つまり、ローカルでこれまで `make static-tests` に期待していた動作は、`make pre-commit` が請け負うことになる
- **補足メモ:**
  - 「副作用のあるコマンド」と「副作用のない（＝冪等な）コマンド」は明確に分けるべきである。
  - 副作用のあるコマンドを実行する前には、ユーザーがそれを認識できるようにすべき。「このコマンドを叩いたら何が起きるか」をわかりやすくする。
  - 特に CI/CDパイプラインでは、副作用のあるコマンドを安易に混ぜるべきではない。
    - CI/CDは「コードの品質を検証するための環境」であり、コードを変更するための環境ではない。
    - CI/CDで副作用のあるコマンドを実行すると、「CIが通るのにローカルで手順が違う」という状況が生まれやすくなり、開発者の混乱を招く。
  - 「副作用の有無」「冪等性（idempotency）」「CI では冪等に」がキーワード。

## ADR-005: インテグレーションテストの設計方針

- **日付:** 2026-04-04
- **状況:**
  - インテグレーションテストに関するコードが複数箇所に散在しており（`Makefile`、`run-integ-test.linux-x64.bash`、`integ-test.yml`）、「どのコードを、どのテストで、どの環境で、どのタイミングで実行するのか」が不明確だった。
  - `run-integ-test.linux-x64.bash` が `main` ブランチから `install.bash` を取得している意図がコードから読み取れなかった。
  - テストは「スクリプトが exit 0 で終了するか」しか確認しておらず、出力内容の検証がなかった。
  - これらを整理・文書化する必要性が生じたため、このADRを作成した。

### テスト対象となる「コードの状態」の定義

proper7y には実質的に以下の3つの状態がある。

| 呼び名            | 実体                                 | 説明                                  |
| ----------------- | ------------------------------------ | ------------------------------------- |
| **local-HEAD**    | `./proper7y`（ローカルファイル）     | 現在開発中のコード                    |
| **remote-main**   | GitHub の main ブランチの proper7y   | push 済みだがリリース前の可能性がある |
| **remote-stable** | GitHub のタグ付きリリースの proper7y | 最新安定版                            |

### テストの種別

| 種別                   | 内容                                                              |
| ---------------------- | ----------------------------------------------------------------- |
| **実行テスト**         | proper7y を直接実行して動作するか確認する                         |
| **インストールテスト** | install.bash 経由でインストールしてから実行して動作するか確認する |

### 現状のテスト構成

#### ローカル実行（`make integ-tests`）

| Makeターゲット             | 実体                                   | テスト種別         | テスト対象    |
| -------------------------- | -------------------------------------- | ------------------ | ------------- |
| `run-integ-test-to-head`   | `./proper7y` を直接実行                | 実行テスト         | local-HEAD    |
| `run-integ-test-to-latest` | `run-integ-test.linux-x64.bash` を実行 | インストールテスト | remote-stable |

実行順序は `run-integ-test-to-head` → `run-integ-test-to-latest` の順だが、両者の間に依存関係はない。ローカルで完結する高速なテストを先に実行するという慣習的な順序である。

#### CI（`integ-test.yml`）

| Job名                             | 実行内容                | テスト種別                     | テスト対象                  | 実行環境      |
| --------------------------------- | ----------------------- | ------------------------------ | --------------------------- | ------------- |
| `install-and-run-stable-proper7y` | `make integ-tests`      | 実行テスト＋インストールテスト | local-HEAD と remote-stable | Ubuntu, macOS |
| `run-head-proper7y`               | `./proper7y` を直接実行 | 実行テスト                     | local-HEAD                  | Ubuntu, macOS |

`run-head-proper7y` は `run-integ-test-to-head` と同じ内容であり、重複している。この重複は既知の問題として認識しているが、現時点では許容する。

#### `run-integ-test.linux-x64.bash` が main ブランチから install.bash を取得する理由

`install.bash` はバージョン情報を内包しており、main ブランチの `install.bash` を実行すれば常に最新安定版の proper7y がインストールされる（ADR-004 参照）。よって、インストールテストのエントリーポイントとして main ブランチの `install.bash` のURLを使うことは正しい。「stable版のテスト」と「mainブランチのURLを使うこと」は矛盾しない。

### アサーションの方針

テストは「スクリプトが exit 0 で終了するか」だけでなく、出力内容も検証する。アサーションは以下の3レベルで定義する。

**レベル1（実装済み）：構造の確認**

- ヘッダー行（`proper7y v` で始まる行）が存在する
- 区切り線（`====...`）が2行存在する
- 各フィールド名（`OS NAME` など）が存在する
- `CURRENT DATE` の値が `YYYY-MM-DD` 形式である
- `BASH VERSION` の値が `X.Y.Z` 形式である

**レベル2（未実装）：値が有効であることの確認**

- 各フィールドの値が `Unknown` や空でないことを確認する
- CI 環境への依存度が高くなるため、環境ごとの期待値の管理方法を先に設計する必要がある

**レベル3（未実装）：より多くのフィールドの形式確認**

- 現状は `CURRENT DATE` と `BASH VERSION` のみ。他のフィールドにも形式チェックを追加する

現時点ではレベル1のみ実装している。レベル2・3は TODO.md のバックログに記載している。

### 既知の問題・懸念事項

- `run-integ-test-to-head` には出力内容のアサーションがない（TODO.md のバックログに記載）
- CI の `run-head-proper7y` Job と `run-integ-test-to-head` が重複している（TODO.md のバックログに記載）
- アサーションは現状 `run-integ-test.linux-x64.bash`（インストールテスト側）にしか存在しない

## ADR-004: install.bash の設計思想と存在意義

- **日付:** 2026-04-04
- **状況:**
  - `install.bash` が何のために存在するのか、なぜそのような実装になっているのかが、コードを読むだけでは分かりにくかった。
  - TODO.md のバックログにも「`install.bash` がある理由を README.md に書く」というタスクが存在していたが、長らく未着手だった。
  - テスト設計を見直す議論（ADR-005 参照）の中で、`install.bash` の設計意図を言語化・文書化する必要性が明確になった。

### install.bash の存在意義

`install.bash` には以下の2つの役割がある。

**役割1：固定エントリーポイントの提供**

利用者（≒ 将来の自分）が proper7y をインストールする際、バージョン番号を意識せずに済むようにする。具体的には、以下のURLを「永続的に変わらないインストール用エントリーポイント」として機能させる。

```
https://raw.githubusercontent.com/rnazmo/proper7y/main/install.bash
```

このURLを叩けば、常に最新安定版の proper7y がインストールされる。利用者はバージョン番号を調べたり、ダウンロード用URLを更新したりする必要がない。

**役割2：インストール手順のラップ**

`curl` でのダウンロード、`chmod` での実行権限付与、インストール先ディレクトリの作成と確認、といった手順をスクリプトにまとめる。
利用者はこれらを毎回手打ちする必要がない。

### 「常に最新安定版がインストールされる」仕組み

`install.bash` は内部に `PROPER7Y_VERSION` を持つ。

```bash
readonly PROPER7Y_VERSION="v0.9.3"
readonly SRC_URL="https://raw.githubusercontent.com/rnazmo/proper7y/${PROPER7Y_VERSION}/proper7y"
```

バージョンをリリースする際（`make bump-project`）、この値も同時に更新される。よって、mainブランチの `install.bash` を実行すれば、常にその時点での最新安定版の proper7y がインストールされる。

エントリーポイントのURL（`main` ブランチを指すURL）は変わらない。バージョン情報は `install.bash` の中に隠蔽されている。これが「固定URLで常に最新安定版をインストールできる」を実現する。

### 検討した代替案と採用しなかった理由

**案：GitHub Releases の `latest` を使う**

```bash
# install.bash を廃止し、直接 latest のアセットを取得する
curl -L https://github.com/rnazmo/proper7y/releases/latest/download/proper7y \
  -o "${HOME}/.bin/proper7y" && chmod +x "${HOME}/.bin/proper7y"
```

- GitHub Releases にリリース時のファイルをアップロードする仕組みが必要になる。
- このプロジェクトは「GitHub に過度に依存」させたくない（GitLab などへの移行容易性を保ちたい）。GitHub Releases は GitHub 固有の機能であるため、このポリシーに反する。
- よって採用しない。

### この設計の制約

`install.bash` が `PROPER7Y_VERSION` を内包する設計の結果、バージョン番号が `proper7y`・`install.bash`・`common.bash` の3ファイルに重複して定義される。この問題と対処方針については ADR-001 を参照。

## ADR-003: TODO.md へのマイルストーン導入

- **日付:** 2026-03-30
- **状況:**
  - TODO.md のタスクがフラットに並んでいるだけで、優先順位も期限も不明確だった。
    - 正確には、一応 `Priority` 毎にセクションを区切る形で優先度を管理しようとしていた。しかし、まともに管理できていなかった。
  - 「いつかやる」タスクと「今やるべき」タスクが混在しており、何から手をつければよいか分かりにくかった。
- **検討した解決策:**
  - マイルストーンを導入することにした。その上で、下記の 2 つの導入方法を検討した
  - **案1:** GitHub Issues + Milestone 機能を使う
  - **案2:** TODO.md にマイルストーンセクションを設ける
- **却下した理由（案1）:**
  - このプロジェクトのポリシーとして、Issue・Pull Request への重要情報の記載を避ける方針がある（README.md 参照）。外部ツールへの依存を増やすことは、そのポリシーと相容れない。
  - このプロジェクトは極小規模、かつ個人開発＆個人利用であり、また学習目的の砂場も兼ねたプロジェクトである。そのため重厚な管理ツールは不要で、テキスト形式でのマイルストーン管理で十分である。
- **決定:**
  - 上述の通り重厚な管理ツールは不要なので、1ファイルで完結するシンプルな運用を行う。
  - `TODO.md` にマイルストーンセクションを設け、「今取り組むタスク」と「バックログ」を区別する。
  - マイルストーンは `vX.X.X` 単位で設定し、「一定の期間内にこれをやる」という軽い区切りとして運用する。
    - なお、`v1.0.0` は遠い将来の話であり、現時点では見通しは立っていない。しばらくは、`v0.X.X` で区切っていくことになるだろう。
- **運用ルール:**
  - アクティブなマイルストーンは常に0〜3つだけ置く。(SHOULD)
    - タスクの優先順位が決まっていない段階では、マイルストーンセクションを空欄（TBD）のまま置いておいてよい。
  - マイルストーンのタスクが終わったら、次のバージョンのセクションに差し替える。
- **決定:**
  - バージョン番号の散在を受け入れた上で、`bump-project.linux-x64.bash` に事後検証関数 `verify_version_consistency()` を追加し、バージョン書き換え後・コミット前に3ファイルの整合性を自動チェックする。

## ADR-002: ドキュメントの分割管理方針

- **日付:** 2026-03-30
- **状況:**
  - README.md への編集が TODO の更新に集中しており、README.md のコミット履歴を分かりづらくしていた。
  - TODO が README.md 内の他のセクションに埋もれており、参照・更新しづらい状態になっていた。
  - TODO をマイルストーン単位で構造的に管理したいという要求が生じたが、そのような構造を README.md に持ち込むと煩雑になりすぎる。
  - ADR はこれから増えていく見込みであり、これを README.md 内の 1 セクションとして扱うのは適切でないと判断した。
  - Issue などの外部ツールは使わず、Markdown ファイルでシンプルに管理するという方針は維持したい。
- **決定:**
  - `TODO.md` と `ADR.md` を新規作成し、README.md から切り出す。
  - README.md の "Simple documentation" ポリシーを改定し、「重要な情報は `README.md` (とソースコード中のコメント) に集約する。」から「重要なドキュメントは `README.md`、`TODO.md`、`ADR.md`、およびソースコード中のコメントに集約する。」に変更する。
- **影響:**
  - README.md の `### TODO` セクションは `TODO.md` に移動する。
  - README.md の `### ADR` セクションは `ADR.md` に移動する。

## ADR-001: プロジェクトバージョン番号の管理方針

- **日付:** 2026-03-26
- **状況:**
  - `PROPER7Y_VERSION` が `proper7y`、`install.bash`、`common.bash` の3ファイルに重複して定義されており、Single Source of Truth の原則に反している。
- **検討した解決策:**
  - **案1:** `common.bash` を唯一の定義元とし、他のファイルは `source` で読み込む
  - **案2:** `VERSION` ファイルを作り、各スクリプトがそこから読み込む
- **却下した理由:**
  - `proper7y` および `install.bash` は単体でダウンロード・実行されることを前提とした設計である。これらのスクリプトは `common.bash` や `VERSION` ファイルが手元に存在しない環境で動作しなければならないため、外部ファイルへの依存を持たせることができない。バージョンの重複は、このプロジェクトの「スクリプト単体で動く」という設計思想に起因する、避けがたい構造的制約である。
