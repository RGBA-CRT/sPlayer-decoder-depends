LIST=`find $*`
RET=0
for f in ${LIST}; do
    echo "checking ${f} ..."
    CMOVES=`i486_i686-w64-mingw32-objdump -S ${f} | grep cmov`
    NCMOVES=`echo "$CMOVES" | wc -l`
    echo "${CMOVES}" | head -6
    if [ $NCMOVES -gt 1 ]; then
        echo -e "detect=${NCMOVES}"
        echo -e "WARNING: this file is built for i486-i586 arch CPU.\n"
        RET=-1
    fi
done
exit $RET