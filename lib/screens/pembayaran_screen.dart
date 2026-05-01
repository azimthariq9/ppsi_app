import 'package:flutter/material.dart';

class PembayaranScreen extends StatefulWidget {
  const PembayaranScreen({super.key});

  @override
  State<PembayaranScreen> createState() => _PembayaranScreenState();
}

class _PembayaranScreenState extends State<PembayaranScreen> {
  String selectedMethod = 'QRIS';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Total
            const Text(
              'Total Pembayaran',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 5),
            const Text(
              'Rp 50.000',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 20),

            /// Pilih metode
            const Text(
              'Metode Pembayaran',
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 10),

            _buildMethodTile('QRIS'),
            _buildMethodTile('Transfer Bank'),
            _buildMethodTile('Cash'),

            const SizedBox(height: 20),

            /// Konten sesuai metode
            Expanded(
              child: _buildPaymentContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodTile(String method) {
    return Card(
      child: RadioListTile(
        value: method,
        groupValue: selectedMethod,
        title: Text(method),
        onChanged: (value) {
          setState(() {
            selectedMethod = value.toString();
          });
        },
      ),
    );
  }

  Widget _buildPaymentContent() {
    if (selectedMethod == 'QRIS') {
      return Column(
        children: [
          const Text(
            'Scan QR Code berikut untuk pembayaran',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          /// QR IMAGE
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset(
              'assets/qris.png',
              height: 200,
              width: 200,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Pastikan nominal sesuai sebelum melakukan pembayaran',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      );
    }

    if (selectedMethod == 'Transfer Bank') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Bank BCA'),
          SizedBox(height: 5),
          Text('No Rekening: 1234567890'),
          SizedBox(height: 5),
          Text('A/N: RT 03 RW 011'),
        ],
      );
    }

    return const Center(
      child: Text('Silakan bayar langsung ke petugas'),
    );
  }
}