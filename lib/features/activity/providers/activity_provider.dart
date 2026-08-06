import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/activity_model.dart';
import '../repository/activity_repository.dart';

final activityRepositoryProvider =
    Provider<ActivityRepository>(
  (ref) => ActivityRepository(
    FirebaseFirestore.instance,
    FirebaseAuth.instance,
  ),
);

final activitiesProvider =
    StreamProvider<List<ActivityModel>>(
  (ref) {
    return ref
        .read(activityRepositoryProvider)
        .watchActivities();
  },
);