---
title: Java Annotation in Action 2
date: 2020-05-01 20:43:29
tags: Java Annotation APT PAPA Reflection
categories: dev java
series: java_annotation_in_action
number: 2
---

애너테이션은 직접 정의하여 활용할 수 있습니다. 이러한 애너테이션을 사용자 정의(User Defined) 또는 커스텀(Custom) 애너테이션이라고 합니다. 애너테이션도 인터페이스, 클래스와 같은 하나의 타입이며, 인터페이스의 특성을 갖습니다. 이번 글에서는 애너테이션을 작성하기 위한 문법과 애너테이션의 특성을 부여하기 위한 자바 내장 애너테이션에 대해 다뤄보겠습니다.

# 1. 애너테이션 타입 문법
애너테이션은 `@interface` 키워드를 사용하여 정의합니다. 애너테이션 정의 내에 어떠한 요소도 포함하지 않는 가장 단순한 모습의 애너테이션은 아래와 같습니다.

```java
public @interface FirstAnnotation {
}
```

그리고 작성한 FirstAnnotation은 아래와 같이 태그할 수 있습니다.

```java
@FirstAnnotation
public class FirstAnnotationTest {
	@FirstAnnotation
	private String value;
    
    @FirstAnnotation
    FirstAnnotationTest() {
    
    }
    
    @FirstAnnotation
    public static void main(@FirstAnnotation String[] args) {
    	@FirstAnnotation
        String greeting = "Hello, Annotation!";
    }
}
```

`@FirstAnnotation` 애너테이션은 위 코드에서와 같이 클래스, 멤버 변수, 메서드, 생성자, 파라미터, 로컬 변수와 패키지 정보 파일인 package-info.java 파일의 패키지 선언에도 태그할 수 있습니다.

```java
// package-info.java 파일
@FirstAnnotation
package com.nnoco.annotation;
```

# 2. 애너테이션 타입의 요소(Element) 추가
애너테이션 타입의 본문에는 메서드 선언을 포함할 수 있으며, 이러한 메서드 선언을 애너테이션의 요소라고 합니다. 애너테이션의 요소는 제한된 반환 타입을 가지며, 일반 파라미터, 타입 파라미터, throws 절을 포함할 수 없습니다. 의사 코드로 표현한 문법은 아래와 같습니다.

```
[modifier] @interface <type_identifier> {
    [public abstract] <type> <element_identifier>() [default <elementValue>]; 
}
```

대괄호로 감싼 부분은 생략 가능하고, 꺽쇠 괄호로 감싼 부분은 필수로 입력해야 하는 부분입니다.
- modifier: 인터페이스의 지시자와 동일합니다.
- type_identifier: 애너테이션 타입의 이름입니다.
- 요소의 지시자는 생략 가능하며, public, abstract, public abstract만 가능합니다.
- type: 요소의 반환 타입입니다.
- element_identifier: 애너테이션 타입 요소의 이름입니다.
- default: 요소의 기본 값을 설정할 수 있으며 default 값의 형식으로 사용합니다.

이 중 요소가 반환하는 타입은 자바의 원시(Primitive) 타입, `String`, `Class`, `Enum`, `Annotation` 타입 및 그들의 1차원 배열만 가능하고 자기 자신을 반환 타입으로 갖거나 애너테이션 간 타입 참조 사이클을 가질 수 없습니다.

```java
// 애너테이션 타입 자신을 요소의 반환 타입으로 사용하는 경우 - 컴파일 오류
@interface Foo {
    Foo value();
}

// 타입 참조 사이클(상호 참조)이 발생하는 경우 - 컴파일 오류
@interface Foo {
    Bar value();
}

@interface Bar {
    Foo value();
}
```

애너테이션 타입의 요소의 개수에 따라 아래와 같이 명칭을 구분합니다.
- 마커 애너테이션(Marker Annotation): 요소가 없는 경우
- 단일 요소 애너테이션(Single-Element Annotation): 요소가 하나만 정의된 경우
- 일반 애너테이션: 2개 이상의 요소가 정의된 경우 

위의 내용을 참고하여 `javax.validation` 패키지의 `@Max` 애너테이션처럼 최대 값을 제한하는 `@IntMax` 애너테이션을 정의해 보겠습니다.

```java
// Log.java
public @interface Log {
    // 로그 레벨(0: Debug, 1: Info, 2: Warn, 3: Error
    int level() default 1;
    
    // 로그 앞에 붙일 접두어
    String prefix() default "";
    
    // 반환 값도 로그로 출력할지 여부
    boolean logReturn();
}
```
`@Log` 애너테이션 타입에는 로그 레벨을 설정하기 위한 `level`, 로그 출력 시 메시지 앞에 붙일 접두어 `prefix`, 반환 값을 출력하기 위한 `logReturn` 요소가 선언되어 있으며, `level`과 `prefix`에는 기본 값이 있어 생략할 수 있습니다. `@Log` 애너테이션은 아래와 같이 사용합니다.

```java
// LogTest.java
public class LogTest {

    // level, prefix는 기본 값이 있으므로 생략 가능
    // logReturn은 기본 값이 없으므로 생략 불가
    @Log(level = 0, logReturn = false)
    public void hello() {
        System.out.println("안녕하세요.");
    }
}
```
애너테이션은 `@애너테이션(요소 = 값)`의 형태로 사용할 수 있으며, 요소가 기본 값을 가지고 있는 경우에는 생략할 수 있습니다.

이번에는 javax.validation 패키지의 @Max와 같이 값의 최대 크기를 제한하는 @IntMax 애너테이션을 정의해 보겠습니다.

```java
// IntMax.java
public @interface IntMax {
    int value() default Integer.MAX_VALUE;
}
```
`value`라는 이름의 하나의 요소를 가지고 있는 `@IntMax` 애너테이션입니다. 요소 이름 중 특별히 `value`의 경우에는 애너테이션을 사용할 때 요소 이름을 생략할 수 있습니다.

```java
// Point.java
public class Point {
    // 생략하지 않고 표기
    @IntMax(value = 10)
    private int x;
    
    // "value =" 부분을 생략할 수 있습니다.
    @IntMax(20)
    private int y;
}
```
하지만 애너테이션을 사용할 때 여러 개의 요소 값을 설정하는 경우에는 `value`를 생략할 수 없습니다.

요소의 반환 타입이 배열인 경우는 요소에 값을 전달할 때 배열 리터럴을 사용하여 값을 전달할 수 있으며 예시는 아래와 같습니다.

```java
// AllowedValue.java
public @interface AllowedValue {
    String[] value();
}

// AllowedValue 사용
public class Radio {

    @AllowedValue({ "AM", "FM" })
    // 또는
    // @AllowedValue(value = { "AM", "FM" })
    private String frequencyType;
}
```

요소의 반환 타입이 애너테이션인 경우는 아래와 같습니다.

```java
// Book.java
public @interface Book {
    Author author();
}

// Author.java
public @interface Author {
    String value();
}

// AnnotationInAction.java
@Book(author = @Author("nnoco"))
public class AnnotationInAction {
    // ...
}
```
애너테이션 타입의 요소에 값을 전달할 때는 애너테이션 표현식 그대로 `@애너테이션(요소=값)` 형태로 전달합니다.

# 3. 애너테이션 타입에 중첩 타입 정의
애너테이션 타입의 본문에는 해당 애너테이션 타입의 요소 외에도 중첩 타입(클래스, 인터페이스, 애너테이션, Enum 클래스)을 정의할 수 있습니다. 앞에서 다뤘던 `@Log` 애너테이션의 `level` 요소는 반환 타입이 `int`이고, `level` 요소의 값을 제한할 수 있는 방법이 없습니다. 이런 경우 `level` 요소의 반환 타입은 `int` 보다 `enum`을 사용하는 것이 적절해 보입니다.

별도의 파일에 `level`을 표현하기 위한 `enum`을 정의해도 되지만 해당 `enum`은 `@Log` 내에서만 사용되므로 `@Log` 애너테이션 내에 `Level` enum을 정의해 보겠습니다.

```java
// Log.java
public @interface Log {
    // 로그 레벨 - 기존 int 타입에서 Level 타입으로 변경
    Level level() default Level.Info;
    
    // 로그 앞에 붙일 접두어
    String prefix() default "";
    
    // 반환 값도 로그로 출력할지 여부
    boolean logReturn();
    
    /* public 생략 */ enum Level {
        DEBUG, INFO, WARN, ERROR
    }
}
```

```java
// LogTest.java
public class LogTest {

    @Log(level = Log.Level.DEBUG, logReturn = true)
    String getMessage() {
        return "Hello, Annotation!";
    }
}
```
애너테이션 타입인 `Log` 내에 중첩된 `Level`을 참고할 때는 `@Log.Level`이 아닌 `Log.Level`의 형식입니다. 애너테이션으로써 `Log`를 참조하는 것이 아니라 타입으로써 `Log`를 참조하기 때문입니다.

enum 클래스 외에도 일반 클래스, 인터페이스, 애너테이션 역시 애너테이션 본문 내에 중첩해서 정의할 수 있으므로 상황에 맞게 정의하여 사용할 수 있습니다.

# 4. 메타 애너테이션(Meta Annotation)
애너테이션 타입의 속성을 설명하기 위한 애너테이션으로 메타 애너테이션이 있습니다. 이러한 메타 애너테이션으로 `@Target`, `@Retention`, `@Inherited`, `@Documented` 그리고 `@Repeatable`이 있습니다.

## `@Target` 애너테이션
앞서 작성했던 애너테이션들은 소스 코드의 대부분에 태그하여 사용할 수 있었습니다. `@Target` 애너테이션은 `@Target` 애너테이션이 태그된 애너테이션을 어디에 태그할 것인지 제한할 수 있습니다.

```java
// java.lang.annotation.Target
public @interface Target {
    ElementType[] value();
}​
```
`@Target` 애너테이션은 `ElementType` enum 배열 타입의 `value` 요소가 있습니다. `ElementType`에는 아래와 같은 값이 정의되어 있습니다.
- `TYPE`: 타입(클래스, 인터페이스, 애너테이션, 열거형)
- `FIELD`: 필드(멤버 변수) 선언, 열거형 선언도 포함됩니다.
- `METHOD`: 메서드
- `PARAMETER`: 메서드의 파라미터
- `CONSTRUCTOR`: 생성자
- `LOCAL_VARIABLE`: 지역 변수
- `PACKAGE`: package-info.java 파일의 패키지 선언
- `TYPE_PARAMETER`: 타입 파라미터(Java 8 이상)
- `TYPE_USE`: 타입 파라미터를 포함한 타입 식별자(Java 8 이상)
- `MODULE`: 모듈(Java 9 이상)

예를 들어 생성자와 메서드에만 태그할 수 있는 애너테이션은 아래 코드와 같습니다.

```java
import java.lang.annotation.ElementType;
import java.lang.annotation.Target;

@Target({ElementType.CONSTRUCTOR, ElementType.METHOD})
public @interface OnlyConstructorAndMethod {
}
```

## `@Retention` 애너테이션
애너테이션의 관점에서 애너테이션의 정보가 유지되는 단계를 나눠보면 소스 코드, `.class` 파일(컴파일 타입), 런타임으로 나눠 볼 수 있습니다. `@Retention` 애너테이션은 `RetentionPolicy` 열거형을 `value` 요소로 전달 받아 태그한 애너테이션의 정보를 어느 단계까지 유지할 지 설정할 수 있습니다.

RetentionPolicy 열거형에 정의된 상수는 아래와 같습니다.
- `SOURCE`: 소스 코드에서만 존재하며 컴파일 타임 및 런타임에는 애너테이션 정보가 유지되지 않습니다.
- `CLASS`: 소스 코드를 컴파일한 `.class` 파일까지만 유지됩니다. 런타임에는 애너테이션 정보가 유지되지 않습니다. 컴파일 타임에 애너테이션을 처리하는 경우 CLASS 상수를 사용합니다. `@Retention` 애너테이션을 태그하지 않는 경우 기본 값입니다.
- `RUNTIME`: 프로그램이 실행 중인 런타임에도 애너테이션 정보가 유지됩니다.

애너테이션의 용도와 처리 시점에 따라 `@Retention`을 적용할 수 있습니다. 예를 들어 소스 코드의 최초 작성자를 `@Author` 애너테이션을 정의해 기록하기로 했다면, `@Author` 애너테이션은 프로그램의 기능상으로 사용하지 않으므로 소스 코드에만 존재하면 됩니다. 이런 경우 `@Author` 애너테이션에 `@Retention(RetentionPolicy.SOURCE)`을 태그하여 컴파일 타임이나 런타임에 불필요한 메모리를 차지하지 않도록 할 수 있습니다.

```java
// Author.java

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@Retention(RetentionPolicy.SOURCE)
public @interface Author {
    // 최초 작성자 이름
    String value();
}
// SourceExample.java
@Author("nnoco")
public class SourceExample {
}
```

만약 런타임에 애너테이션을 처리한다면 `@Retention(RetentionPolicy.RUNTIME)`을 태그하여 런타임에도 애너테이션이 유지되도록 하여 처리할 수 있습니다. 런타임에 처리되어야 할 애너테이션의 Retention이 `RetentionPolicy.RUNTIME`으로 태그되어 있지 않다면 당연하게도 애너테이션 정보를 읽을 수 없습니다.

## `@Inherited` 애너테이션
애너테이션 정보는 기본적으로 하위 클래스로 상속되지 않습니다. `@Inherited` 애너테이션은 애너테이션이 하위 클래스로 상속되도록 합니다. 애너테이션을 처리하는 과정에서 하위 클래스에서 애너테이션을 태그하지 않았다면, 해당 요소의 상위 클래스에서 애너테이션 정보를 찾습니다. 계층 구조를 가지고 있다면 가장 상위의 클래스에 도달할 때까지 반복됩니다.

```java
// InheritedAnnotation.java

import java.lang.annotation.Inherited;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@Retention(RetentionPolicy.RUNTIME)
@Inherited
public @interface InheritedAnnotation {
}
```
`@Inherited` 애너테이션을 태그하여 하위 클래스에서도 애너테이션의 정보를 얻을 수 있도록 했고, 런타임에 처리하기 위해 `@Retention(RetentionPolicy.RUNTIME)`을 태그해 주었습니다.

```java
// SuperClass.java
@InheritedAnnotation
public class SuperClass {
}
```

```java
// SubClass.java
public class SubClass extends SuperClass {
    public void printInheritedAnnotation() {
        InheritedAnnotation annotation = getClass().getAnnotation(InheritedAnnotation.class);
        System.out.println(annotation);
    }
}
```
`@InheritedAnnotation` 애너테이션을 `SuperClass`에 태그해주면 `SuperClass`를 상속한 `SubClass`도 `@InheritedAnnotation` 정보를 갖고 있습니다. `SubClass`의 인스턴스를 생성하여 `printInheritedAnnotation()` 메서드를 호출하면 "@com.nnoco.aia.ch2.InheritedAnnotation()"이 출력됩니다. (패키지 위치에 따라 달라질 수 있습니다.)

만약 `@Inherited` 애너테이션이 없다면, 하위 클래스에서도 동일한 애너테이션을 태그해 주어야 합니다.

## `@Documented` 애너테이션
`@Documented` 애너테이션을 태그하면 태그된 요소의 정보(public contract)에 태그된 애너테이션 정보가 포함됩니다. `@Documented`가 태그된 애너테이션을 태그하는 요소는 Javadoc이나 IDE에서 확인할 수 있게 됩니다.

`@InheritedAnnotation`에 `@Documented` 애너테이션을 태그하고 이를 확인해 보겠습니다.

```java
// InheritedAnnotation.java
import java.lang.annotation.Documented;
import java.lang.annotation.Inherited;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@Retention(RetentionPolicy.RUNTIME)
@Inherited
@Documented
public @interface InheritedAnnotation {
}
```

IntelliJ IDEA 기준 `SuperClass`에 커서를 두고 {% include kbd.html key='F1' %} 키를 누르면 Javadoc 주석을 확인할 수 있는데, 여기에 `@InheritedAnnotation`이 표시됩니다.

{% include image.html
    url="/assets/images/2020/05-01_annotation/inherited1.png"
    description="@Documented가 태그된 @InheritedAnnotation이 Javadoc에 표시" %}
@InheritedAnnotation의 @Documented 부분을 주석처리하면 아래와 같이 @InheritedAnnotation이 표시되지 않습니다.

{% include image.html
    url="/assets/images/2020/05-01_annotation/inherited2.png"
    description="@Documented가 태그되지 않은 경우 미표시" %}
@InheritedAnnotation의 @Inherited와 상관없이 하위 클래스에서의 Javadoc에서는 표시되지 않습니다.

{% include image.html
    url="/assets/images/2020/05-01_annotation/inherited3.png"
    description="SubClass에는 @InheritedAnnotation 미표시" %}


# `@Repeatable` 애너테이션
Java 8 이전에는 같은 애너테이션을 같은 요소에 여러 개 태그할 수 없었습니다. 아래 예시를 살펴보겠습니다.

먼저 멤버 변수의 별칭을 애너테이션으로 정의하기 위해 `@Alias` 애너테이션을 정의합니다.

```java
// Alias.java
@Retention(RetentionPolicy.RUNTIME)
public @interface Alias {
    String value();
}
```
그리고 아래 Person 클래스에서 name 멤버 변수에 두 개의 별칭을 지정하기 위해 `@Alias` 애너테이션을 태그합니다.

```java
// Person.java
public class Person {
    @Alias("이름")
    @Alias("성함")
    private String name;
}
```
Person 클래스를 컴파일 하면 컴파일 오류가 발생합니다.

```
Person.java:6: error: Alias is not a repeatable annotation type
    @Alias("성함")
    ^
1 error
```

이를 해결하기 위해 여러 개의 `@Alias` 애너테이션을 담을 `@Aliases` 애너테이션을 정의해 줍니다. `@Aliases` 애너테이션과 같이 다른 애너테이션의 배열을 담은 애너테이션을 컨테이너(Container) 애너테이션이라고 합니다.

```java
// Aliases.java
@Retention(RetentionPolicy.RUNTIME)
public @interface Aliases {
    Alias[] value();
}
```
Person에 태그한 `@Alias` 애너테이션은 `@Aliases` 애너테이션으로 감싸서 아래와 같이 바꿔줄 수 있습니다.

```java
// Person.java
public class Person {
    @Aliases({
        @Alias("이름"),
        @Alias("성함")
    })
    private String name;
}
```

Java 8에서는 `@Repeatable` 메타 애너테이션이 추가되어 애너테이션을 태그할 때는 `@Aliases`로 감싸지 않고 여러 개의 `@Alias`를 태그할 수 있습니다. `@Alias` 애너테이션에 `@Repeatable` 애너테이션을 추가해 보겠습니다.

```java
// Alias.java
@Retention(RetentionPolicy.RUNTIME)
@Repeatable(Aliases.class)
public @interface Alias {
    String value();
}
```
`@Repeatable`은 `value` 요소로 컨테이너 애너테이션의 클래스를 받습니다. `@Repeatable` 애너테이션이 추가되었지만 컨테이너 클래스는 필요합니다. 이 때 컨테이너 클래스에는 `@Repeatable` 애너테이션이 태그된 애너테이션 배열 타입의 `value` 이름을 갖는 요소가 정의되어 있어야 합니다. 이름이 `value`가 아니거나, 타입이 일치하지 않는 경우 컴파일 오류가 발생합니다.

앞서 작성한 `@Aliases` 컨테이너 애너테이션은 이미 `Alias[]` 타입의 `value` 요소가 정의되어 있으므로 그대로 사용할 수 있습니다. `@Alias` 애너테이션에 `@Repeatable(Aliases.class)`를 태그했으므로 `Person.java` 파일은 다시 아래와 같이 작성할 수 있습니다.

```java
// Person.java
public class Person {
    @Alias("이름")
    @Alias("성함")
    private String name;
}
```

여러 개의 동일한 애너테이션을 태그한 경우 리플렉션에서 `getAnnotationsByType(Class<? extends Annotation>)` 메서드에 `@Repeatable`이 태그된 애너테이션 클래스를 전달하여 배열로 가져오거나, `getAnnotation(Class<? extends Annotation>)` 메서드에 컨테이너 애너테이션의 클래스를 전달하여 컨테이너를 가져와 컨테이너에 포함된 애너테이션을 가져올 수 있습니다.

아래는 리플렉션을 통해 런타임에 `Person` 클래스의 멤버 변수에 태그된 `Alias` 애너테이션을 가져오는 예시입니다. 리플렉션을 통한 애너테이션 처리는 다음 글에서 상세히 다루도록 하고, 여기에서는 간략하게 설명하겠습니다.

```java
public class AliasProcessor {
    // 컨테이너 애너테이션으로 가져오기
    public Aliases getByContainer(Class<?> type, String fieldName) throws NoSuchFieldException {
        Field field = type.getDeclaredField(fieldName);
        return field.getAnnotation(Aliases.class);
    }

    // @Repeatable이 적용된 애너테이션으로 가져오기
    public Alias[] getByItem(Class<?> type, String fieldName) throws NoSuchFieldException {
        Field field = type.getDeclaredField(fieldName);
        return field.getAnnotationsByType(Alias.class);
    }

    public Alias getByItem2(Class<?> type, String fieldName) throws NoSuchFieldException {
        Field field = type.getDeclaredField(fieldName);
        return field.getAnnotation(Alias.class);
    }

    public static void main(String[] args) throws NoSuchFieldException {
        AliasProcessor processor = new AliasProcessor();

        Aliases aliases = processor.getByContainer(Person.class, "name");
        for(Alias alias: aliases.value()) {
            System.out.println("Aliases: " + alias.value());
        }

        Alias[] aliasArray = processor.getByItem(Person.class, "name");
        for(Alias alias: aliasArray) {
            System.out.println("AliasArray: " + alias.value());
        }

        // 아래는 null을 반환
        Alias alias = processor.getByItem2(Person.class, "name");
        
        // NullPointerException 발생
        System.out.println(alias.value());
    }
}
```

`Class` 클래스에는 클래스의 모든 정보를 포함하고 있습니다. 클래스의 필드(멤버 변수)를 가져오기 위해서는 `getDeclaredField(String)`메서드에 필드의 이름을 전달하여 `Field` 객체를 가져옵니다. 그리고 해당 필드에 태그된 애너테이션을 가져오기 위해서 `getAnnotation(Class)` 또는 `getAnnotationsByType(Class)` 메서드를 사용합니다.

`getAnnotation(Class)` 메서드는 Java 5에서 추가된 메서드로 `@Repeatable`을 지원하지 않습니다. `getAnnotation(Class)` 메서드를 사용할 때는 컨테이너 클래스를 전달하여 컨테이너 클래스를 반환 받은 후 그 안의 `value` 요소에서 `Alias` 배열을 얻을 수 있습니다.

`getAnnotationsByType(Class)` 메서드는 Java 8에 `@Repeatable`과 함께 추가된 메서드로써 `@Alias` 애너테이션의 클래스를 전달하면 컨테이너 없이 `Alias` 배열을 가져올 수 있습니다.

애너테이션을 정의하고 태그하여 사용하는 것은 프로그램의 기능에 아무런 영향을 주지 않지만 리플렉션이나 애너테이션 처리 API를 활용하면 실제로 애너테이션을 이용해 동작하는 프로그램을 작성할 수 있습니다. 이 후의 글에서는 작성한 애너테이션을 어떻게 처리할 수 있는지에 대해 다뤄보도록 하겠습니다.

---
# References
- https://docs.oracle.com/javase/specs/jls/se8/html
