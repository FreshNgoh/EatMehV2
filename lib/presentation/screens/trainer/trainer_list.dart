import 'package:eatmehv2/data/services/trainer_profile_service.dart';
import 'package:eatmehv2/presentation/widgets/custom_list.dart';
import 'package:flutter/material.dart';

class TrainerList extends StatefulWidget {
  const TrainerList({super.key});

  @override
  State<TrainerList> createState() => _TrainerListState();
}

class _TrainerListState extends State<TrainerList> {
  final trainerProfileService = TrainerProfileService();
  bool isLoading = true;
  List<Map<String, dynamic>> trainers = [];

  @override
  void initState() {
    super.initState();
    fetchTrainers();
  }

  Future<void> fetchTrainers() async {
    final result = await trainerProfileService.getAllTrainers();
    // print('Trainer profile: $result');
    setState(() {
      trainers = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Trainer List'),
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : trainers.isEmpty
              ? const Center(child: Text("No trainers available"))
              : ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 30,
                ),
                itemCount: trainers.length,
                itemBuilder: (context, index) {
                  final trainer = trainers[index];
                  return CustomList(
                    profile: CircleAvatar(
                      backgroundImage: AssetImage(
                        'assets/images/default_face.jpeg',
                      ),
                    ),
                    value: trainer['name'],
                    actionIcons: [
                      ListActionIcon(
                        icon: Icons.add,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Friend request sent to ${trainer['name']}',
                              ),
                            ),
                          );
                        },
                        tooltip: 'Add Friend',
                      ),
                    ],
                    onFieldTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => TrainerProfile(trainerId: trainer['id']),
                      //   ),
                      // );
                    },
                  );
                },
              ),
    );
  }
}
