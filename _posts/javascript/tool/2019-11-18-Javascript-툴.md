---
title: Javascript 툴
tags:
  - null
categories: [javascript, tool]
date: 2019-11-18 21:56:04
---
# Package Manager(Dependency Manager)
패키지 매니저는 자바스크립트 개발 시 필요한 모듈(라이브러리/프레임워크 등)을 저장소(Repository)에서 관리하고, 이를 이름과 버전으로 다운로드하여 사용할 수 있는 도구입니다. 예를 들어 jquery가 필요하다면, jquery.com이 아니라 패키지 매니저를 통해 다운로드할 수 있습니다.
또한 아래에 설명하는 번들러, 트랜스파일러 등을 패키지 매니저를 통해 설치하여 사용할 수도 있습니다.
- npm(Node Package Manager)
- bower
- yarn

# Module Bundler
번들러는 모듈로 나뉘어진 코드를 하나 또는 여러개의 파일로 묶어주는(Bundling) 도구이며, CommonJS나 ES6 모듈로 작성된 코드는 브라우저에서 바로 실행할 수 없으므로,
이를 브라우저에서 사용할 수 있도록 변환하여 번들링하는 역할을 합니다.
- webpack
- RequireJS
- Browserify
- Rollup
- Parcel

# Javascript Transpiler
Compiler는 소스코드로부터 실행 가능한 바이너리로 변환하는 역할을 합니다. 이와 유사하지만 트랜스파일러는 소스코드로부터 다른 형태의 소스코드로 변환하는 일을 합니다.
babel이라는 트랜스파일러를 사용하면 ES6 버전의 문법으로 작성한 자바스크립트 파일을 브라우저 호환성을 위해 ES5 버전의 문법으로 변환할 수 있습니다.
- babel
- typescript
- coffeescript

# Task Runner
태스크 러너는 애플리케이션 개발, 실행, 테스트 등 반복되는 작업(Task)을 스크립트로 작성하여 자동화할 수 있는 도구입니다.
- grunt
- gulp
- webpack: 웹팩은 훌륭한 모듈 번들러이면서 태스크러너의 역할을 할 수도 있습니다.

# 자바스크립트 모듈
모듈이란 자바스크립트로 작성된 함수의 덩어리로 생각할 수 있습니다. 웹 브라우저 기반 자바스크립트에서는 모듈 개념이 없지만 모듈 라이브러리를 이용해 모듈 개념을 사용할 수 있습니다. ES6에 모듈 개념과 문법이 추가되었지만, 모든 브라우저가 ES6 모듈을 지원하지 않으며 사용방법이 다소 상이합니다.
- 네임스페이스 개념 이해하기
- CommonJS
- AMD
- UMD

### 참고 자료
- [패키지 매니저, 자동화 도구](https://codeflow.study/courses/88)
- [믿을만한 자바스크립트 테스트 도구 10가지](http://www.itworld.co.kr/news/128974)
- [참고 - Toast UI](https://ui.toast.com/fe-guide/ko_BUNDLER/)