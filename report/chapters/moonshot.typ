= Arquitetura Moonshot

A aplicação _Moonshot_ segue o padrão arquitetural _multilayer_, como tal as responsabilidades de armazenamento e lógica de negócio estão claramente separadas, sendo que o componente do nível _N_ age como cliente e fornecedor dos níveis _N-1_ e _N+1_ respetivamente.

#figure(
  image("../images/moonshot.png", width: 90%),
  caption: [Arquitetura da aplicação _Moonshot_],
)

Tendo isto em mente, todos os componentes (sistema de ficheiros, base de dados e servidor aplicacional) apresenta-se como um ponto único de falha e contenção, visto a falha de qualquer um deles impossibilita o correto funcionamento da aplicação, e em consequência disso não existem garantias de _availability_ e _dependability_.

Muito sucintamente, a aplicação _Moonshot_ não está prepara para lidar com cenários de _stress_ e tolerância a faltas, algo que não resulta diretamente dos componentes utilizados, mas sim da forma como estão organizados.

== Servidor Aplicacional

Este componente tem como responsabilidade gerir a lógica de negócio e responder aos pedidos _HTTP_ dos clientes, como tal pode ser muito penalizado em cenários de _stress_ onde é necessário dar resposta a milhares de pedidos em simultâneo, além disso, como está implementado em _python_ sofre uma penalização de performance ainda maior.

== Base de Dados

Por norma estes componentes são bastante eficientes, no entanto a necessidade de garantir a consistência dos dados revela-se como um forte inibidor da sua distribuição, algo que seria necessário para diminuir o impacto de executar milhões de operações de _io_. 

== Armazenamento

Nalgum momento, todas as aplicações que requerem estado persistente irão precisar deste componente, sendo que a escolha do equipamento de armazenamento depende naturalmente das _workloads_ desejadas, uma vez que o _Moonshot_ está especializado na criação de certificados, isso pode indicar _workloads_ de _backup_, pelo que os _HDD_ e _SSD_ são possivelmente os mais adequados.

