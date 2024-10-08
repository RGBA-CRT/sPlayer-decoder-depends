# Sample toolchain file for building for Windows from an Ubuntu Linux system.
#
# Typical usage:
#    *) install cross compiler: `sudo apt-get install mingw-w64`
#    *) cd build
#    *) cmake -DCMAKE_TOOLCHAIN_FILE=~/mingw-w64-x86_64.cmake ..
# This is free and unencumbered software released into the public domain.

set(CMAKE_SYSTEM_NAME Windows)
set(TOOLCHAIN_PREFIX i486_i686-w64-mingw32)
# please remove "i486-" if you don't have i486-i686-w64-mingw32 compiler.

# cross compilers to use for C, C++ and Fortran
set(CMAKE_C_COMPILER ${TOOLCHAIN_PREFIX}-gcc)
set(CMAKE_CXX_COMPILER ${TOOLCHAIN_PREFIX}-g++)
set(CMAKE_Fortran_COMPILER ${TOOLCHAIN_PREFIX}-gfortran)
set(CMAKE_RC_COMPILER ${TOOLCHAIN_PREFIX}-windres)
# SET(CMAKE_C_COMPILER_AR  ${TOOLCHAIN_PREFIX}-gcc-ar)
# SET(CMAKE_CXX_COMPILER_AR  ${TOOLCHAIN_PREFIX}-gcc-ar)
# SET(CMAKE_C_COMPILER_RUNLIB  ${TOOLCHAIN_PREFIX}-gcc-runlib)
# SET(CMAKE_CXX_COMPILER_RUNLIB  ${TOOLCHAIN_PREFIX}-gcc-runlib)


# SET(CMAKE_AR  ${TOOLCHAIN_PREFIX}-gcc-ar)
# SET(CMAKE_RANLIB ${TOOLCHAIN_PREFIX}-gcc-ranlib)
# SET(CMAKE_C_ARCHIVE_CREATE "<CMAKE_AR> qcs <TARGET> <LINK_FLAGS> <OBJECTS>")
# SET(CMAKE_C_ARCHIVE_FINISH "<CMAKE_RANLIB> <TARGET>")
# SET(CMAKE_RANLIB ${TOOLCHAIN_PREFIX}-ranlib)

# target environment on the build host system
# set(CMAKE_FIND_ROOT_PATH /usr/${TOOLCHAIN_PREFIX})

# modify default behavior of FIND_XXX() commands
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)