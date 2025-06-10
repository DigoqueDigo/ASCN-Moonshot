#import "../funcs.typ": question, answer

= Questões

#question(
  title: [Questão - 1 A],
  question: [
Para um número crescente de clientes, que componentes da aplicação poderão constituir um gargalo de desempenho?
  ]
)

#answer(
  answer: [
A aplicação é constituída por apenas dois componentes: o servidor aplicacional e a base de dados. Segundo o nosso entender, para um número crescente de clientes, o servidor aplicacional rapidamente torna-se num fator limitante da aplicação. No entanto, para certos tipos de pedidos, podemos também constatar os tempos de resposta a serem severamente penalizados pela base de dados. Concluímos portanto que ambos os componentes podem ser um gargalo de desempenho, embora o mais preocupante seja o servidor aplicacional.
  ]
)

#question(
  title: [Questão - 1 B],
  question: [
Qual o desempenho da aplicação perante diferentes números de clientes e cargas de trabalho?
  ]
)

#answer(
  answer: [
Para um número relativamente pequeno de clientes simultâneos, o serviço é capaz de responder a todos os pedidos em tempo útil e sem qualquer problema, no entanto o aumento da carga leva a uma rápida saturação dos recursos e consequente indisponibilidade da aplicação.

Além disso, as cargas de trabalho também constituem um fator determinante no desempenho, visto que o GET de uma página estática é praticamente imediato, enquanto um POST geralmente requer acessos à base de dados e consequentes operações de io, sendo estas bastante penalizadoras.

Posto isto, workloads com centenas de utilizadores e operações que requerem consultas à base de dados, são ideais para colocar o serviço em stress e perceber quais os componentes que devemos priorizar.
  ]
)

#question(
  title: [Questão - 1 C],
  question: [
Que componentes da aplicação poderão constituir um ponto único de falha?
  ]
)

#answer(
  answer: [  
Tendo em conta que a aplicação Moonshot está montada sobre o padrão arquitetural multilayer, tanto o servidor aplicacional como a base de dados constituem um ponto único de falha e contenção, ou seja, sem o servidor aplicacional nenhum cliente consegue comunicar com a API pública, enquanto a falha da base de dados implica a impossibilidade de realizar queries sobre o armazenamento persistente.

Além disso, se considerarmos o sistema de armazenamento como um componente, também esse é um ponto único de falha, sendo que no pior dos cenários a sua indisponibilidade implica a perda permanente de toda a informação armazenada até ao momento.
  ]
)

#question(
  title: [Questão - 2 A ],
  question: [
Que otimizações de distribuição/replicação de carga podem ser aplicadas à instalação base?  
  ]
)

#answer(
  answer: [
Uma vez que o servidor aplicacional representa um gargalo de desempenho, e tendo sido pedido que nos focássemos num único componente da aplicação, decidimos que este devia ser escalado na horizontal, tendo por base políticas relativas à utilização média de CPU e memória, sendo que seria ideal explorar outras métricas como o número de clientes servidos em simultâneo.

Além disso, enquanto medida para otimizar a resposta aos pedidos, usamos um serviço do tipo Load Balancer para realizar uma distribuição justa da carga de trabalho ao longo das diversas réplicas. 

Por fim, embora não tenhamos conseguido escalar a base de dados, decidimos colocar o seu espaço de armazenamento sobre um disco SSD ao invés de HDD, visto que o primeiro apresenta menor latência e como tal a penalização das operações de io é atenuada.
  ]
)

#question(
  title: [Questão - 2 B],
  question: [
Qual o impacto das otimizações propostas no desempenho e/ou resiliência da aplicação?
  ]
)

#answer(
  answer: [
Ao serem disponibilizadas várias instâncias do servidor aplicacional, podemos garantir que este deixa de ser um fator limitante no desempenho da aplicação, sendo a carga de trabalho distribuída de modo a amortizar a utilização que cada cliente faz.

No entanto, não foi possível constatar tal comportamento através dos testes efetuados, visto que o número máximo de réplicas definidas pelo grupo continua a ser bastante baixo face à procura efetuada nos testes de caão de ameaças (ou threat modeling) é uma prática essencial na área da cibersegurança e do desenvolvimento de software. Sua importância reside em identificar, entender e mitigar potenciais vulnerabilidades antes que elas possam ser exploradas. Aqui estão algumas razões para sua relevância:rga. 

Numa outra perspetiva, a falha de uma réplica não afeta as restantes, o que aumenta a resiliência do serviço e não obriga o cliente a esperar pelo restart da réplica em questão caso existam outras disponíveis. 

Por fim, visto não termos escalado a base de dados, esta certamente passará a constituir um gargalo de desempenho, mas para verificar tal comportamento será necessário um número considerável de instâncias do servidor aplicacional.
  ]
)