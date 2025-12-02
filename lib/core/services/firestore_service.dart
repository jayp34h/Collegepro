import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/project_model.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  // Add a new project
  static Future<String?> addProject(ProjectModel project) async {
    try {
      final docRef = await _firestore.collection('projects').add(project.toJson());
      return docRef.id;
    } catch (e) {
      print('Error adding project: $e');
      return null;
    }
  }

  // Get all projects
  static Future<List<ProjectModel>> getAllProjects() async {
    try {
      final querySnapshot = await _firestore
          .collection('projects')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ProjectModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      print('Error fetching projects: $e');
      return [];
    }
  }

  // Get project by ID
  static Future<ProjectModel?> getProjectById(String projectId) async {
    try {
      final doc = await _firestore.collection('projects').doc(projectId).get();
      if (doc.exists) {
        return ProjectModel.fromJson({...doc.data()!, 'id': doc.id});
      }
      return null;
    } catch (e) {
      print('Error fetching project: $e');
      return null;
    }
  }

  // Update project
  static Future<bool> updateProject(String projectId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('projects').doc(projectId).update(data);
      return true;
    } catch (e) {
      print('Error updating project: $e');
      return false;
    }
  }

  // Delete project
  static Future<bool> deleteProject(String projectId) async {
    try {
      await _firestore.collection('projects').doc(projectId).delete();
      return true;
    } catch (e) {
      print('Error deleting project: $e');
      return false;
    }
  }

  // Search projects
  static Future<List<ProjectModel>> searchProjects(String query) async {
    try {
      final querySnapshot = await _firestore
          .collection('projects')
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      return querySnapshot.docs
          .map((doc) => ProjectModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      print('Error searching projects: $e');
      return [];
    }
  }

  // Get projects by domain
  static Future<List<ProjectModel>> getProjectsByDomain(String domain) async {
    try {
      final querySnapshot = await _firestore
          .collection('projects')
          .where('domain', isEqualTo: domain)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ProjectModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      print('Error fetching projects by domain: $e');
      return [];
    }
  }

  // Get projects by difficulty
  static Future<List<ProjectModel>> getProjectsByDifficulty(String difficulty) async {
    try {
      final querySnapshot = await _firestore
          .collection('projects')
          .where('difficulty', isEqualTo: difficulty)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ProjectModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      print('Error fetching projects by difficulty: $e');
      return [];
    }
  }
}
