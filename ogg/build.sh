#!/bin/bash -e 
CURDIR=$(cd "$(dirname "$0")" && pwd)
TOOL_DIR="$(cd $CURDIR/../tools; pwd)"
source ${TOOL_DIR}/config.source

LUNCHER="ccache"
GEN="Ninja"
GENCMD="ninja"
BUILD_DIR=".build"
BUILD_MODE="Release"
CMAKE_OPT="-DBUILD_SHARED_LIBS=1"
INSTALL_DIR="$CURDIR/.install"

CMAKE_OPT="-DCMAKE_CXX_COMPILER_LAUNCHER=${LUNCHER} -DCMAKE_C_COMPILER_LAUNCHER=${LUNCHER} -DCMAKE_TOOLCHAIN_FILE=${TOOL_DIR}/toolchain.cmake -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} -DCMAKE_PREFIX_PATH=${INSTALL_DIR} ${CMAKE_OPT} -DCMAKE_BUILD_TYPE=${BUILD_MODE} "
echo ${CMAKE_OPT}
function vorbis(){
	pushd vorbis
	git apply ../vorbis-*.patch | echo
	mkdir -p $BUILD_DIR
	cd $BUILD_DIR
	cmake -G ${GEN} $CMAKE_OPT -DCMAKE_C_FLAGS="${COMMON_CFLAGS}" ../
	ninja install
	git reset --hard
	popd
}

function ogg(){
	pushd ogg
	git apply ../ogg-*.patch | echo
	mkdir -p $BUILD_DIR
	cd $BUILD_DIR
	cmake -G ${GEN} $CMAKE_OPT -DCMAKE_C_FLAGS="${COMMON_CFLAGS}" ../
	ninja install
	git reset --hard
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

