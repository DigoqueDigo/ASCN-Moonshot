#import "../funcs.typ": code_block, code_grid

= Automatização e Instalação

Tal como mencionado anteriormente, os processos de _provisioning_ e _deployment_ são repetitivos e costumam demorar imenso tempo, o que impossibilita o _provider_ de forcar-se noutras tarefas. Além disso, neste caso em concreto, será necessário contactar vários equipamentos, visto que para garantir a disponibilidade do serviço terá de haver replicação. 

== Ansible

Com a utilização desta ferramenta é possível criar receitas que são executas em paralelo ou sequencialmente por diversos _hosts_, após ser efetuada uma conexão _SSH_ entre estes e o _Management Node_, além disso a leitura das instruções é extremamente facilitada pela estrutura declarativa da linguagem _YAML_, o que contribui para uma maior compreensão dos elementos do grupo.

Posto isto, foram desenvolvidos _playbooks_ relativos ao _deploy/undeploy_ do _Postgres/Servidor Aplicacional_, dado que estes representam componentes distintos, no entanto a instalação completa do serviço envolve a execução conjunta das receitas.

Não obstante, como o serviço estará montado sobre um _cluster_ de _Kubernetes_, optamos por criar _templates_ direcionados a componentes muito específicos, dado que isso permite a sua reutilização ao longo dos _playbooks_ de _deploy_ e _undeploy_.

#code_block(
  code:
  ```
├── moonshot-deploy.yml
├── moonshot-undeploy.yml
├── roles
│   ├── moonshot-deploy
│   │   └── tasks
│   │       └── main.yml
│   └─── postgres-deploy
│       └── tasks
│           └── main.yml
└─── templates
    ├── moonshot
    │   ├── moonshot-deployment.yml
    │   └── moonshot-service.yml
    └─── postgres
        ├── postgres-deployment.yml
        ├── postgres-pvc.yml
        └── postgres-service.yml
```
)

=== Vault

Para proceder à instalação do serviço é necessário manipular dados sensíveis, neste caso em concreto a _password_ de acesso à base de dados, assim sendo é desejável encriptar tal informação, para que o acesso aos _playbooks_ não implique um conhecimento maior que o pretendido. Por conseguinte, com a aplicação de _Vault_, somente aqueles que conhecem a _password_ de encriptação saberão as credenciais de acesso à base de dados e poderão executar os _playbooks_.

=== Inventário Dinâmico

Na fase de monitorização do serviço, são criadas cinco máquinas virtuais com o objetivo de efetuar testes de carga, e uma vez que os endereços _IP_ atribuídos pelo _cloud provider_ variam, torna-se necessário atualizar o inventário durante a execução dos _playbooks_ para que as restantes tarefas sejam executadas nos equipamentos corretos. 

== Docker

Tanto o servidor aplicacional como a base de dados, apresentam diversas dependências necessárias ao seu correto funcionamento, como tal é conveniente criar uma imagem _docker_, visto que esta facilita o processo de _deploy_, ao armazenar todas as _libs_ e descrever os comandos de execução.

Assim sendo, foi desenvolvida uma imagem _docker_ para o servidor aplicacional do _Moonshot_, sendo que a imagem dos _Postgres_ estava previamente disponível no repositório da comunidade. Deste modo, a criação de _deployments_ em _Kubernetes_ fica bastante facilitada, visto que podemos abstrair toda a complexidade dos componentes e trabalhar apenas com a imagem _docker_.

== Kubernetes

A instalação do _Moonshot_ tem como principal objetivo garantir que o serviço está permanentemente disponível, independentemente da demanda dos clientes ou falha de servidores, nesse sentido a plataforma de _Kubernetes_ surge como sendo a mais adequada, visto que possibilita uma orquestração eficiente e escalável de _containers_.

=== Variáveis de Ambiente

Antes de iniciar os componentes do _Moonshot_, é preciso atribuir um valor a determinadas variáveis de ambiente, tais como o utilizador e nome da base de dados, nesse sentido foi criado um _ConfigMap_ para centralizar todas as atribuições e tornar a configuração do _deployment_ mais simplista.

Além disso, como a _password_ da base de dados representa informação sensível, torna-se relevante a utilização de um _Secret_, visto que esconde o valor atribuído, mesmo depois de efetuado um _describe_ do _deployment_ e respetivas variáveis de ambiente.

#code_grid(
  code1: code_block(
    code: [
```yml
kind: ConfigMap
metadata:
  name: moonshot-config
data:
  DB_HOST: "{{ db_host }}"
  DB_NAME: "{{ db_name }}"
  DB_USER: "{{ db_username }}"
```
]),
  code2: code_block(
    code: [
```yml
kind: Secret
metadata:
  name: moonshot-secret
  namespace: default
type: Opaque
data:
  DB_PASSWORD: "{{ db_password }}"
```
]))

=== Persistent Volume Claim

Para usufruir do _Postgres_ é essencial garantir a existência de armazenamento persistente, como tal o _pvc_ tem por objetivo fazer um pedido de disco, que mais tarde é satisfeito pelo administrador ou _Storage Class_ visada.

#code_grid(
  code1: code_block(
    code: [
```yml
kind: StorageClass
metadata:
  name: stc-postgres
parameters:
  type: pd-ssd
reclaimPolicy: Delete
volumeBindingMode: Immediate
allowVolumeExpansion: true
```
]),
  code2: code_block(
    code: [
```yml
kind: PersistentVolumeClaim
metadata:
  name: "{{ pvc_name }}"
spec:
  storageClassName: stc-postgres 
  resources:
    requests:
      storage: 20Gi
```
]))

Tendo isto em mente, foi desenvolvida uma _Storage Class_ especifica para a base de dados, onde a _reclaimPolicy_ corresponde a _Delete_ (o _pv_ é eliminado assim que não houver nenhum _pvc_ ativo), o _volumeBindingMode_ a _Immediate_ (o _pv_ é imediatamente criado assim que o _pvc_ também o for, não espeta por um _consumer_), e o _type_ equivale a _pd-ssd_, visto que um _SSD_ é significativamente mais rápido que um _HDD_, e portanto as operações do _io_ tornam-se menos penalizadoras.

Por fim, uma vez que o _undeploy_ do serviço não implica a perda de todos os dados armazenados, o _pvc_ apenas é eliminado quanto a variável de ambiente _delete_data_ corresponde a _true_.

=== Serviços

Para que o serviço funcione devidamente, é necessário que haja comunicação entre os componentes, além disso o servidor aplicacional deve expor as suas funcionalidade num determinado endereço _IP_, caso contrário os clientes não serão capazes de efetuar pedidos à aplicação.

Tendo isto em mente, foram desenvolvidos dois serviços, um direcionado para as comunicações dirigidas à base de dados, e outro que define um endereço _IP_ a partir do qual o servidor aplicacional é exposto na _internet_.

#code_grid(
  code1: code_block(
    code: [
```yml
kind: Service
metadata:
  name: "{{ db_host }}"
spec:
  type: ClusterIP
  selector:
    app: postgres
  ports:
    - targetPort: 5432
      port: 5432   
```
]),
  code2: code_block(
    code: [
```yml
kind: Service
metadata:
  name: moonshot-service
spec:
  type: LoadBalancer
  selector:
    app: moonshot
  ports:
    - targetPort: 8000
      port: 30007
```
]))

==== ClusterIP

O serviço de _ClusterIP_ permite que todos os _pods_ do _cluster_ comuniquem com a base de dados, além disso o serviço não é exposto ao exterior, o que oferece algumas garantias de segurança, na medida em que todas as comunicações ocorrem internamente.

Por fim, enquanto ponto de curiosidade, repararmos que a variável _db_host_ está presente no _ConfigMap_ do servidor aplicacional, o que faz todo o sentido, visto que o nome deste serviço passa a ser o _host_, e o _Django_ precisa de comunicar com o _Postgres_. 

==== Load Balancer

O serviço de _Load Balancer_ torna o servidor aplicacional acessível através da _internet_, ademais acarreta várias vantagens em termos de configuração, visto que oferece um endereço dinâmico, pronto a utilizar e sem necessidade de criar regras de _firewall_, bem como posiciona um distribuidor de carga entre os pedidos dos clientes e os _pods_ disponíveis.

=== Deployment

Até agora foram apresentados elementos da plataforma _Kubernetes_ que por si só não disponibilizam qualquer serviço aplicacional, nesse sentido um _deployment_ corresponde a uma especificação de um dado programa, algo que geralmente é conseguido através de imagens _docker_ e _containers_.

==== Moonshot

O _deployment_ do servidor aplicacional faz uso de uma imagem _docker_ que o grupo publicou no repositório da comunidade, além disso consideramos que seria mais vantajosos ter um _pod_ por _deployment_, visto que isso facilita a gestão dos recursos e torna a replicação mais simples de alcançar.

Em sequência disso, definimos regras do _nodeAffinity_, para que os _pods_ sejam criados apenas em _nodes_ cuja _zone_ corresponde a _us-central1-a_, sendo que tal afinidade é apenas preferível, de modo a permitir o escalonamento quando os critérios são insatisfazíveis.

#code_grid(
  code1: code_block(
    code: [
```yml
topologySpreadConstraints:
  - maxSkew: 1
    nodeAffinityPolicy: Honor
    topologyKey: zone
    labelSelector:
      matchLabels:
        app: moonshot
```
]),
  code2: code_block(
    code: [
```yml
resources:
  requests:
    cpu: "200m"
    memory: "200Mi"
  limits:
    cpu: "500m"
    memory: "500Mi"
```
]))

Além disso, foram também estabelecidas regras de distribuição com _maxSkew_ igual a um, para que na prática a diferença de _pods_ entre _nodes_ nunca fosse superior a um, evitando assim uma atribuição injusta e desequilibrada de _deployments_.

Por fim, julgamos que para executar o servidor aplicacional seriam precisos 200 _millicores_ e 200 _Mi_, no entanto mais tarde reparámos que tal valor era exagerado, visto que em _idle_ eram gastos somente 25 _millicores_ e 140 _Mi_, no entanto acabamos por manter a especificação dos recursos, visto que o limite é o único que tem impacto na performance dos _pods_.

===== Horizontal Pod Autoscaling

Tal como mencionado anteriormente, o servidor aplicacional constitui um gargalo e ponto único de falha, deste modo convém adquirir propriedades elásticas para assegurar a resposta aos clientes independentemente da demanda do serviço.

Sendo este projeto meramente académico, definimos que o número mínimo de réplicas seria um, enquanto o máximo corresponderia a cinco, no entanto para cenários reais de produção estes valores deveriam ser estudados e ajustados, visto que para cenários de _stress_ cinco é um valor insuficiente.

#code_grid(
  code1: code_block(
    code: [
```yml
- type: Resource
  resource:
    name: cpu
    target:
      type: Utilization
      averageUtilization: 80
```
]),
  code2: code_block(
    code: [
```yml
- type: Resource
  resource:
    name: memory
    target:
      type: Utilization
      averageUtilization: 90
```
]))

Um dos pontos críticos dos _HPA_ é saber quando escalar, como tal foram definidos dois critérios, um que visa uma utilização média do _CPU_ superior a 80%, enquanto o outro explora um consumo médio da memória superior a 90%. Tendo estes valores bem estabelecidos, utiliza-se a seguinte fórmula para calcular o número de réplicas ativas.

#code_block(
  code: [
$ "desiredReplicas" = ceil("currentReplicas" times frac("currentMetricValue","desiredMetricValue"))  $
  ]
)

Posto isto, a utilização conjunta do _HPA_ e _ReplicaSet_ fornece propriedades elásticas ao serviço, na medida em que a quantidade de réplicas do servidor aplicacional é ajustada conforme a demanda do serviço, o que contribui para minimizar os custos em alturas de menor afluência, e além disso garante tolerância a faltas, visto que o _HPA_ define o número mínimo de réplicas ativas que o _ReplicaSet_ tem por responsabilidade assegurar.  

==== Postgres

A especificação deste _deployment_ é bastante mais simplista que a anterior, dado que apenas é chamada a imagem _docker_ do repositório, sendo depois atribuídas as variáveis de ambiente e realizado um pedido de disco através do _pvc_ mencionado previamente.

===== Vertical Pod Autoscaling

Mesmo utilizando um _SSD_, as operações de _io_ são bastante lentas em comparação com as restantes instruções, à visto disso o componente da base de dados pode constituir um gargalo, já para não mencionar que também é um ponto único de falha. 

Tendo isto em mente, seria vantajoso aplicar um _HPA_, no entanto a utilização deste é dificultada pela necessidade de manter estado persistente, pois existindo diversos _pods_ do _Postgres_ teria de ser mantida uma visão consistente dos dados, sem haver disrupção ou _data races_ no acesso a disco.

Perante tal adversidade, julgamos que a alternativa mais viável passa por utilizar um _VPA_, ou seja, os recursos do _pod_ são alocados conforme a demanda, no entanto esta solução também apresenta deficiências, visto que a atribuição de novos recursos implica o _restart_ do _pod_, o que leva a uma indisponibilidade temporária do serviço.

Em suma, parece não existir uma solução trivial, capaz de resolver o problema da escalabilidade da base de dados, destarte optámos por manter apenas um _pod_ com recursos limitados, tendo a perfeita noção que isso será um problema em cenários de _stress_.

=== Cluster Autoscaling

De modo a suportar todos os _pods_, o _cluster_ é constituído por três _nodes_, no entanto estes não são necessários em períodos de menor afluência, o que leva a um consumo ineficiente de recursos, bem como um aumento desnecessário da despesa.

Enquanto estratégia para evitar tal situação, seria conveniente criar um _cluster_ elástico, onde os _nodes_ são atribuídos consoante a procura do serviço, no entanto o grupo no pôde implementar tal _feature_, dado que isso implicava alterar os _playbooks_ da equipa docente.

== Google Cloud

Tal como é evidente, o grupo não possui recursos físicos para albergar um _cluster_ de _Kurbenetes_ e cinco máquina virtuais dedicadas a testes de carga, em consequência disso optou-se por recorrer à plataforma _Google Cloud_, visto que fornece a sensação de recursos ilimitados e abrange uma vasta gama de equipamentos com diferentes especificações.

=== Máquinas Virtuais

A execução de uma determinada ação sobre equipamentos, depende muitas vezes das características dos mesmos, sejam elas relativas a _hardware_ ou _software_, nesse sentido a heterogeneidade dificulta a criação de _playbooks_ genéricos.

Tendo isto em consideração, o uso de máquinas virtuais adquire particular relevância, visto que esconde a diversidade do _hardware_ e fornece recursos unificados, além de ser bastante mais simples realizar a gestão dos recursos.

Posto isto, foram selecionas máquinas virtuais que permitem a execução de todos os componentes aplicacionais ao menor custo, sendo de realçar que os _nodes_ do _cluster_ executam vários _pods_ relativos a monitorização, e portanto foi preciso dar o _upgrade_ de _e2-small_ para _e2-standard-2_. 

#figure(
  table(
    columns: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
    inset: (
      x: 5pt,
      y: 8pt,
    ),
    align: horizon + left,
    table.header(
      table.cell(fill: luma(230), [*Tipo*]),
      table.cell(fill: luma(230), [*vCPUs*]),
      table.cell(fill: luma(230), [*Memória (GB)*]),
      table.cell(fill: luma(230), [*Zona*]),
      table.cell(fill: luma(230), [*Contexto*]),
      table.cell(fill: luma(230), [*Quantidade*]),
    ),
    [e2-standard-2],
    [2],
    [8],
    [us-central1-a],
    [cluster],
    [3],
    [e2-small],
    [2],
    [2],
    [us-central1-a],
    [testes],
    [5]
  ),
  caption: [Especificação das máquinas virtuais]
)

O dispêndio mensal é calculado conforme o tipo de máquina e zona onde está localizada, como tal houve o cuidado de posicionar os recursos numa das zonas mais baratas, a fim de minimizar as despesas, no entanto o custo mensal do _cluster_ ronda os \$190.

== Arquitetura Desenvolvida

Tendo especificado os componentes do _cluster_, resta saber de que modo as interações se procedem, para isso convém destacar somente o _namespace default_, visto ser aí que o _Moonshot_ se encontra instalado. Para as tarefas de monitorização foram criados outros _namespaces_, no entanto a sua inserção no diagrama iria dificultar a compreensão do mesmo. 

#figure(
  image("../images/k8s.png", width: 100%),
  caption: [Arquitetura da aplicação _Moonshot_ em _Kubernetes_ ],
)

Tal como mencionado anteriormente, existem dois macrocomponentes, a base de dados e servidor aplicacional, além disso o funcionamento de ambos é bastante semelhante, no sentido em que o _Deployment_ possui um _ConfigMap_/_Secret_ com as variáveis de ambiente, e expõe as suas funcionalidade num dado serviço, sendo este _ClusterIP_ ou _Load Balancer_.

Centrando a análise na base de dados, o _Deployment_ é responsável por criar um pedido de armazenamento (_pvc_), que mais tarde será satisfeito pela _Storage Class_ ou administador, além disso os _volumes_ do _pod_ são montados no _pv_ previamente fornecido.

Por fim, os _pods_ do servidor aplicacional acedem à base de dados através do serviço _ClusterIP_, sem esquecer que as propriedades elásticas são asseguradas pelo _HPA_, que recolhe informações do _Metrics Server_ e informa o _Deployment_ acerca do número desejado de réplicas, consequentemente o _ReplicaSet_ é tolerante a falhas e garante um número mínimo de _pods_ ativos.