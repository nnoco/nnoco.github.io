# nnoco 기술 블로그
Jekyll 기반으로 작성한 블로그입니다.

## Series
`_data/series` 하위에 시리즈를 정의하는 YAML 파일을 작성하여 포스트에 시리즈를 적용할 수 있도록 함

YAML 파일 포맷
```yaml
name: 시리즈 제목
posts:
  - title: 시리즈 포스트 타이틀
    path: 포스트의 상대 경로
    published: (Optional) false인 경우 작성 예정으로 표시
```

포스트 파일의 Front Matter에 series 속성을 확장자를 제외한 YAML 파일의 이름을 설정
```yaml
---
# ...생략
series: series_file_name
---
```

## includes
- `image.html`: `img`를 캡션과 함께 표시하기 위한 파일
    ```liquid
    {% includes image.html url="..." description="..." %}
    ```
- `kbd.html`: `kbd`태그를 사용하기 위한 파일
    ```liquid
    {% includes kbd.html key="F1" %}
    ```