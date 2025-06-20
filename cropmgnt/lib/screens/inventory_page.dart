import 'package:flutter/material.dart';
import '../services/inventory_service.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final InventoryService _inventoryService = InventoryService();
  List<Map<String, dynamic>> inventoryItems = [];
  List<Map<String, dynamic>> filteredItems = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInventory(); // Load items when the screen is initialized
  }

  // Load inventory items from the service
  void _loadInventory() async {
    try {
      inventoryItems = await _inventoryService.getInventoryItems();
      print(
        'Loaded inventory items: $inventoryItems',
      ); // Log items to check for IDs
      filteredItems = inventoryItems; // Initialize filtered items
      setState(() {}); // Refresh UI
    } catch (error) {
      print('Error loading inventory: $error');
    }
  }

  // Function to show the "Add or Edit Item" dialog
  void _showItemDialog({int? index}) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController quantityController = TextEditingController();
    final TextEditingController unitController = TextEditingController();
    final TextEditingController expirationDateController =
        TextEditingController();

    // Populate fields if editing an existing item
    if (index != null) {
      final item = inventoryItems[index];
      nameController.text = item['name'] ?? ''; // Handle null
      quantityController.text =
          item['quantity']?.toString() ?? '0'; // Handle null
      unitController.text = item['unit'] ?? ''; // Handle null
      expirationDateController.text =
          item['expirationDate'] ?? ''; // Handle null
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(index == null ? 'Add New Item' : 'Edit Item'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Item Name'),
                ),
                TextField(
                  controller: quantityController,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: unitController,
                  decoration: const InputDecoration(
                    labelText: 'Unit (e.g., kg, liters)',
                  ),
                ),
                TextField(
                  controller: expirationDateController,
                  decoration: const InputDecoration(
                    labelText: 'Expiration Date (YYYY-MM-DD)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final newItem = {
                  'name': nameController.text,
                  'quantity':
                      int.tryParse(quantityController.text) ??
                      0, // Handle parsing
                  'unit': unitController.text,
                  'expirationDate': expirationDateController.text,
                };

                if (index == null) {
                  // Add new item
                  final createdItem = await _inventoryService
                      .createInventoryItem(newItem);
                  inventoryItems.add(createdItem); // Ensure created item has ID
                } else {
                  // Update existing item
                  final item =
                      inventoryItems[index]; // Retrieve the current item
                  if (item.containsKey('id')) {
                    await _inventoryService.updateInventoryItem(
                      item['id'],
                      newItem,
                    );
                    inventoryItems[index] = newItem; // Update the local list
                  } else {
                    print('Error: Item does not have an ID.'); // Handle error
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Item ID is missing!')),
                    );
                  }
                }

                _loadInventory(); // Refresh the inventory list
                Navigator.of(context).pop();
              },
              child: Text(index == null ? 'Add Item' : 'Update Item'),
            ),
          ],
        );
      },
    );
  }

  // Function to filter items based on search query
  void _filterItems(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredItems = inventoryItems;
      });
    } else {
      setState(() {
        filteredItems =
            inventoryItems.where((item) {
              return item['name']?.toLowerCase().contains(
                    query.toLowerCase(),
                  ) ??
                  false; // Handle null
            }).toList();
      });
    }
  }

  // Function to determine the chip color based on quantity
  Color _getChipColor(int quantity) {
    if (quantity <= 4) {
      return Colors.red; // Out of Stock
    } else if (quantity <= 10) {
      return Colors.deepOrange; // Low Stock
    } else {
      return Colors.green; // In Stock
    }
  }

  // Function to use an item
  void _useItem() {
    // Show dialog to enter item name and quantity to use
    final TextEditingController itemNameController = TextEditingController();
    final TextEditingController quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Use Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: itemNameController,
                decoration: const InputDecoration(labelText: 'Item Name'),
              ),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Quantity to Use'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final itemName = itemNameController.text;
                final quantityToUse =
                    int.tryParse(quantityController.text) ?? 0;

                // Find the item in the filtered list
                final item = filteredItems.firstWhere(
                  (item) =>
                      item['name']?.toLowerCase() == itemName.toLowerCase(),
                  orElse: () => {}, // Return an empty map if not found
                );

                // Check if the item is valid
                if (item.isEmpty) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Item not found!')));
                  return;
                }

                if (quantityToUse <= 0 || quantityToUse > item['quantity']) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Invalid quantity!')));
                  return;
                }

                setState(() {
                  item['quantity'] -= quantityToUse; // Update local state
                });

                // Update the item in the database
                if (item['id'] != null) {
                  await _inventoryService.updateInventoryItem(item['id'], {
                    'name': item['name'],
                    'quantity': item['quantity'],
                    'unit': item['unit'],
                    'expirationDate': item['expirationDate'],
                  });
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Item used successfully!')),
                );
                Navigator.of(context).pop();
              },
              child: const Text('Use Item'),
            ),
          ],
        );
      },
    );
  }

  // Function to delete an item
  void _deleteItem() {
    // Show dialog to enter item name to delete
    final TextEditingController itemNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: itemNameController,
                decoration: const InputDecoration(labelText: 'Item Name'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final itemName = itemNameController.text;

                // Find the item in the inventory
                final item = filteredItems.firstWhere(
                  (item) =>
                      item['name']?.toLowerCase() == itemName.toLowerCase(),
                  orElse: () => {}, // Return an empty map if not found
                );

                if (item.isEmpty) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Item not found!')));
                  return;
                }

                // Delete the item from the database
                if (item['id'] != null) {
                  await _inventoryService.deleteInventoryItem(item['id']);
                }

                // Remove the item from the local list
                setState(() {
                  filteredItems.removeWhere((i) => i['id'] == item['id']);
                  inventoryItems.removeWhere((i) => i['id'] == item['id']);
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Item deleted successfully!')),
                );
                Navigator.of(context).pop();
              },
              child: const Text('Delete Item'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteItem, // Button to delete an item
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search items...',
                prefixIcon: const Icon(Icons.search, color: Colors.green),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onChanged: _filterItems,
            ),
            const SizedBox(height: 16),

            // Add New Item Button
            ElevatedButton.icon(
              onPressed: () => _showItemDialog(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Add New Item', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 16),

            // Use Item Button
            ElevatedButton.icon(
              onPressed: _useItem, // Updated to call the new function
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.check, color: Colors.white),
              label: const Text('Use Item', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 16),

            // Inventory List
            Expanded(
              child: ListView.builder(
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green.withOpacity(0.2),
                        child: Icon(Icons.inventory, color: Colors.green),
                      ),
                      title: Text(
                        item['name'] ?? 'Unknown', // Handle null
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quantity: ${item['quantity'] ?? 0} ${item['unit'] ?? ''}',
                          ), // Handle null
                          Text(
                            'Expiration: ${item['expirationDate'] ?? 'N/A'}',
                          ), // Handle null
                        ],
                      ),
                      trailing: Chip(
                        label: Text(
                          'Stock',
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: _getChipColor(
                          (item['quantity'] as int?) ??
                              0, // Ensure quantity is an integer
                        ),
                      ),
                      onTap: () => _showItemDialog(index: index),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
