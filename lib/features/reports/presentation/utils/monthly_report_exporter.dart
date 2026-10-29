import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../data/models/report_models.dart';

/// Exports a [MonthlyReport] to a PDF and opens the system share sheet,
/// mirroring [TeacherReportExporter] so the two reports feel identical.
class MonthlyReportExporter {
  static final _amountFormat = NumberFormat('#,###');

  static const _headerColor = PdfColor.fromInt(0xFF3B5BDB);
  static const _summaryBg = PdfColor.fromInt(0xFFE8ECFD);
  static const _rowAlt = PdfColor.fromInt(0xFFF1F3F5);

  static const _uzMonths = [
    'Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun',
    'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr',
  ];

  static String _monthLabel(MonthlyReport r) =>
      '${_uzMonths[r.month - 1].toUpperCase()} ${r.year}';

  static Future<void> sharePdf(MonthlyReport report) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(report),
          pw.SizedBox(height: 16),
          _buildSummaryTable(report),
          pw.SizedBox(height: 24),
          pw.Text(
            'Guruhlar statistikasi',
            style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          _buildGroupsTable(report),
        ],
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            '${context.pageNumber} / ${context.pagesCount} - Creative Learning Center',
            style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
          ),
        ),
      ),
    );

    final bytes = await pdf.save();
    final dir = await getTemporaryDirectory();
    final monthKey = '${report.year}-${report.month.toString().padLeft(2, '0')}';
    final file = File('${dir.path}/Oylik_hisobot_$monthKey.pdf');
    await file.writeAsBytes(bytes);

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/pdf')],
      subject: 'Oylik hisobot ($monthKey) - Creative Learning Center',
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  static pw.Widget _buildHeader(MonthlyReport report) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          'Oylik hisobot',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          _monthLabel(report),
          style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          'Creative Learning Center',
          style: pw.TextStyle(fontSize: 10, color: PdfColors.grey500),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }

  // ── Summary ──────────────────────────────────────────────────────────────

  static pw.Widget _buildSummaryTable(MonthlyReport r) {
    final a = r.attendanceStats;
    final rows = <List<String>>[
      ['Faol o\'quvchilar', '${r.totalActiveStudents}'],
      ['Guruhlar', '${r.totalGroups}'],
      ['Kutilgan daromad', _fmt(r.expectedRevenue)],
      ['Haqiqiy daromad', _fmt(r.actualRevenue)],
      ['Yig\'ish foizi', '${r.collectionRate.toStringAsFixed(1)}%'],
      ['To\'lovlar soni', '${r.totalPayments}'],
      ['To\'liq to\'lagan', '${r.studentsWhoFullyPaid} o\'quvchi'],
      ['Qisman to\'lagan', '${r.studentsWhoPartiallyPaid} o\'quvchi'],
      ['To\'lamagan', '${r.studentsWhoDidNotPay} o\'quvchi'],
      [
        'Davomat',
        '${a.attendanceRate.toStringAsFixed(1)}% '
            '(${a.totalPresent} kelgan, ${a.totalAbsent} kelmagan)',
      ],
    ];

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: [
        for (var i = 0; i < rows.length; i++)
          pw.TableRow(
            decoration: pw.BoxDecoration(
              color: i.isOdd ? PdfColors.white : _summaryBg,
            ),
            children: [
              _cell(rows[i][0]),
              _cell(
                rows[i][1],
                align: pw.TextAlign.right,
                bold: rows[i][0] == 'Haqiqiy daromad',
              ),
            ],
          ),
      ],
    );
  }

  // ── Groups table ───────────────────────────────────────────────────────────

  static pw.Widget _buildGroupsTable(MonthlyReport report) {
    if (report.groupStats.isEmpty) {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 8),
        child: pw.Text(
          'Bu oy uchun guruh ma\'lumotlari yo\'q',
          style: pw.TextStyle(
            fontSize: 10,
            color: PdfColors.grey500,
            fontStyle: pw.FontStyle.italic,
          ),
        ),
      );
    }

    return pw.Table(
      columnWidths: const {
        0: pw.FixedColumnWidth(24),
        1: pw.FlexColumnWidth(3),
        2: pw.FlexColumnWidth(3),
        3: pw.FlexColumnWidth(1.2),
        4: pw.FlexColumnWidth(2),
        5: pw.FlexColumnWidth(2),
        6: pw.FlexColumnWidth(1.4),
        7: pw.FlexColumnWidth(1.4),
      },
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: _headerColor),
          children: [
            '#', 'Guruh', 'O\'qituvchi', 'Faol', 'Kutilgan', 'Haqiqiy',
            'Yig\'ish', 'To\'ladi',
          ]
              .map((h) => _cell(h, textColor: PdfColors.white, bold: true, size: 9))
              .toList(),
        ),
        ...report.groupStats.asMap().entries.map((e) {
          final g = e.value;
          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: e.key.isOdd ? _rowAlt : PdfColors.white,
            ),
            children: [
              _cell('${e.key + 1}', align: pw.TextAlign.center, size: 9),
              _cell(g.groupName, size: 9),
              _cell(g.teacherName, size: 9),
              _cell('${g.activeStudents}', align: pw.TextAlign.center, size: 9),
              _cell(_money(g.expectedRevenue), align: pw.TextAlign.right, size: 9),
              _cell(_money(g.actualRevenue), align: pw.TextAlign.right, size: 9),
              _cell('${g.collectionRate.toStringAsFixed(0)}%',
                  align: pw.TextAlign.right, size: 9),
              _cell('${g.paidStudents}/${g.activeStudents}',
                  align: pw.TextAlign.center, size: 9),
            ],
          );
        }),
        // Totals row
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: _summaryBg),
          children: [
            _cell('', size: 9),
            _cell('Jami', bold: true, size: 9),
            _cell('', size: 9),
            _cell('${report.totalActiveStudents}',
                align: pw.TextAlign.center, bold: true, size: 9),
            _cell(_money(report.expectedRevenue),
                align: pw.TextAlign.right, bold: true, size: 9),
            _cell(_money(report.actualRevenue),
                align: pw.TextAlign.right, bold: true, size: 9),
            _cell('${report.collectionRate.toStringAsFixed(0)}%',
                align: pw.TextAlign.right, bold: true, size: 9),
            _cell('', size: 9),
          ],
        ),
      ],
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  static pw.Widget _cell(
    String text, {
    pw.TextAlign align = pw.TextAlign.left,
    bool bold = false,
    PdfColor textColor = PdfColors.black,
    double size = 10,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: size,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: textColor,
        ),
      ),
    );
  }

  static String _fmt(double amount) => "${_amountFormat.format(amount)} so'm";

  static String _money(double amount) => _amountFormat.format(amount);
}
