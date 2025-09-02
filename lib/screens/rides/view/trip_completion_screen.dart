import 'package:flutter/material.dart';

class TripCompletionScreen extends StatefulWidget {
  final String riderName;
  final String? riderImageUrl;
  final String distance;
  final String time;
  final String fare;
  final VoidCallback onComplete;

  const TripCompletionScreen({
    super.key,
    required this.riderName,
    this.riderImageUrl,
    required this.distance,
    required this.time,
    required this.fare,
    required this.onComplete,
  });

  @override
  State<TripCompletionScreen> createState() => _TripCompletionScreenState();
}

class _TripCompletionScreenState extends State<TripCompletionScreen> {
  int _rating = 0;
  final TextEditingController _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _submit() {
    // For demo, just call onComplete
    widget.onComplete();
  }

  void _skip() {
    widget.onComplete();
  }

  void _simulateRating() {
    setState(() {
      _rating = 5;
      _feedbackController.text = 'Great rider!';
    });
    Future.delayed(const Duration(milliseconds: 500), _submit);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Trip Complete', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Trip summary
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            const Icon(Icons.route, color: Colors.blue, size: 28),
                            const SizedBox(height: 4),
                            Text(widget.distance, style: const TextStyle(fontWeight: FontWeight.bold)),
                            const Text('Distance', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                        Column(
                          children: [
                            const Icon(Icons.timer, color: Colors.green, size: 28),
                            const SizedBox(height: 4),
                            Text(widget.time, style: const TextStyle(fontWeight: FontWeight.bold)),
                            const Text('Time', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                        Column(
                          children: [
                            const Icon(Icons.attach_money, color: Colors.amber, size: 28),
                            const SizedBox(height: 4),
                            Text(widget.fare, style: const TextStyle(fontWeight: FontWeight.bold)),
                            const Text('Fare', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Rider avatar and name
                widget.riderImageUrl != null
                    ? CircleAvatar(
                        radius: 36,
                        backgroundImage: NetworkImage(widget.riderImageUrl!),
                      )
                    : const CircleAvatar(
                        radius: 36,
                        backgroundColor: Color(0xFFE0E0E0),
                        child: Icon(Icons.person, color: Colors.black54, size: 38),
                      ),
                const SizedBox(height: 12),
                Text(
                  widget.riderName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 24),
                // Rating stars
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    return IconButton(
                      icon: Icon(
                        i < _rating ? Icons.star : Icons.star_border,
                        color: Colors.amber[700],
                        size: 32,
                      ),
                      onPressed: () => setState(() => _rating = i + 1),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                // Feedback field
                TextField(
                  controller: _feedbackController,
                  minLines: 1,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Leave feedback (optional)',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Submit',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _skip,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Skip',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Center(
                  child: TextButton(
                    onPressed: _simulateRating,
                    child: const Text(
                      'Simulate Rating Submission',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
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