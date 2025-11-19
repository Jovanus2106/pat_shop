import 'package:flutter/material.dart';
import 'package:patshop/models/ProductEntry.dart';
import 'package:patshop/widgets/product_entry_card.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:patshop/screens/product_detail.dart';  
class MyProductEntryListPage extends StatefulWidget {
  const MyProductEntryListPage({super.key});

  @override
  State<MyProductEntryListPage> createState() => _MyProductEntryListPageState();
}

class _MyProductEntryListPageState extends State<MyProductEntryListPage> {
  Future<List<ProductEntry>> fetchMyProducts(CookieRequest request) async {
    // Endpoint untuk produk milik user
    final response = await request.get(
      "http://127.0.0.1:8000/json/user/",
    );

    List<ProductEntry> products = [];
    for (var item in response) {
      products.add(ProductEntry.fromJson(item));
    }

    return products;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Products"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder(
        future: fetchMyProducts(request),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;

          if (data.isEmpty) {
            return const Center(
              child: Text(
                "Kamu belum membuat produk.",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              return ProductEntryCard(
                product: data[index],

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailPage(
                        product: data[index],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
