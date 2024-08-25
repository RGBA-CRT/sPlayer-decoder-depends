find | grep "\.o$" > objlist
while read line ; do
    echo "checking ${line} ..."
    i686-w64-mingw32-objdump -S ${line} | grep cmov
    echo -e "\n\n"

done < objlist
# for item in "${obj_list[@]}" ; do
#     echo "checking [ ${item} ] ..."
    
# done