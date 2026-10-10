import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

const String baseUrl = 'http://127.0.0.1:8080';

void main() {
  runApp(const SpendIQApp());
}

// =====================================================
// APP
// =====================================================

class SpendIQApp extends StatelessWidget {
  const SpendIQApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SpendIQ',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const SpendIQSplashScreen(),
    );
  }
}


// =====================================================
// SPENDIQ SIGNATURE SPLASH
// =====================================================

class SpendIQSplashScreen extends StatefulWidget {
  const SpendIQSplashScreen({super.key});

  @override
  State<SpendIQSplashScreen> createState() => _SpendIQSplashScreenState();
}

class _SpendIQSplashScreenState extends State<SpendIQSplashScreen>
    with TickerProviderStateMixin {
  static const MethodChannel _platform = MethodChannel('spend_iq_test');

  late final AnimationController _walletController;
  late final AnimationController _coinController;
  late final AnimationController _brandController;

  @override
  void initState() {
    super.initState();

    _walletController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _coinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _brandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _runSplash();
  }

  Future<void> _playCoinSound() async {
    try {
      await _platform.invokeMethod('playCoinSound');
    } catch (_) {
      // App still works if the device cannot play the short native tone.
    }
  }

  Future<int?> _savedUserId() async {
    try {
      final value = await _platform.invokeMethod('getSavedUserId');
      if (value is int && value > 0) return value;
      if (value is num && value.toInt() > 0) return value.toInt();
    } catch (_) {}
    return null;
  }

  Future<void> _runSplash() async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (!mounted) return;

    await _walletController.forward();
    if (!mounted) return;

    _playCoinSound();
    await _coinController.forward();
    if (!mounted) return;

    await _brandController.forward();
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;

    final userId = await _savedUserId();
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => userId != null
            ? DashboardScreen(userId: userId)
            : const LoginScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _walletController.dispose();
    _coinController.dispose();
    _brandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF061126);
    const purple = Color(0xFF7C4DFF);
    const cyan = Color(0xFF29D9D0);

    return Scaffold(
      backgroundColor: navy,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 230,
                  height: 230,
                  child: AnimatedBuilder(
                    animation: Listenable.merge([
                      _walletController,
                      _coinController,
                    ]),
                    builder: (context, _) {
                      final open = Curves.easeOutBack.transform(
                        _walletController.value,
                      );
                      final coin = Curves.easeOutCubic.transform(
                        _coinController.value,
                      );

                      return Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          // Rupee coins rise out of the wallet.
                          for (int i = 0; i < 3; i++)
                            Positioned(
                              top: 82 - (coin * (72 + i * 15)),
                              left: 72 + i * 36,
                              child: Opacity(
                                opacity: _coinController.value,
                                child: Transform.rotate(
                                  angle: (i - 1) * .22 * coin,
                                  child: Transform.scale(
                                    scale: .65 + (.22 * coin),
                                    child: Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFFFD86F),
                                            Color(0xFFFFA726),
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFFFC857)
                                                .withValues(alpha: .35),
                                            blurRadius: 18,
                                          ),
                                        ],
                                      ),
                                      alignment: Alignment.center,
                                      child: const Text(
                                        '₹',
                                        style: TextStyle(
                                          color: Color(0xFF332000),
                                          fontSize: 23,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          // Card coming out of wallet.
                          Positioned(
                            top: 69 - (open * 16),
                            child: Transform.rotate(
                              angle: -.10 * open,
                              child: Container(
                                width: 112,
                                height: 62,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  gradient: const LinearGradient(
                                    colors: [cyan, Color(0xFF3B82F6)],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Wallet body.
                          Positioned(
                            bottom: 31,
                            child: Transform.scale(
                              scale: .82 + (.18 * open),
                              child: Container(
                                width: 174,
                                height: 112,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(28),
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFFA66BFF),
                                      purple,
                                      Color(0xFF4C37E8),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: purple.withValues(alpha: .45),
                                      blurRadius: 30,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Align(
                                  alignment: const Alignment(.88, .12),
                                  child: Container(
                                    width: 48,
                                    height: 43,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF25186E),
                                      borderRadius: BorderRadius.circular(13),
                                    ),
                                    child: const Icon(
                                      Icons.circle,
                                      size: 10,
                                      color: Color(0xFFBDA8FF),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),
                FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _brandController,
                    curve: Curves.easeIn,
                  ),
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, .25),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _brandController,
                      curve: Curves.easeOutCubic,
                    )),
                    child: Column(
                      children: [
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -.8,
                            ),
                            children: [
                              TextSpan(
                                text: 'Spend',
                                style: TextStyle(color: Colors.white),
                              ),
                              TextSpan(
                                text: 'IQ',
                                style: TextStyle(color: purple),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Smarter Choices. Brighter Future.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFAEBBD3),
                            fontSize: 15,
                            letterSpacing: .2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =====================================================
// FIRST LOGIN SUCCESS COIN
// =====================================================

class LoginSuccessCoinScreen extends StatefulWidget {
  final int userId;

  const LoginSuccessCoinScreen({
    super.key,
    required this.userId,
  });

  @override
  State<LoginSuccessCoinScreen> createState() => _LoginSuccessCoinScreenState();
}

class _LoginSuccessCoinScreenState extends State<LoginSuccessCoinScreen>
    with SingleTickerProviderStateMixin {
  static const MethodChannel _platform = MethodChannel('spend_iq_test');
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _run();
  }

  Future<void> _run() async {
    try {
      await _platform.invokeMethod('playCoinSound');
    } catch (_) {}

    await _controller.forward();
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => DashboardScreen(userId: widget.userId),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF7C4DFF);

    return Scaffold(
      backgroundColor: const Color(0xFF061126),
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final jump = Curves.easeOutBack.transform(_controller.value);
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.translate(
                  offset: Offset(0, -75 * jump),
                  child: Transform.scale(
                    scale: .7 + (.35 * jump),
                    child: Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFE082), Color(0xFFFFA726)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFC857)
                                .withValues(alpha: .4),
                            blurRadius: 28,
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        '₹',
                        style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF332000),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Opacity(
                  opacity: _controller.value,
                  child: const Column(
                    children: [
                      Text(
                        'Welcome to SpendIQ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Your smarter money journey starts here.',
                        style: TextStyle(
                          color: Color(0xFFAEBBD3),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                SizedBox(
                  width: 150,
                  child: LinearProgressIndicator(
                    value: _controller.value,
                    minHeight: 5,
                    borderRadius: BorderRadius.circular(10),
                    color: purple,
                    backgroundColor: const Color(0xFF172440),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// =====================================================
// LOGIN SCREEN
// =====================================================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;

  Future<void> login() async {
    setState(() {
      loading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': emailController.text.trim(),
          'password': passwordController.text,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final int userId = data['id'];
        const platform = MethodChannel('spend_iq_test');

        await platform.invokeMethod(
        'saveUserId',
       {
       'userId': userId,
      },
            );        

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginSuccessCoinScreen(
              userId: userId,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid email or password'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection error: $e'),
        ),
      );
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SpendIQ Login'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 80),

            const Text(
              'SpendIQ',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Track less. Understand more.',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : login,
                child: loading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Login'),
              ),
            ),

            const SizedBox(height: 10),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const RegisterScreen(),
                  ),
                );
              },
              child: const Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// REGISTER SCREEN
// =====================================================

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;

  Future<void> register() async {
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
        ),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'password': passwordController.text,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration Successful!'),
          ),
        );

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Registration failed: ${response.body}',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection error: $e'),
        ),
      );
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 50),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : register,
                child: loading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Register'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// DASHBOARD SCREEN
// =====================================================


class _BudgetDonutPainter extends CustomPainter {
  final double progress;
  final Color color;

  const _BudgetDonutPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * .11;
    final rect = Offset(stroke / 2, stroke / 2) &
        Size(size.width - stroke, size.height - stroke);

    final track = Paint()
      ..color = Colors.white.withValues(alpha: .08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final active = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, -math.pi / 2, math.pi * 2, false, track);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * progress.clamp(0.0, 1.0),
      false,
      active,
    );
  }

  @override
  bool shouldRepaint(covariant _BudgetDonutPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

class DashboardScreen extends StatefulWidget {
  final int userId;

  const DashboardScreen({
    super.key,
    required this.userId,
  });

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState
    extends State<DashboardScreen> with SingleTickerProviderStateMixin {

  final ScrollController _dashboardScrollController = ScrollController();
  final GlobalKey _spendingOverviewKey = GlobalKey();
  late final AnimationController _analyticsAnimationController;
  bool _highlightSpendingOverview = false;
  String _selectedSpendingRange = 'Weekly';

  double totalSpending = 0;

  double monthlyIncome = 0;
  bool loadingIncome = false;

  Map<String, dynamic>? smartBudget;
  bool loadingSmartBudget = false;

  Map<String, dynamic>? aiAdvice;
  bool loadingAiAdvice = false;

  List<Map<String, dynamic>> transactions = [];

  Map<String, double> get currentMonthCategorySpending {
    final now = DateTime.now();
    final totals = <String, double>{};

    for (final expense in transactions) {
      final date = DateTime.tryParse(expense['dateTime']?.toString() ?? '');
      if (date == null || date.year != now.year || date.month != now.month) continue;

      final rawCategory = expense['category']?.toString().trim() ?? '';
      final category = rawCategory.isEmpty ? 'Other' : rawCategory;
      final amount = (expense['amount'] as num?)?.toDouble() ?? 0;
      totals[category] = (totals[category] ?? 0) + amount;
    }
    return totals;
  }

  Widget expenseAnalyticsCard() {
    final entries = currentMonthCategorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final monthTotal = entries.fold<double>(0, (sum, item) => sum + item.value);

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                Icon(Icons.insights_outlined),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Expense Analytics',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Where your money is going this month',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            if (entries.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'No expenses available for this month yet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else ...[
              Row(
                children: [
                  Expanded(
                    child: _smartBudgetMetric(
                      'This Month',
                      '₹${monthTotal.toStringAsFixed(0)}',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _smartBudgetMetric('Top Category', entries.first.key),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...entries.take(6).map((entry) {
                final percentage =
                    monthTotal > 0 ? (entry.value / monthTotal) * 100 : 0.0;
                final progress =
                    monthTotal > 0 ? entry.value / monthTotal : 0.0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              entry.key,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          Text(
                            '₹${entry.value.toStringAsFixed(0)} • ${percentage.toStringAsFixed(1)}%',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0).toDouble(),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  double dailyLimit = 0;
  double todaySpending = 0;
  double dailyPercentage = 0;
  double dailyExceededAmount = 0;
  String dailyStatus = 'NOT_SET';

  double weeklyLimit = 0;
  double thisWeekSpending = 0;
  double weeklyPercentage = 0;
  double weeklyExceededAmount = 0;
  String weeklyStatus = 'NOT_SET';

  double fifteenDayLimit = 0;
  double lastFifteenDaysSpending = 0;
  double fifteenDayPercentage = 0;
  double fifteenDayExceededAmount = 0;
  String fifteenDayStatus = 'NOT_SET';

  double monthlyLimit = 0;
  double currentMonthSpending = 0;
  double monthlyPercentage = 0;
  double monthlyExceededAmount = 0;
  String monthlyStatus = 'NOT_SET';

  bool loadingExpenses = false;
  bool loadingDaily = false;
  bool loadingWeekly = false;
  bool loadingFifteenDays = false;
  bool loadingMonthly = false;
  bool persistentBudgetStatusEnabled = true;

  static const MethodChannel _nativeChannel = MethodChannel('spend_iq_test');

  @override
  void initState() {
    super.initState();
    _analyticsAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _initializeBudgetStatus();
  }

  @override
  void dispose() {
    _analyticsAnimationController.dispose();
    _dashboardScrollController.dispose();
    super.dispose();
  }

  Future<void> _focusSpendingOverview() async {
    final targetContext = _spendingOverviewKey.currentContext;
    if (targetContext != null) {
      await Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeInOutCubic,
        alignment: .16,
      );
    }

    if (!mounted) return;
    setState(() => _highlightSpendingOverview = true);

    _analyticsAnimationController
      ..reset()
      ..forward();

    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      setState(() => _highlightSpendingOverview = false);
    }
  }

  Future<void> _initializeBudgetStatus() async {
    try {
      final enabled = await _nativeChannel.invokeMethod<bool>('isBudgetStatusEnabled');
      if (mounted && enabled != null) {
        setState(() => persistentBudgetStatusEnabled = enabled);
      }
      await _nativeChannel.invokeMethod('requestNotificationPermission');
    } catch (e) {
      debugPrint('Budget status init error: $e');
    }
    await refreshDashboard();
  }

  Future<void> _updatePersistentBudgetNotification() async {
    if (!persistentBudgetStatusEnabled) return;
    try {
      await _nativeChannel.invokeMethod('updateBudgetStatus', {
        'dailyLimit': dailyLimit,
        'todaySpending': todaySpending,
        'weeklyLimit': weeklyLimit,
        'thisWeekSpending': thisWeekSpending,
        'fifteenDayLimit': fifteenDayLimit,
        'lastFifteenDaysSpending': lastFifteenDaysSpending,
        'monthlyLimit': monthlyLimit,
        'currentMonthSpending': currentMonthSpending,
      });
    } catch (e) {
      debugPrint('Budget notification update error: $e');
    }
  }

  Future<void> _setPersistentBudgetStatus(bool enabled) async {
    setState(() => persistentBudgetStatusEnabled = enabled);
    try {
      await _nativeChannel.invokeMethod('setBudgetStatusEnabled', {'enabled': enabled});
      if (enabled) {
        await _nativeChannel.invokeMethod('requestNotificationPermission');
        await _updatePersistentBudgetNotification();
      }
    } catch (e) {
      debugPrint('Budget status setting error: $e');
    }
  }

  // ===================================================
  // TEST NOTIFICATION
  // ===================================================

  Future<void> sendTestNotification() async {
    try {
      const channel = MethodChannel('spend_iq_test');

      await channel.invokeMethod(
        'sendTestNotification',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Test payment notification sent!',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Test notification error: $e',
          ),
        ),
      );
    }
  }

  // ===================================================
  // LOAD EXPENSES
  // ===================================================

  Future<void> loadExpenses() async {
    setState(() {
      loadingExpenses = true;
    });

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/expenses'),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        final userTransactions = data
            .where((expense) => expense['userId'] == widget.userId)
            .map<Map<String, dynamic>>(
              (expense) => Map<String, dynamic>.from(expense),
            )
            .toList();

        userTransactions.sort((a, b) {
          final aDate = DateTime.tryParse(a['dateTime']?.toString() ?? '');
          final bDate = DateTime.tryParse(b['dateTime']?.toString() ?? '');
          if (aDate == null && bDate == null) return 0;
          if (aDate == null) return 1;
          if (bDate == null) return -1;
          return bDate.compareTo(aDate);
        });

        double total = 0;
        for (final expense in userTransactions) {
          total += (expense['amount'] as num).toDouble();
        }

        if (mounted) {
          setState(() {
            totalSpending = total;
            transactions = userTransactions;
          });
          _analyticsAnimationController
            ..reset()
            ..forward();
        }
      }
    } catch (e) {
      debugPrint('Expense error: $e');
    }

    if (mounted) {
      setState(() {
        loadingExpenses = false;
      });
    }
  }

  // ===================================================
  // LOAD DAILY
  // ===================================================

  Future<void> loadDailyLimit() async {
    setState(() {
      loadingDaily = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/api/daily-limit/${widget.userId}/status',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (mounted) {
          setState(() {
            if (data['dailyLimit'] != null) {
              dailyLimit =
                  (data['dailyLimit'] as num).toDouble();
            }

            if (data['todaySpending'] != null) {
              todaySpending =
                  (data['todaySpending'] as num).toDouble();
            }

            if (data['percentage'] != null) {
              dailyPercentage =
                  (data['percentage'] as num).toDouble();
            }

            if (data['exceededAmount'] != null) {
              dailyExceededAmount =
                  (data['exceededAmount'] as num).toDouble();
            }

            if (data['status'] != null) {
              dailyStatus =
                  data['status'].toString();
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Daily error: $e');
    }

    if (mounted) {
      setState(() {
        loadingDaily = false;
      });
    }
  }

  // ===================================================
  // LOAD WEEKLY
  // ===================================================

  Future<void> loadWeeklyLimit() async {
    setState(() {
      loadingWeekly = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/api/weekly-limit/${widget.userId}/status',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (mounted) {
          setState(() {
            if (data['weeklyLimit'] != null) {
              weeklyLimit =
                  (data['weeklyLimit'] as num).toDouble();
            }

            if (data['thisWeekSpending'] != null) {
              thisWeekSpending =
                  (data['thisWeekSpending'] as num).toDouble();
            }

            if (data['percentage'] != null) {
              weeklyPercentage =
                  (data['percentage'] as num).toDouble();
            }

            if (data['exceededAmount'] != null) {
              weeklyExceededAmount =
                  (data['exceededAmount'] as num).toDouble();
            }

            if (data['status'] != null) {
              weeklyStatus =
                  data['status'].toString();
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Weekly error: $e');
    }

    if (mounted) {
      setState(() {
        loadingWeekly = false;
      });
    }
  }

  // ===================================================
  // LOAD 15 DAYS
  // ===================================================

  Future<void> loadFifteenDayLimit() async {
    setState(() {
      loadingFifteenDays = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/api/fifteen-day-limit/${widget.userId}/status',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (mounted) {
          setState(() {
            if (data['fifteenDayLimit'] != null) {
              fifteenDayLimit =
                  (data['fifteenDayLimit'] as num)
                      .toDouble();
            }

            if (data['lastFifteenDaysSpending'] != null) {
              lastFifteenDaysSpending =
                  (data['lastFifteenDaysSpending'] as num)
                      .toDouble();
            }

            if (data['percentage'] != null) {
              fifteenDayPercentage =
                  (data['percentage'] as num)
                      .toDouble();
            }

            if (data['exceededAmount'] != null) {
              fifteenDayExceededAmount =
                  (data['exceededAmount'] as num)
                      .toDouble();
            }

            if (data['status'] != null) {
              fifteenDayStatus =
                  data['status'].toString();
            }
          });
        }
      }
    } catch (e) {
      debugPrint('15 Days error: $e');
    }

    if (mounted) {
      setState(() {
        loadingFifteenDays = false;
      });
    }
  }

  // ===================================================
  // LOAD MONTHLY
  // ===================================================

  Future<void> loadMonthlyLimit() async {
    setState(() {
      loadingMonthly = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/api/monthly-limit/${widget.userId}/status',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (mounted) {
          setState(() {
            if (data['monthlyLimit'] != null) {
              monthlyLimit =
                  (data['monthlyLimit'] as num)
                      .toDouble();
            }

            if (data['currentMonthSpending'] != null) {
              currentMonthSpending =
                  (data['currentMonthSpending'] as num)
                      .toDouble();
            }

            if (data['percentage'] != null) {
              monthlyPercentage =
                  (data['percentage'] as num)
                      .toDouble();
            }

            if (data['exceededAmount'] != null) {
              monthlyExceededAmount =
                  (data['exceededAmount'] as num)
                      .toDouble();
            }

            if (data['status'] != null) {
              monthlyStatus =
                  data['status'].toString();
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Monthly error: $e');
    }

    if (mounted) {
      setState(() {
        loadingMonthly = false;
      });
    }
  }

  // ===================================================
  // SMART BUDGET
  // ===================================================

  Future<void> loadSmartBudget() async {
    if (mounted) setState(() => loadingSmartBudget = true);

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/smart-budget/${widget.userId}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            smartBudget = Map<String, dynamic>.from(data);
          });
        }
      } else {
        debugPrint('Smart Budget GET failed: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      debugPrint('Smart Budget GET error: $e');
    }

    if (mounted) setState(() => loadingSmartBudget = false);
  }

  Widget smartBudgetCard() {
    final data = smartBudget;

    if (data == null) {
      return Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              const Icon(Icons.auto_graph),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  loadingSmartBudget
                      ? 'Calculating your smart budget...'
                      : 'Smart budget is not available yet.',
                ),
              ),
              if (loadingSmartBudget)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
        ),
      );
    }

    final safeDailySpend = (data['safeDailySpend'] as num?)?.toDouble() ?? 0;
    final savingsTarget = (data['savingsTarget'] as num?)?.toDouble() ?? 0;
    final safeBudgetRemaining = (data['safeBudgetRemaining'] as num?)?.toDouble() ?? 0;
    final safeMonthlyBudget = (data['safeMonthlyBudget'] as num?)?.toDouble() ?? 0;
    final spentThisMonth = (data['spentThisMonth'] as num?)?.toDouble() ?? 0;
    final daysRemaining = (data['daysRemaining'] as num?)?.toInt() ?? 0;
    final status = (data['status'] ?? 'UNKNOWN').toString();

    double progress = safeMonthlyBudget > 0 ? spentThisMonth / safeMonthlyBudget : 0;
    progress = progress.clamp(0.0, 1.0).toDouble();

    String statusText;
    IconData statusIcon;
    switch (status) {
      case 'OVER_INCOME':
        statusText = 'Over Income';
        statusIcon = Icons.error_outline;
        break;
      case 'SAVINGS_AT_RISK':
        statusText = 'Savings at Risk';
        statusIcon = Icons.warning_amber_rounded;
        break;
      case 'CAUTION':
        statusText = 'Caution';
        statusIcon = Icons.warning_amber_rounded;
        break;
      default:
        statusText = 'On Track';
        statusIcon = Icons.check_circle_outline;
    }

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_graph),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Smart Budget',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
                Icon(statusIcon),
                const SizedBox(width: 5),
                Text(statusText, style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 18),
            const Text('Safe to spend today', style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 3),
            Text(
              '₹${safeDailySpend.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 18),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 8),
            Text(
              '₹${spentThisMonth.toStringAsFixed(0)} spent of ₹${safeMonthlyBudget.toStringAsFixed(0)} safe monthly budget',
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(child: _smartBudgetMetric('Savings Target', '₹${savingsTarget.toStringAsFixed(0)}')),
                const SizedBox(width: 12),
                Expanded(child: _smartBudgetMetric('Safe Budget Left', '₹${safeBudgetRemaining.toStringAsFixed(0)}')),
              ],
            ),
            const SizedBox(height: 12),
            _smartBudgetMetric('Days Remaining', '$daysRemaining days'),
          ],
        ),
      ),
    );
  }

  // ===================================================
  // AI BUDGET ADVISOR
  // ===================================================

  Future<void> loadAiAdvice() async {
    if (mounted) setState(() => loadingAiAdvice = true);

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/ai-advisor/budget/${widget.userId}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            aiAdvice = Map<String, dynamic>.from(data);
          });
        }
      } else {
        debugPrint('AI Advisor GET failed: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      debugPrint('AI Advisor GET error: $e');
    }

    if (mounted) setState(() => loadingAiAdvice = false);
  }

  Widget aiAdvisorCard() {
    final data = aiAdvice;
    final advice = (data?['advice'] ?? '').toString().trim();
    final status = (data?['status'] ?? '').toString();

    String statusText = 'AI Budget Coach';
    IconData statusIcon = Icons.auto_awesome;
    if (status == 'ON_TRACK') {
      statusText = 'On Track';
      statusIcon = Icons.check_circle_outline;
    } else if (status == 'CAUTION') {
      statusText = 'Caution';
      statusIcon = Icons.warning_amber_rounded;
    } else if (status == 'SAVINGS_AT_RISK') {
      statusText = 'Savings at Risk';
      statusIcon = Icons.warning_amber_rounded;
    } else if (status == 'OVER_INCOME') {
      statusText = 'Over Income';
      statusIcon = Icons.error_outline;
    }

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'SpendIQ AI Advisor',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
                if (loadingAiAdvice)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else ...[
                  Icon(statusIcon, size: 20),
                  const SizedBox(width: 5),
                  Text(statusText, style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ],
            ),
            const SizedBox(height: 14),
            if (advice.isEmpty)
              Text(
                loadingAiAdvice
                    ? 'AI is analysing your income and spending...'
                    : monthlyIncome <= 0
                        ? 'Set your monthly income to get personalised AI advice.'
                        : 'AI advice is not available right now. Tap refresh to try again.',
                style: const TextStyle(fontSize: 14, height: 1.45),
              )
            else
              Text(
                advice,
                style: const TextStyle(fontSize: 14.5, height: 1.5),
              ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: loadingAiAdvice ? null : loadAiAdvice,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Refresh Advice'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _smartBudgetMetric(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ===================================================
  // MONTHLY INCOME
  // ===================================================

  Future<void> loadIncome() async {
    if (mounted) {
      setState(() {
        loadingIncome = true;
      });
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/income/${widget.userId}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (mounted) {
          setState(() {
            monthlyIncome =
                (data['monthlyIncome'] as num?)?.toDouble() ?? 0;
          });
        }
      } else {
        debugPrint(
          'Income GET failed: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('Income GET error: $e');
    }

    if (mounted) {
      setState(() {
        loadingIncome = false;
      });
    }
  }

  Future<void> saveIncome(double amount) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/income'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'userId': widget.userId,
          'monthlyIncome': amount,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          monthlyIncome =
              (data['monthlyIncome'] as num?)?.toDouble() ?? amount;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Monthly income saved successfully'),
          ),
        );

        await loadSmartBudget();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not save income (${response.statusCode})',
            ),
          ),
        );

        debugPrint(
          'Income POST failed: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Income save error: $e'),
        ),
      );
    }
  }

  Future<void> showIncomeDialog() async {
    final controller = TextEditingController(
      text: monthlyIncome > 0
          ? monthlyIncome.toStringAsFixed(0)
          : '',
    );

    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            monthlyIncome > 0
                ? 'Update Monthly Income'
                : 'Set Monthly Income',
          ),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Monthly Income',
              prefixText: '₹ ',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  controller.text.trim(),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (value == null || value.isEmpty) {
      return;
    }

    final amount = double.tryParse(value);

    if (amount == null || amount <= 0) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a valid monthly income',
          ),
        ),
      );
      return;
    }

    await saveIncome(amount);
  }

  // ===================================================
  // REFRESH
  // ===================================================

  Future<void> refreshDashboard() async {
    await Future.wait([
      loadExpenses(),
      loadIncome(),
      loadSmartBudget(),
      loadAiAdvice(),
      loadDailyLimit(),
      loadWeeklyLimit(),
      loadFifteenDayLimit(),
      loadMonthlyLimit(),
    ]);
    await _updatePersistentBudgetNotification();
  }

  // ===================================================
  // OPEN ADD EXPENSE
  // ===================================================

  Future<void> openAddExpense() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddExpenseScreen(
          userId: widget.userId,
        ),
      ),
    );

    await refreshDashboard();
  }

  // ===================================================
  // OPEN SET LIMITS
  // ===================================================

  Future<void> openSetLimits() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SetLimitsScreen(
          userId: widget.userId,
        ),
      ),
    );

    await refreshDashboard();
  }

  // ===================================================
  // PROGRESS
  // ===================================================

  double progressValue(double percentage) {
    if (percentage <= 0) {
      return 0;
    }

    if (percentage >= 100) {
      return 1;
    }

    return percentage / 100;
  }

  // ===================================================
  // STATUS COLOR
  // ===================================================

  Color statusColor(String status) {
    if (status == 'LIMIT_EXCEEDED') {
      return Colors.red;
    }

    if (status == 'WITHIN_LIMIT') {
      return Colors.green;
    }

    return Colors.grey;
  }

  // ===================================================
  // STATUS TEXT
  // ===================================================

  String statusText(String status) {
    if (status == 'LIMIT_EXCEEDED') {
      return 'Limit Exceeded';
    }

    if (status == 'WITHIN_LIMIT') {
      return 'Within Limit';
    }

    return 'Limit Not Set';
  }

  // ===================================================
  // LIMIT CARD
  // ===================================================

  Widget limitCard({
    required String title,
    required double spent,
    required double limit,
    required double percentage,
    required String status,
    required bool loading,
  }) {
    final color = statusColor(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                if (loading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 15),

            Text(
              '₹${spent.toStringAsFixed(0)} / ₹${limit.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 10),

            LinearProgressIndicator(
              value: progressValue(percentage),
              minHeight: 8,
              color: color,
              backgroundColor: Colors.grey[300],
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${percentage.toStringAsFixed(1)}% Used',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),

                Text(
                  statusText(status),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),

            if (status == 'LIMIT_EXCEEDED')
              Padding(
                padding:
                    const EdgeInsets.only(top: 8),
                child: Text(
                  'Exceeded by ₹${(spent - limit).toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String transactionTitle(Map<String, dynamic> expense) {
    final merchant = expense['merchant']?.toString().trim() ?? '';
    final description = expense['description']?.toString().trim() ?? '';
    if (merchant.isNotEmpty) return merchant;
    if (description.isNotEmpty) return description;
    return 'Expense';
  }

  String transactionDate(dynamic value) {
    if (value == null) return 'Date unavailable';
    final date = DateTime.tryParse(value.toString());
    if (date == null) return value.toString();

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour12 =
        date.hour == 0 ? 12 : (date.hour > 12 ? date.hour - 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '${date.day} ${months[date.month - 1]} ${date.year}, '
        '$hour12:$minute $period';
  }

  final List<String> expenseCategories = [
    'Food',
    'Travel',
    'Shopping',
    'Bills',
    'Education',
    'Entertainment',
    'Health',
    'Other',
  ];

  Future<void> updateTransactionCategory(
    Map<String, dynamic> expense,
    String category,
  ) async {
    final id = expense['id'];

    if (id == null) return;

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/expenses/$id/details'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'category': category,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          expense['category'] = category;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Category saved: $category'),
            duration: const Duration(seconds: 1),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Category save failed: ${response.body}'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Category error: $e'),
        ),
      );
    }
  }

  Future<void> updateTransactionReason(
    Map<String, dynamic> expense,
    String reason,
  ) async {
    final id = expense['id'];
    if (id == null) return;

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/expenses/$id/details'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'reason': reason,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          expense['reason'] = reason;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reason saved successfully'),
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reason save failed: ${response.body}'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reason error: $e'),
        ),
      );
    }
  }

  Future<void> showReasonDialog(
    Map<String, dynamic> expense,
  ) async {
    final controller = TextEditingController(
      text: expense['reason']?.toString() ?? '',
    );

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Expense Reason'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: 500,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Reason / Note',
              hintText: 'Example: Breakfast, College books...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  controller.text.trim(),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      await updateTransactionReason(
        expense,
        result,
      );
    }
  }

  Widget transactionCard(Map<String, dynamic> expense) {
    final amount =
        (expense['amount'] as num?)?.toDouble() ?? 0;

    final rawSource =
        expense['source']?.toString().trim() ?? '';

    final source =
        rawSource.isEmpty
            ? 'MANUAL'
            : rawSource.toUpperCase();

    final paymentMode =
        expense['paymentMode']?.toString().trim() ?? '';

    final savedCategory =
        expense['category']?.toString().trim();

    final String? selectedCategory =
        savedCategory != null &&
                expenseCategories.contains(savedCategory)
            ? savedCategory
            : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Icon(
                    source == 'AUTO'
                        ? Icons.auto_awesome
                        : Icons.edit_note,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        transactionTitle(expense),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        [
                          source,
                          if (paymentMode.isNotEmpty &&
                              paymentMode.toUpperCase() !=
                                  'UNKNOWN')
                            paymentMode.replaceAll('_', ' '),
                          transactionDate(
                            expense['dateTime'],
                          ),
                        ].join(' • '),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '-₹${amount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category_outlined),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              hint: const Text('Select Category'),
              items: expenseCategories
                  .map(
                    (category) => DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    ),
                  )
                  .toList(),
              onChanged: (category) {
                if (category != null) {
                  updateTransactionCategory(
                    expense,
                    category,
                  );
                }
              },
            ),

            const SizedBox(height: 10),

            if ((expense['reason']?.toString().trim() ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.notes,
                      size: 18,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Reason: ${expense['reason']}',
                        style: const TextStyle(
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  showReasonDialog(expense);
                },
                icon: Icon(
                  (expense['reason']?.toString().trim() ?? '').isEmpty
                      ? Icons.add_comment_outlined
                      : Icons.edit_note,
                ),
                label: Text(
                  (expense['reason']?.toString().trim() ?? '').isEmpty
                      ? 'Add Reason'
                      : 'Edit Reason',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget recentTransactionsSection() {
    return Card(
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TransactionsScreen(userId: widget.userId),
            ),
          );
          await loadExpenses();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 17),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _dashPurple.withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: _dashPurple,
                  size: 21,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Transactions',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'View complete history',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              if (loadingExpenses)
                const SizedBox(
                  width: 17,
                  height: 17,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 15,
                  color: Colors.grey,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ===================================================
  // PREMIUM DASHBOARD HELPERS
  // ===================================================

  static const Color _dashNavy = Color(0xFF071226);
  static const Color _dashCard = Color(0xFF101F3D);
  static const Color _dashCard2 = Color(0xFF142445);
  static const Color _dashPurple = Color(0xFF7C4DFF);
  static const Color _dashCyan = Color(0xFF43B5FF);
  static const Color _dashGreen = Color(0xFF24D69A);
  static const Color _dashText = Color(0xFFF7F8FF);
  static const Color _dashMuted = Color(0xFFAAB7D0);

  Widget _premiumCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      decoration: BoxDecoration(
        color: _dashCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: .06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .18),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(18),
        child: child,
      ),
    );
  }

  Widget _quickAction(
    IconData icon,
    String label,
    VoidCallback onTap, {
    Color accent = _dashPurple,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
          decoration: BoxDecoration(
            color: _dashCard2,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: .05)),
          ),
          child: Column(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accent, size: 22),
              ),
              const SizedBox(height: 9),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _dashText,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  DateTime? _expenseDate(Map<String, dynamic> expense) {
    return DateTime.tryParse(expense['dateTime']?.toString() ?? '');
  }

  double _expenseAmount(Map<String, dynamic> expense) {
    return (expense['amount'] as num?)?.toDouble() ?? 0;
  }

  bool _isExpenseInSelectedRange(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expenseDay = DateTime(date.year, date.month, date.day);

    switch (_selectedSpendingRange) {
      case 'Today':
        return expenseDay == today;
      case '15 Days':
        final start = today.subtract(const Duration(days: 14));
        return !expenseDay.isBefore(start) && !expenseDay.isAfter(today);
      case 'Monthly':
        return date.year == now.year && date.month == now.month;
      case 'Weekly':
      default:
        final start = today.subtract(const Duration(days: 6));
        return !expenseDay.isBefore(start) && !expenseDay.isAfter(today);
    }
  }

  List<Map<String, dynamic>> get _selectedRangeTransactions {
    return transactions.where((expense) {
      final date = _expenseDate(expense);
      return date != null && _isExpenseInSelectedRange(date);
    }).toList();
  }

  List<double> get _selectedSpendingValues {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_selectedSpendingRange == 'Today') {
      final values = List<double>.filled(24, 0);
      for (final expense in transactions) {
        final date = _expenseDate(expense);
        if (date == null) continue;
        if (date.year == now.year &&
            date.month == now.month &&
            date.day == now.day) {
          values[date.hour] += _expenseAmount(expense);
        }
      }
      return values;
    }

    if (_selectedSpendingRange == 'Monthly') {
      final values = List<double>.filled(now.day, 0);
      for (final expense in transactions) {
        final date = _expenseDate(expense);
        if (date == null) continue;
        if (date.year == now.year &&
            date.month == now.month &&
            date.day <= now.day) {
          values[date.day - 1] += _expenseAmount(expense);
        }
      }
      return values;
    }

    final days = _selectedSpendingRange == '15 Days' ? 15 : 7;
    final values = List<double>.filled(days, 0);
    final start = today.subtract(Duration(days: days - 1));

    for (final expense in transactions) {
      final date = _expenseDate(expense);
      if (date == null) continue;
      final expenseDay = DateTime(date.year, date.month, date.day);
      final index = expenseDay.difference(start).inDays;
      if (index >= 0 && index < days) {
        values[index] += _expenseAmount(expense);
      }
    }
    return values;
  }

  List<String> get _selectedSpendingLabels {
    final now = DateTime.now();

    if (_selectedSpendingRange == 'Today') {
      return List<String>.generate(24, (hour) {
        if (hour == 0) return '12a';
        if (hour == 6) return '6a';
        if (hour == 12) return '12p';
        if (hour == 18) return '6p';
        if (hour == 23) return 'Now';
        return '';
      });
    }

    if (_selectedSpendingRange == 'Monthly') {
      return List<String>.generate(now.day, (index) {
        final day = index + 1;
        if (day == 1 || day == now.day || day % 5 == 0) return '$day';
        return '';
      });
    }

    final days = _selectedSpendingRange == '15 Days' ? 15 : 7;
    final start = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: days - 1));
    const weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return List<String>.generate(days, (index) {
      final date = start.add(Duration(days: index));
      if (days == 7) return weekdayNames[date.weekday - 1];
      if (index == 0 || index == days - 1 || index % 3 == 0) {
        return '${date.day}/${date.month}';
      }
      return '';
    });
  }

  String get _selectedRangeSubtitle {
    switch (_selectedSpendingRange) {
      case 'Today':
        return 'Today • hourly spending';
      case '15 Days':
        return 'Last 15 days';
      case 'Monthly':
        return 'Current month';
      case 'Weekly':
      default:
        return 'Last 7 days';
    }
  }

  String get _selectedRangeTopCategory {
    final totals = <String, double>{};
    for (final expense in _selectedRangeTransactions) {
      final raw = expense['category']?.toString().trim() ?? '';
      final category = raw.isEmpty ? 'Other' : raw;
      totals[category] = (totals[category] ?? 0) + _expenseAmount(expense);
    }
    if (totals.isEmpty) return '—';
    final entries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.first.key;
  }

  void _selectSpendingRange(String range) {
    if (_selectedSpendingRange == range) return;
    setState(() => _selectedSpendingRange = range);
    _analyticsAnimationController
      ..reset()
      ..forward();
  }

  Widget _spendingRangeButton(String label) {
    final selected = _selectedSpendingRange == label;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Material(
          color: selected
              ? _dashPurple.withValues(alpha: .24)
              : Colors.white.withValues(alpha: .035),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _selectSpendingRange(label),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected
                      ? _dashPurple.withValues(alpha: .80)
                      : Colors.white.withValues(alpha: .06),
                ),
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected ? _dashText : _dashMuted,
                  fontSize: 10.5,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _spendingDetailPill(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .035),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: .055)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(color: _dashMuted, fontSize: 9.5),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _dashText,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _spendingOverviewCard() {
    final values = _selectedSpendingValues;
    final labels = _selectedSpendingLabels;
    final selectedTransactions = _selectedRangeTransactions;
    final selectedTotal = values.fold<double>(0, (a, b) => a + b);
    final activeDays = values.where((value) => value > 0).length;
    final average = activeDays > 0 ? selectedTotal / activeDays : 0.0;

    return AnimatedContainer(
      key: _spendingOverviewKey,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
      padding: _highlightSpendingOverview ? const EdgeInsets.all(2) : EdgeInsets.zero,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: _highlightSpendingOverview
            ? [
                BoxShadow(
                  color: _dashCyan.withValues(alpha: .35),
                  blurRadius: 22,
                  spreadRadius: 2,
                ),
              ]
            : const [],
        border: _highlightSpendingOverview
            ? Border.all(color: _dashCyan.withValues(alpha: .85), width: 1.5)
            : null,
      ),
      child: _premiumCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Spending Overview',
                        style: TextStyle(
                          color: _dashText,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _selectedRangeSubtitle,
                        style: const TextStyle(color: _dashMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₹${selectedTotal.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: _dashCyan,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _spendingRangeButton('Today'),
                _spendingRangeButton('Weekly'),
                _spendingRangeButton('15 Days'),
                _spendingRangeButton('Monthly'),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 150,
              child: loadingExpenses && transactions.isEmpty
                  ? const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2.4),
                      ),
                    )
                  : values.every((v) => v == 0)
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.show_chart_rounded,
                                color: _dashMuted.withValues(alpha: .75),
                                size: 30,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '₹0 spent • $_selectedRangeSubtitle',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: _dashText,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 3),
                              const Text(
                                'No spending recorded in this period.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: _dashMuted, fontSize: 10.5),
                              ),
                            ],
                          ),
                        )
                      : AnimatedBuilder(
                          animation: _analyticsAnimationController,
                          builder: (context, child) {
                            return CustomPaint(
                              painter: _SpendIQLineChartPainter(
                                values,
                                progress: _analyticsAnimationController.value,
                              ),
                              child: const SizedBox.expand(),
                            );
                          },
                        ),
            ),
            const SizedBox(height: 8),
            Row(
              children: List<Widget>.generate(labels.length, (index) {
                final label = labels[index];
                return Expanded(
                  child: Text(
                    label,
                    textAlign: index == 0
                        ? TextAlign.left
                        : index == labels.length - 1
                            ? TextAlign.right
                            : TextAlign.center,
                    maxLines: 1,
                    style: const TextStyle(
                      color: _dashMuted,
                      fontSize: 8.5,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _spendingDetailPill(
                  'Transactions',
                  '${selectedTransactions.length}',
                ),
                const SizedBox(width: 8),
                _spendingDetailPill('Top Category', _selectedRangeTopCategory),
                const SizedBox(width: 8),
                _spendingDetailPill(
                  'Avg Active Day',
                  '₹${average.toStringAsFixed(0)}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _budgetDonutStatus(
    String title,
    double spent,
    double limit,
    double percentage,
    Color accent,
  ) {
    final progress =
        limit > 0 ? (spent / limit).clamp(0.0, 1.0).toDouble() : 0.0;
    final displayPercentage =
        limit > 0 ? percentage.clamp(0.0, 999.0).toDouble() : 0.0;

    final statusColor = limit <= 0
        ? _dashMuted
        : percentage >= 100
            ? const Color(0xFFFF5F78)
            : percentage >= 80
                ? const Color(0xFFFFB84D)
                : accent;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 62,
          height: 62,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size.square(62),
                painter: _BudgetDonutPainter(
                  progress: progress,
                  color: statusColor,
                ),
              ),
              Text(
                limit > 0
                    ? '${displayPercentage.toStringAsFixed(0)}%'
                    : '--',
                style: const TextStyle(
                  color: _dashText,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _dashText,
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            limit > 0
                ? '₹${spent.toStringAsFixed(0)} / ₹${limit.toStringAsFixed(0)}'
                : 'Not set',
            maxLines: 1,
            style: const TextStyle(
              color: _dashMuted,
              fontSize: 9.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _budgetStatusCard() {
    return _premiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.track_changes_rounded,
                color: _dashPurple,
                size: 22,
              ),
              const SizedBox(width: 9),
              const Expanded(
                child: Text(
                  'Budget Status',
                  style: TextStyle(
                    color: _dashText,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(
                onPressed: openSetLimits,
                child: const Text('View Details  →'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _budgetDonutStatus(
                  'Daily',
                  todaySpending,
                  dailyLimit,
                  dailyPercentage,
                  const Color(0xFF43B5FF),
                ),
              ),
              Expanded(
                child: _budgetDonutStatus(
                  'Weekly',
                  thisWeekSpending,
                  weeklyLimit,
                  weeklyPercentage,
                  _dashGreen,
                ),
              ),
              Expanded(
                child: _budgetDonutStatus(
                  '15 Days',
                  lastFifteenDaysSpending,
                  fifteenDayLimit,
                  fifteenDayPercentage,
                  const Color(0xFFFFB84D),
                ),
              ),
              Expanded(
                child: _budgetDonutStatus(
                  'Monthly',
                  currentMonthSpending,
                  monthlyLimit,
                  monthlyPercentage,
                  _dashPurple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _monthlyHeroCard() {
    final limit = monthlyLimit;
    final spent = currentMonthSpending;
    final progress = limit > 0 ? (spent / limit).clamp(0.0, 1.0).toDouble() : 0.0;
    final remaining = limit > 0 ? (limit - spent) : (monthlyIncome - spent);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6E49FF), Color(0xFF4031C8)],
        ),
        boxShadow: [
          BoxShadow(
            color: _dashPurple.withValues(alpha: .28),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Monthly Budget',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  limit > 0 ? '${monthlyPercentage.toStringAsFixed(0)}% used' : 'Limit not set',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            limit > 0
                ? '₹${spent.toStringAsFixed(0)} / ₹${limit.toStringAsFixed(0)}'
                : '₹${spent.toStringAsFixed(0)} spent',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 29,
              fontWeight: FontWeight.w800,
              letterSpacing: -.5,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              backgroundColor: Colors.white.withValues(alpha: .18),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF63E6BE)),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.savings_outlined, color: Colors.white70, size: 17),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  limit > 0
                      ? (remaining >= 0
                          ? '₹${remaining.toStringAsFixed(0)} remaining in monthly limit'
                          : '₹${(-remaining).toStringAsFixed(0)} over monthly limit')
                      : (monthlyIncome > 0
                          ? '₹${remaining.toStringAsFixed(0)} income remaining this month'
                          : 'Set income and monthly limit for smarter guidance'),
                  style: const TextStyle(color: Colors.white70, fontSize: 12.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===================================================
  // DASHBOARD UI - OPTION 10
  // ===================================================

  Widget _compactActionCard({
    required IconData icon,
    required String title,
    required String text,
    required Color accent,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        constraints: const BoxConstraints(minHeight: 116),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _dashCard2,
              accent.withValues(alpha: .13),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accent.withValues(alpha: .24)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: .17),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: accent, size: 23),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: _dashText,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    text,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _dashMuted,
                      fontSize: 11.5,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: accent, size: 23),
          ],
        ),
      ),
    );
  }

  Widget _compactAiCard() {
    final advice = (aiAdvice?['advice'] ?? '').toString().trim();
    return _compactActionCard(
      icon: Icons.smart_toy_rounded,
      title: 'SpendIQ AI Advisor',
      text: advice.isNotEmpty
          ? advice
          : loadingAiAdvice
              ? 'AI is analysing your spending...'
              : 'Get personalised advice from your income and spending.',
      accent: _dashCyan,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SpendIqAiAdvisorScreen(userId: widget.userId),
          ),
        );
      },
    );
  }

  Widget _compactSmartBudgetCard() {
    final data = smartBudget;
    final safeDaily = (data?['safeDailySpend'] as num?)?.toDouble() ?? 0;
    final remaining =
        (data?['safeBudgetRemaining'] as num?)?.toDouble() ?? 0;
    final text = data == null
        ? (loadingSmartBudget
            ? 'Calculating your smart budget...'
            : 'Set income and let SpendIQ build your safe budget.')
        : 'Safe today ₹${safeDaily.toStringAsFixed(0)} • ₹${remaining.toStringAsFixed(0)} budget left';

    return _compactActionCard(
      icon: Icons.savings_rounded,
      title: 'Smart Budget',
      text: text,
      accent: _dashGreen,
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SmartBudgetScreen(userId: widget.userId),
          ),
        );
        if (!mounted) return;
        await loadSmartBudget();
      },
    );
  }

  Widget _compactSmartShoppingCard() {
    return _compactActionCard(
      icon: Icons.shopping_cart_checkout_rounded,
      title: 'Smart Shopping',
      text: 'Compare real products, prices and affordability before you buy.',
      accent: _dashPurple,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PurchaseAdvisorScreen(userId: widget.userId),
          ),
        );
      },
    );
  }

  Widget _compactLiveBudgetCard() {
    return Container(
      constraints: const BoxConstraints(minHeight: 58),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_dashCard2, _dashCyan.withValues(alpha: .08)],
        ),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: _dashCyan.withValues(alpha: .18)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _dashCyan.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.notifications_active_rounded,
              color: _dashCyan,
              size: 19,
            ),
          ),
          const SizedBox(width: 9),
          const Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Live Budget Status',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _dashText,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Real-time budget in notification bar',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _dashMuted,
                    fontSize: 9.5,
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: .82,
            child: Switch(
              value: persistentBudgetStatusEnabled,
              onChanged: _setPersistentBudgetStatus,
              activeThumbColor: _dashPurple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _motivationCard() {
    return Container(
      constraints: const BoxConstraints(minHeight: 58),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _dashGreen.withValues(alpha: .12),
            _dashCard2,
          ],
        ),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: _dashGreen.withValues(alpha: .25)),
      ),
      child: const Row(
        children: [
          Icon(Icons.eco_rounded, color: _dashGreen, size: 21),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              'Discipline today. A better tomorrow.',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _dashText,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: 7),
          Icon(Icons.trending_up_rounded, color: _dashGreen, size: 20),
        ],
      ),
    );
  }

  Widget _bottomNavigation() {
    Widget item(IconData icon, String label, bool selected, VoidCallback tap) {
      final color = selected ? _dashPurple : _dashMuted;
      return Expanded(
        child: InkWell(
          onTap: tap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 9),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 23),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 9.5,
                    fontWeight:
                        selected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF08152B),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: .08)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            item(Icons.home_rounded, 'Home', true, () {}),
            item(
              Icons.receipt_long_rounded,
              'Transactions',
              false,
              () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TransactionsScreen(userId: widget.userId),
                  ),
                );
                await loadExpenses();
              },
            ),
            item(
              Icons.bar_chart_rounded,
              'Analytics',
              false,
              () {
                _focusSpendingOverview();
              },
            ),
            item(
              Icons.smart_toy_rounded,
              'Advisor',
              false,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SpendIqAiAdvisorScreen(userId: widget.userId),
                  ),
                );
              },
            ),
            item(
              Icons.person_outline_rounded,
              'Profile',
              false,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(userId: widget.userId),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }


  double get _plannedMonthlySavings {
    if (monthlyIncome <= 0) return 0;
    final plannedSpend = monthlyLimit > 0 ? monthlyLimit : 0;
    return math.max(0.0, monthlyIncome - plannedSpend);
  }

  double get _plannedSavingsPercent {
    if (monthlyIncome <= 0) return 0;
    return (_plannedMonthlySavings / monthlyIncome * 100).clamp(0.0, 100.0);
  }

  Future<void> _showSavingsPlan() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        Widget planRow(String label, double value, IconData icon, Color color) {
          return Container(
            margin: const EdgeInsets.only(bottom: 9),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            decoration: BoxDecoration(
              color: const Color(0xFF0B1830),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withValues(alpha: .05)),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFFAAB7D0),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '₹${value.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Color(0xFFF7F8FF),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          );
        }

        return SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
            decoration: const BoxDecoration(
              color: Color(0xFF101F3D),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF24D69A).withValues(alpha: .14),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.savings_rounded,
                          color: Color(0xFF24D69A),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Savings Plan',
                              style: TextStyle(
                                color: Color(0xFFF7F8FF),
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Income minus your monthly spending limit',
                              style: TextStyle(
                                color: Color(0xFFAAB7D0),
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  if (monthlyIncome <= 0)
                    const Text(
                      'Set your monthly income first to calculate planned savings.',
                      style: TextStyle(
                        color: Color(0xFFAAB7D0),
                        height: 1.4,
                      ),
                    )
                  else ...[
                    planRow(
                      'Monthly Income',
                      monthlyIncome,
                      Icons.account_balance_wallet_rounded,
                      const Color(0xFF43B5FF),
                    ),
                    planRow(
                      'Monthly Spending Limit',
                      monthlyLimit,
                      Icons.calendar_month_rounded,
                      const Color(0xFF7C4DFF),
                    ),
                    planRow(
                      '15-Day Limit',
                      fifteenDayLimit,
                      Icons.date_range_rounded,
                      const Color(0xFFFFC857),
                    ),
                    planRow(
                      'Weekly Limit',
                      weeklyLimit,
                      Icons.view_week_rounded,
                      const Color(0xFF43B5FF),
                    ),
                    planRow(
                      'Daily Limit',
                      dailyLimit,
                      Icons.today_rounded,
                      const Color(0xFFFF7D8A),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF24D69A).withValues(alpha: .10),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFF24D69A).withValues(alpha: .25),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Reserved for Savings',
                            style: TextStyle(
                              color: Color(0xFFAAB7D0),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '₹${_plannedMonthlySavings.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Color(0xFF24D69A),
                              fontSize: 27,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_plannedSavingsPercent.toStringAsFixed(0)}% of monthly income kept outside the spending budget.',
                            style: const TextStyle(
                              color: Color(0xFFAAB7D0),
                              fontSize: 11.5,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _savingsSection() {
    final hasPlan = monthlyIncome > 0 && monthlyLimit > 0;
    final savings = _plannedMonthlySavings;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: _showSavingsPlan,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: const Color(0xFF24D69A).withValues(alpha: .08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF24D69A).withValues(alpha: .22),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFF24D69A).withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.savings_rounded,
                  color: Color(0xFF24D69A),
                  size: 19,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Savings',
                      style: TextStyle(
                        color: Color(0xFFF7F8FF),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasPlan
                          ? '₹${savings.toStringAsFixed(0)} reserved'
                          : 'Set income + monthly limit',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFAAB7D0),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF71809D),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final darkTheme = ThemeData.dark().copyWith(
      scaffoldBackgroundColor: _dashNavy,
      cardColor: _dashCard,
      colorScheme: const ColorScheme.dark(
        primary: _dashPurple,
        secondary: _dashCyan,
        surface: _dashCard,
      ),
      dividerColor: Colors.white12,
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: _dashCyan),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _dashPurple,
          foregroundColor: Colors.white,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _dashText,
          side: BorderSide(color: Colors.white.withValues(alpha: .16)),
        ),
      ),
    );

    return Theme(
      data: darkTheme,
      child: Scaffold(
        backgroundColor: _dashNavy,
        body: RefreshIndicator(
          onRefresh: refreshDashboard,
          color: _dashPurple,
          child: ListView(
            controller: _dashboardScrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 34),
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_dashPurple, _dashCyan],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 11),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SpendIQ',
                          style: TextStyle(
                            color: _dashText,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -.4,
                          ),
                        ),
                        Text(
                          'Smarter Choices. Brighter Future.',
                          style: TextStyle(color: _dashMuted, fontSize: 10.5),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Refresh dashboard',
                    onPressed: refreshDashboard,
                    icon: const Icon(Icons.refresh_rounded, color: _dashMuted),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              const Text(
                'Hi Ayush! 👋',
                style: TextStyle(
                  color: _dashText,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.5,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Stay in control. Every rupee counts.',
                style: TextStyle(color: _dashMuted, fontSize: 14),
              ),
              const SizedBox(height: 20),

              _monthlyHeroCard(),
              const SizedBox(height: 18),

              Row(
                children: [
                  _quickAction(Icons.add_rounded, 'Add Expense', openAddExpense),
                  const SizedBox(width: 9),
                  _quickAction(Icons.tune_rounded, 'Set Limit', openSetLimits, accent: _dashCyan),
                  const SizedBox(width: 9),
                  _quickAction(
                    Icons.auto_awesome_rounded,
                    'AI Advisor',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SpendIqAiAdvisorScreen(userId: widget.userId),
                        ),
                      );
                    },
                    accent: _dashGreen,
                  ),
                  const SizedBox(width: 9),
                  _quickAction(
                    Icons.compare_arrows_rounded,
                    'Compare',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PurchaseAdvisorScreen(userId: widget.userId),
                        ),
                      );
                    },
                    accent: const Color(0xFFFFC857),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              _spendingOverviewCard(),
              const SizedBox(height: 18),

              _budgetStatusCard(),
              const SizedBox(height: 18),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _compactAiCard()),
                  const SizedBox(width: 10),
                  Expanded(child: _compactSmartBudgetCard()),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 6,
                    child: Column(
                      children: [
                        recentTransactionsSection(),
                        const SizedBox(height: 10),
                        _compactLiveBudgetCard(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 6,
                    child: _compactSmartShoppingCard(),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _motivationCard(),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: openSetLimits,
                      icon: const Icon(Icons.account_balance_wallet_outlined),
                      label: Text(
                        monthlyIncome > 0 ? 'Income ₹${monthlyIncome.toStringAsFixed(0)}' : 'Set Income',
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _savingsSection(),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'User ID: ${widget.userId}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF667693), fontSize: 11),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _bottomNavigation(),
      ),
    );
  }

}



// =====================================================
// PROFILE SCREEN
// =====================================================

class ProfileScreen extends StatefulWidget {
  final int userId;

  const ProfileScreen({
    super.key,
    required this.userId,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const MethodChannel _platform = MethodChannel('spend_iq_test');

  static const Color _navy = Color(0xFF061126);
  static const Color _card = Color(0xFF0D1B33);
  static const Color _card2 = Color(0xFF12223E);
  static const Color _purple = Color(0xFF7C4DFF);
  static const Color _cyan = Color(0xFF29D9D0);
  static const Color _text = Color(0xFFF4F7FC);
  static const Color _muted = Color(0xFFAEBBD3);

  double _monthlyIncome = 0;
  double _monthlyLimit = 0;
  double _monthSpent = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileSummary();
  }

  Future<void> _loadProfileSummary() async {
    if (mounted) setState(() => _loading = true);

    double income = 0;
    double limit = 0;
    double spent = 0;

    try {
      final responses = await Future.wait([
        http.get(Uri.parse('$baseUrl/api/income/${widget.userId}')),
        http.get(Uri.parse('$baseUrl/api/monthly-limit/${widget.userId}/status')),
      ]);

      if (responses[0].statusCode == 200) {
        final data = jsonDecode(responses[0].body);
        income = (data['monthlyIncome'] as num?)?.toDouble() ?? 0;
      }

      if (responses[1].statusCode == 200) {
        final data = jsonDecode(responses[1].body);
        limit = (data['monthlyLimit'] as num?)?.toDouble() ?? 0;
        spent = (data['currentMonthSpending'] as num?)?.toDouble() ?? 0;
      }
    } catch (_) {
      // Profile still opens even if a summary API is temporarily unavailable.
    }

    if (!mounted) return;
    setState(() {
      _monthlyIncome = income;
      _monthlyLimit = limit;
      _monthSpent = spent;
      _loading = false;
    });
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _card,
        title: const Text(
          'Logout from SpendIQ?',
          style: TextStyle(color: _text, fontWeight: FontWeight.w800),
        ),
        content: const Text(
          'Your account and saved data will stay safe. You can login again using your registered email and password.',
          style: TextStyle(color: _muted, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5F78),
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;

    try {
      await _platform.invokeMethod('saveUserId', {'userId': -1});
    } catch (_) {}

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String title,
    required String value,
    Color accent = _cyan,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: _card2,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: .06)),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: .14),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: _text,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: _navy,
        colorScheme: const ColorScheme.dark(
          primary: _purple,
          secondary: _cyan,
          surface: _card,
        ),
      ),
      child: Scaffold(
        backgroundColor: _navy,
        appBar: AppBar(
          backgroundColor: _navy,
          elevation: 0,
          title: const Text(
            'Profile',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _loadProfileSummary,
          color: _purple,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _purple.withValues(alpha: .28),
                      _cyan.withValues(alpha: .10),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withValues(alpha: .08)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 82,
                      height: 82,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _purple.withValues(alpha: .20),
                        border: Border.all(color: _purple, width: 2),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 45,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'SpendIQ User',
                      style: TextStyle(
                        color: _text,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'User ID • ${widget.userId}',
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF20C997).withValues(alpha: .14),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '●  Account Active',
                        style: TextStyle(
                          color: Color(0xFF20C997),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Account Overview',
                style: TextStyle(
                  color: _text,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else ...[
                _infoTile(
                  icon: Icons.account_balance_wallet_rounded,
                  title: 'Monthly Income',
                  value: _monthlyIncome > 0
                      ? '₹${_monthlyIncome.toStringAsFixed(0)}'
                      : 'Not set',
                  accent: _cyan,
                ),
                _infoTile(
                  icon: Icons.track_changes_rounded,
                  title: 'Monthly Limit',
                  value: _monthlyLimit > 0
                      ? '₹${_monthlyLimit.toStringAsFixed(0)}'
                      : 'Not set',
                  accent: _purple,
                ),
                _infoTile(
                  icon: Icons.payments_rounded,
                  title: 'Spent This Month',
                  value: '₹${_monthSpent.toStringAsFixed(0)}',
                  accent: const Color(0xFFFFB84D),
                ),
              ],
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: .06)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lock_rounded, color: _cyan, size: 21),
                    SizedBox(width: 11),
                    Expanded(
                      child: Text(
                        'Your SpendIQ account remains registered after logout. Login again with the same registered email and password.',
                        style: TextStyle(
                          color: _muted,
                          fontSize: 12,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5F78).withValues(alpha: .16),
                    foregroundColor: const Color(0xFFFF7D8A),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                      side: BorderSide(
                        color: const Color(0xFFFF5F78).withValues(alpha: .35),
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'SpendIQ • Smarter Choices. Brighter Future.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF71809D), fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// =====================================================
// SMART BUDGET FULL SCREEN
// =====================================================

class SmartBudgetScreen extends StatefulWidget {
  final int userId;

  const SmartBudgetScreen({
    super.key,
    required this.userId,
  });

  @override
  State<SmartBudgetScreen> createState() => _SmartBudgetScreenState();
}

class _SmartBudgetScreenState extends State<SmartBudgetScreen> {
  Map<String, dynamic>? data;
  bool loading = true;
  String? error;

  static const Color navy = Color(0xFF061126);
  static const Color purple = Color(0xFF7C4DFF);
  static const Color cyan = Color(0xFF29D9D0);

  @override
  void initState() {
    super.initState();
    loadBudget();
  }

  Future<void> loadBudget() async {
    if (mounted) {
      setState(() {
        loading = true;
        error = null;
      });
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/smart-budget/${widget.userId}'),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (mounted) {
          setState(() => data = Map<String, dynamic>.from(decoded));
        }
      } else {
        String message = 'Could not load Smart Budget.';
        try {
          final decoded = jsonDecode(response.body);
          message = (decoded['message'] ?? message).toString();
        } catch (_) {}
        if (mounted) setState(() => error = message);
      }
    } catch (e) {
      if (mounted) setState(() => error = 'Connection error: $e');
    }

    if (mounted) setState(() => loading = false);
  }

  double money(dynamic value) => (value as num?)?.toDouble() ?? 0;

  Color categoryColor(String status, double percentage) {
    if (status == 'OVER_BUDGET' || percentage >= 100) return Colors.red;
    if (status == 'WARNING' || percentage >= 80) return Colors.orange;
    return const Color(0xFF20C997);
  }

  IconData categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant_rounded;
      case 'bills':
        return Icons.receipt_long_rounded;
      case 'travel':
        return Icons.directions_car_filled_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'entertainment':
        return Icons.movie_rounded;
      default:
        return Icons.account_balance_wallet_rounded;
    }
  }

  Widget metric(String label, double value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: .08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: cyan, size: 20),
            const SizedBox(height: 9),
            Text(
              label,
              style: const TextStyle(color: Color(0xFFAEBBD3), fontSize: 11),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                '₹${value.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget categoryCard(Map<String, dynamic> item) {
    final category = (item['category'] ?? 'Other').toString();
    final recommended = money(item['recommendedBudget']);
    final spent = money(item['spent']);
    final remaining = money(item['remaining']);
    final percentage = money(item['percentage']);
    final status = (item['status'] ?? 'ON_TRACK').toString();
    final color = categoryColor(status, percentage);
    final progress = (percentage / 100).clamp(0.0, 1.0).toDouble();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(categoryIcon(category), color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      status == 'OVER_BUDGET'
                          ? 'Budget exceeded'
                          : status == 'WARNING'
                              ? 'Close to category limit'
                              : 'On track',
                      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Text(
                '₹${recommended.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              color: color,
              backgroundColor: const Color(0xFFE9EDF5),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Spent ₹${spent.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF667085)),
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}% used',
                style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 12),
              Text(
                'Left ₹${remaining.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF667085)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final budget = data;
    final monthlyLimit = money(budget?['monthlyLimit'] ?? budget?['safeMonthlyBudget']);
    final spent = money(budget?['spentThisMonth']);
    final remaining = money(budget?['remainingBudget'] ?? budget?['safeBudgetRemaining']);
    final daily = money(budget?['safeDailySpend']);
    final percentage = money(budget?['spendingPercentage']);
    final days = (budget?['daysRemaining'] as num?)?.toInt() ?? 0;
    final rawCategories = budget?['categories'];
    final categories = rawCategories is List
        ? rawCategories.map((e) => Map<String, dynamic>.from(e as Map)).toList()
        : <Map<String, dynamic>>[];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Smart Budget', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            onPressed: loading ? null : loadBudget,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadBudget,
        child: loading && budget == null
            ? ListView(
                physics: AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: 220),
                  Center(child: CircularProgressIndicator()),
                ],
              )
            : error != null && budget == null
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    children: [
                      const SizedBox(height: 120),
                      const Icon(Icons.account_balance_wallet_outlined, size: 58, color: purple),
                      const SizedBox(height: 18),
                      Text(
                        error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Set your Monthly Limit first. SpendIQ will then divide it into smart category budgets.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, height: 1.4),
                      ),
                    ],
                  )
                : ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF111D3B), Color(0xFF312E81)],
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'MONTHLY SMART PLAN',
                              style: TextStyle(
                                color: Color(0xFFAEBBD3),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '₹${monthlyLimit.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'SpendIQ has divided your monthly limit across ${categories.length} categories.',
                              style: const TextStyle(color: Color(0xFFC8D2E8), height: 1.35),
                            ),
                            const SizedBox(height: 18),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: (percentage / 100).clamp(0.0, 1.0).toDouble(),
                                minHeight: 9,
                                color: cyan,
                                backgroundColor: Colors.white.withValues(alpha: .12),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${percentage.toStringAsFixed(1)}% of monthly budget used • $days days remaining',
                              style: const TextStyle(color: Color(0xFFAEBBD3), fontSize: 12),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                metric('Spent', spent, Icons.payments_rounded),
                                const SizedBox(width: 8),
                                metric('Remaining', remaining, Icons.savings_rounded),
                                const SizedBox(width: 8),
                                metric('Safe / Day', daily, Icons.today_rounded),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'Category Plan',
                        style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Recommended amount, current spending and money left in each category.',
                        style: TextStyle(color: Color(0xFF667085), height: 1.35),
                      ),
                      const SizedBox(height: 14),
                      if (categories.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(child: Text('No category budget available yet.')),
                        )
                      else
                        ...categories.map(categoryCard),
                    ],
                  ),
      ),
    );
  }
}

// =====================================================
// FULL TRANSACTIONS SCREEN
// =====================================================

class TransactionsScreen extends StatefulWidget {
  final int userId;

  const TransactionsScreen({
    super.key,
    required this.userId,
  });

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  static const Color _navy = Color(0xFF071226);
  static const Color _card = Color(0xFF101F3D);
  static const Color _card2 = Color(0xFF142445);
  static const Color _purple = Color(0xFF7C4DFF);
  static const Color _cyan = Color(0xFF43B5FF);
  static const Color _green = Color(0xFF24D69A);
  static const Color _text = Color(0xFFF7F8FF);
  static const Color _muted = Color(0xFFAAB7D0);

  List<Map<String, dynamic>> _transactions = [];
  bool _loading = true;
  String? _error;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final response = await http.get(Uri.parse('$baseUrl/api/expenses'));

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! List) {
        throw Exception('Unexpected transaction response');
      }

      final items = decoded
          .where((item) =>
              item is Map &&
              (item['userId'] as num?)?.toInt() == widget.userId)
          .map<Map<String, dynamic>>(
              (item) => Map<String, dynamic>.from(item as Map))
          .toList();

      items.sort((a, b) {
        final ad = DateTime.tryParse(a['dateTime']?.toString() ?? '');
        final bd = DateTime.tryParse(b['dateTime']?.toString() ?? '');
        if (ad == null && bd == null) return 0;
        if (ad == null) return 1;
        if (bd == null) return -1;
        return bd.compareTo(ad);
      });

      if (mounted) {
        setState(() => _transactions = items);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  List<Map<String, dynamic>> get _visibleTransactions {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _transactions;

    return _transactions.where((expense) {
      final searchable = [
        expense['merchant'],
        expense['description'],
        expense['category'],
        expense['reason'],
        expense['paymentMode'],
        expense['mode'],
        expense['source'],
        expense['transactionRef'],
      ].where((v) => v != null).join(' ').toLowerCase();

      return searchable.contains(q) ||
          ((expense['amount'] as num?)?.toString() ?? '').contains(q);
    }).toList();
  }

  double get _totalSpent => _transactions.fold<double>(
        0,
        (sum, item) => sum + ((item['amount'] as num?)?.toDouble() ?? 0),
      );

  double get _monthSpent {
    final now = DateTime.now();
    return _transactions.fold<double>(0, (sum, item) {
      final date = DateTime.tryParse(item['dateTime']?.toString() ?? '');
      if (date != null && date.year == now.year && date.month == now.month) {
        return sum + ((item['amount'] as num?)?.toDouble() ?? 0);
      }
      return sum;
    });
  }

  String _title(Map<String, dynamic> expense) {
    final merchant = expense['merchant']?.toString().trim() ?? '';
    final description = expense['description']?.toString().trim() ?? '';
    final reason = expense['reason']?.toString().trim() ?? '';
    if (merchant.isNotEmpty) return merchant;
    if (description.isNotEmpty) return description;
    if (reason.isNotEmpty) return reason;
    return 'Expense';
  }

  String _date(dynamic value) {
    if (value == null) return 'Date unavailable';
    final date = DateTime.tryParse(value.toString());
    if (date == null) return value.toString();

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final h = date.hour == 0 ? 12 : (date.hour > 12 ? date.hour - 12 : date.hour);
    final m = date.minute.toString().padLeft(2, '0');
    final p = date.hour >= 12 ? 'PM' : 'AM';
    return '${date.day} ${months[date.month - 1]} ${date.year} • $h:$m $p';
  }

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant_rounded;
      case 'travel':
        return Icons.directions_car_filled_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'bills':
        return Icons.receipt_rounded;
      case 'entertainment':
        return Icons.movie_rounded;
      case 'health':
        return Icons.health_and_safety_rounded;
      case 'education':
        return Icons.school_rounded;
      default:
        return Icons.payments_rounded;
    }
  }

  Widget _summaryBox(String label, String value, IconData icon, Color accent) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: .06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: accent, size: 21),
            const SizedBox(height: 10),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _text,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                color: _muted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _transactionTile(Map<String, dynamic> expense) {
    final amount = (expense['amount'] as num?)?.toDouble() ?? 0;
    final category = (expense['category']?.toString().trim().isNotEmpty ?? false)
        ? expense['category'].toString().trim()
        : 'Other';
    final reason = expense['reason']?.toString().trim() ?? '';
    final source = expense['source']?.toString().trim() ?? '';
    final mode = (expense['paymentMode'] ?? expense['mode'])
            ?.toString()
            .trim() ??
        '';
    final ref = expense['transactionRef']?.toString().trim() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: .06)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () async {
          final updated = await Navigator.push<Map<String, dynamic>>(
            context,
            MaterialPageRoute(
              builder: (_) => TransactionDetailsScreen(
                expense: Map<String, dynamic>.from(expense),
              ),
            ),
          );

          if (updated != null && mounted) {
            final id = updated['id'];
            setState(() {
              final index = _transactions.indexWhere((item) => item['id'] == id);
              if (index != -1) {
                _transactions[index] = updated;
              }
            });
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _purple.withValues(alpha: .15),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(_categoryIcon(category), color: _purple, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        _title(expense),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _text,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '-₹${amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Color(0xFFFF7D8A),
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  _date(expense['dateTime']),
                  style: const TextStyle(color: _muted, fontSize: 11.5),
                ),
                const SizedBox(height: 9),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _chip(category, _cyan),
                    if (mode.isNotEmpty) _chip(mode, _green),
                    if (source.isNotEmpty) _chip(source, _purple),
                  ],
                ),
                if (reason.isNotEmpty) ...[
                  const SizedBox(height: 9),
                  Text(
                    'Reason: $reason',
                    style: const TextStyle(
                      color: Color(0xFFD6DEEE),
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
                if (ref.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    'Ref: $ref',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Color(0xFF71809D), fontSize: 10.5),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 6),
          const Padding(
            padding: EdgeInsets.only(top: 16),
            child: Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF71809D),
              size: 22,
            ),
          ),
        ],
      ),
        ),
      ),
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: .22)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleTransactions;

    return Scaffold(
      backgroundColor: _navy,
      appBar: AppBar(
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Transactions',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading ? null : _loadTransactions,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadTransactions,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            const Text(
              'Your complete spending history',
              style: TextStyle(color: _muted, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _summaryBox(
                  'Total Transactions',
                  '${_transactions.length}',
                  Icons.receipt_long_rounded,
                  _purple,
                ),
                const SizedBox(width: 10),
                _summaryBox(
                  'This Month',
                  '₹${_monthSpent.toStringAsFixed(0)}',
                  Icons.calendar_month_rounded,
                  _cyan,
                ),
                const SizedBox(width: 10),
                _summaryBox(
                  'All Time',
                  '₹${_totalSpent.toStringAsFixed(0)}',
                  Icons.account_balance_wallet_rounded,
                  _green,
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: (value) => setState(() => _query = value),
              style: const TextStyle(color: _text),
              decoration: InputDecoration(
                hintText: 'Search merchant, category, amount...',
                hintStyle: const TextStyle(color: Color(0xFF71809D)),
                prefixIcon: const Icon(Icons.search_rounded, color: _muted),
                filled: true,
                fillColor: _card2,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 18),
            if (_loading && _transactions.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null && _transactions.isEmpty)
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.cloud_off_rounded, color: Color(0xFFFF7D8A), size: 38),
                    const SizedBox(height: 10),
                    const Text(
                      'Could not load transactions',
                      style: TextStyle(color: _text, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: _muted, fontSize: 11),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _loadTransactions,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              )
            else if (visible.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 70),
                child: Column(
                  children: [
                    Icon(Icons.receipt_long_outlined, color: _muted, size: 50),
                    SizedBox(height: 12),
                    Text(
                      'No transactions found',
                      style: TextStyle(color: _text, fontWeight: FontWeight.w800),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Your expenses will appear here automatically.',
                      style: TextStyle(color: _muted, fontSize: 12),
                    ),
                  ],
                ),
              )
            else ...[
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Latest first',
                      style: TextStyle(
                        color: _text,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    '${visible.length} records',
                    style: const TextStyle(color: _muted, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...visible.map(_transactionTile),
            ],
          ],
        ),
      ),
    );
  }
}

class TransactionDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> expense;

  const TransactionDetailsScreen({
    super.key,
    required this.expense,
  });

  @override
  State<TransactionDetailsScreen> createState() =>
      _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState extends State<TransactionDetailsScreen> {
  static const Color _navy = Color(0xFF071226);
  static const Color _card = Color(0xFF101F3D);
  static const Color _card2 = Color(0xFF142445);
  static const Color _purple = Color(0xFF7C4DFF);
  static const Color _cyan = Color(0xFF43B5FF);
  static const Color _green = Color(0xFF24D69A);
  static const Color _text = Color(0xFFF7F8FF);
  static const Color _muted = Color(0xFFAAB7D0);

  late Map<String, dynamic> _expense;
  bool _savingNote = false;

  @override
  void initState() {
    super.initState();
    _expense = Map<String, dynamic>.from(widget.expense);
  }

  String _value(dynamic value, {String fallback = 'Not available'}) {
    final result = value?.toString().trim() ?? '';
    return result.isEmpty ? fallback : result;
  }

  String _title() {
    final merchant = _value(_expense['merchant'], fallback: '');
    final description = _value(_expense['description'], fallback: '');
    if (merchant.isNotEmpty) return merchant;
    if (description.isNotEmpty) return description;
    return 'Expense';
  }

  String _date(dynamic value) {
    if (value == null) return 'Date unavailable';
    final date = DateTime.tryParse(value.toString());
    if (date == null) return value.toString();

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour =
        date.hour == 0 ? 12 : (date.hour > 12 ? date.hour - 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '${date.day} ${months[date.month - 1]} ${date.year}, '
        '$hour:$minute $period';
  }

  Future<void> _openNotePad() async {
    final controller = TextEditingController(
      text: _expense['reason']?.toString() ?? '',
    );

    final note = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
            decoration: const BoxDecoration(
              color: _card2,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _purple.withValues(alpha: .16),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: const Icon(
                          Icons.edit_note_rounded,
                          color: _purple,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Transaction Note',
                              style: TextStyle(
                                color: _text,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Write why or to whom you made this payment.',
                              style: TextStyle(
                                color: _muted,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    minLines: 5,
                    maxLines: 8,
                    maxLength: 500,
                    style: const TextStyle(
                      color: _text,
                      fontSize: 14,
                      height: 1.4,
                    ),
                    decoration: InputDecoration(
                      hintText:
                          'Example: Auto fare from station to college...',
                      hintStyle: const TextStyle(color: Color(0xFF71809D)),
                      filled: true,
                      fillColor: _navy,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: _purple,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () =>
                          Navigator.pop(sheetContext, controller.text.trim()),
                      icon: const Icon(Icons.save_rounded),
                      label: const Text(
                        'Save Note',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    // Do not dispose this local controller immediately after the bottom sheet
    // closes. Flutter may still use the TextField during the sheet's reverse
    // animation. It becomes unreachable with the dismissed sheet and can be
    // collected safely afterwards.
    if (note == null) return;
    await _saveNote(note);
  }

  Future<void> _saveNote(String note) async {
    final id = _expense['id'];
    if (id == null || _savingNote) return;

    setState(() => _savingNote = true);

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/expenses/$id/details'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'reason': note}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() => _expense['reason'] = note);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(note.isEmpty ? 'Note removed' : 'Note saved'),
            duration: const Duration(seconds: 1),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Note save failed: ${response.body}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save note: $e')),
      );
    } finally {
      if (mounted) setState(() => _savingNote = false);
    }
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: .22)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _purple.withValues(alpha: .11),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: _purple, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                SelectableText(
                  value,
                  style: const TextStyle(
                    color: _text,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final amount = (_expense['amount'] as num?)?.toDouble() ?? 0;
    final category = _value(_expense['category'], fallback: 'Other');
    final mode = _value(
      _expense['paymentMode'] ?? _expense['mode'],
      fallback: 'Unknown mode',
    );
    final source = _value(_expense['source'], fallback: 'MANUAL');
    final reason = _value(_expense['reason'], fallback: '');
    final description = _value(_expense['description']);
    final merchant = _value(_expense['merchant']);
    final reference = _value(_expense['transactionRef']);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
      },
      child: Scaffold(
        backgroundColor: _navy,
        appBar: AppBar(
          backgroundColor: _navy,
          foregroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Transaction Details',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.pop(context, _expense),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _purple.withValues(alpha: .22),
                    _card,
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _purple.withValues(alpha: .22)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: _purple.withValues(alpha: .18),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.payments_rounded,
                      color: _purple,
                      size: 29,
                    ),
                  ),
                  const SizedBox(height: 13),
                  Text(
                    _title(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _text,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    '-₹${amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Color(0xFFFF7D8A),
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _date(_expense['dateTime']),
                    style: const TextStyle(color: _muted, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white.withValues(alpha: .06)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Payment Info',
                    style: TextStyle(
                      color: _text,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _chip(category, _cyan),
                      _chip(mode, _green),
                      _chip(source.toUpperCase(), _purple),
                      Material(
                        color: _purple,
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: _savingNote ? null : _openNotePad,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _savingNote
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.add_rounded,
                                        color: Colors.white,
                                        size: 17,
                                      ),
                                const SizedBox(width: 4),
                                Text(
                                  reason.isEmpty ? 'Add Note' : 'Edit Note',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (reason.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _navy,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _purple.withValues(alpha: .20),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.sticky_note_2_rounded,
                            color: _purple,
                            size: 19,
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Your Note',
                                  style: TextStyle(
                                    color: _muted,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  reason,
                                  style: const TextStyle(
                                    color: _text,
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white.withValues(alpha: .06)),
              ),
              child: Column(
                children: [
                  _detailRow(Icons.storefront_rounded, 'Merchant / Payee', merchant),
                  const Divider(color: Color(0xFF203153), height: 1),
                  _detailRow(Icons.description_rounded, 'Description', description),
                  const Divider(color: Color(0xFF203153), height: 1),
                  _detailRow(Icons.tag_rounded, 'Transaction Reference', reference),
                  const Divider(color: Color(0xFF203153), height: 1),
                  _detailRow(Icons.schedule_rounded, 'Date & Time',
                      _date(_expense['dateTime'])),
                  const Divider(color: Color(0xFF203153), height: 1),
                  _detailRow(Icons.category_rounded, 'Category', category),
                  const Divider(color: Color(0xFF203153), height: 1),
                  _detailRow(Icons.account_balance_wallet_rounded, 'Payment Mode', mode),
                  const Divider(color: Color(0xFF203153), height: 1),
                  _detailRow(Icons.auto_awesome_rounded, 'Source', source.toUpperCase()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// =====================================================
// SPENDIQ 7-DAY LINE CHART
// =====================================================

class _SpendIQLineChartPainter extends CustomPainter {
  final List<double> values;
  final double progress;

  _SpendIQLineChartPainter(this.values, {this.progress = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final maxValue = values.reduce((a, b) => a > b ? a : b);
    if (maxValue <= 0) return;

    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: .06)
      ..strokeWidth = 1;

    for (int i = 1; i <= 3; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final linePaint = Paint()
      ..color = const Color(0xFF7C4DFF)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x557C4DFF), Color(0x007C4DFF)],
      ).createShader(Offset.zero & size);

    final pointPaint = Paint()
      ..color = const Color(0xFF43B5FF)
      ..style = PaintingStyle.fill;

    final points = <Offset>[];
    for (int i = 0; i < values.length; i++) {
      final x = values.length == 1
          ? size.width / 2
          : size.width * i / (values.length - 1);
      final normalized = values[i] / maxValue;
      final y = size.height - (normalized * (size.height - 14)) - 7;
      points.add(Offset(x, y));
    }

    final fullPath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      fullPath.lineTo(points[i].dx, points[i].dy);
    }

    final metrics = fullPath.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final metric = metrics.first;
    final reveal = progress.clamp(0.0, 1.0).toDouble();
    final revealedPath = metric.extractPath(0, metric.length * reveal);

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width * reveal, size.height));

    final fillPath = Path()
      ..moveTo(points.first.dx, size.height)
      ..lineTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      fillPath.lineTo(points[i].dx, points[i].dy);
    }
    fillPath
      ..lineTo(points.last.dx, size.height)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(revealedPath, linePaint);

    final visibleX = size.width * reveal + 2;
    for (final point in points) {
      if (point.dx <= visibleX) {
        canvas.drawCircle(point, 4, pointPaint);
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SpendIQLineChartPainter oldDelegate) {
    if (oldDelegate.progress != progress) return true;
    if (oldDelegate.values.length != values.length) return true;
    for (int i = 0; i < values.length; i++) {
      if (oldDelegate.values[i] != values[i]) return true;
    }
    return false;
  }
}


// =====================================================
// SPENDIQ AI ADVISOR SCREEN
// =====================================================

class SpendIqAiAdvisorScreen extends StatefulWidget {
  final int userId;

  const SpendIqAiAdvisorScreen({
    super.key,
    required this.userId,
  });

  @override
  State<SpendIqAiAdvisorScreen> createState() => _SpendIqAiAdvisorScreenState();
}

class _SpendIqAiAdvisorScreenState extends State<SpendIqAiAdvisorScreen> {
  static const Color _dashNavy = Color(0xFF071226);
  static const Color _dashCard = Color(0xFF101F3D);
  static const Color _dashCard2 = Color(0xFF142445);
  static const Color _dashPurple = Color(0xFF7C4DFF);
  static const Color _dashCyan = Color(0xFF43B5FF);
  static const Color _dashGreen = Color(0xFF24D69A);
  static const Color _dashText = Color(0xFFF7F8FF);
  static const Color _dashMuted = Color(0xFFAAB7D0);

  bool loading = true;
  String? error;
  Map<String, dynamic>? data;

  @override
  void initState() {
    super.initState();
    _loadAdvice();
  }

  double _number(dynamic value) => value is num
      ? value.toDouble()
      : double.tryParse(value?.toString() ?? '') ?? 0;

  Future<void> _loadAdvice() async {
    if (mounted) {
      setState(() {
        loading = true;
        error = null;
      });
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/ai-advisor/budget/${widget.userId}'),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            data = Map<String, dynamic>.from(decoded);
          });
        }
      } else {
        String message = 'AI Advisor is unavailable right now.';
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map && decoded['message'] != null) {
            message = decoded['message'].toString();
          }
        } catch (_) {}
        if (mounted) setState(() => error = message);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          error = 'Could not connect to SpendIQ AI Advisor.';
        });
      }
    }

    if (mounted) setState(() => loading = false);
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'LIMIT_EXCEEDED':
      case 'CRITICAL':
        return Colors.redAccent;
      case 'CAUTION':
        return Colors.orangeAccent;
      default:
        return _dashGreen;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'LIMIT_EXCEEDED':
        return 'Limit Exceeded';
      case 'CRITICAL':
        return 'Critical';
      case 'CAUTION':
        return 'Caution';
      case 'ON_TRACK':
        return 'On Track';
      default:
        return 'Budget Coach';
    }
  }

  Widget _metric(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
        decoration: BoxDecoration(
          color: _dashCard2,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withValues(alpha: .07)),
        ),
        child: Column(
          children: [
            Icon(icon, color: _dashCyan, size: 20),
            const SizedBox(height: 7),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _dashText,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _dashMuted, fontSize: 9.5),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = data;
    final status = (d?['status'] ?? '').toString();
    final statusColor = _statusColor(status);
    final advice = (d?['advice'] ?? '').toString().trim();
    final monthlyLimit = _number(d?['monthlyLimit']);
    final spent = _number(d?['spentThisMonth']);
    final remaining = _number(d?['remainingBudget']);
    final safeDaily = _number(d?['safeDailySpend']);
    final percentage = _number(d?['spendingPercentage']).clamp(0, 100).toDouble();

    return Scaffold(
      backgroundColor: _dashNavy,
      appBar: AppBar(
        backgroundColor: _dashNavy,
        elevation: 0,
        title: const Text(
          'SpendIQ AI Advisor',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh advice',
            onPressed: loading ? null : _loadAdvice,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAdvice,
        child: loading && d == null
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 240),
                  Center(child: CircularProgressIndicator()),
                ],
              )
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                children: [
                  if (error != null && d == null)
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: _dashCard,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.redAccent.withValues(alpha: .30),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.cloud_off_rounded,
                            color: Colors.redAccent,
                            size: 36,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: _dashText),
                          ),
                          const SizedBox(height: 14),
                          FilledButton.icon(
                            onPressed: _loadAdvice,
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Try Again'),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _dashPurple.withValues(alpha: .22),
                            _dashCard2,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _dashPurple.withValues(alpha: .28),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: _dashCyan.withValues(alpha: .12),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(
                              Icons.auto_awesome_rounded,
                              color: _dashCyan,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Your AI Budget Coach',
                                  style: TextStyle(
                                    color: _dashText,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Advice based on your monthly limit and current spending.',
                                  style: TextStyle(
                                    color: _dashMuted.withValues(alpha: .95),
                                    fontSize: 10.5,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: .13),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _statusLabel(status),
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _metric(
                          'Monthly Limit',
                          '₹${monthlyLimit.toStringAsFixed(0)}',
                          Icons.account_balance_wallet_outlined,
                        ),
                        const SizedBox(width: 9),
                        _metric(
                          'Spent',
                          '₹${spent.toStringAsFixed(0)}',
                          Icons.payments_outlined,
                        ),
                        const SizedBox(width: 9),
                        _metric(
                          'Remaining',
                          '₹${remaining.toStringAsFixed(0)}',
                          Icons.savings_outlined,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _dashCard,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: .07),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Monthly Spending',
                                  style: TextStyle(
                                    color: _dashText,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              Text(
                                '${percentage.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 11),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: LinearProgressIndicator(
                              value: percentage / 100,
                              minHeight: 8,
                              backgroundColor:
                                  Colors.white.withValues(alpha: .07),
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(statusColor),
                            ),
                          ),
                          const SizedBox(height: 11),
                          Text(
                            'Safe to spend today: ₹${safeDaily.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: _dashMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _dashCyan.withValues(alpha: .10),
                            _dashCard2,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _dashCyan.withValues(alpha: .20),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.smart_toy_rounded,
                                color: _dashCyan,
                                size: 22,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'SpendIQ Advice',
                                style: TextStyle(
                                  color: _dashText,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 13),
                          Text(
                            advice.isEmpty
                                ? 'No advice available yet. Pull down or tap refresh to try again.'
                                : advice,
                            style: const TextStyle(
                              color: _dashText,
                              fontSize: 13,
                              height: 1.55,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (error != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.orangeAccent,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ],
                ],
              ),
      ),
    );
  }
}

// =====================================================
// PURCHASE ADVISOR SCREEN
// =====================================================

class PurchaseAdvisorScreen extends StatefulWidget {
  final int userId;

  const PurchaseAdvisorScreen({
    super.key,
    required this.userId,
  });

  @override
  State<PurchaseAdvisorScreen> createState() => _PurchaseAdvisorScreenState();
}

class _PurchaseAdvisorScreenState extends State<PurchaseAdvisorScreen> {
  final searchController = TextEditingController();
  final productController = TextEditingController();
  final priceController = TextEditingController();

  bool searchingProducts = false;
  bool comparingProducts = false;
  bool loading = false;

  List<Map<String, dynamic>> products = [];
  final List<Map<String, dynamic>> comparisonSelection = [];
  List<Map<String, dynamic>> comparisonResults = [];

  Map<String, dynamic>? selectedProduct;
  Map<String, dynamic>? result;
  Map<String, dynamic>? comparisonSummary;
  String? searchMessage;
  String? comparisonMessage;

  @override
  void dispose() {
    searchController.dispose();
    productController.dispose();
    priceController.dispose();
    super.dispose();
  }

  double productPrice(Map<String, dynamic> product) {
    final value = product['price'];
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  double comparisonScore(Map<String, dynamic> product) {
    final value = product['valueScore'];
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  bool sameProduct(Map<String, dynamic> a, Map<String, dynamic> b) {
    final aName = (a['name'] ?? '').toString();
    final bName = (b['name'] ?? '').toString();
    final aStore = (a['store'] ?? '').toString();
    final bStore = (b['store'] ?? '').toString();
    final aPrice = productPrice(a);
    final bPrice = productPrice(b);
    return aName == bName && aStore == bStore && aPrice == bPrice;
  }

  bool isInComparison(Map<String, dynamic> product) {
    return comparisonSelection.any((item) => sameProduct(item, product));
  }

  Future<void> searchProducts() async {
    final query = searchController.text.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter what you want to search for.')),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      searchingProducts = true;
      products = [];
      comparisonSelection.clear();
      comparisonResults = [];
      comparisonSummary = null;
      comparisonMessage = null;
      selectedProduct = null;
      searchMessage = null;
      result = null;
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/product-comparison/search'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'query': query}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = Map<String, dynamic>.from(jsonDecode(response.body));
        final rawProducts = (data['products'] as List?) ?? [];
        final found = rawProducts
            .map((item) => Map<String, dynamic>.from(item as Map))
            .where((item) => productPrice(item) > 0)
            .toList();

        setState(() {
          products = found;
          searchMessage = found.isEmpty
              ? 'No usable products found. You can still enter a product manually below.'
              : '${found.length} options found. Select a product or add 2-4 options to comparison.';
        });
      } else {
        String message = 'Unable to search products.';
        try {
          final data = jsonDecode(response.body);
          message = (data['message'] ?? message).toString();
        } catch (_) {}
        setState(() => searchMessage = message);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => searchMessage = 'Product search error: $e');
    } finally {
      if (mounted) setState(() => searchingProducts = false);
    }
  }

  void selectProduct(Map<String, dynamic> product) {
    final price = productPrice(product);
    setState(() {
      selectedProduct = product;
      productController.text = (product['name'] ?? '').toString();
      priceController.text = price.toStringAsFixed(price % 1 == 0 ? 0 : 2);
      result = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Selected ${(product['name'] ?? 'product')} from ${(product['store'] ?? 'store')}',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void toggleComparison(Map<String, dynamic> product) {
    setState(() {
      final index =
          comparisonSelection.indexWhere((item) => sameProduct(item, product));

      if (index >= 0) {
        comparisonSelection.removeAt(index);
      } else {
        if (comparisonSelection.length >= 4) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Compare up to 4 products at a time.'),
            ),
          );
          return;
        }
        comparisonSelection.add(product);
      }

      comparisonResults = [];
      comparisonSummary = null;
      comparisonMessage = null;
    });
  }

  Future<void> compareSelectedProducts() async {
    if (comparisonSelection.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least 2 products to compare.')),
      );
      return;
    }

    setState(() {
      comparingProducts = true;
      comparisonResults = [];
      comparisonSummary = null;
      comparisonMessage = null;
    });

    try {
      final payload = comparisonSelection
          .map(
            (product) => {
              'name': (product['name'] ?? 'Product').toString(),
              'price': productPrice(product),
              'store': (product['store'] ?? 'Online Store').toString(),
              'productUrl': (product['productUrl'] ?? '').toString(),
              'specifications': <String, dynamic>{
                if ((product['rating'] ?? '').toString().isNotEmpty)
                  'rating': (product['rating'] ?? '').toString(),
                if ((product['delivery'] ?? '').toString().isNotEmpty)
                  'delivery': (product['delivery'] ?? '').toString(),
              },
            },
          )
          .toList();

      final response = await http.post(
        Uri.parse('$baseUrl/api/product-comparison/compare'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'products': payload}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = Map<String, dynamic>.from(jsonDecode(response.body));
        final rawComparison = (data['comparison'] as List?) ?? [];
        final compared = rawComparison
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();

        setState(() {
          comparisonSummary = data;
          comparisonResults = compared;
          comparisonMessage = compared.isEmpty
              ? 'Comparison returned no usable results.'
              : 'Compared ${compared.length} products using price-based value scoring.';
        });
      } else {
        String message = 'Unable to compare products.';
        try {
          final data = jsonDecode(response.body);
          message = (data['message'] ?? message).toString();
        } catch (_) {}
        setState(() => comparisonMessage = message);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => comparisonMessage = 'Product comparison error: $e');
    } finally {
      if (mounted) setState(() => comparingProducts = false);
    }
  }

  void chooseComparedProduct(Map<String, dynamic> compared) {
    final name = (compared['name'] ?? 'Product').toString();
    final store = (compared['store'] ?? 'Online Store').toString();
    final price = productPrice(compared);

    Map<String, dynamic> product = compared;
    for (final original in products) {
      if ((original['name'] ?? '').toString() == name &&
          (original['store'] ?? '').toString() == store &&
          productPrice(original) == price) {
        product = original;
        break;
      }
    }

    selectProduct(product);
  }

  Future<void> analysePurchase() async {
    final productName = productController.text.trim();
    final price = double.tryParse(priceController.text.trim());

    if (productName.isEmpty || price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Select a product or enter a product name and valid price.'),
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      loading = true;
      result = null;
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/purchase-advisor/check'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': widget.userId,
          'productName': productName,
          'price': price,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          result = Map<String, dynamic>.from(jsonDecode(response.body));
        });
      } else {
        String message = 'Unable to analyse purchase.';
        try {
          final data = jsonDecode(response.body);
          message = (data['message'] ?? message).toString();
        } catch (_) {}
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Purchase Advisor error: $e')),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Widget metric(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value,
              style:
                  const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget productCard(Map<String, dynamic> product) {
    final name = (product['name'] ?? 'Product').toString();
    final store = (product['store'] ?? 'Online Store').toString();
    final rating = (product['rating'] ?? '').toString();
    final price = productPrice(product);
    final imageUrl = (product['imageUrl'] ?? '').toString();
    final isSelected =
        selectedProduct != null && sameProduct(selectedProduct!, product);
    final checked = isInComparison(product);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: isSelected ? 4 : 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            InkWell(
              onTap: () => selectProduct(product),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.shopping_bag_outlined, size: 34),
                          )
                        : const Icon(Icons.shopping_bag_outlined, size: 34),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                        const SizedBox(height: 6),
                        Text(store,
                            style: const TextStyle(color: Colors.grey)),
                        if (rating.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text('★ $rating',
                              style: const TextStyle(fontSize: 13)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${price.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      isSelected
                          ? const Icon(Icons.check_circle)
                          : const Text('Select',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              value: checked,
              onChanged: (_) => toggleComparison(product),
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text(
                'Add to comparison',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              subtitle: checked
                  ? Text(
                      '${comparisonSelection.length} selected',
                      style: const TextStyle(fontSize: 12),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget comparisonSection() {
    if (comparisonSelection.isEmpty && comparisonResults.isEmpty) {
      return const SizedBox.shrink();
    }

    final summary = comparisonSummary;
    final lowest = (summary?['lowestPrice'] as num?)?.toDouble();
    final average = (summary?['averagePrice'] as num?)?.toDouble();
    final bestName = (summary?['bestPriceProduct'] ?? '').toString();
    final bestStore = (summary?['bestPriceStore'] ?? '').toString();

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.compare_arrows),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Product Comparison',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  '${comparisonSelection.length}/4',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              comparisonSelection.length < 2
                  ? 'Select at least one more product.'
                  : 'Ready to compare ${comparisonSelection.length} products.',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: comparisonSelection
                  .map(
                    (product) => InputChip(
                      label: Text(
                        '${(product['store'] ?? 'Store')} • ₹${productPrice(product).toStringAsFixed(0)}',
                      ),
                      onDeleted: () => toggleComparison(product),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 46,
              child: ElevatedButton.icon(
                onPressed: comparingProducts || comparisonSelection.length < 2
                    ? null
                    : compareSelectedProducts,
                icon: comparingProducts
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.analytics_outlined),
                label: Text(
                    comparingProducts ? 'Comparing...' : 'Compare Selected'),
              ),
            ),
            if (comparisonMessage != null) ...[
              const SizedBox(height: 10),
              Text(comparisonMessage!,
                  style: const TextStyle(color: Colors.grey)),
            ],
            if (summary != null && comparisonResults.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 10),
              const Text(
                'Comparison Summary',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              if (lowest != null && average != null)
                Row(
                  children: [
                    Expanded(
                        child: metric(
                            'Lowest Price', '₹${lowest.toStringAsFixed(0)}')),
                    const SizedBox(width: 10),
                    Expanded(
                        child: metric(
                            'Average Price', '₹${average.toStringAsFixed(0)}')),
                  ],
                ),
              if (bestName.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Best price: $bestName${bestStore.isEmpty ? '' : ' • $bestStore'}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              ...comparisonResults.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final name = (item['name'] ?? 'Product').toString();
                final store = (item['store'] ?? 'Online Store').toString();
                final price = productPrice(item);
                final score = comparisonScore(item);

                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.grey.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 16,
                              child: Text('${index + 1}'),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(store,
                                      style:
                                          const TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '₹${price.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Value ${score.toStringAsFixed(0)}/100',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        LinearProgressIndicator(
                          value: (score.clamp(0, 100)) / 100,
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: () => chooseComparedProduct(item),
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('Choose for Purchase Advisor'),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget resultCard() {
    final data = result;
    if (data == null) return const SizedBox.shrink();

    final decision = (data['decision'] ?? '').toString();
    final score = (data['affordabilityScore'] as num?)?.toInt() ?? 0;
    final aiAdvice = (data['aiAdvice'] ?? data['reason'] ?? '').toString();
    final productPriceValue =
        (data['productPrice'] as num?)?.toDouble() ?? 0;
    final safeBudgetRemaining =
        (data['safeBudgetRemaining'] as num?)?.toDouble() ?? 0;
    final budgetAfterPurchase =
        (data['budgetAfterPurchase'] as num?)?.toDouble() ?? 0;
    final savingsTarget = (data['savingsTarget'] as num?)?.toDouble() ?? 0;

    IconData icon = Icons.check_circle_outline;
    if (decision == 'WAIT') icon = Icons.schedule;
    if (decision == 'AVOID') icon = Icons.warning_amber_rounded;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('SpendIQ Decision',
                          style: TextStyle(color: Colors.grey)),
                      Text(decision,
                          style: const TextStyle(
                              fontSize: 28, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Text('$score/100',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: (score.clamp(0, 100)) / 100),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                    child: metric('Product Price',
                        '₹${productPriceValue.toStringAsFixed(0)}')),
                const SizedBox(width: 10),
                Expanded(
                    child: metric('Safe Budget Left',
                        '₹${safeBudgetRemaining.toStringAsFixed(0)}')),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                    child: metric('After Purchase',
                        '₹${budgetAfterPurchase.toStringAsFixed(0)}')),
                const SizedBox(width: 10),
                Expanded(
                    child: metric(
                        'Savings Target', '₹${savingsTarget.toStringAsFixed(0)}')),
              ],
            ),
            const SizedBox(height: 18),
            const Row(
              children: [
                Icon(Icons.auto_awesome),
                SizedBox(width: 8),
                Text('AI Advice',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 8),
            Text(aiAdvice,
                style: const TextStyle(fontSize: 15, height: 1.45)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleProducts = products.take(12).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Purchase Advisor')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Should I Buy This?',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Search current product options, compare prices and value, then let SpendIQ check the chosen product against your budget.',
            style: TextStyle(color: Colors.grey, height: 1.4),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: searchController,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) {
              if (!searchingProducts) searchProducts();
            },
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'Search Products',
              hintText: 'Example: Samsung phone under 25000',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              suffixIcon: searchController.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        searchController.clear();
                        setState(() {
                          products = [];
                          comparisonSelection.clear();
                          comparisonResults = [];
                          comparisonSummary = null;
                          comparisonMessage = null;
                          selectedProduct = null;
                          searchMessage = null;
                        });
                      },
                      icon: const Icon(Icons.clear),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: searchingProducts ? null : searchProducts,
              icon: searchingProducts
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.travel_explore),
              label:
                  Text(searchingProducts ? 'Searching...' : 'Search Products'),
            ),
          ),
          if (searchMessage != null) ...[
            const SizedBox(height: 12),
            Text(searchMessage!, style: const TextStyle(color: Colors.grey)),
          ],
          if (visibleProducts.isNotEmpty) ...[
            const SizedBox(height: 18),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Product Options',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  'Showing ${visibleProducts.length} of ${products.length}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Tap a product to choose it, or tick 2-4 products to compare.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 10),
            ...visibleProducts.map(productCard),
          ],
          if (comparisonSelection.isNotEmpty ||
              comparisonResults.isNotEmpty) ...[
            const SizedBox(height: 8),
            comparisonSection(),
          ],
          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 12),
          Text(
            selectedProduct == null
                ? 'Manual Entry / Selected Product'
                : 'Selected Product',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: productController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Product Name',
              hintText: 'Select above or enter manually',
              prefixIcon: Icon(Icons.shopping_bag_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: priceController,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Product Price',
              hintText: '3000',
              prefixText: '₹ ',
              border: OutlineInputBorder(),
            ),
          ),
          if (selectedProduct != null) ...[
            const SizedBox(height: 8),
            Text(
              'Store: ${(selectedProduct!['store'] ?? 'Online Store')}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: loading ? null : analysePurchase,
              icon: loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.psychology_alt_outlined),
              label:
                  Text(loading ? 'Analysing...' : 'Should I Buy This?'),
            ),
          ),
          const SizedBox(height: 20),
          resultCard(),
        ],
      ),
    );
  }
}

// =====================================================
// ADD EXPENSE SCREEN
// =====================================================

class AddExpenseScreen extends StatefulWidget {
  final int userId;

  const AddExpenseScreen({
    super.key,
    required this.userId,
  });

  @override
  State<AddExpenseScreen> createState() =>
      _AddExpenseScreenState();
}

class _AddExpenseScreenState
    extends State<AddExpenseScreen> {

  final amountController = TextEditingController();
  final descriptionController =
      TextEditingController();

  final List<String> expenseCategories = [
    'Food',
    'Travel',
    'Shopping',
    'Bills',
    'Education',
    'Entertainment',
    'Health',
    'Other',
  ];

  String? selectedCategory;
  bool loading = false;

  Future<void> addExpense() async {

    if (amountController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty ||
        selectedCategory == null) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter amount, description and category',
          ),
        ),
      );

      return;
    }

    final double? amount =
        double.tryParse(
      amountController.text.trim(),
    );

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a valid amount',
          ),
        ),
      );

      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/expenses'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'amount': amount,
          'description':
              descriptionController.text.trim(),
          'userId': widget.userId,
          'category': selectedCategory,
          'source': 'MANUAL',
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Expense Added Successfully!',
            ),
          ),
        );

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed: ${response.body}',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            TextField(
              controller: amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '₹ ',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description / Reason',
                hintText:
                    'Example: Breakfast, Auto fare, College book',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            DropdownButtonFormField<String>(
              initialValue: selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category_outlined),
                border: OutlineInputBorder(),
              ),
              hint: const Text('Select Category'),
              items: expenseCategories
                  .map(
                    (category) => DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                });
              },
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed:
                    loading ? null : addExpense,

                child: loading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Save Expense'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// SET LIMITS SCREEN
// =====================================================

class SetLimitsScreen extends StatefulWidget {
  final int userId;

  const SetLimitsScreen({
    super.key,
    required this.userId,
  });

  @override
  State<SetLimitsScreen> createState() => _SetLimitsScreenState();
}

class _SetLimitsScreenState extends State<SetLimitsScreen> {
  final incomeController = TextEditingController();
  final dailyController = TextEditingController();
  final weeklyController = TextEditingController();
  final fifteenDayController = TextEditingController();
  final monthlyController = TextEditingController();

  bool loading = false;
  bool loadingPlan = true;
  int usedUpdates = 0;
  int remainingUpdates = 2;
  int maxUpdates = 2;
  bool canUpdate = true;

  @override
  void initState() {
    super.initState();
    loadBudgetPlan();
  }

  @override
  void dispose() {
    incomeController.dispose();
    dailyController.dispose();
    weeklyController.dispose();
    fifteenDayController.dispose();
    monthlyController.dispose();
    super.dispose();
  }

  Future<void> loadBudgetPlan() async {
    if (mounted) setState(() => loadingPlan = true);
    try {
      final responses = await Future.wait([
        http.get(Uri.parse('$baseUrl/api/income/${widget.userId}')),
        http.get(Uri.parse('$baseUrl/api/daily-limit/${widget.userId}')),
        http.get(Uri.parse('$baseUrl/api/weekly-limit/${widget.userId}')),
        http.get(Uri.parse('$baseUrl/api/fifteen-day-limit/${widget.userId}')),
        http.get(Uri.parse('$baseUrl/api/monthly-limit/${widget.userId}')),
        http.get(Uri.parse('$baseUrl/api/budget-plan/${widget.userId}/status')),
      ]);

      if (!mounted) return;

      if (responses[0].statusCode == 200) {
        final data = jsonDecode(responses[0].body);
        final value = (data?['monthlyIncome'] as num?)?.toDouble() ?? 0;
        if (value > 0) incomeController.text = value.toStringAsFixed(0);
      }
      if (responses[1].statusCode == 200) {
        final data = jsonDecode(responses[1].body);
        final value = (data?['limitAmount'] as num?)?.toDouble() ?? 0;
        if (value > 0) dailyController.text = value.toStringAsFixed(0);
      }
      if (responses[2].statusCode == 200) {
        final data = jsonDecode(responses[2].body);
        final value = (data?['limitAmount'] as num?)?.toDouble() ?? 0;
        if (value > 0) weeklyController.text = value.toStringAsFixed(0);
      }
      if (responses[3].statusCode == 200) {
        final data = jsonDecode(responses[3].body);
        final value = (data?['limitAmount'] as num?)?.toDouble() ?? 0;
        if (value > 0) fifteenDayController.text = value.toStringAsFixed(0);
      }
      if (responses[4].statusCode == 200) {
        final data = jsonDecode(responses[4].body);
        final value = (data?['limitAmount'] as num?)?.toDouble() ?? 0;
        if (value > 0) monthlyController.text = value.toStringAsFixed(0);
      }
      if (responses[5].statusCode == 200) {
        final data = jsonDecode(responses[5].body);
        setState(() {
          usedUpdates = (data['usedUpdates'] as num?)?.toInt() ?? 0;
          remainingUpdates = (data['remainingUpdates'] as num?)?.toInt() ?? 0;
          maxUpdates = (data['maxUpdatesPerMonth'] as num?)?.toInt() ?? 2;
          canUpdate = data['canUpdate'] == true;
        });
      }
    } catch (e) {
      debugPrint('Load budget plan error: $e');
    }
    if (mounted) setState(() => loadingPlan = false);
  }

  Future<void> saveBudgetPlan() async {
    final income = double.tryParse(incomeController.text.trim());
    final daily = double.tryParse(dailyController.text.trim());
    final weekly = double.tryParse(weeklyController.text.trim());
    final fifteenDays = double.tryParse(fifteenDayController.text.trim());
    final monthly = double.tryParse(monthlyController.text.trim());

    if (income == null || daily == null || weekly == null ||
        fifteenDays == null || monthly == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid amounts in all fields')),
      );
      return;
    }
    if (income <= 0 || daily <= 0 || weekly <= 0 ||
        fifteenDays <= 0 || monthly <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Income and all limits must be greater than 0')),
      );
      return;
    }
    if (monthly > income) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Monthly limit cannot be greater than monthly income')),
      );
      return;
    }
    if (!canUpdate || remainingUpdates <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have used both budget plan changes for this month.')),
      );
      return;
    }

    setState(() => loading = true);
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/budget-plan'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': widget.userId,
          'monthlyIncome': income,
          'dailyLimit': daily,
          'weeklyLimit': weekly,
          'fifteenDayLimit': fifteenDays,
          'monthlyLimit': monthly,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final left = (data['remainingUpdates'] as num?)?.toInt() ?? 0;
        setState(() {
          remainingUpdates = left;
          usedUpdates = maxUpdates - left;
          canUpdate = left > 0;
        });
        final savings = (data['savings'] as num?)?.toDouble() ?? (income - monthly);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Budget plan saved • ₹${savings.toStringAsFixed(0)} reserved for savings • $left change${left == 1 ? '' : 's'} left')),
        );
        Navigator.pop(context, true);
      } else if (response.statusCode == 429) {
        setState(() {
          remainingUpdates = 0;
          usedUpdates = maxUpdates;
          canUpdate = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Monthly limit reached: only 2 budget plan changes are allowed.')),
        );
      } else {
        String message = 'Could not save budget plan';
        try {
          final data = jsonDecode(response.body);
          message = data['message']?.toString() ?? message;
        } catch (_) {}
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Budget plan error: $e')),
      );
    }
    if (mounted) setState(() => loading = false);
  }

  Widget _moneyField(String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        enabled: canUpdate && !loading,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          prefixText: '₹ ',
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final income = double.tryParse(incomeController.text.trim()) ?? 0;
    final monthly = double.tryParse(monthlyController.text.trim()) ?? 0;
    final savings = math.max(0.0, income - monthly);

    return Scaffold(
      appBar: AppBar(title: const Text('Income & Budget Plan')),
      body: loadingPlan
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Plan your month',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'Set income and all spending checkpoints together. One save counts as one monthly plan change.',
                    style: TextStyle(color: Colors.grey, height: 1.4),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: canUpdate
                          ? const Color(0xFF7C4DFF).withValues(alpha: .09)
                          : Colors.orange.withValues(alpha: .10),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: canUpdate
                            ? const Color(0xFF7C4DFF).withValues(alpha: .25)
                            : Colors.orange.withValues(alpha: .30),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(canUpdate ? Icons.edit_calendar_rounded : Icons.lock_clock_rounded),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Text(
                            canUpdate
                                ? '$remainingUpdates of $maxUpdates budget plan changes remaining this month'
                                : '0 of $maxUpdates changes remaining • Plan locked until next month',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  _moneyField('Monthly Income', incomeController, Icons.account_balance_wallet_outlined),
                  _moneyField('Daily Limit', dailyController, Icons.today_rounded),
                  _moneyField('Weekly Limit', weeklyController, Icons.view_week_rounded),
                  _moneyField('15 Days Limit', fifteenDayController, Icons.date_range_rounded),
                  _moneyField('Monthly Limit', monthlyController, Icons.calendar_month_rounded),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: .08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.savings_rounded, color: Colors.green),
                        const SizedBox(width: 11),
                        const Expanded(
                          child: Text('Planned Savings', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                        Text(
                          '₹${savings.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: loading || !canUpdate ? null : saveBudgetPlan,
                      icon: loading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : Icon(canUpdate ? Icons.save_rounded : Icons.lock_rounded),
                      label: Text(
                        loading
                            ? 'Saving...'
                            : canUpdate
                                ? 'Save Budget Plan'
                                : 'Monthly Changes Used',
                        style: const TextStyle(fontSize: 17),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      'Used this month: $usedUpdates / $maxUpdates',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

