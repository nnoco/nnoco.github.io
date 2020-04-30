---
title: Jekyll 명령어 만들기
tags: [Jekyll, 'Shell Script']
categories: [blog]
date: 2019-11-24 17:03:59
---

쉘 스크립트 연습도 할 겸, 자주 사용하는 Jekyll 명령어를 조금 더 편하게 써보려고 Node.js `package.json`의 `scripts`처럼 활용할 수 있게 몇 가지 Jekyll 명령어를 만들어 보았습니다.

# 새로운 포스트 생성
`_posts` 디렉토리에 새로운 파일을 생성합니다. `./new.sh <_posts/하위 경로> "<제목>"` 형식으로 사용합니다. 띄어쓰기가 없따면 쌍따옴표(`"`)로 감싸주지 않아도 됩니다.
```sh
#!/bin/bash
# new.sh 파일
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
```

예시
```bash
# new.sh 파일에 권한 부여(최초 1회)
$ chmod 500 new.sh

# _posts/hello/world에 yyyy-MM-dd-Hello-World.md 파일 생성
$ ./new.sh hello/world "Hello World"
path: ./_posts/hello/world/2020-05-01-hello-world.md
./_posts/hello/world/2020-05-01-hello-world.md 생성 완료!
```
결과로 아래와 같이 Front Matter 템플릿의 `2020-05-01-hello-world.md` 파일이 생성됩니다.
```
---
title: hello world
date: 2020-05-01 00:24:40
tags:
categories:
---
```

# draft 및 미래 날짜의 포스트도 함께 serve
```bash
#!/bin/bash
# serve.sh 파일
bundle exec jekyll serve --future -V --drafts
```
예시
```bash
# serve.sh 파일에 권한 부여(최초 1회)
$ chmod 500 serve.sh

$ ./serve.sh
```

# draft 및 미래 날짜의 포스트도 함께 build
```bash
#!/bin/bash
# build.sh 파일
bundle exec jekyll build --future -V
```
예시
```bash
# build.sh 파일에 권한 부여(최초 1회)
$ chmod 500 build.sh

$ ./build.sh
```

# References
- https://www.tutorialkart.com/bash-shell-scripting/