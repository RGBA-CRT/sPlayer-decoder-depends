#!/bin/bash
TOOLDIR=$(cd "$(dirname "$0")" && pwd)
python3 ${TOOLDIR}/exe-tls-remover.py $*
i686-w64-mingw32-strip $*
${TOOLDIR}/upx.exe $*
