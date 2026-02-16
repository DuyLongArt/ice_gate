import 'package:flutter/material.dart';

class ExternalWidgetImage extends StatelessWidget {
  
  // 1. Field Declaration: Must be final in a StatelessWidget
  final String fullImageUrl;

  // 2. Corrected Constructor: 
  //    The 'required this.fullImageUrl' syntax automatically initializes the field,
  //    so the initializer list must be removed.
  const ExternalWidgetImage({
    super.key,
    required this.fullImageUrl, 
  });
String getFaviconUrl(String host) {
  // Use the host field from your widget (e.g., 'www.youtube.com')
  return 'https://www.google.com/s2/favicons?domain=$host&sz=64'; 
  // '&sz=64' requests the size (e.g., 64x64 pixels)
}
  @override
  Widget build(BuildContext context) {
    return Image.network(
      getFaviconUrl(fullImageUrl),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(child: CircularProgressIndicator());
      },
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.broken_image, size: 50, color: Colors.grey);
      },
      fit: BoxFit.cover,
    );
  }
}