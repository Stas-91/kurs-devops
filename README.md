# kurs-devops

### Решение Задачи  
- Все поставленные задачи решаются через запуск terraform (terraform apply)
- Сруктура проекта терраформ следующая:
  - main.tf - в нем создаются необходимые ВМ для сервисов, расписание snapshots и выходные данные (IP адреса) для ВМ, также задаются локальные значения для создания ВМ (locals) и указываются дополнительные провадеры необходимые для работы (null, time)
  - network.tf - здесь описывается вся сетевая инфраструктура - создается сеть (network-1) и подсети (subnet-1,2,3,4) в соответсвии с заданием
  - security_groups.tf - описываются группы безопасности
  - alb.tf - создается Балансировщик L-7
  - ansible.tf - на основе провайдера null (provisioner "local-exec"), отсюда передаются пепеменные и запускаются конфигурации Ansible (playbook), подробная работа ansible описана ниже
  - variables.tf - здесь объявляются необходмивые переменные для работы выше описанных ресурсов
  - terraform.tfvars - здесь хранятся чувствительные данные - токены и пароли
  - каталог meta - содержит мета данные для ВМ

- Структура Ansible:
  - В папке ansible хранятся плейбуки для настройки сервисов, каждый плейбук запускается из terraform через провайдера null и передает через параметр --extra-vars необходиммые данные для работы разворачиваемых сервисов (это IP адреса, имена и пароли)
  - Подключение ко всем ВМ происходит через bastion host, как того требудет задание. Для этого в конфигурации Ansible, в инвентори, используется параметр ansible_ssh_common_args с опцией конфигурации SSH - ProxyCommand
  - В самих плейбуках, соответвтвено их наименованиям, описана конфигурация сервисов
  - Также в папке ansible присутствуют еще 2 дирректории templates и files
      - В files расположенны статичные конфигурации которые подгружаются из плейбуков для работы соответствующих сервисов
      - В templates - расположены шаблоны Jinja2 - динамически изменяемые файлы с использованием данных, переданных из Ansible (--extra-vars)

- Основные этапы работы проекта terraform
  - Сначала создаются Сеть, группы безопасности и ВМ
  - Затем создается ALB, расписание snapshots
  - До начала работы Ansible выдерживается пауза 90 секунд для того чтобы ВМ были готовы к разворачиванию плейбуков
  - После паузы активируется ресурсы null провайдер ansible.tf и запускают плейбуки Ansible
  - Когда плейбуки Ansible завершают свою работу, в проетке terraform выводятся выходные данные и работа завершается
  - Теперь вся инфраструкура доступна и готова к работе. Посмотреть Kibana можно на дефолтном порту 5601 используя имя - elastic и заданный пароль, Grafana порт 3000, имя - admin и соответствующий пароль из настроек работы (см. ниже)

### Настройка для работы:  
- Для работы необходимо указать данные в файле terraform.tfvars - yandex_cloud_token, elastic_passwd и grafana_passwd
- В файле user-data.yaml необходимо указать публичный ключ SSH, а в папку ansible положить соответствующий приватный ключ и указать его имя в ansible.cfg, так же приватный ключ должен быть и в обычном расположении ~/.ssh
- Для входа в grafana пользователь - admin, kibana - elastic
- На всех ВМ пользователь - stas (указывается в meta), в Ansible inventory.ini и ansible.cfg соответвенно тоже указавается пользователь - stas

### Дополнительные настройки:  
- В файле variables.tf можно настроить характеристики ВМ
- Также variables.tf можно ужесточить политику безопасности, но только после создания всей инфраструктуры, для этого нужно для Переменной управления средой применить default = true и снова запустить terraform apply
- При создании ВМ в файле main.tf можно использовать статические IP. Для этого нужно добавить ключ для IP в locals и раскоментировать ip_address = each.value.ip в блоке network_interface

### Результаты работы:
Работающая инфраструктура рассходует денежные средства, поэтому представляю только данные о ее работе.  
Если в ходе провери задания потребуется показать работу, то развертка занимает не дольше 10 минут и может быть осуществлена по предварительной договоренности.  

Лог создания ресурсов terraform и настройки ansible представлен в файле:  
[worklog](results/worklog)  

Скриншоты (католог resalts): [VM](results/)
