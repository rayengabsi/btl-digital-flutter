import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../home/presentation/widgets/btl_bottom_nav.dart';
import '../widgets/recipient_selector.dart';
import '../widgets/amount_card.dart';
import '../widgets/quick_amount_chip.dart';
import '../widgets/transfer_method_card.dart';
import '../widgets/transfer_summary_card.dart';
import '../widgets/confirmation_bottom_sheet.dart';
import '../widgets/success_transfer_screen.dart';

// ─── Demo data ────────────────────────────────────────────────────────────────

class RecipientModel {
  const RecipientModel({
    required this.name,
    required this.initials,
    this.isFavorite = false,
    this.bank = '',
    this.account = '',
  });
  final String name;
  final String initials;
  final bool isFavorite;
  final String bank;
  final String account;
}

class BankModel {
  const BankModel({required this.name, required this.code});
  final String name;
  final String code;
}

const _savedRecipients = [
  RecipientModel(
    name: 'Mohamed Ben Ali',
    initials: 'MB',
    isFavorite: true,
    bank: 'BTL Bank',
    account: 'TN59 1234 5678 9012 3456 7890',
  ),
  RecipientModel(
    name: 'Ahmed Karoui',
    initials: 'AK',
    bank: 'BIAT',
    account: 'TN59 9876 5432 1098 7654 3210',
  ),
  RecipientModel(
    name: 'Sarah Mansour',
    initials: 'SM',
    isFavorite: true,
    bank: 'Amen Bank',
    account: 'TN59 1111 2222 3333 4444 5555',
  ),
  RecipientModel(
    name: 'Fatma Trabelsi',
    initials: 'FT',
    bank: 'ATB',
    account: 'TN59 6666 7777 8888 9999 0000',
  ),
  RecipientModel(
    name: 'Omar Bejaoui',
    initials: 'OB',
    bank: 'UIB',
    account: 'TN59 1234 0000 1111 2222 3333',
  ),
];

const _banks = [
  BankModel(name: 'BTL Bank', code: 'BTL'),
  BankModel(name: 'BIAT', code: 'BIAT'),
  BankModel(name: 'Amen Bank', code: 'AMEN'),
  BankModel(name: 'ATB', code: 'ATB'),
  BankModel(name: 'UIB', code: 'UIB'),
  BankModel(name: 'STB', code: 'STB'),
  BankModel(name: 'BH Bank', code: 'BH'),
  BankModel(name: 'Zitouna Bank', code: 'ZIT'),
];

const _quickAmounts = [20.0, 50.0, 100.0, 250.0, 500.0, 1000.0];

enum TransferType { instant, scheduled, recurring }

enum RecurringFrequency { daily, weekly, monthly }

// ═══════════════════════════════════════════════════════════════════════════════
// Transfer Screen
// ═══════════════════════════════════════════════════════════════════════════════
class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key, this.onNavTap});

  final ValueChanged<int>? onNavTap;

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen>
    with TickerProviderStateMixin {
  // ── Nav ────────────────────────────────────────────────────────────────────
  int _navIndex = 2;

  // ── Tab: 0 = New Recipient, 1 = Saved Recipients ──────────────────────────
  int _tabIndex = 0;

  // ── Entry animations ───────────────────────────────────────────────────────
  late AnimationController _entryFadeCtrl;
  late Animation<double> _entryFade;
  late AnimationController _entrySlideCtrl;
  late Animation<Offset> _entrySlide;

  // ── Form state ─────────────────────────────────────────────────────────────
  RecipientModel? _selectedRecipient;

  // New recipient fields
  final _nameCtrl = TextEditingController();
  final _ibanCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  BankModel? _selectedBank;

  // Amount
  final _amountCtrl = TextEditingController();
  double get _amount => double.tryParse(_amountCtrl.text.replaceAll(',', '')) ?? 0;
  final double _balance = 12450.80;

  // Note
  final _noteCtrl = TextEditingController();

  // Transfer type
  TransferType _transferType = TransferType.instant;
  RecurringFrequency _recurringFreq = RecurringFrequency.monthly;
  DateTime? _scheduledDate;

  // Success state
  bool _showSuccess = false;

  @override
  void initState() {
    super.initState();

    _entryFadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _entryFade = CurvedAnimation(parent: _entryFadeCtrl, curve: Curves.easeOut);

    _entrySlideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _entrySlide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entrySlideCtrl, curve: Curves.easeOut));

    _entryFadeCtrl.forward();
    _entrySlideCtrl.forward();

    _amountCtrl.addListener(() => setState(() {}));
    _nameCtrl.addListener(() => setState(() {}));
    _noteCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _entryFadeCtrl.dispose();
    _entrySlideCtrl.dispose();
    _nameCtrl.dispose();
    _ibanCtrl.dispose();
    _phoneCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  // ── Derived helpers ────────────────────────────────────────────────────────
  String get _recipientName {
    if (_tabIndex == 1 && _selectedRecipient != null) {
      return _selectedRecipient!.name;
    }
    return _nameCtrl.text.trim();
  }

  String get _recipientBank {
    if (_tabIndex == 1 && _selectedRecipient != null) {
      return _selectedRecipient!.bank;
    }
    return _selectedBank?.name ?? '';
  }

  String get _recipientAccount {
    if (_tabIndex == 1 && _selectedRecipient != null) {
      return _selectedRecipient!.account;
    }
    return _ibanCtrl.text.trim();
  }

  double get _fee => _amount > 0 ? (_amount * 0.005).clamp(0.5, 15.0) : 0.0;
  double get _total => _amount + _fee;

  bool get _canContinue {
    final hasRecipient = _recipientName.isNotEmpty;
    final hasAmount = _amount > 0;
    final withinBalance = _amount <= _balance;
    if (_tabIndex == 0) {
      return hasRecipient && _selectedBank != null && hasAmount && withinBalance;
    }
    return _selectedRecipient != null && hasAmount && withinBalance;
  }

  String get _estimatedArrival {
    switch (_transferType) {
      case TransferType.instant:
        return 'Immediately';
      case TransferType.scheduled:
        return _scheduledDate != null
            ? '${_scheduledDate!.day}/${_scheduledDate!.month}/${_scheduledDate!.year}'
            : 'Select a date';
      case TransferType.recurring:
        return _recurringFreq == RecurringFrequency.daily
            ? 'Every day'
            : _recurringFreq == RecurringFrequency.weekly
                ? 'Every week'
                : 'Every month';
    }
  }

  // ── Actions ────────────────────────────────────────────────────────────────
  void _onContinue() {
    if (!_canContinue) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ConfirmationBottomSheet(
        recipientName: _recipientName,
        bank: _recipientBank,
        account: _recipientAccount,
        amount: _amount,
        fee: _fee,
        total: _total,
        transferType: _transferType,
        estimatedArrival: _estimatedArrival,
        onConfirm: () {
          Navigator.of(context).pop();
          setState(() => _showSuccess = true);
        },
      ),
    );
  }

  void _onSelectBank() async {
    final bank = await showModalBottomSheet<BankModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BankPickerSheet(banks: _banks),
    );
    if (bank != null) setState(() => _selectedBank = bank);
  }

  void _onScheduledDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primaryGreen,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _scheduledDate = picked);
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    if (_showSuccess) {
      return SuccessTransferScreen(
        recipientName: _recipientName,
        amount: _amount,
        onDone: () {
          setState(() {
            _showSuccess = false;
            _amountCtrl.clear();
            _nameCtrl.clear();
            _ibanCtrl.clear();
            _phoneCtrl.clear();
            _noteCtrl.clear();
            _selectedRecipient = null;
            _selectedBank = null;
            _transferType = TransferType.instant;
          });
          if (widget.onNavTap != null) widget.onNavTap!(0);
        },
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ── Background ───────────────────────────────────────────────
          Positioned.fill(
            child: Image.asset(
              'assets/images/dashboard_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          // ── Scrollable content ───────────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _entryFade,
              child: SlideTransition(
                position: _entrySlide,
                child: Column(
                  children: [
                    // ── AppBar ─────────────────────────────────────────
                    _TransferAppBar(
                      onBack: () {
                        if (widget.onNavTap != null) {
                          widget.onNavTap!(0);
                        } else {
                          Navigator.of(context).maybePop();
                        }
                      },
                    ),

                    // ── Scrollable body ────────────────────────────────
                    Expanded(
                      child: CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          // Tab selector
                          SliverToBoxAdapter(
                            child: _TabSelector(
                              selectedIndex: _tabIndex,
                              onChanged: (i) => setState(() {
                                _tabIndex = i;
                                _selectedRecipient = null;
                              }),
                            ),
                          ),

                          // Recipient section
                          SliverToBoxAdapter(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 320),
                              transitionBuilder: (child, anim) => FadeTransition(
                                opacity: anim,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0.04, 0),
                                    end: Offset.zero,
                                  ).animate(anim),
                                  child: child,
                                ),
                              ),
                              child: _tabIndex == 1
                                  ? RecipientSelector(
                                      key: const ValueKey('saved'),
                                      recipients: _savedRecipients,
                                      selected: _selectedRecipient,
                                      onSelect: (r) =>
                                          setState(() => _selectedRecipient = r),
                                    )
                                  : _NewRecipientForm(
                                      key: const ValueKey('new'),
                                      nameCtrl: _nameCtrl,
                                      ibanCtrl: _ibanCtrl,
                                      phoneCtrl: _phoneCtrl,
                                      selectedBank: _selectedBank,
                                      onSelectBank: _onSelectBank,
                                    ),
                            ),
                          ),

                          // Amount card
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                              child: AmountCard(
                                amountCtrl: _amountCtrl,
                                balance: _balance,
                                amount: _amount,
                              ),
                            ),
                          ),

                          // Quick amounts
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                              child: _QuickAmountRow(
                                amounts: _quickAmounts,
                                onSelect: (v) {
                                  _amountCtrl.text = v.toStringAsFixed(0);
                                },
                              ),
                            ),
                          ),

                          // Note
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                              child: _NoteField(ctrl: _noteCtrl),
                            ),
                          ),

                          // Transfer method
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                              child: _TransferMethodSection(
                                selected: _transferType,
                                recurringFreq: _recurringFreq,
                                scheduledDate: _scheduledDate,
                                onTypeChanged: (t) =>
                                    setState(() => _transferType = t),
                                onFreqChanged: (f) =>
                                    setState(() => _recurringFreq = f),
                                onScheduledDateTap: _onScheduledDate,
                              ),
                            ),
                          ),

                          // Summary
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                              child: TransferSummaryCard(
                                recipientName: _recipientName,
                                bank: _recipientBank,
                                account: _recipientAccount,
                                transferType: _transferType,
                                amount: _amount,
                                fee: _fee,
                                total: _total,
                                estimatedArrival: _estimatedArrival,
                              ),
                            ),
                          ),

                          // Continue button
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                              child: _ContinueButton(
                                enabled: _canContinue,
                                onTap: _onContinue,
                              ),
                            ),
                          ),

                          // Nav clearance
                          const SliverToBoxAdapter(
                            child: SizedBox(height: 120),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Floating bottom nav ──────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BtlBottomNav(
              currentIndex: _navIndex,
              onTap: (i) {
                if (widget.onNavTap != null) {
                  widget.onNavTap!(i);
                } else {
                  setState(() => _navIndex = i);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// AppBar
// ═══════════════════════════════════════════════════════════════════════════════
class _TransferAppBar extends StatelessWidget {
  const _TransferAppBar({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: [
          // Back button
          _CircleIconBtn(
            icon: Icons.arrow_back_rounded,
            onTap: onBack,
          ),

          // Title
          const Expanded(
            child: Center(
              child: Text(
                'Transfer',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),

          // Recipient icon
          _CircleIconBtn(
            icon: Icons.person_search_rounded,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

// ─── Circle icon button (same pattern as Home/Cards) ─────────────────────────
class _CircleIconBtn extends StatefulWidget {
  const _CircleIconBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_CircleIconBtn> createState() => _CircleIconBtnState();
}

class _CircleIconBtnState extends State<_CircleIconBtn>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      lowerBound: 0.88,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) {
        _ctrl.forward();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _ctrl,
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Icon(widget.icon, size: 22, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Tab Selector
// ═══════════════════════════════════════════════════════════════════════════════
class _TabSelector extends StatelessWidget {
  const _TabSelector({
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Animated indicator
            AnimatedAlign(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOut,
              alignment: selectedIndex == 0
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: FractionallySizedBox(
                widthFactor: 0.5,
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  ),
                ),
              ),
            ),

            // Labels
            Row(
              children: [
                _TabLabel(
                  label: 'New Recipient',
                  isSelected: selectedIndex == 0,
                  onTap: () => onChanged(0),
                ),
                _TabLabel(
                  label: 'My Recipients',
                  isSelected: selectedIndex == 1,
                  onTap: () => onChanged(1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TabLabel extends StatelessWidget {
  const _TabLabel({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: AppTypography.labelMedium.copyWith(
              color: isSelected ? AppColors.white : AppColors.textSecondary,
              fontWeight:
                  isSelected ? FontWeight.w600 : FontWeight.w400,
              fontSize: 13,
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// New Recipient Form
// ═══════════════════════════════════════════════════════════════════════════════
class _NewRecipientForm extends StatelessWidget {
  const _NewRecipientForm({
    super.key,
    required this.nameCtrl,
    required this.ibanCtrl,
    required this.phoneCtrl,
    required this.selectedBank,
    required this.onSelectBank,
  });

  final TextEditingController nameCtrl;
  final TextEditingController ibanCtrl;
  final TextEditingController phoneCtrl;
  final BankModel? selectedBank;
  final VoidCallback onSelectBank;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Container(
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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Send Money To',
                style: AppTypography.h6.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),

              // Recipient name
              _PremiumTextField(
                controller: nameCtrl,
                label: 'Recipient Name',
                hint: 'Full name',
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 12),

              // IBAN
              _PremiumTextField(
                controller: ibanCtrl,
                label: 'IBAN / Account Number',
                hint: 'TN59 XXXX XXXX XXXX XXXX',
                icon: Icons.account_balance_outlined,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 12),

              // Phone
              _PremiumTextField(
                controller: phoneCtrl,
                label: 'Phone Number',
                hint: '+216 XX XXX XXX',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),

              // Bank selector
              GestureDetector(
                onTap: onSelectBank,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingM,
                    vertical: AppDimensions.paddingM,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.lightBackground,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.account_balance_rounded,
                        size: 20,
                        color: selectedBank != null
                            ? AppColors.primaryGreen
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Select Bank',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              selectedBank?.name ?? 'Choose a bank',
                              style: AppTypography.bodyMedium.copyWith(
                                color: selectedBank != null
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                                fontWeight: selectedBank != null
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Premium text field ───────────────────────────────────────────────────────
class _PremiumTextField extends StatelessWidget {
  const _PremiumTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: AppTypography.bodyMedium.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.lightBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.paddingM,
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

// ═══════════════════════════════════════════════════════════════════════════════
// Quick amount row
// ═══════════════════════════════════════════════════════════════════════════════
class _QuickAmountRow extends StatelessWidget {
  const _QuickAmountRow({
    required this.amounts,
    required this.onSelect,
  });

  final List<double> amounts;
  final ValueChanged<double> onSelect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: amounts
            .map((a) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: QuickAmountChip(
                    amount: a,
                    onTap: () => onSelect(a),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Note field
// ═══════════════════════════════════════════════════════════════════════════════
class _NoteField extends StatelessWidget {
  const _NoteField({required this.ctrl});
  final TextEditingController ctrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Note',
                  style: AppTypography.h6.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '(Optional)',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Stack(
              children: [
                TextField(
                  controller: ctrl,
                  maxLength: 100,
                  maxLines: 2,
                  buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
                      const SizedBox.shrink(),
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Add a note...',
                    hintStyle: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    filled: true,
                    fillColor: AppColors.lightBackground,
                    contentPadding: const EdgeInsets.fromLTRB(16, 14, 48, 14),
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
                      borderSide: const BorderSide(
                          color: AppColors.primaryGreen, width: 2),
                    ),
                  ),
                ),
                Positioned(
                  right: 12,
                  bottom: 10,
                  child: Text(
                    '${ctrl.text.length}/100',
                    style: AppTypography.labelSmall.copyWith(
                      color: ctrl.text.length > 80
                          ? AppColors.warning
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Transfer method section
// ═══════════════════════════════════════════════════════════════════════════════
class _TransferMethodSection extends StatelessWidget {
  const _TransferMethodSection({
    required this.selected,
    required this.recurringFreq,
    required this.scheduledDate,
    required this.onTypeChanged,
    required this.onFreqChanged,
    required this.onScheduledDateTap,
  });

  final TransferType selected;
  final RecurringFrequency recurringFreq;
  final DateTime? scheduledDate;
  final ValueChanged<TransferType> onTypeChanged;
  final ValueChanged<RecurringFrequency> onFreqChanged;
  final VoidCallback onScheduledDateTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transfer Type',
              style: AppTypography.h6.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),

            // Instant + Scheduled row
            Row(
              children: [
                Expanded(
                  child: TransferMethodCard(
                    icon: Icons.flash_on_rounded,
                    title: 'Instant Transfer',
                    subtitle: 'Money arrives immediately',
                    isSelected: selected == TransferType.instant,
                    onTap: () => onTypeChanged(TransferType.instant),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TransferMethodCard(
                    icon: Icons.calendar_today_rounded,
                    title: 'Scheduled Transfer',
                    subtitle: scheduledDate != null
                        ? '${scheduledDate!.day}/${scheduledDate!.month}/${scheduledDate!.year}'
                        : 'Pick date and time',
                    isSelected: selected == TransferType.scheduled,
                    onTap: () {
                      onTypeChanged(TransferType.scheduled);
                      onScheduledDateTap();
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Recurring full-width
            TransferMethodCard(
              icon: Icons.repeat_rounded,
              title: 'Recurring Transfer',
              subtitle: 'Daily • Weekly • Monthly',
              isSelected: selected == TransferType.recurring,
              onTap: () => onTypeChanged(TransferType.recurring),
              isFullWidth: true,
            ),

            // Recurring frequency chips
            AnimatedSize(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOut,
              child: selected == TransferType.recurring
                  ? Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        children: [
                          _FreqChip(
                            label: 'Daily',
                            isSelected:
                                recurringFreq == RecurringFrequency.daily,
                            onTap: () =>
                                onFreqChanged(RecurringFrequency.daily),
                          ),
                          const SizedBox(width: 8),
                          _FreqChip(
                            label: 'Weekly',
                            isSelected:
                                recurringFreq == RecurringFrequency.weekly,
                            onTap: () =>
                                onFreqChanged(RecurringFrequency.weekly),
                          ),
                          const SizedBox(width: 8),
                          _FreqChip(
                            label: 'Monthly',
                            isSelected:
                                recurringFreq == RecurringFrequency.monthly,
                            onTap: () =>
                                onFreqChanged(RecurringFrequency.monthly),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _FreqChip extends StatelessWidget {
  const _FreqChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGreen
              : AppColors.primaryGreen.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGreen
                : AppColors.borderLight,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: isSelected ? AppColors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Continue button
// ═══════════════════════════════════════════════════════════════════════════════
class _ContinueButton extends StatefulWidget {
  const _ContinueButton({required this.enabled, required this.onTap});
  final bool enabled;
  final VoidCallback onTap;

  @override
  State<_ContinueButton> createState() => _ContinueButtonState();
}

class _ContinueButtonState extends State<_ContinueButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.enabled ? (_) => _ctrl.reverse() : null,
      onTapUp: widget.enabled
          ? (_) {
              _ctrl.forward();
              widget.onTap();
            }
          : null,
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _ctrl,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: double.infinity,
          height: AppDimensions.buttonHeight,
          decoration: BoxDecoration(
            color: widget.enabled
                ? AppColors.primaryGreen
                : AppColors.borderLight,
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            boxShadow: widget.enabled
                ? [
                    BoxShadow(
                      color: AppColors.primaryGreen.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: AppTypography.buttonLarge.copyWith(
              color: widget.enabled ? AppColors.white : AppColors.textSecondary,
            ),
            child: const Text('Continue'),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Bank picker bottom sheet
// ═══════════════════════════════════════════════════════════════════════════════
class _BankPickerSheet extends StatefulWidget {
  const _BankPickerSheet({required this.banks});
  final List<BankModel> banks;

  @override
  State<_BankPickerSheet> createState() => _BankPickerSheetState();
}

class _BankPickerSheetState extends State<_BankPickerSheet> {
  final _searchCtrl = TextEditingController();
  List<BankModel> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = widget.banks;
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? widget.banks
          : widget.banks
              .where((b) => b.name.toLowerCase().contains(q))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXL),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Text(
                'Select Bank',
                style: AppTypography.h5.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            // Search field
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: TextField(
                controller: _searchCtrl,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Search banks...',
                  prefixIcon: const Icon(Icons.search_rounded,
                      size: 20, color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.lightBackground,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusM),
                    borderSide:
                        const BorderSide(color: AppColors.borderLight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusM),
                    borderSide:
                        const BorderSide(color: AppColors.borderLight),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusM),
                    borderSide: const BorderSide(
                        color: AppColors.primaryGreen, width: 2),
                  ),
                ),
              ),
            ),

            // Bank list
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.45,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                itemCount: _filtered.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: AppColors.divider,
                ),
                itemBuilder: (context, i) {
                  final bank = _filtered[i];
                  return InkWell(
                    onTap: () => Navigator.of(context).pop(bank),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusS),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen
                                  .withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusS),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              bank.code.substring(0, 2),
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.primaryGreen,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            bank.name,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
