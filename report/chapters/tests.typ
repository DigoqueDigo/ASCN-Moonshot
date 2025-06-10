#import "../funcs.typ": code_grid, image_block

= Testes e Avaliação

O _playbook_ referente à automatização dos testes de carga é responsável por executar as duas _workloads_ mencionadas anteriormente, sendo que a _simples_ (focada no servidor aplicacional) estreou-se às 22:55, enquanto a _complexa_ (focada na base de dados) teve início às 23:00.

Tendo isto em consideração, podemos fazer uma análise mais cuidada dos _dashboards_ e constatar se os objetivos da instalação foram alcançados, entre eles ajustar os _deployments_ mediante a demanda do serviço, e diminuir o impacto provocado pelos gargalos. 

== Pods

Antes de examinar os seguintes _dashboards_, convém destacar que o _pod_ do _Postgres_ está identificado a roxo, enquanto os restantes traços correspondem a réplicas do servidor aplicacional.

#code_grid(
  code1:
    image_block(
      imagem: image("../images/pod_cpu.png", width: 100%),
      caption: [Consumo de _CPU_ pelos _pods_]
    ),
  code2:
    image_block(
      imagem: image("../images/pod_memory.png", width: 100%),
      caption: [Consumo de memória pelos _pods_]
    )
)

Inicialmente existe somente uma réplica de cada componente, no entanto, logo após o princípio da _workload simples_, regista-se um aumento do _CPU_ e memória por parte do servidor aplicacional, o que levou à criação de novas réplicas, visto terem sido atingidas as políticas de _CPU_.

Por outro lado, não se regista qualquer alteração na base de dados durante a _workload simples_, o que faz todo o sentido, visto tratar-se simplesmente de um _GET_ sobre a rota _api/health_. Entretanto, a _workload complexa_ origina um aumento do consumo de _CPU_ e memória, no entanto estes valores são tão insignificantes, ao ponto de julgarmos que o gargalo nunca estará na base de dados.

Por fim, podemos constatar que o término das _workloads_ levou à diminuição do consumo de recursos, consequentemente uma das réplicas do servidor aplicacional foi eliminada por volta das 23:14.

#code_grid(
  code1:
    image_block(
      imagem: image("../images/pod_bytes_transmitted.png", width: 100%),
      caption: [Débito de transmissão dos _pods_]
    ),
  code2:
    image_block(
      imagem: image("../images/pod_bytes_received.png", width: 100%),
      caption: [Débito de receção dos _pods_]
    )
)

A quantidade de informação transmitida pelos _pods_ é idêntica nas duas _workloads_, visto que os pedidos efetuados pelo cliente não requerem grande quantidade de dados, no entanto, caso a _workload complexa_ solicitasse certificados, veríamos um aumento significativo do débito a partir da 23:00.

Por outro lado, a análise do débito recebido dá a entender que _workload simples_ requer o envio de mais dados por parte do cliente, no entanto isso é falso, sendo que a justificativa para tal reside no número de utilizadores virtuais, ou seja, a _workload simples_ possui 300 _vus_, enquanto a _complexa_ apresenta somente _20_.

#code_grid(
  code1:
    image_block(
      imagem: image("../images/pod_ephemeral_storage.png", width: 100%),
      caption: [Utilização de armazenamento efémero]
    ),
  code2:
    image_block(
      imagem: image("../images/pod_volume.png", width: 100%),
      caption: [Utilização de _volumes_]
    )
)

Aparentemente nenhum componente aplicacional faz um uso intensivo de armazenamento efémero, visto que os valores calculados são significativamente baixos, tendo sido registado um pico de 7 _Mib_. Por outro lado, a utilização de _volumes_ diz apenas respeito à base de dados, visto que os _pods_ do servidor aplicacional guardam as informações em _RAM_, e portanto faz sentido estarem fixados em 0 _Mib_.

== Nodes

O número de réplicas atribuídas ao servidor aplicacional é claramente insuficiente, dado que o consumo de _CPU_ dos _pods_ atinge o limite estabelecido pelo grupo (500 _millicores_), nesse sentido deve ser realizada uma análise dos _nodes_, a fim de perceber se é possível melhorar a qualidade do _deployment_.

#code_grid(
  code1:
    image_block(
      imagem: image("../images/vm_cpu.png", width: 100%),
      caption: [Consumo de _CPU_ pelos _nodes_]
    ),
  code2:
    image_block(
      imagem: image("../images/vm_memory.png", width: 100%),
      caption: [Consumo de memória pelos _nodes_]
    )
)

Dois dos _nodes_ apresentam uma utilização de _CPU_ a roçar o limite (2 _vCPU_), no entanto existe um terceiro que está claramente em subutilização, o que indica uma distribuição desigual da carga de trabalho. Por outro lado, a utilização de memória parece equilibrada, estando ainda distante do limite.

Tendo isto em mente, seria admissível aumentar a quantidade de réplicas do servidor aplicacional, sendo que isso iria oferecer uma melhor qualidade de serviço, e possivelmente equilibraria a carga entre os _nodes_.

== Cliente

Na perspetiva do _cluster_, as duas _workloads_ apresentam um comportamento relativamente semelhante face ao consumo de recursos, no entanto o cliente é regido por outras métricas de desempenho que efetuam uma distinção mais palpável entre os dois cenários.

=== Workload Simples

Esta _workload_ tem como principal objetivo testar as capacidades do servidor aplicacional e respetivas réplicas, como tal os pedidos são satisfeitos sem qualquer acesso a disco ou execução da lógica de negócio, como tal à partida são esperados _request rates_ elevados.

#image_block(
  imagem: image("../images/test_1_http_overview.png", width: 100%),
  caption: [_HTTP performance overview_]
)

Tendo em conta que existem 300 utilizadores virtuais, podemos especular que o _request rate_ não foi tão elevado quanto o esperado, além disso a resposta aos pedidos registou uma média de cinco segundos, o que é francamente baixo e indica uma sobrecarga do serviço.

Por outro lado, o _request failed rate_ manteve valores nulos ao longo do teste, significando assim que o serviço nunca chegou a ficar indisponível, apesar de ter alcançado um ponto onde os recursos estavam evidentemente saturados.

#code_grid(
  code1:
    image_block(
      imagem: image("../images/test_1_http_request_duration.png", width: 100%),
      caption: [_HTTP request duration_]
    ),
  code2:
    image_block(
      imagem: image("../images/test_1_http_request_receiving.png", width: 100%),
      caption: [_HTTP request receiving_]
    )
)

Numa outra análise, podemos constatar que 90% dos pedidos são satisfeitos abaixo dos dez segundos, o que é um valor extremamente satisfatório tendo em consideração a existência simultânea de 300 utilizadores virtuais. 

Por fim, denotámos que os valores obtidos para _request receiving_ são bastante baixos, tendo sido registada uma média de aproximadamente 50 milissegundos, daí conclui-se que o servidor aplicacional demonstrou elevada disponibilidade, e portanto os valores de _request durantion_ estão mais relacionados com o _delay_ da rede, do que propriamente com a incapacidade do serviço.

=== Workload Complexa

Numa utilização realista do serviço são efetuados pedidos que visam todos os componentes aplicacionais, mediante esse propósito esta _workload_ está especializada na criação de certificados, sem esquecer que para tal é necessário realizar _login_ de antemão.

Numa primeira versão desta _workload_, o cliente fazia _GET_ do certificado criado por si, no entanto reparámos que tal aquisição era muito penalizada pelos atrasos da rede, o que consequentemente diminuía o _request rate_ e levava a que fossem tiradas conclusões erradas acerca da qualidade do serviço.

#image_block(
  imagem: image("../images/test_2_http_overview.png", width: 100%),
  caption: [_HTTP Performance overview_]
)

Ao efetuarmos uma comparação com os resultados obtidos anteriormente, observamos que o _request rate_ baixou drasticamente, passando a ser efetuado somente um pedido por segundo, além disso os valores para _request failed rate_ também descolaram do zero e estão muito próximos do _request rate_, o que indica o insucesso de praticamente todos os pedidos realizados.

Perante tamanha quantidade de pedidos falhados, seria admissível pensar que o componente da base de dados é o principal responsável, no entanto os _dashboards_ relativos ao consumo de _CPU_ e memória indicam que o _pod_ do _Postgres_ não entrou em saturação com o início da _workload complexa_, o que parece um contracenso face aos resultados obtidos do lado do cliente.

#code_grid(
  code1:
    image_block(
      imagem: image("../images/test_2_http_request_duration.png", width: 100%),
      caption: [_HTTP Request Duration_]
    ),
  code2:
    image_block(
      imagem: image("../images/test_2_http_request_receiving.png", width: 100%),
      caption: [_HTTP request receiving_]
    )
)

O peso desta _workload_ reflete-se em todas as métricas capturadas, tendo o tempo de resposta aumentado consideravelmente para uma média de 30 segundos, valor que é totalmente inadmissível em cenários de produção. Diante tais resultados, podemos especular que o serviço está completamente saturado e começou a fazer uma gestão ineficiente dos recursos, no entanto a duração não é uma métrica fiável, visto ser fortemente condicionada pelas características da rede.

Por outro lado, o _request receiving_ mede o tempo necessário para o servidor dar _acknowledge_ de um pedido, o que oferece uma visão mais realista do estado do serviço, posto isto, ao serem registados picos de três segundos, podemos afirmar com alguma certeza que o serviço entrou em declínio.

Tal como mencionado anteriormente, as métricas recolhidas pelo _cluster_ e cliente são contraditórias face a esta _workload_, por um lado o _pod_ do _Postgres_ não revela um consumo exaustivo dos recursos e dá respostas eficientes ao servidor aplicacional, enquanto por outro o cliente vê um aumento considerável do tempo de resposta e pedidos falhados.

Provavelmente a resposta para tal incógnita encontra-se no servidor aplicacional, mas se assim fosse o cliente deveria constatar um _request receiving_ elevado na _workload simples_, já que os _pods_ do servidor aplicacional estavam no limite da sua performance. 