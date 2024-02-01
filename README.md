# verification-platform-ps
これは検証プラットフォームPS部構築のためのレポジトリです <br>

1. Xilinx 公式の ZCU102 (2020.2) BSP ファイルをダウンロードして `./bsp` ディレクトリに置く <br>
2. Vivado で作成した.xsaファイルを `./hw` ディレクトリに置く<br>
3. `make BSP` を実行しBSPからプロジェクトを作成 (peta_proj ができる) <br>
4. `mqke kernel` を実行しカーネルの設定を行う
5. `make rootfs` を実行してrootfsにあらかじめインストーしておきたいライブラリの設定を行う
6. `make build` で linux kernel や  u-boot をビルドする
7. `make gen` でブートイメージを作成 (./peta_proj/images/linux にできる)
8. `BOOT.BIN`, `boot.scr`, `image.ub` をブートデバイスに入れるとブートする
