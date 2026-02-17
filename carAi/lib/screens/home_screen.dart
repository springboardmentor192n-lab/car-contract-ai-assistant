import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.accent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.description, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ContractAI', style: AppTextStyles.lg.copyWith(color: AppColors.primary)),
                      Text('AI-Powered Contract Analysis', style: AppTextStyles.xs),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(),
              const SizedBox(height: 24),
              _buildPrimaryButton(context),
              const SizedBox(height: 24),
              _buildStatsBanner(),
              const SizedBox(height: 24),
              _buildQuickAccessCards(context),
              const SizedBox(height: 24),
              _buildRecentAnalysis(context),
              const SizedBox(height: 24),
              _buildTrustIndicators(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Welcome back', style: AppTextStyles.xl),
        const SizedBox(height: 8),
        Text(
          'Upload your car lease or loan contract to get an instant AI analysis and find hidden fees.',
          style: AppTextStyles.sm.copyWith(color: AppColors.mutedForeground, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/analysis/demo'),
          borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.upload_file, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                'Upload Contract',
                style: AppTextStyles.base.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.green50, AppColors.blue50],
        ),
        border: Border.all(color: AppColors.accent.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.trending_up, color: AppColors.success),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Average savings per analysis', style: AppTextStyles.sm),
              Text('\$1,247', style: AppTextStyles.xxl.copyWith(color: AppColors.success)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessCards(BuildContext context) {
    return Column(
      children: [
        _QuickAccessCard(
          icon: Icons.description,
          iconBg: AppColors.blue50,
          iconColor: AppColors.primary,
          title: 'My Analyses',
          subtitle: 'View past contract reviews',
          onTap: () => context.push('/analysis/demo'),
        ),
        const SizedBox(height: 12),
        _QuickAccessCard(
          icon: Icons.chat_bubble_outline,
          iconBg: AppColors.green50,
          iconColor: AppColors.success,
          title: 'Negotiation Assistant',
          subtitle: 'AI-powered negotiation help',
          onTap: () => context.push('/negotiate/demo'),
        ),
        const SizedBox(height: 12),
        _QuickAccessCard(
          icon: Icons.search,
          iconBg: AppColors.amber50,
          iconColor: AppColors.warning,
          title: 'VIN Check',
          subtitle: 'Vehicle history & details',
          onTap: () => context.push('/vin-report'),
        ),
      ],
    );
  }

  Widget _buildRecentAnalysis(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Analysis', style: AppTextStyles.xs),
            TextButton(
              onPressed: () => context.push('/history'),
              child: Text('View all', style: AppTextStyles.sm.copyWith(color: AppColors.primary)),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.description, color: AppColors.mutedForeground),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('2024 Tesla Model 3 Lease', style: AppTextStyles.sm.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('Feb 5, 2026 · \$549/mo', style: AppTextStyles.xs),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _Badge(text: 'Score: 78/100', color: AppColors.success, textColor: Colors.white),
                        const SizedBox(width: 8),
                        _Badge(text: 'Fair Deal', color: AppColors.blue50, textColor: AppColors.primary),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.mutedForeground),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrustIndicators() {
    return Container(
      padding: const EdgeInsets.only(top: 24),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _TrustItem(value: '10K+', label: 'Contracts analyzed'),
          _TrustItem(value: '95%', label: 'Accuracy rate'),
          _TrustItem(value: '\$1.2M', label: 'Total saved'),
        ],
      ),
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.sm.copyWith(fontWeight: FontWeight.w600)),
                    Text(subtitle, style: AppTextStyles.xs),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.mutedForeground),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;

  const _Badge({required this.text, required this.color, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: AppTextStyles.xs.copyWith(color: textColor, fontWeight: FontWeight.w600, fontSize: 10),
      ),
    );
  }
}

class _TrustItem extends StatelessWidget {
  final String value;
  final String label;

  const _TrustItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.xl),
        Text(label, style: AppTextStyles.xs),
      ],
    );
  }
}
