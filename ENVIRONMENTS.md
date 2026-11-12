# Ambientes do Hippie Turismo

O projeto possui três ambientes independentes.

| Ambiente | Aplicativo | Servidor | Uso |
| --- | --- | --- | --- |
| Desenvolvimento | `config.development.json` | `.env.development`, porta 3000 | Desenvolvimento diário e emulador |
| Testes | `config.test.json` | `.env.test`, porta 3001 | Testes automatizados e conferência isolada |
| Produção | `config.production.json` | `.env.production`, porta 8080 | Aplicativo publicado e Firebase real |

## Abrir no VS Code

Abra a pasta `mobile` no VS Code. Na área **Executar e Depurar**, escolha **Hippie Turismo - Desenvolvimento Android** e pressione **F5**. O VS Code inicia o servidor de desenvolvimento e abre o aplicativo no emulador `emulator-5554`.

Se o identificador do emulador mudar, execute `flutter devices` e altere `deviceId` em `mobile/.vscode/launch.json`.

## Desenvolvimento

O ambiente vem pronto com dados demonstrativos, sem credenciais externas.

```powershell
cd "C:\Users\Fernanda Moreira13\Documents\Codex\2026-09-03\mon\outputs\hippie-turismo\backend"
npm.cmd run start:dev
```

Em outro terminal:

```powershell
cd "C:\Users\Fernanda Moreira13\Documents\Codex\2026-09-03\mon\outputs\hippie-turismo\mobile"
flutter run -d emulator-5554 --dart-define-from-file=config.development.json
```

## Testes

O servidor de testes usa a porta 3001 para não conflitar com o ambiente de desenvolvimento.

```powershell
cd "C:\Users\Fernanda Moreira13\Documents\Codex\2026-09-03\mon\outputs\hippie-turismo\backend"
npm.cmd test
```

Para abrir manualmente o aplicativo no ambiente de testes, escolha **Hippie Turismo - Testes Android** no VS Code.

## Produção

Crie os arquivos locais a partir dos exemplos:

```powershell
cd "C:\Users\Fernanda Moreira13\Documents\Codex\2026-09-03\mon\outputs\hippie-turismo"
Copy-Item backend\.env.production.example backend\.env.production
Copy-Item mobile\config.production.example.json mobile\config.production.json
```

Preencha o domínio HTTPS, as informações do Firebase e o caminho da credencial do servidor. Os dois arquivos reais de produção são ignorados pelo Git.

Depois de configurar Firebase, execute as migrations e inicie o servidor:

```powershell
cd backend
npm.cmd run migrate:prod
npm.cmd run start:prod
```

No VS Code, escolha **Hippie Turismo - Produção Android** para gerar e abrir a versão release.

## Conferência

Na pasta `backend`, execute `npm.cmd run env:check`. O comando confirma nomes, modos, portas e endereços dos três ambientes.
