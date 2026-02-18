import 'package:flutter/material.dart';
import '../../../data_layer/Protocol/Plugin/BasePluginProtocol.dart';
import 'package:ice_shield/data_layer/Protocol/Home/PluginProtocol.dart';

class CarTrackerPlugin extends BasePluginProtocol {
  const CarTrackerPlugin()
    : super(
        name: 'Car Tracker',
        description: 'Track your car location, fuel, and maintenance',
        icon: Icons.directions_car,
        protocol: 'https',
        host: 'cartracker.example.com',
        url: '/dashboard',
        imageUrl: null,
        category: PluginCategory.tracking,
        tags: const ['car', 'vehicle', 'gps', 'maintenance'],
        requiresAuth: false,
      );
}
