import 'dart:typed_data';
import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final Uint8List? generatedImage;
  final Map<String, dynamic>? recommendationJson;

  final int tripDuration;
  final int travelBudget;
  final int participants;
  final String destination;
  final String travelType;

  const ResultScreen({
    super.key,
    required this.generatedImage,
    required this.recommendationJson,
    required this.tripDuration,
    required this.travelBudget,
    required this.participants,
    required this.destination,
    required this.travelType,
  });

  @override
  Widget build(BuildContext context) {
    final activities =
        (recommendationJson?['recommendedActivities'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList();

    final tips = (recommendationJson?['travelTips'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Plan Result'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTripSummaryCard(),
            const SizedBox(height: 20),

            if (generatedImage != null) ...[
              const Text(
                'Generated Travel Poster',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.memory(
                  generatedImage!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
            ],

            const Text(
              'Personalised Travel Recommendation',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: recommendationJson == null
                    ? const Text(
                        'No recommendation available.',
                        style: TextStyle(fontSize: 15),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recommendationJson!['title']?.toString() ??
                                'No Title',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            recommendationJson!['summary']?.toString() ?? '-',
                            style: const TextStyle(fontSize: 15, height: 1.5),
                          ),
                          const SizedBox(height: 16),

                          _buildInfoRow(
                            'Suggested Accommodation',
                            recommendationJson!['suggestedAccommodation']
                                    ?.toString() ??
                                '-',
                          ),
                          _buildInfoRow(
                            'Estimated Daily Budget',
                            recommendationJson!['estimatedDailyBudget']
                                    ?.toString() ??
                                '-',
                          ),
                          _buildInfoRow(
                            'Best Time to Visit',
                            recommendationJson!['bestTimeToVisit']?.toString() ??
                                '-',
                          ),

                          const SizedBox(height: 16),
                          const Text(
                            'Recommended Activities',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (activities.isEmpty)
                            const Text('-')
                          else
                            ...activities.map(
                              (activity) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  '• $activity',
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                            ),

                          const SizedBox(height: 16),
                          const Text(
                            'Travel Tips',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (tips.isEmpty)
                            const Text('-')
                          else
                            ...tips.map(
                              (tip) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  '• $tip',
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                            ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Planner'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripSummaryCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Travel Plan Summary',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Trip Duration', '$tripDuration day(s)'),
            _buildInfoRow('Travel Budget', 'RM $travelBudget'),
            _buildInfoRow('Number of Participants', '$participants'),
            _buildInfoRow('Destination', destination),
            _buildInfoRow('Type of Travel', travelType),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black,
            height: 1.4,
          ),
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
}