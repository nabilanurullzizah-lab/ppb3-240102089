import 'package:flutter/material.dart';

import 'product_service.dart';
import 'pages/detail_page.dart';

void main() {
  runApp(const PastelShopApp());
}

class PastelShopApp extends StatelessWidget {
  const PastelShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pastel Shop',
      theme: ThemeData(
        primaryColor: const Color(0xFFB4E197),
        scaffoldBackgroundColor: const Color(0xFFF7F6F2),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFD1D1),
          foregroundColor: Colors.black87,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ProductService productService = ProductService();

  List<dynamic> products = [];
  bool isLoading = true;

  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // READ: ambil semua produk
  Future<void> loadProducts() async {
    setState(() => isLoading = true);
    final data = await productService.fetchProducts();
    if (!mounted) return;
    setState(() {
      products = data;
      isLoading = false;
    });
  }

  // READ: cari produk
  Future<void> handleSearch(String query) async {
    setState(() => isLoading = true);
    final data = query.isEmpty
        ? await productService.fetchProducts()
        : await productService.searchProducts(query);
    if (!mounted) return;
    setState(() {
      products = data;
      isLoading = false;
    });
  }

  // CREATE: dialog form tambah produk
  Future<void> _showAddDialog() async {
    _titleController.clear();
    _priceController.clear();
    _descController.clear();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Produk'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Judul'),
              ),
              TextField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Harga'),
              ),
              TextField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (_titleController.text.trim().isEmpty) {
      _showSnackBar('Judul tidak boleh kosong');
      return;
    }

    final newProduct = {
      'title': _titleController.text.trim(),
      'price': double.tryParse(_priceController.text) ?? 0,
      'description': _descController.text.trim(),
    };

    final result = await productService.addProduct(newProduct);
    if (!mounted) return;

    if (result != null) {
      // Response API tidak punya thumbnail, jadi gabungkan dengan data kita
      setState(() => products.insert(0, {...newProduct, ...result}));
      _showSnackBar('Produk berhasil ditambahkan');
    } else {
      _showSnackBar('Gagal menambah produk');
    }
  }

  // Buka halaman detail lalu tangkap hasilnya (hapus / edit)
  Future<void> _openDetail(Map<String, dynamic> product) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPage(productId: product['id']),
      ),
    );
    if (!mounted) return;

    if (result == true) {
      // DELETE: produk dihapus di halaman detail
      setState(() => products.removeWhere((p) => p['id'] == product['id']));
    } else if (result is Map<String, dynamic>) {
      // UPDATE: produk diedit di halaman detail
      setState(() {
        final i = products.indexWhere((p) => p['id'] == product['id']);
        if (i != -1) products[i] = {...products[i], ...result};
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pastel Store 🌸'), centerTitle: true),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: const Color(0xFFB4E197),
        foregroundColor: Colors.black87,
        tooltip: 'Tambah produk',
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: handleSearch,
              decoration: InputDecoration(
                hintText: 'Cari produk...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : products.isEmpty
                    ? const Center(child: Text('Produk tidak ditemukan'))
                    : GridView.builder(
                        padding: const EdgeInsets.all(10),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return GestureDetector(
                            onTap: () => _openDetail(product),
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F6EF),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius:
                                          const BorderRadius.vertical(
                                        top: Radius.circular(15),
                                      ),
                                      child: Image.network(
                                        product['thumbnail'] ?? '',
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        errorBuilder: (_, __, ___) =>
                                            const Center(
                                          child: Icon(
                                            Icons.image_not_supported,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      product['title'] ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
                                    child: Text(
                                      '\$${product['price'] ?? 0}',
                                      style: const TextStyle(
                                        color: Colors.pinkAccent,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}