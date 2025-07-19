#!/bin/bash -e

#  sudo apt install cmake ninja-build yasm

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
BUILD_MODE="Release"
INSTALL_DIR="$CURDIR/.install"

export PKG_CONFIG_PATH=${INSTALL_DIR}/lib/pkgconfig/

VGMSTREAM_CMAKE_OPT="${VGMSTREAM_CMAKE_OPT} -DBUILD_SHARED_LIBS=1"
VGMSTREAM_CMAKE_OPT="${VGMSTREAM_CMAKE_OPT} -DBUILD_CLI=ON"
VGMSTREAM_CMAKE_OPT="${VGMSTREAM_CMAKE_OPT} -DBUILD_FB2K=OFF"
VGMSTREAM_CMAKE_OPT="${VGMSTREAM_CMAKE_OPT} -DBUILD_WINAMP=OFF"
VGMSTREAM_CMAKE_OPT="${VGMSTREAM_CMAKE_OPT} -DBUILD_XMPLAY=OFF"
VGMSTREAM_CMAKE_OPT="${VGMSTREAM_CMAKE_OPT} -DBUILD_STATIC=ON"
VGMSTREAM_CMAKE_OPT="${VGMSTREAM_CMAKE_OPT} -DBUILD_DLL=ON"
VGMSTREAM_CMAKE_OPT="${VGMSTREAM_CMAKE_OPT} -DDLLTOOL=${DLLTOOL}"
VGMSTREAM_CMAKE_OPT="${VGMSTREAM_CMAKE_OPT} -DUSE_FFMPEG=ON -DFFMPEG_PATH=${INSTALL_DIR}"
# VGMSTREAM_CFLAGS="-ffunction-sections -fdata-sections -Wl,--gc-sections -Os -momit-leaf-frame-pointer "
# VGMSTREAM_CFLAGS="-flto -ffat-lto-objects -ffunction-sections -fdata-sections -Wl,--gc-sections "

FFMPEG_CFLAGS="${FFMPEG_CFLAGS} -v -march=i486 -mtune=pentium -fPIC"
FFMPEG_CFLAGS="${FFMPEG_CFLAGS} -fno-if-conversion -fno-if-conversion2 -fno-tree-loop-if-convert " #本当はこれを効かせたいが最適化オプションによって勝手にONになるため効果がない。

CMAKE_OPT="${CMAKE_OPT} -DCMAKE_TOOLCHAIN_FILE="${TOOL_DIR}/toolchain.cmake" -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} -DCMAKE_PREFIX_PATH=${INSTALL_DIR} ${CMAKE_OPT} -DCMAKE_BUILD_TYPE=${BUILD_MODE}"
# CMAKE_OPT="-DCMAKE_SYSTEM_NAME=Windows -DCMAKE_CXX_COMPILER_LAUNCHER=${LUNCHER} -DCMAKE_C_COMPILER_LAUNCHER=${LUNCHER} -DCMAKE_C_COMPILER=${CC} -DCMAKE_CXX_COMPILER=${CPP} -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} ${CMAKE_OPT}"

function vgmstream(){
	pushd vgmstream
	mkdir -p $BUILD_DIR
	cd $BUILD_DIR
	cmake -G ${GEN} $CMAKE_OPT $VGMSTREAM_CMAKE_OPT -DCMAKE_C_FLAGS="$COMMON_CFLAGS ${VGMSTREAM_CFLAGS}" ../ 
	# cmake -G ${GEN} $CMAKE_OPT $VGMSTREAM_CMAKE_OPT -DCMAKE_C_FLAGS="-march=i486 -mtune=pentium -nostdlib -L${CRTPATH} -lkernel32 -luser32 -lgdi32 -lwinspool -lshell32 -lole32 -loleaut32 -luuid -lcomdlg32 -ladvapi32 -lmingw32 -lgcc -lgcc_eh -lmoldname -lmingwex -lmsvcrt -ladvapi32 -lshell32 -luser32 -lkernel32 -lmingw32 -lgcc -lgcc_eh -lmoldname -lmingwex -lmsvcrt" ../ 
	${GENCMD} install
	popd
}
function opus(){
	pushd opus
	mkdir -p $BUILD_DIR
	cd $BUILD_DIR
	cmake -G ${GEN} $CMAKE_OPT -DCMAKE_SHARED_LINKER_FLAGS="-fstack-protector -static-libgcc" ../
	ninja install/strip
	popd
}
function ffmpeg_configure(){
	pushd ffmpeg
	FFMPEG_OPTIONS=`sed -e '/^#/d' ../vgmstream/ext_libs/extra/ffmpeg_options.txt`
	echo $FFMPEG_OPTIONS
	# sed -i -e "s/require_pkg_config libopus/: #require_pkg_config libopus/g" configure
	sh ./configure $FFMPEG_OPTIONS \
		--logfile=configure.log \
		--target-os=mingw32 \
		--enable-cross-compile \
		--cross-prefix="ccache ${COMPILER_FAMILY}-" --arch=x86 --extra-ldflags="-static-libgcc -L${INSTALL_DIR}/lib/ -fstack-protector " \
		--extra-cflags="-I${INSTALL_DIR}/include -I${INSTALL_DIR}/include/opus ${FFMPEG_CFLAGS}" \
		--prefix=${INSTALL_DIR}\
		--pkgconfigdir="${PKG_CONFIG_PATH}"\
		--extra-libs="-lopus" \
		--pkg-config=pkg-config \
		--disable-optimizations
		# --enable-small
	# TODO： --enable-lto
	# sh ./configure $FFMPEG_OPTIONS --logfile=.build/configure.log --target-os=mingw32 --enable-cross-compile --cross-prefix="ccache ${COMPILER_FAMILY}-" --arch=x86 --extra-ldflags="-static-libgcc -L${INSTALL_DIR}/lib/  -Wl,--start-group -lopus -Wl,--end-group   --verbose" --extra-cflags="-I${INSTALL_DIR}/include -I${INSTALL_DIR}/include/opus" --prefix=${INSTALL_DIR}
	popd
}
function ffmpeg_build(){
	pushd ffmpeg
	make -j6
	make install
	popd
}
function post_proces(){
	pushd $INSTALL_DIR
	${TOOL_DIR}/post_process_dll.sh bin/vgmstream.dll
	popd
}

if [ "$1" != "--skip-deps" ]; then
	opus
	ffmpeg_configure
	ffmpeg_build
fi
vgmstream
post_proces

