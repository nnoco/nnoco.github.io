---
title: Java Annotation in Action 3
date: 2020-05-06 20:11:31+0900
tags: Java Annotation APT PAPA Reflection
categories: dev java
series: java_annotation_in_action
---

Java Annotation in Action 1편과 2편에서는 애너테이션의 개념과 정의 방법을 알아보았습니다. 이번 편에서는 소스 코드에 태그된 애너테이션을 자바 리플렉션을 통해 숨을 불어 넣어줄 차례입니다. 애너테이션을 읽어 필요한 로직을 작성하는 것을 애너테이션 프로세싱(Annotation Processing)이라고 하며, 컴파일 타임과 런타임에 애너테이션 프로세싱을 할 수 있으며, 런타임에는 자바의 리플렉션을 이용해 애너테이션을 처리할 수 있습니다.

# 1. 리플렉션(Reflection)
[위키피디아](https://ko.wikipedia.org/wiki/%EB%B0%98%EC%98%81_(%EC%BB%B4%ED%93%A8%ED%84%B0_%EA%B3%BC%ED%95%99))에서 리플렉션은 다음과 같이 정의하고 있습니다.
> 컴퓨터 프로그램에서 런타임 시점에 사용되는 자신의 구조와 행위를 관리(type introspection)하고 수정할 수 있는 프로세스를 의미한다.

자바의 리플렉션은 클래스의 상속/구현 관계, 클래스를 구성하고 있는 생성자, 멤버 변수, 멤버 메서드 등과 클래스, 멤버 등에 태그된 **애너테이션**을 읽어 올 수 있고, 읽는 것 뿐만 아니라 클래스의 새로운 인스턴스를 생성하거나, 멤버 변수의 값을 바꾸거나, 메서드를 실행하는 등의 기능을 수행할 수 있습니다.

이러한 정보는 `java.lang.Class` 클래스의 인스턴스로 표현되며, 아래의 방법으로 `Class` 인스턴스를 가져올 수 있습니다.
```java
// class 키워드를 사용
Class<?> clazz = String.class;

// 객체의 getClass() 메서드를 호출
Class<?> clazz = "Hello, World!".getClass();

// Class 클래스의 forName() static 메서드를 호출
Class<?> clazz = Class.forName("java.lang.String");
```

상황에 맞는 방법으로 대상 클래스의 정보를 갖고 있는 `Class` 객체를 가져올 수 있고 `Class` 객체가 리플렉션의 시작점이 됩니다. 참고로 위의 코드에서 변수 이름은 `clazz`로 한 이유는 `class`가 자바의 키워드이므로 변수 이름으로 사용할 수 없기 때문입니다.

이 글에서는 리플렉션의 모든 내용을 다루지 않고 애너테이션 처리에 초점을 맞춰 필요한 기능들을 사용하며 설명을 더하도록 하겠습니다.


# 2. 유효성 검증 애너테이션 예제
객체의 유효성 검증을 위한 몇 가지 애너테이션을 만들고 이를 검증하는 애너테이션 처리를 개발해 보겠습니다. `@NotNull` 애너테이션을 정의한 후 클래스의 멤버 변수에 태그하여 해당 멤버 변수가 `null`이 아닌지 체크하도록 합니다.

먼저 `@NotNull` 애너테이션입니다.

```java
// io.github.nnoco.annotation_in_action.ch3.validation.NotNull.java

package io.github.nnoco.annotation_in_action.ch3.validation;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * 멤버 변수가 null이 아님을 체크하는 애너테이션
 */
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.FIELD)
public @interface NotNull {
    String message() default "";
}
```
런타임에도 애너테이션이 유지되도록 `@Retention(RetentionPolicy.RUNTIME)`을 태그하고, 멤버 변수에만 한정적으로 태그할 수 있도록 `@Target(ElementType.FIELD)`를 태그해 주었습니다. `message` 요소를 정의하여 `null`인 경우에 표시할 메시지를 작성할 수 있도록 하고 기본 값을 두어 꼭 전달하지 않아도 사용할 수 있게 하였습니다.

`@NotNull` 애너테이션을 사용하는 `Book` 클래스입니다.
```java
package io.github.nnoco.annotation_in_action.ch3.validation;

/**
 * 책 정보 클래스
 */
public class Book {
    @NotNull(message = "title은 필수 항목입니다.")
    private String title;

    @NotNull(message = "author는 필수 항목입니다.")
    private String author;

    private Integer price;

    public Book(String title, String author, Integer price) {
        this.title = title;
        this.author = author;
        this.price = price;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    // 이하 Getter, Setter 생략
}
```

책 정보를 관리하는 `Book` 클래스는 제목(title), 저자(author), 가격(price)을 가지고 있으며, `title`, `author` 필드를 필수 값으로 지정하였습니다. `@NotNull`애너테이션의 `message`에 적절한 메시지를 입력하여, 어느 필드에서 유효성 검증을 통과하지 못했는지 알 수 있도록 합니다.

이제 `NotNullValidator` 클래스를 작성하고 리플렉션으로 `@NotNull` 애너테이션이 태그된 필드의 `null` 여부를 체크해 봅시다.
```java
// io.github.nnoco.annotation_in_action.ch3.validation.NotNullValidator.java
package io.github.nnoco.annotation_in_action.ch3.validation;

import java.lang.reflect.Field;
import java.util.Objects;

/**
 * {@link NotNull}이 태그된 필드의 null 여부를 체크하는 유효성 검사기
 */
public class NotNullValidator {
    /**
     * 전달된 객체의 NotNull 유효성을 검증합니다.
     * @param object 유효성을 검사할 객체
     * @throws IllegalArgumentException @NotNull을 태그한 필드의 값이 null인 경우
     * @throws NullPointerException {@code object}가 null인 경우
     */
    public void validate(Object object) {
        if(Objects.isNull(object)) {
            throw new NullPointerException("object는 null일 수 없습니다.");
        }

        // 전달된 객체의 Class 객체 가져오기
        Class<?> clazz = object.getClass();

        // 해당 클래스에 정의된 모든 필드 가져오기
        Field[] fields = clazz.getDeclaredFields();

        for(Field field: fields) {
            // 필드에 태그된 NotNull 애너테이션 가져오기(없으면 null)
            NotNull notNull = field.getAnnotation(NotNull.class);

            // @NotNull 애너테이션이 태그되어 있는 경우
            if(Objects.nonNull(notNull)) {
                validateField(object, field, notNull);
            }
        }
    }

    private void validateField(Object object, Field field, NotNull notNull) {
        // 필드의 값 가져오기
        Object value = getFieldValue(object, field);

        if(Objects.isNull(value)) {
            // 필드의 값이 null이라면 예외 발생
            throw new IllegalArgumentException(notNull.message());
        }
    }

    private Object getFieldValue(Object object, Field field) {
        // private 접근 제어 지시자를 무시하도록 accessible을 true로 설정
        boolean accessible = field.isAccessible();
        field.setAccessible(true);

        // 필드의 값 가져오기
        Object value = null;
        try {
            // object 객체의 field 필드의 값 조회
            value = field.get(object);
        } catch(IllegalAccessException e) {
            // 필드에 접근할 수 없는 경우 발생 - accessible을 변경하여 발생하지 않음
            e.printStackTrace();
        }

        // 원래의 accessible로 설정
        field.setAccessible(accessible);

        return value;
    }
}
```

유효성 검증이 필요한 객체에 대해 `NotNullValidator`의 `validate` 메서드를 호출하여 유효성을 검증하고 유효성 검증에 실패한 경우 즉, `@NotNull`이 태그 되어 있는 필드의 값이 `null`인 경우 `IllegalArgumentException`을 발생시킵니다. `NotNullValidator` 클래스를 자세히 살펴보겠습니다.

1\. `Class<?> clazz = object.getClass();`  
`validate` 메서드에 전달된 `object` 객체의 `getClass()` 메서드를 호출하여 `Class` 객체를 가져옵니다. 이 때 object가 null이면 NullPointerException이 발생하므로 앞에서 먼저 object에 대한 null 체크를 먼저 수행해 줍니다.

2\. `Field[] fields = clazz.getDeclaredFields();`  
`Field` 클래스는 필드의 이름, 값 등을 가져올 수 있는 정보를 가지고 있습니다. 이러한 필드를 가져오기 위해 `Class` 클래스에는 `getDeclaredFields()` 메서드가 정의되어 있습니다. 이 메서드는 접근 플래그(private, protected, default)에 상관없이 클래스에 정의된 모든 필드를 배열로 반환합니다. 이 때 상속된 필드는 해당되지 않으므로 상속된 필드를 가져오기 위해서는 부모 클래스의 `Class` 객체를 가져와 `getDeclaredFields()` 메서드를 호출해야 합니다. `getFields()` 메서드는 상속받은 필드를 가져올 수 있지만 `public` 필드에만 해당됩니다. 이 예제에서는 상속받은 필드는 제외하도록 하겠습니다.

3\. `NotNull notNull = field.getAnnotation(NotNull.class);` 
필드에 태그된 `@NotNull` 애너테이션을 가져오는 부분입니다. 보이는 것처럼 리플렉션을 통해 가져온 애너테이션은 객체로 표현되고, 애너테이션에 정의된 요소에 전달한 값은 메서드를 호출하여 얻을 수 있습니다. `getAnnotation()` 메서드는 Java 5에 추가된 메서드로 Java 8에 추가된 `@Repeatable`을 지원하지 않습니다. 이를 위해 Java 8에서는 `getAnnotationsByType()` 메서드가 추가되었습니다. `getAnnotation()` 메서드는 애너테이션이 태그되어 있으면 해당 애너테이션의 객체를 반환하고 없으면 `null`을 반환합니다. `Book` 클래스의 경우 `title`, `author`에 `@NotNull`이 태그되어 있으므로 해당 애너테이션을 가져올 수 있습니다.

4\. `field.setAccessible(true);`  
필드의 accessible은 필드에 접근할 수 있는지 여부를 나타냅니다. `private` 필드의 경우 기본적으로 접근할 수 없습니다. 따라서 `setAccessible(true)`를 호출해 주어 접근 가능하도록 만들고, 뒤에서 필드의 값을 가져올 수 있도록 합니다. 만약 이런 식으로 객체의 캡슐화를 깨고 싶지 않다면 해당 필드의 값을 반환하는 Getter 메서드를 호출하여 값을 가져오도록 할 수도 있습니다.

5\. `value = field.get(object);`
`get()` 메서드를 이용해 특정 객체의 필드에 담긴 값을 가져올 수 있습니다. 이 때 실제 객체를 인자로 넘겨줄 수 있으며, 해당 `field`가 정의된 객체여야 합니다. 만약 `field`와 `object`가 올바르지 않다면 `IllegalArgumentException`이 발생하며, `field`에 접근 할 수 없는 경우에는 `IllegalAccessException`이 발생합니다. 4번의 과정에서 accessible을 `ture`로 설정했으므로 `IllegalAccessException`은 발생하지 않고 정상적으로 값을 가져올 수 있습니다.

끝으로 `validateField` 메서드에서 필드의 값이 `null`인지 체크하고 `null`이라면 `IllegalArgumentException`을 발생시킵니다. 이 때 `IllegalArgumentException`의 인자로 `@NotNull` 애너테이션의 인스턴스인 `notNull`의 `message()`를 호출하여 애너테이션을 태그할 때 `message` 요소에 전달한 메시지를 전달합니다.


# 3. `NotNullValidator`의 동작 확인
간단히 테스트할 수 있도록 `NotNullValidatorTest` 클래스를 작성하여 `NotNullValidator` 클래스가 정상적으로 동작하는지 확인해 보겠습니다.

```java
// io.github.nnoco.annotation_in_action.ch3.validation.NotNullValidatorTest.java
package io.github.nnoco.annotation_in_action.ch3.validation;

/**
 * NotNullValidator 동작 확인
 */
public class NotNullValidatorTest {
    public static void main(String[] args) throws IllegalAccessException {
        NotNullValidator validator = new NotNullValidator();

        Book book = new Book("Java Annotation in Action", "nnoco", 0);

        // 유효한 객체이므로 통과
        validator.validate(book);

        book.setTitle(null);
        // title이 null이므로 예외 발생
        validator.validate(book);
    }
}
```

첫 번째 `validate()` 메서드를 호출했을 때는 `title`과 `author`의 값이 있으므로 예외가 발생하지 않고 정상적으로 유효성 검증이 통과됩니다. `title`의 값을 바꿔주고 `validate()` 메서드를 호출하면 구현한 대로 `IllegalArgumentException`이 발생합니다.
```
Exception in thread "main" java.lang.IllegalArgumentException: title은 필수 항목입니다.
	at io.github.nnoco.annotation_in_action.ch3.validation.NotNullValidator.validateField(NotNullValidator.java:45)
	at io.github.nnoco.annotation_in_action.ch3.validation.NotNullValidator.validate(NotNullValidator.java:34)
	at io.github.nnoco.annotation_in_action.ch3.validation.NotNullValidatorTest.main(NotNullValidatorTest.java:18)
```
`NotNullValidator`에서는 예외를 던지는 방식으로 구현했지만 입맛에 따라 올바르지 않은 필드의 목록을 반환하도록 할 수도 있을 것입니다. 또한 accessible을 강제로 `true`로 설정하여 필드의 값을 가져오도록 구현했는데, `@NotNull` 애너테이션에 해당 필드의 값을 반환하는 Getter의 이름을 전달하도록 하여 해당 Getter를 호출하도록 하거나, 필드의 이름으로 Getter이름을 만들어(title 필드의 경우 getTitle) Getter를 가져온 후 호출하는 방법 등이 있을 것입니다.

이번 예제에서는 클래스의 필드에 태그된 애너테이션을 리플렉션을 통해 읽고 처리해보았습니다. 유사한 방법으로 클래스, 메서드, 파라미터 등에 태그된 애너테이션을 처리할 수 있으며 뒤에서 다양한 실습 예제를 통해 함께 다뤄보도록 하겠습니다.

---
위 코드는 [GitHub Repository](https://github.com/nnoco/java-annotation-in-action/tree/master/src/io/github/nnoco/annotation_in_action/ch3/validation)에서 확인하실 수 있습니다.