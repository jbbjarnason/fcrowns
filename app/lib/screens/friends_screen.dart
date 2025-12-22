import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(friendsProvider).loadFriends();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.beamToNamed('/games'),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Friends'),
            Tab(text: 'Requests'),
            Tab(text: 'Search'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFriendsList(),
          _buildRequestsList(),
          _buildSearch(),
        ],
      ),
    );
  }

  Widget _buildFriendsList() {
    final friends = ref.watch(friendsProvider);

    if (friends.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (friends.friends.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No friends yet', style: TextStyle(color: Colors.grey)),
            SizedBox(height: 8),
            Text('Search for users to add friends', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => friends.loadFriends(),
      child: ListView.builder(
        itemCount: friends.friends.length,
        itemBuilder: (context, index) {
          final friend = friends.friends[index];
          return ListTile(
            leading: CircleAvatar(
              child: Text((friend['username'] as String? ?? '?')[0].toUpperCase()),
            ),
            title: Text(friend['displayName'] as String? ?? friend['username'] as String? ?? 'Unknown'),
            subtitle: Text('@${friend['username'] ?? ''}'),
            trailing: PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'remove') {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Remove Friend'),
                      content: Text('Remove ${friend['displayName']} from your friends?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Remove'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    await friends.removeFriend(friend['id'] as String);
                  }
                } else if (value == 'block') {
                  await friends.blockUser(friend['id'] as String);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'remove', child: Text('Remove Friend')),
                const PopupMenuItem(value: 'block', child: Text('Block User')),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRequestsList() {
    final friends = ref.watch(friendsProvider);
    final incoming = friends.pendingIncoming;
    final outgoing = friends.pendingOutgoing;

    if (incoming.isEmpty && outgoing.isEmpty) {
      return const Center(
        child: Text('No pending requests', style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView(
      children: [
        if (incoming.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Incoming Requests', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ...incoming.map((request) => ListTile(
            leading: CircleAvatar(
              child: Text((request['username'] as String? ?? '?')[0].toUpperCase()),
            ),
            title: Text(request['displayName'] as String? ?? request['username'] as String? ?? 'Unknown'),
            subtitle: Text('@${request['username'] ?? ''}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () => friends.acceptFriendRequest(request['id'] as String),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => friends.declineFriendRequest(request['id'] as String),
                ),
              ],
            ),
          )),
        ],
        if (outgoing.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Sent Requests', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ...outgoing.map((request) => ListTile(
            leading: CircleAvatar(
              child: Text((request['username'] as String? ?? '?')[0].toUpperCase()),
            ),
            title: Text(request['displayName'] as String? ?? request['username'] as String? ?? 'Unknown'),
            subtitle: Text('@${request['username'] ?? ''} - Pending'),
          )),
        ],
      ],
    );
  }

  Widget _buildSearch() {
    final friends = ref.watch(friendsProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by username',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        friends.clearSearch();
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              friends.searchUsers(value);
            },
          ),
        ),
        Expanded(
          child: Builder(
            builder: (context) {
              if (friends.searchResults.isEmpty) {
                return const Center(
                  child: Text('Enter a username to search', style: TextStyle(color: Colors.grey)),
                );
              }

              return ListView.builder(
                itemCount: friends.searchResults.length,
                itemBuilder: (context, index) {
                  final user = friends.searchResults[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text((user['username'] as String? ?? '?')[0].toUpperCase()),
                    ),
                    title: Text(user['displayName'] as String? ?? user['username'] as String? ?? 'Unknown'),
                    subtitle: Text('@${user['username'] ?? ''}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.person_add),
                      onPressed: () async {
                        final success = await friends.sendFriendRequest(user['id'] as String);
                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Friend request sent')),
                          );
                        }
                      },
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
}
