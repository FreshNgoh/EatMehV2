import 'package:eatmehv2/core/localization/app_localizations.dart';
import 'package:eatmehv2/presentation/screens/user/profile_screen.dart';
import 'package:eatmehv2/presentation/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eatmehv2/bloc/auth/auth_bloc.dart';
import 'package:eatmehv2/data/models/user/user_model.dart';
import 'package:eatmehv2/data/repos/user_repo.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final UserRepository _userRepo = UserRepository();

  List<UserModel> _searchResults = [];
  List<UserModel> _friendRequests = [];
  bool _isSearching = false;
  bool _isLoadingRequests = true;

  // ✅ 1. Add a flag to run the load only once
  bool _isInit = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // ⛔️ 2. DO NOT load data here anymore
    // _loadFriendRequests();
  }

  // ✅ 3. Add didChangeDependencies
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This runs after initState and has a valid context
    if (_isInit) {
      _loadFriendRequests();
      _isInit = false; // Set flag to false so it only runs once
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ✅ 4. This function logic is now correct AND called at the right time
  Future<void> _loadFriendRequests() async {
    if (!mounted) return;
    final loc = context.loc;
    final authState = context.read<AuthBloc>().state;

    // The 'try' block now wraps ALL logic.
    try {
      // The 'if' check is INSIDE the 'try' block.
      if (authState is Authenticated) {
        // Path 1: User is authenticated
        final requests = await _userRepo.getFriendRequests(authState.user.uid);
        if (!mounted) return;
        setState(() {
          _friendRequests = requests;
          _isLoadingRequests = false; // <-- Loading stops
        });
      } else {
        // Path 2: User is NOT authenticated, but we still stop loading.
        if (!mounted) return;
        setState(() {
          _friendRequests = []; // No requests
          _isLoadingRequests = false; // <-- Loading stops
        });
      }
    } catch (e) {
      // Path 3: An error happened, stop loading.
      if (!mounted) return;
      setState(() {
        _isLoadingRequests = false; // <-- Loading stops
      });
      final errorMsg = loc.friendsErrorLoadRequests(e.toString());
      showCustomToast(context, errorMsg, type: ToastType.error);
    }
  }

  Future<void> _searchUsers(String query) async {
    if (!mounted) return;
    final loc = context.loc;
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final results = await _userRepo.searchUsers(query.trim());
      if (!mounted) return;
      final authState = context.read<AuthBloc>().state;

      if (authState is Authenticated) {
        // Filter out current user from results
        final filtered =
            results.where((user) => user.uid != authState.user.uid).toList();
        setState(() {
          _searchResults = filtered;
          _isSearching = false;
        });
      } else {
        // Handle no auth
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSearching = false);
      final errorMsg = loc.friendsErrorSearch(e.toString());
      showCustomToast(context, errorMsg, type: ToastType.error);
    }
  }

  Future<void> _acceptFriendRequest(String requesterId) async {
    if (!mounted) return;
    final loc = context.loc;
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return;

    try {
      await _userRepo.acceptFriendRequest(authState.user.uid, requesterId);
      await _loadFriendRequests(); // Reload the list
      if (mounted) {
        final successMsg = loc.friendButtonSuccessAccepted;
        showCustomToast(context, successMsg, type: ToastType.success);
      }
    } catch (e) {
      if (mounted) {
        final errorMsg = loc.friendsErrorAccept(e.toString());
        showCustomToast(context, errorMsg, type: ToastType.error);
      }
    }
  }

  Future<void> _rejectFriendRequest(String requesterId) async {
    if (!mounted) return;
    final loc = context.loc;
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return;

    try {
      await _userRepo.rejectFriendRequest(authState.user.uid, requesterId);
      await _loadFriendRequests(); // Reload the list
      if (mounted) {
        final rejectMsg = loc.friendsRequestRejected;
        showCustomToast(context, rejectMsg, type: ToastType.info);
      }
    } catch (e) {
      if (mounted) {
        final errorMsg = loc.friendsErrorReject(e.toString());
        showCustomToast(context, errorMsg, type: ToastType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leadingWidth: 60,
        title: Text(
          loc.navFriends,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF191919),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF191919),
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          indicatorColor: Colors.green,
          dividerColor: Colors.transparent,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search, size: 20),
                  const SizedBox(width: 8),
                  Text(loc.friendsTabFindFriends,
                      style: const TextStyle(fontSize: 15)),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_add, size: 20),
                  const SizedBox(width: 8),
                  Text(loc.adminNavRequests,
                      style: const TextStyle(fontSize: 15)),
                  // Show badge only if loading is finished and requests exist
                  if (!_isLoadingRequests && _friendRequests.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Center(
                        child: Text(
                          '${_friendRequests.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildSearchTab(), _buildRequestsTab()],
      ),
    );
  }

  Widget _buildSearchTab() {
    final loc = context.loc;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: loc.friendsSearchHint,
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        _searchUsers('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: _searchUsers,
          ),
        ),
        Expanded(
          child: _isSearching
              ? const Center(child: CircularProgressIndicator())
              : _searchResults.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 80,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchController.text.isEmpty
                                ? loc.friendsSearchPrompt
                                : loc.friendsSearchNoResults,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 5, 16, 20),
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final user = _searchResults[index];

                        return ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 8),
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.grey.shade300,
                            backgroundImage:
                                user.imageUrl != null && user.imageUrl!.isNotEmpty
                                    ? NetworkImage(user.imageUrl!)
                                    : null,
                            child:
                                user.imageUrl == null || user.imageUrl!.isEmpty
                                    ? Text(
                                        user.username[0].toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : null,
                          ),
                          title: Text(
                            user.username,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: user.bio != null && user.bio!.isNotEmpty
                              ? Text(
                                  user.bio!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                )
                              : null,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ProfileScreen(userUid: user.uid),
                              ),
                            );
                          },
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildRequestsTab() {
    final loc = context.loc;
    // This is the check that fixes the UI:
    if (_isLoadingRequests) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_friendRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_add_disabled,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              loc.friendsRequestsEmpty,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 5, 16, 20),
      itemCount: _friendRequests.length,
      itemBuilder: (context, index) {
        final user = _friendRequests[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          leading: CircleAvatar(
            radius: 25,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: user.imageUrl != null && user.imageUrl!.isNotEmpty
                ? NetworkImage(user.imageUrl!)
                : null,
            child: (user.imageUrl == null || user.imageUrl!.isEmpty)
                ? Text(
                    user.username[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          title: Text(
            user.username,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          subtitle: user.bio != null && user.bio!.isNotEmpty
              ? Text(
                  user.bio!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                )
              : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _acceptFriendRequest(user.uid),
                icon: const Icon(Icons.check),
                color: Colors.green,
                tooltip: loc.friendButtonLabelConfirm,
              ),
              IconButton(
                onPressed: () => _rejectFriendRequest(user.uid),
                icon: const Icon(Icons.close),
                color: Colors.red,
                tooltip: loc.friendButtonLabelDelete,
              ),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfileScreen(userUid: user.uid),
              ),
            );
          },
        );
      },
    );
  }
}