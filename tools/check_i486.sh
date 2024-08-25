LIST=`ls $* -1`
RET=0
for f in ${LIST}; do
    echo "checking ${f} ..."
    CMOVES=`i486_i686-w64-mingw32-objdump -S ${f} | grep cmov`
    NCMOVES=`echo $CMOVES | wc -l`
    echo "${CMOVES}"
    if [ $NCMOVES -ne 1 ]; then
        echo "this file is built for i686 arch CPU."
        RET=-1
    fi
    # echo -e "\n\n"
done
exit $RET