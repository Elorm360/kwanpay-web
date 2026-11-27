import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/kyc_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/money_error.dart';
import '../../../core/widgets/kwan_text_field.dart';
import '../../../core/widgets/primary_button.dart';

enum _Shot { front, back, selfie }

class VerifyIdScreen extends ConsumerStatefulWidget {
  const VerifyIdScreen({super.key});

  @override
  ConsumerState<VerifyIdScreen> createState() => _VerifyIdScreenState();
}

class _VerifyIdScreenState extends ConsumerState<VerifyIdScreen> {
  final _numberController = TextEditingController();
  final _picker = ImagePicker();
  final Map<_Shot, Uint8List> _photos = {};
  KycDocumentType _type = KycDocumentType.ghanaCard;
  bool _sending = false;
  String? _error;

  bool get _needsBack => _type == KycDocumentType.ghanaCard;

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  String _shotTitle(_Shot shot) => switch (shot) {
    _Shot.front =>
      _type == KycDocumentType.ghanaCard ? 'Front of the card' : 'Photo page',
    _Shot.back => 'Back of the card',
    _Shot.selfie => 'A photo of you',
  };

  String _shotHint(_Shot shot) => switch (shot) {
    _Shot.front ||
    _Shot.back => 'Flat, in good light, all four corners showing',
    _Shot.selfie => 'Face the camera, no hat or sunglasses',
  };

  Future<void> _take(_Shot shot) async {
    ImageSource? source = ImageSource.camera;
    if (shot != _Shot.selfie) {
      source = await showModalBottomSheet<ImageSource>(
        context: context,
        showDragHandle: true,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Take a photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from your photos'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );
      if (source == null) return;
    }

    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 80,
        preferredCameraDevice: shot == _Shot.selfie
            ? CameraDevice.front
            : CameraDevice.rear,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _photos[shot] = bytes;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _error =
            'We could not open the camera. Check that KwanPay may use it in your phone settings.',
      );
    }
  }

  String? _problem() {
    final number = _numberController.text.replaceAll(RegExp(r'\s'), '');
    if (number.isEmpty) {
      return 'Enter your ${_type.label} number.';
    }
    if (_type == KycDocumentType.ghanaCard &&
        !RegExp(r'^GHA-?\d{9}-?\d$', caseSensitive: false).hasMatch(number)) {
      return 'Enter the card number as shown, e.g. GHA-123456789-0.';
    }
    for (final shot in _requiredShots) {
      if (!_photos.containsKey(shot)) {
        return 'Add: ${_shotTitle(shot).toLowerCase()}.';
      }
    }
    return null;
  }

  List<_Shot> get _requiredShots => [
    _Shot.front,
    if (_needsBack) _Shot.back,
    _Shot.selfie,
  ];

  Future<void> _submit() async {
    final problem = _problem();
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      final service = ref.read(kycServiceProvider);
      final front = await service.uploadPhoto(_photos[_Shot.front]!, 'front');
      final back = _needsBack
          ? await service.uploadPhoto(_photos[_Shot.back]!, 'back')
          : null;
      final selfie = await service.uploadPhoto(
        _photos[_Shot.selfie]!,
        'selfie',
      );
      await service.submit(
        type: _type,
        documentNumber: _numberController.text,
        frontPath: front,
        backPath: back,
        selfiePath: selfie,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sent. We will raise your limits once it is checked.'),
        ),
      );
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _error = moneyErrorMessage(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(title: const Text('Verify your ID')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          children: [
            Text(
              'We need to see one ID and your face, so we know it is really you. Only the KwanPay review team can see these photos.',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SegmentedButton<KycDocumentType>(
              showSelectedIcon: false,
              style: SegmentedButton.styleFrom(
                backgroundColor: AppColors.surface,
                foregroundColor: AppColors.textPrimary,
                selectedBackgroundColor: AppColors.primary,
                selectedForegroundColor: Colors.white,
                side: const BorderSide(color: AppColors.border),
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
                minimumSize: const Size.fromHeight(48),
              ),
              segments: [
                for (final type in KycDocumentType.values)
                  ButtonSegment(value: type, label: Text(type.label)),
              ],
              selected: {_type},
              onSelectionChanged: _sending
                  ? null
                  : (value) => setState(() {
                      _type = value.first;
                      _photos.remove(_Shot.back);
                      _error = null;
                    }),
            ),
            const SizedBox(height: AppSpacing.lg),
            KwanTextField(
              label: '${_type.label} number',
              icon: Icons.badge_outlined,
              controller: _numberController,
            ),
            const SizedBox(height: AppSpacing.lg),
            for (final shot in _requiredShots) ...[
              _PhotoSlot(
                title: _shotTitle(shot),
                hint: _shotHint(shot),
                icon: shot == _Shot.selfie
                    ? Icons.face_outlined
                    : Icons.credit_card_outlined,
                photo: _photos[shot],
                onTap: _sending ? null : () => _take(shot),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                _error!,
                style: AppTextStyles.body.copyWith(color: AppColors.error),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            IgnorePointer(
              ignoring: _sending,
              child: Opacity(
                opacity: _sending ? 0.6 : 1,
                child: PrimaryButton(
                  text: _sending ? 'Sending…' : 'Send for review',
                  onPressed: _submit,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoSlot extends StatelessWidget {
  final String title;
  final String hint;
  final IconData icon;
  final Uint8List? photo;
  final VoidCallback? onTap;

  const _PhotoSlot({
    required this.title,
    required this.hint,
    required this.icon,
    required this.photo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final done = photo != null;
    return Semantics(
      button: true,
      label: done ? '$title, added. Tap to retake.' : '$title. $hint',
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.medium),
              border: Border.all(
                color: done ? AppColors.success : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.small),
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: done
                        ? Image.memory(photo!, fit: BoxFit.cover)
                        : ColoredBox(
                            color: AppColors.paper,
                            child: Icon(icon, color: AppColors.textSecondary),
                          ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        done ? 'Added. Tap to retake.' : hint,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  done
                      ? Icons.check_circle_rounded
                      : Icons.add_a_photo_outlined,
                  color: done ? AppColors.success : AppColors.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
