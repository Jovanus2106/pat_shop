import 'package:flutter/material.dart';
import 'package:patshop/productlist_form.dart';
import 'package:patshop/widgets/left_drawer.dart';

class MyHomePage extends StatelessWidget {
  
  const MyHomePage({super.key});
  
  // tiga tombol dengan nama dan ikon
  final List<ItemHomepage> items = const [
    ItemHomepage("All Products", Icons.list, Colors.blue),
    ItemHomepage("My Products", Icons.shopping_bag, Colors.green),
    ItemHomepage("Create Product", Icons.add, Colors.red),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PAT SHOP',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      drawer: const LeftDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: items.map((ItemHomepage item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: ItemCard(item),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// tetap pakai ItemCard, tapi diubah jadi tombol berwarna
class ItemCard extends StatelessWidget {
  final ItemHomepage item;
  const ItemCard(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                "Kamu telah menekan tombol ${item.name}",
              ),
            ),
          );
        if (item.name == "Create Product") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProductFormPage(),
            ),
          );
        }
      },
      icon: Icon(item.icon, color: Colors.white),
      label: Text(item.name, style: const TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: item.color,
        minimumSize: const Size(220, 50),
      ),
    );
  }
}

// tambahkan atribut color di ItemHomepage
class ItemHomepage {
  final String name;
  final IconData icon;
  final Color color;

  const ItemHomepage(this.name, this.icon, this.color);
}
