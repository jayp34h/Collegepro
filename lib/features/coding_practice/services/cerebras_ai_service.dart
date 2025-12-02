import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../../../core/config/api_config.dart';

class CerebrasAIService {
  static const String _baseUrl = '${ApiConfig.cerebrasBaseUrl}/chat/completions';

  Future<Map<String, dynamic>> generateSolution({
    required String question,
    required String language,
    required String expectedOutput,
    String? difficulty,
    List<String>? tags,
  }) async {
    try {
      log('CerebrasAIService: Generating AI solution for coding problem');
      
      final prompt = _buildSolutionPrompt(
        question: question,
        language: language,
        expectedOutput: expectedOutput,
        difficulty: difficulty,
        tags: tags,
      );

      final response = await _makeCerebrasRequest(prompt);
      if (response == null) {
        return _createFallbackSolution(language, question: question);
      }

      return _parseSolutionResponse(response);
    } catch (e) {
      log('CerebrasAIService: Error generating solution: $e');
      return _createFallbackSolution(language, question: question);
    }
  }

  Future<Map<String, dynamic>> explainSolution({
    required String question,
    required String solutionCode,
    required String language,
  }) async {
    try {
      log('CerebrasAIService: Generating solution explanation');
      
      final prompt = _buildExplanationPrompt(
        question: question,
        solutionCode: solutionCode,
        language: language,
      );

      final response = await _makeCerebrasRequest(prompt);
      if (response == null) {
        return _createFallbackExplanation();
      }

      return _parseExplanationResponse(response);
    } catch (e) {
      log('CerebrasAIService: Error generating explanation: $e');
      return _createFallbackExplanation();
    }
  }

  String _buildSolutionPrompt({
    required String question,
    required String language,
    required String expectedOutput,
    String? difficulty,
    List<String>? tags,
  }) {
    final difficultyText = difficulty != null ? '\nDIFFICULTY: $difficulty' : '';
    final tagsText = tags != null && tags.isNotEmpty ? '\nTAGS: ${tags.join(', ')}' : '';

    return '''
You are an expert coding tutor and competitive programming mentor. Generate an optimal solution for this coding problem with detailed explanation.

PROBLEM:
$question$difficultyText$tagsText

LANGUAGE: $language
EXPECTED OUTPUT FORMAT:
$expectedOutput

Provide response in this EXACT JSON format:
{
  "code": "<complete, optimized, well-commented solution code>",
  "explanation": "<step-by-step explanation of the approach and algorithm>",
  "approach": "<brief description of the solution strategy>",
  "time_complexity": "<Big O time complexity with explanation>",
  "space_complexity": "<Big O space complexity with explanation>",
  "key_insights": ["<insight 1>", "<insight 2>", "<insight 3>"],
  "edge_cases": ["<edge case 1>", "<edge case 2>"],
  "optimization_tips": "<tips for further optimization if any>"
}

Guidelines:
- Write production-quality, clean, and efficient code
- Include meaningful variable names and comments
- Provide the most optimal solution (best time/space complexity)
- Explain the algorithm step-by-step
- Include key insights that help understand the problem
- Mention important edge cases to consider
- Use proper coding conventions for the specified language
- Make the explanation educational and easy to understand
''';
  }

  String _buildExplanationPrompt({
    required String question,
    required String solutionCode,
    required String language,
  }) {
    return '''
You are an expert coding tutor. Analyze this solution code and provide a comprehensive explanation.

PROBLEM:
$question

SOLUTION CODE ($language):
$solutionCode

Provide response in this EXACT JSON format:
{
  "explanation": "<detailed line-by-line explanation of the code>",
  "algorithm": "<name and description of the algorithm used>",
  "walkthrough": "<step-by-step walkthrough with example>",
  "time_complexity": "<Big O time complexity with detailed analysis>",
  "space_complexity": "<Big O space complexity with detailed analysis>",
  "strengths": ["<strength 1>", "<strength 2>"],
  "potential_improvements": ["<improvement 1>", "<improvement 2>"]
}

Guidelines:
- Explain each significant line or block of code
- Identify the algorithm or technique used
- Provide a walkthrough with a concrete example
- Analyze time and space complexity thoroughly
- Highlight the strengths of this approach
- Suggest potential improvements if any
''';
  }

  Future<String?> _makeCerebrasRequest(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: ApiConfig.cerebrasHeaders,
        body: jsonEncode({
          'model': ApiConfig.cerebrasModel,
          'messages': [
            {
              'role': 'system',
              'content': 'You are an expert coding tutor and competitive programming mentor. Always respond with valid JSON format as requested.',
            },
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'max_tokens': 2000,
          'temperature': 0.3, // Lower temperature for more consistent code generation
          'top_p': 0.9,
        }),
      ).timeout(const Duration(seconds: 45)); // Longer timeout for solution generation

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices']?[0]?['message']?['content'];
        log('CerebrasAIService: Got response: ${content?.substring(0, 200)}...');
        return content;
      } else {
        log('CerebrasAIService: Request failed with status: ${response.statusCode}');
        log('CerebrasAIService: Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      log('CerebrasAIService: Error making request: $e');
      return null;
    }
  }

  Map<String, dynamic> _parseSolutionResponse(String response) {
    try {
      // Try to extract JSON from response
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(response);
      if (jsonMatch != null) {
        final jsonStr = jsonMatch.group(0)!;
        final parsed = jsonDecode(jsonStr);
        
        return {
          'code': parsed['code']?.toString() ?? _getDefaultCode('python'),
          'explanation': parsed['explanation']?.toString() ?? 'Here\'s an optimal solution for this problem.',
          'approach': parsed['approach']?.toString() ?? 'Standard algorithmic approach',
          'time_complexity': parsed['time_complexity']?.toString() ?? 'O(n)',
          'space_complexity': parsed['space_complexity']?.toString() ?? 'O(1)',
          'key_insights': _parseStringList(parsed['key_insights']) ?? ['Focus on the problem constraints', 'Consider edge cases'],
          'edge_cases': _parseStringList(parsed['edge_cases']) ?? ['Empty input', 'Single element'],
          'optimization_tips': parsed['optimization_tips']?.toString() ?? 'Consider space-time tradeoffs',
        };
      }
    } catch (e) {
      log('CerebrasAIService: Error parsing solution response: $e');
    }
    
    return _createFallbackSolution('python');
  }

  Map<String, dynamic> _parseExplanationResponse(String response) {
    try {
      // Try to extract JSON from response
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(response);
      if (jsonMatch != null) {
        final jsonStr = jsonMatch.group(0)!;
        final parsed = jsonDecode(jsonStr);
        
        return {
          'explanation': parsed['explanation']?.toString() ?? 'This solution implements an efficient algorithm.',
          'algorithm': parsed['algorithm']?.toString() ?? 'Standard algorithm',
          'walkthrough': parsed['walkthrough']?.toString() ?? 'Step-by-step execution of the solution.',
          'time_complexity': parsed['time_complexity']?.toString() ?? 'O(n)',
          'space_complexity': parsed['space_complexity']?.toString() ?? 'O(1)',
          'strengths': _parseStringList(parsed['strengths']) ?? ['Efficient', 'Clean code'],
          'potential_improvements': _parseStringList(parsed['potential_improvements']) ?? ['Consider edge cases'],
        };
      }
    } catch (e) {
      log('CerebrasAIService: Error parsing explanation response: $e');
    }
    
    return _createFallbackExplanation();
  }

  List<String>? _parseStringList(dynamic list) {
    if (list is List) {
      return list.map((item) => item.toString()).toList();
    }
    return null;
  }

  Map<String, dynamic> _createFallbackSolution(String language, {String? question}) {
    // Generate solution based on the specific question or default to Two Sum
    String code = '';
    String explanation = '';
    
    // Check if it's a specific question type
    if (question != null && question.toLowerCase().contains('reverse')) {
      return _createReverseStringSolution(language);
    } else if (question != null && question.toLowerCase().contains('palindrome')) {
      return _createPalindromeSolution(language);
    } else if (question != null && question.toLowerCase().contains('fibonacci')) {
      return _createFibonacciSolution(language);
    } else if (question != null && question.toLowerCase().contains('factorial')) {
      return _createFactorialSolution(language);
    } else if (question != null && question.toLowerCase().contains('binary search')) {
      return _createBinarySearchSolution(language);
    }
    
    // Default to Two Sum solution
    switch (language.toLowerCase()) {
      case 'python':
        code = '''def two_sum(nums, target):
    """
    Find two numbers in array that add up to target
    Time: O(n), Space: O(n)
    """
    num_map = {}
    
    for i, num in enumerate(nums):
        complement = target - num
        if complement in num_map:
            return [num_map[complement], i]
        num_map[num] = i
    
    return []

# Test the solution
nums = [2, 7, 11, 15]
target = 9
result = two_sum(nums, target)
print(result)  # Output: [0, 1]''';
        explanation = 'Uses a hash map to store numbers and their indices. For each number, calculates the complement needed to reach the target and checks if it exists in the map.';
        break;
        
      case 'java':
        code = '''import java.util.*;

public class Solution {
    public int[] twoSum(int[] nums, int target) {
        Map<Integer, Integer> map = new HashMap<>();
        
        for (int i = 0; i < nums.length; i++) {
            int complement = target - nums[i];
            if (map.containsKey(complement)) {
                return new int[] {map.get(complement), i};
            }
            map.put(nums[i], i);
        }
        
        return new int[0];
    }
    
    // Test
    public static void main(String[] args) {
        Solution sol = new Solution();
        int[] nums = {2, 7, 11, 15};
        int target = 9;
        int[] result = sol.twoSum(nums, target);
        System.out.println(Arrays.toString(result)); // [0, 1]
    }
}''';
        explanation = 'Java implementation using HashMap to store numbers and indices. Returns array of indices when complement is found.';
        break;
        
      case 'cpp':
      case 'c++':
        code = '''#include <vector>
#include <unordered_map>
#include <iostream>
using namespace std;

class Solution {
public:
    vector<int> twoSum(vector<int>& nums, int target) {
        unordered_map<int, int> numMap;
        
        for (int i = 0; i < nums.size(); i++) {
            int complement = target - nums[i];
            if (numMap.find(complement) != numMap.end()) {
                return {numMap[complement], i};
            }
            numMap[nums[i]] = i;
        }
        
        return {};
    }
};

// Test
int main() {
    Solution sol;
    vector<int> nums = {2, 7, 11, 15};
    int target = 9;
    vector<int> result = sol.twoSum(nums, target);
    cout << "[" << result[0] << ", " << result[1] << "]" << endl; // [0, 1]
    return 0;
}''';
        explanation = 'C++ solution using unordered_map for O(1) average lookup time. Returns vector of indices.';
        break;
        
      case 'javascript':
        code = '''function twoSum(nums, target) {
    const numMap = new Map();
    
    for (let i = 0; i < nums.length; i++) {
        const complement = target - nums[i];
        if (numMap.has(complement)) {
            return [numMap.get(complement), i];
        }
        numMap.set(nums[i], i);
    }
    
    return [];
}

// Test the solution
const nums = [2, 7, 11, 15];
const target = 9;
const result = twoSum(nums, target);
console.log(result); // [0, 1]''';
        explanation = 'JavaScript implementation using Map object for efficient key-value storage and lookup.';
        break;
        
      default:
        code = _getDefaultCode(language);
        explanation = 'This is a template solution. Please implement the Two Sum algorithm.';
    }
    
    return {
      'code': code,
      'explanation': explanation,
      'timeComplexity': 'O(n)',
      'spaceComplexity': 'O(n)',
      'approach': 'Hash Map',
      'keyPoints': [
        'Use hash map for O(1) lookups',
        'Single pass through array',
        'Store complement values'
      ],
      'tags': ['Array', 'Hash Table', 'Two Pointers']
    };
  }

  Map<String, dynamic> _createFallbackExplanation() {
    return {
      'explanation': 'The AI explanation service is currently unavailable. Please analyze the code step by step.',
      'algorithm': 'Standard algorithm',
      'walkthrough': 'Trace through the code with sample input to understand the flow.',
      'time_complexity': 'Analyze the loops and recursive calls',
      'space_complexity': 'Consider additional data structures used',
      'strengths': ['Clean implementation', 'Handles basic cases'],
      'potential_improvements': ['Consider optimization opportunities', 'Add error handling'],
    };
  }

  String _getDefaultCode(String language) {
    switch (language.toLowerCase()) {
      case 'python':
        return '''def solution():
    """
    Implement your solution here
    """
    # Your code goes here
    pass

# Test the solution
if __name__ == "__main__":
    result = solution()
    print(result)''';
      
      case 'java':
        return '''public class Solution {
    public static void main(String[] args) {
        // Your solution goes here
        System.out.println("Implement your solution");
    }
    
    // Implement your method here
    public static void solve() {
        // Your code goes here
    }
}''';
      
      case 'cpp':
        return '''#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;

int main() {
    // Your solution goes here
    cout << "Implement your solution" << endl;
    return 0;
}''';
      
      case 'javascript':
        return '''function solution() {
    // Your solution goes here
    return "Implement your solution";
}

// Test the solution
console.log(solution());''';
      
      default:
        return '// Implement your solution here\nprint("Hello, World!")';
    }
  }

  Map<String, dynamic> _createReverseStringSolution(String language) {
    String code = '';
    String explanation = '';
    
    switch (language.toLowerCase()) {
      case 'python':
        code = '''def reverse_string(s):
    """
    Reverse a string using two pointers
    Time: O(n), Space: O(1)
    """
    left, right = 0, len(s) - 1
    s = list(s)  # Convert to list for mutability
    
    while left < right:
        s[left], s[right] = s[right], s[left]
        left += 1
        right -= 1
    
    return ''.join(s)

# Example usage
result = reverse_string("hello")
print(result)  # Output: "olleh"''';
        explanation = 'This solution uses the two-pointer technique to reverse a string in-place. We start with pointers at both ends and swap characters while moving towards the center.';
        break;
        
      case 'java':
        code = '''public class Solution {
    public void reverseString(char[] s) {
        /*
         * Reverse string using two pointers
         * Time: O(n), Space: O(1)
         */
        int left = 0;
        int right = s.length - 1;
        
        while (left < right) {
            char temp = s[left];
            s[left] = s[right];
            s[right] = temp;
            left++;
            right--;
        }
    }
}''';
        explanation = 'This Java solution reverses a character array in-place using two pointers. We swap characters from both ends moving towards the center.';
        break;
        
      case 'javascript':
        code = '''function reverseString(s) {
    /*
     * Reverse string using two pointers
     * Time: O(n), Space: O(1)
     */
    let left = 0;
    let right = s.length - 1;
    
    while (left < right) {
        [s[left], s[right]] = [s[right], s[left]];
        left++;
        right--;
    }
    
    return s;
}''';
        explanation = 'This JavaScript solution uses array destructuring to swap characters at two pointers, efficiently reversing the string in-place.';
        break;
        
      default:
        code = '''def reverse_string(s):
    left, right = 0, len(s) - 1
    s = list(s)
    while left < right:
        s[left], s[right] = s[right], s[left]
        left += 1
        right -= 1
    return ''.join(s)''';
        explanation = 'Two-pointer approach to reverse a string efficiently.';
    }
    
    return {
      'code': code,
      'explanation': explanation,
      'timeComplexity': 'O(n)',
      'spaceComplexity': 'O(1)',
      'approach': 'Two Pointers',
      'keyPoints': [
        'Use two pointers from both ends',
        'Swap characters while moving inward',
        'In-place reversal for optimal space'
      ],
      'tags': ['String', 'Two Pointers']
    };
  }

  Map<String, dynamic> _createPalindromeSolution(String language) {
    String code = '';
    String explanation = '';
    
    switch (language.toLowerCase()) {
      case 'python':
        code = '''def is_palindrome(s):
    """
    Check if string is palindrome (case-insensitive, alphanumeric only)
    Time: O(n), Space: O(1)
    """
    left, right = 0, len(s) - 1
    
    while left < right:
        # Skip non-alphanumeric characters
        while left < right and not s[left].isalnum():
            left += 1
        while left < right and not s[right].isalnum():
            right -= 1
        
        # Compare characters (case-insensitive)
        if s[left].lower() != s[right].lower():
            return False
        
        left += 1
        right -= 1
    
    return True

# Example usage
result = is_palindrome("A man, a plan, a canal: Panama")
print(result)  # Output: True''';
        explanation = 'This solution uses two pointers to check palindrome while skipping non-alphanumeric characters and ignoring case.';
        break;
        
      case 'java':
        code = '''public class Solution {
    public boolean isPalindrome(String s) {
        /*
         * Check palindrome ignoring case and non-alphanumeric
         * Time: O(n), Space: O(1)
         */
        int left = 0;
        int right = s.length() - 1;
        
        while (left < right) {
            // Skip non-alphanumeric characters
            while (left < right && !Character.isLetterOrDigit(s.charAt(left))) {
                left++;
            }
            while (left < right && !Character.isLetterOrDigit(s.charAt(right))) {
                right--;
            }
            
            // Compare characters (case-insensitive)
            if (Character.toLowerCase(s.charAt(left)) != 
                Character.toLowerCase(s.charAt(right))) {
                return false;
            }
            
            left++;
            right--;
        }
        
        return true;
    }
}''';
        explanation = 'Java solution using two pointers to validate palindrome with proper character filtering and case handling.';
        break;
        
      default:
        code = '''def is_palindrome(s):
    left, right = 0, len(s) - 1
    while left < right:
        while left < right and not s[left].isalnum():
            left += 1
        while left < right and not s[right].isalnum():
            right -= 1
        if s[left].lower() != s[right].lower():
            return False
        left += 1
        right -= 1
    return True''';
        explanation = 'Two-pointer palindrome check with character filtering.';
    }
    
    return {
      'code': code,
      'explanation': explanation,
      'timeComplexity': 'O(n)',
      'spaceComplexity': 'O(1)',
      'approach': 'Two Pointers',
      'keyPoints': [
        'Skip non-alphanumeric characters',
        'Case-insensitive comparison',
        'Two pointers from both ends'
      ],
      'tags': ['String', 'Two Pointers']
    };
  }

  Map<String, dynamic> _createFibonacciSolution(String language) {
    String code = '';
    String explanation = '';
    
    switch (language.toLowerCase()) {
      case 'python':
        code = '''def fibonacci(n):
    """
    Calculate nth Fibonacci number using dynamic programming
    Time: O(n), Space: O(1)
    """
    if n <= 1:
        return n
    
    prev, curr = 0, 1
    
    for i in range(2, n + 1):
        next_fib = prev + curr
        prev = curr
        curr = next_fib
    
    return curr

# Example usage
result = fibonacci(10)
print(f"10th Fibonacci number: {result}")  # Output: 55''';
        explanation = 'This solution uses dynamic programming with O(1) space to calculate Fibonacci numbers efficiently.';
        break;
        
      case 'java':
        code = '''public class Solution {
    public int fibonacci(int n) {
        /*
         * Calculate nth Fibonacci using DP
         * Time: O(n), Space: O(1)
         */
        if (n <= 1) {
            return n;
        }
        
        int prev = 0, curr = 1;
        
        for (int i = 2; i <= n; i++) {
            int nextFib = prev + curr;
            prev = curr;
            curr = nextFib;
        }
        
        return curr;
    }
}''';
        explanation = 'Java implementation using iterative approach with constant space complexity for Fibonacci calculation.';
        break;
        
      default:
        code = '''def fibonacci(n):
    if n <= 1:
        return n
    prev, curr = 0, 1
    for i in range(2, n + 1):
        prev, curr = curr, prev + curr
    return curr''';
        explanation = 'Iterative Fibonacci calculation with optimal space complexity.';
    }
    
    return {
      'code': code,
      'explanation': explanation,
      'timeComplexity': 'O(n)',
      'spaceComplexity': 'O(1)',
      'approach': 'Dynamic Programming',
      'keyPoints': [
        'Iterative approach for efficiency',
        'Constant space optimization',
        'Handle base cases properly'
      ],
      'tags': ['Dynamic Programming', 'Math']
    };
  }

  Map<String, dynamic> _createFactorialSolution(String language) {
    String code = '';
    String explanation = '';
    
    switch (language.toLowerCase()) {
      case 'python':
        code = '''def factorial(n):
    """
    Calculate factorial using iterative approach
    Time: O(n), Space: O(1)
    """
    if n < 0:
        raise ValueError("Factorial not defined for negative numbers")
    
    result = 1
    for i in range(1, n + 1):
        result *= i
    
    return result

# Example usage
result = factorial(5)
print(f"5! = {result}")  # Output: 120''';
        explanation = 'This solution provides iterative approach to calculate factorial, which is more space-efficient than recursion.';
        break;
        
      case 'java':
        code = '''public class Solution {
    public long factorial(int n) {
        /*
         * Calculate factorial iteratively
         * Time: O(n), Space: O(1)
         */
        if (n < 0) {
            throw new IllegalArgumentException("Factorial not defined for negative numbers");
        }
        
        long result = 1;
        for (int i = 1; i <= n; i++) {
            result *= i;
        }
        
        return result;
    }
}''';
        explanation = 'Java implementation with iterative factorial method, using long to handle larger results.';
        break;
        
      default:
        code = '''def factorial(n):
    if n < 0:
        return None
    result = 1
    for i in range(1, n + 1):
        result *= i
    return result''';
        explanation = 'Simple iterative factorial calculation.';
    }
    
    return {
      'code': code,
      'explanation': explanation,
      'timeComplexity': 'O(n)',
      'spaceComplexity': 'O(1)',
      'approach': 'Iteration',
      'keyPoints': [
        'Iterative approach for efficiency',
        'Handle edge cases (negative numbers)',
        'Consider overflow for large numbers'
      ],
      'tags': ['Math', 'Recursion']
    };
  }

  Map<String, dynamic> _createBinarySearchSolution(String language) {
    String code = '';
    String explanation = '';
    
    switch (language.toLowerCase()) {
      case 'python':
        code = '''def binary_search(nums, target):
    """
    Binary search in sorted array
    Time: O(log n), Space: O(1)
    """
    left, right = 0, len(nums) - 1
    
    while left <= right:
        mid = left + (right - left) // 2
        
        if nums[mid] == target:
            return mid
        elif nums[mid] < target:
            left = mid + 1
        else:
            right = mid - 1
    
    return -1  # Target not found

# Example usage
arr = [1, 3, 5, 7, 9, 11, 13]
result = binary_search(arr, 7)
print(f"Index of 7: {result}")  # Output: 3''';
        explanation = 'This solution implements binary search on a sorted array, repeatedly dividing the search space in half.';
        break;
        
      case 'java':
        code = '''public class Solution {
    public int binarySearch(int[] nums, int target) {
        /*
         * Binary search implementation
         * Time: O(log n), Space: O(1)
         */
        int left = 0;
        int right = nums.length - 1;
        
        while (left <= right) {
            int mid = left + (right - left) / 2;
            
            if (nums[mid] == target) {
                return mid;
            } else if (nums[mid] < target) {
                left = mid + 1;
            } else {
                right = mid - 1;
            }
        }
        
        return -1; // Target not found
    }
}''';
        explanation = 'Java implementation of binary search with proper overflow prevention in mid calculation.';
        break;
        
      default:
        code = '''def binary_search(nums, target):
    left, right = 0, len(nums) - 1
    while left <= right:
        mid = left + (right - left) // 2
        if nums[mid] == target:
            return mid
        elif nums[mid] < target:
            left = mid + 1
        else:
            right = mid - 1
    return -1''';
        explanation = 'Standard binary search implementation.';
    }
    
    return {
      'code': code,
      'explanation': explanation,
      'timeComplexity': 'O(log n)',
      'spaceComplexity': 'O(1)',
      'approach': 'Binary Search',
      'keyPoints': [
        'Array must be sorted',
        'Divide search space in half each iteration',
        'Prevent integer overflow in mid calculation'
      ],
      'tags': ['Array', 'Binary Search']
    };
  }
}
