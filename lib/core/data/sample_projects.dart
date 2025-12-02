import '../models/project_model.dart';

class SampleProjects {
  static List<ProjectModel> getSampleProjects() {
    return [
      ProjectModel(
        id: 'proj_001',
        title: 'AI-Powered Smart Campus Assistant',
        description: 'A comprehensive mobile and web application that uses AI to help students navigate campus life, find resources, and get personalized recommendations.',
        problemStatement: 'Students often struggle to find relevant campus resources, navigate complex university systems, and get timely assistance with academic and administrative queries.',
        techStack: ['Flutter', 'Python', 'FastAPI', 'Firebase', 'OpenAI API', 'Google Maps API'],
        domain: 'AI & Machine Learning',
        difficulty: 'Advanced',
        industryRelevanceScore: 5,
        realWorldApplications: [
          'University management systems',
          'Corporate campus navigation',
          'Smart city applications',
          'Educational technology platforms'
        ],
        possibleExtensions: [
          'Integration with IoT sensors for real-time campus data',
          'AR-based navigation system',
          'Voice-activated assistant',
          'Predictive analytics for resource planning'
        ],
        careerRelevance: 'Full Stack Developer',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
        upvotes: 45,
        downvotes: 3,
        tags: ['AI', 'Mobile', 'Campus', 'Assistant', 'Navigation'],
      ),
      
      ProjectModel(
        id: 'proj_002',
        title: 'Blockchain-Based Digital Certificate Verification',
        description: 'A decentralized platform for issuing, storing, and verifying academic certificates and professional credentials using blockchain technology.',
        problemStatement: 'Traditional certificate verification is time-consuming, prone to fraud, and requires manual intervention from institutions.',
        techStack: ['Solidity', 'Web3.js', 'React', 'Node.js', 'IPFS', 'MetaMask'],
        domain: 'Blockchain',
        difficulty: 'Expert',
        industryRelevanceScore: 5,
        realWorldApplications: [
          'Academic credential verification',
          'Professional certification systems',
          'Employment background checks',
          'Government document verification'
        ],
        possibleExtensions: [
          'Integration with major universities',
          'Mobile app for certificate holders',
          'API for HR systems',
          'Multi-language support'
        ],
        careerRelevance: 'Blockchain Developer',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now().subtract(const Duration(days: 8)),
        upvotes: 38,
        downvotes: 5,
        tags: ['Blockchain', 'Verification', 'Certificates', 'Decentralized'],
      ),
      
      ProjectModel(
        id: 'proj_003',
        title: 'IoT-Based Smart Agriculture Monitoring System',
        description: 'An IoT solution that monitors soil conditions, weather patterns, and crop health to optimize farming practices and increase yield.',
        problemStatement: 'Farmers lack real-time data about soil conditions and crop health, leading to inefficient resource usage and reduced crop yields.',
        techStack: ['Arduino', 'Raspberry Pi', 'Python', 'React', 'MongoDB', 'AWS IoT'],
        domain: 'Internet of Things',
        difficulty: 'Intermediate',
        industryRelevanceScore: 4,
        realWorldApplications: [
          'Precision agriculture',
          'Smart greenhouse management',
          'Crop yield optimization',
          'Water conservation systems'
        ],
        possibleExtensions: [
          'Machine learning for predictive analytics',
          'Drone integration for aerial monitoring',
          'Mobile app for farmers',
          'Integration with weather services'
        ],
        careerRelevance: 'IoT Developer',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now().subtract(const Duration(days: 12)),
        upvotes: 52,
        downvotes: 2,
        tags: ['IoT', 'Agriculture', 'Sensors', 'Monitoring', 'Smart Farming'],
      ),
      
      ProjectModel(
        id: 'proj_004',
        title: 'Cybersecurity Threat Detection Dashboard',
        description: 'A real-time dashboard that monitors network traffic, detects anomalies, and provides automated threat response capabilities.',
        problemStatement: 'Organizations struggle to detect and respond to cybersecurity threats in real-time, often discovering breaches too late.',
        techStack: ['Python', 'Elasticsearch', 'Kibana', 'Docker', 'Machine Learning', 'Splunk'],
        domain: 'Cybersecurity',
        difficulty: 'Advanced',
        industryRelevanceScore: 5,
        realWorldApplications: [
          'Enterprise security monitoring',
          'SOC (Security Operations Center) tools',
          'Network intrusion detection',
          'Compliance monitoring systems'
        ],
        possibleExtensions: [
          'AI-powered threat prediction',
          'Integration with SIEM tools',
          'Mobile alerts and notifications',
          'Automated incident response'
        ],
        careerRelevance: 'Cybersecurity Specialist',
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
        upvotes: 41,
        downvotes: 4,
        tags: ['Cybersecurity', 'Threat Detection', 'Dashboard', 'Monitoring'],
      ),
      
      ProjectModel(
        id: 'proj_005',
        title: 'Cloud-Native E-Learning Platform',
        description: 'A scalable e-learning platform built with microservices architecture, supporting video streaming, interactive content, and real-time collaboration.',
        problemStatement: 'Traditional e-learning platforms struggle with scalability, performance issues, and lack of interactive features for modern educational needs.',
        techStack: ['Kubernetes', 'Docker', 'Node.js', 'React', 'PostgreSQL', 'Redis', 'AWS'],
        domain: 'Cloud Computing',
        difficulty: 'Advanced',
        industryRelevanceScore: 4,
        realWorldApplications: [
          'Online education platforms',
          'Corporate training systems',
          'Skill development programs',
          'Remote learning solutions'
        ],
        possibleExtensions: [
          'AI-powered personalized learning paths',
          'VR/AR integration for immersive learning',
          'Blockchain-based certification',
          'Advanced analytics and reporting'
        ],
        careerRelevance: 'Cloud Architect',
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
        updatedAt: DateTime.now().subtract(const Duration(days: 6)),
        upvotes: 35,
        downvotes: 1,
        tags: ['Cloud', 'E-Learning', 'Microservices', 'Scalable'],
      ),
      
      ProjectModel(
        id: 'proj_006',
        title: 'React Native Fitness Tracking App',
        description: 'A comprehensive fitness tracking mobile app with workout planning, nutrition tracking, social features, and integration with wearable devices.',
        problemStatement: 'Most fitness apps lack comprehensive features and fail to provide personalized experiences that keep users motivated long-term.',
        techStack: ['React Native', 'Node.js', 'MongoDB', 'Firebase', 'HealthKit', 'Google Fit API'],
        domain: 'Mobile Development',
        difficulty: 'Intermediate',
        industryRelevanceScore: 3,
        realWorldApplications: [
          'Personal fitness applications',
          'Corporate wellness programs',
          'Healthcare monitoring systems',
          'Sports performance tracking'
        ],
        possibleExtensions: [
          'AI-powered workout recommendations',
          'Integration with gym equipment',
          'Telemedicine features',
          'Gamification elements'
        ],
        careerRelevance: 'Mobile Developer',
        createdAt: DateTime.now().subtract(const Duration(days: 18)),
        updatedAt: DateTime.now().subtract(const Duration(days: 9)),
        upvotes: 28,
        downvotes: 6,
        tags: ['Mobile', 'Fitness', 'Health', 'Tracking', 'React Native'],
      ),
      
      ProjectModel(
        id: 'proj_007',
        title: 'Data Science Stock Market Predictor',
        description: 'A machine learning system that analyzes market data, news sentiment, and economic indicators to predict stock price movements.',
        problemStatement: 'Individual investors lack access to sophisticated tools for market analysis and often make decisions based on incomplete information.',
        techStack: ['Python', 'TensorFlow', 'Pandas', 'Scikit-learn', 'Flask', 'Alpha Vantage API'],
        domain: 'Data Science',
        difficulty: 'Advanced',
        industryRelevanceScore: 4,
        realWorldApplications: [
          'Investment advisory services',
          'Algorithmic trading systems',
          'Risk management tools',
          'Financial research platforms'
        ],
        possibleExtensions: [
          'Real-time trading integration',
          'Portfolio optimization features',
          'Cryptocurrency support',
          'Advanced visualization dashboard'
        ],
        careerRelevance: 'Data Scientist',
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        updatedAt: DateTime.now().subtract(const Duration(days: 15)),
        upvotes: 47,
        downvotes: 8,
        tags: ['Data Science', 'Machine Learning', 'Finance', 'Prediction'],
      ),
      
      ProjectModel(
        id: 'proj_008',
        title: 'DevOps CI/CD Pipeline Automation',
        description: 'A comprehensive DevOps solution that automates the entire software development lifecycle from code commit to production deployment.',
        problemStatement: 'Manual deployment processes are error-prone, time-consuming, and create bottlenecks in software delivery cycles.',
        techStack: ['Jenkins', 'Docker', 'Kubernetes', 'Terraform', 'Ansible', 'AWS', 'GitLab'],
        domain: 'DevOps',
        difficulty: 'Expert',
        industryRelevanceScore: 5,
        realWorldApplications: [
          'Enterprise software delivery',
          'Microservices deployment',
          'Infrastructure as Code',
          'Continuous integration systems'
        ],
        possibleExtensions: [
          'Multi-cloud deployment support',
          'Advanced monitoring and alerting',
          'Security scanning integration',
          'Cost optimization features'
        ],
        careerRelevance: 'DevOps Engineer',
        createdAt: DateTime.now().subtract(const Duration(days: 14)),
        updatedAt: DateTime.now().subtract(const Duration(days: 7)),
        upvotes: 39,
        downvotes: 2,
        tags: ['DevOps', 'CI/CD', 'Automation', 'Deployment'],
      ),
    ];
  }
}
