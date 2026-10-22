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
  String? _nameError; // shown under the name field when validation fails
  String? _priceError; // shown under the price field when validation fails

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

  // Every change to _items or to an item's fields happens inside setState so the screen rebuilds.
  void _increase(int i) => setState(() { if (_items[i].quantity < 99) _items[i].quantity++; }); // plus stops at 99
  void _decrease(int i) => setState(() { if (_items[i].quantity > 1) _items[i].quantity--; }); // minus never goes below 1
  void _toggle(int i) => setState(() => _items[i].gotIt = !_items[i].gotIt);
  void _clearChecked() => setState(() => _items.removeWhere((item) => item.gotIt));

  // Validates both fields: the name must not be empty and the price must be a number above 0.
  void _addItem() {
    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text.trim()); // null when the text is not a number
    setState(() {
      _nameError = name.isEmpty ? 'Enter an item name' : null;
      _priceError = (price == null || price <= 0) ? 'Enter a price above 0' : null;
      if (_nameError == null && _priceError == null) {
        _items.add(CartItem(name: name, price: price!));
        _nameController.clear();
        _priceController.clear();
      }
    });
  }

  // Derived values are computed from _items every build, so the summary is always live.
  int get _gotCount => _items.where((item) => item.gotIt).length;
  double get _total => _items.fold(0.0, (sum, item) => sum + item.price * item.quantity);

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(title: const Text('Mini Shopping Cart'), backgroundColor: color, foregroundColor: Colors.white),
      body: SafeArea(
        child: Column(
          children: [
            // Expanded gives the ListView a bounded height inside the Column.
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _items.length,
                itemBuilder: (context, i) => CartItemTile(item: _items[i], onIncrease: () => _increase(i), onDecrease: () => _decrease(i), onToggle: () => _toggle(i)),
              ),
            ),
            // Summary bar: item count, got-it count and the live total.
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
            // Add item form: two fields with validation errors, then the Add and Clear checked buttons.
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: TextField(controller: _nameController, decoration: InputDecoration(labelText: 'Item name', errorText: _nameError, border: const OutlineInputBorder(), isDense: true))),
                      const SizedBox(width: 8),
                      Expanded(flex: 2, child: TextField(controller: _priceController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: 'Price', errorText: _priceError, border: const OutlineInputBorder(), isDense: true))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: FilledButton(onPressed: _addItem, child: const Text('Add'))),
                      const SizedBox(width: 8),
                      Expanded(child: OutlinedButton(onPressed: _clearChecked, child: const Text('Clear checked'))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Stateless: it only displays the CartItem it is given and reports taps through callbacks; it never calls setState because the parent owns the data.
class CartItemTile extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onToggle;
  const CartItemTile({super.key, required this.item, required this.onIncrease, required this.onDecrease, required this.onToggle});
  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              Checkbox(value: item.gotIt, onChanged: (_) => onToggle()),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Line-through and grey text when the item is checked.
                    Text(item.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, decoration: item.gotIt ? TextDecoration.lineThrough : null, color: item.gotIt ? Colors.grey : null)),
                    Text('PHP ${item.price.toStringAsFixed(2)} each', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                  ],
                ),
              ),
              IconButton.outlined(onPressed: onDecrease, icon: const Icon(Icons.remove)),
              SizedBox(width: 28, child: Text('${item.quantity}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
              IconButton.outlined(onPressed: onIncrease, icon: const Icon(Icons.add)),
            ],
          ),
        ),
      );
}