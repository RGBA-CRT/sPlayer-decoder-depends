#!/bin/bash
export CC="i686-w64-mingw32-gcc"
export CPP="i686-w64-mingw32-g++"
LUNCHER="ccache"
GEN="Ninja"
GENCMD="ninja"
BUILD_DIR=".build"
BUILD_MODE="Release"
CMAKE_OPT="-DBUILD_SHARED_LIBS=1"
CURDIR=$(cd "$(dirname "$0")" && pwd)
INSTALL_DIR="$CURDIR/.install"
TOOL_DIR="$(cd $CURDIR/../tools; pwd)"

CMAKE_OPT="-DCMAKE_CXX_COMPILER_LAUNCHER=${LUNCHER} -DCMAKE_C_COMPILER_LAUNCHER=${LUNCHER} -DCMAKE_TOOLCHAIN_FILE="${TOOL_DIR}/toolchain.cmake" -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} -DCMAKE_PREFIX_PATH=${INSTALL_DIR} ${CMAKE_OPT} -DCMAKE_BUILD_TYPE=${BUILD_MODE}"
# CMAKE_OPT="-DCMAKE_SYSTEM_NAME=Windows -DCMAKE_CXX_COMPILER_LAUNCHER=${LUNCHER} -DCMAKE_C_COMPILER_LAUNCHER=${LUNCHER} -DCMAKE_C_COMPILER=${CC} -DCMAKE_CXX_COMPILER=${CPP} -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} ${CMAKE_OPT}"

function vorbis(){
	pushd vorbis
	mkdir -p $BUILD_DIR
	cd $BUILD_DIR
	cmake -G ${GEN} $CMAKE_OPT ../
	ninja install
	popd
}

function ogg(){
	pushd ogg
	mkdir -p $BUILD_DIR
	cd $BUILD_DIR
	cmake -G ${GEN} $CMAKE_OPT ../
	ninja install
	popd
}

function post_proces(){
	pushd $INSTALL_DIR
	${TOOL_DIR}/post_process_dll.sh bin/*.dll
	popd
}
ogg
vorbis
post_proces

