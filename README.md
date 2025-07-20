# sPlayer-decoder-depends
My build environment for audio decoder.

[Tray Sound Player](https://www.vector.co.jp/soft/win95/art/se511684.html)用のオーディオデコーダのビルド環境です。

# Policy
- Win32バイナリが生成されること
- WSL & mingw-w64でビルドできること
- Windows 95で動作すること
- stdcallのAPIになること
- なるべくバイナリサイズが小さいこと

上記ポリシーでパッチを当てます。

# Build
- WSL1 & ubuntu
- todo...

# Licence
- このリポジトリに入っているスクリプト類はMITライセンスです。
- 参照先(git submoduleの先)のライブラリ、パッチはオリジナルのライセンスに従います。

# tips for older Windows machines
※当時を知らないので間違っている可能性あり

## Windows95で動くEXEを作る
- i686-w64-mingw-gccを使う
- Windows95で使えないAPIに明示的に触らなければ動くはず
  - 最近のMSDNではWindows95での対応状況を明記しなくなってしまった
  - 情報の古いサイトを頼るか、"MSDN Library for Visual Studio 2008"など古めのオフラインマニュアルを入手するとよい
- 書いた時点のバージョン
  - ubuntu 2022.04 @ 2024
  - gcc version 10-win32 20220113 (GCC) 
  - gcc-mingw-w64-i686-win32/jammy,now 10.3.0-14ubuntu1+24.3 amd64 [installed,automatic]

## Windows95でロードできるDLLを作る
- i686-w64-mingw-gccでビルドしたDLLにはnative TLS callbackがついる
- Windows95だとTLSが有効なDLLはLoadLibraryするとERROR_DLL_INIT_FAILEDで失敗する
- 詳しい説明
  - https://twitter.com/GenericRead/status/1766893450639855920
- tools/exe-tls-remover.pyでTLSセクションを除去できる
  - ただしTLSを使用していないことが前提

## Pentium機実機で動作するバイナリを作る
- これまでで作成したバイナリは仮想マシン環境では動作するはず
- しかし実際Windows95が搭載されていたころのCPUでは動作しない
  - i686-w64-mingw-gccはi686がターゲットである
  - i686はP6 Microarchitecture世代のCPUを指していると思われる。
    - 具体的にPentium Pro（ハイエンド向け）, Pentium2以降のCPU。
  - Windows95現役時代はその前の世代のCPUであり、i686用命令が含まれたバイナリは0xC000001d（無効命令）で失敗する
  - 前の世代
    - i586: Pentiumの世代
      - 後期にMMX命令が追加される
      - クロックは60MHz～200MHzぐらい？
      - 1994～1997ぐらいが全盛期？
    - i486: 80486, i486DXの世代
      - クロックは30～60MHzぐらい？
      - 1990-1993ぐらいが全盛期？
    - ref: wiki, http://exp98.web.fc2.com/PC/PC-11.HTML
- 具体的にはCMOV命令で無効命令例外が発生する
    - https://merom686.hatenablog.com/entry/20101002/1286025834
- CMOVを使っているのはmingw-w64のCRT(C Runtime)
  - つまり、i686-w64-mingw-gccでビルドしたバイナリはi586では動かない
- CRTをi486向けにビルドすれば良い
  - CRTだけビルドして差し替える方法がわからなかったのでmingw-w64ごとビルドする
  - ビルドスクリプト: depend/build_toolchain/build.sh
  - /opt/retro-mingw-i486 にビルドしたmingwがインストールされる
  - パスを通し、i486_i686-w64-mingw32-gccコマンドでビルドする
  - tools/toolchain.cmake も i486_i686に乗り換え済み