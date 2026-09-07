import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ReimbursementProApp());
}

class ReimbursementProApp extends StatelessWidget {
  const ReimbursementProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LegacyHtmlScreen(),
    );
  }
}

class LegacyHtmlScreen extends StatefulWidget {
  const LegacyHtmlScreen({super.key});

  @override
  State<LegacyHtmlScreen> createState() => _LegacyHtmlScreenState();
}

class _LegacyHtmlScreenState extends State<LegacyHtmlScreen> {
  static const String _viewType = 'reimbursement-pro-legacy-html';
  static bool _registered = false;

  @override
  void initState() {
    super.initState();
    if (_registered) return;

    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final iframe = html.IFrameElement()
        ..src = Uri.base.resolve('assets/assets/ReimbursementPro.html').toString()
        ..style.border = '0'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allow = 'clipboard-read; clipboard-write';
      return iframe;
    });

    _registered = true;
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SizedBox.expand(
        child: HtmlElementView(viewType: _viewType),
      ),
    );
  }
}
