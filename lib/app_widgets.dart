import 'package:flutter/material.dart';

import 'app_theme.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({required this.step, required this.subtitle, super.key});

  final int step;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.wifi_off, size: 18),
            const SizedBox(width: 6),
            Text(
              'OFFLINE',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.gold,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Zakat Calculator',
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 16),
        Row(
          children: List.generate(
            3,
            (index) => Expanded(
              child: Container(
                height: 5,
                margin: EdgeInsets.only(right: index == 2 ? 0 : 6),
                decoration: BoxDecoration(
                  color: index < step ? AppColors.gold : Colors.white24,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class StepTitle extends StatelessWidget {
  const StepTitle({
    required this.icon,
    required this.title,
    required this.description,
    super.key,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.gold, size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: AppColors.helper),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ActionRow extends StatelessWidget {
  const ActionRow({
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    super.key,
  });

  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (secondaryLabel != null) ...[
          Expanded(
            child: OutlinedButton(
              onPressed: onSecondary,
              child: Text(secondaryLabel!),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: FilledButton(onPressed: onPrimary, child: Text(primaryLabel)),
        ),
      ],
    );
  }
}
