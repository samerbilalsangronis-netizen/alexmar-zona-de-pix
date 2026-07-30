import { jsPDF } from 'jspdf';
import autoTable from 'jspdf-autotable';
import { NEGOCIO } from './negocio';
import type { ItemFactura } from '../components/TablaFactura';

export interface TotalPdf {
  etiqueta: string;
  valor: number;
  destacado?: boolean;
  prefijo?: string; // ej: '− ' para restar visualmente sin pasar un número negativo
}

export interface DatosFacturaPdf {
  etiqueta: string;
  numero?: string;
  clienteNombre: string;
  clienteContacto: string;
  items: ItemFactura[];
  totales: TotalPdf[];
}

const NEGRO: [number, number, number] = [10, 10, 10];
const NARANJA: [number, number, number] = [255, 107, 0];
const AZUL: [number, number, number] = [29, 63, 143];
const VERDE: [number, number, number] = [27, 175, 122];
const VERDE_CLARO: [number, number, number] = [232, 248, 239];
const GRIS: [number, number, number] = [244, 244, 244];

let logoCache: string | null | undefined;

async function cargarLogoBase64(): Promise<string | null> {
  if (logoCache !== undefined) return logoCache;
  if (!NEGOCIO.logoUrl) {
    logoCache = null;
    return null;
  }
  try {
    const resp = await fetch(NEGOCIO.logoUrl);
    const blob = await resp.blob();
    logoCache = await new Promise<string>((resolve, reject) => {
      const reader = new FileReader();
      reader.onload = () => resolve(reader.result as string);
      reader.onerror = () => reject(new Error('No se pudo leer el logo'));
      reader.readAsDataURL(blob);
    });
  } catch {
    logoCache = null;
  }
  return logoCache;
}

function money(v: number): string {
  return `$${v.toLocaleString('es-VE', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
}

function fechaCorta(iso?: string | null): string {
  if (!iso) return '';
  return new Date(iso).toLocaleDateString('es-VE', { day: '2-digit', month: '2-digit', year: 'numeric' });
}

export async function generarFacturaPdf(datos: DatosFacturaPdf): Promise<jsPDF> {
  const doc = new jsPDF({ unit: 'mm', format: 'a4' });
  const margin = 12;
  const pageW = doc.internal.pageSize.getWidth();
  const pageH = doc.internal.pageSize.getHeight();
  const contentW = pageW - margin * 2;

  const logo = await cargarLogoBase64();

  // ── Header ──
  const headerH = 26;
  doc.setFillColor(...NEGRO);
  doc.rect(margin, margin, contentW, headerH, 'F');

  const logoSize = 18;
  const logoX = margin + 4;
  const logoY = margin + (headerH - logoSize) / 2;
  doc.setFillColor(255, 255, 255);
  doc.roundedRect(logoX, logoY, logoSize, logoSize, 2, 2, 'F');
  if (logo) {
    try {
      doc.addImage(logo, 'PNG', logoX + 1, logoY + 1, logoSize - 2, logoSize - 2);
    } catch {
      // si el logo no carga, seguimos sin él
    }
  }

  const textX = logoX + logoSize + 4;
  doc.setTextColor(255, 255, 255);
  doc.setFont('helvetica', 'bold');
  doc.setFontSize(7);
  doc.text(NEGOCIO.categoria, textX, margin + 9);
  doc.setFontSize(15);
  doc.text(NEGOCIO.nombre, textX, margin + 17);

  const badgeW = 46;
  const badgeX = margin + contentW - badgeW - 4;
  const badgeY = margin + 4;
  const badgeH = datos.numero ? 12 : 8;
  doc.setFillColor(...AZUL);
  doc.rect(badgeX, badgeY, badgeW, badgeH, 'F');
  doc.setFont('helvetica', 'bold');
  doc.setFontSize(7);
  doc.setTextColor(255, 255, 255);
  doc.text(datos.etiqueta, badgeX + badgeW / 2, badgeY + 4, { align: 'center' });
  if (datos.numero) {
    doc.setFontSize(11);
    doc.text(`Nº ${datos.numero}`, badgeX + badgeW / 2, badgeY + 10, { align: 'center' });
  }
  doc.setFont('helvetica', 'normal');
  doc.setFontSize(7);
  doc.setTextColor(220, 220, 220);
  doc.text(`Emitido: ${new Date().toLocaleDateString('es-VE')}`, badgeX + badgeW, badgeY + badgeH + 4, { align: 'right' });

  // ── Franja ubicación / teléfono ──
  let y = margin + headerH;
  const bandH = 14;
  doc.setFillColor(...GRIS);
  doc.rect(margin, y, contentW, bandH, 'F');
  doc.setFont('helvetica', 'bold');
  doc.setFontSize(6.5);
  doc.setTextColor(90, 90, 90);
  doc.text('UBICACIÓN', margin + 4, y + 5);
  doc.text('TELÉFONO', margin + contentW / 2 + 4, y + 5);
  doc.setFont('helvetica', 'normal');
  doc.setFontSize(9);
  doc.setTextColor(20, 20, 20);
  doc.text(NEGOCIO.ubicacion, margin + 4, y + 10.5);
  doc.text(NEGOCIO.telefono, margin + contentW / 2 + 4, y + 10.5);
  y += bandH + 6;

  // ── Cliente / contacto ──
  const clienteBoxH = 16;
  doc.setDrawColor(210, 210, 210);
  doc.rect(margin, y, contentW, clienteBoxH);
  doc.setFont('helvetica', 'bold');
  doc.setFontSize(6.5);
  doc.setTextColor(130, 130, 130);
  doc.text('CLIENTE', margin + 4, y + 5);
  doc.text('CONTACTO', margin + contentW / 2 + 4, y + 5);
  doc.setFontSize(11);
  doc.setTextColor(10, 10, 10);
  doc.text(datos.clienteNombre || '—', margin + 4, y + 12);
  doc.setFont('helvetica', 'normal');
  doc.setFontSize(9);
  doc.text(datos.clienteContacto || '—', margin + contentW / 2 + 4, y + 12);
  y += clienteBoxH + 4;

  // ── Tabla de ítems ──
  const body = datos.items.map((it) => {
    if (it.tipo === 'TITULO') {
      return [
        {
          content: `« ${it.descripcion} »`,
          colSpan: 5,
          styles: { fillColor: NARANJA, textColor: [0, 0, 0] as [number, number, number], fontStyle: 'bold' as const, halign: 'center' as const },
        },
      ];
    }
    const esAbono = it.tipo === 'ABONO';
    return [
      it.fecha ? fechaCorta(it.fecha) : '',
      esAbono ? '' : String(it.cantidad ?? ''),
      esAbono ? `ABONO${it.metodoPago ? ` · ${it.metodoPago}` : ''}` : it.descripcion,
      esAbono ? '' : it.precioUnitario ? money(it.precioUnitario) : '',
      `${esAbono ? '− ' : ''}${money(it.total)}`,
    ];
  });

  autoTable(doc, {
    startY: y,
    margin: { left: margin, right: margin, bottom: 16 },
    head: [['Fecha', 'Cant.', 'Producto / Servicio', 'P. Unit.', 'P. Total']],
    body,
    styles: { fontSize: 8, cellPadding: 1.6, textColor: [20, 20, 20] },
    headStyles: { fillColor: NEGRO, textColor: 255, fontStyle: 'bold' },
    columnStyles: {
      0: { cellWidth: 22 },
      1: { cellWidth: 14 },
      3: { cellWidth: 24, halign: 'right' },
      4: { cellWidth: 26, halign: 'right' },
    },
    didParseCell: (data) => {
      if (data.section === 'body') {
        const item = datos.items[data.row.index];
        if (item?.tipo === 'ABONO') {
          data.cell.styles.fillColor = VERDE_CLARO;
          if (data.column.index === 4) data.cell.styles.textColor = VERDE;
        }
      }
    },
    didDrawPage: () => {
      doc.setFont('helvetica', 'normal');
      doc.setFontSize(7);
      doc.setTextColor(140, 140, 140);
      doc.text(`${NEGOCIO.categoria} ${NEGOCIO.nombre}`, pageW / 2, pageH - 8, { align: 'center' });
    },
  });

  // ── Totales ──
  const alturaTotales = datos.totales.length * 9 + 22;
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  let finalY = (doc as any).lastAutoTable.finalY + 6;
  if (finalY + alturaTotales > pageH - 15) {
    doc.addPage();
    finalY = margin;
  }

  const totalesW = 76;
  const totalesX = margin + contentW - totalesW;
  for (const t of datos.totales) {
    if (t.destacado) {
      doc.setFillColor(...AZUL);
      doc.rect(totalesX, finalY, totalesW, 9, 'F');
      doc.setTextColor(255, 255, 255);
      doc.setFont('helvetica', 'bold');
      doc.setFontSize(8);
      doc.text(t.etiqueta.toUpperCase(), totalesX + 4, finalY + 6);
      doc.text(`${t.prefijo ?? ''}${money(t.valor)}`, totalesX + totalesW - 4, finalY + 6, { align: 'right' });
      finalY += 11;
    } else {
      doc.setTextColor(60, 60, 60);
      doc.setFont('helvetica', 'normal');
      doc.setFontSize(9);
      doc.text(t.etiqueta, totalesX, finalY + 4);
      doc.text(`${t.prefijo ?? ''}${money(t.valor)}`, totalesX + totalesW, finalY + 4, { align: 'right' });
      finalY += 7;
    }
  }

  finalY += 8;
  doc.setFont('helvetica', 'italic');
  doc.setFontSize(7.5);
  doc.setTextColor(120, 120, 120);
  const nota = doc.splitTextToSize(NEGOCIO.notaPie, contentW);
  doc.text(nota, pageW / 2, finalY, { align: 'center' });

  const totalPaginas = doc.getNumberOfPages();
  for (let i = 1; i <= totalPaginas; i++) {
    doc.setPage(i);
    doc.setFont('helvetica', 'normal');
    doc.setFontSize(7);
    doc.setTextColor(140, 140, 140);
    doc.text(`Página ${i} de ${totalPaginas}`, pageW - margin, pageH - 8, { align: 'right' });
  }

  return doc;
}

/** Genera el PDF y lo comparte con el share sheet nativo (WhatsApp, etc.) si el navegador lo soporta;
 *  si no, lo descarga para compartirlo a mano. */
export async function compartirFacturaPdf(datos: DatosFacturaPdf, nombreArchivo: string): Promise<'compartido' | 'descargado'> {
  const doc = await generarFacturaPdf(datos);
  const blob = doc.output('blob');
  const archivo = new File([blob], nombreArchivo, { type: 'application/pdf' });

  if (navigator.canShare?.({ files: [archivo] })) {
    await navigator.share({
      files: [archivo],
      title: `${datos.etiqueta}${datos.numero ? ` Nº ${datos.numero}` : ''} — ${NEGOCIO.nombre}`,
    });
    return 'compartido';
  }

  doc.save(nombreArchivo);
  return 'descargado';
}
