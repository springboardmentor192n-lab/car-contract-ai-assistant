import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../models/contract_data.dart'; // Keep for fallbacks or constants if needed
import '../models/contract_analysis_response.dart';
import '../services/api_service.dart';
import 'dart:math' as math;

class ContractAnalysisScreen extends StatefulWidget {
  final String contractId;
  const ContractAnalysisScreen({super.key, required this.contractId});

  @override
  State<ContractAnalysisScreen> createState() => _ContractAnalysisScreenState();
}

class _ContractAnalysisScreenState extends State<ContractAnalysisScreen> {
  // State
  bool analyzing = false;
  bool showResults = false;
  int analysisProgress = 0;
  String analysisStage = '';
  String? _fileName;
  List<int>? _selectedFileBytes; // Store bytes instead of File
  ContractAnalysisResponse? _analysisResult;
  String? _errorMessage;

  final ApiService _apiService = ApiService();

  Future<void> _pickFile() async {
    try {
      // clear previous state
      setState(() {
         _errorMessage = null;
      });

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true, // Crucial for Web to get bytes
      );

      if (result != null) {
        PlatformFile pFile = result.files.first;
        
        List<int>? fileBytes;
        
        if (pFile.bytes != null) {
           // Web or if withData worked
           fileBytes = pFile.bytes;
        } else if (pFile.path != null) {
           // Desktop/Mobile fallback
           final file = File(pFile.path!);
           fileBytes = await file.readAsBytes();
        }

        if (fileBytes != null) {
          setState(() {
            _selectedFileBytes = fileBytes;
            _fileName = pFile.name;
            showResults = false;
            _errorMessage = null;
          });
        } else {
           setState(() {
             _errorMessage = "Could not read file data.";
           });
        }
      }
    } catch (e) {
       setState(() {
         _errorMessage = "Error picking file: $e";
       });
    }
  }

  Future<void> startAnalysis() async {
    if (_selectedFileBytes == null || _fileName == null) {
      setState(() {
        _errorMessage = "Please upload a contract PDF first.";
      });
      return;
    }

    setState(() {
      analyzing = true;
      showResults = false;
      _errorMessage = null;
      analysisProgress = 10;
      analysisStage = 'Uploading document...';
    });

    try {
      // Simulate progress for better UX while waiting for API
      _simulateProgress();
      
      // Pass bytes and filename
      final result = await _apiService.analyzePdf(_selectedFileBytes!, _fileName!);

      setState(() {
        _analysisResult = result;
        analysisProgress = 100;
        analysisStage = 'Analysis complete!';
      });

      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        analyzing = false;
        showResults = true;
      });
    } catch (e) {
      setState(() {
        analyzing = false;
        _errorMessage = "Analysis failed: ${e.toString()}";
      });
    }
  }

  void _simulateProgress() async {
    if (!analyzing) return;
    await Future.delayed(const Duration(milliseconds: 800));
    if (analyzing) setState(() { analysisProgress = 30; analysisStage = 'Extracting text...'; });
    
    await Future.delayed(const Duration(milliseconds: 1500));
    if (analyzing) setState(() { analysisProgress = 60; analysisStage = 'Analyzing clauses...'; });
    
    await Future.delayed(const Duration(milliseconds: 1500));
    if (analyzing) setState(() { analysisProgress = 80; analysisStage = 'Calculating fairness...'; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
           decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.foreground),
              onPressed: () => context.pop(),
            ),
            title: Column(
              children: [
                Text('Contract Analysis', style: AppTextStyles.base.copyWith(fontWeight: FontWeight.w600)),
                Text('AI-powered review', style: AppTextStyles.xs),
              ],
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildContractPreviewCard(),
              const SizedBox(height: 16),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(_errorMessage!, style: TextStyle(color: AppColors.error)),
                ),
              if (!analyzing && !showResults) _buildAnalyzeButton(),
              if (analyzing) _buildLoadingCard(),
              if (showResults && _analysisResult != null) _buildResultsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContractPreviewCard() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Uploaded Contract', style: AppTextStyles.sm.copyWith(fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: _pickFile, 
              child: Text(_selectedFileBytes == null ? 'Upload' : 'Change')
            ),
          ],
        ),
        Container(
          height: 200, // Reduced height
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Stack(
            children: [
              const Center(child: Icon(Icons.insert_drive_file, size: 64, color: Colors.grey)),
              if (_fileName != null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.description, color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _fileName!, 
                            style: const TextStyle(color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_fileName == null)
                  const Center(child: Padding(
                    padding: EdgeInsets.only(top: 80.0),
                    child: Text("No file selected"),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyzeButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _selectedFileBytes != null ? startAnalysis : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: Colors.grey[300],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.analytics_outlined),
            SizedBox(width: 8),
            Text('Analyze Contract'),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Analyzing contract...', style: AppTextStyles.sm.copyWith(fontWeight: FontWeight.w600)),
                    Text(analysisStage, style: AppTextStyles.xs),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: analysisProgress / 100,
            backgroundColor: AppColors.secondary,
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSection() {
    final result = _analysisResult!;
    // Use price estimation if available, or fallbacks/zeros
    final priceEst = result.priceEstimation;
    final userTotal = ContractData.total; // Ideally this should come from OCR parsing too if possible
    
    // For now, we will use static total from ContractData as per original design 
    // BUT we should try to extract it from the 'clauses' or 'vehicle_info' if the backend provides it.
    // The current backend doesn't seem to extract 'total_cost' explicitly in the root response.
    // So we'll stick to ContractData.total for the "Your Total Lease Cost" 
    // UNLESS we want to add parsing logic on the specific 'total' field.
    
    // However, the prompt says "connect backend", so we should use what we have.
    // The backend returns: clauses, fairness, ai_summary, vehicle_info, price_estimation.

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary Section
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text('AI Contract Summary', style: AppTextStyles.lg.copyWith(fontWeight: FontWeight.bold)),
             const SizedBox(height: 12),
             Container(
               width: double.infinity,
               padding: const EdgeInsets.all(20),
               decoration: BoxDecoration(
                 color: const Color(0xFFEFF6FF), // Light blue background
                 borderRadius: BorderRadius.circular(16),
                 border: Border.all(color: const Color(0xFFDBEAFE)), // Subtle border
               ),
               child: Row(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Container(
                     padding: const EdgeInsets.all(8),
                     decoration: const BoxDecoration(
                       color: Color(0xFFDBEAFE), // Slightly darker blue circle
                       shape: BoxShape.circle,
                     ),
                     child: const Icon(Icons.check, color: AppColors.primary, size: 20),
                   ),
                   const SizedBox(width: 16),
                   Expanded(
                     child: Text(
                       result.aiSummary,
                       style: AppTextStyles.base.copyWith(height: 1.5, fontSize: 15),
                     ),
                   ),
                 ],
               ),
             ),
          ],
        ),
        const SizedBox(height: 24),

        // Fairness Score
        Center(
          child: Column(
            children: [
              _CircularScoreWidget(score: result.fairness.round()),
              if (result.fairnessRating != null) ...[
                const SizedBox(height: 8),
                Text(
                  result.fairnessRating!,
                  style: AppTextStyles.lg.copyWith(
                    color: _getFairnessColor(result.fairness.round()),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              if (result.fairnessReasons != null && result.fairnessReasons!.isNotEmpty) ...[
                const SizedBox(height: 12),
                ...result.fairnessReasons!.map((reason) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.warning),
                      const SizedBox(width: 8),
                      Text(reason, style: AppTextStyles.sm.copyWith(color: AppColors.mutedForeground)),
                    ],
                  ),
                )).toList(),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Key Terms Grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: [
            _TermCard(
              icon: Icons.percent,
              iconBg: AppColors.blue50,
              iconColor: AppColors.primary,
              label: 'Interest Rate',
              value: result.contractDetails?['interest_rate'] != null 
                  ? '${result.contractDetails!['interest_rate']}%' 
                  : 'NaN',
              status: result.contractDetails?['interest_rate'] != null ? 'Analyzed' : null,
              statusColor: AppColors.success,
            ),
            _TermCard(
              icon: Icons.attach_money,
              iconBg: AppColors.green50,
              iconColor: AppColors.success,
              label: 'Monthly',
              value: result.contractDetails?['monthly_payment'] != null 
                  ? '\$${result.contractDetails!['monthly_payment']}' 
                  : 'NaN',
              subtitle: result.contractDetails?['lease_term_months'] != null 
                  ? '${result.contractDetails!['lease_term_months']} months' 
                  : null,
            ),
             _TermCard(
              icon: Icons.calendar_today,
              iconBg: AppColors.purple50,
              iconColor: AppColors.purple,
              label: 'Term',
              value: result.contractDetails?['lease_term_months'] != null 
                  ? '${result.contractDetails!['lease_term_months']} mo' 
                  : 'NaN',
              subtitle: 'Duration',
            ),
            _TermCard(
              icon: Icons.speed,
              iconBg: AppColors.amber50,
              iconColor: AppColors.warning,
              label: 'Mileage',
              value: result.contractDetails?['mileage_limit_per_year'] != null 
                  ? '${(result.contractDetails!['mileage_limit_per_year'] / 1000).toStringAsFixed(0)}K/yr' 
                  : 'NaN',
              subtitle: 'Limit',
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Early Termination Fee (if detected in prediction)
        // We can check if 'early_termination' is in clauses
        if (result.clauses.containsKey('early_termination'))
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.red50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.error.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.error),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Early Termination Clause Detected', style: AppTextStyles.sm.copyWith(fontWeight: FontWeight.bold, color: AppColors.error)),
                  Text('Review Carefully', style: AppTextStyles.xs.copyWith(color: AppColors.error)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Market Price Benchmark
        if (priceEst != null)
           _buildMarketBenchmark(context, priceEst),
        
        const SizedBox(height: 24),

        // Action Button
        ElevatedButton(
          onPressed: () => context.push(
            '/negotiate/${widget.contractId}',
            extra: result,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            minimumSize: const Size(double.infinity, 48),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chat),
              SizedBox(width: 8),
              Text('Start Negotiation'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMarketBenchmark(BuildContext context, Map<String, dynamic> priceEst) {
    // Backend returns 'estimated_price_min' and 'estimated_price_max'
    
    final double marketMin = (priceEst['estimated_price_min'] ?? ContractData.marketMin).toDouble();
    final double marketMax = (priceEst['estimated_price_max'] ?? ContractData.marketMax).toDouble();
    final double totalCost = ContractData.total.toDouble(); // Still static as we don't extract total cost yet

    final double range = marketMax - marketMin;
    final double value = totalCost - marketMin;
    final double percentage = (range == 0) ? 0.5 : (value / range).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Market Price Benchmark', style: AppTextStyles.lg.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Top Row: Cost and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your Total Lease Cost', style: AppTextStyles.sm.copyWith(color: AppColors.mutedForeground)),
                      const SizedBox(height: 4),
                      Text(
                        '\$${totalCost.toStringAsFixed(0)}',
                        style: AppTextStyles.xxl.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.green50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.success),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.trending_down, size: 16, color: AppColors.success),
                        const SizedBox(width: 4),
                        Text('Below Market', style: AppTextStyles.sm.copyWith(color: AppColors.success, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Market Range Labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Market Range', style: AppTextStyles.sm.copyWith(color: AppColors.mutedForeground)),
                  Text(
                    '\$${marketMin.toStringAsFixed(0)} - \$${marketMax.toStringAsFixed(0)}', 
                    style: AppTextStyles.sm.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Gradient Bar with Indicator
              SizedBox(
                height: 60,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final double indicatorPosition = width * percentage;

                    return Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.centerLeft,
                      children: [
                        // The Gradient Bar
                        Container(
                          height: 12,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4ADE80), Color(0xFFFACC15), Color(0xFFFB923C)],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        
                        // The Indicator
                        Positioned(
                          left: (indicatorPosition - 40).clamp(0.0, width - 80),
                          top: -30,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1F2937),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Your deal',
                                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                              CustomPaint(
                                size: const Size(10, 6),
                                painter: _TrianglePainter(),
                              ),
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1F2937),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 8),

              // Legend
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF4ADE80), shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text('Great Deal', style: AppTextStyles.xs.copyWith(color: AppColors.success)),
                    ],
                  ),
                  Row(
                    children: [
                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFFB923C), shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text('Above Market', style: AppTextStyles.xs.copyWith(color: Colors.orange)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getFairnessColor(int score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return Colors.orange;
    return AppColors.error;
  }
}

class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1F2937)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CircularScoreWidget extends StatelessWidget {
  final int score;
  const _CircularScoreWidget({required this.score});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: CustomPaint(
            painter: _ScorePainter(score),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$score', style: AppTextStyles.xxxl),
                  Text('/100', style: AppTextStyles.xs.copyWith(color: AppColors.mutedForeground)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(color: AppColors.green50, borderRadius: BorderRadius.circular(12)),
          child: Text('Fair Deal', style: AppTextStyles.sm.copyWith(color: AppColors.success, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

class _ScorePainter extends CustomPainter {
  final int score;
  _ScorePainter(this.score);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 10.0;

    final bgPaint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final scorePaint = Paint()
      ..color = AppColors.success
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);
    
    final angle = 2 * math.pi * (score / 100);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -math.pi / 2,
      angle,
      false,
      scorePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _TermCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String value;
  final String? subtitle;
  final String? status;
  final Color? statusColor;

  const _TermCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.value,
    this.subtitle,
    this.status,
    this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              if (status != null)
                Text(status!, style: AppTextStyles.xs.copyWith(color: statusColor, fontWeight: FontWeight.bold)),
            ],
          ),
          const Spacer(),
          Text(label, style: AppTextStyles.xs.copyWith(color: AppColors.mutedForeground)),
          Text(value, style: AppTextStyles.lg.copyWith(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
          if (subtitle != null) Text(subtitle!, style: AppTextStyles.xs.copyWith(fontSize: 10), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
