import 'package:flutter/material.dart';

import '../models/operator_model.dart';

class OperatorCard extends StatelessWidget {
  final OperatorModel operatorModel;

  const OperatorCard({
    super.key,
    required this.operatorModel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: const Color(0xFFEDEDED),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.image_outlined,
                size: 45,
                color: Colors.grey,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  operatorModel.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  operatorModel.category,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 18,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(operatorModel.location),
                    ),
                    const Icon(
                      Icons.star,
                      size: 18,
                      color: Colors.amber,
                    ),
                    Text(
                      operatorModel.rating.toString(),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text("View Details"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

