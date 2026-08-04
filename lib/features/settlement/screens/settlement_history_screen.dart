import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettlementHistoryScreen extends StatelessWidget {
  const SettlementHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('User not found'),
        ),
      );
    }

    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final flatId =
            userSnapshot.data!.data()?['currentFlatId'];

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('flats')
              .doc(flatId)
              .collection('settlements')
              .orderBy(
                'createdAt',
                descending: true,
              )
              .snapshots(),
                        builder: (context, snapshot) {
            return Scaffold(
              appBar: AppBar(
                title: const Text(
                  'Settlement History',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              body: snapshot.hasData
                  ? snapshot.data!.docs.isEmpty
                      ? const Center(
                          child: Text(
                            'No settlement history',
                          ),
                        )
                      : ListView.builder(
                          padding:
                              const EdgeInsets.all(16),
                          itemCount:
                              snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            final data = snapshot
                                .data!.docs[index];

                            final map =
                                data.data()
                                    as Map<String, dynamic>;

                            final from =
                                map['from'] ?? '';

                            final to =
                                map['to'] ?? '';

                            final amount =
                                (map['amount'] as num)
                                    .toDouble();

                            final status =
                                map['status'] ?? '';

                            final date =
                                (map['createdAt']
                                        as Timestamp?)
                                    ?.toDate();

                            final isMe =
                                from == user.uid;

                            return Card(
                              margin:
                                  const EdgeInsets.only(
                                bottom: 14,
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: Icon(
                                    isMe
                                        ? Icons
                                            .arrow_upward
                                        : Icons
                                            .arrow_downward,
                                  ),
                                ),

                                title: Text(
                                  isMe
                                      ? 'You paid'
                                      : 'You received',
                                  style:
                                      const TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),

                                subtitle: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    Text(
                                      '₹${amount.toStringAsFixed(2)}',
                                    ),
                                    Text(
                                      status,
                                    ),
                                    if (date != null)
                                      Text(
                                        '${date.day}/${date.month}/${date.year}',
                                      ),
                                  ],
                                ),

                                trailing: Icon(
                                  status == 'paid'
                                      ? Icons.check_circle
                                      : Icons.pending,
                                  color: status == 'paid'
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ),
                            );
                          },
                        )
                  : const Center(
                      child:
                          CircularProgressIndicator(),
                    ),
            );
          },
        );
      },
    );
  }
}