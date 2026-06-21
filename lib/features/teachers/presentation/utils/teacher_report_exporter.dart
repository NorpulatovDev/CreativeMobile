import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../data/models/teacher_monthly_report_model.dart';

class TeacherReportExporter {
  static final _amountFormat = NumberFormat('#,###');
  static final _dateFormat = DateFormat('dd.MM.yyyy');
  static final _monthFormat = DateFormat('MMMM yyyy');

  static const _headerColor = PdfColor.fromInt(0xFF3B5BDB);
  static const _groupBg = PdfColor.fromInt(0xFFE8ECFD);
  static const _rowAlt = PdfColor.fromInt(0xFFF1F3F5);
  static const _unpaidHeaderColor = PdfColor.fromInt(0xFFE03131);
  static const _unpaidRowAlt = PdfColor.fromInt(0xFFFFF5F5);
  static const _unpaidBorder = PdfColor.fromInt(0xFFFFCDD2);

  static Future<void> sharePdf(TeacherMonthlyReport report) async {
    final pdf = pw.Document();

    final paymentsByGroup = <String, List<TeacherPaymentItem>>{};
    for (final p in report.payments) {
      paymentsByGroup.putIfAbsent(p.groupName, () => []).add(p);
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(report),
          pw.SizedBox(height: 16),
          _buildSummaryTable(report),
          pw.SizedBox(height: 20),
          _buildMonthLabel(report),
          pw.SizedBox(height: 12),
          // Each widget in the list is a direct MultiPage child so tables
          // can paginate correctly — no wrapping pw.Column here.
          ...report.groups.expand((group) {
            final payments = paymentsByGroup[group.groupName] ?? [];
            return _buildGroupWidgets(group, payments);
          }),
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
    final file = File('${dir.path}/${report.teacherName}_$monthKey.pdf');
    await file.writeAsBytes(bytes);

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/pdf')],
      subject: "${report.teacherName} - To'lovlar hisoboti ($monthKey)",
    );
  }

  // ── Header / summary ─────────────────────────────────────────────────────

  static pw.Widget _buildHeader(TeacherMonthlyReport report) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          "${report.teacherName} - To'lovlar hisoboti",
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          report.phoneNumber,
          style: pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }

  static pw.Widget _buildSummaryTable(TeacherMonthlyReport report) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: [
        pw.TableRow(children: [
          _cell("Jami to'lovlar soni"),
          _cell('${report.totalPaymentsCount}', align: pw.TextAlign.right),
        ]),
        pw.TableRow(children: [
          _cell('Jami summa'),
          _cell(_fmt(report.totalAmount), align: pw.TextAlign.right, bold: true),
        ]),
      ],
    );
  }

  static pw.Widget _buildMonthLabel(TeacherMonthlyReport report) {
    final label = _monthFormat.format(DateTime(report.year, report.month));
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 2),
        pw.Text(
          "${report.totalPaymentsCount} ta to'lov | ${_fmt(report.totalAmount)}",
          style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
        ),
      ],
    );
  }

  // ── Per-group widgets (flat list — no wrapping Column) ────────────────────

  static List<pw.Widget> _buildGroupWidgets(
    TeacherGroupMonthlyStats group,
    List<TeacherPaymentItem> payments,
  ) {
    return [
      // Group header bar
      pw.Container(
        decoration: const pw.BoxDecoration(color: _groupBg),
        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              group.groupName,
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              "${group.paidStudents}/${group.activeStudents} to'ladi | ${_fmt(group.actualRevenue)}",
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey800),
            ),
          ],
        ),
      ),

      // Paid payments table (or empty notice)
      if (payments.isEmpty)
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: pw.Text(
            "Bu oy uchun to'lovlar yo'q",
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey500,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
        )
      else
        pw.Table(
          columnWidths: const {
            0: pw.FixedColumnWidth(32),
            1: pw.FlexColumnWidth(3),
            2: pw.FlexColumnWidth(2),
            3: pw.FlexColumnWidth(1.5),
          },
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: _headerColor),
              children: ['#', "O'quvchi", 'Summa', 'Sana']
                  .map((h) => _cell(h, textColor: PdfColors.white, bold: true))
                  .toList(),
            ),
            ...payments.asMap().entries.map((e) => pw.TableRow(
                  decoration: pw.BoxDecoration(
                      color: e.key.isOdd ? _rowAlt : PdfColors.white),
                  children: [
                    _cell('${e.key + 1}', align: pw.TextAlign.center),
                    _cell(e.value.studentName),
                    _cell(_fmt(e.value.amount), align: pw.TextAlign.right),
                    _cell(_dateFormat.format(e.value.paidAt)),
                  ],
                )),
          ],
        ),

      // Unpaid students table
      if (group.unpaidStudentList.isNotEmpty) ...[
        pw.SizedBox(height: 4),
        pw.Table(
          columnWidths: const {
            0: pw.FixedColumnWidth(32),
            1: pw.FlexColumnWidth(3),
            2: pw.FlexColumnWidth(2),
            3: pw.FlexColumnWidth(2),
          },
          border: pw.TableBorder.all(color: _unpaidBorder, width: 0.5),
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: _unpaidHeaderColor),
              children: ['#', "To'lamagan o'quvchi", "To'lagan", 'Qoldiq']
                  .map((h) => _cell(h, textColor: PdfColors.white, bold: true))
                  .toList(),
            ),
            ...group.unpaidStudentList.asMap().entries.map((e) => pw.TableRow(
                  decoration: pw.BoxDecoration(
                      color: e.key.isOdd ? _unpaidRowAlt : PdfColors.white),
                  children: [
                    _cell('${e.key + 1}', align: pw.TextAlign.center),
                    _cell(e.value.studentName),
                    _cell(
                      e.value.amountPaid > 0 ? _fmt(e.value.amountPaid) : '-',
                      align: pw.TextAlign.right,
                    ),
                    _cell(_fmt(e.value.amountDue),
                        align: pw.TextAlign.right, bold: true),
                  ],
                )),
          ],
        ),
      ],

      pw.SizedBox(height: 16),
    ];
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static pw.Widget _cell(
    String text, {
    pw.TextAlign align = pw.TextAlign.left,
    bool bold = false,
    PdfColor textColor = PdfColors.black,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: textColor,
        ),
      ),
    );
  }

  static String _fmt(double amount) => "${_amountFormat.format(amount)} so'm";
}
