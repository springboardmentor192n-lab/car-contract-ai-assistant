class ContractData {
  static const vehicle = '2024 Tesla Model 3 Long Range';
  static const vin = '5YJ3E1EA8LF123456';
  static const monthly = 549;
  static const term = 36;
  static const total = 19764;
  static const interestRate = 4.9;
  static const mileagePerYear = 12000;
  static const mileageOverage = 0.25;
  static const earlyTerminationFee = 2500;
  static const fairnessScore = 78;
  static const marketMin = 18500;
  static const marketMax = 22400;
  static const savingsAmount = 386;

  static final history = [
    HistoryItem(
      id: '1',
      vehicle: '2024 Tesla Model 3 Long Range',
      dealer: 'Tesla Direct',
      date: 'Feb 5, 2026',
      monthly: 549,
      term: 36,
      score: 78,
      status: 'Fair Deal',
      totalCost: 19764,
    ),
    HistoryItem(
      id: '2',
      vehicle: '2024 BMW 330i xDrive',
      dealer: 'BMW of Manhattan',
      date: 'Jan 28, 2026',
      monthly: 485,
      term: 36,
      score: 92,
      status: 'Great Deal',
      totalCost: 17460,
    ),
    HistoryItem(
      id: '3',
      vehicle: '2023 Honda Accord Sport',
      dealer: 'Honda City Center',
      date: 'Jan 15, 2026',
      monthly: 395,
      term: 48,
      score: 62,
      status: 'Needs Review',
      totalCost: 18960,
    ),
    HistoryItem(
      id: '4',
      vehicle: '2024 Audi Q5 Premium',
      dealer: 'Audi Downtown',
      date: 'Dec 20, 2025',
      monthly: 625,
      term: 36,
      score: 45,
      status: 'Risky',
      totalCost: 22500,
    ),
    HistoryItem(
      id: '5',
      vehicle: '2024 Mercedes C300 4MATIC',
      dealer: 'Mercedes-Benz of SoHo',
      date: 'Dec 10, 2025',
      monthly: 589,
      term: 36,
      score: 72,
      status: 'Fair Deal',
      totalCost: 21204,
    ),
    HistoryItem(
      id: '6',
      vehicle: '2023 Toyota Camry XSE',
      dealer: 'Toyota Plaza',
      date: 'Nov 25, 2025',
      monthly: 375,
      term: 48,
      score: 88,
      status: 'Great Deal',
      totalCost: 18000,
    ),
    HistoryItem(
      id: '7',
      vehicle: '2024 Porsche Macan S',
      dealer: 'Porsche Center',
      date: 'Nov 10, 2025',
      monthly: 895,
      term: 36,
      score: 58,
      status: 'Needs Review',
      totalCost: 32220,
    ),
     HistoryItem(
      id: '8',
      vehicle: '2024 Ford Mustang GT',
      dealer: 'Ford Performance',
      date: 'Oct 30, 2025',
      monthly: 525,
      term: 48,
      score: 75,
      status: 'Fair Deal',
      totalCost: 25200,
    ),
  ];
}

class HistoryItem {
  final String id;
  final String vehicle;
  final String dealer;
  final String date;
  final int monthly;
  final int term;
  final int score;
  final String status;
  final int totalCost;

  HistoryItem({
    required this.id,
    required this.vehicle,
    required this.dealer,
    required this.date,
    required this.monthly,
    required this.term,
    required this.score,
    required this.status,
    required this.totalCost,
  });
}
