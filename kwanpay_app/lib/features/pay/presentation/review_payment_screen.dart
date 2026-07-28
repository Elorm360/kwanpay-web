import 'package:flutter/material.dart';

class ReviewPaymentScreen extends StatelessWidget {
  const ReviewPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Review Payment"),
        centerTitle: true,
      ),

      body: ListView(
        padding: const EdgeInsets.all(24),

        children: [

          const Text(
            "Please review your payment before confirming.",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 28),

          _infoTile("Recipient", "Savannah Trails"),
          _infoTile("Service", "Safari Circuit"),
          _infoTile("Amount", "USD 300"),
          _infoTile("Exchange Rate", "1 USD = GHS 15.20"),
          _infoTile("Network Fee", "GHS 4.50"),

          const Divider(height: 40),

          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              Text(
                "Total",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                "GHS 4,564.50",
                style: TextStyle(
                  fontSize: 22,
                  color: Color(0xFFFF8A00),
                  fontWeight: FontWeight.bold,
                ),
              ),

            ],
          ),

          const SizedBox(height: 40),

          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: () {

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Payment processing coming in Sprint 8"),
                  ),
                );

              },

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8A00),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),

              child: const Text(
                "Confirm Payment",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }

  Widget _infoTile(String title, String value) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [

          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade700,
            ),
          ),

          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),

        ],
      ),
    );
  }
}

