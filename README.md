# sPlayer-decoder-depends
My audio decoder build environment.

[Tray Sound Player](https://www.vector.co.jp/soft/win95/art/se511684.html)用のオーディオデコーダのビルド環境です。

# Policy
- Win32バイナリが生成されること
- WSL & mingw-w64でビルドできること
- Windows 95で動作すること
- stdcallのAPIになること
- なるべくバイナリサイズが小さいこと

上記ポリシーでパッチを当てます。

# Licence
- このリポジトリに入っているスクリプト類はMITライセンスです。
- 参照先(git submoduleの先)のライブラリ、パッチはオリジナルのライセンスに従います。
