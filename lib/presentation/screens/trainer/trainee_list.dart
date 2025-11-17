import 'package:eatmehv2/bloc/auth/auth_bloc.dart';
import 'package:eatmehv2/data/repos/trainer_profile_repo.dart';
import 'package:eatmehv2/data/services/trainer_profile_service.dart';
import 'package:eatmehv2/presentation/widgets/trainee_chat_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TraineeList extends StatefulWidget {
  const TraineeList({super.key});

  @override
  State<TraineeList> createState() => _TraineeListState();
}

class _TraineeListState extends State<TraineeList> {
  final trainerProfileRepo = TrainerProfileRepo(TrainerProfileService());
  final TextEditingController _searchController = TextEditingController();

  bool _loading = true;
  String? currentUserUid;
  String _searchQuery = '';
  List<String> _traineeUids = [];

  @override
  void initState() {
    super.initState();
    _initTrainerData();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  Future<void> _initTrainerData() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return;

    currentUserUid = authState.user.uid;

    final trainerProfile = await trainerProfileRepo.getTrainerProfile(
      currentUserUid!,
    );

    if (trainerProfile != null && trainerProfile.trainees.isNotEmpty) {
      setState(() {
        _traineeUids = trainerProfile.trainees;
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search trainees...',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 15,
                    ),
                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                    suffixIcon:
                        _searchQuery.isNotEmpty
                            ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: Colors.grey.shade600,
                              ),
                              onPressed: () => _searchController.clear(),
                            )
                            : null,
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF191919),
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Trainee list
          Expanded(
            child:
                _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _traineeUids.isEmpty
                    ? _buildEmptyState()
                    : StreamBuilder<List<Map<String, dynamic>>>(
                      stream: trainerProfileRepo.getTraineesDetailsStream(
                        _traineeUids,
                        currentUserUid!,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return _buildEmptyState();
                        }

                        var trainees = snapshot.data!;

                        // Sort by latest message
                        trainees.sort((a, b) {
                          final timeA =
                              a['lastUpdated']?.toDate() ??
                              DateTime.fromMillisecondsSinceEpoch(0);
                          final timeB =
                              b['lastUpdated']?.toDate() ??
                              DateTime.fromMillisecondsSinceEpoch(0);
                          return timeB.compareTo(timeA);
                        });

                        // Apply search filter
                        final filtered =
                            _searchQuery.isEmpty
                                ? trainees
                                : trainees
                                    .where(
                                      (t) => t['name']
                                          .toString()
                                          .toLowerCase()
                                          .contains(_searchQuery),
                                    )
                                    .toList();

                        if (filtered.isEmpty) return _buildNoResultsState();

                        return RefreshIndicator(
                          onRefresh: _initTrainerData,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            itemCount: filtered.length,
                            separatorBuilder:
                                (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final trainee = filtered[index];
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: TraineeChatPreview(
                                  currentUserUid: currentUserUid!,
                                  traineeUid: trainee['uid'],
                                  traineeName: trainee['name'],
                                  traineeImage: trainee['image'],
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No trainees yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start accepting trainee requests\nto see them here',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No trainees found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching with a different name',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => _searchController.clear(),
            icon: const Icon(Icons.clear),
            label: const Text('Clear search'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF191919),
            ),
          ),
        ],
      ),
    );
  }
}
