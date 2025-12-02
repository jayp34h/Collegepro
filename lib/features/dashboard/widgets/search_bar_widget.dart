import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/project_provider.dart';

class SearchBarWidget extends StatefulWidget {
  final VoidCallback onFilterTap;

  const SearchBarWidget({
    super.key,
    required this.onFilterTap,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
    _searchController.text = projectProvider.searchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search projects...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          Provider.of<ProjectProvider>(context, listen: false)
                              .setSearchQuery('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                Provider.of<ProjectProvider>(context, listen: false)
                    .setSearchQuery(value);
                setState(() {});
              },
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: widget.onFilterTap,
            icon: const Icon(Icons.tune),
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
