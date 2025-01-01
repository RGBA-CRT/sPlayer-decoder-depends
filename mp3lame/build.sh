#!/bin/bash -e
CURDIR=$(cd "$(dirname "$0")" && pwd)
TOOL_DIR="$(cd $CURDIR/../tools; pwd)"
source ${TOOL_DIR}/config.source
INSTALL_DIR="$CURDIR/.install"

# configureのCFLAGSはDLLに効かないので仕方なくここで効かせる
export CC="ccache ${COMPILER_FAMILY}-gcc -O3 -march=i486 -mtune=pentium"
export CXX="ccache ${COMPILER_FAMILY}-g++"

function lame_pre_process(){
	rm -r .install -f
	pushd lame
	autoconf
	LIBMP3LAME_LDADD="-static-libgcc -static-libstdc++ -flto" ./configure --build=x86_64-linux-gnu --host=${COMPILER_FAMILY} --prefix=${INSTALL_DIR} --enable-nasm
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
	cp bin/libmp3lame-0.dll  bin/libmp3lame.dll 
	popd
}

lame_pre_process
lame_compile
# $CC $INSTALL_DIR/lib/libmp3lame.a lame/Dll/BladeMP3EncDLL.c -static-libgcc -static-libstdc++ -o $INSTALL_DIR/lib/libmp3lame.dll 
lame_post_process


post_proces

