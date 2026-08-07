import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../accounts/data/models/customer_account_model.dart';
import '../../../accounts/presentation/providers/accounts_provider.dart';

class SourceAccountSelector extends ConsumerWidget {
  const SourceAccountSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final CustomerAccount? selected;
  final ValueChanged<CustomerAccount> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(customerAccountsProvider);

    return GestureDetector(
      onTap: () async {
        final account = await _showAccountPicker(context, ref, accountsAsync);
        if (account != null) onSelected(account);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                color: AppColors.primaryGreen,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'From Account',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (selected == null)
                    Text(
                      'Select an account to debit',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  else ...[
                    Text(
                      selected!.productName,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_maskAccount(selected!.accountId)} • Available '
                      '${selected!.availableBalance?.toStringAsFixed(3) ?? 'N/A'} '
                      '${selected!.currencyId}',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Future<CustomerAccount?> _showAccountPicker(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<CustomerAccount>> accountsAsync,
  ) {
    return showModalBottomSheet<CustomerAccount>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AccountPickerSheet(accounts: accountsAsync),
    );
  }

  String _maskAccount(String accountId) {
    if (accountId.length <= 4) return accountId;
    return '••••${accountId.substring(accountId.length - 4)}';
  }
}

class _AccountPickerSheet extends StatelessWidget {
  const _AccountPickerSheet({required this.accounts});

  final AsyncValue<List<CustomerAccount>> accounts;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                'Select From Account',
                style: AppTypography.h5.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Flexible(
              child: accounts.when(
                data: (list) {
                  if (list.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('No accounts available.'),
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    itemCount: list.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final account = list[index];
                      return _AccountTile(
                        account: account,
                        onTap: () => Navigator.of(context).pop(account),
                      );
                    },
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primaryGreen),
                  ),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'Unable to load accounts.',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({required this.account, required this.onTap});

  final CustomerAccount account;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.lightBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_rounded,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.productName,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${account.currencyId} • ${account.accountId}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                account.availableBalance != null
                    ? '${account.availableBalance!.toStringAsFixed(2)} '
                        '${account.currencyId}'
                    : 'N/A',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}