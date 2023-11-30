import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer';
import 'dart:io';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared/page_title_widget.dart';
import 'package:shared/server_url_notifier.dart';
import 'package:shared/snack.dart';
import 'package:shared/theme/app_theme.dart';

class QRScanner extends StatefulWidget {
  const QRScanner({super.key});

  @override
  State<StatefulWidget> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller!.resumeCamera();
        },
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
        child: Icon(
          Icons.restart_alt,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      body: Column(
        children: [
          const PageTitleWidget(
            title: 'Scan QR Code',
          ),
          Expanded(
            child: _buildQrView(context),
          ),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    // 3/4 of screen width
    final scanArea = MediaQuery.of(context).size.width * 0.75;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: SurfaceVariant.bg(context),
          borderRadius: 20,
          borderLength: 40,
          borderWidth: 10,
          overlayColor: SurfaceVariant.fg(context),
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });

    if (!mounted) {
      return;
    }

    controller.scannedDataStream.listen(onScanData);
  }

  void onScanData(scanData) {
    controller!.pauseCamera();
    setState(() {
      result = scanData;
    });
    if (result == null) {
      return;
    }
    Provider.of<ServerUrlNotifier>(context, listen: false)
        .tryCandidate(result!.code.toString())
        .onError(onServerUrlErr)
        .then((_) => {
              // Show toast that is connected to the server
              snack(context, 'Connected to ${result!.code.toString()}')
            });
  }

  onServerUrlErr(Object? e, StackTrace? stackTrace) {
    log('onServerUrlErr $e');
    if (e is FormatException) {
      snack(context, 'Invalid URL');
      controller?.resumeCamera();
      return;
    }
    snack(context, 'Unknown Error ${e.toString()}}');
    result = null;
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      snackErr(context, 'no Permission');
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
