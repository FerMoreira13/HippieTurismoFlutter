# Hippie Turismo
## Sprint 4 e Fase 4 - Qualidade e entrega

**Responsável:** Fernanda Alves Moreira  
**Produto:** MVP de descoberta turística por proximidade  
**Marco acadêmico da Sprint 4:** 30/10/2026  
**Marco acadêmico de qualidade:** 05/11/2026  
**Revisão técnica e execução dos testes deste relatório:** 11/11/2026  
**Entrega prevista:** 12/11/2026

### 1. Apresentação e objetivo
Esta entrega reúne o planejamento de estabilização, a revisão do incremento disponível, os critérios de aceitação, a execução de testes e a avaliação das limitações do Hippie Turismo. A proposta é apresentar um MVP navegável e demonstrável, com tratamento de erros e evidências compatíveis com o que foi efetivamente verificado.

Os marcos de 30/10 e 05/11 são as datas informadas na atividade. A inspeção do código e os testes registrados aqui ocorreram em 11/11/2026. Não há registro suficiente para afirmar quais alterações foram implementadas exatamente em cada marco ou para atribuir retrospectivamente a eles os resultados atuais.

### 2. Base de comparação
A documentação da Sprint 3 descrevia um protótipo com dados estáticos, favoritos em memória e ações simuladas. A versão atual possui aplicativo Flutter organizado em arquivos de modelos, estado, API e telas, além de backend Node.js, armazenamento local de demonstração e integrações configuráveis.

A comparação comprova a evolução do produto disponível, mas não substitui histórico de commits, evidências no aparelho ou validação com serviços externos. As funcionalidades atuais já existiam no projeto inspecionado; nesta revisão foram executadas verificações e preparada a documentação de entrega.

### 3. Meta da Sprint 4
Estabilizar o fluxo principal de autenticar, explorar atrações, consultar detalhes, salvar favoritos e organizar um roteiro; revisar falhas de integração; definir testes reproduzíveis; preparar a apresentação e registrar pendências sem ampliar o escopo antes da entrega.

**Critério de conclusão:** testes automatizados aprovados, análise estática sem problemas, limitações descritas e roteiro de aceite disponível. A aprovação final das integrações nativas depende dos testes manuais indicados neste documento.

<!-- PAGE -->

## Planejamento e priorização da Sprint 4

### 4. Backlog de estabilização
As prioridades abaixo orientam a entrega final. Não representam horas executadas nem comprovação de conclusão histórica em 30/10.

| ID / prioridade | Entrega e critério de aceitação | Situação em 11/11 |
| S4-01 / Alta | Navegar, abrir detalhes, salvar e avaliar sem falha bloqueante no fluxo testado. | Fluxo coberto por teste de widgets aprovado. |
| S4-02 / Alta | Buscar por nome parcial; limpar restaura lista; termo ausente mostra estado vazio. | Filtro presente no código; aceite manual pendente. |
| S4-03 / Alta | Manter contas, favoritos e avaliações após reiniciar o servidor local. | Teste automatizado de persistência aprovado. |
| S4-04 / Alta | Informar falha de rede, resposta inválida e indisponibilidade de serviços. | Tratamentos presentes; cenários manuais pendentes. |
| S4-05 / Alta | Tratar GPS negado, bloqueado e desligado; abrir rota válida. | Código presente; execução no dispositivo pendente. |
| S4-06 / Alta | Executar testes, registrar resultados e preparar demonstração. | 16 testes API e 11 Flutter aprovados; análise limpa. |
| S4-07 / Média | Roteiro respeita orçamento/tempo; consulta offline bloqueia alterações online. | Cenários automatizados aprovados. |
| S4-08 / Média | Interface legível, ações claras e uso em tela pequena. | Fluxos em 390 x 844 testados; avaliação com usuários pendente. |

### 5. Escopo do MVP e decisões
O núcleo da apresentação será login local, catálogo, busca, detalhes, favoritos, avaliação e roteiro. Consulta offline e administração podem ser demonstradas como recursos complementares, conforme o tempo disponível.

Firebase, mapa incorporado, busca externa de restaurantes e notificações nativas exigem configuração e/ou execução específica. Sua presença no código não será apresentada como prova de integração validada em produção.

Pagamentos, reservas, publicação nas lojas, navegação própria curva a curva e alertas com o app fechado ficam fora do escopo desta entrega. Novas funcionalidades devem ceder prioridade à estabilidade e ao registro das evidências faltantes.

### 6. Planejado versus disponível
A separação de camadas proposta na Sprint 3 está refletida em `models.dart`, `app_state.dart`, `api.dart` e `screens/`. Busca, persistência e rotas possuem implementações atuais, superando as simulações descritas naquele documento. A principal pendência de aceite permanece a comprovação dos cenários nativos e das integrações externas no ambiente de demonstração.

<!-- PAGE -->

## Desenvolvimento, integração e refinamento

### 7. Arquitetura do incremento
O Flutter apresenta as telas e coordena sessão e estado. A classe de API envia requisições HTTP autenticadas. O backend valida dados e permissões, aplica regras e acessa o armazenamento. GPS, notificações e abertura de mapas usam recursos da plataforma.

**Fluxo:** telas Flutter → AppState / Api → backend Node.js → repositório local de demonstração ou Firestore configurado.

| Área | Evidência técnica inspecionada | Limite da comprovação |
| Modelos e interface | `lib/models.dart` e `lib/screens/` | Estrutura de código, sem auditoria completa de arquitetura. |
| Sessão e favoritos | `lib/app_state.dart`, rotas e testes da API | Flutter usa API simulada; backend testado localmente. |
| Comunicação e erros | `lib/api.dart` | Timeout de 12 s e mensagens para falha HTTP/rede/formato; aceite manual pendente. |
| Localização | `lib/app_state.dart` e `lib/alerts.dart` | Permissões e serviço tratados no código; plugins nativos não exercitados nesta revisão. |
| Rotas e planejamento | `lib/travel_actions.dart` e `lib/trip_planner.dart` | URLs e regras testadas; abertura do aplicativo externo pendente. |
| Persistência e offline | Backend local, preferências e cache do roteiro | Testes automatizados aprovados; reinício completo no aparelho pendente. |

### 8. Tratamento de erros e estabilidade
O cliente distingue falhas de conexão, espera excessiva e resposta inválida. A interface apresenta mensagens e permite nova tentativa. As rotas administrativas exigem autorização; dados pessoais e favoritos são vinculados ao usuário autenticado.

Quando Google Places está indisponível, a API mantém o catálogo local e sinaliza o fallback; esse comportamento foi aprovado em teste. A consulta offline permite ler dados baixados e bloqueia chamadas pela API, sem fornecer uma sessão autenticada online.

### 9. Refinamento da experiência
A busca aplica o termo ao nome e à descrição; categorias restringem o catálogo. O centro demonstrativo é identificado na interface, enquanto o uso de GPS mostra coordenadas e informações da posição. Valores de entrada não confirmados preservam essa indicação inclusive na serialização para consulta offline.

Há testes de formulário e roteiro em tela de 390 x 844. Isso fornece evidência limitada de layout nos fluxos exercitados. Leitor de tela, contraste, texto ampliado e compreensão por usuários reais ainda exigem avaliação própria.

<!-- PAGE -->

## Qualidade de software e evidências

### 10. Estratégia de verificação e validação
**Verificação:** análise estática, testes de regras, testes de widgets e integração HTTP da API, para conferir o comportamento implementado. **Validação:** execução das tarefas de uso e confirmação de que o MVP atende à necessidade do usuário. Os testes automáticos apoiam a qualidade; não substituem o aceite no dispositivo nem a avaliação com usuários.

### 11. Execução registrada em 11/11/2026

| Verificação | Resultado observado | Escopo |
| Backend: `node --env-file=.env.test --test test/*.test.js` | 16 aprovados; 0 falhas. | Testes locais da API e persistência de demonstração. |
| Mobile: `flutter test --no-pub --reporter expanded` | 11 aprovados; 0 falhas. | Regras e widgets com simulações e preferências de teste. |
| Mobile: `flutter analyze --no-pub` | No issues found. | Análise estática do projeto Flutter. |

Os comandos foram executados nas pastas `backend` e `mobile`, respectivamente. A análise e os testes Flutter precisaram de acesso ao cache do SDK em `C:/develop/flutter`. A instalação de bibliotecas para produzir este relatório não altera dependências do aplicativo.

### 12. Cobertura observada
**API:** distância e raio; cadastro/login e senha incorreta; exigência de autenticação; validação de locais; favoritos privados e idempotentes; autoria e edição de avaliações; acesso administrativo; restaurantes e fallback; logout; persistência após reinício e recuperação de acesso; relatos/fotos; migrations; fontes do catálogo e atualização sem sobrescrever dados existentes; busca regional.

**Flutter:** ordem e persistência de roteiro por conta; preservação de seleção com catálogo vazio; planejamento em tela pequena; preço desconhecido e limites do orçamento; tempo, transporte e duplicatas; parâmetros das URLs de rota; consulta offline após recriar o estado e bloqueio de API; favorito demo e remoção após recarregar; intervalo de alertas; formulário; fluxo explorar → salvar → roteiro → detalhes → avaliar.

### 13. Interpretação dos resultados
Não houve falha nos cenários automatizados executados. Isso não significa ausência de defeitos no produto inteiro. Não foram executados nesta revisão testes ponta a ponta em Android/iOS, integração real Firebase/Google, medição de bateria, desempenho em rede real, testes de carga ou auditoria de segurança.

Os testes de widgets usam dados simulados. A persistência após reinício é comprovada pelo teste do backend local, não por vídeo de encerramento e reabertura do aplicativo. As duas evidências devem ser apresentadas com essa distinção.

<!-- PAGE -->

## Plano de aceite, usabilidade e evidências manuais

### 14. Roteiro de testes funcionais e de integração
Todos os casos abaixo permanecem **pendentes de execução manual nesta revisão**. Registrar ambiente, resultado observado e arquivo de evidência; marcar aprovado somente após executar.

| Caso | Procedimento | Critério de aceitação |
| T01 - Sessão | Cadastrar conta de teste; sair; tentar senha incorreta e correta. | Mensagem clara para erro e entrada apenas com credenciais válidas. |
| T02 - Navegação e detalhes | Percorrer abas e abrir duas atrações. | Aba correta; detalhes correspondem ao item; retorno preserva uso. |
| T03 - Busca | Nome parcial, termo inexistente e limpeza do campo. | Lista filtrada; estado vazio; catálogo restaurado. |
| T04 - Favoritos | Salvar, remover e salvar novamente; reiniciar app e servidor; entrar. | Estado recuperado sem duplicatas na mesma conta. |
| T05 - GPS | Negar permissão, testar bloqueio permanente, desligar serviço e conceder acesso. | Feedback legível; navegação possível; posição atualizada ao autorizar. |
| T06 - Mapa e rota | Abrir mapa configurado e rota para destino válido; testar falha de abertura. | Destino correto ou erro legível, sem afirmar sucesso indevido. |
| T07 - Rede | Interromper API; carregar catálogo; restaurar API e tentar novamente. | Sem travamento; erro informado; recuperação por nova tentativa. |
| T08 - Avaliação | Publicar, editar e recarregar avaliação da conta. | Uma avaliação por usuário/local e conteúdo atualizado. |
| T09 - Offline | Baixar roteiro; fechar app; desligar rede; reabrir consulta offline. | Dados salvos acessíveis e alterações online bloqueadas. |
| T10 - Notificação | Autorizar GPS/notificações e simular proximidade com app ativo. | Alerta respeita raio/intervalo e abre o local ao tocar. |

### 15. Usabilidade e acessibilidade
Solicitar a uma pessoa que encontre uma atração, salve-a e monte um roteiro, sem orientar cada toque. Registrar conclusão, dificuldades, mensagens incompreendidas e sugestões. Testar texto ampliado e leitor de tela, verificando rótulos dos botões, ordem de foco e legibilidade. Nenhum participante ou resultado foi inventado para este relatório.

### 16. Organização das evidências
Usar nomes como `T03-busca.mp4`, `T04-reinicio.mp4` e `T05-permissao-negada.png`, com data, plataforma, versão/configuração, passos e resultado. Preferir contas de teste e ocultar dados pessoais. Para persistência e transições, um vídeo é mais informativo que uma imagem isolada. Não há capturas do aparelho anexadas a esta revisão.

<!-- PAGE -->

## Defeitos, correção, reteste e riscos

### 17. Classificação de defeitos
**Crítico:** impede o fluxo principal ou expõe dados indevidamente. **Alto:** bloqueia uma função essencial sem alternativa adequada. **Médio:** prejudica uma função com alternativa disponível. **Baixo:** problema visual ou textual que não impede a tarefa. Prioridade considera também prazo, frequência e impacto na apresentação.

### 18. Registro desta revisão

| ID / tipo | Constatação | Tratamento e situação |
| DOC-01 / documental / Médio | Sprint 3 descreve protótipo anterior, com busca e ações simuladas. | Relatório atual diferencia código, teste e pendência. Documento anterior preservado como histórico. |
| DOC-02 / documental / Médio | README, FEATURES e VALIDACAO da raiz contêm trechos de épocas diferentes e resultados antigos. | Utilizar este registro datado para os resultados atuais; arquivos antigos não foram reescritos nesta revisão. |
| VAL-01 / lacuna / Alta | GPS, mapa, notificações e reabertura no aparelho sem nova evidência. | Executar T04 a T06 e T09 a T10; anexar evidências antes de declarar aceite completo. |
| CFG-01 / dependência / Alta | Serviços externos dependem de ambiente, chaves e permissões. | Conferir configuração antes da apresentação e identificar recursos indisponíveis. |

Não foi reproduzido defeito de código que exigisse correção durante esta revisão. Não há ciclo de correção/reteste de bug de código a declarar. VAL-01 e CFG-01 são lacunas ou dependências, não falhas comprovadas. DOC-01 foi tratada neste relatório, sem alterar o documento histórico.

### 19. Procedimento para novos bugs
Registrar ID, versão, plataforma, passos, esperado, observado, severidade e evidência. Reproduzir e localizar a causa antes de alterar o código. Após a correção, executar novamente o cenário que falhou e a regressão relacionada. Fechar o defeito somente com resultado de reteste registrado; se não houver tempo, declarar a limitação e seu impacto.

### 20. Riscos e limitações restantes
As notificações dependem de consentimento e funcionam durante uso ativo; monitoramento com app fechado não faz parte do escopo. Mapas e Firebase reais exigem configuração e teste. O backend de demonstração com arquivo local é destinado a um processo, sem validação de concorrência de produção.

Tempos de viagem são estimados; orçamento considera entradas. Offline depende de download prévio e não oferece navegação/mapa completo. Preços, horários e acessibilidade não confirmados devem permanecer sinalizados. iOS, assinatura/distribuição, desempenho, consumo de bateria e validação com usuários permanecem pendentes.

<!-- PAGE -->

## Preparação da entrega e avaliação do MVP

### 21. Roteiro de demonstração
1. Apresentar o problema: descobrir atrações próximas e organizar visitas. Explicar se o ambiente é local ou integrado a serviços reais.
2. Entrar com conta de teste; mostrar catálogo, busca e detalhes. Distinguir centro demonstrativo de posição GPS.
3. Salvar e remover favorito; organizar roteiro e mostrar estimativa de entradas. Publicar ou editar avaliação.
4. Demonstrar consulta offline já baixada. Mostrar rota externa e GPS somente com configuração e resultado confirmados.
5. Apresentar os 16 testes da API, os 11 testes Flutter e a análise estática limpa; explicar as limitações e os testes manuais restantes.

### 22. Checklist de preparação
- [x] Inspecionar o incremento e comparar com a Sprint 3.
- [x] Definir prioridades, critérios de aceite e roteiro de testes.
- [x] Executar testes automatizados e análise estática em 11/11/2026.
- [x] Registrar resultados, lacunas e riscos sem retroagir as datas.
- [ ] Executar testes manuais críticos no aparelho/emulador e anexar evidências.
- [ ] Confirmar app e API funcionando juntos no ambiente da apresentação.
- [ ] Conferir o formato exigido pelo professor para código, vídeo e/ou APK.
- [ ] Se APK for exigido, gerar e instalar a compilação com configuração de rede apropriada; nenhum APK foi gerado nesta revisão.
- [ ] Revisar o material e enviar pela plataforma acadêmica.

### 23. Avaliação do incremento
O incremento apresenta funcionalidades além do protótipo descrito na Sprint 3 e passou pelos cenários automatizados disponíveis. O resultado sustenta uma demonstração acadêmica do fluxo testado, condicionada à conferência do ambiente do aplicativo com a API.

O aceite completo de GPS, mapas, notificações e serviços externos permanece pendente. A aprovação nos testes locais não comprova prontidão de produção ou publicação nas lojas. A prioridade até a entrega é comprovar o uso no dispositivo e registrar eventuais problemas encontrados, preservando o escopo.

### 24. Fontes e rastreabilidade
Base acadêmica: enunciado de Sprint 4 e Fase 4 fornecido pela responsável; documento “Hippie Turismo - Documentação Sprint 3.pdf”, quatro páginas, com refinamento em 22/10 e review em 23/10/2026.

Base técnica: código em `mobile/lib`, testes em `mobile/test` e `backend/test`, além de `backend/src`. `README.md`, `FEATURES.md` e `VALIDACAO.md` da raiz foram usados como contexto histórico; seus números antigos não substituem a execução atual.

Material preparado: este relatório em PDF e fonte Markdown editável, acompanhado de registro textual dos comandos e resultados. Não foram anexados vídeos, capturas do dispositivo, histórico de commits ou relatos de participantes.
