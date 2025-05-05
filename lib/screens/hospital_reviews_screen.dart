import 'package:flutter/material.dart';

class HospitalReviewsScreen extends StatelessWidget {
  const HospitalReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Hospital Reviews',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        color: Colors.grey.shade100,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildReviewCard(
              'Seoul National University Hospital',
              'Dr. Kim',
              'General Check-up',
              4.5,
              'The doctor was very professional and thorough. The waiting time was reasonable and the staff was friendly.',
              'March 15, 2024',
            ),
            const SizedBox(height: 16),
            _buildReviewCard(
              'Asan Medical Center',
              'Dr. Lee',
              'Dental Consultation',
              5.0,
              'Excellent service! The dental clinic was clean and modern. Dr. Lee explained everything clearly.',
              'March 10, 2024',
            ),
            const SizedBox(height: 16),
            _buildReviewCard(
              'Samsung Medical Center',
              'Dr. Park',
              'Eye Examination',
              4.0,
              'Good experience overall. The equipment was state-of-the-art, but the waiting time was a bit long.',
              'March 5, 2024',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 새 리뷰 작성 로직
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildReviewCard(
    String hospitalName,
    String doctorName,
    String serviceType,
    double rating,
    String reviewText,
    String date,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    hospitalName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
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
                      rating.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '$doctorName - $serviceType',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Text(
              reviewText,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Text(
              date,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 