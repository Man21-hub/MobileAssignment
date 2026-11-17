import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/baggage_fare.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/result_card.dart';

/// Home page: collects the flight details and shows the calculated fees.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey _resultKey = GlobalKey();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();

  /// Only digits and a single decimal point may be typed.
  static final List<TextInputFormatter> _decimalOnly = <TextInputFormatter>[
    TextInputFormatter.withFunction((
      TextEditingValue oldValue,
      TextEditingValue newValue,
    ) {
      final String text = newValue.text;
      if (text.isEmpty || RegExp(r'^\d*\.?\d*$').hasMatch(text)) {
        return newValue;
      }
      return oldValue;
    }),
  ];

  TicketClass _ticketClass = TicketClass.economy;
  BaggageFare? _result;

  @override
  void dispose() {
    _weightController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  double _parse(String text) => double.parse(text.trim());

  void _calculate() {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() => _result = null);
      _showMessage('Please complete the form with valid values.');
      return;
    }

    setState(() {
      _result = BaggageFare.calculate(
        ticketClass: _ticketClass,
        weightKg: _parse(_weightController.text),
        ratePerKg: _parse(_rateController.text),
      );
    });

    // Scroll to the new result so the user sees it immediately.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final BuildContext? resultContext = _resultKey.currentContext;
      if (resultContext == null) return;
      Scrollable.ensureVisible(
        resultContext,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        alignment: 0.08,
      );
    });
  }

  void _reset() {
    FocusManager.instance.primaryFocus?.unfocus();
    _weightController.clear();
    _rateController.clear();
    _formKey.currentState?.reset();

    setState(() {
      _ticketClass = TicketClass.economy;
      _result = null;
    });

    _showMessage('Inputs cleared. Ready for a new calculation.');
  }

  void _showMessage(String message) {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  String? _validateWeight(String? value) {
    final String text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Please enter the checked baggage weight.';
    }
    final double? weight = double.tryParse(text);
    if (weight == null || !weight.isFinite) {
      return 'Enter a valid weight, e.g. 42.5.';
    }
    if (weight < 0) {
      return 'Baggage weight cannot be negative.';
    }
    return null;
  }

  String? _validateRate(String? value) {
    final String text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Please enter the excess baggage rate per kg.';
    }
    final double? rate = double.tryParse(text);
    if (rate == null || !rate.isFinite) {
      return 'Enter a valid rate, e.g. 15.00.';
    }
    if (rate < 0) {
      return 'Rate per kg cannot be negative.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _HomeHeader(),
                const SizedBox(height: 16),
                _buildFormCard(),
                if (_result != null) ...[
                  const SizedBox(height: 16),
                  KeyedSubtree(
                    key: _resultKey,
                    child: ResultCard(fare: _result!),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.lightBlue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.flight_takeoff,
                      size: 19,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Flight details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                key: const Key('weightField'),
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: _decimalOnly,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Checked baggage weight',
                  hintText: 'e.g. 42.5',
                  prefixIcon: Icon(Icons.scale_outlined),
                  suffixText: 'kg',
                ),
                validator: _validateWeight,
              ),
              const SizedBox(height: 20),
              const Text(
                'Ticket class',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.navy,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _TicketClassOption(
                      value: TicketClass.economy,
                      icon: Icons.airline_seat_recline_normal,
                      selected: _ticketClass == TicketClass.economy,
                      onTap: () => _selectClass(TicketClass.economy),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TicketClassOption(
                      value: TicketClass.business,
                      icon: Icons.work_outline,
                      selected: _ticketClass == TicketClass.business,
                      onTap: () => _selectClass(TicketClass.business),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Baggage allowance: ${_ticketClass.allowanceKg} kg per passenger',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.mutedText,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                key: const Key('rateField'),
                controller: _rateController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: _decimalOnly,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _calculate(),
                decoration: const InputDecoration(
                  labelText: 'Excess baggage rate',
                  hintText: 'e.g. 15.00',
                  prefixIcon: Icon(Icons.payments_outlined),
                  prefixText: 'RM ',
                  suffixText: '/ kg',
                ),
                validator: _validateRate,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                key: const Key('calculateButton'),
                onPressed: _calculate,
                icon: const Icon(Icons.calculate_outlined),
                label: const Text('Calculate total'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                key: const Key('resetButton'),
                onPressed: _reset,
                icon: const Icon(Icons.restart_alt),
                label: const Text('Reset'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectClass(TicketClass ticketClass) {
    setState(() {
      _ticketClass = ticketClass;
      // The old result belongs to the previous class, so hide it.
      _result = null;
    });
  }
}

/// The navy banner at the top of the Home page.
class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.navy, AppColors.navyLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.18),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.luggage_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Excess Baggage Fee Calculator',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Enter your baggage weight and rate to see the excess '
                  'charge, 8% tax and total payable.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12.5,
                    height: 1.45,
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

/// One selectable ticket class card.
class _TicketClassOption extends StatelessWidget {
  const _TicketClassOption({
    required this.value,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final TicketClass value;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '${value.label} class, ${value.allowanceKg} kg allowance',
      child: InkWell(
        key: Key('${value.name}Option'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
          decoration: BoxDecoration(
            color: selected ? AppColors.lightBlue : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.accent : AppColors.border,
              width: selected ? 2 : 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: selected ? AppColors.accent : AppColors.mutedText,
                  ),
                  const Spacer(),
                  if (selected)
                    const Icon(
                      Icons.check_circle,
                      size: 17,
                      color: AppColors.accent,
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                value.label,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: selected ? AppColors.navy : AppColors.mutedText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${formatWeight(value.allowanceKg.toDouble())} kg allowance',
                style: TextStyle(
                  fontSize: 11.5,
                  color: selected ? AppColors.navyLight : AppColors.mutedText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
