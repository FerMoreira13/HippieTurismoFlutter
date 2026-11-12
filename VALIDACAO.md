# Validação da entrega

Validação executada em 3 de setembro de 2026, no Windows, com Flutter 3.47.0 e Dart 3.13.0.

## Resultados

- API Node.js: **10 testes aprovados**, nenhum teste com falha.
- Flutter: **3 testes aprovados**, com regra de notificações, validação de formulário e fluxo de explorar → salvar → detalhes → avaliar.
- Análise estática Flutter: concluída sem problemas.
- Auditoria npm após atualização de dependência transitiva: **zero vulnerabilidades reportadas** naquele momento.
- Telas de exploração e detalhes renderizadas e inspecionadas em dimensão de 390 × 844. O teste de formulário também verificou ausência de erros de layout.

## Correspondência com a documentação

| Requisito | Implementação |
| --- | --- |
| RF01 Cadastro | Firebase Authentication; cadastro local em memória no demo |
| RF02 Login | Firebase ID token no modo real; sessão opaca no demo |
| RF03 GPS | Permissão, localização nativa e controle no perfil |
| RF04 Proximidade | Distância geográfica, raio configurável e busca por geohash no Firestore |
| RF05 Notificações | Alertas locais durante o uso, com permissão e intervalo por local |
| RF06 Detalhes | Descrição, categoria, horário, valor e endereço |
| RF07 Restaurantes | Catálogo local; integração opcional com Places API |
| RF08 Avaliações | Nota/comentário; uma avaliação editável por usuário/local |
| RF09 Favoritos | Inclusão/remoção autenticada e lista pessoal |
| RF10 Rotas | Abertura do Google Maps externo; mapa incorporado configurável |
| Administração | Rotas de cadastro/atualização e moderação, protegidas por custom claim |

## O que estes resultados não validam

Os testes Flutter usam uma API simulada; os testes Node usam o repositório em memória e servidores HTTP locais. O código de integração Firebase e Google foi incluído, mas não testado com contas externas, pois credenciais não foram fornecidas. As permissões, notificações nativas e serviços de mapas precisam de teste em Android e iOS reais. Não foi gerado ou validado APK/IPA, nem feita publicação.

Alertas com o app fechado, painel administrativo visual, funcionamento offline e agregações/paginação para grandes volumes não fazem parte desta implementação. A média usa até 500 avaliações retornadas. O limite de três segundos e o consumo de bateria exigem medição em infraestrutura e aparelhos reais. A configuração de assinatura release, políticas de acesso da hospedagem e catálogo real precisam ser concluídas antes da distribuição.

## Ampliação visual e de roteiro

Validado em 03/09/2026: quatro fotografias locais, fallback ilustrado, Cachoeira Serena no catálogo, roteiro persistente por conta, contador de paradas e custo estimado. Flutter analyze sem problemas; 3 testes Flutter e 10 testes da API aprovados.


## Paleta Jovem e Descomplicado

Aplicada em 04/09/2026: coral #FF4B4B, menta #06D6A0 e fundo #FAFAFA. Login, exploração e detalhes foram renderizados para inspeção visual. Flutter analyze sem problemas e 3 testes Flutter aprovados.


## Paleta Natureza Contemporânea

Aplicada em 04/09/2026: verde-petróleo #176B65, jade #AEB8A0, persimmon #FF5C34, fundo azul-gelo #F3FAFF e Plum Noir #351E28. Login, exploração e detalhes renderizados; Flutter analyze sem problemas e 3 testes aprovados.


## Integração de GPS ampliada

Validada em 04/09/2026: solicitação de permissão em uso, leitura de latitude/longitude e precisão, atualização por deslocamento, verificação ao retomar o app, busca por raio e exibição do status no perfil. Flutter analyze sem problemas e 3 testes aprovados.


## Fundação do banco e domínios

Validada em 05/09/2026: configuração centralizada, conexão Firestore, perfis, pontos turísticos, restaurantes, avaliações, favoritos, migrations 001 e 002 e registro de esquema. Sintaxe validada e 11 testes Node aprovados.

