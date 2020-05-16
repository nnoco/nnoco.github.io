---
title: Java Annotation in Action 5
date: 2020-05-17 01:20:55+0900
tags: Java Annotation APT PAPA Reflection Proxy
categories: dev java
series: java_annotation_in_action
---

앞서 리플렉션으로 메서드, 파라미터 정보를 읽고 메서드를 호출하면서 애너테이션을 처리하는 방법을 살펴봤습니다. 끝에서 언급했듯 아래와 같은 문제점이 있었습니다.

- 타입 안전성을 해칠 가능성
- 안전하지 않은 메서드 이름
- 시그니처가 다른 메서드 지원이 어려움

충분히 원하는 기능을 구현했지만 여러 변경에 대해 용이한 구현은 아닙니다. 자바에서 제공하는 동적 프록시(Proxy)를 활용하면 같은 동작을 하는 코드를 수월하게 작성할 수 있습니다. 프록시는 "대리인"이라는 뜻의 사전적 의미를 가지며, 프로그래밍에서의 프록시도 그와 유사하게 원래의 대상 메서드를 프록시를 통해 대신해서 호출할 수 있습니다.

{% include image.html
    url="/assets/images/2020/05-17_aia5/normal_call.png"
    description="figure 1. 일반적인 메서드 호출" %}

{% include image.html
    url="/assets/images/2020/05-17_aia5/proxy_call.png"
    description="figure 2. 프록시를 통한 메서드 호출" %}

figure 1은 `calculator.plus(1, 2)`와 같이 일반적인 방법으로 메서드를 호출할 때의 관계를 보여주고 있습니다. figure 2 프록시를 통해 `plus` 메서드를 호출할 때의 관계이며, 클라이언트는 프록시의 `plus` 메서드를 호출하게 되고 다시 프록시 객체는 `Calculator` 객체의 `plus` 메서드를 호출하게 됩니다.
프록시를 통해 호출할 때 메서드 호출 전/후의 처리와 메서드 호출 제어를 할 수 있게 됩니다.

자바의 프록시는 표준 JDK에 내장되어 있어 별도의 라이브러리를 추가하지 않아도 되며 `java.lang.reflect.Proxy` 클래스를 활용해서 프록시 기능을 사용하게 됩니다.

새로운 프록시 인스턴스를 생성하기 위해서는 `Proxy.newProxyInstance` 정적 메서드를 호출합니다. `newProxyInstance` 메서드는 `ClassLoader`, 인터페이스의 `Class` 배열 그리고 `InvocationHandler` 객체를 필요로 합니다. 프록시 클래스는 지정된 `ClassLoader`에 정의되며, 두 번째 인자인 인터페이스의 `Class` 배열로 전달한 모든 인터페이스를 구현합니다. 이 때 배열은 인터페이스로만 구성되어야 하고 인터페이스 외의 클래스나 열거형 등의 타입은 전달할 수 없습니다.

`InvocationHandler` 인터페이스에는 `invoke` 메서드가 정의되어 있습니다. 이 `invoke` 메서드가 프록시 객체를 통해 호출되는 모든 메서드를 처리하게 됩니다. 이 때 클라이언트가 호출한 메서드가 `Method` 타입의 파라미터로 전달되고, 인자 역시 `Object[]` 타입으로 받게 됩니다.

아래는 `java.lang.Runnable` 인터페이스의 프록시 인스턴스를 생성하는 예시입니다.
```java
// RunnableProxy.java
package io.github.nnoco.annotation_in_action.ch5;

import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;

public class RunnableProxy {
    public static void main(String[] args) {
        Runnable runnable = (Runnable) Proxy.newProxyInstance(
                Runnable.class.getClassLoader(),
                new Class[] { Runnable.class },
                new InvocationHandler() {
                    @Override
                    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
                        System.out.println(method.getName() + " 메서드 호출");
                        return null;
                    }
                });
        
        runnable.run();
    }
}
```

`runnable` 변수에는 `Runnable` 인터페이스를 구현한 프록시 객체가 담겨 있으며, 일반적인 `Runnable` 인터페이스를 구현한 객체처럼 호출 할 수 있습니다. `run` 메서드를 호출하면 `run` 메서드의 정보가 `invoke` 메서드에 `method` 파라미터로 전달됩니다. `method` 파라미터는 4편에서 썼던 `Method`와 동일하며, 메서드를 실행하기 위해서는 실제 객체가 필요합니다. (위의 예시에서는 프록시가 아닌 실제 `Runnable` 객체가 없으므로 실행할 수 없습니다.) 그리고 메서드를 호출하면서 전달한 인자가 있다면 `args` 파라미터로 받을 수 있습니다.

---

## 프록시를 활용한 @Log 애너테이션 처리
Java Annotation in Action 4편의  `@Log`와 `@Ignore` 애너테이션은 그대로 사용하고, 프록시 객체는 인터페이스에 대해서만 생성할 수 있으므로, `ICalculator`  인터페이스를 작성하고 `Calculator` 클래스에서는 해당 인터페이스를 구현하도록 수정해 보겠습니다.

```java
// Calculator.java
package io.github.nnoco.annotation_in_action.ch5;

import io.github.nnoco.annotation_in_action.ch4.Ignore;
import io.github.nnoco.annotation_in_action.ch4.Log;

// ICalculator 인터페이스를 구현합니다.
public class Calculator implements ICaculator {
    public long plus(int operand1, int operand2) {
        return operand1 + operand2;
    }

    public long minus(int operand1, int operand2) {
        return operand1 - operand2;
    }
}
```

```java
// ICalculator.java
package io.github.nnoco.annotation_in_action.ch5;

import io.github.nnoco.annotation_in_action.ch4.Log;
import io.github.nnoco.annotation_in_action.ch4.Ignore;

public interface ICaculator {
    long plus(int operand1, int operand2);

    // 애너테이션은 인터페이스의 메서드에 태그합니다.
    @Log
    long minus(int operand1, @Ignore int operand2);
}
```

기존의 `Calculator` 클래스의 메서드를 `ICalculator` 인터페이스로 옮긴 후 `implements ICalculator`를 추가해 줍니다. 이 때 태그되어 있던 애너테이션은 인터페이스 쪽으로 옮겨 줍니다. 프록시에서는 인터페이스의 메서드 정보만을 알고 있으므로, 인터페이스를 구현한 클래스의 애너테이션은 알지 못합니다. 이제 인터페이스는 준비되었으므로 `InvocationHandler` 구현 클래스를 작성할 차례입니다. `InvocationHandler`를 구현하는 클래스는 로그를 출력하고 실제 객체의 메서드를 호출해야 하므로 프록시 대상 객체를 담아둘 멤버 변수를 정의하고, 생성자를 통해 초기화하도록 합니다.

```java
// LogProxy.java
package io.github.nnoco.annotation_in_action.ch5;

import io.github.nnoco.annotation_in_action.ch4.Ignore;
import io.github.nnoco.annotation_in_action.ch4.Log;

import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Parameter;
import java.lang.reflect.Proxy;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

public class LogProxy implements InvocationHandler {
    private Object object;

    public LogProxy(Object object) {
        this.object = object;
    }

    @Override
    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
        boolean logAnnotationPresented = method.isAnnotationPresent(Log.class);

        // Log 애너테이션이 있으면 메서드를 호출하기 전에 파라미터를 로그로 출력
        if(logAnnotationPresented) {
            String parameterLog = getParameterLog(method.getParameters(), args);

            System.out.println(method.getName() + " 메서드 시작. " + parameterLog);
        }

        // 리플렉션을 통해 메서드 실행
        Object result = method.invoke(object, args);

        // Log 애너테이션이 있으면 리턴 값을 출력
        if(logAnnotationPresented) {
            System.out.println(method.getName() + " 메서드 끝. " + result);
        }

        // 값 반환
        return result;
    }

    String getParameterLog(Parameter[] parameters, Object[] arguments) {
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

`InvocationHandler` 인터페이스를 구현했으므로 `invoke` 메서드를 구현하는 것 이외에 기존의 `CalculatorReflection.calculateWithLog` 메서드와 큰 차이점은 없습니다. 다만 `invoke` 메서드가 파라미터로 `method`와 인자인 `args`를 받게 되므로 `Class` 정보로부터 실행할 메서드를 찾는 과정이 없어졌습니다. 또한 `Calculator` 클래스에만 국한되지 않고 모든 타입에 대해 `LogProxy`를 적용할 수 있도록 했습니다.

작성한 `LogProxy`를 테스트 해 봅시다.

```java
// LogProxyTest.java
package io.github.nnoco.annotation_in_action.ch5;

import java.lang.reflect.Proxy;

public class LogProxyTest {
    public static void main(String[] args) {
        ICalculator calculator = (ICalculator) Proxy.newProxyInstance(
                Calculator.class.getClassLoader(),
                new Class[] { ICalculator.class },
                new LogProxy(new Calculator()));

        calculator.minus(1, 2);
    }
}
```

`Proxy.newProxyInstance` 메서드를 통해 프록시 객체를 생성합니다. `ICalculator` 인터페이스를 전달하고, `LogProxy` 객체를 생성하여 `InvocationHandler`를 전달합니다. `Proxy.newProxyInstance` 메서드의 반환 타입을 `ICalculator` 타입으로 형변환 해 주는데, 이 때 구현 타입인 `Calculator` 타입으로 형변환을 하면 `ClassCastException`이 발생하므로 주의해야 합니다.

`LogProxyTest`의 `main` 메서드를 실행해 보면 이 전의 로그 처리와 동일하게 동작하는 것을 확인할 수 있고, 이제 `Calculator`가 아닌 다른 타입에 대해서도 `@Log` 애너테이션 처리를 할 수 있게 되었습니다.

```
// 실행 결과
minus 메서드 시작. operand1=1
minus 메서드 끝. -1
```

여기까지 Java Annotation in Action 3, 4, 5편을 통해 리플렉션과 리플렉션을 이용해 애너테이션을 읽고 처리하는 방법을 다뤄봤습니다. 클래스나 생성자 등 아직 다루지 않은 리플렉션의 영역들이 있지만 시리즈의 나머지 편에서 보다 실용적인 예제들과 함께 리플렉션의 추가적인 내용을 다뤄보도록 하겠습니다.

\* 작성한 코드는 [GitHub Repository](https://github.com/nnoco/java-annotation-in-action/tree/master/src/io/github/nnoco/annotation_in_action/ch5)에서 확인하실 수 있습니다.

---
## References
- [https://docs.oracle.com/javase/8/docs/technotes/guides/reflection/proxy.html](https://docs.oracle.com/javase/8/docs/technotes/guides/reflection/proxy.html)
- [https://www.baeldung.com/java-dynamic-proxies](https://www.baeldung.com/java-dynamic-proxies)