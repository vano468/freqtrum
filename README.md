# Запуск веб-приложения

## Подготовления

Установить nodejs и npm для [Windows](http://nodejs.org/download/).
Для Linux:
```
$ sudo apt-get install nodejs
```

Установить нужные зависимости, вводим в консоли:
```
$ npm install connect serve-static
```

## Запуск

Заходи в консоль, переходим в папку с проектом и запускаем сервер:
```
$ node server.js
```

Приложение будет доступно по адресу: http://localhost:8080/

# Настройки

В файле script.js или script.coffee (во втором случае после изменений в коде нужно будет запустить транслятор coffee в js, в первом случае ничего делать не нужно) находим инициализцию плеера и добавляем туда информацю о песнях (название и путь).

## Плейлист

```javascript
player = new Player [
  { path: 'media/drink.mp3', title: 'Alestorm - Drink' },
  { path: 'media/everything.mp3', title: 'Derdian - In Everything' },
  { path: 'media/attero.mp3', title: 'Sabaton - Attero Dominatus' },
  { path: 'media/eternity.mp3', title: 'Freedom Call - Beyond Eternity' }
]
```

## Сглаживание по времени

```javascript
init = function() {
  ...
  analyser.smoothingTimeConstant = 0.3; // [0;1]
  ...
}
```
