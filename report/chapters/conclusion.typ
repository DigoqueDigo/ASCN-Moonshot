= Conclusão

Tendo chegado a este ponto, e revendo o trabalho desenvolvido, julgámos ter atingido todos os objetivos propostos pela equipa docente, além de terem sido incluídos alguns extras (monitorização com _Prometheus_ e _Grafana_) e exploradas outras ferramentas que nunca foram abordadas em contexto de sala de aula (k6).

Numa primeira fase, o grupo focou-se em automatizar a instalação do serviço _Moonshot_ num _cluster_ de _Kubernetes_, sem que para isso tivesse em consideração problemas de escalabilidade ou disponibilidade, visto que o mais importante é ter um serviço ativo e funcional.

De seguida foram identificados alguns problemas arquiteturais, tais como pontos únicos de falha e contenção, sendo que a sua solução passou por munir o _deployment_ do servidor aplicacional com propriedades elásticas (escalar na horizontal), bem como colocar um serviço de _Load Balancer_ para distribuir a carga de forma justa.

Por outro lado, não demonstrámos capacidade para solucionar o gargalo da base de dados, tendo explorado várias hipóteses, cada uma com os seus defeitos. Ao escalar na horizontal é difícil manter uma visão consistente dos dados e evitar disrupção, enquanto escalar na vertical implica o _restart_ do _pod_ e consequente indisponibilidade temporária do serviço.

Seja como for, procurámos minimizar o impacto penalizador das operações de _io_, ao montar o armazenamento da base de dados sobre um disco _SSD_, sendo que por _default_ é oferecido um _HDD_.

Além disso, enquanto medida para verificar o comportamento do serviço face a cenários de _stress_, foram desenvolvidas duas _workloads_ com objetivos bem distintos, saturar o servidor aplicacional e base de dados, em consequência disso foram recolhidas diversas métricas que ajudaram a identificar gargalos e permitiram constatar a elasticidade do servidor aplicacional.

Por fim, e sem menosprezar o facto da _Google Cloud_ ter fornecido os recursos necessários ao desenvolvimento do projeto, devemos realçar que esta plataforma apresenta algumas deficiências, em particular a _UI_ de monitorização extremamente complexa (daí termos explorado o _Grafana_), e o custo demasiado elevado de manter o _cluster_ ativo (perdemos imenso tempo a ligar/desligar constantemente o _cluster_).