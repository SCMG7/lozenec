import PDFDocument from 'pdfkit';
import type { Reservation, Expense, Guest, User } from '@prisma/client';

// ---------- Types ----------

interface ReservationWithGuest extends Reservation {
  guest: Pick<Guest, 'full_name'>;
}

interface ReportData {
  user: Pick<User, 'full_name' | 'property_name' | 'currency'>;
  periodLabel: string;
  startDate: Date;
  endDate: Date;
  reservations: ReservationWithGuest[];
  expenses: Expense[];
}

interface MonthlySummary {
  month: string;
  reservations: number;
  nights: number;
  income: number;
  expenses: number;
  net: number;
}

interface CategorySummary {
  category: string;
  total: number;
  percentage: number;
}

// ---------- Helpers ----------

const COLORS = {
  primary: '#1A73E8' as const,
  primaryDark: '#0D47A1' as const,
  text: '#212121' as const,
  textSecondary: '#616161' as const,
  headerBg: '#E3F2FD' as const,
  rowAlt: '#F5F5F5' as const,
  border: '#BDBDBD' as const,
  white: '#FFFFFF' as const,
  green: '#2E7D32' as const,
  red: '#C62828' as const,
};

const MONTH_NAMES = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

function cents(amount: number): string {
  return (amount / 100).toFixed(2);
}

function fmtDate(d: Date): string {
  const dd = String(d.getUTCDate()).padStart(2, '0');
  const mm = String(d.getUTCMonth() + 1).padStart(2, '0');
  const yyyy = d.getUTCFullYear();
  return `${dd}.${mm}.${yyyy}`;
}

function nightsBetween(a: Date, b: Date): number {
  const ms = b.getTime() - a.getTime();
  return Math.max(Math.round(ms / 86_400_000), 0);
}

// ---------- Table drawing helper ----------

interface TableColumn {
  header: string;
  width: number;
  align?: 'left' | 'right' | 'center';
}

interface TableOptions {
  columns: TableColumn[];
  rows: string[][];
  startX: number;
  startY: number;
  rowHeight: number;
  fontSize: number;
  doc: PDFKit.PDFDocument;
  addPageFn: () => void;
  totalsRow?: string[];
}

function drawTable(opts: TableOptions): number {
  const { columns, rows, startX, rowHeight, fontSize, doc, addPageFn, totalsRow } = opts;
  let y = opts.startY;
  const pageBottom = doc.page.height - 80;
  const totalWidth = columns.reduce((s, c) => s + c.width, 0);

  // Header row
  doc.save();
  doc.rect(startX, y, totalWidth, rowHeight).fill(COLORS.primary);
  let x = startX;
  doc.font('Helvetica-Bold').fontSize(fontSize).fillColor(COLORS.white);
  for (const col of columns) {
    const textX = col.align === 'right' ? x + col.width - 5 : x + 5;
    const textOpts: PDFKit.Mixins.TextOptions = {
      width: col.width - 10,
      align: col.align ?? 'left',
      lineBreak: false,
    };
    doc.text(col.header, textX, y + 5, textOpts);
    x += col.width;
  }
  doc.restore();
  y += rowHeight;

  // Data rows
  doc.font('Helvetica').fontSize(fontSize).fillColor(COLORS.text);
  for (let i = 0; i < rows.length; i++) {
    if (y + rowHeight > pageBottom) {
      addPageFn();
      y = 50;
    }

    const row = rows[i]!;
    if (i % 2 === 1) {
      doc.save();
      doc.rect(startX, y, totalWidth, rowHeight).fill(COLORS.rowAlt);
      doc.restore();
      doc.fillColor(COLORS.text);
    }

    x = startX;
    for (let j = 0; j < columns.length; j++) {
      const col = columns[j]!;
      const cell = row[j] ?? '';
      const textX = col.align === 'right' ? x + col.width - 5 : x + 5;
      doc.text(cell, textX, y + 5, {
        width: col.width - 10,
        align: col.align ?? 'left',
        lineBreak: false,
      });
      x += col.width;
    }
    y += rowHeight;
  }

  // Totals row
  if (totalsRow) {
    if (y + rowHeight > pageBottom) {
      addPageFn();
      y = 50;
    }

    doc.save();
    doc.rect(startX, y, totalWidth, rowHeight).fill(COLORS.headerBg);
    doc.restore();

    x = startX;
    doc.font('Helvetica-Bold').fontSize(fontSize).fillColor(COLORS.text);
    for (let j = 0; j < columns.length; j++) {
      const col = columns[j]!;
      const cell = totalsRow[j] ?? '';
      const textX = col.align === 'right' ? x + col.width - 5 : x + 5;
      doc.text(cell, textX, y + 5, {
        width: col.width - 10,
        align: col.align ?? 'left',
        lineBreak: false,
      });
      x += col.width;
    }
    y += rowHeight;
  }

  // Bottom border
  doc.save();
  doc.moveTo(startX, y).lineTo(startX + totalWidth, y).strokeColor(COLORS.border).lineWidth(0.5).stroke();
  doc.restore();

  return y;
}

// ---------- Main generator ----------

export function generateTaxReportPdf(data: ReportData): PDFKit.PDFDocument {
  const { user, periodLabel, reservations, expenses } = data;
  const currency = user.currency ?? 'EUR';

  const doc = new PDFDocument({
    size: 'A4',
    margins: { top: 50, bottom: 80, left: 50, right: 50 },
    bufferPages: true,
    info: {
      Title: `Tax Report - ${periodLabel}`,
      Author: 'RentMate',
    },
  });

  const pageWidth = doc.page.width;
  const contentWidth = pageWidth - 100;
  const leftMargin = 50;

  // Track pages for footer
  const addPage = (): void => {
    doc.addPage();
  };

  // =========== COVER PAGE ===========
  doc.save();
  doc.rect(0, 0, pageWidth, 280).fill(COLORS.primary);
  doc.restore();

  doc.font('Helvetica-Bold').fontSize(36).fillColor(COLORS.white);
  doc.text('RentMate', leftMargin, 80, { width: contentWidth, align: 'center' });

  doc.font('Helvetica').fontSize(16).fillColor(COLORS.white);
  doc.text('Annual Rental Income & Expense Report', leftMargin, 140, { width: contentWidth, align: 'center' });

  doc.fontSize(14);
  doc.text(periodLabel, leftMargin, 175, { width: contentWidth, align: 'center' });

  // Property / owner details below banner
  let coverY = 320;

  if (user.property_name) {
    doc.font('Helvetica-Bold').fontSize(18).fillColor(COLORS.text);
    doc.text(user.property_name, leftMargin, coverY, { width: contentWidth, align: 'center' });
    coverY += 30;
  }

  doc.font('Helvetica').fontSize(14).fillColor(COLORS.textSecondary);
  doc.text(`Owner: ${user.full_name}`, leftMargin, coverY, { width: contentWidth, align: 'center' });
  coverY += 25;
  doc.text(`Generated: ${fmtDate(new Date())}`, leftMargin, coverY, { width: contentWidth, align: 'center' });
  coverY += 25;
  doc.text(`Currency: ${currency}`, leftMargin, coverY, { width: contentWidth, align: 'center' });

  // =========== EXECUTIVE SUMMARY ===========
  addPage();

  const confirmedReservations = reservations.filter((r) => r.status !== 'cancelled');
  const totalIncome = confirmedReservations.reduce((s, r) => s + r.total_price, 0);
  const totalExpenses = expenses.reduce((s, e) => s + e.amount, 0);
  const netProfit = totalIncome - totalExpenses;
  const totalNights = confirmedReservations.reduce(
    (s, r) => s + nightsBetween(new Date(r.check_in), new Date(r.check_out)),
    0,
  );
  const daysInPeriod = nightsBetween(data.startDate, data.endDate);
  const occupancyRate = daysInPeriod > 0 ? Math.round((totalNights / daysInPeriod) * 100) : 0;
  const avgNightlyRate = totalNights > 0 ? Math.round(totalIncome / totalNights) : 0;
  const uniqueGuests = new Set(confirmedReservations.map((r) => r.guest_id)).size;

  let ey = 50;

  doc.font('Helvetica-Bold').fontSize(20).fillColor(COLORS.primary);
  doc.text('Executive Summary', leftMargin, ey);
  ey += 35;

  doc.moveTo(leftMargin, ey).lineTo(leftMargin + contentWidth, ey).strokeColor(COLORS.primary).lineWidth(1).stroke();
  ey += 15;

  const summaryItems: [string, string][] = [
    ['Total Gross Income', `${cents(totalIncome)} ${currency}`],
    ['Total Expenses', `${cents(totalExpenses)} ${currency}`],
    ['Net Profit / Loss', `${cents(netProfit)} ${currency}`],
    ['Total Nights Rented', String(totalNights)],
    ['Average Occupancy Rate', `${occupancyRate}%`],
    ['Average Nightly Rate', `${cents(avgNightlyRate)} ${currency}`],
    ['Number of Reservations', String(confirmedReservations.length)],
    ['Number of Unique Guests', String(uniqueGuests)],
  ];

  for (const [label, value] of summaryItems) {
    doc.font('Helvetica').fontSize(12).fillColor(COLORS.textSecondary);
    doc.text(label, leftMargin, ey, { continued: false });
    doc.font('Helvetica-Bold').fontSize(12).fillColor(COLORS.text);
    doc.text(value, leftMargin + 250, ey);
    ey += 24;
  }

  // =========== MONTHLY BREAKDOWN TABLE ===========
  ey += 30;

  doc.font('Helvetica-Bold').fontSize(20).fillColor(COLORS.primary);
  doc.text('Monthly Breakdown', leftMargin, ey);
  ey += 35;

  const monthlySummaries: MonthlySummary[] = [];
  const startMonth = data.startDate.getUTCMonth();
  const startYear = data.startDate.getUTCFullYear();
  const endMonth = data.endDate.getUTCMonth();
  const endYear = data.endDate.getUTCFullYear();

  // Generate monthly buckets for the period
  const months: { year: number; month: number }[] = [];
  let cy = startYear;
  let cm = startMonth;
  while (cy < endYear || (cy === endYear && cm <= endMonth)) {
    months.push({ year: cy, month: cm });
    cm++;
    if (cm > 11) {
      cm = 0;
      cy++;
    }
  }

  for (const { year, month } of months) {
    const monthStart = new Date(Date.UTC(year, month, 1));
    const monthEnd = new Date(Date.UTC(year, month + 1, 0, 23, 59, 59));

    const monthReservations = confirmedReservations.filter((r) => {
      const ci = new Date(r.check_in);
      return ci >= monthStart && ci <= monthEnd;
    });

    const monthNights = monthReservations.reduce(
      (s, r) => s + nightsBetween(new Date(r.check_in), new Date(r.check_out)),
      0,
    );
    const monthIncome = monthReservations.reduce((s, r) => s + r.total_price, 0);

    const monthExpenses = expenses.filter((e) => {
      const ed = new Date(e.date);
      return ed >= monthStart && ed <= monthEnd;
    });
    const monthExpenseTotal = monthExpenses.reduce((s, e) => s + e.amount, 0);

    monthlySummaries.push({
      month: `${MONTH_NAMES[month]} ${year}`,
      reservations: monthReservations.length,
      nights: monthNights,
      income: monthIncome,
      expenses: monthExpenseTotal,
      net: monthIncome - monthExpenseTotal,
    });
  }

  const monthlyColumns: TableColumn[] = [
    { header: 'Month', width: 110, align: 'left' },
    { header: 'Reservations', width: 80, align: 'right' },
    { header: 'Nights', width: 60, align: 'right' },
    { header: 'Income', width: 85, align: 'right' },
    { header: 'Expenses', width: 85, align: 'right' },
    { header: 'Net', width: 85, align: 'right' },
  ];

  const monthlyRows = monthlySummaries.map((m) => [
    m.month,
    String(m.reservations),
    String(m.nights),
    cents(m.income),
    cents(m.expenses),
    cents(m.net),
  ]);

  const totInc = monthlySummaries.reduce((s, m) => s + m.income, 0);
  const totExp = monthlySummaries.reduce((s, m) => s + m.expenses, 0);
  const totNts = monthlySummaries.reduce((s, m) => s + m.nights, 0);
  const totRes = monthlySummaries.reduce((s, m) => s + m.reservations, 0);

  ey = drawTable({
    columns: monthlyColumns,
    rows: monthlyRows,
    startX: leftMargin,
    startY: ey,
    rowHeight: 22,
    fontSize: 9,
    doc,
    addPageFn: addPage,
    totalsRow: ['TOTAL', String(totRes), String(totNts), cents(totInc), cents(totExp), cents(totInc - totExp)],
  });

  // =========== RESERVATIONS DETAIL TABLE ===========
  addPage();
  let ry = 50;

  doc.font('Helvetica-Bold').fontSize(20).fillColor(COLORS.primary);
  doc.text('Reservations Detail', leftMargin, ry);
  ry += 35;

  const sortedReservations = [...reservations].sort(
    (a, b) => new Date(a.check_in).getTime() - new Date(b.check_in).getTime(),
  );

  const resColumns: TableColumn[] = [
    { header: 'Guest Name', width: 100, align: 'left' },
    { header: 'Check-in', width: 70, align: 'left' },
    { header: 'Check-out', width: 70, align: 'left' },
    { header: 'Nights', width: 45, align: 'right' },
    { header: 'Price/Night', width: 70, align: 'right' },
    { header: 'Total', width: 70, align: 'right' },
    { header: 'Paid', width: 70, align: 'right' },
    { header: 'Status', width: 60, align: 'left' },
  ];

  const resRows = sortedReservations.map((r) => {
    const nights = nightsBetween(new Date(r.check_in), new Date(r.check_out));
    return [
      r.guest.full_name,
      fmtDate(new Date(r.check_in)),
      fmtDate(new Date(r.check_out)),
      String(nights),
      cents(r.price_per_night),
      cents(r.total_price),
      cents(r.amount_paid),
      r.status,
    ];
  });

  ry = drawTable({
    columns: resColumns,
    rows: resRows,
    startX: leftMargin - 10,
    startY: ry,
    rowHeight: 20,
    fontSize: 8,
    doc,
    addPageFn: addPage,
  });

  // =========== EXPENSES DETAIL TABLE ===========
  addPage();
  let exY = 50;

  doc.font('Helvetica-Bold').fontSize(20).fillColor(COLORS.primary);
  doc.text('Expenses Detail', leftMargin, exY);
  exY += 35;

  const sortedExpenses = [...expenses].sort(
    (a, b) => new Date(a.date).getTime() - new Date(b.date).getTime(),
  );

  const expColumns: TableColumn[] = [
    { header: 'Date', width: 80, align: 'left' },
    { header: 'Category', width: 100, align: 'left' },
    { header: 'Description', width: 200, align: 'left' },
    { header: 'Amount', width: 80, align: 'right' },
    { header: 'Recurring', width: 60, align: 'center' },
  ];

  const expRows = sortedExpenses.map((e) => [
    fmtDate(new Date(e.date)),
    e.category,
    e.description ?? '',
    cents(e.amount),
    e.is_recurring ? 'Yes' : 'No',
  ]);

  exY = drawTable({
    columns: expColumns,
    rows: expRows,
    startX: leftMargin - 10,
    startY: exY,
    rowHeight: 20,
    fontSize: 9,
    doc,
    addPageFn: addPage,
    totalsRow: ['', '', 'TOTAL', cents(totalExpenses), ''],
  });

  // =========== EXPENSE BREAKDOWN BY CATEGORY ===========
  exY += 40;
  if (exY > doc.page.height - 200) {
    addPage();
    exY = 50;
  }

  doc.font('Helvetica-Bold').fontSize(20).fillColor(COLORS.primary);
  doc.text('Expense Breakdown by Category', leftMargin, exY);
  exY += 35;

  const categoryMap = new Map<string, number>();
  for (const e of expenses) {
    categoryMap.set(e.category, (categoryMap.get(e.category) ?? 0) + e.amount);
  }

  const categorySummaries: CategorySummary[] = [];
  for (const [category, total] of categoryMap) {
    categorySummaries.push({
      category,
      total,
      percentage: totalExpenses > 0 ? Math.round((total / totalExpenses) * 10000) / 100 : 0,
    });
  }
  categorySummaries.sort((a, b) => b.total - a.total);

  const catColumns: TableColumn[] = [
    { header: 'Category', width: 180, align: 'left' },
    { header: 'Total Amount', width: 130, align: 'right' },
    { header: '% of Total', width: 100, align: 'right' },
  ];

  const catRows = categorySummaries.map((c) => [c.category, cents(c.total), `${c.percentage}%`]);

  drawTable({
    columns: catColumns,
    rows: catRows,
    startX: leftMargin,
    startY: exY,
    rowHeight: 22,
    fontSize: 10,
    doc,
    addPageFn: addPage,
    totalsRow: ['TOTAL', cents(totalExpenses), '100%'],
  });

  // =========== FOOTER ON EVERY PAGE ===========
  const pages = doc.bufferedPageRange();
  const totalPages = pages.count;
  const generatedDate = fmtDate(new Date());

  for (let i = 0; i < totalPages; i++) {
    doc.switchToPage(i);
    doc.save();
    doc.font('Helvetica').fontSize(8).fillColor(COLORS.textSecondary);
    const footerText = `Generated by RentMate \u2022 ${generatedDate} \u2022 Page ${i + 1} of ${totalPages}`;
    doc.text(footerText, leftMargin, doc.page.height - 40, {
      width: contentWidth,
      align: 'center',
    });
    doc.restore();
  }

  doc.end();
  return doc;
}
