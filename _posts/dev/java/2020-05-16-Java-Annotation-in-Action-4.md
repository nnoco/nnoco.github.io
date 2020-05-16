---
title: Java Annotation in Action 4
date: 2020-05-16 21:31:34+0900
tags: Java Annotation APT PAPA Reflection
categories: dev java
series: java_annotation_in_action
published: true
---

Java Annotation in Action 3편에서는 필드에 애너테이션을 태그하여 필드의 값을 체크해 봤습니다. 이번 편에서는 리플렉션을 통해 메서드와 메서드의 파라미터의 애너테이션을 다뤄봅니다.

메서드의 경우에도 필드를 가져올 때와 유사하게 대상 클래스의 `Class` 객체를 얻고, `Class`의 `getMethod(String, Class...)`, `getMethods()` 메서드나 `getDeclaredMethod(String, Class...)`, `getDeclaredMethods()` 메서드를 이용해 클래스에 정의되어 있는 메서드를 가져올 수 있습니다.

먼저 간단한 계산을 할 수 있는 `Calculator` 클래스를 작성합니다.
```java
// Calculator.java
package io.github.nnoco.annotation_in_action.ch4;

public class Calculator {
    public long plus(int operand1, int operand2) {
        return operand1 + operand2;
    }
}
```

`Calculator` 클래스에 정의된 `plus` 메서드를 리플렉션을 통해 가져오기 위해 `CalculatorReflection` 클래스를 작성해 봅시다.
```java
// CalculatorReflection.java
package io.github.nnoco.annotation_in_action.ch4;

import java.lang.reflect.Method;

public class CalculatorReflection {
    void getPlusMethodBySeveralWays() throws Exception {
        Class<?> clazz = Calculator.class;

        // getMethod(이름, 파라미터 타입 가변인자)로 plus 메서드를 가져옵니다.
        // 해당 클래스에 정의된 public 메서드 또는 상속 받은 public 메서드만 가져올 수 있습니다.
        Method plus1 = clazz.getMethod("plus", int.class, int.class);

        // getMethods()로 모든 메서드 목록을 배열로 가져옵니다.
        // 해당 클래스에 정의된 public 메서드 또는 상속 받은 public 메서드만 가져올 수 있습니다.
        Method[] methods1 = clazz.getMethods();

        // getDeclaredMethod(이름, 파라미터 타입 가변인자)로 plus 메서드를 가져옵니다.
        // 상속 받은 메서드는 해당되지 않으며 해당 클래스에 정의된 메서드만 가져옵니다.
        Method plus2 = clazz.getDeclaredMethod("plus", int.class, int.class);

        // getDeclaredMethods()로 모든 메서드 목록을 배열로 가져옵니다.
        // 상속 받은 메서드는 해당되지 않으며 해당 클래스에 정의된 메서드만 가져옵니다.
        Method[] methods2 = clazz.getDeclaredMethods();
    }
}

```

메서드는 이름과 파라미터 타입을 지정하여 하나의 메서드를 가져오거나 클래스의 모든 메서드를 배열로 가져올 수 있습니다. `getMethod()`와 `getMethods()`의 경우 `public`인 메서드만 반환하며, 부모로부터 상속 받은 메서드도 포함됩니다. 반면에 `getDeclaredMethod()`, `getDeclaredMethods()`는 접근 제어 지시자와 상관없이 모든 메서드를 가져올 수 있지만 상속 받은 메서드는 포함되지 않습니다. 즉 자기 자신에게 정의된 메서드만 반환합니다. `plus` 메서드는 `public`이고 `Calculator` 클래스에 정의되어 있으므로 `getMethod()`, `getDeclaredMethod()` 구분없이 두 가지 방법으로 모두 가져올 수 있습니다.

특정 메서드 하나만을 반환하는 `getMethod()`와 `getDeclaredMethod()`는 메서드의 이름뿐만 아니라 메서드의 파라미터 타입을 가변인자로 전달 받습니다. 자바에서는 메서드 파라미터 타입과 개수가 다르게 하여 메서드 오버로딩을 할 수 있으므로, 오버로딩된 메서드 중 찾고자 하는 메서드를 특정하기 위해서는 메서드의 이름과 파라미터 타입이 필요하기 때문입니다.

이제 메서드와 파라미터에 애너테이션을 사용하기 위해 `@Log`와 `@Ignore` 애너테이션을 정의해 보겠습니다. 뒤에서 `@Log` 애너테이션이 태그된 메서드를 호출하면 메서드의 파라미터와 반환 값을 로그로 출력해볼 것입니다. `@Ignore` 애너테이션은 파라미터에 태그하여 로그로 출력하지 않을 때 사용합니다.

```java
// Log.java
package io.github.nnoco.annotation_in_action.ch4;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface Log {

}

```

```java
// Ignore.java
package io.github.nnoco.annotation_in_action.ch4;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

@Target(ElementType.PARAMETER)
@Retention(RetentionPolicy.RUNTIME)
public @interface Ignore {
    
}
```

두 애너테이션 작성이 완료되었으면 `Calculator` 클래스에 `minus` 메서드를 추가하고 `@Log`와 `@Ignore` 애너테이션을 태그해 줍니다.
```java
public class Calculator {
    // plus 생략

    @Log
    public long minus(int operand1, @Ignore int operand2) {
        return operand1 - operand2;
    }
}
```

`CalculatorReflection` 클래스에는 `calculateWithLog` 메서드를 추가해 주겠습니다. 이 메서드는 실행할 메서드의 이름과 해당 메서드를 실행할 때 전달할 인자 값을 전달받아서 메서드를 찾고 `@Log` 애너테이션이 있으면 메서드의 호출 전과 후에 로그를 출력합니다.
```java
// CalculatorReflection.java
package io.github.nnoco.annotation_in_action.ch4;

import java.lang.reflect.Method;
import java.lang.reflect.Parameter;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

public class CalculatorReflection {
    // 기존 코드 생략

    public long calculateWithLog(Calculator calculator, String name, int operand1, int operand2) throws Exception {
        Class<?> clazz = Calculator.class;

        Method method = clazz.getMethod(name, int.class, int.class);

        boolean logAnnotationPresented = method.isAnnotationPresent(Log.class);

        // 처리하기 용이하도록 파라미터를 배열로 묶습니다.
        Object[] arguments = { operand1, operand2 };

        // Log 애너테이션이 있으면 메서드를 호출하기 전에 파라미터를 로그로 출력
        if(logAnnotationPresented) {
            String parameterLog = getParameterLog(method.getParameters(), arguments);

            System.out.println(name + " 메서드 시작. " + parameterLog);
        }

        // 리플렉션을 통해 메서드 실행
        long result = (long) method.invoke(calculator, arguments);

        // Log 애너테이션이 있으면 리턴 값을 출력
        if(logAnnotationPresented) {
            System.out.println(name + " 메서드 끝. " + result);
        }

        // 값 반환
        return result;
    }

    private String getParameterLog(Parameter[] parameters, Object[] arguments) {
        return IntStream.range(0, parameters.length)
                .boxed()
                // Ignore 애너테이션이 태그되지 않은 파라미터만 필터합니다.
                .filter(i -> !parameters[i].isAnnotationPresent(Ignore.class))

                // "파라미터 이름=인자"를 반환합니다.
                // 바이트코드에 파라미터 이름이 유지되어야 파라미터 이름을 얻을 수 있고,
                // 그렇지 않은 경우 argN 형식의 이름을 반환합니다.
                .map(i -> parameters[i].getName() + "=" + arguments[i])
                .collect(Collectors.joining(", "));
    }
}

```

한 번에 모든 코드를 작성하여 코드가 긴 느낌이 있지만 하나씩 살펴보도록 하겠습니다. 먼저 `calculateWithLog` 메서드는 인자로 `Calculator` 클래스의 인스턴스와 실행할 메서드의 이름(`plus` 또는 `minus`), 그리고 메서드에 전달할 인자인 `operand1`, `operand2`를 전달 받습니다. 이 메서드는 결과적으로 원하는 메서드를 실행하면서, 메서드에 `@Log` 애너테이션이 태그되어 있으면 메서드 실행 전에 파라미터를 로그로 출력하고, 실행 후에 결과를 로그로 출력합니다.

먼저 앞서 살펴본 방법으로 실행할 메서드를 `Class.getMethod()`를 호출하여 가져옵니다. 그리고 필드에 있는 애너테이션 태그 여부를 확인할 때와 마찬가지로 `isAnnotationPresent()` 메서드를 호출하여 `@Log` 애너테이션이 태그되어 있는지 확인합니다.

그 다음 줄에서는 인자로 전달할 `operand1`, `operand2`를 `Object` 배열로 묶어주는데, 이는 파라미터를 로그로 출력할 때와 메서드를 호출할 때의 편의를 위함입니다. 메서드의 파라미터는 배열로 표현되기 때문에, 동일한 인덱스로 접근할 수 있게 하기 위해 인자도 배열로 묶습니다.

`@Log` 애너테이션이 태그 되어 있는 경우에는 메서드를 호출하기 전에 아래에 작성한 `getParameterLog` 메서드를 호출하여 파라미터와 인자를 로그로 출력합니다. `getParameterLog` 메서드를 살펴보면 파라미터에 `@Ignore` 애너테이션 태그 여부를 확인하기 위해 메서드와 마찬가지로 `isAnnotationPresent` 메서드를 호출하여 확인합니다. 이 때 `@Ignore` 애너테이션이 있으면 해당 파라미터는 로그를 출력하지 않도록 하기 위해서 스트림에서 `filter`를 통해 걸러내 줍니다.

그리고 `Parameter` 클래스는 파라미터의 이름을 반환하는 `getName()` 메서드가 있습니다. 이 메서드는 파라미터의 이름을 반환하지만, 컴파일 시에 별다른 옵션이 없으면 소스 상의 파라미터의 이름은 제거되어 이 경우 `"argN"`(`"arg0"`, `"arg1"`, ...) 형식으로 반환합니다. 실제 파라미터 이름을 얻기 위해서는 자바 컴파일 시 `-parameters`를 추가해 주어야 합니다.

다시 `calculateWithLog` 메서드로 돌아와서 메서드를 실행하는 부분을 살펴봅시다. 실행할 메서드의 이름을 `name` 파라미터로 전달 받고 있어서 `if`문이나 `switch` 구문을 이용해 호출을 분기해 줄 수도 있지만, `Method` 클래스의 `invoke` 메서드를 이용해 리플렉션을 통해 메서드를 실행할 수도 있습니다. `invoke` 메서드는 해당 메서드가 실행될 실제 객체와 메서드가 실행될 때 필요한 인자를 가변인자로 전달 받습니다. 일반적인 방법으로 `caculate.plus(1, 2)`와 같이 메서드를 실행할 때도 `Caculator` 클래스의 객체가 필요하듯이 리플렉션을 통해 메서드를 실행하더라도 실제 객체가 필요합니다. `method.invoke()` 함수에 전달하는 객체는 해당 메서드가 있는 객체여야 합니다. 인자는 `Object` 타입의 가변인자를 전달받습니다. 이 때 `Object` 배열을 전달할 수도 있으므로 위에서 정의해 둔 `arguments` 변수를 사용합니다.

그리고 `invoke`의 반환 타입은 `Object` 이므로 원래의 타입인 `long`으로 캐스팅 하고 `result` 변수에 담아줍니다. 그 후 파라미터와 마찬가지로 `@Log` 애너테이션이 있는 경우 리턴 값을 로그로 출력해준 다음 `result`를 반환해 줍니다.


작성한 `caculateWithLog` 메서드를 테스트하기 위해 `main` 메서드를 아래와 같이 작성해 줍니다.

```java
public class CalculatorReflection {
    // 기존 코드 생략

    public static void main(String[] args) throws Exception {
        Calculator calculator = new Calculator();

        CalculatorReflection calculatorReflection = new CalculatorReflection();

        // plus 메서드는 @Log가 없으므로 로그가 출력되지 않습니다.
        long plus = calculatorReflection.calculateWithLog(calculator, "plus", 1, 2);
        
        // minus 메서드는 @Log가 있으므로 로그가 출력됩니다.
        long minus = calculatorReflection.calculateWithLog(calculator, "minus", 1, 2);
    }
}
```

`plus` 메서드에는 `@Log` 애너테이션이 태그되어 있지 않으므로 아무런 로그도 출력되지 않습니다. `@Log` 애너테이션을 태그한 `minus` 메서드는 아래와 같이 로그가 출력되는 것을 확인할 수 있습니다.
```
minus 메서드 시작. arg0=1
minus 메서드 끝. -1
```

이번 편에서는 리플렉션을 통해 메서드와 파라미터를 읽고, 메서드를 실행해 보고 메서드와 파라미터에 태그된 애너테이션을 읽고 처리해 보았습니다. 위의 코드를 다듬어 조금 더 범용적인 `calculateWithLog` 메서드를 만들 수 있지만 본질적으로 아래와 같은 문제가 있습니다.

- 타입 안전성을 해칠 가능성
  - `plus`, `minus` 메서드는 동일한 파라미터 타입과 리턴 타입을 가지고 있지만, 다른 메서드를 지원하기 위해 코드를 수정하면 안전하지 않은 타입을 갖게 될 수 있습니다.
- 안전하지 않은 메서드 이름
  - 메서드 이름을 문자열로 전달하므로 잘못된 문자열 이름을 전달하게 될 수 있습니다.
- 시그니처가 다른 메서드 지원이 어려움
  - 파라미터의 갯수가 한정적이고, 리턴 타입도 `long`으로 고정되어 있습니다. 가변인자와 제너릭을 사용해 해결할 수는 있지만 제한적입니다.

이러한 문제를 해결하기 위해서는 다음 편에서는 `java.lang.reflect` 패키지의 `Proxy` 클래스를 활용해 동일한 기능을 다이내믹 프록시로 구현해 보도록 하겠습니다.

---

\* 작성한 코드는 [GitHub Repository](https://github.com/nnoco/java-annotation-in-action/tree/master/src/io/github/nnoco/annotation_in_action/ch4)에서 확인하실 수 있습니다.