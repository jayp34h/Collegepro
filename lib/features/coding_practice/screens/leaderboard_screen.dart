import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/coding_practice_provider.dart';
import '../models/leaderboard_entry.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CodingPracticeProvider>().loadLeaderboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Coding Champions 🏆',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF6366F1),
        elevation: 0,
      ),
      body: Consumer<CodingPracticeProvider>(
        builder: (context, provider, child) {
          final leaderboard = provider.leaderboard;
          
          if (leaderboard.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.emoji_events,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No coding champions yet! 🚀',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start solving problems to appear on the leaderboard!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Top 3 Podium
              if (leaderboard.length >= 3) _buildPodium(leaderboard.take(3).toList()),
              
              // Rest of the leaderboard
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: leaderboard.length,
                  itemBuilder: (context, index) {
                    final entry = leaderboard[index];
                    return _buildLeaderboardCard(entry, index + 1);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPodium(List<LeaderboardEntry> topThree) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF6366F1),
            const Color(0xFF6366F1).withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        children: [
          const Text(
            '🏆 Hall of Fame 🏆',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Second place
              if (topThree.length > 1) _buildPodiumPlace(topThree[1], 2, 120),
              // First place
              _buildPodiumPlace(topThree[0], 1, 140),
              // Third place
              if (topThree.length > 2) _buildPodiumPlace(topThree[2], 3, 100),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumPlace(LeaderboardEntry entry, int position, double height) {
    final colors = [
      Colors.amber, // Gold
      Colors.grey[400]!, // Silver
      const Color(0xFFCD7F32), // Bronze
    ];
    
    final emojis = ['🥇', '🥈', '🥉'];
    
    return Column(
      children: [
        // Avatar and crown
        Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 15),
              child: CircleAvatar(
                radius: 30,
                backgroundColor: colors[position - 1],
                child: Text(
                  entry.studentName.isNotEmpty 
                      ? entry.studentName[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Text(
              emojis[position - 1],
              style: const TextStyle(fontSize: 30),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          entry.studentName,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '${entry.totalScore} pts',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 8),
        // Podium base
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            color: colors[position - 1],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Center(
            child: Text(
              '$position',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardCard(LeaderboardEntry entry, int rank) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Rank
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getRankColor(rank),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Avatar
            CircleAvatar(
              radius: 25,
              backgroundColor: const Color(0xFF6366F1).withOpacity(0.2),
              child: Text(
                entry.studentName.isNotEmpty 
                    ? entry.studentName[0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6366F1),
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.studentName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          entry.title,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6366F1),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.funnyNote,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildStatChip(
                        Icons.star,
                        '${entry.totalScore}',
                        Colors.amber,
                      ),
                      const SizedBox(width: 8),
                      _buildStatChip(
                        Icons.check_circle,
                        '${entry.problemsSolved}',
                        Colors.green,
                      ),
                      const SizedBox(width: 8),
                      _buildStatChip(
                        Icons.trending_up,
                        '${entry.averageScore.toStringAsFixed(1)}',
                        Colors.blue,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    if (rank <= 3) {
      return const Color(0xFF6366F1);
    } else if (rank <= 10) {
      return Colors.green;
    } else if (rank <= 20) {
      return Colors.orange;
    } else {
      return Colors.grey;
    }
  }
}
