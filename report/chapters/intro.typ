= Introdução

No âmbito da unidade curricular de _Aplicações e Serviços de Computação em Nuvem_ foi-nos solicitada a instalação de uma aplicação previamente desenvolvida, mais concretamente o _Moonshot_, que por basear a sua arquitetura no padrão _multilayer_ torna todos os seus componentes em potenciais pontos únicos de falha e contenção.

Tendo isto em mente, o processo de instalação adquire particular importância, visto que muitos dos problemas mencionados anteriormente poderão ser resolvidos ou mitigados se adotarmos estratégias como a replicação e o particionamento.

Além disso, os processos de _provisioning_ e _deployment_ apresentam um caráter repetitivo, pelo que a sua automatização torna-se extremamente desejável, permitindo assim que o _provider_ dedique o seu tempo a criar receitas e não tenha de acompanhar a execução das mesmas.

Em sequência disso, e enquanto forma de ajustar o poder computacional do _cluster_ à demanda do serviço, será dada primazia à elasticidade dos diversos componentes que constituem a aplicação, sendo de realçar que tal propriedade levanta enormes desafios quanto maior for a necessidade de manter o estado.

// TODO ????????????????????? so escalamos 1 componente (era o que o enunciado pedia tbm)
// tens de ser mais ambicioso bro, numa cena bem feita tens tudo escalado

Por fim, com o objetivo de testar as capacidades do _cluster_, convém proceder à sua monitorização e entender as respostas oferecidas face a testes de carga, dado que somente assim temos a certeza se a especificação está preparada para entrar na fase de produção. 

Em suma, ao longo deste relatório pretendemos apresentar todas as dificuldades com as quais nos fomos deparando, bem como explicar as estratégias que adotamos tendo em vista a resolução dos vários problemas. 