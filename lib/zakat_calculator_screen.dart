import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_theme.dart';
import 'app_widgets.dart';
import 'zakat_calculation_service.dart';
import 'zakat_calculator.dart';

class ZakatCalculatorScreen extends StatefulWidget {
  const ZakatCalculatorScreen({super.key});

  @override
  State<ZakatCalculatorScreen> createState() => _ZakatCalculatorScreenState();
}

class _ZakatCalculatorScreenState extends State<ZakatCalculatorScreen> {
  static const _calculationService = ZakatCalculationService();

  final _nisabFormKey = GlobalKey<FormState>();
  final _assetsFormKey = GlobalKey<FormState>();
  final _nisabController = TextEditingController();
  final _sourceController = TextEditingController();
  final _cashController = TextEditingController();
  final _bankController = TextEditingController();
  final _otherAssetsController = TextEditingController();
  final _liabilitiesController = TextEditingController();
  final _zakatRateController = TextEditingController();

  int _step = 0;
  bool _silverBased = true;
  bool _oneHijriYear = false;
  DateTime? _valuationDate;
  String? _message;
  ZakatCalculationResult? _calculationResult;

  @override
  void dispose() {
    _nisabController.dispose();
    _sourceController.dispose();
    _cashController.dispose();
    _bankController.dispose();
    _otherAssetsController.dispose();
    _liabilitiesController.dispose();
    _zakatRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zakat Calculator'),
        actions: [
          IconButton(
            key: const Key('resetButton'),
            tooltip: 'Reset',
            onPressed: _reset,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: AppColors.emerald,
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
            child: AppHeader(
              step: _step + 1,
              subtitle: _step == 0
                  ? 'Step 1 of 3 • Nisab'
                  : _step == 1
                  ? 'Step 2 of 3 • Assets'
                  : 'Step 3 of 3 • Review',
            ),
          ),
          if (_message != null)
            MaterialBanner(
              content: Text(_message!),
              leading: const Icon(Icons.info_outline),
              actions: [
                TextButton(
                  onPressed: () => setState(() => _message = null),
                  child: const Text('Dismiss'),
                ),
              ],
            ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AppSpace.maxWidth),
                child: IndexedStack(
                  index: _step,
                  children: [
                    _buildNisabStep(),
                    _buildAssetsStep(),
                    _buildReviewStep(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNisabStep() {
    return Form(
      key: _nisabFormKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const StepTitle(
            icon: AppIcons.nisab,
            title: 'Nisab',
            description: 'Choose a standard, enter the verified PKR amount, and set its valuation date.',
          ),
          const SizedBox(height: 20),
          SegmentedButton<bool>(
            key: const Key('standardSelector'),
            segments: const [
              ButtonSegment(value: true, label: Text('Silver-based')),
              ButtonSegment(value: false, label: Text('Gold-based')),
            ],
            selected: {_silverBased},
            onSelectionChanged: (selection) {
              setState(() => _silverBased = selection.first);
            },
          ),
          const SizedBox(height: 18),
          _amountField(
            key: const Key('nisabField'),
            controller: _nisabController,
            label: 'Current nisab (PKR)',
            required: true,
          ),
          const SizedBox(height: 12),
          _amountField(
            key: const Key('zakatRateField'),
            controller: _zakatRateController,
            label: 'Zakat rate (%)',
            required: true,
            maxValue: 100,
            requiredMessage: 'Enter the Zakat rate percentage.',
          ),
          const SizedBox(height: 12),
          ListTile(
            key: const Key('valuationDateField'),
            contentPadding: EdgeInsets.zero,
            leading: const Icon(AppIcons.date, color: AppColors.gold),
            title: const Text('Valuation date'),
            subtitle: Text(
              _valuationDate == null
                  ? 'Select a date'
                  : _formatDate(_valuationDate!),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _pickDate,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpace.radius),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            key: const Key('sourceField'),
            controller: _sourceController,
            maxLength: 120,
            decoration: const InputDecoration(
              labelText: 'Source (optional)',
              hintText: 'e.g. verified local rate',
              prefixIcon: Icon(AppIcons.source),
            ),
          ),
          const SizedBox(height: 12),
          ActionRow(
            primaryLabel: 'Continue to assets',
            onPrimary: _continueToAssets,
          ),
        ],
      ),
    );
  }

  Widget _buildAssetsStep() {
    return Form(
      key: _assetsFormKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const StepTitle(
            icon: AppIcons.assets,
            title: 'Assets',
            description: 'Enter PKR amounts. Empty fields and zero are allowed for optional values.',
          ),
          const SizedBox(height: 20),
          _amountField(
            key: const Key('cashField'),
            controller: _cashController,
            label: 'Cash in hand (PKR)',
          ),
          const SizedBox(height: 12),
          _amountField(
            key: const Key('bankField'),
            controller: _bankController,
            label: 'Bank balance (PKR)',
          ),
          const SizedBox(height: 12),
          _amountField(
            key: const Key('otherAssetsField'),
            controller: _otherAssetsController,
            label: 'Other zakatable assets (PKR)',
          ),
          const SizedBox(height: 12),
          _amountField(
            key: const Key('liabilitiesField'),
            controller: _liabilitiesController,
            label: 'Deductible liabilities (PKR)',
          ),
          CheckboxListTile(
            key: const Key('hijriYearField'),
            contentPadding: EdgeInsets.zero,
            value: _oneHijriYear,
            onChanged: (value) =>
                setState(() => _oneHijriYear = value ?? false),
            title: const Text('One Hijri year completed'),
            subtitle: const Text('Stores your selection for the review only.'),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const SizedBox(height: 8),
          ActionRow(
            primaryLabel: 'Review details',
            onPrimary: _reviewAssets,
            secondaryLabel: 'Back',
            onSecondary: () => setState(() => _step = 0),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const StepTitle(
          icon: AppIcons.review,
          title: 'Review',
          description: 'Check your entered values. Edit links take you back without clearing anything.',
        ),
        const SizedBox(height: 20),
        _reviewCard(
          title: 'Nisab',
          icon: AppIcons.nisab,
          rows: [
            _ReviewRow(
              'Standard',
              _silverBased ? 'Silver-based' : 'Gold-based',
            ),
            _ReviewRow('Current nisab', _display(_nisabController)),
            _ReviewRow('Zakat rate', '${_display(_zakatRateController)}%'),
            _ReviewRow(
              'Valuation date',
              _valuationDate == null
                  ? 'Not entered'
                  : _formatDate(_valuationDate!),
            ),
            _ReviewRow(
              'Source',
              _sourceController.text.isEmpty
                  ? 'Not entered'
                  : _sourceController.text,
            ),
          ],
          onEdit: () => setState(() => _step = 0),
        ),
        const SizedBox(height: 12),
        _reviewCard(
          title: 'Assets',
          icon: AppIcons.assets,
          rows: [
            _ReviewRow('Cash in hand', _display(_cashController)),
            _ReviewRow('Bank balance', _display(_bankController)),
            _ReviewRow('Other assets', _display(_otherAssetsController)),
            _ReviewRow('Liabilities', _display(_liabilitiesController)),
            _ReviewRow('One Hijri year', _oneHijriYear ? 'Yes' : 'No'),
          ],
          onEdit: () => setState(() => _step = 1),
        ),
        const SizedBox(height: 20),
        ActionRow(
          primaryLabel: 'Finish review',
          onPrimary: () => setState(
            () => _message =
                'Review acknowledged. No Zakat amount was calculated.',
          ),
          secondaryLabel: 'Back',
          onSecondary: () => setState(() => _step = 1),
        ),
        const SizedBox(height: 16),
        _buildResultCard(),
        const SizedBox(height: 16),
        _buildCalculationDetails(),
      ],
    );
  }

  Widget _buildResultCard() {
    final result = _calculationResult;
    final isEligible = result?.isEligible == true;

    return Card(
      color: AppColors.ivory,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calculate_outlined, color: AppColors.gold),
                const SizedBox(width: 10),
                Text(
                  'Zakat summary',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              decoration: BoxDecoration(
                color: isEligible
                    ? AppColors.emerald
                    : AppColors.helper.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSpace.radius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Zakat amount due',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isEligible ? Colors.white70 : AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatAmount(result?.zakatDue),
                    key: const Key('zakatAmountResult'),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: isEligible ? Colors.white : AppColors.text,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _resultRow(
              'Net zakatable wealth:',
              _formatAmount(result?.netZakatableAmount),
            ),
            const Divider(height: 24),
            _resultRow('Nisab threshold', _formatAmount(result?.nisabAmount)),
            const SizedBox(height: 18),
            Text(
              isEligible
                  ? 'Zakat is due based on the entered values.'
                  : 'The entered wealth is below nisab.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: isEligible ? AppColors.emerald : AppColors.helper,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculationDetails() {
    final result = _calculationResult;
    final isEligible = result?.isEligible == true;

    return Card(
      color: AppColors.ivory,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How this was calculated',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            _calculationStep(
              '1. Total assets',
              '${_formatAmount(result?.totalAssets)}\n'
              '= ${_formatAmount(_parseAmount(_cashController))} cash'
              ' + ${_formatAmount(_parseAmount(_bankController))} bank'
              ' + ${_formatAmount(_parseAmount(_otherAssetsController))} other assets',
            ),
            _calculationStep(
              '2. Net zakatable wealth',
              '${_formatAmount(result?.totalAssets)} total assets'
              ' - ${_formatAmount(_parseAmount(_liabilitiesController))} liabilities'
              ' = ${_formatAmount(result?.netZakatableAmount)}',
            ),
            _calculationStep(
              '3. Nisab comparison',
              '${_formatAmount(result?.netZakatableAmount)} net wealth'
              ' ${isEligible ? '>=' : '<'} ${_formatAmount(result?.nisabAmount)} nisab'
              ' → ${isEligible ? 'eligible' : 'below nisab'}',
            ),
            _calculationStep(
              '4. Zakat due',
              isEligible
                  ? '${_formatAmount(result?.netZakatableAmount)} × '
                    '${_display(_zakatRateController)}%'
                    ' = ${_formatAmount(result?.zakatDue)}'
                  : 'Below nisab = ${_formatAmount(result?.zakatDue)}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _calculationStep(String title, String detail) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.arrow_right_alt, color: AppColors.gold, size: 22),
          const SizedBox(width: 6),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyLarge,
                children: [
                  TextSpan(
                    text: '$title\n',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: detail),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.helper,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _reviewCard({
    required String title,
    required IconData icon,
    required List<_ReviewRow> rows,
    required VoidCallback onEdit,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.gold),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                TextButton(onPressed: onEdit, child: const Text('Edit')),
              ],
            ),
            const Divider(),
            for (final row in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        row.label,
                        style: const TextStyle(color: AppColors.helper),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        row.value,
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _amountField({
    required Key key,
    required TextEditingController controller,
    required String label,
    bool required = false,
    double? maxValue,
    String? requiredMessage,
  }) {
    return TextFormField(
      key: key,
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        LengthLimitingTextInputFormatter(15),
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      decoration: InputDecoration(
        labelText: label,
        hintText: '0.00',
        prefixIcon: const Icon(Icons.payments_outlined),
      ),
      validator: required
          ? (value) {
              final amount = double.tryParse(value ?? '');
              if (amount == null || amount <= 0) {
                return requiredMessage ?? 'Enter a nisab amount greater than zero.';
              }
              if (maxValue != null && amount > maxValue) {
                return 'Enter a value between 0 and $maxValue.';
              }
              return null;
            }
          : null,
    );
  }

  Future<void> _pickDate() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _valuationDate ?? today,
      firstDate: DateTime(2000),
      lastDate: today,
    );
    if (picked != null) {
      setState(() => _valuationDate = picked);
    }
  }

  void _continueToAssets() {
    if (_nisabFormKey.currentState?.validate() != true) {
      return;
    }
    if (_valuationDate == null) {
      setState(() => _message = 'Select a valuation date before continuing.');
      return;
    }
    setState(() {
      _message = null;
      _step = 1;
    });
  }

  void _reviewAssets() {
    if (_assetsFormKey.currentState?.validate() != true) {
      return;
    }
    final result = _calculationService.calculatePkr(
      nisabAmount: double.parse(_nisabController.text),
      zakatRate: _parseAmount(_zakatRateController) / 100,
      cash: _parseAmount(_cashController),
      bankBalance: _parseAmount(_bankController),
      otherAssets: _parseAmount(_otherAssetsController),
      liabilities: _parseAmount(_liabilitiesController),
    );
    setState(() {
      _message = null;
      _step = 2;
      _calculationResult = result;
    });
  }

  void _reset() {
    _nisabController.clear();
    _zakatRateController.clear();
    _sourceController.clear();
    _cashController.clear();
    _bankController.clear();
    _otherAssetsController.clear();
    _liabilitiesController.clear();
    setState(() {
      _step = 0;
      _silverBased = true;
      _oneHijriYear = false;
      _valuationDate = null;
      _message = null;
      _calculationResult = null;
    });
  }

  String _display(TextEditingController controller) {
    return controller.text.isEmpty ? 'Not entered' : controller.text;
  }

  double _parseAmount(TextEditingController controller) {
    return double.tryParse(controller.text) ?? 0;
  }

  String _formatAmount(double? amount) {
    return amount == null ? 'Not calculated' : '${amount.toStringAsFixed(2)} PKR';
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}

class _ReviewRow {
  const _ReviewRow(this.label, this.value);

  final String label;
  final String value;
}
