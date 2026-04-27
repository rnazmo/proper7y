# CHANGELOG

このプロジェクトにおける主な変更点を記録します。

## フォーマット

Keep a Changelog (<https://keepachangelog.com/ja/1.1.0/>) を参考にしつつ、簡素に運用する。

- `Added` : 新機能
- `Changed` : 既存機能またはコードの変更
- `Fixed` : バグ修正
- `Removed` : 機能またはコードの削除

---

<!-- Entries start below. Newest version comes first. -->

## v0.10.0 - 2026-04-27

今回のリリースのテーマ：「堅牢性の向上とコードの整理」

### Added

- 全Linux環境で `KERNEL VERSION` フィールドを追加した（ADR-022）
- `CHASSIS` フィールドを追加し、物理マシンのデバイス種別（Desktop / Laptop 等）を表示するようにした（ADR-023）
- デモ用GIFを作成し、README.md に追加した（ADR-025）
- 全スクリプトに `set -o pipefail` を追加し、パイプ途中のエラーを検知できるようにした（ADR-026）
- インテグレーションテストにレベル2アサーション（各フィールドの値が `Unknown` や空でないことの確認）を追加した（ADR-005）
- CIに週次スケジュールトリガーを追加した（ADR-019）
- `make bump-project` 実行時に現在のバージョンを表示するようにした

### Changed

- `identify_current_shell_id()` をプロセスツリー遡上ループに書き換えた（ADR-028）
- `print_chassis()` から識別ロジックを分離し、`identify_chassis_id()` を新設した（ADR-027）
- `init()` を `check_prerequisites()` と `identify_environment()` に分割した（ADR-013）
- `SUPPORTED_OS_IDS` 等の配列チェックを部分一致から完全一致に変更した（`is_supported()` 関数を実装）
- `print_os_version()` の `lsb_release` 依存を `/etc/os-release` に置き換えた
- `ZSH VERSION` の表示をバージョン番号のみに変更した（ビルドターゲット文字列を除去）
- `run-integ-test.linux-x64.bash` を `run-integ-test.bash` にリネームした（ADR-012）
- Makefile の `static-tests` ターゲットから `format` を除外した（ADR-006）
- CIの静的テストを `make static-tests` に一本化した
- `install_shellcheck()` 内の `trap EXIT` をサブシェルに閉じ込めてスコープを限定した（ADR-008）
- サポート環境ドキュメントを `### Support policy` セクションに一本化した（ADR-024）
- コーディング規約（SHALL/SHOULD 区別、命名規則、関数コメント形式等）を README.md に整備した
- `common.bash` のグローバル変数を分類し、所有権ルールをコメントで文書化した

### Fixed

- ローリングリリース系ディストリビューション（Arch系等）で `OS VERSION` が空欄になるバグを修正した（ADR-015）
- `CPU ARCH` と `KERNEL VERSION` の値が逆に表示されていたバグを修正した
- `verify_version_consistency()` の `grep` パターンに行頭アンカーを追加し、誤マッチを防いだ
- `install.bash` の未使用 `log_warn()` 関数を削除した
- `trap` の未バインド変数エラーを修正し、一時ディレクトリのクリーンアップを確実にした
- SC2329（未使用関数の警告）に対応し、`proper7y` から未使用関数を削除した（ADR-017）
- `print_cpu_arch()` の冗長な初期化を整理した
- macOS CI で Homebrew の bash が確実に使われるよう PATH を修正した
- EndeavourOS の検出を `/etc/os-release` の `ID` フィールドで判定するよう修正した
