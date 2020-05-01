---
title: Java Annotation in Action 1
date: 2020-05-01 19:35:44+0900
tags: Java Annotation APT PAPA Reflection
categories: dev java
series: java_annotation_in_action
---

자바 5(J2SE 5) 버전 이상부터 애너테이션(Annotation) 기능을 사용할 수 있습니다. 자바의  애너테이션은 소스코드의 클래스, 메서드, 멤버 변수나 주석에 붙여 메타 데이터를 제공할 수 있습니다. 메타 데이터란 데이터의 데이터를 의미합니다. 조금 말장난 같지만 주 데이터에 필요하거나 설명하기 위한 부가적인 데이터로 볼 수 있습니다. 현실에서의 예를 들어보면 여러 전원 케이블을 구분하기 위해 케이블에 꼬리표를 붙여 냉장고의 전원 케이블인지 텔레비전의 케이블인지, 스탠드 조명의 케이블인지 구분할 수 있습니다. 이 경우 꼬리표가 전원 케이블의 메타 데이터입니다. 또한 도서의 저자, 출판사, ISDN 등의 데이터도 메타 데이터입니다.

# 1. 자바 애너테이션
자바의 애너테이션은 "@애너테이션 이름"의 형태로 소스코드에 태그하여 메타데이터를 표현할 수 있습니다. 간단한 예시로 자바에 내장되어 있는 애너테이션으로 `@Override`를 살펴보겠습니다.

```java
public class Foo {
  @Override
  public String toString() {
    return "bar";
  }
}
```
위 예시에서 `@Override` 애너테이션은 `toString` 메서드에 태그되어 "toString 메서드는 상위 클래스의 toString 메서드를 오버라이드 했다"는 데이터를 추가할 수 있습니다. 자바의 메서드 자체는 오버라이드 여부를 표현할 수 없지만 애너테이션으로 "오버라이드 메서드"라는 데이터를 추가해 줄 수 있습니다. 이렇게 추가된 @Override 애너테이션은 컴파일러에서도 활용할 수 있고, 주석을 굳이 작성하지 않아도 애너테이션만으로 사람도 코드를 읽을 때 오버라이드 메서드인 것을 알 수 있게 됩니다.

애너테이션 자체는 데이터로써만 존재할 뿐 어떠한 기능을 갖는 것은 아닙니다. 자바의 리플렉션(Reflection) API나 PAPA(Pluggable Annotation Processing API)를 활용해서 컴파일 타임이나 런타임에 소스코드에 태그된 애너테이션 정보를 읽어 처리할 수 있게 합니다.


# 2. 자바 내장 애너테이션
자바 표준 API에 정의된 애너테이션으로는 `@Override`, `@Deprecated`, `@SuprpressWarning`, `@SafeVaragrs`, `@FunctionalInterface` 그리고 애너테이션 타입에 태그하는 애너테이션인 메타 애너테이션으로 `@Target`, `@Retention`, `@Inherited`, `@Documented`, `@Repeatable`이 있습니다.

## @Override
`@Override` 애너테이션은 앞서 간단히 설명했듯 @Override 애너테이션을 태그한 메서드가 부모 클래스로부터 상속 받은 메서드를 재정의(Override) 함을 의미합니다.  

## @Deprecated
`@Deprecated` 애너테이션은 생성자, 필드, 지역변수, 메서드, 파라미터, 타입(클래스, 인터페이스 등) 등에 태그할 수 있고, 태그된 요소의 사용을 더 이상 권장하지 않는 경우에 사용합니다. 이를테면 메서드가 더 이상 유지보수 되지 않고, 다음 버전에서 제거되는 경우 상위 버전 호환을 위하여 `@Deprecated` 애너테이션을 태그하여 메서드를 사용하는 개발자에게 알립니다. 이런 경우 대개 Javadoc 주석으로 대체할 방법을 안내합니다. 직접 `@Deprecated`를 사용하는 경우에도 Deprecated의 이유와 대체 방법 등을 Javadoc 주석으로 안내하는 것이 좋습니다.

```java
public class DeprecatedExample {
    /**
     * @deprecated 더 이상 {@link DeprecatedExample#a} 메서드는 유지보수 되지 않습니다.
     * {@link DeprecatedExample#b} 를 사용해 주십시오.
     */
    @Deprecated
    public void a() {
        
    }

    public void b() {
        
    }
}
```
`a()` 메서드에 `@Deprecated` 애너테이션과 함께 Javadoc 주석을 활용하여 설명을 적어주면, Javadoc 문서 생성 시 해당 내용이 출력되고, 대부분의 IDE에서 `a()` 메서드 참조 시 Deprecated 된 것을 표시해 줍니다. 아래는 IntelliJ IDEA의 예시입니다.

{% include image.html
    url="/assets/images/2020/05-01_annotation/intellij_deprecated.png"
    description="IntelliJ IDEA - a() 메서드 호출 시 취소선으로 표시" %}

{% include image.html
    url="/assets/images/2020/05-01_annotation/intellij_javadoc.png"
    description="a() 메서드의 Javadoc" %}
 

Java 9 에는 `@Deprecated` 애너테이션에 `since`, `forRemoval` 요소가 추가되어 보다 `@Deprecated` 애너테이션에 추가적인 정보를 전달할 수 있습니다. `since`는 Deprecated 되는 버전 문자열, `forRemoval`은 Deprecated의 사유가 삭제인지 `true`/`false`로 전달합니다.

```java
// java.lang 패키지의 Runtime 클래스 내 transactionInstructions(boolean) 메서드
/**
 * Not implemented, does nothing.
 *
 * @deprecated
 * This method was intended to control instruction tracing.
 * It has been superseded by JVM-specific tracing mechanisms.
 * This method is subject to removal in a future version of Java SE.
 *
 * @param on ignored
 */
@Deprecated(since="9", forRemoval=true)
public void traceInstructions(boolean on) { }
```

자바 내장 타입인 `Runtime` 클래스의 `traceInstructions(boolean)` 메서드에 태그된 `@Deprecated` 애너테이션입니다. `since` 요소에 `"9"`,  `forRemoval`이 `true`인 것으로 미루어 Java 9 버전부터 Deprecated 되었고, 이 후 삭제될 수 있음을 알 수 있습니다.

## @SuppressWarnings
자바 컴파일러는 정적 분석을 통해 잘못된 코드, 비효율적인 코드, 혹은 오류가 발생할 수 있는 가능성이 있는 코드를 탐지할 수 있고, 컴파일 시 옵션으로 -Xlint를 추가하면 경고 메시지를 출력해 줍니다. IDE는 소스코드 편집기에서 같은 내용을 강조하여 보여주기도 합니다.

아래는 제너릭 리스트를 타입 파라미터 없이 사용하고 있는 코드입니다.
```java
// SuppressWarningsExample.java 

import java.util.List;
import java.util.ArrayList;

public class SuppressWarningsExample {
    public void test() {
    	// 파라미터화된 타입을 사용하지 않고 List 사용
        List list = new ArrayList();
    }
}
```
위의 `Test.java` 파일을 `javac -Xlint SuppressWarningsExample.java` 명령으로 컴파일하면 아래와 같은 메시지가 출력됩니다.

```bash
$ javac -Xlint SuppressWarningsExample.java
SuppressWarningsExample.java:6: warning: [rawtypes] found raw type: List
        List list = new ArrayList();
        ^
  missing type arguments for generic class List
  where E is a type-variable:
    E extends Object declared in interface List
SuppressWarningsExample.java:6: warning: [rawtypes] found raw type: ArrayList
        List list = new ArrayList();
                        ^
  missing type arguments for generic class ArrayList
  where E is a type-variable:
    E extends Object declared in class ArrayList
2 warnings
```
rawtypes는 타입 파라미터가 정의되었을 때 파라미터화된 타입을 전달하지 않았을 때를 일컫습니다. 만약 이러한 코드에서 의도적으로 타입 파라미터를 전달하지 않았다면 경고 메시지는 방해가 될 수 있습니다. 이럴 때 컴파일러의 경고 메시지를 출력하지 않도록 할 때 `@SuppressWarnings` 애너테이션을 사용할 수 있습니다.

```java
import java.util.List;
import java.util.ArrayList;

public class SuppressWarningsExample {
    public void test() {
    	// @SuppressWarnings 애너테이션을 태그하여 컴파일 경고 무시
        @SuppressWarnings("rawtypes")
        List list = new ArrayList();
    }
}
```
위와 같이 경고가 발생하는 코드에 `@SuppressWarnings` 애너테이션을 태그한 후 컴파일하면 경고 메시지가 출력되지 않는 것을 확인할 수 있습니다. 

`@SuppressWarnings` 애너테이션은 어떤 타입의 경고를 무시할 지 value 요소에 단일 값 또는 배열로 전달할 수 있고, 위에서는  컴파일 시 출력된 경고 메시지의 "SuppressWarningsExample.java:6: warning: [rawtypes] found raw type: List" 에서 표시된 rawtypes를 무시하도록 했습니다.

`@SuppressWarnings`에 전달할 수 있는 경고 타입은 아래와 같습니다.
- auxiliaryclass: Warn about an auxiliary class that is hidden in a source file, and is used from other files.
- cast: 불필요한 타입 캐스팅을 하는 경우
- classfile: classfile 컨텐츠에 관련된 이슈가 있는 경우
- deprecation: deprecated 항목을 사용하는 경우
- dep-ann: Javadoc 주석에 deprecated를 표시하고 있지만 @Deprecated 애너테이션을 태그하지 않은 경우
- divzero: 0으로 나누는 경우
- empty: if 구분의 내용이 비어있는 경우
- exports: 모듈 Export에 대한 이슈가 있는 경우
- fallthrough: switch 구문에서 break 하지 않고 다음 case로 넘어가는(Fall through) 경우
- finally: 정상적으로 종료되지 않는 finally 절이 있는 경우
- module: 모듈 시스템과 관련된 이슈가 있는 경우
- opens: 모듈 오픈에 관련된 이슈가 있는 경우
- options: 커맨드 라인 옵션 사용과 관련된 문제가 있는 경우
- overloads: 잘못된 오버로드와 관련된 문제가 있는 경우
- overrides: 잘못된 오버라이드와 관련된 문제가 있는 경우
- path: 커맨드 라인의 잘못된 경로 요소가 있는 경우
- processing: 애너테이션 프로세싱과 관련된 문제가 있는 경우
- rawtypes: 타입 파라미터가 정의되어 있지만 사용하지 않는 경우
- removal: 삭제될 예정인 API를 사용하는 경우
- requires-automatic: requires 절에서 자동 모듈을 사용하는 경우
- requires-transitive-automatic:  requires transitive 에서 자동 모듈을 사용하는 경우
- serial: Serializable 인터페이스를 구현한 클래스에서 Serial Version ID를 정의하지 않거나, public이 아닌 경우
- static: 인터페이스에서 static 멤버를 액세스하는 경우
- try: try 블록 사용과 관련된 문제가 있는 경우
- unchecked: (타입 체크 등의) 체크를 수행하지 않은 연산의 경우 - 예) 타입 체크를 하지 않고 타입 캐스팅
- varargs: 잠재적으로 안전하지 않은 가변 인자를 가진 메서드에 관한 문제가 있는 경우

이러한 경고들은 컴파일은 수행할 수 있지만 런타임에 잠재적으로 문제를 가진 것들입니다. 따라서 경고를 없애기 위해 @SuppressWarnings 애너테이션을 무분별하게 사용하기보다, 경고를 없앨 수 있는 방법을 찾아보고, 해당 코드가 의도적으로 경고가 발생할 수 있도록 작성되었으며, 런타임에도 오류가 발생하지 않는 것이 분명할 때만 사용하는 것이 좋을 것입니다.

## @SafeVarargs
메서드나 생성자에 에 가변인자(Varargs, Vargs, Variable Arguments)를 사용하면 메서드를 유연하게 사용할 수 있지만, 제너릭 가변인자를 사용하는 경우 타입 안전성이 깨질 수 있습니다. 또한 자바 언어 명세(Java Language Specification, JLS) 4.12.2에서는 파라미터화된 타입의 변수가 다른 타입의 객체를 참조하는, 힙 오염(Heap Pollution)이 발생한다고 안내하고 있습니다. (Joshua Bloch - Effective Java 3/E, Item 32에서 제너릭 가변인자의 문제점과 안전한 제너릭 가변인자를 사용하기 위한 내용을 설명하고 있습니다.)

아래 코드는 컴파일하면 unchecked 타입의 경고를 출력합니다.
```java
// SafeVargsExample.java

public class SafeVargsExample {
    static <T> void foo(T... args) {
        // ...
    }
}
```

```bash
SafeVargsExample.java:2: warning: [unchecked] Possible heap pollution from parameterized vararg type T
    static  void foo(T... args) {
                             ^
  where T is a type-variable:
    T extends Object declared in method toArray(T...)
1 warning
```

이 경고는 마찬가지로 런타임에 오류를 발생시킬 수 있기 때문에 출력되지만, 앞서 `@SuppressWarnings`와 마찬가지로 코드에서 오류가 발생하지 않는 것이 분명한 경우 경고를 무시하도록 할 수 있습니다. `@SuppressWarnings("unchecked")` 는 위의 경고를 무시하도록 합니다. 하지만 `@SuppressWarnings("unchecked")`의 경우 태그한 요소의 하위 요소의 동일 타입(unchecked)의 경고를 무시하게 되므로 어떤 이유로 인해 오류를 무시하도록 한 것인지 의도를 파악하기 어렵습니다. 자바 7 버전 이 전에는 `@SuppressWarnings("unchecked")`를 사용했지만 자바 1.7 에는 한정적으로 제너릭 가변인자에 대한 경고를 무시하도록 하는 `@SafeVarargs` 애너테이션이 추가되었습니다. 

```java
// SafeVarargsExample

public class SafeVarargsExample {

    // foo 메서드에 @SafeVarargs 추가
    @SafeVarargs
    static <T> void foo(T... args) {
        // ...
    }
}
```
foo 메서드에 @SafeVarargs를 태그하면 컴파일 시 경고가 발생하지 않습니다.

## @FunctionalInterface
Java 8에서는 함수형 프로그래밍을 위한 많은 문법과 API가 추가되었습니다. 함수형 인터페이스(Functional Interface)는 하나의 추상 메서드만을 가지는 인터페이스를 의미하며, `@FunctionalInterface` 애너테이션을 인터페이스에 태그하면 해당 인터페이스가 하나의 추상 메서드만 가지도록 강제합니다. `@FunctionalInterface` 애너테이션을 태그한 인터페이스가 2개 이상의 추상 메서드를 가진다면 컴파일 오류가 발생합니다.

```java
// FunctionalInterfaceExample.java
@FunctionalInterface
public interface FunctionalInterfaceExample {
    public void run();

    public void execute();
}
```

컴파일 결과
```bash
FunctionalInterfaceExample.java:2: error: Unexpected @FunctionalInterface annotation
@FunctionalInterface
^
  FunctionalInterfaceExample is not a functional interface
    multiple non-overriding abstract methods found in interface FunctionalInterfaceExample
1 error
```

`@FunctionalInterface` 애너테이션을 태그하지 않았다면, 다른 개발자가 원래 개발자가 작성한 코드의 의도를 파악하지 못하고 실수로 메서드를 추가할 수도 있습니다. `@FunctionalInterface`는 이러한 일이 발생하는 것을 방지해주는 역할을 합니다.


# 3. 애너테이션 활용의 예시
애너테이션을 활용하면 반복되는 보일러 플레이트 코드의 작성을 줄일 수도 있고, 메서드가 호출될 때 부가적인 기능을 수행하게끔 만들 수도 있습니다. 많은 라이브러리나 프레임워크에서는 애너테이션을 활용하고 있습니다.

## Lombok
Lombok은 클래스의 Getter, Setter, 생성자 등의 코드를 컴파일 타임에 자동으로 생성해 주는 라이브러리입니다.
```java
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@NoArgsConstructor
@AllArgsConstructor
public class Book {
    private String title;
    
    @Setter
    private int price;
}
```
`@Getter`나 `@Setter` 메서드는 멤버 변수의 Setter와 Getter를 생성해주고, 클래스 레벨에서 태그하거나, 개별 멤버 변수에 태그할 수 있습니다. 위의 코드에서는 클래스 레벨에서 `@Getter`를, price 멤버 변수에 `@Setter`를 태그해서 title, price 멤버 변수의 Getter와 price 멤버 변수의 Setter를 자동으로 생성합니다.

`@NoArgsConstructor`와 `@AllArgsConstructor`는 생성자를 생성하도록 하는 애너테이션이며 이름대로 `@NoArgsConstructor`는 인자가 없는 생성자, `@AllArgsConstructor`는 모든 멤버 변수를 초기화하기 위한 인자를 받아 초기화하는 생성자를 생성합니다. 위 Lombok 애너테이션을 적용해서 생성된 결과는 아래와 같습니다.

```java
public class Book {
    private String title;
    private int price;

    public Book() {
    }
    
    public Book(String title, int price) {
      this.title = title;
      this.price = price;
    }
    
    public String getTitle() {
      return this.title;
    }
    
    public int getPrice() {
      return this.price;
    }
    
    public void setPrice(int price) {
      this.price = price;
    }
}
```
 
## Spring Framework
Spring Framework는 XML을 통해 할 수 있었던 애플리케이션 설정, 빈 생성 등의 작업을 애너테이션을 이용해 자바 코드에서도 할 수 있도록 지원합니다. 또한 Spring Web에서는 컨트롤러 클래스의 핸들러 메서드 매핑을 애너테이션으로 선언적으로 설정할 수 있습니다.

```java
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/books")
public class BookApiController {
    @GetMapping
    public List<Book> getBooks() {
        // ...
    }
    
    @GetMapping("/{id}")
    public Book getBook(@PathVariable Long id) {
        // ...
    }
}
```
`BookApiController` 클래스를 `@RestController` 애너테이션으로 스프링의 컨트롤러 빈으로 등록하고, `@XxxMapping` 애너테이션들을 이용해 어떤 요청 경로에 매핑할 것인지 설정합니다. 클래스에 태그된 애너테이션들을 읽어 애플리케이션으로 들어오는 요청을 자동으로 처리할 수 있게 됩니다.


## Bean Validation
Java EE(Enterprise Edition) 6 이상에서 빈의 유효성 검증을 위한 클래스들이 `javax.validation` 패키지에 정의되어 있으며, 폼(Form) 요청 등의 데이터를 검증하기 위해 애너테이션을 활용할 수 있습니다.

```java
import javax.validation.constraints.Min;
import javax.validation.constraints.NotEmpty;
import javax.validation.constraints.Size;

public class Book {
    @Size(max = 100, message = "title은 100자를 초과할 수 없습니다.")
    @NotEmpty(message = "title은 필수 입력 항목입니다.")
    private String title;

    @Min(value = 0, message = "가격은 음수일 수 없습니다.")
    private int price;
}
```
길이 제한, Null 가능 여부, Empty 가능 여부, 최대/최소값, 정규표현식을 통한 패턴 체크 등의 유효성 설정을 애너테이션으로 태그하고, 유효성 검사기(Validator)로 객체에 담긴 값이 유효한지 확인할 수 있습니다.


## Feign
Feign은 애너테이션 기반의 HTTP Client 라이브러리입니다. 

```java
import feign.Param;
import feign.RequestLine;
import java.util.List;

public interface BookApiClient {
    @RequestLine("GET /api/books")
    List<Book> getBooks();

    @RequestLine("Get /api/books/{id}")
    Book getBook(@Param("id") Long id);
}
```
HTTP 요청을 위한 정보를 담고 있는 `BookApiClient` 인터페이스를 작성합니다. HTTP 요청을 "어떻게" 해야하는지는 명시할 필요가 없고 "무엇을" 요청해야하는지만 애너테이션으로 정의해 주면됩니다.

```java
import feign.Feign;
import java.util.List;

public class BookApiClientTest {
    public static void main(String[] args) {
        BookApiClient client = Feign.builder()
                .target(BookApiClient.class, "http://some.where...");

        List<Book> books = client.getBooks();
        Book book = client.getBook(1L);
    }
}
```
그리고 Feign 클래스를 통해 `BookApiClient`가 실제로 동작할 수 있도록 객체를 생성해서 별다른 HTTP 통신 관련 코드를 작성하지 않아도 인터페이스에서 정의한 메서드를 사용해서 API를 호출할 수 있습니다.

위의 예시에서 살펴본 것과 같이 애너테이션은 선언적 프로그래밍을 가능하게 해주고 반복적인 많은 코드를 작성하는 수고를 덜 수 있게 도와줄 수 있습니다. 물론 런타임에 애너테이션을 읽어 처리할 때는 그만큼 실행 속도가 느려지는 등의 단점은 있습니다.

이 후의 글에서는 직접 애너테이션을 작성하고 처리하는 방법, 속도 이슈를 해결하기 위한 방법을 다뤄보도록 하겠습니다.