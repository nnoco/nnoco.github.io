---
title: node-schedule 패키지
category: ['dev', 'node']
tags:
  - cron
  - javascript
  - node.js
  - node-schedule
---

`node-schedule`은 Node.js에서 동작하는 스케줄링을 위한 모듈입니다. 원하는 시간에 작업을 수행할 수 있는 기능을 제공하고 유사한 모듈로는 node-cron이 있습니다. 자바스크립트의 `setInterval` 함수나 `setTimeout` 함수로도 동일한 기능을 구현할 수 있지만 그런 작업을 더 편하게 할 수 있도록 도와줍니다.

GitHub Repository: [https://github.com/node-schedule/node-schedule](https://github.com/node-schedule/node-schedule)


# 1. 모듈 추가
```bash
$ npm i node-schedule
```

# 2. Cron 스타일의 스케줄링
유닉스 계열의 Job 스케줄러인 cron의 표현식을 사용해서 스케줄링을 적용할 수 있습니다.

```
*  *  *  *  *  *
│ │ │ │ │ │
│ │ │ │ │ └ 요일(0 - 7) (0 or 7 is Sun)
│ │ │ │ └───── 월 (1 - 12)
│ │ │ └────────── 일 (1 - 31)
│ │ └─────────────── 시 (0 - 23)
│ └──────────────────── 분 (0 - 59)
└───────────────────────── 초 (0 - 59, OPTIONAL)
```

```javascript
const schedule = require('node-schedule');

// 매일 10시 정각에 '스크럼 시간입니다.' 출력
let job = schedule.scheduleJob('0 10 * * *', () => {
  console.log('스크럼 시간입니다.')
});
```

# 3. 날짜 기반 스케줄링
Date 객체를 전달해서 스케줄링 할 수 있습니다. Date 객체에 설정된 시간에 1회 작업을 수행합니다.

```javascript
const schedule = require('node-schedule');

// 2020년 1월 1일 0시 0분 0초 - 월은 0부터 시작
const date = new Date(2020, 0, 1, 0, 0, 0);
let job = schedule.scheduleJob(date, () => {
console.log('새해가 밝았습니다.');
});
```

# 4. Recurrence Rule 스케줄링(반복 작업)
cron 표현식으로도 동일하게 반복 스케줄링 작업을 할 수 있지만 Recurrence Rule로 명시적으로 표현할 수 있습니다.

```javascript
const schedule = require('node-schedule');

let recurrenceRule = new schedule.RecurrenceRule();
// Range 객체로 범위 설정
recurrenceRule.second = new schedule.Range(0, 59);
// 숫자 리터럴로 지정된 값 설정
recurrenceRule.minute = 20;

// 매시 20분 매초에 메시지 출력
schedule.scheduleJob(recurrenceRule, () => {
    console.log('Hello!')
});
```

# 5. 객체 리터럴
Recurrence Rule 대신 객체 리터럴로 전달할 수도 있습니다. 객체 리터럴로 전달 시 프로퍼티로는 second, minute, hour, date, month, year, dayOfWeek, start, end, rule이 있습니다.

```javascript
const schedule = require('node-schedule');

// 매 0초 마다 'hi' 출력
schedule.scheduleJob({
  second: 0
}, () => {
  console.log('hi')
});
const schedule = require('node-schedule');

// startTime, endTime, rule 조합
let start = new Date(Date.now() + 5000); // 5초 뒤
let end = new Date(startTiime.getTime() + 5000); // 10초 뒤

// start ~ end 동안 매초 마다 'hi' 출력
schedule.scheduleJob({
  start,
  end,
  rule: '*/1 * * * * *'
}, () => {
  console.log('hi');
});
```