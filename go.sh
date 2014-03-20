#!/bin/sh

ROOT=configmgr
CSV_DIR=csv
LUA_DIR=lua

GEN_LUA=0
GEN_BIN=0

USAGE="USAGE:\n$0 [-r root] [-c csv-dir] [-l lua-dir] [-o lua/bin/all]\n
    -r: set the root table\n
    -c: set the csv folder\n
    -l: set the output folder\n"

fill_target()
{
    if [ $1 = "lua" ]; then
        GEN_LUA=1
    elif [ $1 = "bin" ]; then
        GEN_BIN=1
    elif [ $1 = "all" ]; then
        GEN_LUA=1
        GEN_BIN=1
    fi
}

while getopts r:c:l:o: opt
do
    case "$opt" in
        r) ROOT=$OPTARG;;
        c) CSV_DIR=$OPTARG;;
        l) LUA_DIR=$OPTARG;;
        o) fill_target $OPTARG;;
        *) echo -e $USAGE; exit -1;
    esac
done

echo "----------------------------------"
echo "[csv2lua]"
echo -e "ROOT: $ROOT"
echo -e "CSV_DIR: $CSV_DIR"
echo -e "LUA_DIR: $LUA_DIR"
echo -e "GEN_LUA: $GEN_LUA"
echo -e "GEN_BIN: $GEN_BIN"
echo "----------------------------------"
echo -e "\n"

# csv -> lua
gen_lua()
{
    TIME_B=`date +%s`
    echo -e "[START] csv -> lua (`date`)"
    csv_list=`ls $CSV_DIR/*.csv`
    for file in $csv_list
    do
        lua run.lua $ROOT $file $LUA_DIR
        if [ $? -ne 0 ] ; then
            echo "[x] lua run.lua $ROOT $file $LUA_DIR"
        fi
    done
    TIME_E=`date +%s`
    echo -e "[DONE] csv -> lua (`expr $TIME_E - $TIME_B` seconds)"
}

# lua -> luac
gen_bin()
{
    TIME_B=`date +%s`
    echo -e "\n\n[START] lua -> luac(`date`)"
    lua_list=`ls $LUA_DIR/*.lua`
    for file in $lua_list
    do
        luacfile=${file}.luac
        luac -o $luacfile $file
        if [ $? -ne 0 ] ; then
            echo "[x] luac -o $luacfile $file"
        else
            echo "[-] $file -> $luacfile"
        fi
    done
    TIME_E=`date +%s`
    echo -e "[DONE] lua -> luac (`expr $TIME_E - $TIME_B` seconds)\n\n"
}

if [ $GEN_LUA -eq 1 ]; then
    gen_lua
fi

if [ $GEN_BIN -eq 1 ]; then
    gen_bin
fi

exit 0
