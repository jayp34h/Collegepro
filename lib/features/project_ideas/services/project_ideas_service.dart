import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/project_idea_model.dart';

class ProjectIdeasService {
  static final DatabaseReference _database = FirebaseDatabase.instance.ref();
  static const String _projectIdeasPath = 'project_ideas';
  static const Uuid _uuid = Uuid();

  /// Submit a new project idea
  static Future<String?> submitProjectIdea(ProjectIdeaModel projectIdea) async {
    try {
      final String ideaId = _uuid.v4();
      final now = DateTime.now();
      
      final ideaWithId = projectIdea.copyWith(
        id: ideaId,
        createdAt: now,
        updatedAt: now,
      );

      await _database
          .child(_projectIdeasPath)
          .child(ideaId)
          .set(ideaWithId.toMap())
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              print('⏰ Project idea submission timeout');
              throw Exception('Request timeout. Please check your internet connection.');
            },
          );

      print('✅ Project idea submitted successfully: $ideaId');
      return ideaId;
    } catch (e) {
      print('❌ Error submitting project idea: $e');
      
      if (e.toString().contains('permission') || e.toString().contains('PERMISSION_DENIED')) {
        print('🔒 Permission denied for project idea submission');
        throw Exception('Permission denied. Please check Firebase database rules.');
      } else if (e.toString().contains('timeout')) {
        throw Exception('Request timeout. Please check your internet connection.');
      } else {
        throw Exception('Failed to submit project idea: ${e.toString()}');
      }
    }
  }

  /// Get all project ideas (including pending approval)
  static Future<List<ProjectIdeaModel>> getAllProjectIdeas() async {
    try {
      print('🔄 Loading all project ideas...');
      
      final snapshot = await _database
          .child(_projectIdeasPath)
          .get()
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              print('⏰ Project ideas loading timeout');
              throw Exception('Request timeout. Please check your internet connection.');
            },
          );

      print('📊 Snapshot exists: ${snapshot.exists}');
      print('📊 Snapshot value: ${snapshot.value}');

      if (snapshot.exists) {
        final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
        final List<ProjectIdeaModel> ideas = [];

        print('📊 Raw project ideas data keys: ${data.keys.toList()}');

        data.forEach((key, value) {
          try {
            if (value is Map<String, dynamic>) {
              ideas.add(ProjectIdeaModel.fromMap(value));
            } else {
              // Convert dynamic map to Map<String, dynamic>
              final Map<String, dynamic> convertedValue = {};
              (value as Map<dynamic, dynamic>).forEach((k, v) {
                convertedValue[k.toString()] = v;
              });
              ideas.add(ProjectIdeaModel.fromMap(convertedValue));
            }
          } catch (e) {
            print('❌ Error parsing project idea $key: $e');
          }
        });

        // Sort by creation date (newest first)
        ideas.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return ideas;
      }
      print('📭 No project ideas found');
      return [];
    } catch (e) {
      print('❌ Error fetching all project ideas: $e');
      
      if (e.toString().contains('permission') || e.toString().contains('PERMISSION_DENIED')) {
        print('🔒 Permission denied for project ideas loading');
        throw Exception('Permission denied. Please check Firebase database rules.');
      }
      
      return [];
    }
  }

  /// Get all approved project ideas
  static Future<List<ProjectIdeaModel>> getAllApprovedProjectIdeas() async {
    try {
      final snapshot = await _database
          .child(_projectIdeasPath)
          .orderByChild('isApproved')
          .equalTo(true)
          .get();

      if (snapshot.exists) {
        final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
        final List<ProjectIdeaModel> ideas = [];

        data.forEach((key, value) {
          if (value is Map<String, dynamic>) {
            ideas.add(ProjectIdeaModel.fromMap(value));
          } else {
            // Convert dynamic map to Map<String, dynamic>
            final Map<String, dynamic> convertedValue = {};
            (value as Map<dynamic, dynamic>).forEach((k, v) {
              convertedValue[k.toString()] = v;
            });
            ideas.add(ProjectIdeaModel.fromMap(convertedValue));
          }
        });

        // Sort by creation date (newest first)
        ideas.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return ideas;
      }
      return [];
    } catch (e) {
      print('Error fetching project ideas: $e');
      return [];
    }
  }

  /// Get project ideas by user
  static Future<List<ProjectIdeaModel>> getProjectIdeasByUser(String userId) async {
    try {
      final snapshot = await _database
          .child(_projectIdeasPath)
          .orderByChild('authorId')
          .equalTo(userId)
          .get();

      if (snapshot.exists) {
        final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
        final List<ProjectIdeaModel> ideas = [];

        data.forEach((key, value) {
          if (value is Map<String, dynamic>) {
            ideas.add(ProjectIdeaModel.fromMap(value));
          } else {
            final Map<String, dynamic> convertedValue = {};
            (value as Map<dynamic, dynamic>).forEach((k, v) {
              convertedValue[k.toString()] = v;
            });
            ideas.add(ProjectIdeaModel.fromMap(convertedValue));
          }
        });

        ideas.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return ideas;
      }
      return [];
    } catch (e) {
      print('Error fetching user project ideas: $e');
      return [];
    }
  }

  /// Like/Unlike a project idea
  static Future<bool> toggleLikeProjectIdea(String ideaId, String userId) async {
    try {
      final snapshot = await _database
          .child(_projectIdeasPath)
          .child(ideaId)
          .get();

      if (snapshot.exists) {
        final Map<String, dynamic> data = {};
        (snapshot.value as Map<dynamic, dynamic>).forEach((k, v) {
          data[k.toString()] = v;
        });

        final ProjectIdeaModel idea = ProjectIdeaModel.fromMap(data);
        final List<String> likedBy = List<String>.from(idea.likedBy);
        
        if (likedBy.contains(userId)) {
          // Unlike
          likedBy.remove(userId);
        } else {
          // Like
          likedBy.add(userId);
        }

        final updatedIdea = idea.copyWith(
          likedBy: likedBy,
          likes: likedBy.length,
          updatedAt: DateTime.now(),
        );

        await _database
            .child(_projectIdeasPath)
            .child(ideaId)
            .update(updatedIdea.toMap());

        return true;
      }
      return false;
    } catch (e) {
      print('Error toggling like: $e');
      return false;
    }
  }

  /// Increment view count
  static Future<void> incrementViewCount(String ideaId) async {
    try {
      final snapshot = await _database
          .child(_projectIdeasPath)
          .child(ideaId)
          .get();

      if (snapshot.exists) {
        final Map<String, dynamic> data = {};
        (snapshot.value as Map<dynamic, dynamic>).forEach((k, v) {
          data[k.toString()] = v;
        });

        final ProjectIdeaModel idea = ProjectIdeaModel.fromMap(data);
        final updatedIdea = idea.copyWith(
          views: idea.views + 1,
          updatedAt: DateTime.now(),
        );

        await _database
            .child(_projectIdeasPath)
            .child(ideaId)
            .update({
              'views': updatedIdea.views,
              'updatedAt': updatedIdea.updatedAt.millisecondsSinceEpoch,
            });
      }
    } catch (e) {
      print('Error incrementing view count: $e');
    }
  }

  /// Get project idea by ID
  static Future<ProjectIdeaModel?> getProjectIdeaById(String ideaId) async {
    try {
      final snapshot = await _database
          .child(_projectIdeasPath)
          .child(ideaId)
          .get();

      if (snapshot.exists) {
        final Map<String, dynamic> data = {};
        (snapshot.value as Map<dynamic, dynamic>).forEach((k, v) {
          data[k.toString()] = v;
        });
        return ProjectIdeaModel.fromMap(data);
      }
      return null;
    } catch (e) {
      print('Error fetching project idea: $e');
      return null;
    }
  }

  /// Search project ideas
  static Future<List<ProjectIdeaModel>> searchProjectIdeas(String query) async {
    try {
      final allIdeas = await getAllApprovedProjectIdeas();
      final searchQuery = query.toLowerCase();
      
      return allIdeas.where((idea) {
        return idea.title.toLowerCase().contains(searchQuery) ||
               idea.description.toLowerCase().contains(searchQuery) ||
               idea.domain.toLowerCase().contains(searchQuery) ||
               idea.techStack.any((tech) => tech.toLowerCase().contains(searchQuery));
      }).toList();
    } catch (e) {
      print('Error searching project ideas: $e');
      return [];
    }
  }

  /// Get project ideas stream for real-time updates
  static Stream<List<ProjectIdeaModel>> getProjectIdeasStream() {
    return _database
        .child(_projectIdeasPath)
        .orderByChild('isApproved')
        .equalTo(true)
        .onValue
        .map((event) {
      final List<ProjectIdeaModel> ideas = [];
      
      if (event.snapshot.exists) {
        final Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;
        
        data.forEach((key, value) {
          if (value is Map<String, dynamic>) {
            ideas.add(ProjectIdeaModel.fromMap(value));
          } else {
            final Map<String, dynamic> convertedValue = {};
            (value as Map<dynamic, dynamic>).forEach((k, v) {
              convertedValue[k.toString()] = v;
            });
            ideas.add(ProjectIdeaModel.fromMap(convertedValue));
          }
        });
      }
      
      ideas.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return ideas;
    });
  }

  /// Delete project idea (only by author)
  static Future<bool> deleteProjectIdea(String ideaId, String userId) async {
    try {
      final snapshot = await _database
          .child(_projectIdeasPath)
          .child(ideaId)
          .get();

      if (snapshot.exists) {
        final Map<String, dynamic> data = {};
        (snapshot.value as Map<dynamic, dynamic>).forEach((k, v) {
          data[k.toString()] = v;
        });

        final ProjectIdeaModel idea = ProjectIdeaModel.fromMap(data);
        
        // Only allow deletion by the author
        if (idea.authorId == userId) {
          await _database
              .child(_projectIdeasPath)
              .child(ideaId)
              .remove();
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error deleting project idea: $e');
      return false;
    }
  }
}
