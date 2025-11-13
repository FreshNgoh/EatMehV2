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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFriendRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFriendRequests() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return;

    try {
      final requests = await _userRepo.getFriendRequests(authState.user.uid);
      setState(() {
        _friendRequests = requests;
        _isLoadingRequests = false;
      });
    } catch (e) {
      setState(() => _isLoadingRequests = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading friend requests: $e')),
        );
      }
    }
  }

  Future<void> _searchUsers(String query) async {
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
      final authState = context.read<AuthBloc>().state;

      if (authState is Authenticated) {
        // Filter out current user from results
        final filtered =
            results.where((user) => user.uid != authState.user.uid).toList();
        setState(() {
          _searchResults = filtered;
          _isSearching = false;
        });
      }
    } catch (e) {
      setState(() => _isSearching = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Search error: $e')));
      }
    }
  }

  Future<void> _sendFriendRequest(String toUserId) async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return;

    try {
      await _userRepo.sendFriendRequest(authState.user.uid, toUserId);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Friend request sent!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error sending request: $e')));
      }
    }
  }

  Future<void> _acceptFriendRequest(String requesterId) async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return;

    try {
      await _userRepo.acceptFriendRequest(authState.user.uid, requesterId);
      await _loadFriendRequests();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Friend request accepted!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error accepting request: $e')));
      }
    }
  }

  Future<void> _rejectFriendRequest(String requesterId) async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return;

    try {
      await _userRepo.rejectFriendRequest(authState.user.uid, requesterId);
      await _loadFriendRequests();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Friend request rejected')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error rejecting request: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF191919)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Friends',
          style: TextStyle(
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
                children: const [
                  Icon(Icons.search, size: 20),
                  SizedBox(width: 8),
                  Text('Find Friends', style: TextStyle(fontSize: 15)),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_add, size: 20),
                  const SizedBox(width: 8),
                  const Text('Requests', style: TextStyle(fontSize: 15)),
                  if (_friendRequests.isNotEmpty) ...[
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
    final authState = context.watch<AuthBloc>().state;
    final currentUser = authState is Authenticated ? authState.user : null;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by username...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon:
                  _searchController.text.isNotEmpty
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
          child:
              _isSearching
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
                              ? 'Search for friends by username'
                              : 'No users found',
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
                      final isFriend =
                          currentUser?.friends.contains(user.uid) ?? false;
                      final hasRequestPending =
                          currentUser?.friendRequests.contains(user.uid) ??
                          false;

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.grey.shade200,
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
                        subtitle:
                            user.bio != null && user.bio!.isNotEmpty
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
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildRequestsTab() {
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
              'No pending friend requests',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _friendRequests.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final user = _friendRequests[index];
        return Card(
          elevation: 0,
          color: Colors.grey.shade50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage:
                      user.imageUrl != null && user.imageUrl!.isNotEmpty
                          ? NetworkImage(user.imageUrl!)
                          : null,
                  child:
                      user.imageUrl == null || user.imageUrl!.isEmpty
                          ? Text(
                            user.username[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                          : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.username,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      if (user.bio != null && user.bio!.isNotEmpty)
                        Text(
                          user.bio!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => _acceptFriendRequest(user.uid),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF191919),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        minimumSize: const Size(90, 36),
                      ),
                      child: const Text('Accept'),
                    ),
                    const SizedBox(height: 6),
                    OutlinedButton(
                      onPressed: () => _rejectFriendRequest(user.uid),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        minimumSize: const Size(90, 36),
                      ),
                      child: const Text('Reject'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
