import 'package:flutter/material.dart';

import '../theme/app_brand.dart';

class BarcodeNotFoundScreen extends StatelessWidget {
  final String barcode;

  const BarcodeNotFoundScreen({
    super.key,
    required this.barcode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppBrand.loginBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 24, 30, 24),
          child: Column(
            children: [
              const _BarcodeNotFoundHeader(),
              const Spacer(),
              const _NotFoundGraphic(),
              const SizedBox(height: 36),
              Text(
                barcode,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppBrand.textDarkGrey,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'This Barcode not in the POS',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppBrand.textDarkGrey,
                ),
              ),
              const Spacer(),
              _ActionButton(
                icon: Icons.add_circle,
                label: 'Add New Product',
                onPressed: () {
                  Navigator.pop(context, true);
                },
              ),
              const SizedBox(height: 18),
              _ActionButton(
                icon: Icons.qr_code_scanner,
                label: 'Scan Again',
                onPressed: () {
                  Navigator.pop(context, false);
                },
              ),
              const SizedBox(height: 34),
              const _BarcodeNotFoundFooter(),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarcodeNotFoundHeader extends StatelessWidget {
  const _BarcodeNotFoundHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SizedBox(width: 48),
        Expanded(
          child: Text(
            'Barcode Not Found',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppBrand.textDarkGrey,
            ),
          ),
        ),
        CircleAvatar(
          radius: 24,
          backgroundColor: AppBrand.primaryLight,
          child: Icon(Icons.person_outline, color: AppBrand.primary),
        ),
      ],
    );
  }
}

class _NotFoundGraphic extends StatelessWidget {
  const _NotFoundGraphic();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 300,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 300,
            height: 300,
            decoration: const BoxDecoration(
              color: AppBrand.white,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: _BarcodeBars(),
            ),
          ),
          Positioned(
            top: 10,
            right: 26,
            child: Container(
              width: 58,
              height: 58,
              decoration: const BoxDecoration(
                color: AppBrand.primaryDark,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: AppBrand.white,
                size: 38,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarcodeBars extends StatelessWidget {
  const _BarcodeBars();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: const [
        _BarcodeBar(width: 22, height: 126),
        SizedBox(width: 10),
        _BarcodeBar(width: 16, height: 126),
        SizedBox(width: 14),
        _BarcodeBar(width: 22, height: 126),
        SizedBox(width: 14),
        _BarcodeBar(width: 16, height: 126),
        SizedBox(width: 14),
        _BarcodeBar(width: 16, height: 126),
      ],
    );
  }
}

class _BarcodeBar extends StatelessWidget {
  final double width;
  final double height;

  const _BarcodeBar({
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppBrand.primaryDark,
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 74,
      child: FilledButton(
        onPressed: onPressed,
        child: Row(
          children: [
            const Spacer(),
            Icon(icon, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, size: 42),
          ],
        ),
      ),
    );
  }
}

class _BarcodeNotFoundFooter extends StatelessWidget {
  const _BarcodeNotFoundFooter();

  @override
  Widget build(BuildContext context) {
    return const Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Powered By ',
            style: TextStyle(
              color: AppBrand.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          TextSpan(
            text: 'OrangePos',
            style: TextStyle(
              color: AppBrand.primary,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}