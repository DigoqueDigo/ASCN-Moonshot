#import "../funcs.typ": code_block, code_grid

= Monitorização

A monitorização é essencial para compreender a atividade de uma aplicação ao longo do seu ciclo de vida, com um sistema de observação e análise, é possível detetar rapidamente comportamentos anómalos, antecipar riscos de falha e ajustar recursos conforme as necessidades de utilização, o que por conseguinte permite ao administrador do sistema tomar decisões com algum fundamento.

Para além da utilização da _Google Cloud_, decidimos implementar uma alternativa com as ferramentas _Prometheus_ e _Grafana_, estando a primeira encarregue de recolher e colecionar métricas, enquanto a segunda trata de apresentar as mesmas através de _dahsboards_.

Infelizmente a serviço _Moonshot_ não possui um _endpoint_ de _metrics_, como tal foi necessário colocar um _DaemonSet_ de _node exporters_ sobre os _nodes_ do _cluster_, deste modo os _daemons_ são responsáveis por recolher as métricas, que posteriormente são passadas ao serviço do _Prometheus_, e consequentemente obtidas pelo _Grafana_.

Tendo esta alternativa de monitorização, usufruímos de um maior controlo e poder para ajustar todo o _pipeline_ de recolha e análise de _logs_, gerindo formatos, _parsers_ e configurações específicas para cada aplicação ou ambiente, além disso o _node exporter_ é capaz de capturar diversas métricas de baixo nível como o número de _mallocs_.

Por outro lado, também existem algumas desvantagens, desde já a maior complexidade de implementação, mas para além disso, o facto de se estar a utilizar um _node exporter_ significa que as métricas que obtemos são apenas relacionadas ao _node_, enquanto que seria bastante interessante ter uma maior granularidade fazendo a distinção entre _pods_ do mesmo _node_.

== Métricas

=== Pods

- *Consumo de _CPU_ e memória:* permite avaliar se o _pod_ tem recursos suficientes ou está sobrecarregado, tornando a alocação de recursos numa tarefa mais eficiente.

- *Débito de transmissão e receção:* fundamental para identificar possíveis gargalos de rede ou picos de tráfego, auxiliando na otimização do fluxo de dados.

- *Utilização de armazenamento efémero e persistente:* esclarece a quantidade de espaço em disco utilizada, prevenindo eventuais problemas de falta de capacidade e garantindo um desempenho consistente.

=== Nodes

- *Consumo de _CPU_ e memória:* determina se o _node_ está a ser utilizado de forma equilibrada e consistente, indicando quando é necessário escalar ou realocar cargas entre os _nodes_.

=== Cliente

- *Duração dos pedidos:* mede a latência sentida pelo utilizador, permitindo verificar se os tempos de resposta permanecem dentro dos limites aceitáveis.

- *Taxa de pedidos efetuados:* revela a intensidade de utilização do sistema, ajudando a prever necessidades de escalabilidade.

- *Taxa de pedidos mal sucedidos:* serve para detetar problemas no lado do cliente ou do servidor, contribuindo para a identificação e resolução de erros ou falhas.

== Workloads

Para conseguirmos visualizar a resposta da nossa aplicação num cenário mais realista é preciso criar _workloads_ que terão como alvo partes diferentes do nosso sistema. Ferramentas como _JMeter_ e _k6_ são muito úteis para conseguirmos implementar isto e efetivamente testar o sistema. Os alvos em causa são o servidor aplicacional e a base de dados

#figure(
  table(
    columns: (1fr, 1.2fr, 0.8fr, 0.8fr ,1.2fr),
    inset: (
      x: 5pt,
      y: 8pt,
    ),
    align: horizon + left,
    table.header(
      table.cell(fill: luma(230), [*Tipo*]),
      table.cell(fill: luma(230), [*Alvo*]),
      table.cell(fill: luma(230), [*VUs*]),
      table.cell(fill: luma(230), [*Iterações*]),
      table.cell(fill: luma(230), [*Ações*]),
    ),
    [Simples],
    [Servidor Aplicacional],
    [300],
    [60000],
    [_GET api/health_],
    [Complexo],
    [Base de Dados],
    [20],
    [200],
    [
      _POST_ api/auth/login \
      _POST_ api/recoveries \
  ],
  ),
  caption: [Especificação dos testes de carga] 
)

=== Workload Simples 

Aqui o teste que se vai utilizar é um simples _GET_ para o _endpoint api/health_, no entanto com a ajuda das ferramentas mencionadas isto é replicado diversas vezes de forma a ativar o _Horizontal Pod Autoscaler_ para escalar este componente.

=== Workload Complexa

Um teste de carga à base de dados não é tão simples como o anterior, como tal optou-se por criar um conjunto de utilizadores que tentam dar _login_ na aplicação e depois criar um certificado. Isto utiliza o método de _POST_ e requer a utilização da base de dados para todos os passos do teste.

== Visualização

Como anteriormente referido, utilizámos a _Google Cloud_ para a monitorização, sendo que esta oferece um serviço de visualização de métricas com _dashboards_ personalizáveis. Decidimos utilizar maioritariamente gráficos de linhas. Esta decisão deve-se ao facto de que estes são os que melhor demonstram a evolução da métrica em função do decorrer do tempo, algo que é imensamente importante para perceber a partir de que altura é que certo evento aconteceu.

== Automatização

Para efetivamente executar estes testes (assumindo que o sistema já está operacional) terá que se passar por quatro fases a explicar a seguir. Toda a execução destes testes é feita a partir de um _playbook_ e com o uso de _tags_ podemos diferenciar estas diferentes etapas (a ausência destas faz com que ocorra a execução de todas as fases) de forma a não ter que repetir sempre o _setup_ dos testes.

=== Criação das Máquinas Virtuais

Para se poder testar um comportamento real de uso da nossa aplicação é necessário emular utilizadores. Para tal existe uma _task_ dentro da _role load_vms_create_ que trata de criar cinco máquinas virtuais de teste, é importante referir que estas são mais simples e portanto também menos custosas.

=== Provisionamento das Máquinas Virtuais

Após a criação destes "utilizadores" é necessário fazer com que todos consigam executar as ferramentas de teste que referimos anteriormente, como tal criou-se outra _task_ de provisionamento de forma a alcançar o objetivo referido.

Enquanto medida para acelerar a execução do _playbook_, tivemos o cuidado de executar apenas as _tasks_ que são necessárias, ou seja, se o _k6_ já se encontra instalado, não vale a pena estar a executar o processo de instalação novamente.

#code_grid(
  code1: code_block(
    code: [
```yml
name: Check if k6 is installed
  ansible.builtin.command:
    cmd: k6 version
  register: k6_check
  failed_when: false
```
]),
  code2: code_block(
    code: [
```yml
name: Install k6
  ansible.builtin.apt:
    name: k6
    state: present
  when: k6_check.rc != 0
```
]))

=== Execução dos Testes

O passo que procede os anteriores será executar as _workloads_. Para tal, temos uma _role_ que está encarregue de o fazer, utilizando as ferramentas já referidas, _JMeter_ e _k6_. De forma a não ser preciso definir manualmente as ações a executar, decidimos criar ficheiros que serão posteriormente passados às ferramentas e contêm, no caso do _k6_, código _JavaScipt_ que dita o comportamento. 

#code_grid(
  code1: code_block(
    code: [
```yml
name: Run tests on load VMs
  hosts: load_vms
  gather_facts: true
  roles:
    - { 
      role: load-test/load_vms_test,
      jmeter_load_test_threads: 300,
      jmeter_load_test_iters: 200,
      jmeter_load_test_file: load_app.jmx,
      k6_load_test_vus: 20,
      k6_load_test_iters: 200,
      k6_load_test_file: load_db.js
      }
  tags: ["test"]
```
]))

=== Destruição das Máquinas Virtuais

Esta etapa visa destruir as máquinas virtuais utilizadas durante os testes de carga, evitando assim que consumam mais recursos apesar de não serem necessárias, além disso este passo adquire um caráter opcional, visto que nem sempre se pretende apagar os recursos após uma _suite_ de testes, sendo comum efetuar diversos testes antes de destruir os equipamentos 