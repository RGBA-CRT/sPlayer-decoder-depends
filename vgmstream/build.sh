#!/bin/bash -e
#  sudo apt install cmake ninja-build yasm pkg-config

# DEBUG=1
CURDIR=$(cd "$(dirname "$0")" && pwd)
TOOL_DIR="$(cd $CURDIR/../tools; pwd)"
source ${TOOL_DIR}/config.source

export CC="ccache ${COMPILER_FAMILY}-gcc"
export CXX="ccache ${COMPILER_FAMILY}-g++"
export DLLTOOL="${COMPILER_FAMILY}-dlltool"
LUNCHER="ccache"
GEN="Ninja"
GENCMD="ninja"
BUILD_DIR=".build"
BUILD_MODE="Release" # 勝手にO2 O3になってしまうので使ってない（Osにしたい）
INSTALL_DIR="$CURDIR/.install"
if [ $DEBUG ] ; then
	INSTALL_DIR="$CURDIR/.install_dbg"
fi

export PKG_CONFIG_PATH=${INSTALL_DIR}/lib/pkgconfig/
export CCACHE_NODEBUG=1
export CCACHE_DEBUGDIR=`pwd`/.ccachedbg
export CCACHE_SLOPPINESS="locale,time_macros,gcno_cwd"

VGMSTREAM_CMAKE_OPT="${VGMSTREAM_CMAKE_OPT} -DBUILD_SHARED_LIBS=1"
VGMSTREAM_CMAKE_OPT="${VGMSTREAM_CMAKE_OPT} -DBUILD_CLI=ON"
VGMSTREAM_CMAKE_OPT="${VGMSTREAM_CMAKE_OPT} -DBUILD_FB2K=OFF"
VGMSTREAM_CMAKE_OPT="${VGMSTREAM_CMAKE_OPT} -DBUILD_WINAMP=OFF"
VGMSTREAM_CMAKE_OPT="${VGMSTREAM_CMAKE_OPT} -DBUILD_XMPLAY=OFF"
VGMSTREAM_CMAKE_OPT="${VGMSTREAM_CMAKE_OPT} -DBUILD_STATIC=ON"
VGMSTREAM_CMAKE_OPT="${VGMSTREAM_CMAKE_OPT} -DBUILD_DLL=ON"
VGMSTREAM_CMAKE_OPT="${VGMSTREAM_CMAKE_OPT} -DDLLTOOL=${DLLTOOL}"
VGMSTREAM_CMAKE_OPT="${VGMSTREAM_CMAKE_OPT} -DUSE_FFMPEG=ON -DFFMPEG_PATH=${INSTALL_DIR}"
if [ $DEBUG ] ; then
	VGMSTREAM_CFLAGS="-O0 -g"
else
	VGMSTREAM_CFLAGS="-flto -ffat-lto-objects -ffunction-sections -fdata-sections -Wl,--gc-sections -momit-leaf-frame-pointer -Os"
fi

# i586向けにcmoveを除去するための設定。
# 全部は除去できない（最適化によって生成されてしまう）ので一部処理で死ぬかも。その場合は以下検討。
# https://stackoverflow.com/questions/60837883/removing-cmov-instructions-using-gcc-9-2-0-x86
FFMPEG_CFLAGS="${FFMPEG_CFLAGS} -march=i486 -mtune=pentium -fPIC"
FFMPEG_CFLAGS="${FFMPEG_CFLAGS} -fno-if-conversion -fno-if-conversion2 -fno-tree-loop-if-convert "

CMAKE_OPT="${CMAKE_OPT} -DCMAKE_TOOLCHAIN_FILE="${TOOL_DIR}/toolchain.cmake" -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} -DCMAKE_PREFIX_PATH=${INSTALL_DIR} ${CMAKE_OPT} -DCMAKE_C_COMPILER_LAUNCHER=${LUNCHER}"

function vgmstream(){
	pushd vgmstream
	mkdir -p $BUILD_DIR
	cd $BUILD_DIR
	cmake -G ${GEN} $CMAKE_OPT $VGMSTREAM_CMAKE_OPT -DCMAKE_C_FLAGS="$COMMON_CFLAGS ${VGMSTREAM_CFLAGS}" ../ 
	${GENCMD} install
	popd
}
function opus(){
	pushd opus
	mkdir -p $BUILD_DIR
	cd $BUILD_DIR
	cmake -G ${GEN} $CMAKE_OPT -DOPUS_STACK_PROTECTOR=NO -DCMAKE_C_FLAGS="-fno-stack-protector" -DCMAKE_SHARED_LINKER_FLAGS="-static-libgcc" ../
	ninja install/strip
	popd
}
function ffmpeg_configure(){
	pushd ffmpeg
	FFMPEG_OPTIONS=`sed -e '/^#/d' ../vgmstream/ext_libs/extra/ffmpeg_options.txt`
	echo $FFMPEG_OPTIONS
	echo "PKG=${PKG_CONFIG_PATH}"
	# sed -i -e "s/require_pkg_config libopus/: #require_pkg_config libopus/g" configure
	
	if [ $DEBUG ] ; then
		FFMPEG_OPTIMIZE_OPT=""
		FFMPEG_CFLAGS="${FFMPEG_CFLAGS} -O0 -g"
	else
		FFMPEG_OPTIMIZE_OPT="--enable-small --enable-lto"
	fi
	sh ./configure $FFMPEG_OPTIONS \
		--target-os=mingw32 \
		--enable-cross-compile \
		--cross-prefix="ccache ${COMPILER_FAMILY}-" --arch=x86 --extra-ldflags="-static-libgcc -L${INSTALL_DIR}/lib/ " \
		--extra-cflags="-I${INSTALL_DIR}/include -I${INSTALL_DIR}/include/opus ${FFMPEG_CFLAGS} -fno-stack-protector" \
		--prefix=${INSTALL_DIR} \
		--pkgconfigdir="${PKG_CONFIG_PATH}" \
		--extra-libs="-lopus" \
		--pkg-config=pkg-config ${FFMPEG_OPTIMIZE_OPT} \
		--disable-asm

	# Windows95のmsvcrt向けにarigned mallocを無効化する。
	# mallocでアラインが取れないとSSEなどSIMD命令が落ちる。このためconfigureに--disable-asmを指定して拡張命令の使用をOFFにしている。
	# 音声Onlyかつ1倍速で処理できれば良いのでそこまでの最適化は不要という想定の下の割り切り。
	sed -i "s/define HAVE_ALIGNED_MALLOC 1/define HAVE_ALIGNED_MALLOC 0/" config.*
	popd
}
function ffmpeg_build(){
	pushd ffmpeg
	make -j6
	make install
	popd
}
function post_proces(){
	pushd ${INSTALL_DIR}
	${TOOL_DIR}/post_process_dll.sh bin/vgmstream.dll
	# python3 ${TOOL_DIR}/exe-tls-remover.py bin/avcodec-vgmstream-59.dll
	# python3 ${TOOL_DIR}/exe-tls-remover.py bin/avutil-vgmstream-57.dll
	# python3 ${TOOL_DIR}/exe-tls-remover.py bin/avformat-vgmstream-59.dll
	${TOOL_DIR}/post_process_dll.sh bin/avcodec-vgmstream-59.dll
	${TOOL_DIR}/post_process_dll.sh bin/avutil-vgmstream-57.dll
	${TOOL_DIR}/post_process_dll.sh bin/avformat-vgmstream-59.dll
	${TOOL_DIR}/post_process_dll.sh bin/swresample-vgmstream-4.dll
	popd
}

if [ "$1" != "--skip-deps" ]; then
	opus
	ffmpeg_configure
	ffmpeg_build
fi
vgmstream

if [ $DEBUG ] ; then
	cp ffmpeg/libavcodec/avcodec-vgmstream-59.dll ${INSTALL_DIR}/bin
	cp ffmpeg/libavformat/avformat-vgmstream-59.dll ${INSTALL_DIR}/bin
	cp ffmpeg/libavcodec/avcodec-vgmstream-59.dll ${INSTALL_DIR}/bin
	cp ffmpeg/libavcodec/avcodec-vgmstream-59.dll ${INSTALL_DIR}/bin
	cp vgmstream/${BUILD_DIR}/export_dll/vgmstream.dll ${INSTALL_DIR}/bin
	
else
	post_proces
fi

