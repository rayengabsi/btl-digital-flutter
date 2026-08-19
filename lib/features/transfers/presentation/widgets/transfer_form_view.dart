import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../accounts/data/models/customer_account_model.dart';
import '../../../beneficiaries/data/models/beneficiary_model.dart';
import '../providers/transfer_mock_providers.dart';
import '../providers/transfers_provider.dart';
import '../providers/transfers_state.dart';
import 'beneficiary_selector.dart';
import 'source_account_selector.dart';

class TransferFormView extends ConsumerStatefulWidget {
  const TransferFormView({super.key});

  @override
  ConsumerState<TransferFormView> createState() => _TransferFormViewState();
}

class _TransferFormViewState extends ConsumerState<TransferFormView> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _detailCtrl = TextEditingController();

  CustomerAccount? _sourceAccount;
  Beneficiary? _beneficiary;

  @override
  void initState() {
    super.initState();
    final accounts = ref.read(mockTransferAccountsProvider);
    if (accounts.isNotEmpty) {
      _sourceAccount = accounts.first;
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _detailCtrl.dispose();
    super.dispose();
  }

  double get _amount => double.tryParse(_amountCtrl.text) ?? 0;

  void _onContinue() {
    final source = _sourceAccount;
    if (source == null) {
      _showSnack('Please select an account to debit from.');
      return;
    }
    final beneficiary = _beneficiary;
    if (beneficiary == null) {
      _showSnack('Please select a beneficiary.');
      return;
    }
    if (_amount <= 0) {
      _showSnack('Enter an amount greater than zero.');
      return;
    }
    if (_amount >= 100000) {
      _showSnack('Amount is too large.');
      return;
    }
    if (source.availableBalance != null && _amount > source.availableBalance!) {
      _showSnack('Amount exceeds the selected account\'s available balance.');
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final draft = TransferDraft(
      debitAccountId: source.accountId,
      debitCurrency: source.currencyId,
      debitAmount: _amount,
      creditAccountId: beneficiary.ribNumber,
      paymentDetail: _detailCtrl.text.trim(),
      debitIban: source.iban,
      debitProductName: source.productName,
    );

    ref.read(transferControllerProvider.notifier).initiate(draft);
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primaryRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(mockTransferAccountsProvider);
    final beneficiaries = ref.watch(mockBeneficiariesProvider);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: _SectionHeader(label: 'Where is the money coming from?'),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: SourceAccountSelector(
              selected: _sourceAccount,
              onSelected: (a) => setState(() => _sourceAccount = a),
              accounts: accounts,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: BeneficiarySelector(
              beneficiaries: beneficiaries,
              selected: _beneficiary,
              onSelected: (b) => setState(() => _beneficiary = b),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: _AmountField(
              controller: _amountCtrl,
              currency: _sourceAccount?.currencyId ?? 'TND',
              balance: _sourceAccount?.availableBalance,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Form(
              key: _formKey,
              child: _DetailField(
                label: 'Payment Details',
                hint: 'e.g. Transfer payment',
                controller: _detailCtrl,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: _ContinueButton(onTap: _onContinue),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Text(
        label,
        style: AppTypography.h6.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _AmountField extends StatefulWidget {
  const _AmountField({
    required this.controller,
    required this.currency,
    this.balance,
  });

  final TextEditingController controller;
  final String currency;
  final double? balance;

  @override
  State<_AmountField> createState() => _AmountFieldState();
}

class _AmountFieldState extends State<_AmountField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final amount = double.tryParse(widget.controller.text) ?? 0;
    final exceeded =
        widget.balance != null && amount > widget.balance!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        border: Border.all(
          color: exceeded ? AppColors.primaryRed.withValues(alpha: 0.5) : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Amount',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                widget.currency,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                  ],
                  style: AppTypography.h1.copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: exceeded ? AppColors.primaryRed : AppColors.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    hintText: '0.00',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.account_balance_wallet_outlined,
                size: 18,
                color: AppColors.primaryGreen,
              ),
              const SizedBox(width: 8),
              Text(
                'Available: ',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                widget.balance != null
                    ? '${widget.balance!.toStringAsFixed(2)} ${widget.currency}'
                    : '—',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (exceeded)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.primaryRed),
                  const SizedBox(width: 6),
                  Text(
                    'Amount exceeds available balance',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.primaryRed,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _DetailField extends StatelessWidget {
  const _DetailField({
    required this.label,
    required this.hint,
    required this.controller,
  });

  final String label;
  final String hint;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: AppTypography.bodyMedium.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: AppColors.lightBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
        ),
      ),
    );
  }
}

class _ContinueButton extends StatelessWidget {
  const _ContinueButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppDimensions.buttonHeight,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
        ),
        child: Text('Continue', style: AppTypography.buttonLarge.copyWith(color: Colors.white)),
      ),
    );
  }
}