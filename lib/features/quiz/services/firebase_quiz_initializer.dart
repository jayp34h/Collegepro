import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quiz_question.dart';

class FirebaseQuizInitializer {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Initialize Firebase with all quiz questions for all subjects
  static Future<void> initializeQuizData() async {
    try {
      print('🔥 Starting Firebase quiz data initialization...');
      
      // Get all subjects
      final subjects = QuizSubject.getAllSubjects();
      
      for (final subject in subjects) {
        await _initializeSubjectQuestions(subject);
      }
      
      print('✅ Firebase quiz data initialization completed successfully!');
    } catch (e) {
      print('❌ Error initializing Firebase quiz data: $e');
      rethrow;
    }
  }

  /// Initialize questions for a specific subject
  static Future<void> _initializeSubjectQuestions(QuizSubject subject) async {
    try {
      print('📚 Initializing questions for ${subject.name}...');
      
      // Check if questions already exist for this subject
      final existingQuestions = await _firestore
          .collection('quiz_questions')
          .where('subject', isEqualTo: subject.id)
          .get();
      
      if (existingQuestions.docs.isNotEmpty) {
        print('⚠️ Questions already exist for ${subject.name}, skipping...');
        return;
      }

      // Generate sample questions for the subject
      final questions = _generateQuestionsForSubject(subject);
      
      // Batch write to Firebase
      final batch = _firestore.batch();
      
      for (final question in questions) {
        final docRef = _firestore.collection('quiz_questions').doc();
        batch.set(docRef, question.toJson());
      }
      
      await batch.commit();
      print('✅ Added ${questions.length} questions for ${subject.name}');
      
    } catch (e) {
      print('❌ Error initializing questions for ${subject.name}: $e');
      rethrow;
    }
  }

  /// Generate sample questions for a subject
  static List<QuizQuestion> _generateQuestionsForSubject(QuizSubject subject) {
    switch (subject.id) {
      case 'programming':
        return _getProgrammingQuestions();
      case 'dsa':
        return _getDSAQuestions();
      case 'dbms':
        return _getDBMSQuestions();
      case 'os':
        return _getOSQuestions();
      case 'cn':
        return _getCNQuestions();
      case 'se_oop':
        return _getSEOOPQuestions();
      default:
        return [];
    }
  }

  static List<QuizQuestion> _getProgrammingQuestions() {
    return [
      QuizQuestion(
        id: 'prog_001',
        question: 'What is the correct way to declare a variable in Python?',
        options: ['var x = 5', 'x = 5', 'int x = 5', 'declare x = 5'],
        correctAnswer: 1,
        subject: 'programming',
        topic: 'Variables',
        difficulty: 'Easy',
        explanation: 'In Python, variables are declared by simply assigning a value to them.',
      ),
      QuizQuestion(
        id: 'prog_002',
        question: 'Which of the following is a valid Python data type?',
        options: ['int', 'string', 'boolean', 'All of the above'],
        correctAnswer: 3,
        subject: 'programming',
        topic: 'Data Types',
        difficulty: 'Easy',
        explanation: 'Python supports int, str (string), bool (boolean), and many other data types.',
      ),
      QuizQuestion(
        id: 'prog_003',
        question: 'What is the output of: print(2 ** 3)?',
        options: ['6', '8', '9', 'Error'],
        correctAnswer: 1,
        subject: 'programming',
        topic: 'Operators',
        difficulty: 'Easy',
        explanation: 'The ** operator is used for exponentiation in Python. 2**3 = 8.',
      ),
      QuizQuestion(
        id: 'prog_004',
        question: 'Which loop is used when the number of iterations is unknown?',
        options: ['for loop', 'while loop', 'do-while loop', 'nested loop'],
        correctAnswer: 1,
        subject: 'programming',
        topic: 'Loops',
        difficulty: 'Medium',
        explanation: 'While loops are used when the number of iterations depends on a condition.',
      ),
      QuizQuestion(
        id: 'prog_005',
        question: 'What is the purpose of the "break" statement?',
        options: ['Exit the program', 'Exit the current loop', 'Skip current iteration', 'Pause execution'],
        correctAnswer: 1,
        subject: 'programming',
        topic: 'Control Flow',
        difficulty: 'Medium',
        explanation: 'The break statement is used to exit/terminate the current loop.',
      ),
    ];
  }

  static List<QuizQuestion> _getDSAQuestions() {
    return [
      QuizQuestion(
        id: 'dsa_001',
        question: 'What is the time complexity of binary search?',
        options: ['O(n)', 'O(log n)', 'O(n²)', 'O(1)'],
        correctAnswer: 1,
        subject: 'dsa',
        topic: 'Search Algorithms',
        difficulty: 'Medium',
        explanation: 'Binary search divides the search space in half each time, resulting in O(log n) complexity.',
      ),
      QuizQuestion(
        id: 'dsa_002',
        question: 'Which data structure follows LIFO principle?',
        options: ['Queue', 'Stack', 'Array', 'Linked List'],
        correctAnswer: 1,
        subject: 'dsa',
        topic: 'Data Structures',
        difficulty: 'Easy',
        explanation: 'Stack follows Last In First Out (LIFO) principle.',
      ),
      QuizQuestion(
        id: 'dsa_003',
        question: 'What is the worst-case time complexity of Quick Sort?',
        options: ['O(n log n)', 'O(n²)', 'O(n)', 'O(log n)'],
        correctAnswer: 1,
        subject: 'dsa',
        topic: 'Sorting',
        difficulty: 'Hard',
        explanation: 'Quick sort has O(n²) worst-case complexity when the pivot is always the smallest or largest element.',
      ),
      QuizQuestion(
        id: 'dsa_004',
        question: 'Which traversal visits the root node first?',
        options: ['Inorder', 'Preorder', 'Postorder', 'Level order'],
        correctAnswer: 1,
        subject: 'dsa',
        topic: 'Trees',
        difficulty: 'Medium',
        explanation: 'Preorder traversal visits the root node first, then left subtree, then right subtree.',
      ),
      QuizQuestion(
        id: 'dsa_005',
        question: 'What is the space complexity of merge sort?',
        options: ['O(1)', 'O(log n)', 'O(n)', 'O(n²)'],
        correctAnswer: 2,
        subject: 'dsa',
        topic: 'Sorting',
        difficulty: 'Medium',
        explanation: 'Merge sort requires O(n) extra space for the temporary arrays used during merging.',
      ),
    ];
  }

  static List<QuizQuestion> _getDBMSQuestions() {
    return [
      QuizQuestion(
        id: 'dbms_001',
        question: 'What does ACID stand for in database systems?',
        options: ['Atomicity, Consistency, Isolation, Durability', 'Accuracy, Consistency, Integrity, Durability', 'Atomicity, Concurrency, Isolation, Durability', 'Accuracy, Concurrency, Integrity, Durability'],
        correctAnswer: 0,
        subject: 'dbms',
        topic: 'Transactions',
        difficulty: 'Medium',
        explanation: 'ACID stands for Atomicity, Consistency, Isolation, and Durability - the four key properties of database transactions.',
      ),
      QuizQuestion(
        id: 'dbms_002',
        question: 'Which SQL command is used to retrieve data from a database?',
        options: ['GET', 'SELECT', 'RETRIEVE', 'FETCH'],
        correctAnswer: 1,
        subject: 'dbms',
        topic: 'SQL',
        difficulty: 'Easy',
        explanation: 'SELECT is the SQL command used to retrieve data from database tables.',
      ),
      QuizQuestion(
        id: 'dbms_003',
        question: 'What is a primary key?',
        options: ['A key that can be null', 'A unique identifier for records', 'A foreign key reference', 'An index on a table'],
        correctAnswer: 1,
        subject: 'dbms',
        topic: 'Keys',
        difficulty: 'Easy',
        explanation: 'A primary key is a unique identifier for each record in a database table.',
      ),
      QuizQuestion(
        id: 'dbms_004',
        question: 'What is normalization in databases?',
        options: ['Combining tables', 'Organizing data to reduce redundancy', 'Creating indexes', 'Backing up data'],
        correctAnswer: 1,
        subject: 'dbms',
        topic: 'Normalization',
        difficulty: 'Medium',
        explanation: 'Normalization is the process of organizing data to minimize redundancy and dependency.',
      ),
      QuizQuestion(
        id: 'dbms_005',
        question: 'Which normal form eliminates transitive dependencies?',
        options: ['1NF', '2NF', '3NF', 'BCNF'],
        correctAnswer: 2,
        subject: 'dbms',
        topic: 'Normalization',
        difficulty: 'Hard',
        explanation: 'Third Normal Form (3NF) eliminates transitive dependencies.',
      ),
    ];
  }

  static List<QuizQuestion> _getOSQuestions() {
    return [
      QuizQuestion(
        id: 'os_001',
        question: 'What is a process in operating systems?',
        options: ['A program in execution', 'A stored program', 'A system call', 'A memory location'],
        correctAnswer: 0,
        subject: 'os',
        topic: 'Processes',
        difficulty: 'Easy',
        explanation: 'A process is a program in execution, including the program code and its current activity.',
      ),
      QuizQuestion(
        id: 'os_002',
        question: 'Which scheduling algorithm gives the shortest average waiting time?',
        options: ['FCFS', 'SJF', 'Round Robin', 'Priority'],
        correctAnswer: 1,
        subject: 'os',
        topic: 'Scheduling',
        difficulty: 'Medium',
        explanation: 'Shortest Job First (SJF) scheduling algorithm gives the shortest average waiting time.',
      ),
      QuizQuestion(
        id: 'os_003',
        question: 'What is deadlock in operating systems?',
        options: ['Process termination', 'Circular wait condition', 'Memory overflow', 'CPU overload'],
        correctAnswer: 1,
        subject: 'os',
        topic: 'Deadlock',
        difficulty: 'Medium',
        explanation: 'Deadlock occurs when processes are blocked because each process holds a resource and waits for another resource acquired by some other process.',
      ),
      QuizQuestion(
        id: 'os_004',
        question: 'What is virtual memory?',
        options: ['Physical RAM', 'Storage technique that provides illusion of large memory', 'Cache memory', 'ROM'],
        correctAnswer: 1,
        subject: 'os',
        topic: 'Memory Management',
        difficulty: 'Medium',
        explanation: 'Virtual memory is a storage technique that provides the illusion of having more physical memory than actually available.',
      ),
      QuizQuestion(
        id: 'os_005',
        question: 'Which algorithm is used for page replacement?',
        options: ['FIFO', 'LRU', 'Optimal', 'All of the above'],
        correctAnswer: 3,
        subject: 'os',
        topic: 'Memory Management',
        difficulty: 'Medium',
        explanation: 'FIFO, LRU (Least Recently Used), and Optimal are all page replacement algorithms.',
      ),
    ];
  }

  static List<QuizQuestion> _getCNQuestions() {
    return [
      QuizQuestion(
        id: 'cn_001',
        question: 'What does TCP stand for?',
        options: ['Transfer Control Protocol', 'Transmission Control Protocol', 'Transport Control Protocol', 'Terminal Control Protocol'],
        correctAnswer: 1,
        subject: 'cn',
        topic: 'Protocols',
        difficulty: 'Easy',
        explanation: 'TCP stands for Transmission Control Protocol, a reliable transport layer protocol.',
      ),
      QuizQuestion(
        id: 'cn_002',
        question: 'Which layer of OSI model handles routing?',
        options: ['Physical', 'Data Link', 'Network', 'Transport'],
        correctAnswer: 2,
        subject: 'cn',
        topic: 'OSI Model',
        difficulty: 'Medium',
        explanation: 'The Network layer (Layer 3) of the OSI model handles routing of packets.',
      ),
      QuizQuestion(
        id: 'cn_003',
        question: 'What is the purpose of ARP?',
        options: ['Address Resolution Protocol - maps IP to MAC', 'Application Request Protocol', 'Automatic Routing Protocol', 'Access Request Protocol'],
        correctAnswer: 0,
        subject: 'cn',
        topic: 'Protocols',
        difficulty: 'Medium',
        explanation: 'ARP (Address Resolution Protocol) maps IP addresses to MAC addresses.',
      ),
      QuizQuestion(
        id: 'cn_004',
        question: 'Which protocol is connectionless?',
        options: ['TCP', 'UDP', 'HTTP', 'FTP'],
        correctAnswer: 1,
        subject: 'cn',
        topic: 'Protocols',
        difficulty: 'Easy',
        explanation: 'UDP (User Datagram Protocol) is a connectionless protocol.',
      ),
      QuizQuestion(
        id: 'cn_005',
        question: 'What is the maximum size of an Ethernet frame?',
        options: ['1024 bytes', '1500 bytes', '2048 bytes', '4096 bytes'],
        correctAnswer: 1,
        subject: 'cn',
        topic: 'Data Link Layer',
        difficulty: 'Hard',
        explanation: 'The maximum size of an Ethernet frame is 1500 bytes (MTU - Maximum Transmission Unit).',
      ),
    ];
  }

  static List<QuizQuestion> _getSEOOPQuestions() {
    return [
      QuizQuestion(
        id: 'se_001',
        question: 'What is encapsulation in OOP?',
        options: ['Hiding implementation details', 'Creating multiple objects', 'Inheriting properties', 'Overriding methods'],
        correctAnswer: 0,
        subject: 'se_oop',
        topic: 'OOP Concepts',
        difficulty: 'Medium',
        explanation: 'Encapsulation is the bundling of data and methods that operate on that data, hiding internal implementation details.',
      ),
      QuizQuestion(
        id: 'se_002',
        question: 'Which SDLC model is most suitable for changing requirements?',
        options: ['Waterfall', 'Agile', 'V-Model', 'Spiral'],
        correctAnswer: 1,
        subject: 'se_oop',
        topic: 'SDLC',
        difficulty: 'Medium',
        explanation: 'Agile methodology is most suitable for projects with changing requirements due to its iterative approach.',
      ),
      QuizQuestion(
        id: 'se_003',
        question: 'What is polymorphism?',
        options: ['Multiple inheritance', 'Method overloading', 'One interface, multiple implementations', 'Data hiding'],
        correctAnswer: 2,
        subject: 'se_oop',
        topic: 'OOP Concepts',
        difficulty: 'Medium',
        explanation: 'Polymorphism allows one interface to be used for different underlying data types or classes.',
      ),
      QuizQuestion(
        id: 'se_004',
        question: 'What is the purpose of unit testing?',
        options: ['Test the entire system', 'Test individual components', 'Test user interface', 'Test performance'],
        correctAnswer: 1,
        subject: 'se_oop',
        topic: 'Testing',
        difficulty: 'Easy',
        explanation: 'Unit testing focuses on testing individual components or modules in isolation.',
      ),
      QuizQuestion(
        id: 'se_005',
        question: 'Which design pattern ensures only one instance of a class?',
        options: ['Factory', 'Singleton', 'Observer', 'Strategy'],
        correctAnswer: 1,
        subject: 'se_oop',
        topic: 'Design Patterns',
        difficulty: 'Medium',
        explanation: 'The Singleton pattern ensures that a class has only one instance and provides global access to it.',
      ),
    ];
  }

  /// Check if quiz data exists in Firebase
  static Future<bool> isQuizDataInitialized() async {
    try {
      final snapshot = await _firestore.collection('quiz_questions').limit(1).get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking quiz data: $e');
      return false;
    }
  }

  /// Clear all quiz data from Firebase (use with caution)
  static Future<void> clearQuizData() async {
    try {
      print('🗑️ Clearing all quiz data from Firebase...');
      
      final snapshot = await _firestore.collection('quiz_questions').get();
      final batch = _firestore.batch();
      
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      print('✅ Quiz data cleared successfully!');
    } catch (e) {
      print('❌ Error clearing quiz data: $e');
      rethrow;
    }
  }
}
