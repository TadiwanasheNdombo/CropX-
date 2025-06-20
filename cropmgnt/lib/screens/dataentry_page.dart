import 'package:flutter/material.dart';

class DataentryPage extends StatefulWidget {
  const DataentryPage({super.key});

  @override
  State<DataentryPage> createState() => _DataentryPageState();
}

class _DataentryPageState extends State<DataentryPage> {
  String selectedCropType = 'Maize';
  String selectedClimate = 'Tropical';
  DateTime? plantingDate;
  double? soilPh;
  double? temperature;

  final List<String> climates = ['Tropical', 'Temperate', 'Arid', 'Custom'];

  void _submitData() {
    // Handle data submission logic here
    print('Crop Type: $selectedCropType');
    print('Planting Date: $plantingDate');
    print('Soil pH: $soilPh');
    print('Climate: $selectedClimate');
    print('Temperature: $temperature');

    // Display analysis and recommendations
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Analysis Summary',
            style: TextStyle(color: Colors.green),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryItem('Crop Type', selectedCropType),
                _buildSummaryItem(
                  'Planting Date',
                  plantingDate?.toLocal().toString().split(' ')[0] ??
                      "Not provided",
                ),
                _buildSummaryItem(
                  'Soil pH',
                  soilPh?.toString() ?? "Not provided",
                ),
                _buildSummaryItem('Climate', selectedClimate),
                _buildSummaryItem(
                  'Temperature',
                  temperature?.toString() ?? "Not provided",
                ),
                const SizedBox(height: 16),
                const Text(
                  'Recommendations:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                const Text('• Optimize your soil pH between 6.0-6.8 for maize'),
                const Text('• Ensure proper nitrogen fertilization'),
                const Text('• Monitor for common pests like stem borers'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close', style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Maize Data Entry',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFE8F5E9)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Maize Management Data',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Enter details for accurate maize management recommendations. All fields are optional.',
                          style: TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 20),

                        // Disabled Crop Type field (Maize only)
                        AbsorbPointer(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Crop Type',
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: const Icon(
                                Icons.grass,
                                color: Colors.green,
                              ),
                            ),
                            initialValue: 'Maize',
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Planting Date
                        GestureDetector(
                          onTap: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: plantingDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (pickedDate != null) {
                              setState(() => plantingDate = pickedDate);
                            }
                          },
                          child: AbsorbPointer(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Planting Date',
                                filled: true,
                                fillColor: Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: const Icon(
                                  Icons.calendar_today,
                                  color: Colors.green,
                                ),
                              ),
                              controller: TextEditingController(
                                text:
                                    plantingDate?.toLocal().toString().split(
                                      ' ',
                                    )[0] ??
                                    '',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Soil pH
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Soil pH',
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(
                              Icons.terrain,
                              color: Colors.green,
                            ),
                            suffixText: '6.0-6.8 optimal',
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) => soilPh = double.tryParse(value),
                        ),
                        const SizedBox(height: 16),

                        // Climate
                        DropdownButtonFormField<String>(
                          value: selectedClimate,
                          decoration: InputDecoration(
                            labelText: 'Climate of the Region',
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(
                              Icons.wb_sunny,
                              color: Colors.green,
                            ),
                          ),
                          items:
                              climates
                                  .map(
                                    (climate) => DropdownMenuItem(
                                      value: climate,
                                      child: Text(climate),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              (value) =>
                                  setState(() => selectedClimate = value!),
                        ),
                        const SizedBox(height: 16),

                        // Temperature
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Current Temperature (°C)',
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(
                              Icons.thermostat,
                              color: Colors.green,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged:
                              (value) => temperature = double.tryParse(value),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'ANALYZE MAIZE DATA',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
