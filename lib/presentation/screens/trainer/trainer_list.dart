import 'package:eatmehv2/presentation/widgets/custom_list.dart';
import 'package:flutter/material.dart';

class TrainerList extends StatefulWidget {
  const TrainerList({super.key});

  @override
  State<TrainerList> createState() => _TrainerListState();
}

class _TrainerListState extends State<TrainerList> {
  final _trainerNameController = TextEditingController();

  @override
  void dispose() {
    _trainerNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          surface: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: Scaffold(
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
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomList(
                    value: "John Doe", // replace
                    actionIcons: [
                      ListActionIcon(
                        icon: Icons.add,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Friend request sent to John Doe'),
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
                      //     builder: (context) => const TraineeList(),
                      //   ),
                      // );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
