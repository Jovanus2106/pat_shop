import 'package:flutter/material.dart';
import 'package:patshop/widgets/left_drawer.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:patshop/screens/menu.dart';

class ProductFormPage extends StatefulWidget {
  const ProductFormPage({super.key});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  String _title = "";
  String _content = "";
  String _category = "Elektronik";
  String _thumbnail = "";
  String _price = "";
  String _stock = "";
  bool _isFeatured = false;

  static const List<String> _categories = [
    'Elektronik',
    'Fashion',
    'Peralatan Rumah',
    'Makanan & Minuman',
    'Olahraga',
  ];

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Add Product Form',
          ),
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === Title ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: "Nama Produk",
                    labelText: "Nama Produk",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _title = value!;
                    });
                  },
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Nama produk wajib diisi!";
                    }

                    if (value.length > 50) {
                      return "Nama produk maksimal 50 karakter!";
                    }
                    return null;
                  },
                ),
              ),

              // === Content ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: "Deskripsi Produk",
                    labelText: "Deskripsi Produk",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _content = value!;
                    });
                  },
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Deskripsi produk wajib diisi!";
                    }

                    if (value.length > 300) {
                      return "Deskripsi produk maksimal 300 karakter!";
                    }
                    return null;
                  },
                ),
              ),

              // === Price ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: "Harga Produk",
                    labelText: "Harga Produk",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (String? value) {
                    setState(() {
                      _price = value!;
                    });
                  },
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Harga produk wajib diisi!";
                    }
                    final num? price = num.tryParse(value);
                    if (price == null) {
                      return "Harga harus berupa angka!";
                    }
                    if (price <= 0) {
                      return "Harga tidak boleh nol atau negatif!";
                    }
                    return null;
                  },
                ),
              ),

              // === Category ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FormField<String>(
                  initialValue: _category,
                  builder: (FormFieldState<String> field) {
                    return InputDecorator(
                      decoration: InputDecoration(
                        labelText: "Kategori",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        errorText: field.errorText,
                      ),
                      child: DropdownButton<String>(
                        value: _category,
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: _categories
                            .map((cat) => DropdownMenuItem(
                                  value: cat,
                                  child: Text(
                                      cat[0].toUpperCase() + cat.substring(1)),
                                ))
                            .toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _category = newValue!;
                          });
                          field.didChange(newValue);
                        },
                      ),
                    );
                  },
                ),
              ),

              // === Thumbnail URL ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: "URL Thumbnail",
                    labelText: "URL Thumbnail",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _thumbnail = value ?? "";
                    });
                  },
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "URL Thumbnail wajib diisi!";
                    }
                    // Cek format dasar URL
                    final uri = Uri.tryParse(value);
                    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
                      return "URL tidak valid! Harus diawali dengan http/https dan memiliki format yang benar.";
                    }
                    return null;
                  },
                ),
              ),

              // === Is Featured ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SwitchListTile(
                  title: const Text("Tandai sebagai Produk Unggulan"),
                  value: _isFeatured,
                  onChanged: (bool value) {
                    setState(() {
                      _isFeatured = value;
                    });
                  },
                ),
              ),
              // === Stock ===
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              decoration: InputDecoration(
                hintText: "Stok Produk",
                labelText: "Stok Produk",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
              keyboardType: TextInputType.number,
              onChanged: (String? value) {
                setState(() {
                  _stock = value!;
                });
              },
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return "Stok wajib diisi!";
                }
                final num? stock = num.tryParse(value);
                if (stock == null) {
                  return "Stok harus berupa angka!";
                }
                if (stock < 0) {
                  return "Stok tidak boleh negatif!";
                }
                return null;
              },
            ),
          ),
             
              // === Tombol Simpan ===
Padding(
  padding: const EdgeInsets.all(8.0),
  child: Center(
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.indigo,
      ),
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          
          // === KIRIM KE DJANGO ===
          final response = await request.postJson(
            "http://127.0.0.1:8000/create-flutter/",
            jsonEncode({
              "name": _title,
              "description": _content,
              "price": int.parse(_price),
              "thumbnail": _thumbnail,
              "category": _category,
              "stock": int.parse(_stock),
              "is_featured": _isFeatured,
            }),
          );

          if (context.mounted) {
            if (response['status'] == 'success') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Product successfully saved!"),
                ),
              );

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MyHomePage()),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Something went wrong, please try again."),
                ),
              );
            }
          }
        }
      },
      child: const Text(
        "Simpan",
        style: TextStyle(color: Colors.white),
      ),
    ),
  ),
),
            ],
          ),
        ),
      ),
    );
  }
}
