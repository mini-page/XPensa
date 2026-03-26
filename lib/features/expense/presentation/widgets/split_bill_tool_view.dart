import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SplitBillToolView extends StatefulWidget {
  const SplitBillToolView({super.key});

  @override
  State<SplitBillToolView> createState() => _SplitBillToolViewState();
}

class _SplitBillToolViewState extends State<SplitBillToolView> {
  final TextEditingController _amountController = TextEditingController(text: '0');
  int _peopleCount = 2;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    final totalAmount = double.tryParse(_amountController.text) ?? 0;
    final perPerson = _peopleCount <= 0 ? 0 : totalAmount / _peopleCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Split Bill',
          style: TextStyle(
            color: Color(0xFF152039),
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const Text(
          'Calculate fair shares instantly',
          style: TextStyle(
            color: Color(0xFF8EA0BC),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Total amount',
            prefixText: '₹ ',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: <Widget>[
              const Expanded(
                child: Text(
                  'People',
                  style: TextStyle(
                    color: Color(0xFF152039),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _StepperButton(
                icon: Icons.remove_rounded,
                onTap: _peopleCount > 1 ? () => setState(() => _peopleCount -= 1) : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '$_peopleCount',
                  style: const TextStyle(
                    color: Color(0xFF152039),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _StepperButton(
                icon: Icons.add_rounded,
                onTap: () => setState(() => _peopleCount += 1),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0A6BE8), Color(0xFF56A0FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0A6BE8).withValues(alpha: 0.2),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Per person',
                style: TextStyle(
                  color: Color(0xCCFFFFFF),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                currency.format(perPerson),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: onTap == null ? const Color(0xFFF1F4F8) : const Color(0xFFE8F1FF),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(
            icon,
            color: onTap == null ? const Color(0xFFAAB7CB) : const Color(0xFF0A6BE8),
            size: 18,
          ),
        ),
      ),
    );
  }
}
