import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pallon_lastversion/Core/Utils/manager_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pallon_lastversion/Core/Utils/app.images.dart';
import 'package:pallon_lastversion/Core/Utils/share_download.dart';

class OfferWidget extends StatefulWidget {
  @override
  _OfferWidgetState createState() => _OfferWidgetState();
}

class _OfferWidgetState extends State<OfferWidget> {
  final _formKey = GlobalKey<FormState>();

  final List<ReportItem> _items = [];
  final List<String> _terms = [];

  final _nameController = TextEditingController();
  final _sizeController = TextEditingController();
  final _qtyController = TextEditingController();
  final _priceController = TextEditingController();

  final _companyController = TextEditingController();
  final _addressController = TextEditingController();
  final _deliveryController = TextEditingController();
  final _termController = TextEditingController();

  pw.Font? _arabicFont;

  @override
  void initState() {
    super.initState();
    _loadFont();
  }

  Future<void> _loadFont() async {
    final fontData = await rootBundle.load(AppImages.font);
    setState(() {
      _arabicFont = pw.Font.ttf(fontData);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sizeController.dispose();
    _qtyController.dispose();
    _priceController.dispose();
    _companyController.dispose();
    _addressController.dispose();
    _deliveryController.dispose();
    _termController.dispose();
    super.dispose();
  }


  void _addItem() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _items.add(
          ReportItem(
            name: _nameController.text,
            size: _sizeController.text,
            quantity: int.parse(_qtyController.text),
            unitPrice: double.parse(_priceController.text),
          ),
        );
        _nameController.clear();
        _sizeController.clear();
        _qtyController.clear();
        _priceController.clear();
      });
    }
  }

  void _addTerm() {
    if (_termController.text.trim().isNotEmpty) {
      setState(() {
        _terms.add(_termController.text.trim());
        _termController.clear();
      });
    }
  }


  Future<void> _generatePDF() async {
    if (_arabicFont == null) return;

    final pdf = pw.Document();
    double total = 0;
    final double delivery = double.tryParse(_deliveryController.text) ?? 0.0;

    final bgBytes = await rootBundle.load(AppImages.bgDots);
    final sigBytes = await rootBundle.load(AppImages.signature);
    final stampBytes = await rootBundle.load(AppImages.ketm);

    final bgImage = bgBytes.buffer.asUint8List();
    final sigImage = sigBytes.buffer.asUint8List();
    final stampImage = stampBytes.buffer.asUint8List();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (context) {
          return pw.FullPage(
            ignoreMargins: true,
            child: pw.Stack(
              children: [
                pw.Positioned.fill(
                  child: pw.Image(
                    pw.MemoryImage(bgImage),
                    fit: pw.BoxFit.cover,
                  ),
                ),

                pw.Padding(
                  padding: const pw.EdgeInsets.fromLTRB(32, 120, 32, 70),
                  child: pw.Directionality(
                    textDirection: pw.TextDirection.rtl,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: pw.BoxDecoration(
                            color: PdfColor.fromInt(0xFFED1C24),
                            borderRadius: pw.BorderRadius.circular(15),
                          ),
                          child: pw.Text(
                            'عرض سعر',
                            style: pw.TextStyle(
                              font: _arabicFont,
                              fontSize: 20,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white,
                            ),
                          ),
                        ),

                        pw.SizedBox(height: 20),

                        pw.Align(
                          alignment: pw.Alignment.centerRight,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'السادة / ${_companyController.text}',
                                style: pw.TextStyle(
                                  font: _arabicFont,
                                  fontSize: 14,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.Text(
                                'العنوان / ${_addressController.text}',
                                style: pw.TextStyle(
                                  font: _arabicFont,
                                  fontSize: 14,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.SizedBox(height: 8),
                              pw.Row(
                                mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Text(
                                    'يسرنا أن نقدم لكم عرض سعر وفق الآتي:',
                                    style: pw.TextStyle(
                                      font: _arabicFont,
                                      fontSize: 13,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                  pw.Text(
                                    'التاريخ: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                                    style: pw.TextStyle(
                                      font: _arabicFont,
                                      fontSize: 13,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        pw.SizedBox(height: 20),

                        pw.Table(
                          border: pw.TableBorder.all(
                            color: PdfColors.grey700,
                            width: 0.8,
                          ),
                          children: [
                            pw.TableRow(
                              decoration: const pw.BoxDecoration(
                                color: PdfColor.fromInt(0xFFED1C24),
                              ),
                              children: [
                                for (final header in [
                                  'المنتج',
                                  'المقاس',
                                  'الكمية',
                                  'سعر الوحدة',
                                  'الإجمالي'
                                ])
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(6),
                                    child: pw.Center(
                                      child: pw.Text(
                                        header,
                                        style: pw.TextStyle(
                                          font: _arabicFont,
                                          fontSize: 12,
                                          fontWeight: pw.FontWeight.bold,
                                          color: PdfColors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),

                            ..._items.map((item) {
                              total += item.total;
                              return pw.TableRow(
                                children: [
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(6),
                                    child: pw.Text(
                                      item.name,
                                      textAlign: pw.TextAlign.center,
                                      style: pw.TextStyle(
                                        font: _arabicFont,
                                        fontSize: 11,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(6),
                                    child: pw.Text(
                                      item.size,
                                      textAlign: pw.TextAlign.center,
                                      style: pw.TextStyle(
                                        font: _arabicFont,
                                        fontSize: 11,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(6),
                                    child: pw.Text(
                                      item.quantity.toString(),
                                      textAlign: pw.TextAlign.center,
                                      style: pw.TextStyle(
                                        font: _arabicFont,
                                        fontSize: 11,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(6),
                                    child: pw.Text(
                                      item.unitPrice.toStringAsFixed(2),
                                      textAlign: pw.TextAlign.center,
                                      style: pw.TextStyle(
                                        font: _arabicFont,
                                        fontSize: 11,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(6),
                                    child: pw.Text(
                                      item.total.toStringAsFixed(2),
                                      textAlign: pw.TextAlign.center,
                                      style: pw.TextStyle(
                                        font: _arabicFont,
                                        fontSize: 11,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),

                            pw.TableRow(
                              decoration:
                              const pw.BoxDecoration(color: PdfColors.grey200),
                              children: [
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(6),
                                  child: pw.Text(
                                    'خدمة التوصيل',
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                      font: _arabicFont,
                                      fontSize: 11,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                ),
                                pw.Container(),
                                pw.Container(),
                                pw.Container(),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(6),
                                  child: pw.Text(
                                    delivery.toStringAsFixed(2),
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                      font: _arabicFont,
                                      fontSize: 11,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            pw.TableRow(
                              decoration: const pw.BoxDecoration(
                                color: PdfColor.fromInt(0xFFFFD5D5),
                              ),
                              children: [
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(6),
                                  child: pw.Text(
                                    'الإجمالي شامل الضريبة',
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                      font: _arabicFont,
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                pw.Container(),
                                pw.Container(),
                                pw.Container(),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(6),
                                  child: pw.Text(
                                    (total + delivery).toStringAsFixed(2),
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                      font: _arabicFont,
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        pw.SizedBox(height: 25),

                        pw.Align(
                          alignment: pw.Alignment.centerRight,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              pw.Text(
                                'الشروط والأحكام:',
                                style: pw.TextStyle(
                                  font: _arabicFont,
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              pw.SizedBox(height: 8),
                              if (_terms.isEmpty)
                                pw.Text(
                                  'لا توجد شروط مضافة',
                                  style: pw.TextStyle(
                                    font: _arabicFont,
                                    fontSize: 12,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                )
                              else
                                pw.Column(
                                  crossAxisAlignment:
                                  pw.CrossAxisAlignment.start,
                                  children: _terms.asMap().entries.map((e) {
                                    return pw.Padding(
                                      padding:
                                      const pw.EdgeInsets.symmetric(vertical: 3),
                                      child: pw.Text(
                                        '${e.key + 1}. ${e.value}',
                                        textAlign: pw.TextAlign.right,
                                        style: pw.TextStyle(
                                          font: _arabicFont,
                                          fontSize: 12,
                                          fontWeight: pw.FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                            ],
                          ),
                        ),

                        pw.SizedBox(height: 25),

                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Column(
                              children: [
                                pw.Text(
                                  'الختم',
                                  style: pw.TextStyle(
                                    font: _arabicFont,
                                    fontSize: 13,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                                pw.SizedBox(height: 4),
                                pw.Image(
                                  pw.MemoryImage(stampImage),
                                  width: 80,
                                  height: 80,
                                ),
                              ],
                            ),
                            pw.Column(
                              children: [
                                pw.Text(
                                  'التوقيع الرقمي',
                                  style: pw.TextStyle(
                                    font: _arabicFont,
                                    fontSize: 13,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                                pw.SizedBox(height: 4),
                                pw.Image(
                                  pw.MemoryImage(sigImage),
                                  width: 100,
                                  height: 60,
                                ),
                              ],
                            ),
                          ],
                        ),

                        pw.SizedBox(height: 18),

                        pw.Container(
                          width: double.infinity,
                          alignment: pw.Alignment.center,
                          child: pw.Text(
                            'المملكة العربية السعودية - جدة - طريق المدينة بجوار حلويات سعد الدين - جوال : 0541773777\n'
                                'المملكة العربية السعودية - جدة - حي الروضة طريق المدينة بجوار كوبري المربع\n'
                                'الحساب البنكي : مؤسسة بالون الهدية للتجارة - البنك الأهلي السعودي\n'
                                'رقم الحساب : 01400005936606 - ايبان : SA5310000001400005936606\n'
                                'جدة - حي البساتين طريق الأمير سلطان مقابل القصر\n'
                                'الحساب البنكي: مؤسسة بالون الهدية للتجارة - البنك الأهلي السعودي\n'
                                'رقم الحساب: 01400029060503 - ايبان: SA8710000001400029060503',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              font: _arabicFont,
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    final bytes = await pdf.save();
    await shareOrDownloadBytes(
      bytes: bytes,
      filename: 'offer.pdf',
      mimeType: 'application/pdf',
      text: 'عرض السعر',
    );
  }


  @override
  Widget build(BuildContext context) {
    if (_arabicFont == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          children: [
            Container(
              height: screenHeight * 0.25,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF07933E), Color(0xFF007530)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.08,
                vertical: screenHeight * 0.05,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenHeight * 0.04),
                  Text(
                    'Create Offer Price'.tr,
                    style: TextStyle(
                      fontFamily: ManagerFontFamily.fontFamily,

                      fontSize: screenWidth * 0.08,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Create a professional offer as PDF and share it.'
                        .tr,
                    style: TextStyle(
                      fontFamily: ManagerFontFamily.fontFamily,
                      fontSize: screenWidth * 0.04,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Card(
                color: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 12,
                    children: [
                      _buildTextField(
                        _companyController,
                        'Company Name'.tr,
                        false,
                      ),
                      _buildTextField(
                        _addressController,
                        'Address'.tr,
                        false,
                      ),
                      _buildTextField(
                        _deliveryController,
                        'Delivery Price'.tr,
                        true,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Card(
                color: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add Item'.tr,
                          style:  TextStyle(
                            fontFamily: ManagerFontFamily.fontFamily,

                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 12,
                          children: [
                            _buildTextField(
                              _nameController,
                              'Item'.tr,
                              false,
                            ),
                            _buildTextField(
                              _sizeController,
                              'Size'.tr,
                              false,
                            ),
                            _buildTextField(
                              _qtyController,
                              'Count'.tr,
                              true,
                            ),
                            _buildTextField(
                              _priceController,
                              'Price'.tr,
                              true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: ElevatedButton.icon(
                            onPressed: _addItem,
                            icon: const Icon(Icons.add),
                            label: Text('Add'.tr,style: TextStyle(
                              fontFamily: ManagerFontFamily.fontFamily,

                            ),),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF07933E),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            if (_items.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Card(
                  color: Colors.white,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Items Preview'.tr,
                          style:  TextStyle(
                            fontFamily: ManagerFontFamily.fontFamily,

                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            border: TableBorder.all(
                              color: Colors.grey.shade300,
                            ),
                            headingRowColor: MaterialStateProperty.all(
                              Colors.green[100],
                            ),
                            columns: [
                              DataColumn(label: Text('المنتج'.tr,style: TextStyle(
                                fontFamily: ManagerFontFamily.fontFamily,

                              ),)),
                              DataColumn(label: Text('المقاس'.tr,style: TextStyle(
                                fontFamily: ManagerFontFamily.fontFamily,

                              ),)),
                              DataColumn(label: Text('الكمية'.tr,style: TextStyle(
                                fontFamily: ManagerFontFamily.fontFamily,

                              ),)),
                              DataColumn(label: Text('سعر الوحدة'.tr,style: TextStyle(
                                fontFamily: ManagerFontFamily.fontFamily,

                              ),)),
                              DataColumn(label: Text('الإجمالي'.tr,style: TextStyle(
                                fontFamily: ManagerFontFamily.fontFamily,

                              ),)),
                            ],
                            rows: _items
                                .map(
                                  (item) => DataRow(
                                cells: [
                                  DataCell(Text(item.name,style: TextStyle(
                                    fontFamily: ManagerFontFamily.fontFamily,

                                  ),)),
                                  DataCell(Text(item.size,style: TextStyle(
                                    fontFamily: ManagerFontFamily.fontFamily,

                                  ),)),
                                  DataCell(Text(item.quantity.toString(),style: TextStyle(
                                    fontFamily: ManagerFontFamily.fontFamily,

                                  ),)),
                                  DataCell(
                                    Text(
                                      item.unitPrice.toStringAsFixed(2),style: TextStyle(
                                    fontFamily: ManagerFontFamily.fontFamily,

                                    ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(item.total.toStringAsFixed(2),style: TextStyle(
                                      fontFamily: ManagerFontFamily.fontFamily,

                                    ),),
                                  ),
                                ],
                              ),
                            )
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Card(
                color: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add Terms of Use'.tr,
                        style:  TextStyle(

    fontFamily: ManagerFontFamily.fontFamily,


                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              style: TextStyle(
                                fontFamily: ManagerFontFamily.fontFamily,

                              ),
                              controller: _termController,
                              decoration: InputDecoration(
                                labelText: 'Enter term...'.tr,
                                labelStyle: TextStyle(
                                  fontFamily: ManagerFontFamily.fontFamily,

                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _addTerm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF07933E),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text('Add'.tr,style: TextStyle(
                              fontFamily: ManagerFontFamily.fontFamily,

                            ),),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (_terms.isNotEmpty)
                        Column(
                          children: _terms.asMap().entries.map((entry) {
                            return ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                '${entry.key + 1}. ${entry.value}',
                                style: TextStyle(
                                  fontFamily: ManagerFontFamily.fontFamily,

                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _terms.removeAt(entry.key);
                                  });
                                },
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _generatePDF,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: Text('Export as PDF'.tr,style: TextStyle(
                    fontFamily: ManagerFontFamily.fontFamily,

                  ),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCE232B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }


  Widget _buildTextField(
      TextEditingController c, String label, bool isNumber) {
    return SizedBox(
      width: 180,
      child: TextFormField(
        style: TextStyle(
          fontFamily: ManagerFontFamily.fontFamily,

        ),
        controller: c,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontFamily: ManagerFontFamily.fontFamily,

          ),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        validator: (v) => v == null || v.trim().isEmpty ? 'مطلوب'.tr : null,
      ),
    );
  }
}


class ReportItem {
  final String name;
  final String size;
  final int quantity;
  final double unitPrice;

  ReportItem({
    required this.name,
    required this.size,
    required this.quantity,
    required this.unitPrice,
  });

  double get total => quantity * unitPrice;
}
