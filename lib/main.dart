import 'dart:typed_data';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'services/image_generation_service.dart';
import 'services/travel_recommendation_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Travel Planner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const TravelPlanScreen(),
    );
  }
}

class TravelPlanScreen extends StatefulWidget {
  const TravelPlanScreen({super.key});

  @override
  State<TravelPlanScreen> createState() => _TravelPlanScreenState();
}

class _TravelPlanScreenState extends State<TravelPlanScreen> {
  double tripDuration = 3;
  double travelBudget = 1000;
  double participants = 1;

  final TextEditingController destinationController = TextEditingController();

  String? selectedTravelType;
  final List<String> travelTypes = ['Budget', 'Mid-Range', 'Luxury'];

  bool isLoading = false;
  Uint8List? generatedImage;
  Map<String, dynamic>? recommendationJson;

  @override
  void dispose() {
    destinationController.dispose();
    super.dispose();
  }

  String _buildImagePrompt() {
    final destination = destinationController.text.trim();

    return '''
Create a beautiful travel destination poster for a ${tripDuration.toInt()}-day ${selectedTravelType!.toLowerCase()} trip to $destination for ${participants.toInt()} participant(s) with a budget of RM ${travelBudget.toInt()}.
Make it visually appealing, vibrant, cinematic, professional, and suitable as a travel advertisement poster.
''';
  }

  Future<void> _generateTravelPlan() async {
    final destination = destinationController.text.trim();

    if (destination.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your destination of choice.'),
        ),
      );
      return;
    }

    if (selectedTravelType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a type of travel.'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
      generatedImage = null;
      recommendationJson = null;
    });

    try {
      final imagePrompt = _buildImagePrompt();

      final imageBytes = await ImageGenerationService.generateImage(imagePrompt);

      final recommendation =
          await TravelRecommendationService.generateRecommendation(
        tripDuration: tripDuration.toInt(),
        travelBudget: travelBudget.toInt(),
        participants: participants.toInt(),
        destination: destination,
        travelType: selectedTravelType!,
      );

      setState(() {
        generatedImage = imageBytes;
        recommendationJson = recommendation;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildValueText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        color: Colors.blueAccent,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildGeneratedImageSection() {
    if (generatedImage == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text(
          'Generated Travel Poster',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.memory(
            generatedImage!,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationSection() {
    if (recommendationJson == null) {
      return const SizedBox.shrink();
    }

    final activities =
        (recommendationJson!['recommendedActivities'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList();

    final tips = (recommendationJson!['travelTips'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text(
          'Personalised Travel Recommendation',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recommendationJson!['title']?.toString() ?? 'No Title',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  recommendationJson!['summary']?.toString() ?? '',
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 16),
                Text(
                  'Suggested Accommodation: ${recommendationJson!['suggestedAccommodation'] ?? '-'}',
                ),
                const SizedBox(height: 8),
                Text(
                  'Estimated Daily Budget: ${recommendationJson!['estimatedDailyBudget'] ?? '-'}',
                ),
                const SizedBox(height: 8),
                Text(
                  'Best Time to Visit: ${recommendationJson!['bestTimeToVisit'] ?? '-'}',
                ),
                const SizedBox(height: 16),
                const Text(
                  'Recommended Activities',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...activities.map(
                  (activity) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text('• $activity'),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Travel Tips',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...tips.map(
                  (tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text('• $tip'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingSection() {
    if (!isLoading) {
      return const SizedBox.shrink();
    }

    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Generating travel poster and recommendation...'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Planner'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Plan Your Ideal Travel Experience',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Adjust the travel parameters below to customise your trip.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 24),

                _buildSectionTitle('1. Trip Duration (days)'),
                _buildValueText('${tripDuration.toInt()} days'),
                Slider(
                  value: tripDuration,
                  min: 1,
                  max: 30,
                  divisions: 29,
                  label: tripDuration.toInt().toString(),
                  onChanged: (value) {
                    setState(() {
                      tripDuration = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                _buildSectionTitle('2. Travel Budget (RM)'),
                _buildValueText('RM ${travelBudget.toInt()}'),
                Slider(
                  value: travelBudget,
                  min: 100,
                  max: 10000,
                  divisions: 99,
                  label: travelBudget.toInt().toString(),
                  onChanged: (value) {
                    setState(() {
                      travelBudget = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                _buildSectionTitle('3. Number of Participants'),
                _buildValueText('${participants.toInt()} person(s)'),
                Slider(
                  value: participants,
                  min: 1,
                  max: 20,
                  divisions: 19,
                  label: participants.toInt().toString(),
                  onChanged: (value) {
                    setState(() {
                      participants = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                _buildSectionTitle('4. Destination of Choice'),
                TextField(
                  controller: destinationController,
                  decoration: InputDecoration(
                    hintText: 'Enter destination (e.g. Langkawi, Tokyo)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.location_on),
                  ),
                ),
                const SizedBox(height: 16),

                _buildSectionTitle('5. Type of Travel'),
                DropdownButtonFormField<String>(
                  value: selectedTravelType,
                  items: travelTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedTravelType = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Select travel type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.card_travel),
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _generateTravelPlan,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Generate Travel Plan',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),

                _buildLoadingSection(),
                _buildGeneratedImageSection(),
                _buildRecommendationSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}