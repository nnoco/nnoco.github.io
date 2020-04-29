---
title: Jekyll 설치와 github plugin 적용
date: 2019-11-24 17:05:05
tags:
  - 'jekyll'
  - 'install'
  - 'github-plugin'
categories: [blog]
---

Jekyll은 정적 웹 페이지 변환기(생성기)입니다. 마크다운 또는 텍스트 등의 파일을 Jekyll을 통해 템플릿이 적용된 웹 페이지(HTML 파일)로 변환할 수 있으며 또한 GitHub에 내장되어 다양한 활용이 가능합니다.
[https://jekyllrb.com/showcase](https://jekyllrb.com/showcase)에서 Jekyll을 사용하고 있는 여러 사이트들을 살펴보세요.

(이 포스트는 MacOS 환경을 기준으로 작성되었습니다. 타 운영체제는 [jekyll 공식 사이트의 설치 문서를](https://jekyllrb.com/docs/installation/) 참고해 주세요.)

# rbenv 설치
Jekyll은 Ruby 언어로 작성되어 있어 jekyll을 설치하고 사용하기 위해서는 4.0 버전 기준, 루비 2.4.0 버전이 필요합니다.
ruby 버전이 2.4 미만이라면 아래와 같은 메시지와 함께 설치가 진행되지 않습니다. 
```
ERROR:  Error installing jekyll:
	jekyll-sass-converter requires Ruby version >= 2.4.0.
```

터미널에서 `ruby -v` 명령어로 현재 설치되어 있는 루비 버전을 확인하거나 설치되지 않은 경우 루비 설치가 필요합니다.
아래는 [https://jekyllrb.com/docs/installation/macos](https://jekyllrb.com/docs/installation/macos)에 가이드 되어 있는 내용입니다.
MacOS에서 패키지 관리를 위해 많이 쓰이는 homebrew를 설치한 후 homebrew를 이용해 rbenv를, rbenv로 필요한 버전의 루비를 설치하는 방법입니다.
rbenv는 여러 버전의 루비를 설치하고 사용할 수 있게 해주는 도구입니다. 루비 설치만을 위한 패키지 매니저로 볼 수 있습니다.
루비 외에도 다른 언어들도 언어 버전 관리를 쉽게 할 수 있는 도구들이 만들어져 있습니다. (python-pyenv, nodejs-nvm 등)

```bash
# Homebrew 설치
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# homebrew로 rbenv 설치
brew install rbenv

# rbenv 초기화 - ~/.bash_profile 의 끝에 eval "$(rbenv init -)" 추가

# 설치 확인
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/master/bin/rbenv-doctor | bash
```

## rbenv로 사용할 수 있는 버전 확인하고 설치 및 사용하기
```bash
# 설치되어 있느 루비 버전들을 확인
rbenv versions

# 현재 사용중인 루비 버전을 확인
rbenv version

# 설치할 수 있는 루비 버전들 확인
# 굉장히 많은 버전이 출력되며, 스크롤을 쭉 올려서 숫자로만 구성된 버전을 사용하시면 됩니다.
rbenv install -l

# 저는 여기에서 2.6.5 버전을 설치하도록 하겠습니다
# 2.6.5 버전의 루비 설치
# 설치하는데 시간이 꽤 소요되니 멈춰있는게 아니니 기다려주세요.
rbenv install 2.6.5

# 설치된 버전을 확인(설치한 2.6.5가 목록에 표시됩니다.)
rbenv versions

# 시스템에서 2.6.5 버전을 사용하도록 설정
rbenv global 2.6.5

# 현재 사용중인 버전 확인
rbenv version
```

# Jekyll 설치
Jekyll을 사용하기 위한 루비까지 설정을 마쳤으니, 루비를 이용해 Jekyll을 설치해볼 차례입니다. 루비의 패키지(모듈)은 gem 이라고 부르며, RubyGems(`gem` 명령어)를 통해 gem들을 설치하여 사용할 수 있습니다. 
Jekyll도 gem으로 패키징되어 있어 `gem` 명령어를 통해 설치하며, `gem` 명령어는 루비를 설치할 때 함께 설치되어 루비가 정상적으로 설치되었다면 바로 사용할 수 있습니다.

```bash
# RubyGems로 bunlder와 jekyll 설치
gem install bundler jekyll
```
위 명령을 실행하면 이것 저것 필요한 루비 젬들을 설치합니다. 이번에도 인내를 갖고 기다려주세요. 정상적으로 설치되었다면 이제 `jekyll` 명령어를 사용할 수 있습니다.

# Jekyll 사용하기
## Jekyll 작업 폴더 초기화
Jekyll을 사용해서 블로그를 시작할 때는 `jekyll new` 명령어를 사용하며, 명령어를 실행하면 하나의 작업 폴더가 만들어집니다. (만들어둔 폴더가 있다면 `--force` 옵션을 추가해 초기화할 수 있습니다.)

```bash
# 새로운 폴더를 만들면서 초기화
jekyll new 폴더이름

# 현재 폴더를 작업 폴더로 사용
jekyll new . --force

# 미리 만들어진 폴더를 작업 폴더로 사용
jekyll new 경로 --force
```

Jekyll 작업 폴더를 초기화 했다면 아래와 같은 파일들이 생성된 것을 확인할 수 있습니다.
```
├── 404.html
├── Gemfile
├── Gemfile.lock
├── _config.yml
├── _posts
│   └── 2019-11-25-welcome-to-jekyll.markdown
├── about.markdown
└── index.markdown
```

`_posts` 폴더가 보이고 해당 폴더 아래에 `2019-11-25-welcome-to-jekyll.markdown` 파일이 있습니다. 
`_posts` 폴더는 작성한 글(포스트)이 위치하는 폴더이고, `_posts` 폴더 아래에 다른 폴더를 만들어서 그 안에 포스트를 작성해도 무방합니다.
포스트 파일의 이름에 날짜가 들어가 있는데, 규칙을 지켜주어야 Jekyll이 정상적으로 인식하고 웹 페이지로 생성합니다. 
`4자리의 연도-2자리 월-2자리 일-제목(공백은 - 기호로 구분).확장자`의 형식으로 파일 이름을 지정해 줍니다.

## 포스트 작성하기
포스트는 블로그에 쓰는 글을 의미합니다. 저는 오늘 날짜인 2019-11-25로 Hello World라는 제목을 갖는 파일을 `_posts` 폴더에 만들어주도록 하겠습니다.

`_posts/2019-11-25-hello-world.md` 파일
```
---
title: Hello World
date: 2019-11-25
tags: [jekyll, blog]
---
# Hello, Jekyll!
첫 포스트입니다.
```

파일의 내용을 보면 두 줄의 `---` 사이에 포스트와 관련된 메타 정보를 작성해주는데, 이를 YAML 헤더 또는 YAML Front Matter 블록이라고 합니다. 모든 포스트는 YAML 헤더가 포함되어 있어야 하고, 
Jekyll은 이 데이터를 이용해 포스트 목록, 태그별 포스트, 카테고리별 포스트 등을 만들어낼 수 있습니다. 자세한 내용은 [Jekyll 문서](https://jekyllrb.com/docs/configuration/front-matter-defaults/)를 확인해 주세요.

[YAML](https://ko.wikipedia.org/wiki/YAML)은 JSON처럼 데이터를 표현하기 위한 양식입니다. 일반적인 값이나 문자열, 배열, 객체 등을 표현할 수 있으며, 표현식이 어렵지 않아 금방 익힐 수 있습니다.

어쨌든 하나의 포스트를 잘 작성했으니 어떻게 보이는지 확인해보도록 하겠습니다.
터미널로 돌아와서 작업 폴더 내에서 `bundle exec jekyll serve` 명령를 실행합니다. `serve` 옵션은 로컬에서 정적 페이지를 볼 수 있는 서버를 실행해서 생성된 웹 페이지를 확인할 수 있도록 도와줍니다.
```
# jekyll serve 실행
bundle exec jekyll serve

# 아래는 실행후 출력되는 내용입니다.
Configuration file: /Users/newt.off/test-jekyll/_config.yml
            Source: /Users/newt.off/test-jekyll
       Destination: /Users/newt.off/test-jekyll/_site
 Incremental build: disabled. Enable with --incremental
      Generating...
       Jekyll Feed: Generating feed for posts
                    done in 0.416 seconds.
 Auto-regeneration: enabled for '/Users/newt.off/test-jekyll'
    Server address: http://127.0.0.1:4000/
  Server running... press ctrl-c to stop.
```
아래쪽에 `Server address: http://127.0.0.1:4000/` 라고 표시되어 있는데 웹 브라우저에서 해당 주소를 입력하면 Jekyll로 생성된 페이지를 볼 수 있습니다. 금방 작성한 Hello World 글도 보이네요.
`serve`를 실행하면 실행한 프로세스가 끝나지 않고 계속 대기 중인 상태에 있는데, 웹 페이지를 제공하기 위한 서버 프로세스가 사용자의 접속을 4000번 포트로 받고, 페이지를 제공하기 위해서입니다. 
이 상태에서는 추가적인 명령어를 입력할 수 없으므로, 새로운 터미널 창 또는 탭을 띄우거나, 종료하고 싶을 때는 `Ctrl + c` 키를 입력하면 다시 명령어를 입력할 수 있는 프롬트(Prompt)가 표시됩니다.

이 `serve` 명령어는 실행하면 `build` 라는 과정이 선행됩니다. 작성한 포스트를 정적 웹 페이지로 생성하기 위한 과정이 `build`입니다. `build`는 `serve`와 마찬가지로 독립적인 명령으로 실행할 수 있고,
`build` 명령을 실행하면, `_site` 폴더에 정적 웹 페이지들이 생성된 것을 확인하실 수 있습니다. 
Jekyll이 `new` 명령을 통해 초기화를 할 때 Git이 `_site`와 같은 폴더나 파일을 추적하지 않도록 `.gitignore` 파일이 자동으로 생성된 것을 확인할 수 있습니다.

Jekyll이 자동으로 생성한 `.gitignore` 파일
```
_site
.sass-cache
.jekyll-cache
.jekyll-metadata
vendor
```

이 `_site` 디렉토리는 블로그의 모습을 한 최종적인 파일들이 있습니다. 자신의 웹 서버에 `_site` 폴더의 내용을 업로드하면 블로그를 운영할 수 있게 됩니다.
GitHub에서 제공하는 GitHub Pages 기능을 활용하면 이를 간단하게 할 수 있습니다. 로컬에서 확인할 때는 `build`나 `serve`를 사용하면 되고, GitHub에서 repository의 GitHub Pages 사용을 설정해두었다면,
변경 내용을 GitHub으로 push만 하면 GitHub에서 자동으로 `build` 과정을 수행하게 되고 그 결과는 해당 repository의 GitHub Pages 주소로 접속하여 확인할 수 있습니다.

단, GitHub Pages와 연동을 위해서는 조금의 설정 파일 수정이 필요합니다. `jekyll new` 명령을 통해 생성된 작업 폴더 내에 `Gemfile` 이라는 파일이 함께 초기화되어 있습니다.
`Gemfile` 파일은 RubyGems가 이 프로젝트에 어떤 gem이 필요한지에 대한 정보를 담고 있습니다.

처음 생성됐을 때의 `Gemfile`
```ruby
source "https://rubygems.org"
# Hello! This is where you manage which Jekyll version is used to run.
# When you want to use a different version, change it below, save the
# file and run `bundle install`. Run Jekyll with `bundle exec`, like so:
#
#     bundle exec jekyll serve
#
# This will help ensure the proper Jekyll version is running.
# Happy Jekylling!
gem "jekyll", "~> 4.0.0"
# This is the default theme for new Jekyll sites. You may change this to anything you like.
gem "minima", "~> 2.5"
# If you want to use GitHub Pages, remove the "gem "jekyll"" above and
# uncomment the line below. To upgrade, run `bundle update github-pages`.
# gem "github-pages", group: :jekyll_plugins
# If you have any plugins, put them here!
group :jekyll_plugins do
  gem "jekyll-feed", "~> 0.12"
end

# Windows and JRuby does not include zoneinfo files, so bundle the tzinfo-data gem
# and associated library.
install_if -> { RUBY_PLATFORM =~ %r!mingw|mswin|java! } do
  gem "tzinfo", "~> 1.2"
  gem "tzinfo-data"
end

# Performance-booster for watching directories on Windows
gem "wdm", "~> 0.1.1", :install_if => Gem.win_platform?
```

설치한 Jekyll 버전에 따라 `gem "github-pages", group: :jekyll_plugins`와 같이 `github-pages` gem이 설정되어 있기도 하고, 설정되어 있지 않은 경우가 있는데,
`Gemfile`에서 `#` 기호로 시작하는 줄들 중 `# gem "github-pages", group: :jekyll_plugins` 부분의 `#` 기호를 지워줍니다. `Gemfile`은 루비 스크립트이며 `#`은 루비에서 한 줄 주석을 의미합니다.
위의 `github-pages`의 주석을 제거했다면 `gem "jekyll", "~> 4.0.0"` 이 있는 줄을 찾아 제일 앞에 `#`을 추가하여 주석 처리를 해 줍니다.

`github-pages` gem 자체가 `jekyll`에 의존성을 갖고 있어 RubyGems를 통해 `jekyll`이 자동으로 설치되므로 `jekyll` gem 설정이 없어도 Jekyll은 정상적으로 동작합니다.
만약 `githup-pages`와 `jekyll` gem이 `Gemfile`에 함께 정의 되어있는 경우 gem 간의 버전 충돌이 발생할 수 있습니다.

`Gemfile`의 내용을 수정했다면, 로컬에서 테스트를 정상적으로 하기 위해 `gem update` 명령을 수행해 주면 `github-pages`가 적용된 jekyll을 사용할 수 있습니다.
이 후 GitHub의 remote repository로 포스트를 작성한 후 push 하면 GitHub Pages에 작성한 포스트를 확인할 수 있습니다.

### 참고
GitHub에서도 Jekyll을 빌드할 때 조금의 시간이 소요되므로 푸시를 한 즉시 반영되지는 않고 조금의 지연이 발생할 수 있으니 참고해주세요.
만약 빌드하는 과정에서 오류가 발생하는 경우 GitHub 계정에 설정된 이메일로 관련 내용이 발송되니 해당 메일로 어떤 부분에서 오류가 발생했는지 확인할 수 있습니다. 
(주로 직접 테마나 레이아웃을 만드시는 경우에 참고할 부분이 될 것 같습니다.)

# References
- http://ruby-korea.github.io/rubygems-guides/what-is-a-gem
- https://jekyllrb.com/docs/installation/macos
- https://jekyllrb.com/docs/configuration/front-matter-defaults/
- https://ko.wikipedia.org/wiki/YAML