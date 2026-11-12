import {regionalPlaces} from './regional-catalog.js';
// Os quatro exemplos originais são fictícios; regionalPlaces contém atrações reais.
export const places = [
  ...regionalPlaces,
  {id:'cachoeira-serena', name:'Cachoeira Serena', category:'Natureza', lat:-15.5989, lng:-56.0949, address:'Circuito demonstrativo • Cuiabá', hours:'Exemplo: 8h às 17h', price:0, imageAsset:'assets/places/cachoeira-serena.png', description:'Cachoeira fictícia cercada por mata, com trilha leve e um poço de águas claras. Criada para demonstrar a descoberta de passeios de natureza no aplicativo.', demo:true},
  {id:'casa-memorias', name:'Casa das Memórias', category:'História', lat:-15.6005, lng:-56.0970, address:'Circuito demonstrativo • Cuiabá', hours:'Exemplo: terça a domingo, 9h às 17h', price:12, imageAsset:'assets/places/casa-memorias.png', description:'Museu fictício criado para demonstrar informações históricas, horários, valores de entrada e avaliações. As exposições imaginárias contam histórias da cidade.', demo:true},
  {id:'mirante-sol', name:'Mirante do Sol', category:'Lazer', lat:-15.5952, lng:-56.0901, address:'Circuito demonstrativo • Cuiabá', hours:'Exemplo: 6h às 19h', price:0, imageAsset:'assets/places/mirante-sol.png', description:'Mirante fictício para testar notificações por proximidade e visualização de rotas. Informações, preços e coordenadas destinam-se exclusivamente à demonstração.', demo:true},
  {id:'atelier-rio', name:'Ateliê do Rio', category:'Cultura', lat:-15.6060, lng:-56.1010, address:'Circuito demonstrativo • Cuiabá', hours:'Exemplo: 10h às 18h', price:8, imageAsset:'assets/places/atelier-rio.png', description:'Centro cultural fictício, com artesanato e oficinas imaginárias. Utilize este registro para testar favoritos e avaliações no aplicativo.', demo:true},
];
export const restaurants = [
  {id:'mesa-verde',name:'Mesa Verde',cuisine:'Vegetariana',lat:-15.5994,lng:-56.0955,address:'Endereço fictício • Cuiabá',demo:true},
  {id:'sabor-caminho',name:'Sabor do Caminho',cuisine:'Regional',lat:-15.6010,lng:-56.0960,address:'Endereço fictício • Cuiabá',demo:true},
];
