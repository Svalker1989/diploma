# Дипломный практикум в Yandex.Cloud
  * [Цели:](#цели)
  * [Этапы выполнения:](#этапы-выполнения)
     * [Создание облачной инфраструктуры](#создание-облачной-инфраструктуры)
     * [Создание Kubernetes кластера](#создание-kubernetes-кластера)
     * [Создание тестового приложения](#создание-тестового-приложения)
     * [Подготовка cистемы мониторинга и деплой приложения](#подготовка-cистемы-мониторинга-и-деплой-приложения)
     * [Установка и настройка CI/CD](#установка-и-настройка-cicd)
  * [Что необходимо для сдачи задания?](#что-необходимо-для-сдачи-задания)
  * [Как правильно задавать вопросы дипломному руководителю?](#как-правильно-задавать-вопросы-дипломному-руководителю)

**Перед началом работы над дипломным заданием изучите [Инструкция по экономии облачных ресурсов](https://github.com/netology-code/devops-materials/blob/master/cloudwork.MD).**

---
## Цели:

1. Подготовить облачную инфраструктуру на базе облачного провайдера Яндекс.Облако.
2. Запустить и сконфигурировать Kubernetes кластер.
3. Установить и настроить систему мониторинга.
4. Настроить и автоматизировать сборку тестового приложения с использованием Docker-контейнеров.
5. Настроить CI для автоматической сборки и тестирования.
6. Настроить CD для автоматического развёртывания приложения.

---
## Этапы выполнения:


### Создание облачной инфраструктуры

Для начала необходимо подготовить облачную инфраструктуру в ЯО при помощи [Terraform](https://www.terraform.io/).

Особенности выполнения:

- Бюджет купона ограничен, что следует иметь в виду при проектировании инфраструктуры и использовании ресурсов;
Для облачного k8s используйте региональный мастер(неотказоустойчивый). Для self-hosted k8s минимизируйте ресурсы ВМ и долю ЦПУ. В обоих вариантах используйте прерываемые ВМ для worker nodes.

Предварительная подготовка к установке и запуску Kubernetes кластера.

1. Создайте сервисный аккаунт, который будет в дальнейшем использоваться Terraform для работы с инфраструктурой с необходимыми и достаточными правами. Не стоит использовать права суперпользователя
2. Подготовьте [backend](https://www.terraform.io/docs/language/settings/backends/index.html) для Terraform:  
   а. Рекомендуемый вариант: S3 bucket в созданном ЯО аккаунте(создание бакета через TF)
   б. Альтернативный вариант:  [Terraform Cloud](https://app.terraform.io/)  
[bucket-s3.tf](https://github.com/Svalker1989/diploma/blob/master/terraform/bucket-s3.tf)  
3. Создайте VPC с подсетями в разных зонах доступности.
[vpc_network.tf](https://github.com/Svalker1989/diploma/blob/master/terraform/Kuber_cluster/vpc_network.tf)  
4. Убедитесь, что теперь вы можете выполнить команды `terraform destroy` и `terraform apply` без дополнительных ручных действий.
5. В случае использования [Terraform Cloud](https://app.terraform.io/) в качестве [backend](https://www.terraform.io/docs/language/settings/backends/index.html) убедитесь, что применение изменений успешно проходит, используя web-интерфейс Terraform cloud.

Ожидаемые результаты:

1. Terraform сконфигурирован и создание инфраструктуры посредством Terraform возможно без дополнительных ручных действий.
2. Полученная конфигурация инфраструктуры является предварительной, поэтому в ходе дальнейшего выполнения задания возможны изменения.

---
### Создание Kubernetes кластера
 
На этом этапе необходимо создать [Kubernetes](https://kubernetes.io/ru/docs/concepts/overview/what-is-kubernetes/) кластер на базе предварительно созданной инфраструктуры.   Требуется обеспечить доступ к ресурсам из Интернета.

Это можно сделать двумя способами:

1. Рекомендуемый вариант: самостоятельная установка Kubernetes кластера.  
   а. При помощи Terraform подготовить как минимум 3 виртуальных машины Compute Cloud для создания Kubernetes-кластера. Тип виртуальной машины следует выбрать самостоятельно с учётом требовании к производительности и стоимости. Если в дальнейшем поймете, что необходимо сменить тип инстанса, используйте Terraform для внесения изменений.  
Манифест для создания инфраструктуры в YC:  
[main.tf](https://github.com/Svalker1989/diploma/blob/master/terraform/Kuber_cluster/main.tf)  
   б. Подготовить [ansible](https://www.ansible.com/) конфигурации, можно воспользоваться, например [Kubespray](https://kubernetes.io/docs/setup/production-environment/tools/kubespray/)  
   `git clone https://github.com/kubernetes-sigs/kubespray.git --branch release-2.25`
   в. Задеплоить Kubernetes на подготовленные ранее инстансы, в случае нехватки каких-либо ресурсов вы всегда можете создать их при помощи Terraform.
   Подготовка Ansible:  
   | Ansible Version |	Python Version |  
   | >= 2.16.4       |	3.10-3.12 |  
   1. Устанавливаем python3.10  
 
```
sudo apt install build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev wget libbz2-dev
wget https://www.python.org/ftp/python/3.10.0/Python-3.10.0.tgz
tar -xvf Python-3.10.0.tgz
cd Python-3.10.0
sudo ./configure --enable-optimizations
make altinstall
```

   2. Создаем и активируем виртуальное пространство python и устанавливаем зависимости kubespray
```
VENVDIR=kubespray-venv
KUBESPRAYDIR=kubespray
python3.10 -m venv $VENVDIR
source $VENVDIR/bin/activate
cd $KUBESPRAYDIR
pip install -U -r requirements.txt
```  
[requirements.txt](https://github.com/Svalker1989/diploma/blob/master/terraform/Kuber_cluster/ansible/requirements.txt)  
Управление виртуальными пространствами:  
Показать все виртуальные простарнства python  
`sudo find $HOME -name "*activate" -type f`  
Удалить виртуальные простарнства python  
`sudo rm -rf kubespray-venv`

   3. Генерируем инвентори файл и запускаем плейбук kubespray cluster.yaml
[hosts.yaml](https://github.com/Svalker1989/diploma/blob/master/terraform/Kuber_cluster/ansible/hosts.yaml)  
Особенность:  Публичный адрес только **ansible_host**
**ansible_host** - The IP address Ansible uses to connect to this node. Use the private IP if accessible, otherwise the public IP.  
**ip** - The internal IP address for Kubernetes inter-node communication. Should typically be the private IP.  
**access_ip** - The IP address used for accessing the node, if different from 'ip'. Often the same as 'ip' in private networks. Make sure to set it to private IP (same as the "ip" value).  

`ansible-playbook -i /home/str/kubespray/kubespray/kubespray/inventory/strk8s/hosts.yaml  --become --become-user=root --user=str --private-key=/home/str/.ssh/id_rsa cluster.yml`  

Подключаемся к мастеру и меняем права для кубконфига:
```
ssh $USERNAME@$IP_CONTROLLER_0
USERNAME=$(whoami)
sudo chown -R $USERNAME:$USERNAME /etc/kubernetes/admin.conf
exit
```
Копируем кубконфиг на локальную ВМ:  
`scp $USERNAME@$IP_CONTROLLER_0:/etc/kubernetes/admin.conf kubespray-do.conf`  
Кубконфиг:  
[kubespray-do.conf](https://github.com/Svalker1989/diploma/blob/master/terraform/Kuber_cluster/kubespray-do.conf)  
P.S. в процессе выполнения заданий адрес мастера менялся, поэтому может отличаться в разных файлах.  
Заменяем значение server публичным IP адресом мастера:
```
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: XXX
    server: https://89.169.144.199:6443
  name: cluster.local
...
```
Для того чтобы подключаться удаленно к внешнему IP мастера необходимо его добавить в переменную supplementary_addresses_in_ssl_keys в .../group_vars/k8s_cluster/k8s-cluster.yml
или для пропуска проверки сертификата использовать --insecure-skip-tls-verify  для kubectl.  
Добавляем в bash.rc `export KUBECONFIG=$PWD/kubespray-do.conf`  
Проверяем наш кластер:  
`kubectl get pods --all-namespaces --insecure-skip-tls-verify`  
2. Альтернативный вариант: воспользуйтесь сервисом [Yandex Managed Service for Kubernetes](https://cloud.yandex.ru/services/managed-kubernetes)  
  а. С помощью terraform resource для [kubernetes](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_cluster) создать **региональный** мастер kubernetes с размещением нод в разных 3 подсетях      
  б. С помощью terraform resource для [kubernetes node group](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_node_group)
  
Ожидаемый результат:

1. Работоспособный Kubernetes кластер.
2. В файле `~/.kube/config` находятся данные для доступа к кластеру.  
[kubespray-do.conf](https://github.com/Svalker1989/diploma/blob/master/terraform/Kuber_cluster/kubespray-do.conf)  
3. Команда `kubectl get pods --all-namespaces` отрабатывает без ошибок.  
![1](https://github.com/Svalker1989/diploma/blob/master/1.PNG)  
---
### Создание тестового приложения

Для перехода к следующему этапу необходимо подготовить тестовое приложение, эмулирующее основное приложение разрабатываемое вашей компанией.

Способ подготовки:

1. Рекомендуемый вариант:  
   а. Создайте отдельный git репозиторий с простым nginx конфигом, который будет отдавать статические данные.  
   б. Подготовьте Dockerfile для создания образа приложения.  
2. Альтернативный вариант:  
   а. Используйте любой другой код, главное, чтобы был самостоятельно создан Dockerfile.

Ожидаемый результат:

1. Git репозиторий с тестовым приложением и Dockerfile.  
[nginx_app repo](https://github.com/Svalker1989/nginx_app)  
2. Регистри с собранным docker image. В качестве регистри может быть DockerHub или [Yandex Container Registry](https://cloud.yandex.ru/services/container-registry), созданный также с помощью terraform.  
[docker image](https://hub.docker.com/repository/docker/svalker/nginx-app/general)  
Собираем образ командой  
`docker build -t svalker/nginx-app:1.0 .`  
Делаем `docker login`  
Пушим в докерхаб  
`docker push  svalker/nginx-app:1.0`  
---
### Подготовка cистемы мониторинга и деплой приложения

Уже должны быть готовы конфигурации для автоматического создания облачной инфраструктуры и поднятия Kubernetes кластера.  
Теперь необходимо подготовить конфигурационные файлы для настройки нашего Kubernetes кластера.

Цель:
1. Задеплоить в кластер [prometheus](https://prometheus.io/), [grafana](https://grafana.com/), [alertmanager](https://github.com/prometheus/alertmanager), [экспортер](https://github.com/prometheus/node_exporter) основных метрик Kubernetes.
 
2. Задеплоить тестовое приложение, например, [nginx](https://www.nginx.com/) сервер отдающий статическую страницу.

Способ выполнения:
1. Воспользоваться пакетом [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus), который уже включает в себя [Kubernetes оператор](https://operatorhub.io/) для [grafana](https://grafana.com/), [prometheus](https://prometheus.io/), [alertmanager](https://github.com/prometheus/alertmanager) и [node_exporter](https://github.com/prometheus/node_exporter). Альтернативный вариант - использовать набор helm чартов от [bitnami](https://github.com/bitnami/charts/tree/main/bitnami).
Сначала создаем устанавливаем kube-prometheus с помощью  jsonnet-bundler в пустую папку:  
```
$ mkdir my-kube-prometheus; cd my-kube-prometheus
$ jb init  # Creates the initial/empty `jsonnetfile.json`
# Install the kube-prometheus dependency
$ jb install github.com/prometheus-operator/kube-prometheus/jsonnet/kube-prometheus@main # Creates `vendor/` & `jsonnetfile.lock.json`, and fills in `jsonnetfile.json`

$ wget https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/main/example.jsonnet -O example.jsonnet
$ wget https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/main/build.sh -O build.sh
$ chmod +x build.sh
```
Билдим манифесты для деплоя в kube:  
`./build.sh example.jsonnet`  
Деплоим:  
```
# Update the namespace and CRDs, and then wait for them to be available before creating the remaining resources
$ kubectl apply --server-side -f manifests/setup
$ kubectl apply -f manifests/
```
Для проброса порта графаны наружу исопльзовал:  
`kubectl --namespace monitoring port-forward svc/grafana 3000:3000 --address='0.0.0.0'`  
2. Если на первом этапе вы не воспользовались [Terraform Cloud](https://app.terraform.io/), то задеплойте и настройте в кластере [atlantis](https://www.runatlantis.io/) для отслеживания изменений инфраструктуры. Альтернативный вариант 3 задания: вместо Terraform Cloud или atlantis настройте на автоматический запуск и применение конфигурации terraform из вашего git-репозитория в выбранной вами CI-CD системе при любом комите в main ветку. Предоставьте скриншоты работы пайплайна из CI/CD системы.

Ожидаемый результат:
1. Git репозиторий с конфигурационными файлами для настройки Kubernetes.  
Манифесты:  
[monitoring](https://github.com/Svalker1989/diploma/tree/master/monitoring/manifests)  
2. Http доступ к web интерфейсу grafana.
3. Дашборды в grafana отображающие состояние Kubernetes кластера.  
![2](https://github.com/Svalker1989/diploma/blob/master/2.PNG)  
4. Http доступ к тестовому приложению.
Создал новый неймспейс для приложения:  
`kubectl create namespace app-prod`  
Создал новый контекст для пользователя с указанием созданного неймспейса:  
```
kubectl config set-context prod --namespace=app-prod \
>   --cluster=cluster.local \
>   --user=kubernetes-admin
```
Для удаления контекста:  
`kubectl config delete-context`  
Устанавливаем контекст:  
`kubectl config use-context prod`  
Деплоим наше приложение:  
`kubectl apply -f /home/str/diploma/nginx_app/nginx_app_deploy.yaml`  
Манифест:  
[nginx_app_deploy.yaml](https://github.com/Svalker1989/diploma/blob/master/nginx_app/nginx_app_deploy.yaml)  
Сервис для приложения с nodeport:  
[nginx_app_svc.yaml](https://github.com/Svalker1989/diploma/blob/master/nginx_app/nginx_app_svc.yaml)  
Результат:  
![3](https://github.com/Svalker1989/diploma/blob/master/3.PNG)  

---
### Установка и настройка CI/CD

Осталось настроить ci/cd систему для автоматической сборки docker image и деплоя приложения при изменении кода.

Цель:

1. Автоматическая сборка docker образа при коммите в репозиторий с тестовым приложением.
2. Автоматический деплой нового docker образа.

Можно использовать [teamcity](https://www.jetbrains.com/ru-ru/teamcity/), [jenkins](https://www.jenkins.io/), [GitLab CI](https://about.gitlab.com/stages-devops-lifecycle/continuous-integration/) или GitHub Actions.

Ожидаемый результат:

1. Интерфейс ci/cd сервиса доступен по http.
2. При любом коммите в репозиторие с тестовым приложением происходит сборка и отправка в регистр Docker образа.
3. При создании тега (например, v1.0.0) происходит сборка и отправка с соответствующим label в регистри, а также деплой соответствующего Docker образа в кластер Kubernetes.  
  
Ответ:  
GitLab repo:  
[nginx-app gitlab](https://gitlab.com/svalker/nginx-app)  
DockerHub:  
[nginx-app dockerhub](https://hub.docker.com/repository/docker/svalker/nginx-app/general)  
- Установка gitlab агента в k8s кластер:
```
helm repo add gitlab https://charts.gitlab.io
helm repo update
helm upgrade --install nginx-app gitlab/gitlab-agent \
    --namespace gitlab-agent-nginx-app \
    --create-namespace \
    --set config.token=glagent-bxCYWRh5Tz5rpdLyzrZAVbSx-_z9xhyTUegbMiijEE-EWRsCmA \
    --set config.kasAddress=wss://kas.gitlab.com
```
- Установка gitlab runner в кластер k8s  
`helm install --namespace gitlab --create-namespace gitlab-runner -f values.yaml gitlab/gitlab-runner`  
Файл, который содержит gitlabUrl и runnerToken (gitlab->settings->CI/CD->Runners->new runner):  
[values.yaml](https://github.com/Svalker1989/diploma/blob/master/gitlab/values.yaml)
- Настраиваем CI/CD:  
[gitlab-ci.yaml](https://github.com/Svalker1989/diploma/blob/master/nginx_app/.gitlab-ci.yml)  
Манифест для деплоя:  
[nginx_app_deploy.yaml](https://github.com/Svalker1989/diploma/blob/master/nginx_app/nginx_app_deploy.yaml)  
Сервис для приложения с nodeport:  
[nginx_app_svc.yaml](https://github.com/Svalker1989/diploma/blob/master/nginx_app/nginx_app_svc.yaml)  
Результат работы приложения:  
![4](https://github.com/Svalker1989/diploma/blob/master/4.PNG)  

---
## Что необходимо для сдачи задания?

1. Репозиторий с конфигурационными файлами Terraform и готовность продемонстрировать создание всех ресурсов с нуля.
2. Пример pull request с комментариями созданными atlantis'ом или снимки экрана из Terraform Cloud или вашего CI-CD-terraform pipeline.
3. Репозиторий с конфигурацией ansible, если был выбран способ создания Kubernetes кластера при помощи ansible.
4. Репозиторий с Dockerfile тестового приложения и ссылка на собранный docker image.
5. Репозиторий с конфигурацией Kubernetes кластера.
6. Ссылка на тестовое приложение и веб интерфейс Grafana с данными доступа.
7. Все репозитории рекомендуется хранить на одном ресурсе (github, gitlab)

