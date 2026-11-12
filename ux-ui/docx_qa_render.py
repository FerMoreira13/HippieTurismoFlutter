import base64
import html
import mimetypes
from pathlib import Path
from docx import Document
from docx.document import Document as DocumentType
from docx.table import Table
from docx.text.paragraph import Paragraph
from docx.oxml.ns import qn

ROOT=Path(__file__).resolve().parent
DOCX=ROOT/'Hippie_Turismo_Projeto_UX_UI.docx'
HTML=ROOT/'rendered-qa-2'/'document-preview.html'

def blocks(parent):
    body=parent.element.body if isinstance(parent,DocumentType) else parent._tc
    for child in body.iterchildren():
        if child.tag==qn('w:p'): yield Paragraph(child,parent)
        elif child.tag==qn('w:tbl'): yield Table(child,parent)

def images(paragraph):
    values=[]
    for blip in paragraph._p.xpath('.//a:blip'):
        rid=blip.get(qn('r:embed'))
        if not rid: continue
        part=paragraph.part.related_parts[rid]
        mime=part.content_type or mimetypes.guess_type(str(part.partname))[0] or 'image/png'
        values.append(f"<img src='data:{mime};base64,{base64.b64encode(part.blob).decode()}'/>")
    return ''.join(values)

doc=Document(DOCX)
out=[]
for item in blocks(doc):
    if isinstance(item,Paragraph):
        xml=item._p.xml
        if 'w:type="page"' in xml:
            out.append("<div class='page-break'></div>")
            continue
        img=images(item)
        text=html.escape(item.text).replace('\n','<br>')
        style=(item.style.name if item.style else '').lower()
        if img: out.append(f"<div class='figure'>{img}</div>")
        elif not text: out.append("<div class='spacer'></div>")
        elif style=='title': out.append(f"<h1 class='title'>{text}</h1>")
        elif 'heading 1' in style: out.append(f"<h1>{text}</h1>")
        elif 'heading 2' in style: out.append(f"<h2>{text}</h2>")
        elif 'heading 3' in style: out.append(f"<h3>{text}</h3>")
        elif 'caption' in style: out.append(f"<p class='caption'>{text}</p>")
        elif 'list bullet' in style: out.append(f"<p class='bullet'>• {text}</p>")
        else:
            align='center' if item.alignment and int(item.alignment)==1 else 'left'
            bold=all(r.bold for r in item.runs if r.text) if any(r.text for r in item.runs) else False
            out.append(f"<p class='{align}{' bold' if bold else ''}'>{text}</p>")
    else:
        rows=[]
        for ri,row in enumerate(item.rows):
            tag='th' if ri==0 else 'td'
            rows.append('<tr>'+''.join(f'<{tag}>{html.escape(cell.text)}</{tag}>' for cell in row.cells)+'</tr>')
        out.append('<table>'+''.join(rows)+'</table>')

css="""
@page { size:A4; margin:16mm 17mm; }
*{box-sizing:border-box} body{font-family:Arial,sans-serif;color:#351E28;font-size:10.5pt;line-height:1.25;margin:0}
h1,h2,h3,.title{color:#000;page-break-after:avoid;margin:12pt 0 7pt}.title{text-align:center;font-size:28pt;margin-top:0}h1{font-size:19pt}h2{font-size:14pt}h3{font-size:11pt}
p{margin:0 0 6pt}.center{text-align:center}.bold{font-weight:700}.bullet{padding-left:14pt}.caption{text-align:center;color:#667085;font-size:8.5pt;font-style:italic;margin-top:2pt}.spacer{height:4pt}
.figure{text-align:center;page-break-inside:avoid;margin:6pt 0 2pt}.figure img{max-width:100%;max-height:235mm;object-fit:contain}
table{width:100%;border-collapse:collapse;margin:7pt 0 10pt;page-break-inside:auto;font-size:8.3pt}tr{page-break-inside:avoid}th,td{border:1px solid #D9D9D9;padding:6pt;vertical-align:middle}th{background:#0D4542;color:#fff;text-align:center}tr:nth-child(odd) td{background:#F3F7F8}
.page-break{page-break-before:always}
"""
HTML.parent.mkdir(exist_ok=True)
HTML.write_text('<!doctype html><html><head><meta charset="utf-8"><style>'+css+'</style></head><body>'+''.join(out)+'</body></html>',encoding='utf-8')
print(HTML)
