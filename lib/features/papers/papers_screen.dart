import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/services/arxiv_service.dart';
import '../../core/models/research_paper.dart';
import '../../core/widgets/modern_side_drawer.dart';
import 'widgets/paper_card.dart';
import 'widgets/paper_detail_sheet.dart';

class PapersScreen extends StatefulWidget {
  const PapersScreen({super.key});

  @override
  State<PapersScreen> createState() => _PapersScreenState();
}

class _PapersScreenState extends State<PapersScreen> {
  final ArxivService _arxivService = ArxivService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<ResearchPaper> _papers = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String _selectedCategory = 'cs.AI';
  int _currentPage = 0;
  static const int _pageSize = 10;

  final Map<String, String> _categories = {
    'cs.AI': 'Artificial Intelligence',
    'cs.LG': 'Machine Learning',
    'cs.CV': 'Computer Vision',
    'cs.CL': 'Computation and Language',
    'cs.RO': 'Robotics',
    'cs.CR': 'Cryptography',
    'cs.DB': 'Databases',
    'cs.SE': 'Software Engineering',
    'cs.DS': 'Data Structures',
    'cs.DC': 'Distributed Computing',
  };

  @override
  void initState() {
    super.initState();
    _loadPapers();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      _loadMorePapers();
    }
  }

  Future<void> _loadPapers() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
      _currentPage = 0;
      _papers.clear();
    });

    try {
      final papers = await _arxivService.fetchPapers(
        category: _selectedCategory,
        start: 0,
        maxResults: _pageSize,
      );
      
      if (mounted) {
        setState(() {
          _papers = papers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Failed to load papers: $e');
      }
    }
  }

  Future<void> _loadMorePapers() async {
    if (_isLoadingMore || _isLoading) return;
    
    if (mounted) {
      setState(() {
        _isLoadingMore = true;
      });
    }

    try {
      final papers = await _arxivService.fetchPapers(
        category: _selectedCategory,
        start: (_currentPage + 1) * _pageSize,
        maxResults: _pageSize,
      );
      
      if (mounted) {
        setState(() {
          _papers.addAll(papers);
          _currentPage++;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
        _showErrorSnackBar('Failed to load more papers: $e');
      }
    }
  }

  Future<void> _searchPapers(String query) async {
    if (query.trim().isEmpty) {
      _loadPapers();
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
        _papers.clear();
      });
    }

    try {
      final papers = await _arxivService.searchPapers(
        query: query.trim(),
        maxResults: _pageSize,
      );
      
      if (mounted) {
        setState(() {
          _papers = papers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Search failed: $e');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showPaperDetails(ResearchPaper paper) {
    if (mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => PaperDetailSheet(paper: paper),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF8F9FA),
      drawer: const ModernSideDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Research Papers',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDark),
            _buildSearchBar(isDark),
            _buildCategoryFilter(isDark),
            Expanded(
              child: _buildPapersList(isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.article_rounded,
              color: Color(0xFF6C63FF),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Research Papers',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                ),
              ),
              Text(
                'Discover latest AI research',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onSubmitted: _searchPapers,
        decoration: InputDecoration(
          hintText: 'Search research papers...',
          hintStyle: GoogleFonts.inter(
            color: isDark ? Colors.grey[400] : Colors.grey[500],
          ),
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () {
                    _searchController.clear();
                    _loadPapers();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(bool isDark) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories.keys.elementAt(index);
          final isSelected = category == _selectedCategory;
          
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(
                _categories[category]!,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSelected 
                      ? Colors.white 
                      : (isDark ? Colors.grey[300] : Colors.grey[700]),
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedCategory = category;
                  });
                  _loadPapers();
                }
              },
              backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.grey[100],
              selectedColor: const Color(0xFF6C63FF),
              checkmarkColor: Colors.white,
              side: BorderSide.none,
            ),
          );
        },
      ),
    );
  }

  Widget _buildPapersList(bool isDark) {
    if (_isLoading && _papers.isEmpty) {
      return _buildLoadingShimmer();
    }

    if (_papers.isEmpty) {
      return _buildEmptyState(isDark);
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _papers.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _papers.length) {
          return _buildLoadingIndicator();
        }
        
        return PaperCard(
          paper: _papers[index],
          onTap: () => _showPaperDetails(_papers[index]),
        );
      },
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 200,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.article_outlined,
            size: 64,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No papers found',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or category filter',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: isDark ? Colors.grey[500] : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(
        color: Color(0xFF6C63FF),
      ),
    );
  }
}
