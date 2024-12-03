import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../api/places_api.dart';
import '../models/venue.dart';

class StoreGallery extends StatefulWidget {
  final List<Photo> photos;

  const StoreGallery({
    super.key,
    required this.photos,
  });

  @override
  State<StoreGallery> createState() => _StoreGalleryState();
}

class _StoreGalleryState extends State<StoreGallery> {
  final PageController _pageController = PageController();
  final PlacesApi _placesApi = PlacesApi();
  final Map<String, Future<Image>> _photoCache = {};
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    for (final photo in widget.photos) {
      if (!_photoCache.containsKey(photo.photoReference)) {
        _photoCache[photo.photoReference] = _loadPhoto(photo.photoReference);
      }
    }
  }

  Future<Image> _loadPhoto(String photoReference) async {
    try {
      final bytes = await _placesApi.getPlacePhoto(photoReference);
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[200],
            child: const Center(
              child: Icon(
                Icons.restaurant,
                color: Colors.grey,
                size: 48,
              ),
            ),
          );
        },
      );
    } catch (e) {
      print('Error loading photo: $e');
      return Image.memory(
        Uint8List(0),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[200],
            child: const Center(
              child: Icon(
                Icons.restaurant,
                color: Colors.grey,
                size: 48,
              ),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 写真のページビュー
        PageView.builder(
          controller: _pageController,
          itemCount: widget.photos.length,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          itemBuilder: (context, index) {
            final photo = widget.photos[index];
            return FutureBuilder<Image>(
              future: _photoCache[photo.photoReference],
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                
                if (snapshot.hasError || !snapshot.hasData) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(
                        Icons.restaurant,
                        color: Colors.grey,
                        size: 48,
                      ),
                    ),
                  );
                }

                return snapshot.data!;
              },
            );
          },
        ),

        // ページインジケーター
        if (widget.photos.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.photos.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}