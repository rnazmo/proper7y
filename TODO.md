# TODO (proper7y)

## Milestone: v0.11.0 - テスト戦略の再設計

### コード・機能

無し。

### テスト・CI

- [x] 「環境依存フィールド」のテスト設計を再考する
  - 主にインテグレーションテスト周りの問題。
  - 環境依存フィールドとは、例えば `OS VERSION` はすべての環境で表示されるが、
    `KERNEL VERSION` は Linux 環境でのみ表示される、というようなフィールドのこと。
  - 背景：`KERNEL VERSION`（Linux専用）、`ZSH VERSION`（Zsh時のみ）のように、
    実行環境によって出力されるフィールドが変わる仕様が存在する。
    現状のテストはこれに対して `if [[ "$(uname -s)" == "Linux" ]]` のような
    分岐をテストコード側に直接書くことで（応急処置的に）対処しているが、この方法では
    `proper7y` 本体と同じ条件分岐をテストコードが重複して持つことになり、
    メンテナンスコストが二重になる。根本的な設計の再検討が必要である。
  - 問題意識：環境依存フィールドが増えるたびに `assert_output()` が複雑化していく。
    将来的に macOS の CHASSIS 対応なども加わると、この問題はさらに大きくなる。
  - 検討すべき方向性：
    - テスト側が「どのフィールドが出るか」を静的に決め打ちするのをやめる、というのはどうか？
    - 「出力されたフィールドには必ず値がある（Unknown・空でない）」という
      検証に特化する設計を検討する
    - `proper7y` 側に「出力フィールド一覧を返す」仕組みを持たせる案も検討する
    - その他にも、環境依存フィールドのテスト設計を改善するためのアイデアがあれば検討する
  - **この検討は ADR で行うべき**
- [x] `run-integ-test.bash` の `VIRTUALIZATION` および `KERNEL VERSION` の workaround を解消する
  - 背景：`VIRTUALIZATION` は macOS で `systemd-detect-virt` / `hostnamectl` が使えないため、
    レベル2アサーション（値が `Unknown` でないことの確認）の対象から除外している。
    `KERNEL VERSION` は Linux 専用フィールドのため同様に除外している。
    いずれもコードに `TODO: Excluding ... is workaround.` と明記されている。
  - 解消の前提：「環境依存フィールドのテスト設計を再考する」タスクの設計が固まってから着手すること。
    そのタスクの結果として、このworkaroundも自然に解消される可能性がある。
- [x] ユニットテストを追加することを検討する
  - ShellSpec を検討する
  - **この検討は ADR で行うべき**
- [x] bats-core のバイナリDLを devel-tools の仕組みに組み込む (Ref: ADR-030)
  - 管理方針: shellcheck・shfmt と同じく `devel-tools/bin/` にバイナリを置く方式
- [x] `is_supported()` を対象に bats-core でユニットテストを1本書いてみる（小さく試す）(Ref: ADR-030)
  - この関数はすでに副作用がなく、リファクタリング不要でテスト可能
  - テストファイルは `test/unit/` ディレクトリを新規作成してそこに置く
  - Makefile にテスト実行用ターゲットを追加する
  - CI への組み込みは後回しでよい
- [x] `make unit-tests` がエラーになるので対応する (bats のインストール方法の問題)
- [x] `make unit-tests` が `0 tests, 0 failures` になる問題を解消する
  - **症状:** `./devel-tools/bin/bats test/unit/` および `./devel-tools/bin/bats test/unit/is_supported.bats` を実行すると `1..0` / `0 tests, 0 failures` となり、テストが1本も認識されない
  - **原因1: `source` が bats の前処理フェーズをクラッシュさせている**
    - bats はテストファイルを「前処理フェーズ（`@test` の収集）」と「実行フェーズ」の2段階で処理する
    - 前処理フェーズで `source proper7y` が実行され、`proper7y` 冒頭の `set -euo pipefail` や `declare -l` などのグローバルな副作用が bats の特殊な前処理環境と干渉し、クラッシュする
    - クラッシュの結果、`@test` ブロックが0本として認識される
  - **原因2: `run` がサブシェルで実行されるため `source` した関数が見えない**
    - bats の `run` コマンドはデフォルトでサブシェルでコマンドを実行する
    - サブシェルには親シェルで `source` した関数定義が引き継がれないため、`is_supported` が "Command not found"（exit code 127）になる
    - `source` をコメントアウトして実行すると7本のテストが認識されるが、全テストが exit code 127 で失敗することで上記が確認済み
  - **検討済みの方針と評価:**
    - **方針A（却下）: `is_supported()` の定義をテストファイルにコピー**
      - シンプルだが `proper7y` 本体と定義が重複し、メンテナンスコストが高いため却下
    - **方針B（未検証）: `declare -f` でサブシェルに関数定義を渡す**
      - `IS_SUPPORTED_FUNC="$(declare -f is_supported)"` をファイル冒頭で実行し、各テストで `run bash -c "${IS_SUPPORTED_FUNC}; is_supported ..."` のように呼び出す
      - `source` の問題（原因1）を先に解決する必要がある
      - `source` の問題の解決策候補: `source` の前後で `set` の状態を保存・復元する（`_old_set="$-"` → `set +euo pipefail` → `source` → 復元）
      - ただし `declare -l` などの `proper7y` 固有の副作用が残る可能性があり、完全に解決するかは未検証
    - **方針C（未検討）: bats の `load` ヘルパーや `setup()` を活用する方法**
      - bats には `load` というヘルパーファイル読み込み機構がある
      - `load` が `source` と異なる挙動をするかどうかは未調査
    - **方針D（未検討）: `proper7y` のユニットテスト対象関数を別ファイルに切り出す**
      - `is_supported()` などの副作用のない関数を `lib/functions.bash` のようなファイルに切り出し、`proper7y` からそのファイルを `source` する設計に変更する
      - テストファイルは `proper7y` ではなく `lib/functions.bash` を `source` する
      - `proper7y` のポリシー「Fewer files」に反するため、ADR で設計判断が必要
  - **推奨する検討順序:**
    1. 方針B（`declare -f` + `set` の保存・復元）を試す。実装コストが低く、既存の設計を変えずに済む
    2. 方針Cを調査する（bats の `load` の挙動確認）
    3. 上記2つで解決しない場合、方針Dを ADR で検討する
- [x] 上記の「小さく試す」の結果を踏まえて、ユニットテストを継続するかどうかを判断する (Ref: ADR-030)
  - 判断結果は ADR-030 に追記する
- [x] ユニットテストを、ローカルでの開発フロー＆CIに組み込む
- [x] integ-testのアサーションをレベル3に強化する (Ref: ADR-005)
  - レベル3: より多くのフィールドの値の形式を確認する（現状はCURRENT DATEとBASH VERSIONのみ）
  - 候補: CPU ARCH（英数字・アンダースコア形式）、OS VERSION（数字ドット形式）
  - CURRENT SHELL の Unknown チェック対象への包含可否も合わせて検討する
  - CI環境への依存度が高くなるため、環境ごとの期待値の管理方法を先に設計すること
- [x] CI でのテスト環境に Arch Linux, EndeavourOS, Manjaro Linux などを追加する
  - GitHub Actions のホストランナーで利用可能なのは、Ubuntu と macOS だけ。
    なので、これらのディストリビューションをテスト環境に加えるには、
    「Docker コンテナを使う」か「セルフホストランナーを用意する」かのどちらかが必要になる。
    - 案A: Docker コンテナを使う
      - GitHub Actions の container: キーで archlinux:latest などの Docker イメージを使う？
      - メリット: 追加コストなし、設定がシンプル
      - デメリット: コンテナ環境は仮想化検出が「docker」になり、VIRTUALIZATION_ID が変わる。
        また systemd が使えないため systemd-detect-virt が動かない可能性がある、など
    - 案B: self-hosted runner を使う
      - 実機 or VM に runner を立てる
      - デメリット: 個人プロジェクトには明らかに過剰、維持コストが高い
      - → コスト高いので無し。
  - 公式 Docker イメージの存在を調査：
    - archlinux:latest → 公式イメージあり
    - endeavouros → 公式 Docker イメージなし
    - manjarolinux/base → 非公式イメージあり
  - 導入コストなどを考えると、まずは Arch Linux だけを追加で導入するのが良さそう。
    その後のこと（それ以上テスト環境を増やすかどうか）は、それから考える。
  - この検討は ADR で行うべき
  - ADR-033 に設計判断を記録した。Arch Linux のみ追加（Docker コンテナ方式）。
- [x] ユニットテストの対象範囲を拡大を検討する（「副作用のない関数」について）
  - Ref: ADR-030
  - まずはこれ（「副作用のない関数」）だけやるのが良さそう
  - → `pad_with_spaces()` と `print_row()` のテストを追加済み
- [x] ユニットテストの対象範囲を拡大を検討する（「多少手を加えるだけでユニットテストできそうな関数」について）
  - 調査の結果、`BASH_SOURCE` ガード（ADR-032）の副産物として `print_chassis()` 等の `print_*` 系関数が
    本体変更ゼロでテスト可能になっていることが判明した。
  - `print_chassis()`, `print_kernel_version()`, `print_os_name()`, `print_virtualization()`,
    `print_current_shell()`, `print_cpu_arch()` のテストを追加した（Ref: ADR-030）。
  - `log_err()` / `log_debug()` は除外した（理由は ADR-030 参照）。
- [ ] Arch Linux CI ジョブのアサーション戦略を改善する（Ref: ADR-033）
  - **背景と現状の制約:**
    - 現在の Arch Linux CI ジョブは `./proper7y` を実行して exit 0 を確認するのみ。
      `assert_output()` によるフィールド値の検証（レベル2アサーション）を行っていない。
    - 理由: コンテナ内では systemd が動作せず `systemd-detect-virt` も `hostnamectl` も
      使えないため `VIRTUALIZATION: Unknown` となる。
      これが `assert_output()` の `VIRTUALIZATION` のレベル2アサーションと衝突する。
  - **解決すべき問題:**
    - 問題A: `archlinux:latest` コンテナ内での仮想化検出
      - `systemd-detect-virt` と `hostnamectl` が使えない環境で、
        `VIRTUALIZATION` フィールドに `Unknown` 以外の値を返せるか。
      - 選択肢1: `archlinux:latest` に systemd を追加インストールする
        （→ 「このプロジェクトは systemd を前提とするか」という設計判断が必要になる）
      - 選択肢2: コンテナ環境を検出する別の手段（`/proc/1/cgroup` の参照など）を
        `proper7y` の `identify_virtualization_id()` に追加する
      - 選択肢3: `VIRTUALIZATION: Unknown` のままで、アサーション側を変更する
    - 問題B: アサーション戦略の見直し
      - 問題Aの解決策によっては、`assert_output()` や `REQUIRED_FIELDS` / `CONDITIONAL_FIELDS`
        の設計（ADR-029）を改訂する必要がある。
      - 「`Unknown` はバグの指標である」という設計思想を維持しながら、
        コンテナ環境での `Unknown` を正常として扱う方法を検討する。
  - **検討時の参考情報:**
    - `/proc/1/cgroup` を参照する方法は `systemd` 不要で Docker 検出ができる場合がある
    - `/.dockerenv` ファイルの存在確認でも Docker 環境を検出できる（ただし非公式な手法）
    - systemd をコンテナ内で動かすには `--privileged` フラグや専用の設定が必要になるため、
      GitHub Actions の `container:` キーとの相性を要確認
  - **優先度:** 比較的高め
  - **この検討は ADR で行うべき**

### ドキュメント

- [x] README.md に日本語の記述が混じっているのを英語に統一する
- [x] README.md に日本語の記述がまだ残っていたので、英語に統一する
  - `Conventions` セクション
- [x] Makefile のコマンドを整理し、各コマンドについての説明を文書化する
  - 書く場所は Mafile 内のコメントかな？そして、そこへのリンクを README.md に貼る感じ
- [ ] README.md の記述を全体的に見直す
  - 今あるセクションが妥当かどうか検討
    - [x] フェーズ1：明確なバグ・陳腐化
      - TL;DR・Examples -> v0.9.3 という古いバージョンが残っている
      - "Using without installation" -> v0.3.0 という古いバージョンが残っている
      - TL;DR の出力例
        -> Hyper-V上のUbuntu（= Linux）なのに KERNEL VERSION フィールドが抜けている
        （v0.10.0 から Linux では常に表示される）
      - Examples 1つ目の出力例
        -> CHASSIS : laptop（小文字）と表示されているが、コードの CHASSIS_NAMES["laptop"]="Laptop" により
        実際は Laptop が出力される
    - [ ] フェーズ2：セクション構造の整理
      - Memo セクションが開発者向けドキュメントの外に孤立している（shfmt オプション説明など）
      - "Using without installation" セクションを Installation セクション内に統合した方が自然
      - インストール方法の説明が複数箇所に散在している（重複）
    - [ ] フェーズ3：内容の妥当性検討
      - Policies セクションの内容が現状の運用と合っているか
      - "How to bump a version of my 'proper7y'" セクションの記述が現在の make bump-project の動作と一致しているか
      - など
  - 既存のセクションの内容が妥当かどうか検討
    - セクションの内容の整理
    - 古くなっている記述多そう
    - ポリシーのセクションの内容は妥当？
    - など
  - その他、全体的に色々整理する（セクションの順番とか、内容の重複とか、色々整えるとか）
- [ ] コード内ドキュメント全般について、見直す
  - 記述内容が古くなっていたり、変なところは無いか
  - （できる範囲で、軽く）記述のフォーマットをある程度整えたい
- [ ] リリース直前に ChangeLog を作成する
  - ADR-007 に記載されているワークフローに従って作業する

### プロジェクト管理

無し。

## Milestone: v0.12.0 - proper7y コードの全面再設計

このマイルストーンのテーマ：「責務の分離・テスタビリティの向上」

背景・動機・採用した設計方針は ADR-035 を参照。

### コード・機能

- [ ] `proper7y` 内の全関数をリストアップし、現状を把握する表を作成する
  - **目的:** 設計見直しの出発点として、現状を正確に把握する。
    どこに手を入れるべきかが見えないと設計議論が抽象的になりがちなので、
    この作業を最初にやることを強く推奨する。
  - **含める項目（案）:**
    - 関数名
    - 所属レイヤー（ADR-035 の Layer 1〜4 のどれか、または「未分類」）
    - 簡単な説明（1行）
    - 副作用の種類（システム読み取り / グローバル書き込み / echo / なし）
    - グローバル変数依存（読み取り / 書き込み / なし）
    - 既にユニットテストしているか（Yes / No）
    - ユニットテスト追加コスト感（Low / Medium / High）
  - **書く場所:** ADR-035 に付記するのが自然（外部ファイルを増やさなくて済む）
  - **この作業が完了してから、後続タスクの ADR を書き始める**

- [ ] Layer 2（純粋関数層）を整備する：`get_*_display_name()` 系の切り出し
  - **目的:** 「ID → 表示名」の変換ロジックを副作用なしの純粋関数として切り出す。
    引数 → 戻り値だけで完結するため、直接ユニットテスト可能になる。
  - **設計方針（案）:**

    ```bash
    # 現状: ロジック・副作用が混在
    print_os_name() {
      local -r OS_NAME="${OS_NAMES[$OS_ID]}"  # グローバル依存のロジック
      print_row "OS NAME" "$OS_NAME"           # 副作用（echo）
    }

    # 理想: 純粋関数を切り出す
    get_os_display_name() {
      local -r id="$1"
      echo "${OS_NAMES[$id]:-Unknown}"  # 引数 → 戻り値のみ。副作用なし
    }

    print_os_name() {
      print_row "OS NAME" "$(get_os_display_name "$OS_ID")"  # 薄いラッパーになる
    }
    ```

  - **対象（候補）:** `OS_NAMES`, `VIRTUALIZATION_NAMES`, `SHELL_NAMES`, `CHASSIS_NAMES`
    の各連想配列を使う変換処理すべて
  - **テスト戦略:** `run get_os_display_name "ubuntu"` で直接テスト可能（難易度：低）
  - **配列アクセス安全化（下記タスク参照）もここで併せて対応する**
  - **この検討は ADR で行うべき**（ADR-036 を想定）

- [ ] Layer 1（検出層）を整備する：`detect_*()` 系関数の切り出し
  - **目的:** システム読み取り（副作用）を `detect_*()` に集約し、
    グローバル変数への書き込みを `init()` だけに限定する。
    「誰がいつグローバルを書き換えるか」を追跡しやすくする。
  - **設計方針（案）:**

    ```bash
    # 現状: identify_os_id() がシステム読み取り・ロジック・グローバル書き込みを同時に行う

    # 理想:
    detect_os_id() {
      # /etc/os-release などを読む
      # 結果を echo で返すだけ。グローバル変数は一切触らない
      if [[ -f /etc/lsb-release ]] && grep -q "DISTRIB_ID=Ubuntu" /etc/lsb-release; then
        echo "ubuntu"
      fi
      # ...
    }

    # グローバル変数への書き込みは init() に集約する
    init() {
      readonly OS_ID="$(detect_os_id)"
      readonly VIRTUALIZATION_ID="$(detect_virtualization_id)"
      # ...
    }
    ```

  - **グローバル変数ルール（案）:**
    - `init()` の中でのみ書き込む（`readonly` で固定する）
    - それ以降は読み取り専用
    - `detect_*()` 関数はグローバル変数に一切依存しない
  - **テスト戦略:** PATH 上書きによるコマンドモックでテスト可能（難易度：高、後回し可）

    ```bash
    # mocks/uname を置いて PATH を上書きすれば detect_*() をテストできる
    setup() {
      PATH="$BATS_TEST_DIRNAME/mocks:$PATH"
    }
    ```

  - **前提条件:** Layer 2 の整備が完了していること
  - **この検討は ADR で行うべき**（ADR-037 を想定）

- [ ] `print_*()` 系関数を Layer 3 として整理する（Layer 2 整備後に対応）
  - Layer 2 が整備されれば、`print_*()` は `print_row + get_*_display_name` の
    薄いラッパーになるはず。このタスクは Layer 2 タスクの延長として扱う。
  - 独立した ADR は不要かもしれないが、実装時に判断する。

- [ ] 配列アクセスを安全化する（`${ARRAY[$KEY]:-Unknown}` 形式に統一）
  - **背景:** `set -u` 下で連想配列の未定義キーにアクセスすると即死する。
    例: `${OS_NAMES[$OS_ID]}` で `OS_ID` が想定外の値だった場合。
  - **対象:** `proper7y` 内の連想配列（`OS_NAMES`, `VIRTUALIZATION_NAMES`,
    `SHELL_NAMES`, `CHASSIS_NAMES`）へのアクセス箇所すべて
  - **実装コストが低い。Layer 2 整備タスクと同時に対応するのが効率的**

- [ ] refactor: `common.bash` のグローバル変数設計を見直す
  - **背景・動機:**
    `common.bash` の関数群がグローバル変数に強く依存しており、
    「誰がいつ書き換えるか」の追跡が困難。バグの源泉になる予感がある。
  - **変数の分類（v0.10.0 で整理済み）:**
    - Class A（設定値）: 起動時に決まり以後変わらない。`PROJECT_ROOT`, `SHELLCHECK_CMD_PATH` など
    - Class B（ユーザー設定値）: 期待バージョン。`SHELLCHECK_CURRENT_VERSION` など。
      書き換えは `overwrite_version_number_variable()` 経由のみ
    - Class C（実行時取得値）: バイナリを実行して得られる実際のバージョン。
      `SHELLCHECK_BINARY_VERSION` など。書き換えが追いにくい問題の主因
  - **問題の本体:**
    Class C 変数（`SHELLCHECK_BINARY_VERSION` / `SHFMT_BINARY_VERSION`）と、
    それを書き換える `_compose_*` / `_recompose_*` / `install_*` / `reinstall_*` の連鎖が
    「誰がいつ書き換えるか追えない」という問題の本体
  - **方針（案）:**
    「関数はグローバル変数を読み書きしない。値は引数で受け取り、結果は `echo` で返す。
    グローバル変数の更新は呼び出し側の責任とする」を基本方針とする。
    副作用の連鎖（インストール処理など）はこのルールを完全には満たせないケースがある。
    その場合は「関数がグローバル変数を書き換えることをコメントで明示する」という妥協点を設ける。
  - **Bash の制約として把握済みの問題点:**
    - 複数の戻り値がないため、複数の値を返す場合は工夫が必要
      （区切り文字での連結・`declare -n` 名前参照など）
    - `install_shellcheck()` はサブシェル（ADR-008）を内部で使っており、
      `echo` で値を返す処理が加わると「サブシェルの入れ子」になりデバッグが難しくなる可能性がある
    - `initialize_global_variables()` が2回呼ばれるとエラーになる問題も密接に関わっている
  - **この検討は ADR で行うべき**

### テスト・CI

- [ ] Bash のベストプラクティスに照らして `proper7y` 内のコードを洗い出す
  - **目的:** 「動いているが良くない書き方」を体系的に発見する
  - **参考資料（案）:**
    - [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
    - ShellCheck の全警告種別ドキュメント
    - 「Bash Pitfalls」等の定番リソース
  - **洗い出した問題点は、小さいものはそのまま修正、大きいものは別タスクに切り出す**

- [ ] bats のベストプラクティスに照らして既存ユニットテストを洗い出す
  - **目的:** 「動いているが良くない書き方」を体系的に発見する
  - **参考資料（案）:**
    - [bats-core 公式ドキュメント](https://bats-core.readthedocs.io/en/stable/)
    - [bats Gotchas ページ](https://bats-core.readthedocs.io/en/stable/gotchas.html)
  - **特に確認したい点:**
    - `run` を使うべきか直接呼び出すべきかの判断（ADR-032 参照）
    - `setup()` / `teardown()` の適切な使い方
    - `assert_*` 系ヘルパーの活用可否

- [ ] Layer 1（`detect_*()` 系）のユニットテストを検討する
  - **目的:** 環境コマンド（`uname`, `systemd-detect-virt` 等）に依存する関数をテストする
  - **方針（案）:** PATH 上書きによるコマンドモック
  - **前提条件:** Layer 1 の切り出し（`detect_*()` 系）が完了していること
  - **コスト高め。Layer 2・Layer 1 の整備後に改めて検討する**

- [ ] テスト共通ヘルパーを導入する（優先度低め）
  - **背景:** `run bash -c 'source ...; ...'` パターンが複数テストファイルに増えてきたら共通化する
  - **方針（案）:** `test/helpers/` ディレクトリを作り、bats の `load` で読み込む
  - **今すぐやる必要はない。テストファイルが 5〜6 本を超えてから検討する**

### ドキュメント

- [ ] Layer 分割設計の全体像を README.md の開発者向けセクションに追記することを検討する
  - ADR-035 に設計の概要は書いてあるが、実装が一通り完了した段階で
    README.md にも概要を追記するかどうかを判断する
  - このドキュメントは実装と乖離しないように管理・更新する必要がある。そのへんのメンテナンスコストをどうするかよく考えること。
    最終更新日時だけ付記しておき、最新に保つのは参照する人の責任とするのが現実的かもしれない。

### プロジェクト管理

無し。

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

- [ ] `format` コマンドの再検討
  - **背景:** `format` は対話的確認（`confirm_continue`）を持つため冪等でなく、
    CI で使われる `static-tests` に含められない。現状は `pre-commit` にのみ含まれ「浮いている」状態。
  - **検討事項1:** `format` コマンド自体の変更
    - `-y` フラグや `FORCE=true` 環境変数で対話確認をスキップできるようにする
    - または対話確認を廃止し、冪等なコマンドに変更する
  - **検討事項2:** `format` を `static-tests` に含めるかどうか
    - 「format を static-tests に含める（差分があればエラー）」という設計も検討する
    - この場合 `shfmt -d`（差分チェックのみ、書き換えなし）を使う形になる
  - **検討事項3:** そもそも `format` を CI で行うべきかどうか
  - **この検討は ADR で行うべき**
- [ ] `run-integ-test-to-head` には出力内容のアサーションがない (Ref: ADR-005)
- [ ] CI の `run-head-proper7y` Job と `run-integ-test-to-head` が重複している問題を解消する (Ref: ADR-005)
  - 両者はどちらも `./proper7y` を直接実行するだけで、同じことをしている
  - どちらかを削除するか、役割を明確に分けるかを検討する

### ドキュメント

- [ ] Makefile のコマンドの直接実行しないコマンドには `_` 接頭辞を付けることを検討する
  - 「Makefile のコマンドが多すぎて、作業時に結局どのコマンドを打てばよいのか迷う」ということで現在困っている
  - このルールは強制はしなくてよい。「`_` プレフィックス無いコマンドを使った方が楽だよ」くらいのニュアンス
  - 開発者が私だけだし、ルールを強制する仕組みは必要ない。
  - 具体的には、`make _lint` などを直接呼び出すよりも、より上位のコマンドである `make pre-commit` などを
    呼び出すようにした方が、私が（コミット前にテストをし忘れるなどの）ミスをしにくいよね、という話

### プロジェクト管理

- [ ] v1.0.0 までに必要なものを考える・整理する
  - 対応する環境・対象とするソフトウェアをはっきりさせる
  - README.md を最低限完成させる

### 将来検討
