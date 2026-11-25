# Hippie Turismo
## Documentação completa do projeto

**Da concepção à entrega final do MVP**

Universidade do Estado de Mato Grosso - UNEMAT

Ciência da Computação

Laboratório de Engenharia de Software

**Responsável pela consolidação:** Fernanda Alves Moreira

**Equipe citada na documentação inicial:** Alexandre Assis, Fernanda Alves e Wesley Menezes

**Ano:** 2026

**Versão consolidada:** 1.0 - 11 de novembro de 2026

**Entrega acadêmica prevista:** 12 de novembro de 2026

**Repositório:** https://github.com/FerMoreira13/HippieTurismoFlutter

Este relatório reúne a definição do produto, requisitos, experiência do usuário, arquitetura, desenvolvimento, sprints, testes e preparação da entrega. O incremento passou pelos testes automatizados registrados, enquanto integrações nativas e validação com usuários mantêm pendências explicitadas ao longo do documento.

<!-- PAGE -->

## Sumário e orientação de leitura

| Parte | Conteúdo | Página |
| Apresentação | Capa e identificação | 1 |
| Orientação | Sumário e base documental | 2 |
| Concepção | Problema, justificativa e objetivos | 3 |
| Pessoas | Público, persona e mapa de empatia | 4 |
| Produto | Lean Canvas e hipótese de valor | 5 |
| Escopo | Jornada, MVP e evolução do recorte | 6 |
| Requisitos | Funcionais e rastreabilidade | 7 |
| Qualidades | Não funcionais e casos de uso | 8 |
| UX e UI | Organização e wireframes | 9 |
| Protótipo | Capturas históricas das telas | 10 |
| Arquitetura | Componentes e decisões técnicas | 11 |
| Dados | Modelo, persistência e segurança | 12 |
| Construção | Funcionalidades e contratos da API | 13 |
| Sprints 1 e 2 | Protótipo e preparação do núcleo | 14 |
| Sprint 3 | Integração e refinamento | 15 |
| Sprint 4 | Estabilização e planejamento da entrega | 16 |
| Qualidade | Execução e resultados automatizados | 17 |
| Aceite | Plano de testes manuais | 18 |
| Avaliação | Defeitos, usabilidade e riscos | 19 |
| Operação | Instalação e execução da demonstração | 20 |
| Encerramento | Entrega, evolução e conclusão | 21 |
| Referências | Fontes e rastreabilidade documental | 22 |

### Como interpretar as evidências
**Planejado** descreve uma intenção registrada. **Presente no código** indica implementação inspecionada. **Testado automaticamente** indica cenário executado e aprovado em 11/11/2026. **Pendente de validação manual** significa que ainda falta comprovação no ambiente de uso. Capturas antigas são apresentadas como histórico visual.

Os registros iniciais não constituem uma cronologia completa de commits. As datas das atividades e as datas de validação são distintas. O relatório não atribui execução a reuniões sem ata, nem transforma dependências instaladas em integrações comprovadas. As referências [1] a [11] são identificadas na página 22.

<!-- PAGE -->

## 1 Concepção do projeto

### 1.1 Problema e contexto
Durante uma viagem, o visitante costuma alternar entre mapas, sites, redes sociais e recomendações para encontrar atrações, horários, preços e rotas. Esse esforço exige que ele saiba o que pesquisar e pode fazer com que locais próximos passem despercebidos. O Hippie Turismo foi proposto para concentrar informações e usar o contexto de localização como apoio à descoberta. [1][2]

**Questão orientadora:** como facilitar a descoberta de pontos turísticos e informações úteis durante uma viagem, reduzindo a necessidade de pesquisas manuais?

### 1.2 Justificativa
A proposta organiza o caminho entre descobrir uma atração, compreender suas condições de visita e abrir uma rota. O foco em mobilidade favorece consultas curtas e decisões durante deslocamentos. A divulgação de atrações locais é um benefício esperado, sem medição de impacto econômico ou adesão comercial neste projeto.

### 1.3 Objetivo geral
Desenvolver um aplicativo móvel que utilize localização autorizada e um catálogo de atrações para apoiar a descoberta turística e o planejamento de visitas.

### 1.4 Objetivos específicos
- Consultar atrações por proximidade e categoria.
- Mostrar descrição, localização, horários e valores, sinalizando o que não foi confirmado.
- Abrir rotas em um aplicativo de mapas compatível.
- Permitir guardar locais e organizar paradas.
- Oferecer avaliações e informações complementares sobre restaurantes.
- Tratar indisponibilidade de rede, permissões e serviços sem bloquear toda a exploração.

### 1.5 Natureza da entrega
O produto é um MVP acadêmico. O incremento atual contém Flutter/Dart, uma API Node.js e alternativas de persistência local e Firebase. A apresentação demonstra o comportamento disponível e seus limites; não equivale à publicação em lojas ou à operação de um serviço comercial.

### 1.6 Apoio de inteligência artificial
Os documentos de concepção e blueprint preveem ChatGPT como apoio à elaboração, revisão e explicação de código, requisitos, documentação e testes. A IA não integra a experiência do turista como serviço de recomendação neste MVP. A avaliação técnica e acadêmica depende da revisão do material e das evidências pela responsável. [2][3]

<!-- PAGE -->

## 2 Público e compreensão das necessidades

### 2.1 Público principal
Turistas e visitantes que usam smartphones durante deslocamentos, incluindo viajantes independentes, mochileiros e famílias. O recorte prioriza quem deseja descobrir opções próximas com poucos passos e consultar informações essenciais antes de decidir uma visita. [1][2]

### 2.2 Persona de referência
**Mariana Costa** é uma persona fictícia de viajante independente, usuária de mapas e pesquisas no celular. Deseja aproveitar o tempo e conhecer locais sem depender de planejamento detalhado. As versões iniciais registram 30 e 29 anos; a diferença foi tratada como revisão da persona, sem impacto no requisito. Ela não representa uma participante real de pesquisa.

### 2.3 Mapa de empatia consolidado

| Dimensão | Síntese | Consequência para o produto |
| Vê | Informações dispersas, mapas, atrações e avaliações. | Reunir os dados essenciais nos detalhes do local. |
| Ouve | Sugestões de amigos, moradores e outros viajantes. | Oferecer avaliações como informação complementar. |
| Pensa e sente | Curiosidade, tempo limitado e receio de perder atrações. | Mostrar proximidade e reduzir passos até a rota. |
| Fala e faz | Pergunta o que há perto, pesquisa custos e consulta mapas. | Busca, filtros, preço sinalizado e ação Como chegar. |
| Dores | Pesquisa repetida e dados potencialmente desatualizados. | Fonte, data quando disponível e campo não confirmado. |
| Ganhos | Descoberta rápida, autonomia e passeio organizado. | Favoritos e roteiro vinculados à conta. |

### 2.4 Perfis relacionados
**Visitante ocasional:** precisa escolher rapidamente uma atração em uma visita curta. **Família em viagem:** compara informações e organiza paradas. **Administrador de conteúdo:** mantém locais e restaurantes e trata relatos sobre informações ou avaliações.

### 2.5 Necessidades convertidas em decisões
A localização é opcional e pode ser substituída por um centro de busca, permitindo explorar sem consentimento de GPS. Estados vazios orientam o próximo passo. O acesso à rota permanece junto ao local escolhido. Informações desconhecidas não são apresentadas como confirmadas.

### 2.6 Limite da pesquisa
O mapa de empatia é uma ferramenta de concepção documental. Não foram fornecidas entrevistas, amostras ou transcrições que comprovem pesquisa com o público. A utilidade esperada permanece uma hipótese a validar com participantes reais.

<!-- PAGE -->

## 3 Lean Canvas e hipótese de valor

### 3.1 Modelo do MVP acadêmico
O Canvas consolida a proposta das atividades iniciais. Seu objetivo é relacionar problema, solução e forma de validação, sem declarar receita, clientes ou tração comercial inexistentes. [1][2]

| Bloco | Definição no projeto | Forma proposta de observar |
| Problema | Descoberta limitada e informações turísticas fragmentadas. | Dificuldades relatadas durante tarefas de descoberta. |
| Segmentos | Turistas, visitantes e viajantes que usam smartphone. | Participantes com experiência recente de viagem. |
| Valor | Encontrar atrações próximas e consultar rapidamente dados úteis. | Conclusão da tarefa de encontrar e escolher um local. |
| Solução | Localização autorizada, catálogo, detalhes e rota. | Uso do fluxo de descoberta até Como chegar. |
| Alternativas | Pesquisa em mapas, buscadores, sites e redes sociais. | Comparar o esforço percebido com o fluxo proposto. |
| Canais | Apresentação acadêmica, demonstração e repositório. | Acesso ao projeto e feedback da demonstração. |
| Métricas | Detalhes abertos, locais salvos, rotas e intenção de reutilização. | Indicadores a coletar; telemetria de produto não comprovada. |
| Custos | Desenvolvimento, testes, atualização do catálogo e serviços externos. | Estimativa futura conforme infraestrutura e uso. |
| Receitas | Não há cobrança no MVP acadêmico. | Monetização depende de estudo posterior. |

### 3.2 Hipótese principal
Um aplicativo que relaciona a posição do viajante a atrações cadastradas pode tornar a descoberta e a decisão de visita mais simples. A hipótese depende de dados úteis, confiança nas informações, clareza das permissões e facilidade de navegação.

### 3.3 Diferencial proposto
O uso da proximidade como contexto complementa a pesquisa iniciada pelo usuário. O incremento também permite guardar intenções de visita e montar um roteiro, aproximando descoberta e planejamento.

### 3.4 Estratégia de validação
Observar se participantes conseguem encontrar uma atração, compreender informações, salvá-la e abrir uma rota. Medir conclusão e dificuldades antes de investir em recursos comerciais. Os resultados automatizados medem comportamento de software; não comprovam aceitação do produto pelo público.

### 3.5 Evolução comercial possível
Parcerias, publicidade ou recursos premium aparecem como possibilidades em materiais iniciais. Não estão implementados nem validados. Não há pagamento, compra de ingresso, reserva ou receita comprovada na entrega atual.

<!-- PAGE -->

## 4 Jornada e delimitação do MVP

### 4.1 Jornada antes do produto
A viajante chega a uma região, pesquisa opções em fontes diferentes, compara informações, escolhe uma atração e procura como chegar. O processo depende da iniciativa e do conhecimento prévio do que buscar. [1][2]

### 4.2 Jornada proposta e comportamento atual

| Momento | Ação esperada | Situação do incremento |
| Acesso | Criar conta ou autenticar. | Modo local e código de integração Firebase. |
| Contexto | Autorizar localização ou usar centro de busca. | Código trata permissão e mostra referência demonstrativa. |
| Descoberta | Consultar catálogo, busca e categorias. | Lista e filtro presentes; proximidade coberta na API. |
| Decisão | Abrir detalhes e conferir condições de visita. | Tela e fluxo cobertos por teste de widgets. |
| Planejamento | Guardar local e adicionar paradas. | Favoritos e roteiro com testes automatizados. |
| Deslocamento | Abrir rota externa no transporte escolhido. | URL testada; abertura no dispositivo pendente. |
| Pós-visita | Avaliar ou relatar informação incorreta. | Implementação disponível e cenários da API testados. |

### 4.3 Recorte inicial
As atividades 1 e 2 priorizavam autenticação, localização, base mínima de atrações, proximidade, sugestão/notificação, detalhes e rota. Avaliações e favoritos apareciam como evolução ou recurso secundário; a Atividade 2 deixava avaliações fora do núcleo obrigatório. [1][2]

### 4.4 Escopo ampliado do incremento
O código atual acrescenta favoritos persistidos no backend, avaliações, roteiro por tempo e orçamento, consulta offline, recuperação local de acesso, fotos e relatos, compartilhamento e painel administrativo. Essas ampliações são registradas como evolução disponível, sem afirmar em qual sprint cada linha de código foi criada.

### 4.5 Limites preservados
Ficam fora da entrega: reservas, pagamentos, chat, rede social, publicidade, versão premium, recomendação por IA, realidade aumentada e navegação própria curva a curva. Notificações com o app fechado também não fazem parte da implementação atual.

### 4.6 Controle de mudanças
O núcleo de aceite continua sendo acesso, descoberta, detalhes e apoio à visita. Recursos adicionais não substituem a necessidade de testar GPS, mapa e rotas no ambiente da apresentação. Mudanças tardias devem priorizar defeitos bloqueantes e recuperação de erros.

<!-- PAGE -->

## 5 Requisitos funcionais consolidados

### 5.1 Convenção de rastreabilidade
A numeração RF mudou entre documentos: por exemplo, RF08 designa rota na Atividade 2 e avaliação em outra matriz do projeto. Para evitar equivalências incorretas, esta consolidação usa **RC** como identificador próprio. As referências originais continuam válidas em seus documentos. [2][7]

| ID | Requisito consolidado | Evidência e condição de aceite |
| RC01 | Cadastrar, autenticar e sair da conta. | API local testada; Firebase real pendente de configuração e teste. |
| RC02 | Solicitar localização e tratar negação ou serviço desligado. | Código de permissões presente; teste nativo pendente. |
| RC03 | Consultar atrações por distância e raio. | Regras de proximidade e busca regional aprovadas na API. |
| RC04 | Exibir mapa e marcadores quando configurados. | Integração e alternativa de lista presentes; mapa real pendente. |
| RC05 | Alertar sobre atração próxima elegível. | Regra de raio/intervalo testada; recebimento nativo pendente. |
| RC06 | Consultar descrição, endereço, horário e valor. | Detalhes cobertos em widget; preço desconhecido testado. |
| RC07 | Abrir rota externa para o destino escolhido. | Parâmetros de URL testados; abertura real pendente. |
| RC08 | Buscar por termo e categoria no catálogo. | Filtro presente no código; cenários manuais pendentes. |
| RC09 | Incluir, remover e consultar favoritos da conta. | Isolamento e persistência testados na API. |
| RC10 | Publicar e editar uma avaliação por usuário/local. | Autoria, nota e edição sem duplicação testadas. |
| RC11 | Consultar restaurantes próximos e identificar a fonte. | Catálogo e fallback testados; serviço Google real pendente. |
| RC12 | Montar roteiro respeitando tempo e orçamento informado. | Regras, duplicatas e ordem testadas no Flutter. |
| RC13 | Baixar e consultar roteiro offline com restrição de escrita. | Reabertura do estado e bloqueio de API testados. |
| RC14 | Recuperar acesso e administrar conteúdo autorizado. | Recuperação, revogação e autorização testadas na API. |

### 5.2 Regras centrais
Favoritos e avaliações pertencem ao usuário autenticado. A autoria vem do token, não de um identificador livre no corpo enviado. Uma avaliação pode ser editada sem criar outra para o mesmo usuário/local. Alertas dependem de consentimentos separados para GPS e notificações.

### 5.3 Critério de implementação concluída
Uma função exige código integrado, tratamento de erro, cenário de teste apropriado e evidência do comportamento. Um teste de URL não comprova abertura de mapas, assim como um pacote instalado não comprova integração nativa.

<!-- PAGE -->

## 6 Qualidades e casos de uso

### 6.1 Requisitos não funcionais

| ID / qualidade | Critério de aceitação proposto | Evidência atual |
| Q01 / Usabilidade | Rótulos claros, tarefa identificável e estados vazios compreensíveis. | Interface e testes de widgets; pesquisa com usuários pendente. |
| Q02 / Segurança | Restringir dados e operações à conta e ao papel autorizado. | Testes de autenticação, isolamento e administração aprovados. |
| Q03 / Confiabilidade | Informar falhas e permitir recuperação sem travamento geral. | Tratamentos no código; fallback da API testado. |
| Q04 / Compatibilidade | Fluxos utilizáveis em smartphones e plataformas previstas. | Widgets em 390 x 844; Android físico e iOS pendentes. |
| Q05 / Desempenho | Carregamento visível e resposta adequada ao contexto de uso. | Meta histórica inferior a 3 s sem medição de aceite em rede real. |
| Q06 / Energia | Limitar atualizações e evitar rastreamento desnecessário. | Política de deslocamento e pausa; bateria não medida. |
| Q07 / Manutenção | Separar modelos, estado, comunicação e apresentação. | Estrutura modular atual e análise estática limpa. |
| Q08 / Privacidade | Localização opcional e ausência de credenciais no cache offline. | Código e documentação; operação de produção não auditada. |

### 6.2 Atores e permissões
**Visitante não autenticado:** acesso ao formulário e à consulta offline previamente salva. **Usuário autenticado:** catálogo, detalhes, favoritos, roteiro e avaliações. **Administrador:** manutenção de conteúdo e moderação, além dos recursos comuns. **Serviços externos:** autenticação Firebase, mapas e restaurantes quando configurados.

### 6.3 Casos de uso principais
**UC01 - Descobrir atração:** após entrar, o usuário escolhe centro de busca ou localização, filtra o catálogo e abre detalhes. Em falha de rede, recebe mensagem; sem GPS, pode usar a referência de busca.

**UC02 - Planejar passeio:** o usuário seleciona locais e consulta paradas, tempo estimado e custo de entradas. O planejamento evita duplicatas e locais fechados; preço desconhecido impede prometer adequação a um orçamento explícito.

**UC03 - Consultar e avaliar:** o usuário consulta informações, abre rota e registra avaliação. A API valida autenticação, nota e autoria. Administração e moderação exigem autorização própria.

**UC04 - Consultar offline:** após baixar dados com conexão, o usuário abre a cópia salva. A leitura não concede acesso autenticado à API; envio de alterações exige retorno ao modo online.

<!-- PAGE -->

## 7 Experiência do usuário e wireframes

### 7.1 Organização da informação
A navegação atual agrupa Explorar, Mapa, Salvos, Roteiro e Perfil. Detalhes centraliza informações e ações de cada atração. Acesso, recuperação e consulta offline antecedem ou complementam a área autenticada. O protótipo antigo descrito nas Sprints 2 e 3 tinha quatro abas; essa diferença representa versões distintas. [4][5][6]

### 7.2 Princípios de interação
Busca e categorias ficam próximas ao catálogo. Favoritar, adicionar ao roteiro e abrir rota aparecem no contexto do local. GPS e notificações dependem de escolhas separadas. Mensagens distinguem demonstração, carregamento e falhas.

![Wireframes históricos](../ux-ui/assets/wireframes.png)

Figura 1 - Wireframes preservados no material de UX/UI. Representam estruturas de telas, não evidência de testes ou de aparência final. Fonte: material do projeto. [6]

### 7.3 Identidade visual atual
O código `lib/app_theme.dart` define verde-petróleo #146C70, coral #F4B49D, fundo areia #FAF7EF e texto #243B3B. Materiais históricos usaram outras paletas. As capturas da próxima página preservam a aparência da versão documentada à época.

<!-- PAGE -->

## 8 Registro visual do protótipo

![Telas históricas do aplicativo](../ux-ui/assets/mockups-grid.png)

Figura 2 - Explorar, Mapa, Salvos, Roteiro e Perfil. Montagem existente no acervo de UX/UI; o documento de origem identifica capturas no emulador em 08/09/2026. Estas imagens são históricas e não comprovam a execução da versão atual ou a integração real de mapas. [6]

### 8.1 Leitura das telas
Explorar apresenta contexto de localização e catálogo; Mapa organiza a descoberta espacial quando disponível; Salvos reúne interesses; Roteiro organiza visitas; Perfil concentra controles da conta e permissões. O objetivo visual é tornar o próximo passo reconhecível e manter as ações ligadas à atração.

<!-- PAGE -->

## 9 Arquitetura e decisões técnicas

### 9.1 Evolução em relação ao blueprint
O blueprint inicial previa Flutter com serviços Firebase predominantemente serverless e FCM para notificações. O incremento atual inclui uma API Node.js/Express entre o app e os dados, com Firebase configurável e armazenamento local de demonstração. As notificações implementadas são locais; FCM permanece uma previsão do documento inicial, sem comprovação de uso atual. [3][7]

{{ARCHITECTURE}}

Figura 3 - Arquitetura consolidada a partir do código atual. Setas indicam comunicação e acesso a dados; integrações externas dependem de configuração. [7]

### 9.2 Responsabilidades
**Flutter/Dart:** telas, formulários, estado, roteiro e comunicação autenticada. **API Node.js/Express:** contratos HTTP, validação, autorização e regras de acesso. **Persistência:** adaptadores para o ambiente de demonstração e Firestore. **Plataforma:** localização, notificações, seleção de imagem e abertura de URLs.

### 9.3 Decisões e implicações
A base Flutter permite compartilhar código entre Android e iOS, mas não elimina testes específicos. A API centraliza regras e evita acesso direto do cliente ao banco. O modo local permite demonstração sem credenciais externas; o modo Firebase exige preparação própria. A abertura de mapas externos reduz o escopo de navegação.

### 9.4 Organização do repositório
`mobile/lib` contém modelos, API, estado, telas e widgets. `backend/src` reúne configuração, inicialização, domínios, rotas e banco. `backend/test` e `mobile/test` guardam testes. `firebase` contém regras/índices; `tools` auxilia ambientes; `ux-ui` preserva o material visual.

<!-- PAGE -->

## 10 Modelo de dados e proteção

### 10.1 Entidades e relacionamentos

| Entidade | Conteúdo principal | Relação e armazenamento |
| Usuário | Identificação, nome, e-mail e datas de perfil. | Conta possui favoritos e avaliações. |
| Atração | Nome, categoria, endereço, coordenadas, horário, preço e verificação. | `places/{id}`; referência de favoritos e roteiro. |
| Avaliação | Nota, comentário, autoria, visita e foto opcional. | `places/{id}/reviews/{uid}`; uma por usuário/local. |
| Favorito | Vínculo de interesse e data de inclusão. | `users/{uid}/favorites/{placeId}`. |
| Restaurante | Nome, cozinha, endereço e coordenadas. | `restaurants/{id}` ou resposta externa com fonte. |
| Relato | Informação incorreta ou denúncia para revisão. | Coleção de relatos e operações administrativas. |
| Roteiro e cache | IDs ordenados, detalhes baixados e instante da cópia. | Preferências/armazenamento local no aparelho. |
| Migration | Versão, identificação e execução de alteração. | `_migrations` e metadados de esquema. |

**Relações:** um usuário salva vários locais; um local pode ser salvo por vários usuários. Usuário e local delimitam uma avaliação. Um roteiro reúne atrações existentes, sem criar cópias permanentes do catálogo no servidor.

### 10.2 Persistência por ambiente
O desenvolvimento em modo demo salva contas e documentos em arquivo local, com substituição atômica na gravação. Sessões são mantidas em memória e exigem novo login após reiniciar o servidor. Testes usam isolamento apropriado. O armazenamento local é destinado a um processo; não está validado para múltiplas instâncias de produção.

### 10.3 Autenticação e autorização
No modo local, senhas são protegidas por hash e salt, e a recuperação usa código secreto. No modo Firebase, o Authentication gerencia credenciais e o backend valida tokens. Operações administrativas exigem papel autorizado. As regras Firestore negam acesso direto do cliente; a API depende das permissões do serviço.

### 10.4 Privacidade e limites
Credenciais, banco local, chaves e configurações privadas não foram enviados ao GitHub. O cache offline não guarda senhas ou tokens, mas pode ser consultado por quem usa o aparelho; o perfil permite removê-lo. O sistema não implementa histórico de trajetos como recurso; a configuração de logs da infraestrutura exige revisão na implantação.

<!-- PAGE -->

## 11 Desenvolvimento e integrações

### 11.1 Funcionalidades implementadas
O estado do aplicativo coordena sessão, catálogo, favoritos, roteiro, localização e consulta offline. A API do cliente envia token e transforma timeout, erro HTTP, falha de conexão e resposta inválida em mensagens. O formulário valida e-mail e senha antes da requisição.

O planejador considera distância, velocidade média e duração cadastrada. As estimativas não consultam trânsito em tempo real; orçamento considera entradas. O catálogo regional acrescenta atrações de Cuiabá e Chapada dos Guimarães sem substituir dados locais já existentes.

### 11.2 Contratos principais da API

| Método | Recurso | Finalidade |
| GET | `/health` | Estado público do serviço e modo ativo. |
| POST | `/auth/register`, `/auth/login`, `/auth/logout` | Cadastro/login local e encerramento de sessão. |
| POST | `/auth/recover`, `/auth/recovery-code` | Recuperação e rotação do código no modo local. |
| GET | `/me` | Perfil da conta autenticada. |
| GET | `/places`, `/places/:id` | Busca geográfica e detalhes de uma atração. |
| PUT | `/places/:id/review` | Publicar ou editar avaliação. |
| POST | `/places/:id/reports` | Enviar relato ou denúncia. |
| GET, PUT, DELETE | `/favorites` e `/favorites/:id` | Consultar, salvar e remover favoritos. |
| GET | `/restaurants` | Restaurantes próximos e fonte da resposta. |
| GET, PUT, DELETE | `/admin/...` | Listagem, manutenção e moderação autorizadas. |

### 11.3 Proximidade e alertas
A busca inicial usa raio regional configurável. GPS fornece posição nativa com permissão; a política limita atualizações e consultas. Alertas locais consideram até 500 metros, intervalo de seis horas por local/usuário e consentimento. O centro fictício não deve disparar alertas de localização real. O acompanhamento é pausado quando o aplicativo fica inativo.

### 11.4 Serviços externos
Mapa incorporado exige chave válida por plataforma. Rotas abrem Google Maps por URL. Restaurantes usam catálogo ou Places no servidor; em falha, há fallback sinalizado. Fotos são reduzidas no cliente e validadas no backend. Para escala de produção, mídia, consultas e agregações exigem evolução própria.

<!-- PAGE -->

## 12 Sprints 1 e 2

### 12.1 Sprint 1 e protótipo inicial
O material da Sprint 2 descreve a Sprint 1 como origem de um protótipo Flutter com Início, Explorar, Favoritos, Perfil, detalhes e dados locais. O código posteriormente analisado demonstrava navegação, cartões, abertura de detalhes e atualização de favoritos em memória. A data exata e a ata da Sprint 1 não estão disponíveis nas fontes consolidadas. [4][5]

**Aprendizado:** o protótipo permitiu discutir fluxo e hierarquia visual, mas não comprovou autenticação, banco remoto, GPS ou notificações reais. Sua utilidade foi reduzir incerteza sobre a navegação antes da integração.

### 12.2 Sprint 2 e núcleo do MVP
O planejamento priorizou autenticação, permissões/GPS, mapa e marcadores, persistência de atrações, proximidade, rota, notificações e tratamento de erros. O documento registra uma referência de 54 Story Points, sem capacidade ou velocidade comprovada. Estimativa não equivale a horas ou trabalho concluído. [4]

| Frente | Evidência da etapa histórica | Evolução disponível na revisão final |
| Interface | Protótipo navegável e dados fixos. | Telas modulares e fluxo em teste de widgets. |
| Autenticação | Pacotes identificados, integração não validada. | API local testada e integração Firebase configurável. |
| GPS e mapas | Dependências instaladas. | Código de permissões e mapa; validação nativa pendente. |
| Persistência | Fonte e comportamento ainda a comprovar. | Arquivo local e testes de persistência do backend. |
| Alertas e rotas | Preparação técnica, sem teste de execução. | Política/URLs testadas; entrega nativa pendente. |

### 12.3 Review e retrospectiva
O roteiro de review previa entrar, autorizar localização, visualizar atrações, abrir detalhes e rota e observar erros. Os campos históricos estavam a verificar; não há base para declarar aprovação de integração naquele momento.

Como ações de melhoria, a documentação propôs integrar uma função por vez, registrar evidências, modularizar o código e manter o backlog coerente com o incremento. A ausência de atas impede atribuir essas conclusões a feedback efetivamente coletado em uma reunião.

### 12.4 Relação com a sequência do projeto
As primeiras sprints estabeleceram interface e preparação técnica. A consolidação atual compara as evidências disponíveis de cada versão; não presume uma sequência de implementação por datas que o histórico Git recém-criado não registra.

<!-- PAGE -->

## 13 Sprint 3 e refinamento

**Marcos documentados:** refinamento em 22/10/2026; review e retrospectiva em 23/10/2026. O documento analisa uma versão anterior do protótipo e propõe evolução. [5]

### 13.1 Diagnóstico registrado
Navegação e detalhes estavam implementados, com três atrações estáticas e favoritos em memória. Busca aparecia sem filtragem. GPS, rota e notificações exibiam mensagens demonstrativas. Pacotes Firebase/Mapas/GPS não comprovavam o uso dos serviços.

### 13.2 Backlog e confronto com o incremento atual

| Item original | Critério planejado | Situação observada em 11/11 |
| S3-01 - Busca | Filtrar por nome, restaurar lista e exibir vazio. | Filtro presente; aceite manual pendente. |
| S3-02 - Dados | Distinguir demonstração e informação calculada. | Referência de busca e preço não confirmado sinalizados. |
| S3-03 - Simulações | Integração real ou indisponibilidade explícita. | Código de integrações; comprovação nativa ainda necessária. |
| S3-04 - Camadas | Separar modelos, dados e apresentação. | Modelos, API, estado, telas e widgets separados. |
| S3-05 - GPS | Tratar permissão e serviço desligado. | Tratamentos no código; teste de dispositivo pendente. |
| S3-06 - Favoritos | Preservar itens após reinício. | Persistência no backend testada; reabertura do app pendente. |
| S3-07 - Usabilidade | Textos legíveis, vazios e ações claras. | Widgets testados; avaliação com usuários pendente. |
| S3-08 - Testes | Documentar navegação, busca, favoritos e erros. | Plano de aceite e resultados consolidados neste relatório. |

### 13.3 Refinamento técnico
A recomendação de extrair modelo tipado e serviços foi refletida na estrutura atual. A distância passou a contar com regras baseadas em coordenadas e testes na API. Persistência e recuperação de erro ganharam implementações que não existiam no diagnóstico histórico.

### 13.4 Retrospectiva e continuidade
O material destaca navegação compreensível e cartões reutilizáveis como pontos positivos; concentração de lógica, dados fixos e ações simuladas como dificuldades. O encaminhamento para Sprint 4 foi estabilizar, corrigir defeitos, testar aceite e preparar a entrega final.

Os resultados atuais demonstram evolução em relação à versão descrita, mas não permitem afirmar que cada item estava concluído em 23/10. As ressalvas do documento histórico foram mantidas em sua interpretação.

<!-- PAGE -->

## 14 Sprint 4 e estabilização

**Marco acadêmico informado:** 30/10/2026. **Revisão e testes desta consolidação:** 11/11/2026. A atividade solicita funcionalidades finais, correções, tratamento de erros, refinamento, integração e preparação para validação. [8]

### 14.1 Objetivo e prioridade
Estabilizar o fluxo de autenticar, explorar, abrir detalhes, salvar e planejar visitas. Antes de ampliar o escopo, verificar os caminhos críticos e recuperar falhas. O produto deve demonstrar somente o comportamento confirmado no ambiente disponível.

| Prioridade | Frente de estabilização | Evidência ou próxima ação |
| Alta | Sessão, navegação, detalhes e avaliação. | Cenários API/widgets aprovados; conferir app com API. |
| Alta | Busca e estados vazios. | Implementação presente; executar aceite manual. |
| Alta | Persistência e isolamento. | API testada; demonstrar reabertura no aparelho. |
| Alta | GPS, mapa e rota. | Validar configuração, permissões e abertura nativa. |
| Alta | Testes e registro. | 16 API, 11 Flutter e análise estática aprovados. |
| Média | Offline, planejamento e administração. | Testes específicos aprovados; demonstração complementar. |
| Média | Acessibilidade e clareza. | Planejar rodada de tarefas e recursos assistivos. |

### 14.2 Critério de pronto
Código integrado e revisado; tratamento básico de falhas; teste apropriado executado; resultado registrado; ausência de falha bloqueante no fluxo demonstrado; backlog e limitações atualizados. GPS, mapa e notificações exigem evidência nativa para o aceite completo.

### 14.3 Planejado versus desenvolvido
O incremento atual supera o protótipo estático por conter API, persistência, planejamento e regras testáveis. Ainda não há evidência suficiente de integração ponta a ponta do app atual em dispositivo com todos os serviços. A documentação de Sprint 4 separa esses dois níveis de conclusão.

### 14.4 Correções e mudanças desta revisão
Foram documentados testes e entrega, e o projeto foi enviado ao GitHub. O backend respondeu ao health check após ser iniciado. O acesso final da conta ainda não foi confirmado. Não houve correção de código nesta revisão.

### 14.5 Review e retrospectiva final
O roteiro prevê apresentar o fluxo e confrontar critérios com evidências. A separação de regras facilita testes. Não há ata de review final ou avaliação docente registrada.

<!-- PAGE -->

## 15 Fase 4 e resultados de qualidade

**Marco acadêmico de qualidade:** 05/11/2026. **Execução técnica registrada:** 11/11/2026. Verificação avalia conformidade do software; validação avalia adequação às necessidades do usuário. [8][9]

### 15.1 Execução observada

| Comando e ambiente | Resultado | Alcance da evidência |
| Backend: `node --env-file=.env.test --test test/*.test.js` | 16 aprovados, 0 falhas. | API local, regras e persistência de demonstração. |
| Mobile: `flutter test --no-pub --reporter expanded` | 11 aprovados, 0 falhas. | Regras e widgets, com serviços simulados. |
| Mobile: `flutter analyze --no-pub` | No issues found. | Análise estática Flutter. |

Os comandos foram executados no Windows, nas pastas backend e mobile. O registro textual acompanha a entrega de Sprint 4. Os resultados são os observados nesta sessão e não foram retroativamente atribuídos às datas das aulas.

### 15.2 Cobertura da API
Distância e raio; cadastro/login e senha incorreta; autenticação obrigatória; validação de locais; favoritos privados e idempotentes; autoria/edição de avaliações; autorização administrativa; restaurantes e fallback; logout; persistência após reinício e recuperação; relatos/fotos; migrations; catálogo com fontes e atualização sem sobrescrever dados; busca regional.

### 15.3 Cobertura Flutter
Roteiro ordenado por conta; catálogo vazio sem apagar seleção; planejamento em tela pequena; preço desconhecido; orçamento, tempo e duplicatas; URLs com origem/destino/transporte; consulta offline após recriar estado e bloqueio da API; favorito demo e remoção após recarregar; intervalo dos alertas; validação do formulário; fluxo explorar, salvar, roteiro, detalhes e avaliação.

### 15.4 Limites dos resultados
Não houve falha nos cenários executados. Isso não comprova ausência geral de defeitos. Não foram executados testes atuais ponta a ponta em Android/iOS, serviços Firebase/Google reais, carga, bateria, desempenho em rede móvel ou auditoria de segurança. Testes de widgets usam API simulada.

### 15.5 Evolução dos registros
Os documentos antigos registravam contagens menores de testes em setembro. A referência válida para esta entrega é 16 testes API e 11 Flutter em 11/11. A diferença é evolução de cobertura, sem afirmar quais commits intermediários introduziram cada cenário.

<!-- PAGE -->

## 16 Plano de testes de aceite

Todos os casos abaixo precisam de **execução manual na versão atual** para produzir aceite ponta a ponta. Testes automatizados relacionados apoiam a avaliação, mas não mudam esse status.

| Caso | Procedimento | Resultado esperado |
| T01 - Acesso | Cadastrar conta de teste; sair; tentar senha incorreta e correta. | Feedback de erro e entrada apenas com credenciais válidas. |
| T02 - Telas | Percorrer abas e abrir duas atrações. | Conteúdo correspondente e retorno funcional. |
| T03 - Busca | Nome parcial, termo ausente, categoria e limpeza. | Filtro coerente, vazio orientado e lista restaurada. |
| T04 - Favoritos | Salvar/remover; reiniciar app e backend; entrar novamente. | Itens preservados na mesma conta, sem duplicatas. |
| T05 - GPS | Negar, bloquear, desligar serviço e depois conceder acesso. | Mensagem legível e posição atualizada ao autorizar. |
| T06 - Mapa e rota | Abrir mapa configurado e rota; provocar indisponibilidade. | Destino correto ou erro explícito sem falso sucesso. |
| T07 - Rede | Interromper API, consultar, restaurar e tentar de novo. | Sem travamento; mensagem e recuperação. |
| T08 - Avaliação | Publicar, editar e recarregar. | Uma avaliação da conta no local e texto atualizado. |
| T09 - Offline | Baixar, encerrar, desligar rede e abrir cópia salva. | Leitura disponível e escrita online bloqueada. |
| T10 - Alerta | Autorizar GPS/notificação e simular proximidade com app ativo. | Respeitar raio/intervalo e abrir detalhes ao tocar. |
| T11 - Administração | Tentar acesso com usuário comum e administrador. | Negar operação indevida e permitir a autorizada. |

### 16.1 Registro obrigatório de cada execução
Anotar caso, data, plataforma, versão/commit, configuração, pré-condições, passos, esperado, observado e resultado. Anexar arquivo de imagem ou vídeo. Usar conta de teste e ocultar dados pessoais e credenciais.

### 16.2 Organização das evidências
Nomes sugeridos: `T03-busca.mp4`, `T04-reinicio.mp4` e `T05-permissao-negada.png`. Vídeos são preferíveis para persistência e transições. As imagens históricas incluídas neste relatório não substituem essa coleta atual.

### 16.3 Correção e reteste
Quando um caso falhar, registrar defeito, reproduzir e localizar a causa. Após corrigir, repetir o mesmo cenário e a regressão relacionada. Só encerrar o item com resultado registrado. Sem evidência de reteste, manter o caso aberto.

<!-- PAGE -->

## 17 Defeitos usabilidade e riscos

### 17.1 Classificação
**Crítico:** impede o fluxo central ou expõe dados. **Alto:** bloqueia função essencial sem alternativa adequada. **Médio:** prejudica uma tarefa com alternativa. **Baixo:** problema visual/textual sem impedir a tarefa. Prioridade também considera frequência e impacto na apresentação.

| Registro | Constatação | Encaminhamento |
| DOC-01 / Médio | Documentos descrevem versões e requisitos com numerações distintas. | Consolidar com RC e distinguir histórico de estado atual. |
| VAL-01 / Alta | Faltam evidências atuais de integrações nativas. | Executar T05, T06 e T10 no dispositivo. |
| OPE-01 / Alta | Backend local precisou ser iniciado na revisão de acesso. | Health check respondeu; conferir inicialização antes da demonstração. |
| OPE-02 / A verificar | Usuária relatou mensagem de e-mail inválido. | Validador exige formato completo; acesso final ainda não confirmado. |

OPE-02 não foi classificado como defeito de código sem reprodução com uma entrada válida. Não houve correção e reteste de bug de aplicativo nesta revisão. Lacunas de evidência e configuração não são apresentadas como falhas comprovadas.

### 17.2 Validação de usabilidade proposta
Observar participantes do público em tarefas de encontrar uma atração, salvar, planejar e abrir rota. Registrar conclusão, ajuda, erros, dúvidas e satisfação. O plano histórico sugere cinco a oito participantes; trata-se de proposta, sem rodada realizada. Nenhuma nota SUS ou taxa de sucesso foi medida. [6]

### 17.3 Acessibilidade
Testar leitor de tela, ordem de foco, texto ampliado, rótulos, contraste e áreas de toque. A ausência de erro de layout nos widgets exercitados não comprova acessibilidade. Qualquer resultado deve identificar ferramenta, versão e condições de teste.

### 17.4 Riscos restantes
Chaves/serviços externos podem impedir mapas e Firebase. GPS e notificações variam conforme plataforma/permissão. Catálogo exige atualização. O arquivo local não foi projetado para múltiplas instâncias. Preços e tempos desconhecidos ou estimados precisam permanecer sinalizados. Alertas cessam com o app inativo. iOS, distribuição e operação em escala continuam pendentes.

### 17.5 Mitigação até a entrega
Priorizar login e fluxo central no mesmo ambiente da apresentação; verificar app com backend e preparar dados de teste. Demonstrar recursos externos somente após conferência. Se permanecer um bloqueio, registrar o impacto e mostrar a alternativa disponível de modo explícito.

<!-- PAGE -->

## 18 Instalação e execução da demonstração

### 18.1 Preparação
Usar Flutter/Dart compatíveis com o projeto, Node.js 22 ou superior, dependências instaladas e emulador Android ou aparelho configurado. O README histórico registra Flutter 3.47/Dart 3.13; o clone deve ser conferido com o SDK disponível. iOS requer macOS, Xcode e ferramentas Apple. [7]

### 18.2 Backend local
Na pasta `backend`, instalar dependências com `npm.cmd ci` e iniciar o ambiente com `npm.cmd run start:dev`. O arquivo de desenvolvimento fornecido usa demo, endereço local e porta 3000. Confirmar `http://127.0.0.1:3000/health`: a resposta esperada é status ok e modo demo.

O banco `.data/demo.json` contém dados locais e não faz parte do GitHub. Um clone novo não recebe contas, senhas ou favoritos do computador original. Criar uma conta pelo aplicativo em vez de presumir credenciais padrão.

### 18.3 Aplicativo Flutter
Na pasta `mobile`, executar `flutter pub get` e `flutter run --dart-define-from-file=config.development.json`. No emulador Android, `http://10.0.2.2:3000` aponta para o computador. No VS Code, a configuração de desenvolvimento inclui tarefa de inicialização do backend.

Em aparelho físico, o endereço precisa corresponder ao método de conexão adotado. A configuração do emulador não se aplica automaticamente ao celular. Não expor o modo demo como serviço público.

### 18.4 Acesso e recuperação
Usar e-mail completo, como `nome@exemplo.com`, e senha de pelo menos oito caracteres. O formulário rejeita e-mail incompleto antes de acessar a API. A conta deve existir no banco do ambiente usado. No modo local, a recuperação exige código secreto gerado no cadastro/perfil; no Firebase configurado, usa recuperação por e-mail.

### 18.5 Serviços opcionais e produção
Mapa incorporado exige chave Google por plataforma; Firebase exige configurações do app e credencial administrativa somente no servidor. Consultar os exemplos de produção e `ENVIRONMENTS.md`. Release requer API HTTPS e revisão de assinatura. Não incluir segredos no repositório.

### 18.6 Verificação rápida antes de apresentar
Conferir health check, dispositivo selecionado, ambiente correto, conta acessível, catálogo e detalhes. Depois verificar favoritos, roteiro e avaliação. Não reiniciar o backend no meio da sessão sem prever um novo login.

<!-- PAGE -->

## 19 Entrega final e continuidade

### 19.1 Artefatos disponíveis
Código Flutter e backend Node.js, testes, regras/índices Firebase, configurações de exemplo, material de UX/UI, relatório de Sprint 4 e registro textual de verificação. O projeto foi enviado ao GitHub em 11/11/2026, na branch main, com commit inicial **f19861c**. [9][11]

**Repositório:** https://github.com/FerMoreira13/HippieTurismoFlutter

Este relatório consolidado foi produzido depois desse commit. Sua presença no GitHub depende de um novo commit e envio; a confirmação de publicação anterior refere-se ao pacote já enviado.

### 19.2 Roteiro de apresentação
1. Explicar problema, público e hipótese de valor.
2. Mostrar login, catálogo, busca e detalhes com conta de teste.
3. Salvar local, organizar roteiro e publicar/editar avaliação.
4. Mostrar offline e administração se forem pertinentes ao tempo disponível.
5. Demonstrar GPS, mapa e rota somente após confirmar a configuração.
6. Apresentar resultados dos testes e pendências de validação.

### 19.3 Checklist final
- [x] Documentação e escopo consolidados.
- [x] Testes automatizados e análise estática registrados.
- [x] Projeto existente enviado ao GitHub e commit remoto confirmado.
- [ ] Confirmar login e fluxo completo no ambiente da apresentação.
- [ ] Coletar evidências manuais das integrações nativas.
- [ ] Confirmar se a atividade exige vídeo, código compactado ou APK.
- [ ] Gerar e instalar APK, se exigido; não foi gerado nesta revisão.
- [ ] Anexar o relatório consolidado e enviar na plataforma acadêmica.

### 19.4 Próximas evoluções
Concluir aceite nativo, acessibilidade e testes com usuários; configurar serviços externos; medir desempenho e bateria; melhorar atualização do catálogo; preparar mídia e paginação para escala. Recursos comerciais devem depender da validação do núcleo e de planejamento próprio.

### 19.5 Conclusão
O Hippie Turismo evoluiu de uma proposta de descoberta contextual e protótipo de telas para um incremento com API, persistência e regras testadas. Os 16 testes da API e 11 Flutter, com análise estática sem problemas, sustentam os cenários exercitados. A conclusão integral do aceite depende do uso ponta a ponta, das integrações nativas e da avaliação com usuários. A entrega torna visível essa evolução e preserva os limites das evidências disponíveis.

<!-- PAGE -->

## 20 Referências e rastreabilidade

### 20.1 Fontes do projeto
**[1]** MOREIRA, Fernanda Alves. Hippie Turismo Atividade 1. 2026. Arquivo `Hippie_Turismo_Atividade_1_Fernanda_Alves_Moreira.docx`. Base de problema, objetivos, persona, empatia, Canvas e jornada.

**[2]** MOREIRA, Fernanda Alves. Atividade 2 Definição do Produto e MVP. Setembro de 2026. Arquivo `Atividade_2_Hippie_Turismo_Fernanda_Alves_Moreira.docx`. Base de recorte, histórias, requisitos e critérios de produto.

**[3]** MOREIRA, Fernanda Alves. Blueprint Técnico e Matriz de Decisões Arquiteturais. 2026. Arquivo `Blueprint_Tecnico_Hippie_Turismo.docx`. Representa a arquitetura planejada, anterior ao arranjo atual com API.

**[4]** Equipe Hippie Turismo. Sprint 2 Núcleo do MVP. 2026. Arquivo `Hippie_Turismo_Sprint_2_Nucleo_MVP_sem_capa.docx`. Descreve o antecedente da Sprint 1 e o planejamento de integração da Sprint 2; datas exatas não confirmadas.

**[5]** MOREIRA, Fernanda Alves. Hippie Turismo Documentação Sprint 3. Refinamento em 22/10/2026; review/retro em 23/10/2026. PDF de quatro páginas fornecido na conversa e documento de refinamento correspondente no acervo local.

**[6]** Projeto Hippie Turismo. Projeto UX UI. Arquivo `ux-ui/Hippie_Turismo_Projeto_UX_UI.docx`, roteiro de geração e imagens em `ux-ui/assets`. Fonte dos wireframes e capturas históricas, identificadas no material como registradas em 08/09/2026.

**[7]** Projeto Hippie Turismo. Código local e documentação técnica: `README.md`, `ENVIRONMENTS.md`, `FEATURES.md`, `VALIDACAO.md`, `backend/ARCHITECTURE.md`, `mobile/lib`, `backend/src` e testes. Inspeção em 11/11/2026; textos históricos confrontados com a versão atual.

**[8]** Enunciado da atividade fornecido pela responsável: Sprint 4 Desenvolvimento, Estabilização e Validação, marco de 30/10/2026; Fase 4 Qualidade de Software, marco de 05/11/2026.

**[9]** Projeto Hippie Turismo. Relatório Sprint 4 e Fase 4 e Registro de Verificação. Produzidos em 11/11/2026. Fontes: `mobile/output/entrega-final` e `mobile/output/pdf`.

**[10]** Documentação completa do sistema Hippie Turismo. Arquivo `Documentação Lab.EF.docx`. Fonte da identificação institucional e equipe histórica. Concepção confrontada com o escopo posterior.

**[11]** Repositório GitHub HippieTurismoFlutter. Envio e branch main confirmados por Git nesta sessão em 11/11/2026, commit f19861c. Endereço: https://github.com/FerMoreira13/HippieTurismoFlutter.

### 20.2 Critérios de consolidação
Versões antigas foram usadas como histórico, sem converter planos em resultados. A identificação institucional segue [10]; a responsabilidade pela consolidação segue as atividades individuais. Não foram acrescentadas atas, entrevistas, métricas de uso ou resultados de testes manuais inexistentes. Senhas e dados do banco local não fazem parte deste documento.
