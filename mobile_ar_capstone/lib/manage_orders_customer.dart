import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'collections/order.dart';
import 'collections/livestock.dart';
import 'globals.dart';

class ManageOrdersCustomerPage extends StatefulWidget {
  final Isar isar;

  ManageOrdersCustomerPage({required this.isar});

  @override
  _ManageOrdersCustomerPageState createState() => _ManageOrdersCustomerPageState();
}

class _ManageOrdersCustomerPageState extends State<ManageOrdersCustomerPage> {
  List<Order> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() async {
    final orders = await widget.isar.orders
        .filter()
        .customerIdEqualTo(globalUserCustomer!.id.toString())
        .findAll();
    setState(() {
      _orders = orders;
    });
  }

  void _confirmOrder(Order order) async {
    order.status = 'received';
    await widget.isar.writeTxn(() async {
      await widget.isar.orders.put(order);
      // Update the livestock status to "sold"
      final livestock = await widget.isar.livestocks.get(order.livestockId);
      if (livestock != null) {
        livestock.status = 'sold';
        await widget.isar.livestocks.put(livestock);
      }
    });
    _loadOrders();
  }

  void _cancelOrder(Order order) async {
    order.status = 'cancelled';
    await widget.isar.writeTxn(() async {
      await widget.isar.orders.put(order);
    });
    _loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Orders'),
      ),
      body: _orders.isEmpty
          ? const Center(child: Text('No orders found.'))
          : ListView.builder(
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                final order = _orders[index];
                return Card(
                  child: ListTile(
                    title: Text('Livestock: ${order.livestockId}'), // You can update this to show livestock name/type
                    subtitle: Text('Seller: ${order.sellerId}\nStatus: ${order.status}'), // You can update this to show seller name
                    trailing: order.status == 'requested_cancel'
                        ? ElevatedButton(
                            onPressed: () => _cancelOrder(order),
                            child: Text('Cancel Order'),
                          )
                        : ElevatedButton(
                            onPressed: () => _confirmOrder(order),
                            child: Text('Order Received'),
                          ),
                  ),
                );
              },
            ),
        bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('lib/assets/house.png')),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('lib/assets/market.png')),
            label: 'Market',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('lib/assets/edit-user.png')),
            label: 'Account',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('lib/assets/fees.png')),
            label: 'Manage Orders',
          ),
        ],
        currentIndex: 3,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/main_page_customer');
              break;
            case 1:
              Navigator.pushNamed(context, '/market_page_customer');
              break;
            case 2:
              Navigator.pushNamed(context, '/profile');
              break;
            case 3:
              Navigator.pushNamed(context, '/manage_orders_customer');
              break;
            default:
              Navigator.pushNamed(context, '/');
          }
        },
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}

