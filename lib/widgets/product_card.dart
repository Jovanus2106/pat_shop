import 'package:flutter/material.dart';
import 'package:patshop/my_product_entry_list.dart';
import 'package:patshop/productlist_form.dart';
import 'package:patshop/screens/product_entry_list.dart';
import 'package:patshop/screens/login.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class ItemHomepage {
  final String name;
  final IconData icon;
  final Color color;

  const ItemHomepage(this.name, this.icon, this.color);
}

class ItemCard extends StatelessWidget {
  final ItemHomepage item;
  const ItemCard(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();   

    return ElevatedButton.icon(
      onPressed: () async {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text("Kamu telah menekan tombol ${item.name}"),
            ),
          );

        if (item.name == "Create Product") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProductFormPage()),
          );
        } 
        else if (item.name == "All Products") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProductEntryListPage(),
            ),
          );
        } 
        else if (item.name == "My Products") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MyProductEntryListPage(),
            ),
          );
        }

        else if (item.name == "Logout") {
          final response = await request.logout(
            "http://127.0.0.1:8000/auth/logout/",
          );
          
          String message = response["message"];

          if (context.mounted) {
            if (response['status']) {
              String uname = response["username"];
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("$message See you again, $uname."),
                ),
              );

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                ),
              );
            }
          }
        }

      },
      style: ElevatedButton.styleFrom(
        backgroundColor: item.color,
        minimumSize: const Size(220, 50),
      ),
      icon: Icon(item.icon, color: Colors.white),
      label: Text(
        item.name,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
