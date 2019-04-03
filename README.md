# Monitoring Web Service

![Screenshot](https://user-images.githubusercontent.com/3381390/55513446-57be6e80-566e-11e9-9a06-10d2d211ac95.png)

Мониторинг работы сервисов некоторого сайта.

Можно тестировать несколько сайтов с помощью простого формата спецификации (см. ниже).

Запускать надо по крону, например: `rails r 'HttpRequests.new.perform'`.

Желательно перенаправить stdout в лог-файл. Пример:

    rails r 'HttpRequests.new.perform' &> log/status.log

При измении статуса какого-либо сервиса (что-то перестало работать, что-то заработало) отправляется письмо.

Шаблон письма: <http://localhost:5000/rails/mailers/status_mail> (если запущено на порту 5000).

Веб-интерфейс показывает, какие сайты/сервисы сейчас работают или не работают, а также список новостей о неполадках и техническом обслуживании (эти новости может публиковать администратор). Для вывода текста новостей используется формат Markdown.

Для работы этого мониторинга нужен Redis.

Для проверка работы кода - запустить `rspec`.

Для запуска веб-интерфейса - запустить `foreman start` (`http://localhost:5000/`).

## Перед запуском

Пример для дистрибутивов на основе Debian:

```
sudo apt install ruby redis ruby-foreman
bundle
```

Перед запуском этой программы необходимо сделать копию файла `.env.template` под названием `.env`, этот файл содержит настройки программы:

| Параметр | Комментарий | Пример значения |
|----------|-------------|-----------------|
| DOMAIN_NAME | Адрес который будет указан в теле отправляемых писем | `sitename.com` |
| REDIS_URL | Адрес для подключения к Redis | `redis://localhost:6379` |
| REDIS_NAMESPACE | Название пространства в Redis (позволяет хранить записи нескольких программ на одном сервере) | `status` |
| ADMIN_EMAILS | Адреса email, перечисленные через ';' - кого необходимо уведомлять об изменении работы сервисов | `a@b.cd` или `a@b.cd; e@b.cd` |
| OUTGOING_EMAIL | Адрес отправителя электронных писем | `no-reply@sitename.com` |
| ADMIN_USER | Имя пользователя, имеющего доступ к управлению список новостей | `admin` |
| ADMIN_PASSWORD | Пароль пользователя, имеющего доступ к управлению список новостей | `7niA$SD7.9ad_aS` |

Параметры `ADMIN_USER` и `ADMIN_PASSWORD` используются для авторизации к управлению новостями о технических работах на сервере/сервисе.

Для запуска тестирования необходимо написать свои тесты (пример ниже) и перечислить их в файле `specs/specs.yml` (можно использовать файл `specs/specs.yml.template` как шаблон):

    # any_spec: 'Title'
    root_domain_spec: 'Портал'
    user_section_spec: 'Личный кабинет'
    admin_section_spec: 'Админка'

Левая часть строки (`any_spec`) - это часть имени файла (без расширения `.rb`), находящегося в папке `specs`. Т.е. тест `root_domain_spec` находится в файле `specs/root_domain_spec.rb`.

Правая часть (после знака "`:`") - это название, которое отображается в веб-интерфейсе, рядом со статусом сервиса.

Файл `config/specs.yml` влияет только на то, какие сервисы будут отображаться в веб-интерфейсе.
При тестировании через `HttpRequests.new.perform` будут запущены все тесты, находящиеся в папке `specs`.

Кроме этого, просмотрите файл `config/environments/production.rb`, он содержит настройки среды запуска (рекомендуется запускать в режиме `production`).

## Как писать тесты (specs)

Тесты находятся в папке `specs`. Пример:

    # Комментарий
    domain 'название домена' do
      # visit '/адрес страницы, исключая название домена'

      # код ответа меньше 400; то же, что visit '/', -> { success? }
      visit '/'
      
      # найти на странице слова 'Adobe Connect'
      visit '/', -> { include?('Adobe Connect') }
      
      # регулярное выражение (здесь: четыре пробельных символа или больше), можно записать как %r(\s{4,})
      visit '/system/help/support?set-lang=ru', -> { match? /\s{4,}/ }
      
      # любые действия на ваш вкус
      visit '/', -> {
        @response.body.size > 100 ||
          @response.code == 304 ||
          @response.message == 'Ok' ||
          @response.headers.key?('server')
      }
      
      # Все строки выполняются последовательно, поэтому можно добавить этап авторизации.
      # Авторизация основана на поле authenticity_token в формах на Rails и переданных параметрах.
      # Форма авторизации отправляется через POST.
      
      auth form_url: '/login', login_url: '/login',
        credentials: {email: 'test@email.org', password: '******'}
      
      visit '/my', -> { include? 'test@email.org' }
      
      # Отправка произвольной формы, через POST.
      
      send_form '/messages', {message: Time.now.to_s, title: 'Testing'}, -> { success? }
    end

## Дополнительные параметры запуска тестов

Есть возможность изменить некоторые параметры при вызове команды `rails r 'HttpRequests.new.perform(options)'`, указав необходимые параметры в `options` (`Hash`):

| Параметр | Эффект | Значение по умолчанию |
|---------|--------|---------|
| `domain: 'string'` | все запросы будут идти на этот домен (`'string'`) | `nil`, используется название домена из файла `spec` |
| `redis: false` | не использовать Redis | `true`, использовать Redis |
| `send_mails: false` | не отправлять письма об изменении статуса сервисов | `true`, отправлять письма |
| `emulate: true` | не выполнять запросы и не отправлять письма | `false`, выполнять запросы и отправлять письма |
