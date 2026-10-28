import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../screens/event_detail_screen.dart';
import '../screens/class_detail_screen.dart';
import '../screens/program_detail_screen.dart';
import '../screens/venue_detail_screen.dart';

/// Opens the correct detail screen for [event] based on its [EventModel.listingType].
/// Used by the home-feed cards, which can mix events, classes, programs and venues.
void openListingDetail(BuildContext context, EventModel event) {
  final Widget screen;
  switch (event.listingType) {
    case 'class':
      screen = ClassDetailScreen(event: event);
      break;
    case 'program':
      screen = ProgramDetailScreen(event: event);
      break;
    case 'venue':
      screen = VenueDetailScreen(event: event);
      break;
    default:
      screen = EventDetailScreen(event: event);
  }
  Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
}
