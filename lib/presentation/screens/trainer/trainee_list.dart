import 'package:eatmehv2/presentation/widgets/custom_list.dart';
import 'package:flutter/material.dart';

class TraineeList extends StatefulWidget {
  const TraineeList({super.key});

  @override
  State<TraineeList> createState() => _TraineeListState();
}

class _TraineeListState extends State<TraineeList> {
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
              // Navigator.pop(context);
            },
          ),
          title: const Text('Trainee List'),
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
                    value: "Trainee Name", // replace
                    actionIcons: [
                      ListActionIcon(
                        icon: Icons.track_changes,
                        onPressed: () {},
                        tooltip: 'View Goals',
                      ),
                      ListActionIcon(
                        icon: Icons.wechat,
                        onPressed: () {},
                        tooltip: 'Message trainee',
                      ),
                      ListActionIcon(
                        icon: Icons.restaurant_menu,
                        onPressed: () {},
                        tooltip: 'Custom Meal',
                      ),
                    ],
                    onFieldTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => const TraineeProfileScreen(),
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
