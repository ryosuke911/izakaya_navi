import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/venue.dart';
import '../api/places_api.dart';

class StoreCard extends StatefulWidget {
  final Venue venue;
  final VoidCallback onTap;

  const StoreCard({
    super.key,
    required this.venue,
    required this.onTap,
  });

  @override
  State<StoreCard> createState() => _StoreCardState();
}

class _StoreCardState extends State<StoreCard> {
  final PlacesApi _placesApi = PlacesApi();
  Future<Uint8List>? _photoFuture;

  @override
  void initState() {
    super.initState();
    _loadPhoto();
  }

  void _loadPhoto() {
    if (widget.venue.photos != null && widget.venue.photos!.isNotEmpty) {
      _photoFuture = _placesApi.getPlacePhoto(widget.venue.photos!.first.photoReference);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // 店舗画像
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _photoFuture != null
                      ? FutureBuilder<Uint8List>(
                          future: _photoFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            }

                            if (snapshot.hasError || !snapshot.hasData) {
                              return Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Icon(
                                    Icons.restaurant,
                                    color: Colors.grey,
                                    size: 32,
                                  ),
                                ),
                              );
                            }

                            return Image.memory(
                              snapshot.data!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: Icon(
                                      Icons.restaurant,
                                      color: Colors.grey,
                                      size: 32,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(
                              Icons.restaurant,
                              color: Colors.grey,
                              size: 32,
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              
              // 店舗情報
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 店舗名と評価
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.venue.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (widget.venue.rating != null) ...[
                          const SizedBox(width: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 18,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                widget.venue.rating.toString(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // カテゴリタグ
                    if (widget.venue.types.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: widget.venue.types.map((category) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              category,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
              
              // 矢印アイコン
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}