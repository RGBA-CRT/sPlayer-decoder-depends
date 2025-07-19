#!/bin/bash -e 
CURDIR=$(cd "$(dirname "$0")" && pwd)
TOOL_DIR="$(cd $CURDIR/../tools; pwd)"
source ${TOOL_DIR}/config.source

LUNCHER="ccache"
GEN="Ninja"
GENCMD="ninja"
BUILD_DIR=".build"
BUILD_MODE="Release"
CMAKE_OPT=""
INSTALL_DIR="$CURDIR/.install"

CMAKE_OPT="${CMAKE_OPT} -DCMAKE_CXX_COMPILER_LAUNCHER=${LUNCHER} -DCMAKE_C_COMPILER_LAUNCHER=${LUNCHER} -DCMAKE_TOOLCHAIN_FILE=${TOOL_DIR}/toolchain.cmake -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} -DCMAKE_PREFIX_PATH=${INSTALL_DIR} -DCMAKE_BUILD_TYPE=${BUILD_MODE} "
COMMON_CFLAGS="${COMMON_CFLAGS} -finput-charset=utf-8 -fexec-charset=cp932 -fverbose-asm -save-temps"

function OpenMidiProject(){
	# pushd nezplug/cmake/nezplug

	# mkdir -p $BUILD_DIR
	# cd $BUILD_DIR
	cmake -G ${GEN} -B${CURDIR}/${BUILD_DIR}/om $CMAKE_OPT -DCMAKE_C_FLAGS="${COMMON_CFLAGS}" -DCMAKE_SYSTEM_PROCESSOR="i686" RCSimpleMidiPlay/cmake
	# ninja install
	cmake --build ${CURDIR}/${BUILD_DIR}/om
	cmake --install ${CURDIR}/${BUILD_DIR}/om

	# popd
}
function RCSimpleMidiPlay(){
	# pushd nezplug/cmake/nezplug

	# mkdir -p $BUILD_DIR
	# cd $BUILD_DIR
	cmake -G ${GEN} -B${CURDIR}/${BUILD_DIR}/rcmp $CMAKE_OPT -DCMAKE_C_FLAGS="${COMMON_CFLAGS}" -DCMAKE_SYSTEM_PROCESSOR="i686" RCSimpleMidiPlay/experiment
	# ninja install
	cmake --build ${CURDIR}/${BUILD_DIR}/rcmp
	cmake --install ${CURDIR}/${BUILD_DIR}/rcmp

	# popd
}
function post_proces(){
	pushd $INSTALL_DIR
	i486_i686-w64-mingw32-strip bin/*.dll --strip-unneeded -s -R .tls -R .eh_frame
	${TOOL_DIR}/post_process_dll.sh bin/*.dll
	popd
}
function post_proces_exe(){
	pushd $INSTALL_DIR
	i486_i686-w64-mingw32-strip bin/*.exe --strip-unneeded -s -R .tls -R .eh_frame
	${TOOL_DIR}/post_process_dll.sh bin/*.exe
	popd
}
OpenMidiProject
RCSimpleMidiPlay
# post_proces
# post_proces_exe

