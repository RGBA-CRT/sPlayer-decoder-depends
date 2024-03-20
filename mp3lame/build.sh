#!/bin/bash
# configureのCFLAGSはDLLに効かないので仕方なくここで効かせる
export CC="ccache i686-w64-mingw32-gcc -O2"
export CXX="ccache i686-w64-mingw32-g++"
CURDIR=$(cd "$(dirname "$0")" && pwd)
INSTALL_DIR="$CURDIR/.install"
TOOL_DIR="$(cd $CURDIR/../tools; pwd)"

function lame_pre_process(){
	pushd lame
	autoconf
	LIBMP3LAME_LDADD="-static-libgcc -static-libstdc++" ./configure --build=x86_64-linux-gnu --host=i686-w64-mingw32 --prefix=${INSTALL_DIR}
	popd
}
function lame_compile(){
	pushd lame
	make -j
	make install
	popd
}
function lame_post_process(){
	pushd lame
	git reset --hard
	git clean -fd
	popd
}
function post_proces(){
	pushd $INSTALL_DIR
	${TOOL_DIR}/post_process_dll.sh bin/*.dll
	mv bin/libmp3lame-0.dll  bin/libmp3lame.dll 
	popd
}

lame_pre_process
lame_compile
# $CC $INSTALL_DIR/lib/libmp3lame.a lame/Dll/BladeMP3EncDLL.c -static-libgcc -static-libstdc++ -o $INSTALL_DIR/lib/libmp3lame.dll 
lame_post_process


post_proces

