import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../services/api_service.dart';

class VinReportScreen extends StatefulWidget {
  const VinReportScreen({super.key});

  @override
  State<VinReportScreen> createState() => _VinReportScreenState();
}

class _VinReportScreenState extends State<VinReportScreen> {
  final TextEditingController _vinController = TextEditingController(text: '5YJ3E1EA8LF123456'); // Default for demo
  final ApiService _apiService = ApiService();
  
  bool _isLoading = false;
  Map<String, dynamic>? _vehicleData;
  String? _errorMessage;

  Future<void> _verifyVin() async {
    final vin = _vinController.text.trim();
    if (vin.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _vehicleData = null;
    });

    try {
      final data = await _apiService.getVehicleDetails(vin);
      if (data.containsKey('error')) {
         setState(() {
          _errorMessage = data['error'];
        });
      } else {
        setState(() {
          _vehicleData = data;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to verify VIN. Please check your connection.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('VIN Report'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildVinInputCard(),
              const SizedBox(height: 16),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_errorMessage != null)
                _buildErrorCard()
              else if (_vehicleData != null) ...[
                _buildVehicleImageCard(),
                const SizedBox(height: 16),
                _buildAccordionSections(),
                const SizedBox(height: 16),
                _buildPremiumReportCard(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVinInputCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Vehicle Identification Number', style: AppTextStyles.sm.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: TextField(
                    controller: _vinController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter VIN',
                    ),
                    style: AppTextStyles.base,
                    onSubmitted: (_) => _verifyVin(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _isLoading ? null : _verifyVin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: _isLoading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Verify'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.info_outline, size: 16, color: AppColors.mutedForeground),
              const SizedBox(width: 8),
              Text('Checking global databases...', style: AppTextStyles.xs.copyWith(color: AppColors.mutedForeground)),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  Widget _buildVehicleImageCard() {
    final make = _vehicleData?['Make'] ?? 'Unknown';
    final model = _vehicleData?['Model'] ?? 'Vehicle';
    final year = _vehicleData?['ModelYear'] ?? '';
    final trim = _vehicleData?['Trim'] ?? '';
    final drive = _vehicleData?['DriveType'] ?? '';
    
    // Deterministic data from backend
    final titleStatus = _vehicleData?['TitleStatus'] ?? 'Unknown';
    final accidents = _vehicleData?['Accidents'] == 0 ? 'No Accidents' : '${_vehicleData?['Accidents']} Accidents';
    final owners = _vehicleData?['Owners']?.toString() ?? 'N/A';
    final mileage = _vehicleData?['Mileage'] ?? 'N/A';

    return Container(
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
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 200,
                width: double.infinity,
                color: Colors.grey[300], // Placeholder for image
                child: const Icon(Icons.directions_car, size: 80, color: Colors.grey),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 16,
                child: Wrap(
                  spacing: 8,
                  children: [
                    _Badge(text: titleStatus, color: titleStatus == 'Clean' ? AppColors.green50 : Colors.orange[50]!, textColor: titleStatus == 'Clean' ? AppColors.success : Colors.orange),
                    _Badge(text: accidents, color: accidents == 'No Accidents' ? AppColors.green50 : Colors.orange[50]!, textColor: accidents == 'No Accidents' ? AppColors.success : Colors.orange),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$year $make $model', style: AppTextStyles.lg.copyWith(fontWeight: FontWeight.bold)),
                Text('$trim $drive', style: AppTextStyles.sm.copyWith(color: AppColors.mutedForeground)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _StatBox(label: 'Owners', value: owners)),
                    const SizedBox(width: 12),
                    Expanded(child: _StatBox(label: 'Mileage', value: mileage)),
                    const SizedBox(width: 12),
                    Expanded(child: _StatBox(label: 'Year', value: year)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccordionSections() {
    final make = _vehicleData?['Make'] ?? '-';
    final model = _vehicleData?['Model'] ?? '-';
    final trim = _vehicleData?['Trim'] ?? '-';
    final bodyStyle = _vehicleData?['BodyStyle'] ?? '-';
    final drive = _vehicleData?['DriveType'] ?? '-';
    final engine = '${_vehicleData?['EngineCylinders'] ?? ''} Cyl - ${_vehicleData?['FuelType'] ?? ''}';
    final plant = _vehicleData?['PlantCountry'] ?? '-';
    
    final recalls = _vehicleData?['Recalls'] as List? ?? [];
    final hasRecalls = recalls.isNotEmpty;
    final registrationState = _vehicleData?['RegistrationState'] ?? 'Unknown';

    return Column(
      children: [
        _AccordionCard(
          icon: Icons.directions_car_outlined,
          iconBg: AppColors.blue50,
          iconColor: AppColors.primary,
          title: 'Vehicle Specifications',
          children: [
            _DetailRow('Make', make),
            _DetailRow('Model', model),
            _DetailRow('Trim', trim),
            _DetailRow('Body Style', bodyStyle),
            _DetailRow('Drivetrain', drive),
            _DetailRow('Engine Type', engine),
             _DetailRow('Assembly', plant),
          ],
        ),
        const SizedBox(height: 12),
        _AccordionCard(
          icon: Icons.shield_outlined,
          iconBg: hasRecalls ? Colors.orange[50]! : AppColors.green50,
          iconColor: hasRecalls ? Colors.orange : AppColors.success,
          title: 'Safety & Recalls',
          badge: _Badge(
            text: hasRecalls ? '${recalls.length} Open Recalls' : 'No issues', 
            color: hasRecalls ? Colors.orange[50]! : AppColors.green50, 
            textColor: hasRecalls ? Colors.orange : AppColors.success
          ),
          children: [
             if (hasRecalls) ...[
                for (var recall in recalls)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange[200]!)
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(recall['Component'] ?? 'Unknown Component', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.brown)),
                        const SizedBox(height: 4),
                        Text(recall['Summary'] ?? '', style: const TextStyle(fontSize: 12)),
                        const SizedBox(height: 8),
                        Text('Remedy: ${recall['Remedy']}', style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
                      ],
                    ),
                  )
             ] else
               Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.green50,
                  border: Border.all(color: AppColors.success.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: AppColors.success),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('No Open Recalls', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          SizedBox(height: 4),
                          Text('Vehicle is free of safety recalls.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        _AccordionCard(
          icon: Icons.description_outlined,
          iconBg: AppColors.purple50,
          iconColor: AppColors.purple,
          title: 'Registration & Title',
          children: [
             _DetailRow('Title Status', _vehicleData?['TitleStatus'] ?? 'Unknown', isBadge: true),
            _DetailRow('Registration State', registrationState),
            const _DetailRow('First Registration', 'January 2024'), // Kept mock for simplicity
            _DetailRow('Previous Owners', _vehicleData?['Owners']?.toString() ?? '0'),
          ],
        ),
      ],
    );
  }

  Widget _buildPremiumReportCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.blue50, 
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.assignment_turned_in, size: 40, color: AppColors.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Get Full History Report', style: AppTextStyles.lg.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Detailed accident history, service records & more', style: AppTextStyles.sm),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text('Get Full Report · \$29.99'),
          ),
        ],
      ),
    );
  }
}

class _AccordionCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final List<Widget> children;
  final Widget? badge;

  const _AccordionCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.children,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          title: Text(title, style: AppTextStyles.base.copyWith(fontWeight: FontWeight.w600)),
          trailing: badge ?? const Icon(Icons.expand_more),
          children: [
            const Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: children),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBadge;

  const _DetailRow(this.label, this.value, {this.isBadge = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.sm.copyWith(color: AppColors.mutedForeground)),
          isBadge
              ? _Badge(text: value, color: AppColors.green50, textColor: AppColors.success)
              : Text(value, style: AppTextStyles.sm.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;

  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.xs.copyWith(color: AppColors.mutedForeground)),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.lg.copyWith(fontWeight: FontWeight.bold)),
        ],
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
