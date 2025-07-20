#!/bin/bash
TOOLDIR=$(cd "$(dirname "$0")" && pwd)
python3 ${TOOLDIR}/exe-tls-remover.py $*
i486_i686-w64-mingw32-strip $* --strip-unneeded -s -R .comment -R .gnu.version
i486_i686-w64-mingw32-strip $* --strip-unneeded -s -R .tls
${TOOLDIR}/check_i486.sh $*
if [ $? -ne 0 ]; then
    echo "================== BUILD WARNING =================="
    echo "CPU check failed."
    # exit -1
fi
${TOOLDIR}/upx/upx.exe -7 $*