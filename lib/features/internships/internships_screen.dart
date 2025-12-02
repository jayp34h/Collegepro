import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/widgets/gradient_app_bar.dart';
import '../../core/widgets/drawer_screen_wrapper.dart';
import '../../core/providers/internship_provider.dart';
import '../../core/models/internship_model.dart';
import '../../core/services/manual_internship_refresh.dart';
import '../../core/services/internship_verification_service.dart';

class InternshipsScreen extends StatefulWidget {
  const InternshipsScreen({super.key});

  @override
  State<InternshipsScreen> createState() => _InternshipsScreenState();
}

class _InternshipsScreenState extends State<InternshipsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InternshipProvider>().loadInternships();
      // Verify internships data in debug mode
      InternshipVerificationService.verifyInternshipsData();
    });
    
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= 
          _scrollController.position.maxScrollExtent - 200) {
        context.read<InternshipProvider>().loadMoreInternships();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return DrawerScreenWrapper(
      title: 'Internships',
      child: Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF8F9FA),
      appBar: GradientAppBar(
        title: 'Internships',
        titleIcon: Icons.work,
        additionalActions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.refresh_rounded,
                color: Colors.white,
                size: 22,
              ),
              onPressed: () async {
                // Show loading indicator
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Refreshing internships...'),
                    duration: Duration(seconds: 2),
                  ),
                );
                
                // Force refresh with new data
                await ManualInternshipRefresh.refreshAllInternships();
                
                // Refresh provider
                if (mounted) {
                  await context.read<InternshipProvider>().forceRefreshData();
                  // Verify data after refresh
                  await InternshipVerificationService.verifyInternshipsData();
                }
              },
            ),
          ),
        ],
      ),
      body: Consumer<InternshipProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.filteredInternships.isEmpty) {
            return _buildLoadingState();
          }

          if (provider.error != null && provider.filteredInternships.isEmpty) {
            return _buildErrorState(provider.error!, provider);
          }

          if (provider.filteredInternships.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () => provider.refreshData(),
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Internshala Header
                  _buildInternshalaHeader(),
                  const SizedBox(height: 16),
                  
                  // Quick Stats
                  _buildStatsRow(provider.stats),
                  const SizedBox(height: 24),
                  
                  // Search Bar
                  _buildSearchBar(provider),
                  const SizedBox(height: 16),
                  
                  // Filter Chips
                  _buildFilterChips(provider),
                  const SizedBox(height: 24),
                  
                  // Section Title with debug info
                  _buildSectionTitle(provider.filteredInternships.length),
                  
                  // Debug info in development mode
                  if (kDebugMode)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Debug Info:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                          Text('Total internships: ${provider.internships.length}'),
                          Text('Filtered internships: ${provider.filteredInternships.length}'),
                          Text('Search query: "${provider.searchQuery}"'),
                          Text('Selected location: ${provider.selectedLocation}'),
                          if (provider.filteredInternships.isNotEmpty)
                            Text('Sample companies: ${provider.filteredInternships.take(3).map((i) => i.company).join(", ")}'),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // Internships List
                  _buildInternshipsList(provider),
                  
                  // Loading more indicator
                  if (provider.isLoading && provider.filteredInternships.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    ),
    );
  }

  // Loading State
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Loading internships from Internshala...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // Error State
  Widget _buildErrorState(String error, InternshipProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load internships',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => provider.refreshData(),
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  // Empty State
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.work_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No internships found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // Internshala Header
  Widget _buildInternshalaHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00A5CF), Color(0xFF0078AA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.work,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Internshala Portal',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Live data from internshala.com',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Stats Row
  Widget _buildStatsRow(Map<String, int> stats) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total',
            '${stats['total'] ?? 0}',
            Icons.work_outline,
            const Color(0xFF00A5CF),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Remote',
            '${stats['remote'] ?? 0}',
            Icons.home_work,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Paid',
            '${stats['paid'] ?? 0}',
            Icons.attach_money,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Urgent',
            '${stats['urgent'] ?? 0}',
            Icons.schedule,
            Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
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
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // Search Bar
  Widget _buildSearchBar(InternshipProvider provider) {
    return Container(
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
        onChanged: (value) => provider.searchInternships(value),
        decoration: InputDecoration(
          hintText: 'Search internships, companies, skills...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    provider.searchInternships('');
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
    );
  }

  // Filter Chips
  Widget _buildFilterChips(InternshipProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Location filters
        const Text(
          'Locations',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: provider.availableLocations.length,
            itemBuilder: (context, index) {
              final location = provider.availableLocations[index];
              final isSelected = provider.selectedLocation == location;
              
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(location),
                  selected: isSelected,
                  onSelected: (selected) {
                    provider.filterByLocation(location);
                  },
                  selectedColor: const Color(0xFF00A5CF).withOpacity(0.2),
                  checkmarkColor: const Color(0xFF00A5CF),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        
        // Keyword filters
        const Text(
          'Categories',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: provider.availableKeywords.length,
            itemBuilder: (context, index) {
              final keyword = provider.availableKeywords[index];
              final isSelected = provider.selectedKeyword == keyword;
              
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(keyword),
                  selected: isSelected,
                  onSelected: (selected) {
                    provider.filterByKeyword(keyword);
                  },
                  selectedColor: Colors.green.withOpacity(0.2),
                  checkmarkColor: Colors.green,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Section Title
  Widget _buildSectionTitle(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Available Internships ($count)',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: () {
            context.read<InternshipProvider>().clearFilters();
          },
          child: const Text('Clear Filters'),
        ),
      ],
    );
  }

  // Internships List
  Widget _buildInternshipsList(InternshipProvider provider) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.filteredInternships.length,
      itemBuilder: (context, index) {
        final internship = provider.filteredInternships[index];
        return _buildInternshipCard(internship);
      },
    );
  }

  // Internship Card
  Widget _buildInternshipCard(InternshipModel internship) {

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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00A5CF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.work,
                    color: Color(0xFF00A5CF),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        internship.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        internship.company,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF00A5CF),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (internship.urgencyLevel == 'urgent')
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'URGENT',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Details
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildDetailChip(Icons.location_on, internship.displayLocation),
                _buildDetailChip(Icons.schedule, internship.displayDuration),
                _buildDetailChip(Icons.attach_money, internship.displayStipend),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Skills
            if (internship.skills.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: internship.skills.take(4).map((skill) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      skill,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            
            const SizedBox(height: 16),
            
            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: internship.isValidApplyLink
                    ? () => _launchUrl(internship.applyLink)
                    : null,
                icon: const Icon(Icons.open_in_new),
                label: const Text('Apply Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A5CF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
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
            const SnackBar(content: Text('Could not open the application link')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error opening application link')),
        );
      }
    }
  }
}
