# Melhorias de viagem — 24/09/2026

Implementadas no projeto `Documents/Codex/2026-09-03/mon/outputs/hippie-turismo`.

## Como testar

1. Entre com a conta existente. Em **Perfil**, gere e guarde seu código de recuperação local. Em produção Firebase, **Esqueci minha senha** envia a recuperação por e-mail.
2. Abra um local para consultar contato, site, acessibilidade, duração média, situação de funcionamento e data/fonte da conferência. Campos desconhecidos continuam indicados como não verificados. Use **Informar local fechado ou dado incorreto** para enviar um relato.
3. Em **Roteiro**, toque em **Planejar por tempo e orçamento**. Informe orçamento de entradas, minutos disponíveis e transporte. Locais fechados são excluídos. Uma seleção vazia não apaga o roteiro anterior.
4. **Abrir trecho** e os botões de rota permitem escolher caminhada, carro ou transporte público no Google Maps.
5. **Salvar para usar offline** baixa roteiro, favoritos e detalhes (incluindo avaliações e fotos). Após fechar e reabrir, toque em **Consultar roteiro baixado** na tela de entrada. Essa consulta não concede acesso à API. No perfil é possível apagar a cópia do aparelho.
6. Em **Avaliar**, acrescente data da visita e uma foto JPEG/PNG selecionada da galeria. Imagem reduzida para até 640 px e limitada a 130 KB no cliente; validação de formato/tamanho no servidor. Avaliações podem ser denunciadas.
7. **Compartilhar** oferece cópia do roteiro com links de navegação ou abertura do WhatsApp para o usuário escolher o destinatário e enviar. Não envia mensagens automaticamente.
8. **Perfil → Administrar locais e relatos** permite criar/editar locais e tratar denúncias. Nos detalhes, administradores podem remover avaliações após confirmação. Usuários comuns recebem HTTP 403 nas rotas administrativas.

## Persistência e administração

O servidor de desenvolvimento usa `backend/.data/demo.json` (ou `LOCAL_DATA_FILE`). Contas, hashes de senha, favoritos, avaliações, relatos e catálogo persistem entre reinícios. A escrita substitui o arquivo atomicamente; falha de leitura não apaga dados. Faça backup dessa pasta com o servidor parado. Esse armazenamento é para **um processo local**, não para múltiplas instâncias de produção. O modo de teste continua em memória.

A conta local de teste foi preservada com seu UID, favoritos e senha anterior; recebeu permissão administrativa para testar o painel. O banco está ignorado pelo Git. Sessões expiram e ficam em memória: após reiniciar o servidor, entre novamente. As contas agora permanecem. Contas antigas que já haviam sido apagadas pela versão anterior não podem ser recuperadas.

Para conceder administração a outra conta local existente, pare o servidor e execute na pasta backend:

```powershell
node scripts/local-admin.js email@exemplo.com
```

Depois reinicie. Em produção, continua valendo a custom claim Firebase configurada pelo script `npm run admin -- UID`.

## Limites explícitos

- O catálogo continua fictício. Nenhum horário, contato ou condição de acessibilidade foi inventado ou marcado como verificado.
- Tempos de deslocamento são estimativas pela distância geográfica com fator de percurso e velocidade média; não consultam trânsito ou transporte em tempo real. Visitas usam a duração cadastrada (60 min como padrão). Orçamento inclui apenas entradas, sem retorno, alimentação ou transporte.
- Offline não oferece mapa, navegação, restaurantes atualizados nem envio de avaliações. A cópia mais recente é acessível a quem usa o aparelho; use **Apagar roteiro baixado** para removê-la. Ações online exigem novo login. Não são armazenadas senhas ou tokens no cache offline.
- Recuperação local usa código secreto, rotativo e armazenado como hash. O código anterior deixa de funcionar após recuperação ou geração de um novo. A conta de teste já existente pode gerar seu primeiro código no perfil. Produção requer configuração Firebase e e-mail real.
- As fotos são pequenas e armazenadas junto à avaliação. Para grandes volumes, é necessário armazenamento de mídia dedicado e paginação. iOS tem a descrição de permissão configurada, mas só Android foi compilado neste ambiente Windows.
- Compartilhamento envia texto e links do Google Maps; não oferece edição colaborativa ou importação por link no app.

## Validação

- `npm test`: 13 testes aprovados, incluindo persistência após reinicialização, recuperação/revogação, autorização administrativa, relatos e fotos.
- `flutter test`: 10 testes aprovados, incluindo limites de orçamento/tempo, destinos/transportes, consulta offline após reabrir, bloqueio de escrita offline e tela pequena.
- `flutter analyze`: sem problemas.

Seleção de imagens baseada na [documentação oficial do image_picker](https://pub.dev/packages/image_picker).
