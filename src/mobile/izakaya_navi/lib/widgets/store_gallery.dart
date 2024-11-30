import 'package:flutter/material.dart';

class StoreGallery extends StatefulWidget {
  final List<String> images;

  const StoreGallery({
    super.key,
    required this.images,
  });

  @override
  State<StoreGallery> createState() => _StoreGalleryState();
}

class _StoreGalleryState extends State<StoreGallery> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 画像表示エリア
        AspectRatio(
          aspectRatio: 16 / 9,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: widget.images.isEmpty ? 1 : widget.images.length,
            itemBuilder: (context, index) {
              if (widget.images.isEmpty) {
                return Container(
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.restaurant,
                    size: 48,
                    color: Colors.grey,
                  ),
                );
              }
              return Image.network(
                widget.images[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.restaurant,
                      size: 48,
                      color: Colors.grey,
                    ),
                  );
                },
              );
            },
          ),
        ),

        // インジケーター
        if (widget.images.length > 1)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.images.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? Colors.red
                        : Colors.grey.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}