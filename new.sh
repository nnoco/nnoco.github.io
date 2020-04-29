#!/bin/bash
# references
# - https://bash.cyberciti.biz/guide/Exit_command
# - 
if [ $# -lt 2 ];
then
  echo "파라미터의 갯수가 부족합니다." $#
  echo "./new <경로> <제목> 형식으로 입력해 주세요."
  exit -1
fi

category=$1
dir=./_posts/$1
title=$2
date=`date +%F`
time=`date +%T`
filename=$date-${title// /-}.md
filepath=$dir/$filename

echo path: $filepath

# 파일 있는지 여부
if [ -a $filepath ];
then
    echo "이미 해당 파일이 있습니다. - $filepath"
else
    if [ ! -a $dir ];
    then
        `mkdir -p $dir`
    fi
    
    `touch $filepath`
    echo --- >> $filepath
    echo title: $title >> $filepath
    echo date: $date $time >> $filepath
    echo tags: >> $filepath
    echo categories: >> $filepath
    echo --- >> $filepath
    echo "$filepath 생성 완료!"
fi