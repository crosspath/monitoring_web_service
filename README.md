# Monitoring Web Service

Мониторинг работы сервисов некоторого сайта.

Запускать надо по крону, например: `rails r 'HttpRequests.new.perform'`.

Желательно перенаправить stdout в лог-файл. Пример:

    rails r 'HttpRequests.new.perform' &> log/status.log

При измении статуса какого-либо сервиса (что-то перестало работать, что-то заработало) отправляется письмо.

Шаблон письма: <http://localhost:3000/rails/mailers/status_mail> (если запущено на 3000).

Кого уведомлять об изменении работы сервисов, указано в файле `config/admins.yml`.

В `config/application.yml` поля `auth_user` и `auth_password` используются для авторизации к управлению новостями о технических работах на сервере/сервисе.
Плюс, есть возможность отправки форм с проверкой результатов.

Для работы этого мониторинга нужен Redis.

Для проверка работы кода - запустить `rspec`.

## Перед запуском

Для запускания тестирования необходимо написать свои тесты (пример ниже) и перечислить их в файле `config/specs.yml`:

    # any_spec: 'Title'
    root_domain_spec: 'Портал'
    user_section_spec: 'Личный кабинет'
    admin_section_spec: 'Админка'

Левая часть строки (`any_spec`) - это часть имени файла (без расширения `.rb`), находящегося в папке `app/specs`. Т.е. тест `root_domain_spec` находится в файле `app/specs/root_domain_spec.rb`.

Правая часть (после знака "`:`") - это название, которое отображается в веб-интерфейсе, рядом со статусом сервиса.

Кроме этого, просмотрите файлы:

1. `config/admins.yml`: список email, на которые будут отправлены уведомления об изменении статуса тестируемых сервисов.
2. `config/outgoing_email.yml`: параметры отправки электронных писем.
3. `config/redis.yml`: параметры подключения к Redis.
4. `config/environments/production.rb`: настройки среды запуска (рекомендуется запускать в режиме `production`).

## Как писать тесты (specs)

Тесты находятся в папке `app/specs`. Пример:

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
