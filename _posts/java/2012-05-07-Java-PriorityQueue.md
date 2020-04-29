---
title: Java PriorityQueue
category: java
tags: 
  - Java
  - 자료구조
  - 우선순위큐
  - PriorityQueue
---

(티스토리 블로그에 작성했던 글을 옮긴 글입니다.)

힙을 구현하기는 귀찮아서 '혹시나' 싶어서 찾아보니 '역시나' 고맙게도 자바에 PriorityQueue가 있네요.
먼저 PriortyQueue는 java.util 패키지에 있고, 여러 형태의 생성자가 오버로딩되어 있는데,
주요한 두가지만 알아보면 아래와 같습니다.

- `PriortyQueue<E>()`  
- `PriorityQueue<E>(int initialCapacity, Comparator<? super E> comparator)`


둘을 비교하자면 전자는 기본 생성자를 이용해서 심플하게 생성하는 방법이고, 후자는 초기 큐 내부의 배열 크기와 Comparator 객체를 전달하면서 객체를 생성하는 방법입니다. (어째서인지 initialCapacity 없이 Comparator만 전달하는 생성자는 없더군요.)


※ initialCapacity?  
큐 내부에서 사용하는 배열의 초기 크기를 결정하는 값입니다. 기본적으로 11의 크기를 사용하고 임의로 전달할 경우에는 그 크기를 사용하는데 1보다 작은 경우 `IllegalArgumentException` 예외가 발생합니다. 전달 인자가 잘못되었단 얘기죠.

배열의 크기는 initialCapacity로 고정되는 것이 아니라, 요소의 수가 배열의 크기에 도달하면 크기를 늘립니다. 재밌는 것은 배열의 크기가 커질 때 규칙을 보면 배열의 크기가 64 미만일 때는 2씩 커지고, 그 이후로는 이전 크기의 1/2 씩 증가하도록 되어있습니다. 왜 이런 룰이 적용되었는지는 잘 모르겠네요.

큐 내의 배열의 최대크기는 `private static final int MAX_ARRAY_SIZE = Integer.MAX_VALUE - 8;`
이렇게 정의되어 있으니, 값으로 보면 `2147483639` 까지입니다. 왠만한 경우엔 다 들어갈 수 있겠죠?

다만, 힙 메모리가 부족해서 최대 크기가 되기 전에 `OutOfMemoryError가` 먼저 발생하겠네요.





큐에서 중요한 두 메서드, 큐에 넣고(add), 큐에서 빼는(poll) 메서드에 대해 간단하게 설명하겠습니다. 덤으로 가장 우선순위가 높은 요소를 확인하는 peek 메서드도요.

- `boolean add(E e)` : 큐에 요소를 추가합니다. 반환값은 성공 여부입니다.  
- `E poll()` : 큐에서 우선순위가 가장 높은 요소를 빼냅니다. 즉 반환 후에 큐에서 삭제됩니다.  
- `E peek()` : poll과 달리 큐에서 삭제하지 않고 가장 우선순위가 높은 요소를 얻습니다.

# 1. PriorityQueue()
기본 생성자를 이용하는 경우는 제너릭 타입 E의 `compareTo` 메서드를 이용하여 정렬에 사용합니다. 
`compareTo` 메서드는 그냥 compareTo메서드를 만들어 쓰는 것이 아니라, Comparable 인터페이스를 구현해서 만듭니다.



만약 Comparable 인터페이스를 구현하지 않은 클래스를 큐의 엘리먼트로 사용하는 경우에는 `java.lang.ClassCastException`을 만나게 될 겁니다. PriorityQueue 내부에서 Comparable 타입으로 캐스팅해서 `compareTo` 메서드를 호출하기 때문입니다.

기본 생성자를 이용하여 큐의 객체를 생성하는 경우를 소스코드로 작성해볼까요.

먼저 요소로 사용할 Element 클래스를 작성해 보겠습니다.

```java
class Element implements Comparable<Element>{
	private int num; // 정렬의 기준이 될 값
	
	public Element(int num){
		this.num = num;
	}
	
	public int getNum(){
		return num;
	}

	@Override // Comparable 인터페이스의 compareTo 메서드 구현
	public int compareTo(Element o) {
		return num <= o.num ? -1 : 1;
	}
}
```

compareTo 메서드의 기능은 현재 객체와 다른 Element 객체를 비교하여 우선순위를 판단하는 것입니다. 우선순위의 판단은 반환값으로 하는데 음수인 경우에는 현재 객체가 우선임을 의미하고, 양수인 경우에는 대상 객체(위의 소스코드에서는 Element o)가 우선임을 의미합니다. 간편하게 `return num - o.num;`을 해도 됩니다.

다음으로 PriorityQueue를 사용해 볼 클래스 PriorityQueueTest 를 작성해 보겠습니다.

```java
public class PriorityQueueTest {
	public static void main(String[] args) {
		PriorityQueue<Element> q =
				new PriorityQueue<Element>();
		
		Random random = new Random(System.nanoTime());
		
		// 0~49의 난수를 생성하여 큐에 넣습니다.
		for(int i = 0 ; i < 10 ; i++){
			q.add(new Element(random.nextInt(50)));
		}
		
		// 큐에서 값을 빼면서 정렬이 되었는지 출력해봅니다.
		int size = q.size();
		for(int i = 0 ; i<size ; i++){
			System.out.println(q.poll().getNum());
		}
	}
}
```

[출력결과]
```
4
14
19
19
30
33
42
42
46
49
```

# 2. PriorityQueue(int initialCapacity, Comparator<? super E> comparator)

복잡해 보이는 생성자지만 간단합니다. 초기 배열 크기와 `Comparator`를 구현한 객체를 전달해 주면 되는데, `Comparator<? super E>` 가 조금 거슬리는 분도 있을 거라고 생각합니다. Java 5 부터 제너릭 개념이 들어가면서 컬렉션 관련 API에는 제너릭이 들어가도록 모두 바뀌었습니다. 제너릭이라고 말하는게 꺽쇠 괄호 < > 를 이용해 타입을 지정해 주는 것을 말합니다.

제너릭에 관해서는 다른 글에서 얘기하기로 하고, 위의 `<? super E>`가 의미하는 것만 알아보면 `Comparator` 선언 시, 혹은 구현시에 `Comparator<타입>` 의 형태로 적어줘야 합니다. 이때 `? super E` 가 의미하는 게 위에 들어가는 타입은 `E`를 상속받은 하위 클래스여야 한다는 의미가 됩니다. 풀어보면 어떤 타입(?)의 부모(super)가 `E`여야 한다. 라고 볼 수 있겠네요.

복잡하게 생각할 것 없이 여기서는 "타입"의 위치에 Element를 적어주도록 합시다. 

Comparator 인터페이스를 구현하는 방법은 여러가지가 있겠지만 여기서는 그냥 익명 이너 클래스로 구현하여 전달하도록 하겠습니다. Element 클래스는 위의 클래스 그대로 사용합니다.

```java
class PriorityQueueTest {
	public static void main(String[] args) {
		PriorityQueue<Element> q =
			new PriorityQueue<Element>(50, new Comparator<Element>() {
				@Override
				// Comparator 인터페이스의 compare 메서드를 구현합니다.
				// 여기서는 이전과 반대로 내림차순 정렬을 하도록 했습니다.
				public int compare(Element o1, Element o2) {
					return o2.getNum() - o1.getNum(); 
				}
			});
		
		Random random = new Random(System.nanoTime());
		
		// 0~49의 난수를 생성하여 큐에 넣습니다.
		for(int i = 0 ; i < 10 ; i++){
			q.add(new Element(random.nextInt(50)));
		}
		
		// 큐에서 값을 빼면서 정렬이 되었는지 출력해봅니다.
		int size = q.size();
		for(int i = 0 ; i<size ; i++){
			System.out.println(q.poll().getNum());
		}
	}
}
```

[출력 결과]
```
42
36
33
28
26
18
14
4
3
0
```

내림차순으로 정렬이 되었습니다. 여기서 조금 의아한 점을 찾으신 분도 있을 것 같습니다. 이미 Element는 Comparable 인터페이스를 구현해서 오름차순으로 정렬하도록 되어있는데, 내림차순으로 정렬되었기 때문입니다. 그 의문점의 결과는 위의 출력결과가 말해줍니다.

즉 compareTo 메서드보다 compare 메서드가 우선한다는 말이지요. (그냥 내부적으로는 `if(comparator != null){ ... }` 이렇게 되어있어서 문장상에서 우선하게끔 되어있습니다.)

자바의 PriorityQueue 클래스를 사용해 봤습니다. Comparator나 Comparable인터페이스에 대한 개념이 확실하게 잡힌다면 크게 무리 없이 사용할 수 있을 것 같습니다.