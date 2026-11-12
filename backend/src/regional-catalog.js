import {readFileSync} from 'node:fs';
import {placeSchema} from './domains/place.js';

// Identidade dos locais consultada em fontes oficiais. Coordenadas são referências
// aproximadas; operação, acessibilidade e preços não confirmados ficam sinalizados.
const publicSpaces = new Set(['orla-do-porto', 'centro-historico-cuiaba', 'chapada-praca-dom-wunibaldo', 'chapada-veu-de-noiva', 'chapada-cidade-de-pedra', 'parque-mae-bonifacia']);
export const regionalPlaces = JSON.parse(readFileSync(new URL('./regional-catalog.json', import.meta.url), 'utf8')).map(item => ({
  id: item.id,
  ...placeSchema.parse({
    ...item,
    description: item.description + ' Localização aproximada para referência; confirme o acesso antes de traçar a rota.',
    hours: 'Consulte os horários e a liberação de acesso no site oficial antes da visita.',
    price: 0,
    priceKnown: publicSpaces.has(item.id),
    website: item.website ?? 'https://hmg.camaracuiaba.mt.gov.br/pontosturisticos',
    source: item.id.startsWith('chapada-') || item.id === 'complexo-salgadeira' ? 'Prefeitura de Chapada dos Guimarães / ICMBio' : 'Prefeitura e Câmara Municipal de Cuiabá / Sema-MT',
    status: 'unverified',
    demo: false,
  }),
}));
