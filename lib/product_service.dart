import 'dart:convert';

import 'package:http/http.dart' as http;

class ProductService {
  final String apiUrl = 'https://dummyjson.com/products';

  // ================= READ =================

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

  // Mengambil satu produk berdasarkan id (untuk detail)
  Future<Map<String, dynamic>?> fetchProductById(int id) async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/$id'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Gagal memuat detail produk');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error fetchProductById: $e');
      return null;
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

  // ================= CREATE =================

  Future<Map<String, dynamic>?> addProduct(Map<String, dynamic> product) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/add'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(product),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Gagal menambah produk');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error addProduct: $e');
      return null;
    }
  }

  // ================= UPDATE =================

  Future<Map<String, dynamic>?> updateProduct(
    int id,
    Map<String, dynamic> product,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(product),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Gagal mengubah produk');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error updateProduct: $e');
      return null;
    }
  }

  // ================= DELETE =================

  Future<bool> deleteProduct(int id) async {
    try {
      final response = await http.delete(Uri.parse('$apiUrl/$id'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['isDeleted'] == true;
      } else {
        throw Exception('Gagal menghapus produk');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error deleteProduct: $e');
      return false;
    }
  }
}