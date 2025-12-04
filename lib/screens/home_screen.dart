import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../utils/nequi_alert.dart';

class HomeScreen extends StatefulWidget {
  final String userPhone;
  
  const HomeScreen({super.key, required this.userPhone});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  // final FirebaseFirestore _db = FirebaseFirestore.instance; // Comentado temporalmente
  final ScrollController _scrollController = ScrollController();
  
  String _userName = 'Usuario';
  String _userGreeting = '';
  int _disponible = 0;
  int _total = 0;
  bool _isBalanceHidden = false;
  bool _isRefreshing = false;
  StreamSubscription? _saldoSubscription;
  
  late AnimationController _refreshController;
  
  int _currentSection = 0; // 0: Home, 1: Movements, 2: Services
  
  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _loadUserData();
    // _setupSaldoListener(); // Comentado temporalmente
    _loadBalanceHiddenState();
    
    // Pull to refresh setup
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _saldoSubscription?.cancel();
    _scrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels < -100 && !_isRefreshing) {
      _triggerRefresh();
    }
  }

  Future<void> _loadBalanceHiddenState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isBalanceHidden = prefs.getBool('balance_hidden') ?? false;
    });
  }

  Future<void> _loadUserData() async {
    // Comentado temporalmente hasta configurar Firebase
    // try {
    //   final phoneDigits = widget.userPhone.replaceAll(RegExp(r'[^\d]'), '');
    //   final query = await _db.collection('users')
    //       .where('telefono', isEqualTo: phoneDigits)
    //       .limit(1)
    //       .get();
    //   
    //   if (query.docs.isNotEmpty) {
    //     final doc = query.docs.first;
    //     final data = doc.data();
    //     
    //     setState(() {
    //       _userName = data['name'] as String? ?? '';
    //       _userGreeting = _getGreeting();
    //       _disponible = _readLongFlexible(data, 'saldo');
    //       final colchon = _readLongFlexible(data, 'colchon');
    //       final extra = _readLongFlexible(data, 'saldo_extra');
    //       _disponible = extra > 0 ? extra : _disponible;
    //       _total = (_disponible + colchon).clamp(0, double.infinity).toInt();
    //     });
    //   }
    // } catch (e) {
    //   debugPrint('Error loading user data: $e');
    // }
    
    // Datos de demo
    setState(() {
      _userName = 'Usuario Demo';
      _userGreeting = _getGreeting();
      _disponible = 150000;
      _total = 150000;
    });
  }

  void _setupSaldoListener() {
    // Comentado temporalmente hasta configurar Firebase
    // _loadUserData().then((_) async {
    //   final phoneDigits = widget.userPhone.replaceAll(RegExp(r'[^\d]'), '');
    //   final query = await _db.collection('users')
    //       .where('telefono', isEqualTo: phoneDigits)
    //       .limit(1)
    //       .get();
    //   
    //   if (query.docs.isNotEmpty) {
    //     final docId = query.docs.first.id;
    //     _saldoSubscription = _db.collection('users').doc(docId)
    //         .snapshots()
    //         .listen((snapshot) {
    //       if (snapshot.exists) {
    //         final data = snapshot.data()!;
    //         setState(() {
    //           _disponible = _readLongFlexible(data, 'saldo');
    //           final colchon = _readLongFlexible(data, 'colchon');
    //           final extra = _readLongFlexible(data, 'saldo_extra');
    //           _disponible = extra > 0 ? extra : _disponible;
    //           _total = (_disponible + colchon).clamp(0, double.infinity).toInt();
    //         });
    //       }
    //     });
    //   }
    // });
  }

  int _readLongFlexible(Map<String, dynamic> data, String field) {
    final value = data[field];
    if (value == null) return 0;
    if (value is num) return value.toInt();
    if (value is String) {
      final digits = value.replaceAll(RegExp(r'[^\d]'), '');
      return int.tryParse(digits) ?? 0;
    }
    return 0;
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 18) return 'Buenas tardes';
    return 'Buenas noches';
  }

  String _formatCurrency(int amount) {
    final formatter = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  void _triggerRefresh() {
    if (_isRefreshing) return;
    
    setState(() {
      _isRefreshing = true;
    });
    
    _refreshController.forward();
    
    _loadUserData().then((_) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _isRefreshing = false;
          });
          _refreshController.reverse();
        }
      });
    });
  }

  void _toggleBalanceVisibility() async {
    setState(() {
      _isBalanceHidden = !_isBalanceHidden;
    });
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('balance_hidden', _isBalanceHidden);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF200020),
      body: SafeArea(
        child: Column(
          children: [
            // Header with refresh indicator
            _buildHeader(),
            
            // Main content
            Expanded(
              child: _buildContent(),
            ),
            
            // Bottom navigation
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userGreeting,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _userName.isNotEmpty ? _userName : 'Usuario',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Notifications and profile
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                    onPressed: () {
                      // Open notifications
                    },
                  ),
                  GestureDetector(
                    onTap: () {
                      // Open profile
                    },
                    child: const CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Balance section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Disponible',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _isBalanceHidden ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: _toggleBalanceVisibility,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _isBalanceHidden ? '••••••' : _formatCurrency(_disponible),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF00FF),
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      _isBalanceHidden ? '••••••' : _formatCurrency(_total),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_currentSection == 0) {
      return _buildHomeContent();
    } else if (_currentSection == 1) {
      return _buildMovementsContent();
    } else {
      return _buildServicesContent();
    }
  }

  Widget _buildHomeContent() {
    return RefreshIndicator(
      onRefresh: () async {
        _triggerRefresh();
        await Future.delayed(const Duration(seconds: 1));
      },
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Cards section
            _buildCardsSection(),
            
            const SizedBox(height: 30),
            
            // Suggested icons
            _buildSuggestedIcons(),
            
            const SizedBox(height: 30),
            
            // Favorites section
            _buildFavoritesSection(),
            
            const SizedBox(height: 100), // Space for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildCardsSection() {
    return SizedBox(
      height: 200,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildCard('Depósito Bajo Monto', Icons.account_balance_wallet),
          const SizedBox(width: 12),
          _buildCard('Tu plata', Icons.monetization_on),
          const SizedBox(width: 12),
          _buildCard('Colchón', Icons.savings),
        ],
      ),
    );
  }

  Widget _buildCard(String title, IconData icon) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: const Color(0xFFFF00FF)),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedIcons() {
    final icons = [
      {'icon': Icons.send, 'label': 'Enviar'},
      {'icon': Icons.qr_code, 'label': 'QR'},
      {'icon': Icons.add_circle, 'label': 'Agregar'},
      {'icon': Icons.more_horiz, 'label': 'Más'},
    ];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: icons.map((item) {
          return Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  item['icon'] as IconData,
                  color: const Color(0xFFFF00FF),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item['label'] as String,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFavoritesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Favoritos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: () {
                  // Show favorites bottom sheet
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Favorites grid would go here
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'No hay favoritos',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovementsContent() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar movimientos',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No hay movimientos',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesContent() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.grid_view, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Servicios',
              style: TextStyle(color: Colors.grey[600], fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, 'Inicio', 0),
            _buildNavItem(Icons.receipt_long, 'Movimientos', 1),
            _buildNavItem(Icons.grid_view, 'Servicios', 2),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentSection == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentSection = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFFFF00FF) : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFFFF00FF) : Colors.grey,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

