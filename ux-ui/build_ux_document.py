from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
from docx import Document
from docx.enum.section import WD_SECTION
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_CELL_VERTICAL_ALIGNMENT
from docx.enum.style import WD_STYLE_TYPE
from docx.shared import Inches, Pt, RGBColor
from docx.oxml import OxmlElement
from docx.oxml.ns import qn

ROOT = Path(__file__).resolve().parent
ASSETS = ROOT / "assets"
OUT = ROOT / "Hippie_Turismo_Projeto_UX_UI.docx"
PRIMARY = "176B65"
PRIMARY_DARK = "0D4542"
SECONDARY = "AEB8A0"
ACCENT = "FF5C34"
ICE = "F3FAFF"
INK = "351E28"
MUTED = "667085"
LINE = "D9D9D9"


def font(size, bold=False):
    path = Path(r"C:\Windows\Fonts\arialbd.ttf" if bold else r"C:\Windows\Fonts\arial.ttf")
    return ImageFont.truetype(str(path), size)


def rounded(draw, box, radius=18, fill="white", outline="#D9D9D9", width=2):
    draw.rounded_rectangle(box, radius=radius, fill=fill, outline=outline, width=width)


def draw_phone(draw, x, y, title, elements):
    w, h = 300, 560
    rounded(draw, (x, y, x+w, y+h), 32, "#FFFFFF", "#5B6470", 4)
    draw.rounded_rectangle((x+112, y+10, x+188, y+18), radius=4, fill="#A4AAB1")
    draw.text((x+24, y+36), title, font=font(22, True), fill="#1F2937")
    cy = y + 78
    for kind, label, height in elements:
        if kind == "bar":
            rounded(draw, (x+22, cy, x+w-22, cy+height), 12, "#E9EDF0", "#C8CDD2", 2)
            draw.text((x+36, cy+height//2-10), label, font=font(15), fill="#4B5563")
        elif kind == "card":
            rounded(draw, (x+22, cy, x+w-22, cy+height), 15, "#F7F8F9", "#C8CDD2", 2)
            draw.rectangle((x+36, cy+16, x+96, cy+height-16), fill="#D5DADD")
            draw.text((x+110, cy+18), label, font=font(15, True), fill="#4B5563")
            draw.line((x+110, cy+48, x+w-38, cy+48), fill="#BDC3C8", width=3)
            draw.line((x+110, cy+66, x+w-65, cy+66), fill="#D2D6DA", width=3)
        elif kind == "text":
            draw.text((x+24, cy), label, font=font(15), fill="#4B5563")
        elif kind == "button":
            rounded(draw, (x+22, cy, x+w-22, cy+height), 14, "#DCE5E4", "#889391", 2)
            bbox = draw.textbbox((0,0), label, font=font(15, True))
            draw.text((x+(w-(bbox[2]-bbox[0]))/2, cy+height/2-9), label, font=font(15, True), fill="#31413F")
        cy += height + 14
    draw.line((x+18, y+h-58, x+w-18, y+h-58), fill="#D5DADD", width=2)
    labels = ["Exp", "Mapa", "Sal", "Rot", "Perfil"]
    for i, lab in enumerate(labels):
        draw.text((x+18+i*53, y+h-40), lab, font=font(11), fill="#68707A")


def build_wireframes():
    canvas = Image.new("RGB", (1040, 1250), "white")
    d = ImageDraw.Draw(canvas)
    d.text((40, 24), "Wireframes de baixa fidelidade", font=font(34, True), fill="#111827")
    screens = [
        ("Acesso", [("text","Boas vindas",30),("bar","E mail",48),("bar","Senha",48),("button","Entrar",50),("text","Criar conta",24)]),
        ("Explorar", [("card","Localização e raio",100),("bar","Buscar local",46),("text","Filtros por categoria",26),("card","Ponto turístico",90),("card","Ponto turístico",90)]),
        ("Mapa", [("card","Área do mapa",190),("card","Local próximo",82),("card","Local próximo",82)]),
        ("Detalhes", [("card","Imagem do local",140),("text","Nome categoria endereço",48),("button","Ver rota",46),("text","Descrição horário valor",68),("card","Restaurantes",82)]),
        ("Salvos e roteiro", [("text","Resumo das paradas",36),("card","Local selecionado",90),("card","Local selecionado",90),("button","Limpar ou organizar",46)]),
        ("Perfil", [("text","Nome e conta",40),("bar","Usar GPS",48),("bar","Alertas de proximidade",48),("bar","Raio de descoberta",48),("button","Permissões",46),("text","Privacidade e sair",34)]),
    ]
    positions = [(35,85),(370,85),(705,85),(35,660),(370,660),(705,660)]
    for pos, (title, items) in zip(positions, screens):
        draw_phone(d, *pos, title, items)
    path = ASSETS / "wireframes.png"
    canvas.save(path)
    return path


def arrow(draw, start, end, color="#176B65", width=5):
    draw.line((*start, *end), fill=color, width=width)
    x2,y2=end; x1,y1=start
    import math
    ang=math.atan2(y2-y1,x2-x1)
    for delta in (2.55,-2.55):
        p=(x2+18*math.cos(ang+delta), y2+18*math.sin(ang+delta))
        draw.line((x2,y2,*p),fill=color,width=width)


def node(draw, box, title, subtitle="", fill="#FFFFFF", outline="#176B65"):
    rounded(draw, box, 18, fill, outline, 3)
    x1,y1,x2,y2=box
    tw=draw.textbbox((0,0),title,font=font(20,True))
    draw.text(((x1+x2-(tw[2]-tw[0]))/2,y1+17),title,font=font(20,True),fill="#222222")
    if subtitle:
        sw=draw.textbbox((0,0),subtitle,font=font(14))
        draw.text(((x1+x2-(sw[2]-sw[0]))/2,y1+50),subtitle,font=font(14),fill="#5F6873")


def build_navigation():
    im=Image.new("RGB",(1600,980),"white");d=ImageDraw.Draw(im)
    d.text((55,35),"Fluxo de navegação do protótipo",font=font(38,True),fill="#111827")
    node(d,(60,150,300,245),"Acesso","Entrar ou criar conta",fill="#F3FAFF")
    node(d,(390,150,650,245),"Permissão","Localização opcional",fill="#F3FAFF")
    node(d,(750,130,1030,265),"Navegação principal","Cinco abas persistentes",fill="#E4F2F0")
    arrow(d,(300,198),(390,198));arrow(d,(650,198),(750,198))
    tabs=[("Explorar",70),("Mapa",365),("Salvos",660),("Roteiro",955),("Perfil",1250)]
    for label,x in tabs:
        node(d,(x,390,x+240,480),label)
        arrow(d,(890,265),(x+120,390))
    node(d,(70,650,330,750),"Detalhes do local","Informações e ações",fill="#FFF2ED",outline="#FF5C34")
    arrow(d,(190,480),(190,650));arrow(d,(485,480),(300,650))
    node(d,(390,825,630,920),"Rota externa","Google Maps")
    node(d,(680,825,920,920),"Restaurantes","Até 3 km")
    node(d,(970,825,1210,920),"Avaliação","Nota e comentário")
    node(d,(1260,825,1510,920),"Salvar ou adicionar","Coleção e roteiro")
    for x in (510,800,1090,1385): arrow(d,(200,750),(x,825))
    node(d,(1250,600,1490,695),"Configurações","GPS alertas raio sair")
    arrow(d,(1370,480),(1370,600))
    path=ASSETS/"navigation-flow.png";im.save(path);return path


def build_information_architecture():
    im=Image.new("RGB",(1500,1080),"white");d=ImageDraw.Draw(im)
    d.text((55,35),"Arquitetura da informação",font=font(40,True),fill="#111827")
    node(d,(560,115,940,220),"Hippie Turismo","Descoberta turística por proximidade",fill="#E4F2F0")
    groups=[
        (70,350,"Conta",["Entrar","Criar conta","Sessão","Sair"]),
        (365,350,"Descoberta",["Busca","Categorias","Proximidade","Mapa"]),
        (660,350,"Local",["Detalhes","Rota","Restaurantes","Avaliações"]),
        (955,350,"Planejamento",["Salvos","Roteiro","Paradas","Custo estimado"]),
        (1250,350,"Preferências",["GPS","Alertas","Raio","Permissões"]),
    ]
    for x,y,title,items in groups:
        node(d,(x,y,x+220,y+85),title,fill="#F3FAFF")
        arrow(d,(750,220),(x+110,y))
        cy=y+125
        for item in items:
            rounded(d,(x+10,cy,x+210,cy+52),12,"#FFFFFF","#D0D5DA",2)
            d.text((x+28,cy+15),item,font=font(16),fill="#374151")
            cy+=68
    path=ASSETS/"information-architecture.png";im.save(path);return path


def build_mockup_grid():
    files=[("Explorar","current-01-explorar.png"),("Mapa","current-02-mapa.png"),("Salvos","current-03-salvos.png"),("Roteiro","current-04-roteiro.png"),("Perfil","current-05-perfil.png")]
    canvas=Image.new("RGB",(1320,1600),"white");d=ImageDraw.Draw(canvas)
    d.text((40,22),"Mockups do protótipo funcional",font=font(36,True),fill="#111827")
    positions=[(40,100),(470,100),(900,100),(250,845),(680,845)]
    for (label,name),(x,y) in zip(files,positions):
        im=Image.open(ASSETS/name).convert("RGB");im.thumbnail((370,690))
        rounded(d,(x-8,y-8,x+im.width+8,y+im.height+8),20,"#F8FAFC","#D9D9D9",2)
        canvas.paste(im,(x,y))
        d.text((x,y+im.height+18),label,font=font(22,True),fill="#351E28")
    path=ASSETS/"mockups-grid.png";canvas.save(path);return path


def set_cell_shading(cell, fill):
    tcPr=cell._tc.get_or_add_tcPr();shd=tcPr.find(qn('w:shd'))
    if shd is None: shd=OxmlElement('w:shd');tcPr.append(shd)
    shd.set(qn('w:fill'),fill)


def set_cell_margins(cell, top=100, start=100, bottom=100, end=100):
    tc=cell._tc;tcPr=tc.get_or_add_tcPr();tcMar=tcPr.first_child_found_in('w:tcMar')
    if tcMar is None: tcMar=OxmlElement('w:tcMar');tcPr.append(tcMar)
    for m,v in [('top',top),('start',start),('bottom',bottom),('end',end)]:
        node_=tcMar.find(qn('w:'+m))
        if node_ is None: node_=OxmlElement('w:'+m);tcMar.append(node_)
        node_.set(qn('w:w'),str(v));node_.set(qn('w:type'),'dxa')


def set_repeat_table_header(row):
    trPr=row._tr.get_or_add_trPr();tblHeader=OxmlElement('w:tblHeader');tblHeader.set(qn('w:val'),'true');trPr.append(tblHeader)


def add_page_number(paragraph):
    paragraph.alignment=WD_ALIGN_PARAGRAPH.RIGHT
    run=paragraph.add_run('Página ');run.font.size=Pt(9);run.font.color.rgb=RGBColor.from_string(MUTED)
    fldChar1=OxmlElement('w:fldChar');fldChar1.set(qn('w:fldCharType'),'begin')
    instr=OxmlElement('w:instrText');instr.set(qn('xml:space'),'preserve');instr.text=' PAGE '
    fldChar2=OxmlElement('w:fldChar');fldChar2.set(qn('w:fldCharType'),'end')
    run._r.extend([fldChar1,instr,fldChar2])


def configure(doc):
    sec=doc.sections[0];sec.top_margin=Inches(.62);sec.bottom_margin=Inches(.62);sec.left_margin=Inches(.68);sec.right_margin=Inches(.68)
    styles=doc.styles
    normal=styles['Normal'];normal.font.name='Aptos';normal.font.size=Pt(10.5);normal.font.color.rgb=RGBColor.from_string(INK)
    normal.paragraph_format.space_after=Pt(6);normal.paragraph_format.line_spacing=1.12
    for name,size in [('Title',28),('Heading 1',19),('Heading 2',14),('Heading 3',11)]:
        st=styles[name];st.font.name='Aptos Display';st.font.size=Pt(size);st.font.bold=True;st.font.color.rgb=RGBColor(0,0,0)
        st.paragraph_format.space_before=Pt(12 if name!='Title' else 0);st.paragraph_format.space_after=Pt(7);st.paragraph_format.keep_with_next=True
    if 'Caption UX' not in styles:
        cap=styles.add_style('Caption UX',WD_STYLE_TYPE.PARAGRAPH);cap.font.name='Aptos';cap.font.size=Pt(8.5);cap.font.italic=True;cap.font.color.rgb=RGBColor.from_string(MUTED);cap.paragraph_format.space_after=Pt(8)
    add_page_number(sec.footer.paragraphs[0])


def add_table(doc, headers, rows, widths=None, font_size=8.5):
    table=doc.add_table(rows=1,cols=len(headers));table.alignment=WD_TABLE_ALIGNMENT.CENTER;table.autofit=False
    table.style='Table Grid';hdr=table.rows[0];set_repeat_table_header(hdr)
    for i,h in enumerate(headers):
        c=hdr.cells[i];set_cell_shading(c,PRIMARY_DARK);c.vertical_alignment=WD_CELL_VERTICAL_ALIGNMENT.CENTER;set_cell_margins(c,110,110,110,110)
        p=c.paragraphs[0];p.alignment=WD_ALIGN_PARAGRAPH.CENTER;r=p.add_run(h);r.bold=True;r.font.color.rgb=RGBColor(255,255,255);r.font.size=Pt(font_size)
        if widths:c.width=Inches(widths[i])
    for ridx,row in enumerate(rows):
        cells=table.add_row().cells
        for i,val in enumerate(row):
            c=cells[i];c.vertical_alignment=WD_CELL_VERTICAL_ALIGNMENT.CENTER;set_cell_margins(c,100,110,100,110)
            if ridx%2:set_cell_shading(c,'F3F7F8')
            p=c.paragraphs[0];p.paragraph_format.space_after=Pt(0);r=p.add_run(str(val));r.font.size=Pt(font_size);r.font.color.rgb=RGBColor.from_string(INK)
            if widths:c.width=Inches(widths[i])
    doc.add_paragraph().paragraph_format.space_after=Pt(1)
    return table


def add_bullets(doc, items):
    for item in items:
        p=doc.add_paragraph(style='List Bullet');p.add_run(item)


def caption(doc,text):
    p=doc.add_paragraph(style='Caption UX');p.alignment=WD_ALIGN_PARAGRAPH.CENTER;p.add_run(text)


def main():
    ASSETS.mkdir(parents=True,exist_ok=True)
    wire=build_wireframes();nav=build_navigation();ia=build_information_architecture();mockups=build_mockup_grid()
    doc=Document();configure(doc)
    p=doc.add_paragraph(style='Title');p.alignment=WD_ALIGN_PARAGRAPH.CENTER;p.add_run('Hippie Turismo Projeto de Interface e Experiência do Usuário')
    p=doc.add_paragraph();p.alignment=WD_ALIGN_PARAGRAPH.CENTER;r=p.add_run('Wireframes Mockups Protótipo Fluxos e Validação');r.bold=True;r.font.size=Pt(14);r.font.color.rgb=RGBColor.from_string(PRIMARY)
    p=doc.add_paragraph();p.alignment=WD_ALIGN_PARAGRAPH.CENTER;p.add_run('Laboratório de Engenharia de Software\nFernanda Alves  Alexandre Assis  Wesley Menezes\nUNEMAT  Cáceres MT  2026')
    doc.add_picture(str(ASSETS/'current-01-explorar.png'),width=Inches(2.0))
    doc.paragraphs[-1].alignment=WD_ALIGN_PARAGRAPH.CENTER
    caption(doc,'Tela Explorar executada no emulador Android em 8 de setembro de 2026')
    doc.add_page_break()

    doc.add_heading('Objetivo e conclusão da proposta',level=1)
    doc.add_paragraph('Este documento consolida a estrutura de interface do Hippie Turismo e relaciona a proposta visual ao escopo definido para o produto. A análise usa os requisitos da documentação do projeto, o código Flutter implementado e capturas do protótipo em execução no Android.')
    doc.add_paragraph('A proposta está adequada para a continuidade do MVP. A navegação principal concentra as tarefas recorrentes em cinco abas, mantém os pontos turísticos como objeto central e oferece caminhos curtos para descobrir, salvar, planejar e consultar um local. A validação final para publicação ainda depende de testes com usuários reais, configuração das APIs externas, acessibilidade em dispositivo físico e verificação no iOS.')
    doc.add_heading('Público e contexto de uso',level=2)
    add_bullets(doc,[
        'Viajantes de 18 a 60 anos, incluindo turistas, mochileiros, famílias e pessoas em deslocamento independente.',
        'Uso prioritário em mobilidade, com atenção dividida, conexão variável e necessidade de decisões rápidas.',
        'Descoberta baseada em localização, com consentimento explícito para GPS e alternativa de exploração por centro de busca.',
    ])
    doc.add_heading('Princípios de interface',level=2)
    add_table(doc,['Princípio','Aplicação no produto'],[
        ['Descoberta rápida','Busca, filtros, distância e categorias aparecem antes da lista de locais.'],
        ['Ação no contexto','Salvar, adicionar ao roteiro e abrir rota permanecem junto ao ponto turístico.'],
        ['Orientação constante','A barra inferior mantém as cinco áreas principais visíveis.'],
        ['Consentimento e transparência','O GPS é opcional e o perfil explica o uso da localização.'],
        ['Feedback de estado','Carregamento, erros, modo demonstração e permissões têm mensagens próprias.'],
    ],[1.65,5.45],9)

    doc.add_page_break();doc.add_heading('Arquitetura da informação',level=1)
    doc.add_paragraph('A organização parte de um núcleo autenticado e separa descoberta, consulta de local, planejamento e preferências. Essa divisão reduz a mistura entre conteúdo turístico e configurações da conta.')
    doc.add_picture(str(ia),width=Inches(7.0));doc.paragraphs[-1].alignment=WD_ALIGN_PARAGRAPH.CENTER
    caption(doc,'Organização dos conteúdos e funções do aplicativo')
    add_table(doc,['Área','Conteúdo principal','Decisão do usuário'],[
        ['Conta','Cadastro, login, sessão e saída','Acessar ou encerrar a experiência'],
        ['Descoberta','Busca, categorias, proximidade e mapa','Escolher um local para conhecer'],
        ['Local','Descrição, horário, valor, rota, restaurantes e avaliações','Planejar a visita'],
        ['Planejamento','Favoritos e roteiro','Guardar e organizar paradas'],
        ['Preferências','GPS, alertas, raio e permissões','Controlar personalização e privacidade'],
    ],[1.15,3.2,2.75],8.5)

    doc.add_page_break();doc.add_heading('Fluxo de navegação',level=1)
    doc.add_paragraph('O fluxo principal começa no acesso, oferece localização como escolha e leva à navegação por abas. Explorar e Mapa convergem para os detalhes; Salvos e Roteiro preservam intenções; Perfil concentra os controles sensíveis.')
    doc.add_picture(str(nav),width=Inches(7.05));doc.paragraphs[-1].alignment=WD_ALIGN_PARAGRAPH.CENTER
    caption(doc,'Fluxo principal e saídas acionáveis do protótipo')
    doc.add_heading('Fluxos críticos',level=2)
    add_table(doc,['Fluxo','Sequência','Resultado esperado'],[
        ['Primeiro acesso','Criar conta → entrar → explorar','Sessão aberta e locais carregados'],
        ['Descoberta por GPS','Perfil ou Explorar → permitir localização → atualizar','Lista ordenada por proximidade'],
        ['Planejar visita','Explorar → local → adicionar ao roteiro','Parada e custo refletidos em Roteiro'],
        ['Guardar interesse','Explorar ou local → salvar → Salvos','Local disponível na coleção pessoal'],
        ['Navegar até o destino','Local → Ver rota','Aplicativo de mapas aberto com o destino'],
        ['Avaliar experiência','Local → avaliar → nota e comentário','Avaliação vinculada à conta e ao local'],
    ],[1.3,3.25,2.55],8.3)

    doc.add_page_break();doc.add_heading('Wireframes',level=1)
    doc.add_paragraph('Os wireframes representam hierarquia, agrupamento e posição dos controles sem depender da identidade visual final. Eles confirmam que cada tela possui uma tarefa dominante e que as ações secundárias aparecem próximas ao conteúdo relacionado.')
    doc.add_picture(str(wire),width=Inches(7.0));doc.paragraphs[-1].alignment=WD_ALIGN_PARAGRAPH.CENTER
    caption(doc,'Wireframes das seis estruturas necessárias ao MVP')

    doc.add_page_break();doc.add_heading('Mockups do protótipo funcional',level=1)
    doc.add_paragraph('Os mockups abaixo são capturas reais da versão Android em execução. A paleta usa verde petróleo, jade, persimmon, fundo azul gelo e texto Plum Noir. Fotografias locais, tipografia forte e cartões amplos reforçam o foco em descoberta e leitura rápida.')
    doc.add_picture(str(mockups),width=Inches(7.0));doc.paragraphs[-1].alignment=WD_ALIGN_PARAGRAPH.CENTER
    caption(doc,'Explorar Mapa Salvos Roteiro e Perfil na versão funcional')

    doc.add_page_break();doc.add_heading('Protótipo e comportamento das telas',level=1)
    doc.add_paragraph('O protótipo foi implementado em Flutter e permite testar navegação, dados de demonstração e estados do sistema no emulador. Os pontos de interação abaixo formam o roteiro recomendado para uma demonstração guiada.')
    add_table(doc,['Tela','Interações principais','Resposta da interface'],[
        ['Acesso','Alternar entre login e cadastro; validar nome, e-mail e senha','Exibe erro no campo ou abre a área autenticada'],
        ['Explorar','Ativar GPS; buscar; filtrar; abrir local; salvar; adicionar ao roteiro','Atualiza lista, distância e estados dos ícones'],
        ['Mapa','Visualizar pontos e selecionar um local','Abre detalhes; sem chave, apresenta instrução e lista alternativa'],
        ['Detalhes','Abrir rota; salvar; adicionar; consultar restaurantes; avaliar','Executa ação, confirma estado e atualiza avaliação'],
        ['Salvos','Consultar coleção e abrir um local','Mantém somente os itens associados à conta'],
        ['Roteiro','Consultar paradas, custo e remover itens','Recalcula quantidade e valor estimado'],
        ['Perfil','Ligar GPS, alertas, ajustar raio, abrir permissões e sair','Atualiza preferências e comunica condições necessárias'],
    ],[1.05,3.45,2.6],8.2)
    doc.add_heading('Estados que o protótipo deve demonstrar',level=2)
    add_bullets(doc,[
        'Carregamento ao autenticar, atualizar locais e consultar restaurantes.',
        'Lista vazia em Salvos e Roteiro com orientação para a próxima ação.',
        'Falha de conexão com opção de tentar novamente ou sair.',
        'Permissão de localização negada, bloqueada ou serviço de GPS desligado.',
        'Mapa indisponível sem chave, mantendo a lista de locais utilizável.',
    ])

    doc.add_page_break();doc.add_heading('Relação entre requisitos e telas',level=1)
    rows=[
        ['RF01','Cadastro de usuários','Acesso cadastro','Implementado','Nome, e-mail, senha e validação'],
        ['RF02','Login no aplicativo','Acesso login','Implementado','Sessão demo ou Firebase'],
        ['RF03','Acesso à localização GPS','Explorar e Perfil','Implementado','Consentimento e status de precisão'],
        ['RF04','Pontos turísticos próximos','Explorar e Mapa','Implementado','Distância, raio e ordenação'],
        ['RF05','Notificações automáticas','Perfil e sistema','Implementado com condição','Permissão e GPS ativo'],
        ['RF06','Detalhes dos pontos','Detalhes','Implementado','Descrição, horário, valor e endereço'],
        ['RF07','Restaurantes próximos','Detalhes','Implementado com condição','Catálogo demo ou Google Places'],
        ['RF08','Avaliação de locais','Detalhes e modal de avaliação','Implementado','Uma avaliação editável por usuário'],
        ['RF09','Locais favoritos','Explorar Detalhes e Salvos','Implementado','Inclusão e remoção autenticadas'],
        ['RF10','Rotas até o destino','Detalhes e Mapa','Implementado com condição','Aplicativo externo de mapas'],
        ['RNF01','Interface simples e intuitiva','Todas','Atendido no protótipo','Cinco abas e ações contextuais'],
        ['RNF02','Segurança dos dados','Acesso Perfil e backend','Parcial','Requer Firebase e políticas de produção'],
        ['RNF03','Android e iOS','Todas','Parcial','Android validado; iOS pendente'],
        ['RNF04','Resposta inferior a 3 segundos','Estados de carregamento','Pendente em produção','Medição local não representa a nuvem'],
        ['RNF05','Baixo consumo de bateria','Perfil e serviço GPS','Parcial','Atualização por deslocamento; medir em aparelho real'],
    ]
    add_table(doc,['ID','Requisito','Telas','Situação','Evidência ou condição'],rows,[.5,1.8,1.45,1.15,2.15],7.5)
    doc.add_paragraph('A rastreabilidade cobre todos os requisitos funcionais do documento de origem. As ressalvas concentram-se em serviços externos e qualidades que só podem ser medidas em ambiente real de produção.')

    doc.add_page_break();doc.add_heading('Validação da proposta de interface',level=1)
    doc.add_paragraph('A validação realizada combina inspeção da interface, correspondência com requisitos, execução no emulador Android e evidências técnicas registradas no projeto. Ela confirma a coerência do protótipo, mas não substitui um teste de usabilidade com participantes do público-alvo.')
    add_table(doc,['Critério','Evidência observada','Resultado','Próxima ação'],[
        ['Clareza da navegação','Cinco abas com rótulos e ícones persistentes','Aprovado','Manter rótulos em todas as versões'],
        ['Hierarquia visual','Títulos fortes, cartões, distância e categoria escaneáveis','Aprovado','Testar fonte ampliada em 200 por cento'],
        ['Consistência','Mesma paleta, espaçamento e componentes nas áreas principais','Aprovado','Revisar telas secundárias no mesmo padrão'],
        ['Feedback e recuperação','Carregamento, listas vazias, erro e tentar novamente','Aprovado','Adicionar telemetria de falhas em produção'],
        ['Privacidade','GPS opcional, explicação de uso e acesso às permissões','Aprovado com ressalva','Revisar textos jurídicos antes da loja'],
        ['Acessibilidade','Rótulos em botões e contraste visual adequado à inspeção','Requer teste','Executar TalkBack, foco e contraste automatizado'],
        ['Mapa e rotas','Fallback de lista disponível; mapa depende de credencial','Aprovado com ressalva','Configurar e restringir chave Google Maps'],
        ['Desempenho','Estados de carregamento e testes locais sem falhas','Requer medição','Medir percentil 95 em rede móvel e produção'],
        ['Compatibilidade','Protótipo executado no emulador Android 1080 por 2400','Parcial','Validar Android físico e iOS'],
    ],[1.3,2.65,1.2,2.0],7.7)
    doc.add_heading('Evidências técnicas disponíveis',level=2)
    add_bullets(doc,[
        'Capturas das cinco áreas principais realizadas no emulador Android em 8 de setembro de 2026.',
        'Onze testes automatizados da API aprovados, incluindo autenticação, proximidade, favoritos, avaliações, restaurantes, logout e migrations.',
        'Três testes Flutter registrados no arquivo de validação do projeto, cobrindo notificações, formulário e o fluxo explorar salvar detalhes avaliar.',
        'Análise estática Flutter registrada sem problemas na entrega do protótipo.',
    ])

    doc.add_page_break();doc.add_heading('Plano de teste com usuários',level=1)
    doc.add_paragraph('Recomenda-se uma rodada moderada com cinco a oito participantes do público-alvo. Cada participante deve usar o protótipo sem orientação sobre os controles, enquanto o avaliador registra sucesso, tempo, erros, dúvidas e comentários.')
    add_table(doc,['Tarefa','Cenário','Critério de sucesso'],[
        ['Criar conta','Você instalou o app pela primeira vez','Concluir cadastro sem ajuda'],
        ['Encontrar uma atração','Você quer conhecer uma cachoeira próxima','Localizar e abrir os detalhes'],
        ['Montar um passeio','Você deseja visitar dois locais hoje','Adicionar duas paradas e consultar custo'],
        ['Guardar para depois','Você encontrou um local interessante','Salvar e reencontrar em Salvos'],
        ['Usar localização','Você quer resultados baseados na posição atual','Ativar GPS entendendo a permissão'],
        ['Abrir rota','Você decidiu visitar o local','Iniciar a rota no aplicativo de mapas'],
        ['Avaliar','Você terminou a visita','Registrar nota e comentário'],
    ],[1.35,3.35,2.45],8.3)
    doc.add_heading('Metas de aceitação',level=2)
    add_table(doc,['Indicador','Meta para aprovação'],[
        ['Conclusão das tarefas críticas','Pelo menos 85 por cento sem ajuda'],
        ['Erros críticos','Nenhum erro que impeça cadastro descoberta ou rota'],
        ['Facilidade após cada tarefa','Média mínima 5 em escala de 1 a 7'],
        ['Satisfação geral','SUS igual ou superior a 75'],
        ['Compreensão da permissão de GPS','Todos explicam por que a localização é solicitada'],
    ],[3.0,4.15],9)
    doc.add_paragraph('As falhas observadas devem voltar ao backlog com tela, contexto, gravidade e evidência. Uma segunda rodada confirma se as correções resolveram os problemas sem criar novos obstáculos.')

    doc.add_page_break();doc.add_heading('Decisão de validação',level=1)
    doc.add_paragraph('A proposta de interface está aprovada para continuidade do MVP. A arquitetura da informação corresponde ao problema de descoberta turística por proximidade, os requisitos funcionais possuem representação nas telas e o protótipo permite demonstrar os fluxos centrais.')
    doc.add_paragraph('Antes de publicar, a equipe deve concluir quatro pontos: configurar mapas e serviços externos com credenciais restritas; testar GPS, notificações e consumo de bateria em aparelho físico; executar avaliação de acessibilidade; e validar as tarefas críticas com usuários reais. Esses pontos não impedem a apresentação acadêmica do protótipo, mas limitam a afirmação de que o produto está pronto para uso público.')
    doc.add_heading('Entregáveis consolidados',level=2)
    add_bullets(doc,[
        'Wireframes das estruturas de acesso, descoberta, mapa, detalhes, planejamento e perfil.',
        'Mockups das cinco áreas principais capturados no protótipo funcional.',
        'Fluxo de navegação e arquitetura da informação.',
        'Matriz de rastreabilidade entre requisitos e telas.',
        'Inspeção da interface, evidências existentes e plano de validação com usuários.',
    ])
    doc.add_paragraph('Fonte de requisitos: documentação do sistema Hippie Turismo fornecida pela equipe. Fonte da implementação: aplicativo Flutter e API Node.js presentes no projeto local em setembro de 2026.')
    doc.save(OUT)
    print(OUT)


if __name__ == '__main__':
    main()
