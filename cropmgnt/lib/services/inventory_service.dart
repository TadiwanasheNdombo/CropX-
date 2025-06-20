import 'dart:convert';
import 'package:http/http.dart' as http;

class InventoryService {
  final String baseUrl =
      'http://10.0.2.2:8080/api/inventory'; // Update with your backend URL

  // Create a new inventory item
  Future<Map<String, dynamic>> createInventoryItem(
    Map<String, dynamic> item,
  ) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(item),
    );

    if (response.statusCode == 201) {
      // Return the created item, including its ID
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create inventory item: ${response.body}');
    }
  }

  // Get all inventory items
  Future<List<Map<String, dynamic>>> getInventoryItems() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      // Ensure each item includes an 'id'
      return data.map((item) {
        final itemMap = item as Map<String, dynamic>;
        return {
          'id': itemMap['id'], // Ensure 'id' is included
          'name': itemMap['name'],
          'quantity': itemMap['quantity'],
          'unit': itemMap['unit'],
          'expirationDate': itemMap['expirationDate'],
        };
      }).toList();
    } else {
      throw Exception('Failed to load inventory items: ${response.body}');
    }
  }

  // Update an inventory item
  Future<void> updateInventoryItem(String id, Map<String, dynamic> item) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(item),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update inventory item: ${response.body}');
    }
  }

  // Delete an inventory item
  Future<void> deleteInventoryItem(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete inventory item: ${response.body}');
    }
  }
}
