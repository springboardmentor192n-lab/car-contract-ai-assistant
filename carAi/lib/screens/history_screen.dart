
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/contract_data.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Great Deal', 'Fair Deal', 'Needs Review', 'Risky'];
  List<HistoryItem> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = ContractData.history;
    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = ContractData.history.where((item) {
        final matchesQuery = item.vehicle.toLowerCase().contains(query) || 
                             item.dealer.toLowerCase().contains(query);
        final matchesFilter = _selectedFilter == 'All' || item.status == _selectedFilter;
        return matchesQuery && matchesFilter;
      }).toList();
    });
  }

  void _updateFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      _filterItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Contract History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text('${_filteredItems.length} analyses', style: AppTextStyles.xs),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilters(),
          _buildListHeader(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredItems.length,
              itemBuilder: (context, index) {
                final item = _filteredItems[index];
                return _buildHistoryCard(context, item);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by vehicle or dealer...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: _filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(filter),
                  if (isSelected) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${filter == 'All' ? ContractData.history.length : ContractData.history.where((i) => i.status == filter).length}',
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ],
                ],
              ),
              selected: isSelected,
              onSelected: (_) => _updateFilter(filter),
              backgroundColor: Colors.white,
              selectedColor: AppColors.blue50,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.foreground,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border),
              ),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildListHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('${_filteredItems.length} results', style: AppTextStyles.xs),
          Text('Sort by date', style: AppTextStyles.xs.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, HistoryItem item) {
    Color statusColor;
    Color statusBg;
    
    switch (item.status) {
      case 'Great Deal':
      case 'Fair Deal':
        statusColor = AppColors.success;
        statusBg = AppColors.green50;
        break;
      case 'Needs Review':
        statusColor = AppColors.warning;
        statusBg = AppColors.amber50;
        break;
      case 'Risky':
        statusColor = AppColors.error;
        statusBg = AppColors.red50;
        break;
      default:
        statusColor = AppColors.primary;
        statusBg = AppColors.blue50;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: () => context.push('/analysis/${item.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.description_outlined, color: AppColors.foreground),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.vehicle, style: AppTextStyles.base.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(item.dealer, style: AppTextStyles.xs),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _InfoItem(icon: Icons.calendar_today, text: item.date),
                  _InfoItem(icon: Icons.attach_money, text: '\$${item.monthly}/mo'),
                  _InfoItem(icon: Icons.schedule, text: '${item.term} months'),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              Row(
                children: [
                  _ScoreBadge(score: item.score, color: statusColor, bgColor: statusBg),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(item.status, style: AppTextStyles.xs.copyWith(color: statusColor, fontWeight: FontWeight.bold)),
                  ),
                  const Spacer(),
                  Text('\$${item.totalCost.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} total', style: AppTextStyles.xs),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;
  
  const _InfoItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 6),
        Text(text, style: AppTextStyles.sm.copyWith(color: AppColors.mutedForeground)),
      ],
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final int score;
  final Color color;
  final Color bgColor;

  const _ScoreBadge({required this.score, required this.color, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text('Score: $score/100', style: AppTextStyles.xs.copyWith(color: color, fontWeight: FontWeight.bold)),
    );
  }
}
