#!/bin/bash -e

# Build mingw-w64 CRT (+ compiler) to run compiled programs on i486 CPU.
# tested on Ubuntu 22.04.3 LTS on WSL.

# https://qiita.com/notunusualtales/items/6a4bf96a9f4e946aebc3
# https://gist.github.com/jeroen/b3876b065512299d80f1

# We use Ubuntu 14.04 to build a native gcc for win32 with multilib support
#
# Based on:
# http://sourceforge.net/p/mingw-w64/wiki2/Native%20Win64%20compiler/
# http://sourceforge.net/p/mingw-w64/code/HEAD/tree/stable/v3.x/mingw-w64-doc/howto-build/mingw-w64-howto-build.txt?format=raw
#
# Cross compiling notes:
# - The minor version of gcc must match that of our cross compiler (4.8 in this case)
# - Important parameters: http://gcc.gnu.org/onlinedocs/gccint/Configure-Terms.html
#
# Use ubuntu cross compiler
# sudo apt-get install make gcc-mingw-w64-x86-64 gcc-mingw-w64-i686 mingw-w64

# Setup dir structure
BUILDROOT=~/build_mingw
SRC=$BUILDROOT/sources
DEST=/opt/retro-mingw-i486
TOOL_NAME=i486_i686-w64-mingw32
mkdir -p $BUILDROOT
mkdir -p $SRC
mkdir -p $DEST

cd $SRC

# mingwにc52f1eb09901e038ceb7012730e7cf3395d65a78が入っていないバージョンを探す
# 　ちなみに、現在まだタグがついていないが上記をrevertする修正が出ている
#   https://sourceforge.net/p/mingw-w64/mingw-w64/ci/4953f7746a9aca7ae065fa9aa77eb9d02d0ed752/
MINGW_RELEASE=mingw-w64-v10.0.0
GCC_RELEASE=gcc-13.2.0
BINUTILS_RELEASE=binutils-2.24

function ret_check(){
    if [ "$1" -ne "$2" ]; then
        echo "############################ unexpected retval: expected=$2, real=$1"
        echo "PRESS ENTER TO CONTINUE> " && read
        # exit
    fi
}

function get_src(){
    # Get sources
    wget http://ftp.gnu.org/gnu/binutils/${BINUTILS_RELEASE}.tar.bz2
    tar xvjf ${BINUTILS_RELEASE}.tar.bz2
    wget https://jaist.dl.sourceforge.net/project/mingw-w64/mingw-w64/mingw-w64-release/${MINGW_RELEASE}.tar.bz2
    tar xjvf ${MINGW_RELEASE}.tar.bz2
    wget http://ftp.gnu.org/gnu/gcc/${GCC_RELEASE}/${GCC_RELEASE}.tar.xz
    # tar --exclude="${GCC_RELEASE}/gcc/testsuite/*" --exclude="${GCC_RELEASE}/libgo/*" -xvf ${GCC_RELEASE}.tar.xz
    tar -xvf ${GCC_RELEASE}.tar.xz
}

function get_binutil_dep(){
    # Get gcc dependencies
    cd ${GCC_RELEASE}
    ./contrib/download_prerequisites
}

# Make binutils
function build_binutils(){
    echo "=============== BUID binutils ==============="
    mkdir -p $BUILDROOT/binutils
    cd $BUILDROOT/binutils
    $SRC/${BINUTILS_RELEASE}/configure --prefix=$DEST --with-sysroot=$DEST --target=i686-w64-mingw32 --enable-targets=i686-w64-mingw32,x86_64-w64-mingw32 --enable-lto --enable-plugins --enable-gold --disable-werror --enable-install-libiberty #--enable-64-bit-bfd
    ret_check $? 0
    make -j
    ret_check $? 0
    make install
}


function build_header(){
    echo "=============== BUID mingw-header ==============="
    # Build mingw headers
    # Assumes we are building with x86_64-w64-mingw32 cross compiler!
    mkdir -p $BUILDROOT/headers
    cd $BUILDROOT/headers
    $SRC/${MINGW_RELEASE}/mingw-w64-headers/configure --prefix=$DEST/i686-w64-mingw32 --host=i686-w64-mingw32 --build=x86_64-w64-mingw32  #--build=i686-w64-mingw32
    make
    make install
    
    # Symlink for gcc
    ln -s $DEST/i686-w64-mingw32 $DEST/mingw
}


function build_gcc(){
    echo "=============== BUID GCC ==============="
    # Multilib symlink. Not sure if this is necessary for i686.
    # ln -s $DEST/i686-w64-mingw32/lib $DEST/i686-w64-mingw32/lib64

    # Building GCC
    # Not sure about --disable-shared
    mkdir -p $BUILDROOT/gcc
    cd $BUILDROOT/gcc
    $SRC/${GCC_RELEASE}/configure -v --target=i686-w64-mingw32 --prefix=$DEST --with-sysroot=$DEST --enable-targets=all --enable-languages=c,c++,lto --disable-sjlj-exceptions --with-dwarf2 --disable-multilib --enable-libstdcxx-time=yes --enable-threads=win32 --enable-libstdcxx-threads=yes --enable-libatomic --enable-plugin --enable-lto --enable-fully-dynamic-string 	--disable-libstdcxx-pch	--disable-libstdcxx-debug 	--enable-libstdcxx --disable-rpath	--disable-win32-registry --disable-nls --disable-werror --disable-symvers --with-pkgversion="i686-w64-mingw32, with i486 stdlib" CC="ccache cc" CXX="ccache c++" 
    
    ret_check $? 0
    make all-gcc -j 6
    ret_check $? 0
    make install-gcc
    ret_check $? 0
}

function build_crt(){
    echo "=============== BUID CRT ==============="
    # Building CRT (Mingw-w64 itself)
    mkdir -p $BUILDROOT/crt
    cd $BUILDROOT/crt
    $SRC/${MINGW_RELEASE}/configure --host=i686-w64-mingw32 --prefix=$DEST/i686-w64-mingw32 --with-sysroot=$DEST/i686-w64-mingw32 --enable-lib32 --enable-warnings=0 CC="ccache i686-w64-mingw32-gcc" CXX="ccache i686-w64-mingw32-g++" CFLAGS="-march=i486 -mtune=pentium -Os"
    make -j
    make install
}

function install_gcc(){
    echo "=============== INSTALL GCC ==============="
    # Finishing gcc
    cd $BUILDROOT/gcc
    $SRC/${GCC_RELEASE}/configure --target=i686-w64-mingw32 --prefix=$DEST --with-sysroot=$DEST --enable-targets=all --enable-languages=c,c++,lto --disable-sjlj-exceptions --with-dwarf2 --disable-multilib --enable-libstdcxx-time=yes --enable-threads=win32 --enable-libstdcxx-threads=yes --enable-libatomic --enable-plugin --enable-lto --enable-fully-dynamic-string 	--disable-libstdcxx-pch	--disable-libstdcxx-debug 	--enable-libstdcxx --disable-rpath	--disable-win32-registry --disable-nls --disable-werror --disable-symvers --with-pkgversion="i686-w64-mingw32, with i486 stdlib" CC="ccache cc" CXX="ccache c++" 
    make 
    make install-strip
}

function gen_link(){
    commands=("addr2line"
              "ar"
              "as"
              "c++"
              "c++filt"
              "cpp"
              "dlltool"
              "dllwrap"
              "elfedit"
              "g++"
              "gcc"
              "gcc-ar"
              "gcc-nm"
              "gcc-ranlib"
              "gcov"
              "gcov-dump"
              "gcov-tool"
              "gprof"
              "ld"
              "lto-dump"
              "nm"
              "objcopy"
              "objdump"
              "ranlib"
              "readelf"
              "size"
              "strings"
              "strip"
              "windmc"
              "windres")
    LINK_DIR=$DEST/bin_export
    mkdir -p $LINK_DIR
    for item in "${commands[@]}" ; do
        echo "[ ${item} ]"
        ln $DEST/bin/i686-w64-mingw32-$item $LINK_DIR/${TOOL_NAME}-$item
    done
    echo "export PATH=$DEST/bin_export:\${PATH}" > $DEST/envfile
}

get_src
get_binutil_dep
build_binutils

# Add path (required for building gcc later)
export PATH="$PATH:$DEST/bin"

build_header
build_gcc
build_crt
install_gcc
gen_link