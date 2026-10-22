import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(title: 'Mini Shopping Cart', debugShowCheckedModeBanner: false, theme: ThemeData(colorSchemeSeed: Colors.blueAccent, useMaterial3: true), home: const CartScreen()));

// Data model: name and price are final because they never change, while quantity and gotIt are changeable because the user edits them.
class CartItem {
  final String name;
  final double price;
  int quantity;
  bool gotIt;
  CartItem({required this.name, required this.price, this.quantity = 1, this.gotIt = false});
}

// Stateful: the cart changes while the app runs (quantities, checkmarks, new items), so Flutter keeps a State object alive between rebuilds.
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override
  State<CartScreen> createState() => _CartScreenState();
}

// The State class owns everything that changes: the _items list, the two text controllers and the error messages.
class _CartScreenState extends State<CartScreen> {
  final List<CartItem> _items = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  // Runs once when the screen is created: preload the 3 sample items.
  @override
  void initState() {
    super.initState();
    _items.addAll([CartItem(name: 'Rice', price: 60.00, quantity: 2), CartItem(name: 'Eggs', price: 8.00, quantity: 12), CartItem(name: 'Milk', price: 95.00)]);
  }

  // Runs once when the screen is removed: release both controllers so they do not leak memory.
  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // Derived values are computed from _items every build, so the summary is always live.
  int get _gotCount => _items.where((item) => item.gotIt).length;
  double get _total => _items.fold(0.0, (sum, item) => sum + item.price * item.quantity);

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(title: const Text('Mini Shopping Cart'), backgroundColor: color, foregroundColor: Colors.white),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _items.length,
              itemBuilder: (context, i) => ListTile(title: Text(_items[i].name), subtitle: Text('PHP ${_items[i].price.toStringAsFixed(2)} x ${_items[i].quantity}')),
            ),
          ),
          Container(
            width: double.infinity,
            color: color.withValues(alpha: 0.12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Items: ${_items.length}  •  Got it: $_gotCount'),
                Text('Total: PHP ${_total.toStringAsFixed(2)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}