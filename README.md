# Monitoring Web Service

Мониторинг работы сервисов некоторого сайта.

Запускать надо по крону, например: `rails r 'HttpRequests.new.perform'`.

Желательно перенаправить stdout в лог-файл. Пример:

    rails r 'HttpRequests.new.perform' &> log/status.log

При измении статуса какого-либо сервиса (что-то перестало работать, что-то заработало) отправляется письмо.

Шаблон письма: <http://localhost:3000/rails/mailers/status_mail> (если запущено на 3000).

Кого уведомлять об изменении работы сервисов, указано в файле `config/admins.yml`.

В `config/application.yml` поля `auth_user` и `auth_password` используются для авторизации к управлению новостями о технических работах на сервере/сервисе.

Для работы этого мониторинга нужен Redis.

Для проверка работы кода - запустить `rspec`.

## Перед запуском

Нужно написать свои тесты (пример ниже) и перечислить их в файле `app/controllers/pages_controller.rb`:

    names({
              'root_domain_spec' => 'Портал',
              # Define your specs there!
    })

Изменить параметры в файлах `config/admins.yml`, `config/outgoing_email.yml`, `config/redis.yml`, `config/environments/production.rb`

## Как писать тесты (specs)

Тесты находятся в папке ```app/specs```.

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
    end
