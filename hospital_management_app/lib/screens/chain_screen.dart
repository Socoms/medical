import 'package:flutter/material.dart';

class ChainScreen extends StatefulWidget {
  const ChainScreen({super.key});

  @override
  State<ChainScreen> createState() => _ChainScreenState();
}

class _ChainScreenState extends State<ChainScreen> {
  final List<String> departments = [
    '내과',
    '외과',
    '정형외과',
    '신경외과',
    '피부과',
    '안과',
    '이비인후과',
    '산부인과',
  ];

  final List<bool> _selectedDepartments = List.generate(8, (index) => false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chain 진료'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '연속 진료 서비스',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '여러 진료과를 연속으로 예약하고 진료받을 수 있는 서비스입니다.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              '진료과 선택',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: departments.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedDepartments[index] = !_selectedDepartments[index];
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: _selectedDepartments[index]
                            ? Colors.purple.shade100
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _selectedDepartments[index]
                              ? Colors.purple
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          departments[index],
                          style: TextStyle(
                            color: _selectedDepartments[index]
                                ? Colors.purple
                                : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  final selectedDepts = departments
                      .where((dept) => _selectedDepartments[departments.indexOf(dept)])
                      .toList();
                  if (selectedDepts.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('진료과를 선택해주세요.'),
                      ),
                    );
                    return;
                  }
                  // TODO: 예약 처리 로직 구현
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('선택한 진료과: ${selectedDepts.join(", ")}'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  '예약하기',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 