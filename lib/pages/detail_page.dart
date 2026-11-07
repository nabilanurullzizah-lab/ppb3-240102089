import 'package:flutter/material.dart';

import '../product_service.dart';

class DetailPage extends StatefulWidget {
  final int productId;

  const DetailPage({super.key, required this.productId});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final ProductService _service = ProductService();

  Map<String, dynamic>? productDetail;
  bool isLoading = true;

  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProductDetail();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // READ: ambil detail produk berdasarkan ID
  Future<void> fetchProductDetail() async {
    final data = await _service.fetchProductById(widget.productId);
    if (!mounted) return;
    setState(() {
      productDetail = data;
      isLoading = false;
    });
  }

  // UPDATE: tampilkan dialog edit lalu kirim ke API
  Future<void> _showEditDialog() async {
    _titleController.text = productDetail!['title']?.toString() ?? '';
    _priceController.text = productDetail!['price']?.toString() ?? '';
    _descController.text = productDetail!['description']?.toString() ?? '';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Produk'),
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

    final changes = {
      'title': _titleController.text,
      'price': double.tryParse(_priceController.text) ?? 0,
      'description': _descController.text,
    };

    final result = await _service.updateProduct(widget.productId, changes);
    if (!mounted) return;

    if (result != null) {
      // DummyJSON tidak menyimpan data, jadi kita update state lokal sendiri
      setState(() {
        productDetail = {...productDetail!, ...changes};
      });
      _showSnackBar('Produk berhasil diubah');
    } else {
      _showSnackBar('Gagal mengubah produk');
    }
  }

  // DELETE: konfirmasi dulu, lalu hapus
  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Produk?'),
        content: const Text('Produk ini akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final ok = await _service.deleteProduct(widget.productId);
    if (!mounted) return;

    if (ok) {
      _showSnackBar('Produk berhasil dihapus');
      Navigator.pop(context, true); // kirim sinyal "terhapus" ke halaman list
    } else {
      _showSnackBar('Gagal menghapus produk');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F2), // Warna background pastel lembut
      appBar: AppBar(
        title: const Text('Detail Produk 🌸'),
        backgroundColor: const Color(0xFFFFD1D1), // Pink pastel
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          if (productDetail != null) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit',
              onPressed: _showEditDialog,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Hapus',
              onPressed: _confirmDelete,
            ),
          ],
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : productDetail == null
              ? const Center(child: Text('Gagal memuat detail produk'))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 300,
                        width: double.infinity,
                        color: Colors.white,
                        child: Image.network(
                          productDetail!['thumbnail'] ?? '',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Chip(
                                  backgroundColor:
                                      const Color(0xFFB4E197), // Hijau pastel
                                  label: Text(
                                    (productDetail!['category'] ?? '')
                                        .toString()
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${productDetail!['rating'] ?? 0}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              productDetail!['title'] ?? '',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '\$${productDetail!['price'] ?? 0}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFE84545),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 8),
                            const Text(
                              'Deskripsi Produk',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              productDetail!['description'] ?? '',
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black54,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Stok Tersedia: ${productDetail!['stock'] ?? 0}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
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