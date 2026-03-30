# TODO

## Priority: ☆☆☆

- Check "prerequisites exists?", "the os is supported os?":
  - proper7y: 最初に OS を特定し、未対応の OS の場合にはエラーを返して終了させる
    - main 関数の最初で OS を特定し、その情報を変数に保存しておく
  - コマンドの exit status を整える。(正常終了で 0 を返す、など)
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
      - <https://github.com/rnazmo/proper7y/blob/5d25e105ac879c5787945b333f13327e33cdb562/README.md?plain=1#L163-L166>
    - やっぱり、変更が大きいときは branch 使いたいかも。
    - 「**なるべく `main` だけ**の状態を維持することが望ましい。ただし、機能追加などで**一時的な**ブランチを作るのは全く構わない」などと改定する？
    - Google Style Guide
    - Conventional Commits

## Priority: ☆

- `v1.0.0` までに実装すべきもの(足りないもの)を列挙しておく
  - 対応する環境・対象とするソフトウェアをはっきりさせる
    - 対応する環境は？:
      - OS: ubuntu, kali, macos, ...
      - shell: bash, zsh
  - オプション機能は作る？どうする？
  - README.md の内容を整える
    - Refine README.md (内容が重複しているところとかある)
    - `install.bash` がある理由を書いておく
      - これを使うと常に同じコマンドで最新版をインストールできる。使わない場合、明示的にバージョンを指定しなければならなくて面倒。(特に、別のスクリプト中で 'property' をインストールする場合、バージョン管理しなくてはならず面倒)
      - ref: <https://github.com/rnazmo/proper7y/blob/6b77aee0debf25f4d6f6a1aee8224c84470a765f/README.md#do-not-download-install-proper7y-without-specifying-the-version>
      - 書き方はここが参考になりそう：
        - <https://github.com/golangci/golangci-lint/blob/3c795d8637855c813c7c22fb36a3521c726bcd87/docs/src/docs/usage/install/index.mdx#other-ci>
        - <https://github.com/golangci/golangci-lint/blob/3c795d8637855c813c7c22fb36a3521c726bcd87/docs/src/docs/usage/install/index.mdx#install-from-source>
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
  - Run the script `check-devel-tools-versions.bash` on CI ?
    - Trigger: weekly (Can I use <https://docs.github.com/en/actions/reference/events-that-trigger-workflows#scheduled-events> ?)
  - 自動で Pull Request 作成するところまでやる？ (dependabot みたいに)
    - 実装や権限管理面倒じゃない？大丈夫？
    - そもそも Pull Request はあまり使いたくないのでは？
    - でもあると便利だし、Bot に限れば Pull Request 使っても良いかも。
  - Add the badge to `README.md`. (The text is like `dependencies latest` ?)
- Add ChangeLog
