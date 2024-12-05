import 'package:flutter/material.dart';
import '../models/venue.dart';

class StoreGallery extends StatelessWidget {
  final Venue venue;
  
  const StoreGallery({Key? key, required this.venue}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (venue.photos.isEmpty) {
      return _buildPlaceholder();
    }

    return PageView.builder(
      itemCount: venue.photos.length,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              venue.photos[index],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildPlaceholder();
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Icon(
          Icons.restaurant,
          color: Colors.grey,
          size: 48,
        ),
      ),
    );
  }
}