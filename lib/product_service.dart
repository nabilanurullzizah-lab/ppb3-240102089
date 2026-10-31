import 'dart:convert';

import 'package:http/http.dart' as http;

class ProductService {
  final String apiUrl = 'https://dummyjson.com/products';

  // Mengambil seluruh produk untuk halaman depan
  Future<List<dynamic>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['products'];
      } else {
        throw Exception('Gagal memuat produk');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error fetchProducts: $e');
      return [];
    }
  }

  // Fungsi untuk pencarian produk (Search) yang fungsional
  Future<List<dynamic>> searchProducts(String query) async {
    try {
      final response = await http.get(
        Uri.parse('https://dummyjson.com/products/search?q=$query'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['products'];
      } else {
        throw Exception('Gagal mencari produk');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error searchProducts: $e');
      return [];
    }
  }
}
