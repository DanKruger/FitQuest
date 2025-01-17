import 'dart:async';

import 'package:fitquest/presentation/viewmodels/social_viewmodel.dart';
import 'package:fitquest/presentation/widgets/neumorphic_widgets.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = []; // Mock search results
  Timer? _debounce;

  void _onSearchChanged(SocialViewmodel viewModel) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final query = _searchController.text;
      if (query.isNotEmpty) {
        viewModel.isSearching = true; // Trigger UI updates if needed
        List<Map<String, dynamic>>? results = await viewModel.searchUsers(
          query,
        );
        setState(() {
          _searchResults = results!;
        });
        viewModel.isSearching = false;
      } else {
        setState(() {
          _searchResults = [];
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchMock(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
      });
      return;
    }

    // Mock delay to simulate search, replace this with a call to your ViewModel
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _searchResults.clear();
      _searchResults.addAll([
        {'name': 'John Doe', 'email': 'johndoe@example.com'},
        {'name': 'Jane Smith', 'email': 'janesmith@example.com'},
        {'name': 'Alice Johnson', 'email': 'alicej@example.com'},
      ].where(
          (user) => user['name']!.toLowerCase().contains(query.toLowerCase())));
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    return Consumer<SocialViewmodel>(
      builder: (context, viewmodel, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Add Friends'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: neumorphicBoxDecoration(999, theme),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      enabled: viewmodel.isConnected,
                      controller: _searchController,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12), // Adjust vertical padding
                        alignLabelWithHint: true,
                        hintText: viewmodel.isConnected
                            ? 'Search by name or email'
                            : 'You need to be online to search',
                        hintStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: viewmodel.isConnected
                            ? Icon(
                                Icons.search,
                                color: theme.primary,
                              )
                            : const Icon(Icons.wifi_off),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: theme.error,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchMock('');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                      ),
                      onChanged: (query) => _onSearchChanged(viewmodel),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (viewmodel.isSearching)
                  Center(
                    child: LoadingAnimationWidget.stretchedDots(
                      color: theme.primary,
                      size: 50,
                    ),
                  )
                else if (_searchResults.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final user = _searchResults[index];
                        return ListTile(
                          title: Text(
                            user['first_name'] ?? "name",
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          subtitle: Text(
                            user['email_address'] ?? "email",
                            overflow: TextOverflow.fade,
                            softWrap: true,
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: IconButton(
                            onPressed: () {
                              _handleFriendRequest(viewmodel, user, context);
                            },
                            icon: const Icon(Icons.add_rounded),
                          ),
                        );
                      },
                    ),
                  )
                else
                  const Center(
                    child: Text(
                      'No results found.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleFriendRequest(
    SocialViewmodel viewmodel,
    Map<String, dynamic> user,
    BuildContext context,
  ) async {
    await viewmodel.sendFriendRequest(user['user_id']);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Request sent to ${user['first_name'] ?? "name"}')),
    );
  }
}
