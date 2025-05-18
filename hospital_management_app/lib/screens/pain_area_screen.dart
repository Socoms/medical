import 'package:flutter/material.dart';

class PainAreaScreen extends StatefulWidget {
  const PainAreaScreen({super.key});

  @override
  State<PainAreaScreen> createState() => _PainAreaScreenState();
}

class _PainAreaScreenState extends State<PainAreaScreen> {
  String? selectedBodyPart;
  String? selectedDetailPart;
  bool showDetails = true;
  
  final Map<String, List<String>> bodyPartDetails = {
    'Head': [
      'Forehead',
      'Temple',
      'Back of head',
      'Whole head',
      'Eye area',
      'Ear area',
      'Jaw',
      'Face',
    ],
    'Chest': [
      'Upper chest',
      'Lower chest',
      'Left chest',
      'Right chest',
      'Center chest',
      'Heart area',
      'Breast area',
    ],
    'Stomach': [
      'Upper abdomen',
      'Lower abdomen',
      'Left side',
      'Right side',
      'Navel area',
      'Whole stomach',
    ],
    'Back': [
      'Upper back',
      'Middle back',
      'Lower back',
      'Left shoulder blade',
      'Right shoulder blade',
      'Spine area',
    ],
    'Arms': [
      'Shoulder',
      'Upper arm',
      'Elbow',
      'Forearm',
      'Wrist',
      'Hand',
      'Fingers',
    ],
    'Legs': [
      'Hip',
      'Thigh',
      'Knee',
      'Calf',
      'Ankle',
      'Foot',
      'Toes',
    ],
    'Neck': [
      'Front neck',
      'Back neck',
      'Left side',
      'Right side',
      'Throat area',
      'Whole neck',
    ],
    'Others': [
      'Joints',
      'Muscles',
      'Skin',
      'Internal pain',
      'Multiple areas',
      'General body pain',
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pain Area Check',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              childAspectRatio: 1.0,
              padding: const EdgeInsets.all(12),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: [
                _buildBodyPartButton('Head', Icons.psychology_outlined),
                _buildBodyPartButton('Chest', Icons.favorite_border),
                _buildBodyPartButton('Stomach', Icons.favorite_border),
                _buildBodyPartButton('Back', Icons.compare_arrows),
                _buildBodyPartButton('Arms', Icons.back_hand),
                _buildBodyPartButton('Legs', Icons.accessibility_new),
                _buildBodyPartButton('Neck', Icons.chair),
                _buildBodyPartButton('Others', Icons.help_outline),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedBodyPart ?? 'Select a body part',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (selectedBodyPart != null && showDetails) ...[
                  const SizedBox(height: 15),
                  Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.2,
                    ),
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: bodyPartDetails[selectedBodyPart]!.map((detail) {
                          final isSelected = selectedDetailPart == detail;
                          return ChoiceChip(
                            label: Text(detail, style: TextStyle(fontSize: 12)),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                selectedDetailPart = selected ? detail : null;
                              });
                            },
                            backgroundColor: Colors.white,
                            selectedColor: Colors.purple.shade100,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.purple : Colors.black,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: selectedDetailPart != null
                            ? () {
                                // Handle confirmation
                                Navigator.pop(context, {
                                  'bodyPart': selectedBodyPart,
                                  'detailPart': selectedDetailPart,
                                });
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          disabledBackgroundColor: Colors.grey.shade300,
                        ),
                        child: const Text(
                          'Confirm',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyPartButton(String label, IconData icon) {
    final isSelected = selectedBodyPart == label;
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? Colors.purple.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isSelected ? Colors.purple.shade200 : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              if (selectedBodyPart == label) {
                showDetails = !showDetails;
                if (!showDetails) {
                  selectedBodyPart = null;
                  selectedDetailPart = null;
                }
              } else {
                selectedBodyPart = label;
                selectedDetailPart = null;
                showDetails = true;
              }
            });
          },
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected ? Colors.purple : Colors.black,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.purple : Colors.black,
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