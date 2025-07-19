#!/bin/bash
CURDIR=$(cd "$(dirname "$0")" && pwd)
TOOL_DIR="$(cd $CURDIR/../tools; pwd)"
source ${TOOL_DIR}/config.source

find $1 -name "*" | grep -e "\.o$" -e "\.a$" -e "\.obj$" -e "\.dll" > .objlist
while read line ; do
    echo "checking ${line} ..."
    ${COMPILER_FAMILY}-objdump -S ${line} | grep cmov
    # echo -e "\n\n"

done < .objlist
# for item in "${obj_list[@]}" ; do
#     echo "checking [ ${item} ] ..."
    
# done