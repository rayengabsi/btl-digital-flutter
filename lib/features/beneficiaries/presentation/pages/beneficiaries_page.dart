import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/beneficiary_model.dart';
import '../providers/beneficiaries_provider.dart';


class BeneficiariesPage extends ConsumerWidget {
  const BeneficiariesPage({super.key, this.onNavTap});

  final ValueChanged<int>? onNavTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final beneficiariesAsync = ref.watch(beneficiariesListProvider);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('My Beneficiaries'),
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddOrEditDialog(context, ref),
        backgroundColor: AppColors.primaryGreen,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Add Beneficiary', style: AppTypography.buttonMedium.copyWith(color: Colors.white)),
      ),
      body: SafeArea(
        child: beneficiariesAsync.when(
          data: (list) {
            if (list.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.people_outline_rounded,
                          size: 48,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text('No Beneficiaries Yet', style: AppTypography.h3),
                      const SizedBox(height: 8),
                      Text(
                        'Add trusted bank accounts with a 20-digit RIB for fast intra transfers.',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(beneficiariesListProvider),
              color: AppColors.primaryGreen,
              child: ListView.separated(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                itemCount: list.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = list[index];
                  return _BeneficiaryCard(
                    beneficiary: item,
                    onEdit: () => _showAddOrEditDialog(context, ref, beneficiary: item),
                    onDelete: () => _confirmDelete(context, ref, item),
                  );
                },
              ),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen),
          ),
          error: (err, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.primaryRed),
                const SizedBox(height: 12),
                Text('Failed to load beneficiaries', style: AppTypography.h3),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(beneficiariesListProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddOrEditDialog(
    BuildContext context,
    WidgetRef ref, {
    Beneficiary? beneficiary,
  }) {
    final isEdit = beneficiary != null;
    final nameCtrl = TextEditingController(text: beneficiary?.beneficiaryName ?? '');
    final ribCtrl = TextEditingController(text: beneficiary?.ribNumber ?? '');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        bool isSubmitting = false;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEdit ? 'Edit Beneficiary' : 'Add New Beneficiary',
                      style: AppTypography.h3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Beneficiary Full Name',
                        hintText: 'e.g. Mohamed Ali',
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: ribCtrl,
                      keyboardType: TextInputType.number,
                      maxLength: 20,
                      decoration: const InputDecoration(
                        labelText: 'RIB Number (20 Digits)',
                        hintText: '12345678901234567897',
                        counterText: '',
                      ),
                      validator: (v) {
                        final digits = (v ?? '').replaceAll(RegExp(r'\D'), '');
                        if (digits.length != 20) {
                          return 'Tunisian RIB must contain exactly 20 digits';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;
                                final messenger = ScaffoldMessenger.of(context);
                                final navigator = Navigator.of(context);
                                setModalState(() => isSubmitting = true);

                                try {
                                  if (isEdit) {
                                    await ref
                                        .read(beneficiariesListProvider.notifier)
                                        .updateBeneficiary(
                                          id: beneficiary.id,
                                          name: nameCtrl.text,
                                          ribNumber: ribCtrl.text,
                                        );
                                  } else {
                                    await ref
                                        .read(beneficiariesListProvider.notifier)
                                        .addBeneficiary(
                                          name: nameCtrl.text,
                                          ribNumber: ribCtrl.text,
                                        );
                                  }
                                  navigator.pop();
                                } catch (e) {
                                  setModalState(() => isSubmitting = false);
                                  final msg = e is ApiException ? e.message : 'Error saving beneficiary';
                                  messenger.showSnackBar(
                                    SnackBar(content: Text(msg), backgroundColor: AppColors.primaryRed),
                                  );
                                }

                              },
                        child: isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(isEdit ? 'Save Changes' : 'Add Beneficiary'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Beneficiary item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Beneficiary'),
        content: Text('Are you sure you want to delete "${item.beneficiaryName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref
                    .read(beneficiariesListProvider.notifier)
                    .deleteBeneficiary(item.id);
              } catch (e) {
                final msg = e is ApiException ? e.message : 'Failed to delete';
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(msg), backgroundColor: AppColors.primaryRed),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.primaryRed)),
          ),
        ],
      ),
    );
  }
}

class _BeneficiaryCard extends StatelessWidget {
  const _BeneficiaryCard({
    required this.beneficiary,
    required this.onEdit,
    required this.onDelete,
  });

  final Beneficiary beneficiary;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final initials = beneficiary.beneficiaryName.isNotEmpty
        ? beneficiary.beneficiaryName
            .trim()
            .split(' ')
            .map((e) => e[0])
            .take(2)
            .join('')
            .toUpperCase()
        : 'B';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.1),
              child: Text(
                initials,
                style: AppTypography.h3.copyWith(
                  fontSize: 16,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    beneficiary.beneficiaryName,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'RIB: ${beneficiary.ribNumber}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.textSecondary, size: 20),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.primaryRed, size: 20),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
