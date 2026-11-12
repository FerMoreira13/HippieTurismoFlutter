# Hippie Turismo

**Identidade visual:** verde-petróleo #146C70, coral #F4B49D e fundo areia #FAF7EF.

Código do aplicativo descrito em **Documentação Lab.EF (1) (1).docx**, com Flutter, servidor Node.js e Firebase Firestore. Interface em português.

## Ambientes

O projeto possui ambientes separados de desenvolvimento, testes e produção. O desenvolvimento usa a porta 3000, os testes usam a porta 3001 e produção usa Firebase com credenciais locais. Consulte [ENVIRONMENTS.md](ENVIRONMENTS.md) para iniciar pelo VS Code e configurar cada ambiente.

## Executar a demonstração

Requisitos: Flutter 3.47 (versão validada), Node.js 22.9 ou superior e emulador Android com SDK configurado. Para iOS: macOS, Xcode e CocoaPods. Projeto gerado e verificado com Flutter 3.47 / Dart 3.13. As versões resolvidas estão nos arquivos de lock.

Extraia o projeto em um caminho curto, como `C:\projetos\hippie-turismo`. Abra um terminal na pasta `backend`:

```powershell
npm.cmd ci
Copy-Item .env.example .env
npm.cmd start
```

A API inicia em `http://127.0.0.1:3000`. Abra outro terminal na pasta `mobile`:

```powershell
flutter pub get
Copy-Item config.example.json config.local.json
flutter run --dart-define-from-file=config.local.json
```

Na primeira tela, toque em **Primeira viagem? Crie sua conta**. Use dados de teste e senha com pelo menos oito caracteres. Não existe senha padrão. Explore as fotografias dos pontos turísticos, use a busca e os filtros, abra um local, salve favoritos, adicione paradas ao Meu roteiro e publique ou edite uma avaliação. O roteiro mostra a quantidade de paradas e o custo estimado das entradas, e fica salvo no aparelho para cada conta. No perfil, altere o raio de busca e autorize GPS e notificações.

O endereço `10.0.2.2` aponta do emulador Android para o computador. No simulador iOS, use `http://localhost:3000`. Em um Android por USB, execute `adb reverse tcp:3000 tcp:3000` e use `http://127.0.0.1:3000`. No iPhone físico, utilize uma API HTTPS acessível. Para teste por rede local, configure `HOST=0.0.0.0` no servidor e ajuste o endereço. Não exponha o modo demo na internet.

**Dados fictícios:** os locais e restaurantes do exemplo não são recomendações de viagem. As coordenadas ficam próximas a um centro de busca em Cuiabá apenas para testar distâncias. A interface identifica os exemplos. No modo demo, contas, favoritos e avaliações ficam em `backend/.data/demo.json` e sobrevivem ao reinício. Sessões ficam em memória: é necessário entrar novamente após reiniciar o servidor. A recuperação local usa código secreto gerado no cadastro ou no perfil. Lista, favoritos, avaliações e links de rota funcionam sem credenciais externas. O mapa incorporado requer uma chave Google.

## Estrutura

- `backend/src`: configuração, aplicação, domínios, banco, rotas e regras de distância.
- `backend/ARCHITECTURE.md`: camadas, coleções e processo de migrations.
- `backend/scripts`: importação de exemplos e atribuição de administrador.
- `backend/test`: testes de API.
- `mobile/lib/screens`: login, explorar, mapa, salvos, roteiro, perfil e detalhes.
- `mobile/lib/app_state.dart`: sessão, favoritos, roteiro persistente e acompanhamento de localização.
- `mobile/lib/alerts.dart`: notificações e intervalo de repetição.
- `mobile/android` e `mobile/ios`: projetos nativos e permissões.
- `mobile/test`: testes de regras e navegação.
- `firebase/firestore.rules`: bloqueio de acesso direto ao banco.
- `api.http`: exemplos de requisições.
- `VALIDACAO.md`: resultados dos testes e limites da validação.

## Configurar Firebase

1. Crie um projeto Firebase, ative **Authentication → Email/Password** e crie o **Cloud Firestore**.
2. Cadastre Android com `br.com.hippieturismo.hippie_turismo` e iOS com `br.com.hippieturismo.hippieTurismo`.
3. O Flutter usa `FirebaseOptions` explícito. Preencha `FIREBASE_API_KEY`, `FIREBASE_APP_ID`, `FIREBASE_MESSAGING_SENDER_ID` e `FIREBASE_PROJECT_ID` em `config.local.json`, usando os valores do aplicativo cadastrado. Android e iOS possuem `FIREBASE_APP_ID` diferentes. Altere `DEMO_MODE` para `false`.
4. No `.env` do backend, defina `DATA_MODE=firebase`, `GOOGLE_CLOUD_PROJECT` e `GOOGLE_APPLICATION_CREDENTIALS` apontando para uma credencial administrativa fora do projeto. Em infraestrutura Google Cloud, prefira a identidade do serviço e credenciais padrão. Nunca coloque credenciais administrativas no app ou no repositório.
5. Execute `npm run migrate` na pasta `backend` para registrar o esquema e importar o catálogo inicial. Depois publique regras e índices com `firebase deploy --only firestore:rules,firestore:indexes --project SEU_PROJETO` e reinicie a API.
6. Crie uma conta pelo app. As contas demo não são migradas. Opcionalmente, execute `npm run seed` para importar os exemplos fictícios; IDs existentes são preservados.

O Firebase Authentication gerencia as senhas reais. Não são gravadas senhas no Firestore. A API verifica tokens Firebase e revogação. O modo demo usa hash com salt e sessões opacas. As regras negam acesso direto de clientes ao banco; a API usa o Admin SDK e precisa de permissões IAM adequadas.

## Google Maps e restaurantes

Ative **Maps SDK for Android** e/ou **Maps SDK for iOS** no Google Cloud, configure faturamento e restrinja as chaves ao aplicativo e às APIs. Defina `MAPS_ENABLED=true` no JSON de configuração.

No Android, o projeto lê a propriedade Gradle `MAPS_API_KEY`. No PowerShell:

```powershell
$env:ORG_GRADLE_PROJECT_MAPS_API_KEY = 'SUA_CHAVE_ANDROID'
flutter run --dart-define-from-file=config.local.json
```

Restrinja a chave ao application ID e ao certificado SHA-1. HTTP é permitido somente no debug para teste local; release exige uma API HTTPS. A configuração de assinatura release deve ser feita antes da distribuição.

No iOS, crie `ios/Flutter/Maps.local.xcconfig` com `MAPS_API_KEY=SUA_CHAVE_IOS`. Os arquivos Debug e Release incluem essa configuração opcional. O AppDelegate inicializa o SDK pela chave. Restrinja-a ao bundle ID. Execute `pod install` na pasta `ios` e abra `Runner.xcworkspace`. O projeto usa iOS 15 ou superior e precisa da equipe e assinatura Apple para aparelho físico.

O GPS é obtido pela API nativa do dispositivo, via Geolocator; não depende da API de Geolocalização do Google. Rotas abrem o Google Maps externo por URL, com escolha de caminhada, carro ou transporte público. Não há navegação própria curva a curva.

Sem chave Places, o app mostra restaurantes cadastrados. Para busca real, ative **Places API (New)** e configure `GOOGLE_PLACES_API_KEY` somente no servidor, restrita à API e ao IP de saída quando possível. A busca utiliza raio de 3 km ao redor do local visitado, identifica a fonte e inclui atribuições. Se o serviço falhar, o catálogo local é exibido com aviso. O código não persiste os resultados Google. Confira os requisitos atuais de atribuição da plataforma antes da publicação comercial.

## Administração

No backend configurado para Firebase, execute `npm run admin -- UID_DO_USUARIO`. O script preserva outras custom claims e adiciona `admin: true`. O usuário deve sair e entrar novamente para atualizar o token.

O cadastro de locais/restaurantes e a moderação são feitos pelas rotas administrativas, com um token autorizado. Consulte `api.http`. O painel fica em Perfil → Administrar locais e relatos. No ambiente local, com o servidor parado, use `node scripts/local-admin.js email@exemplo.com` para autorizar uma conta existente. Reinicie o servidor e entre novamente.

## API

Todas as rotas de dados exigem `Authorization: Bearer TOKEN`. IDs usam letras, números, `_` ou `-`, até 128 caracteres. Cadastro/login Firebase são realizados pelo SDK Flutter; as rotas de cadastro/login da API existem apenas no modo demo.

| Método e caminho | Função |
| --- | --- |
| `GET /health` | Estado e modo; público |
| `POST /auth/register` e `/auth/login` | Autenticação demo |
| `POST /auth/logout` | Revoga sessão demo; Firebase também sai no cliente |
| `GET /me` | Perfil autenticado |
| `GET /places?lat=...&lng=...&radius=10000` | Locais próximos; raio em metros |
| `GET /places/:id` | Detalhes e avaliações |
| `PUT /places/:id/review` | Cria/edita uma avaliação por usuário |
| `GET /favorites` | Favoritos do usuário |
| `PUT /favorites/:id` | Salva um local |
| `DELETE /favorites/:id` | Remove favorito |
| `GET /restaurants?lat=...&lng=...&radius=3000` | Restaurantes próximos |
| `PUT /admin/places/:id` | Cria/substitui os campos do local |
| `PUT /admin/restaurants/:id` | Cria/substitui restaurante |
| `DELETE /admin/places/:id/reviews/:userId` | Modera avaliação |

## Dados e limites de consulta

- `places/{id}`: nome, descrição, categoria, endereço, lat/lng, geohash, horários, preço, imagem e indicador demo.
- `restaurants/{id}`: nome, cozinha, endereço, lat/lng, geohash e indicador demo.
- `places/{id}/reviews/{uid}`: nota, comentário, nome público, UID e data.
- `users/{uid}/favorites/{placeId}`: data de inclusão; o documento pai não precisa existir.

Nome/e-mail são mantidos no Firebase Authentication. O proprietário de uma alteração vem do token, nunca de um UID enviado no corpo pelo cliente.

A busca usa intervalos de geohash e filtro de distância real. Retorna até 100 locais, com até 500 leituras por intervalo. Favoritos e avaliações retornam até 500 registros. Catálogos densos e grandes volumes requerem paginação/agregações adicionais; a média mostrada usa as avaliações retornadas.

## GPS e alertas

GPS e notificações exigem consentimentos separados. A tela de perfil mostra coordenadas, precisão e horário da última posição. A precisão é moderada, com atualizações após aproximadamente 100 metros e consultas limitadas a uma por 20 segundos. Quando o app volta ao primeiro plano, ele verifica se o serviço e a permissão continuam ativos. Alertas são locais, a até 500 metros, com intervalo de seis horas por local/usuário salvo no aparelho, e no máximo um alerta por atualização. Tocar abre os detalhes.

O centro fictício não dispara alertas: é necessário ativar GPS real. Para testar, simule `-15.5989, -56.0949` no emulador e autorize ambos os recursos no perfil.

**O rastreamento é pausado quando o aplicativo fica inativo. Não há novos alertas com o app fechado.** Monitoramento contínuo requer implementação específica por plataforma e testes em aparelhos. A API não grava histórico de posições; os logs da infraestrutura precisam ser configurados na implantação.

## Testes e escopo

No backend: `npm test`. No mobile: `flutter analyze` e `flutter test`. Os testes de API cobrem autenticação, isolamento, avaliações, geolocalização e acesso administrativo. Os testes Flutter usam API simulada para regras e fluxos de interface.

Esta é uma implementação inicial para desenvolvimento e apresentação acadêmica. Contas Firebase/Google, catálogo real, implantação, assinatura e publicação nas lojas precisam de configuração. A meta de resposta inferior a três segundos e o consumo de bateria dependem de medições em rede/aparelhos reais. O modo offline permite consultar o último roteiro baixado e seus detalhes; mapas e envio de alterações exigem conexão. Não há reservas, pagamentos ou monetização. A dependência transitiva `uuid` foi atualizada por override à linha 11 para remover um alerta de segurança anterior, preservando a API v4 usada pelas bibliotecas Google.

## Referências técnicas

- [Validação de tokens Firebase](https://firebase.google.com/docs/auth/admin/verify-id-tokens)
- [Busca geográfica Firestore](https://firebase.google.com/docs/firestore/solutions/geoqueries)
- [Geolocator](https://pub.dev/packages/geolocator)
- [Google Maps Flutter](https://pub.dev/packages/google_maps_flutter)
- [Notificações locais 19.5](https://pub.dev/packages/flutter_local_notifications/versions/19.5.0)
- [Places Nearby Search](https://developers.google.com/maps/documentation/places/web-service/nearby-search)



## Novas funcionalidades de viagem

Consulte [o guia das oito melhorias](FEATURES.md) para testar recuperação de acesso, informações verificáveis, planejamento por tempo/orçamento, transportes, offline, fotos, compartilhamento e painel administrativo, incluindo limites e validação.
