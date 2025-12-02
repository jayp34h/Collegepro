import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/providers/hackathon_provider.dart';
import '../../core/models/hackathon_model.dart';

class HackathonScreen extends StatefulWidget {
  const HackathonScreen({super.key});

  @override
  State<HackathonScreen> createState() => _HackathonScreenState();
}

class _HackathonScreenState extends State<HackathonScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HackathonProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: Consumer<HackathonProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.hackathons.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.purple),
                  const SizedBox(height: 16),
                  const Text('Loading Hackathons...'),
                  const SizedBox(height: 8),
                  Text('Loading your specified hackathons from Firebase', 
                       style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.refreshData(),
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(child: _buildHeader()),
                
                // Stats
                SliverToBoxAdapter(child: _buildStats(provider)),
                
                // Search & Filters
                SliverToBoxAdapter(child: _buildSearchAndFilters(provider)),
                
                // Hackathons List
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: provider.filteredHackathons.isEmpty
                      ? SliverFillRemaining(child: _buildEmptyState())
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => _buildHackathonCard(
                              provider.filteredHackathons[index],
                            ),
                            childCount: provider.filteredHackathons.length,
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2E5BBA), Color(0xFF6B46C1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emoji_events, color: Colors.white, size: 24),
          SizedBox(width: 12),
          Text(
            'Hackathons 2025',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () => context.read<HackathonProvider>().refreshData(),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E5BBA), Color(0xFF6B46C1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.emoji_events, color: Colors.white, size: 32),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Hackathons 2025',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Latest hackathons and coding challenges',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          Chip(
            label: Text('Live', style: TextStyle(color: Colors.white, fontSize: 12)),
            backgroundColor: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildStats(HackathonProvider provider) {
    final stats = provider.stats;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: _buildStatCard('Total', '${stats['total']}', Icons.emoji_events, Colors.purple)),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard('Active', '${stats['active']}', Icons.play_circle, Colors.green)),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard('Upcoming', '${stats['upcoming']}', Icons.schedule, Colors.blue)),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard('Open', '${stats['registrationOpen']}', Icons.how_to_reg, Colors.orange)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(HackathonProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: provider.searchHackathons,
              decoration: InputDecoration(
                hintText: 'Search hackathons...',
                prefixIcon: const Icon(Icons.search, color: Colors.purple),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          provider.searchHackathons('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Categories
          const Text('Categories', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: provider.categories.length,
              itemBuilder: (context, index) {
                final category = provider.categories[index];
                final isSelected = provider.selectedCategory == category;
                
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (_) => provider.filterByCategory(category),
                    selectedColor: Colors.purple.withOpacity(0.2),
                    checkmarkColor: Colors.purple,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHackathonCard(HackathonModel hackathon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple.withOpacity(0.2), Colors.blue.withOpacity(0.2)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.emoji_events, color: Colors.purple, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hackathon.title,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'by ${hackathon.organizer}',
                        style: TextStyle(color: Colors.purple[600], fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(hackathon.status),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Description
            if (hackathon.description.isNotEmpty)
              Text(
                hackathon.description,
                style: TextStyle(color: Colors.grey[600]),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            
            const SizedBox(height: 16),
            
            // Details
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildDetailChip(Icons.location_on, hackathon.displayLocation, Colors.blue),
                _buildDetailChip(Icons.emoji_events, hackathon.displayPrize, Colors.green),
                if (hackathon.timeRemaining.isNotEmpty)
                  _buildDetailChip(Icons.schedule, hackathon.timeRemaining, Colors.red),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Tags
            if (hackathon.tags.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: hackathon.tags.take(4).map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                    ),
                  );
                }).toList(),
              ),
            
            const SizedBox(height: 20),
            
            // Register Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: hackathon.isValidUrl ? () => _launchUrl(hackathon.registrationUrl) : null,
                icon: const Icon(Icons.open_in_new),
                label: Text(hackathon.isRegistrationOpen ? 'Register Now' : 'View Details'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.orange;
    switch (status.toLowerCase()) {
      case 'active':
        color = Colors.green;
        break;
      case 'upcoming':
        color = Colors.blue;
        break;
      case 'registration closed':
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('No Hackathons Found', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[700])),
          const SizedBox(height: 8),
          Text('Try adjusting your search or filters', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<HackathonProvider>().clearFilters();
              _searchController.clear();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reset Filters'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open the registration link')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error opening registration link')),
        );
      }
    }
  }
}
