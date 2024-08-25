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

function nezplug(){
	# pushd nezplug/cmake/nezplug

	# mkdir -p $BUILD_DIR
	# cd $BUILD_DIR
	cmake -G ${GEN} -B${CURDIR}/${BUILD_DIR} $CMAKE_OPT -DCMAKE_C_FLAGS="${COMMON_CFLAGS}" -DCMAKE_SYSTEM_PROCESSOR="i686" nezplug/cmake/nezplug
	# ninja install
	cmake --build ${CURDIR}/${BUILD_DIR} 
	cmake --install ${CURDIR}/${BUILD_DIR} 

	# popd
}
function nezplug2(){
	pushd libnezplug

	mkdir -p $BUILD_DIR
	cd $BUILD_DIR
	cmake -G ${GEN} $CMAKE_OPT -DCMAKE_C_FLAGS="${COMMON_CFLAGS}" -DCMAKE_SYSTEM_PROCESSOR="i686" ../
	ninja install

	popd
}

function post_proces(){
	pushd $INSTALL_DIR
	i486_i686-w64-mingw32-strip bin/*.dll --strip-unneeded -s -R .tls -R .eh_frame
	${TOOL_DIR}/post_process_dll.sh bin/*.dll
	popd
}

# mkdir -p $INSTALL_DIR
# libxaac
# nezplug2
nezplug
mv ${INSTALL_DIR}/bin/libnezplug.dll ${INSTALL_DIR}/bin/npnez.dll
post_proces

