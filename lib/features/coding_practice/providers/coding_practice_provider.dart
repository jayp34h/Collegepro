import 'dart:developer';
import 'package:flutter/material.dart';
import '../models/coding_question.dart';
import '../models/submission.dart';
import '../models/leaderboard_entry.dart';
import '../services/judge0_service.dart';
import '../services/groq_ai_service.dart';
import '../services/cerebras_ai_service.dart';
import '../services/coding_storage_service.dart';

class CodingPracticeProvider extends ChangeNotifier {
  final Judge0Service _judge0Service = Judge0Service();
  final GroqAIService _groqService = GroqAIService(); // For feedback
  final CerebrasAIService _cerebrasService = CerebrasAIService(); // For solutions

  // Current state
  CodingQuestion? _currentQuestion;
  String _currentCode = '';
  String _selectedLanguage = 'python';
  int _selectedLanguageId = 71;
  bool _isExecuting = false;
  bool _isGettingFeedback = false;
  bool _isGeneratingSolution = false;
  bool _isLoading = false;
  String? _error;
  List<CodingQuestion> _questions = [];

  // Results
  Map<String, dynamic>? _executionResult;
  Map<String, dynamic>? _aiFeedback;
  Map<String, dynamic>? _solutionData;
  List<Submission> _submissions = [];
  List<LeaderboardEntry> _leaderboard = [];

  // Real company coding questions
  final List<CodingQuestion> _sampleQuestions = [
    // Google Interview Questions
    CodingQuestion(
      id: 'google_1',
      title: 'Two Sum (Google)',
      description: 'Given an array of integers nums and an integer target, return indices of the two numbers such that they add up to target.\n\nYou may assume that each input would have exactly one solution, and you may not use the same element twice.\n\nExample 1:\nInput: nums = [2,7,11,15], target = 9\nOutput: [0,1]\nExplanation: Because nums[0] + nums[1] == 2 + 7 == 9, we return [0, 1].\n\nExample 2:\nInput: nums = [3,2,4], target = 6\nOutput: [1,2]',
      difficulty: 'Easy',
      tags: ['Array', 'Hash Table', 'Google'],
      sampleInput: '[2,7,11,15]\n9',
      expectedOutput: '[0, 1]',
      solutionCode: '''def two_sum(nums, target):
    """
    Time Complexity: O(n)
    Space Complexity: O(n)
    """
    num_map = {}
    for i, num in enumerate(nums):
        complement = target - num
        if complement in num_map:
            return [num_map[complement], i]
        num_map[num] = i
    return []

# Test cases
nums = [2, 7, 11, 15]
target = 9
result = two_sum(nums, target)
print(result)  # [0, 1]

nums2 = [3, 2, 4]
target2 = 6
result2 = two_sum(nums2, target2)
print(result2)  # [1, 2]''',
      solutionExplanation: 'Use a hash map to store numbers and their indices. For each number, check if its complement (target - current number) exists in the map. This reduces time complexity from O(n²) to O(n).',
    ),
    
    // Amazon Interview Question
    CodingQuestion(
      id: 'amazon_1',
      title: 'Valid Parentheses (Amazon)',
      description: 'Given a string s containing just the characters \'(\', \')\', \'{\', \'}\', \'[\' and \']\', determine if the input string is valid.\n\nAn input string is valid if:\n1. Open brackets must be closed by the same type of brackets.\n2. Open brackets must be closed in the correct order.\n3. Every close bracket has a corresponding open bracket of the same type.\n\nExample 1:\nInput: s = "()"\nOutput: true\n\nExample 2:\nInput: s = "()[]{}"\nOutput: true\n\nExample 3:\nInput: s = "(]"\nOutput: false',
      difficulty: 'Easy',
      tags: ['String', 'Stack', 'Amazon'],
      sampleInput: '()[]{}',
      expectedOutput: 'true',
      solutionCode: '''def is_valid(s):
    """
    Time Complexity: O(n)
    Space Complexity: O(n)
    """
    stack = []
    mapping = {')': '(', '}': '{', ']': '['}
    
    for char in s:
        if char in mapping:
            # Closing bracket
            if not stack or stack.pop() != mapping[char]:
                return False
        else:
            # Opening bracket
            stack.append(char)
    
    return len(stack) == 0

# Test cases
test1 = "()"
print(is_valid(test1))  # True

test2 = "()[]{}"
print(is_valid(test2))  # True

test3 = "(]"
print(is_valid(test3))  # False

test4 = "([)]"
print(is_valid(test4))  # False''',
      solutionExplanation: 'Use a stack to keep track of opening brackets. When encountering a closing bracket, check if it matches the most recent opening bracket. The string is valid if the stack is empty at the end.',
    ),
    
    // Microsoft Interview Question
    CodingQuestion(
      id: 'microsoft_1',
      title: 'Reverse Linked List (Microsoft)',
      description: 'Given the head of a singly linked list, reverse the list, and return the reversed list.\n\nExample 1:\nInput: head = [1,2,3,4,5]\nOutput: [5,4,3,2,1]\n\nExample 2:\nInput: head = [1,2]\nOutput: [2,1]\n\nExample 3:\nInput: head = []\nOutput: []',
      difficulty: 'Easy',
      tags: ['Linked List', 'Recursion', 'Microsoft'],
      sampleInput: '[1,2,3,4,5]',
      expectedOutput: '[5,4,3,2,1]',
      solutionCode: '''class ListNode:
    def __init__(self, val=0, next=None):
        self.val = val
        self.next = next

def reverse_list(head):
    """
    Iterative approach
    Time Complexity: O(n)
    Space Complexity: O(1)
    """
    prev = None
    current = head
    
    while current:
        next_temp = current.next
        current.next = prev
        prev = current
        current = next_temp
    
    return prev

def reverse_list_recursive(head):
    """
    Recursive approach
    Time Complexity: O(n)
    Space Complexity: O(n) - due to recursion stack
    """
    if not head or not head.next:
        return head
    
    reversed_head = reverse_list_recursive(head.next)
    head.next.next = head
    head.next = None
    
    return reversed_head

# Helper function to create linked list from array
def create_linked_list(arr):
    if not arr:
        return None
    head = ListNode(arr[0])
    current = head
    for val in arr[1:]:
        current.next = ListNode(val)
        current = current.next
    return head

# Helper function to convert linked list to array
def linked_list_to_array(head):
    result = []
    current = head
    while current:
        result.append(current.val)
        current = current.next
    return result

# Test
original = create_linked_list([1, 2, 3, 4, 5])
reversed_list = reverse_list(original)
result = linked_list_to_array(reversed_list)
print(result)  # [5, 4, 3, 2, 1]''',
      solutionExplanation: 'Iteratively reverse the pointers of each node. Keep track of previous, current, and next nodes. The previous node becomes the new head.',
    ),
    
    // Facebook/Meta Interview Question
    CodingQuestion(
      id: 'meta_1',
      title: 'Maximum Subarray (Meta)',
      description: 'Given an integer array nums, find the contiguous subarray (containing at least one number) which has the largest sum and return its sum.\n\nA subarray is a contiguous part of an array.\n\nExample 1:\nInput: nums = [-2,1,-3,4,-1,2,1,-5,4]\nOutput: 6\nExplanation: [4,-1,2,1] has the largest sum = 6.\n\nExample 2:\nInput: nums = [1]\nOutput: 1\n\nExample 3:\nInput: nums = [5,4,-1,7,8]\nOutput: 23',
      difficulty: 'Medium',
      tags: ['Array', 'Dynamic Programming', 'Divide and Conquer', 'Meta'],
      sampleInput: '[-2,1,-3,4,-1,2,1,-5,4]',
      expectedOutput: '6',
      solutionCode: '''def max_subarray(nums):
    """
    Kadane's Algorithm
    Time Complexity: O(n)
    Space Complexity: O(1)
    """
    if not nums:
        return 0
    
    max_sum = nums[0]
    current_sum = nums[0]
    
    for i in range(1, len(nums)):
        # Either extend the existing subarray or start a new one
        current_sum = max(nums[i], current_sum + nums[i])
        max_sum = max(max_sum, current_sum)
    
    return max_sum

def max_subarray_with_indices(nums):
    """
    Returns both max sum and the subarray indices
    """
    if not nums:
        return 0, 0, 0
    
    max_sum = nums[0]
    current_sum = nums[0]
    start = 0
    end = 0
    temp_start = 0
    
    for i in range(1, len(nums)):
        if current_sum < 0:
            current_sum = nums[i]
            temp_start = i
        else:
            current_sum += nums[i]
        
        if current_sum > max_sum:
            max_sum = current_sum
            start = temp_start
            end = i
    
    return max_sum, start, end

# Test cases
nums1 = [-2, 1, -3, 4, -1, 2, 1, -5, 4]
result1 = max_subarray(nums1)
print(f"Max sum: {result1}")  # 6

nums2 = [1]
result2 = max_subarray(nums2)
print(f"Max sum: {result2}")  # 1

nums3 = [5, 4, -1, 7, 8]
result3 = max_subarray(nums3)
print(f"Max sum: {result3}")  # 23

# With indices
max_sum, start, end = max_subarray_with_indices(nums1)
print(f"Max sum: {max_sum}, Subarray: {nums1[start:end+1]}")''',
      solutionExplanation: 'Use Kadane\'s algorithm. At each position, decide whether to extend the current subarray or start a new one. Keep track of the maximum sum seen so far.',
    ),
    
    // Apple Interview Question
    CodingQuestion(
      id: 'apple_1',
      title: 'Binary Tree Level Order Traversal (Apple)',
      description: 'Given the root of a binary tree, return the level order traversal of its nodes\' values. (i.e., from left to right, level by level).\n\nExample 1:\nInput: root = [3,9,20,null,null,15,7]\nOutput: [[3],[9,20],[15,7]]\n\nExample 2:\nInput: root = [1]\nOutput: [[1]]\n\nExample 3:\nInput: root = []\nOutput: []',
      difficulty: 'Medium',
      tags: ['Tree', 'Breadth-First Search', 'Binary Tree', 'Apple'],
      sampleInput: '[3,9,20,null,null,15,7]',
      expectedOutput: '[[3],[9,20],[15,7]]',
      solutionCode: '''from collections import deque

class TreeNode:
    def __init__(self, val=0, left=None, right=None):
        self.val = val
        self.left = left
        self.right = right

def level_order(root):
    """
    BFS approach using queue
    Time Complexity: O(n)
    Space Complexity: O(n)
    """
    if not root:
        return []
    
    result = []
    queue = deque([root])
    
    while queue:
        level_size = len(queue)
        current_level = []
        
        for _ in range(level_size):
            node = queue.popleft()
            current_level.append(node.val)
            
            if node.left:
                queue.append(node.left)
            if node.right:
                queue.append(node.right)
        
        result.append(current_level)
    
    return result

# Helper function to create binary tree from array
def create_binary_tree(arr):
    if not arr:
        return None
    
    root = TreeNode(arr[0])
    queue = deque([root])
    i = 1
    
    while queue and i < len(arr):
        node = queue.popleft()
        
        if i < len(arr) and arr[i] is not None:
            node.left = TreeNode(arr[i])
            queue.append(node.left)
        i += 1
        
        if i < len(arr) and arr[i] is not None:
            node.right = TreeNode(arr[i])
            queue.append(node.right)
        i += 1
    
    return root

# Test
tree_array = [3, 9, 20, None, None, 15, 7]
root = create_binary_tree(tree_array)
result = level_order(root)
print(result)  # [[3], [9, 20], [15, 7]]''',
      solutionExplanation: 'Use BFS with a queue. Process nodes level by level by tracking the number of nodes at each level. Add all nodes of the current level to the result before moving to the next level.',
    ),
    
    // Netflix Interview Question
    CodingQuestion(
      id: 'netflix_1',
      title: 'Longest Substring Without Repeating Characters (Netflix)',
      description: 'Given a string s, find the length of the longest substring without repeating characters.\n\nExample 1:\nInput: s = "abcabcbb"\nOutput: 3\nExplanation: The answer is "abc", with the length of 3.\n\nExample 2:\nInput: s = "bbbbb"\nOutput: 1\nExplanation: The answer is "b", with the length of 1.\n\nExample 3:\nInput: s = "pwwkew"\nOutput: 3\nExplanation: The answer is "wke", with the length of 3.',
      difficulty: 'Medium',
      tags: ['Hash Table', 'String', 'Sliding Window', 'Netflix'],
      sampleInput: 'abcabcbb',
      expectedOutput: '3',
      solutionCode: '''def length_of_longest_substring(s):
    """
    Sliding Window approach
    Time Complexity: O(n)
    Space Complexity: O(min(m,n)) where m is charset size
    """
    if not s:
        return 0
    
    char_map = {}
    left = 0
    max_length = 0
    
    for right in range(len(s)):
        if s[right] in char_map and char_map[s[right]] >= left:
            # Move left pointer to avoid repetition
            left = char_map[s[right]] + 1
        
        char_map[s[right]] = right
        max_length = max(max_length, right - left + 1)
    
    return max_length

def length_of_longest_substring_with_substring(s):
    """
    Returns both length and the actual substring
    """
    if not s:
        return 0, ""
    
    char_map = {}
    left = 0
    max_length = 0
    max_start = 0
    
    for right in range(len(s)):
        if s[right] in char_map and char_map[s[right]] >= left:
            left = char_map[s[right]] + 1
        
        char_map[s[right]] = right
        
        if right - left + 1 > max_length:
            max_length = right - left + 1
            max_start = left
    
    return max_length, s[max_start:max_start + max_length]

# Test cases
test1 = "abcabcbb"
result1 = length_of_longest_substring(test1)
print(f"Length: {result1}")  # 3

test2 = "bbbbb"
result2 = length_of_longest_substring(test2)
print(f"Length: {result2}")  # 1

test3 = "pwwkew"
result3 = length_of_longest_substring(test3)
print(f"Length: {result3}")  # 3

# With substring
length, substring = length_of_longest_substring_with_substring(test1)
print(f"Length: {length}, Substring: '{substring}'")  # Length: 3, Substring: 'abc' ''',
      solutionExplanation: 'Use sliding window technique with two pointers. Maintain a hash map to store character positions. When a repeating character is found, move the left pointer to avoid repetition.',
    ),
    
    // Uber Interview Question
    CodingQuestion(
      id: 'uber_1',
      title: 'Group Anagrams (Uber)',
      description: '''Given an array of strings strs, group the anagrams together. You can return the answer in any order.

An Anagram is a word or phrase formed by rearranging the letters of a different word or phrase, typically using all the original letters exactly once.

Example 1:
Input: strs = ["eat","tea","tan","ate","nat","bat"]
Output: [["bat"],["nat","tan"],["ate","eat","tea"]]

Example 2:
Input: strs = [""]
Output: [[""]]

Example 3:
Input: strs = ["a"]
Output: [["a"]]

Constraints:
- 1 <= strs.length <= 10^4
- 0 <= strs[i].length <= 100
- strs[i] consists of lowercase English letters only.''',
      difficulty: 'Medium',
      tags: ['Array', 'Hash Table', 'String', 'Sorting', 'Uber'],
      sampleInput: '["eat","tea","tan","ate","nat","bat"]',
      expectedOutput: '[["bat"],["nat","tan"],["ate","eat","tea"]]',
      solutionCode: '''def group_anagrams(strs):
    """
    Group anagrams using sorted string as key.
    
    Time Complexity: O(n * k * log k) where n is number of strings, k is max length
    Space Complexity: O(n * k) for storing the groups
    """
    from collections import defaultdict
    
    anagram_groups = defaultdict(list)
    
    for s in strs:
        # Sort the string to create a key for anagrams
        key = ''.join(sorted(s))
        anagram_groups[key].append(s)
    
    return list(anagram_groups.values())

# Test the function
strs = ["eat","tea","tan","ate","nat","bat"]
result = group_anagrams(strs)
print(result)''',
      solutionExplanation: '''The key insight is that anagrams will have the same characters when sorted. We use a hash map where the key is the sorted version of each string, and the value is a list of all strings that are anagrams of each other. This efficiently groups all anagrams together in O(n * k * log k) time.''',
    ),
    
    // Additional Google Questions
    CodingQuestion(
      id: 'google_2',
      title: 'Merge Intervals (Google)',
      description: '''Given an array of intervals where intervals[i] = [starti, endi], merge all overlapping intervals, and return an array of the non-overlapping intervals that cover all the intervals in the input.

Example 1:
Input: intervals = [[1,3],[2,6],[8,10],[15,18]]
Output: [[1,6],[8,10],[15,18]]
Explanation: Since intervals [1,3] and [2,6] overlap, merge them into [1,6].

Example 2:
Input: intervals = [[1,4],[4,5]]
Output: [[1,5]]
Explanation: Intervals [1,4] and [4,5] are considered overlapping.

Constraints:
- 1 <= intervals.length <= 10^4
- intervals[i].length == 2
- 0 <= starti <= endi <= 10^4''',
      difficulty: 'Medium',
      tags: ['Array', 'Sorting', 'Google'],
      sampleInput: '[[1,3],[2,6],[8,10],[15,18]]',
      expectedOutput: '[[1,6],[8,10],[15,18]]',
      solutionCode: '''def merge_intervals(intervals):
    """
    Merge overlapping intervals by sorting and comparing adjacent intervals.
    
    Time Complexity: O(n log n) for sorting
    Space Complexity: O(1) if we don't count output space
    """
    if not intervals:
        return []
    
    # Sort intervals by start time
    intervals.sort(key=lambda x: x[0])
    
    merged = [intervals[0]]
    
    for current in intervals[1:]:
        last_merged = merged[-1]
        
        # If current interval overlaps with the last merged interval
        if current[0] <= last_merged[1]:
            # Merge by updating the end time
            last_merged[1] = max(last_merged[1], current[1])
        else:
            # No overlap, add current interval
            merged.append(current)
    
    return merged

# Test the function
intervals = [[1,3],[2,6],[8,10],[15,18]]
result = merge_intervals(intervals)
print(result)''',
      solutionExplanation: '''Sort intervals by start time, then iterate through them. If the current interval overlaps with the last merged interval (current start <= last end), merge them by updating the end time. Otherwise, add the current interval as a new non-overlapping interval.''',
    ),

    // Additional Amazon Questions
    CodingQuestion(
      id: 'amazon_2',
      title: 'LRU Cache (Amazon)',
      description: '''Design a data structure that follows the constraints of a Least Recently Used (LRU) cache.

Implement the LRUCache class:
- LRUCache(int capacity) Initialize the LRU cache with positive size capacity.
- int get(int key) Return the value of the key if the key exists, otherwise return -1.
- void put(int key, int value) Update the value of the key if the key exists. Otherwise, add the key-value pair to the cache. If the number of keys exceeds the capacity from this operation, evict the least recently used key.

The functions get and put must each run in O(1) average time complexity.

Example:
Input: ["LRUCache", "put", "put", "get", "put", "get", "put", "get", "get", "get"]
[[2], [1, 1], [2, 2], [1], [3, 3], [2], [4, 4], [1], [3], [4]]
Output: [null, null, null, 1, null, -1, null, -1, 3, 4]''',
      difficulty: 'Medium',
      tags: ['Hash Table', 'Linked List', 'Design', 'Amazon'],
      sampleInput: 'capacity = 2, operations = ["put(1,1)", "put(2,2)", "get(1)", "put(3,3)", "get(2)"]',
      expectedOutput: '[null, null, 1, null, -1]',
      solutionCode: '''class Node:
    def __init__(self, key=0, value=0):
        self.key = key
        self.value = value
        self.prev = None
        self.next = None

class LRUCache:
    """
    LRU Cache implementation using HashMap + Doubly Linked List
    
    Time Complexity: O(1) for both get and put operations
    Space Complexity: O(capacity)
    """
    
    def __init__(self, capacity: int):
        self.capacity = capacity
        self.cache = {}  # key -> node
        
        # Create dummy head and tail nodes
        self.head = Node()
        self.tail = Node()
        self.head.next = self.tail
        self.tail.prev = self.head
    
    def get(self, key: int) -> int:
        node = self.cache.get(key)
        if node:
            self._move_to_head(node)
            return node.value
        return -1
    
    def put(self, key: int, value: int) -> None:
        node = self.cache.get(key)
        if node:
            node.value = value
            self._move_to_head(node)
        else:
            new_node = Node(key, value)
            if len(self.cache) >= self.capacity:
                tail = self._pop_tail()
                del self.cache[tail.key]
            self.cache[key] = new_node
            self._add_node(new_node)

# Test the LRU Cache
lru = LRUCache(2)
lru.put(1, 1)
print(lru.get(1))  # returns 1''',
      solutionExplanation: '''Use a combination of HashMap and Doubly Linked List. HashMap provides O(1) access to nodes, while the doubly linked list maintains the order of usage. Most recently used items are near the head, least recently used near the tail.''',
    ),

    // Additional Microsoft Questions
    CodingQuestion(
      id: 'microsoft_2',
      title: 'Word Ladder (Microsoft)',
      description: '''A transformation sequence from word beginWord to word endWord using a dictionary wordList is a sequence of words beginWord -> s1 -> s2 -> ... -> sk such that:
- Every adjacent pair of words differs by a single letter.
- Every si for 1 <= i <= k is in wordList. Note that beginWord does not need to be in wordList.
- sk == endWord

Given two words, beginWord and endWord, and a dictionary wordList, return the length of the shortest transformation sequence from beginWord to endWord, or 0 if no such sequence exists.

Example 1:
Input: beginWord = "hit", endWord = "cog", wordList = ["hot","dot","dog","lot","log","cog"]
Output: 5
Explanation: One shortest transformation sequence is "hit" -> "hot" -> "dot" -> "dog" -> "cog", which is 5 words long.''',
      difficulty: 'Hard',
      tags: ['Hash Table', 'String', 'BFS', 'Microsoft'],
      sampleInput: 'beginWord = "hit", endWord = "cog", wordList = ["hot","dot","dog","lot","log","cog"]',
      expectedOutput: '5',
      solutionCode: '''from collections import deque

def ladder_length(beginWord, endWord, wordList):
    """
    Find shortest transformation sequence using BFS.
    
    Time Complexity: O(M^2 * N) where M is length of words, N is total words
    Space Complexity: O(M^2 * N) for the adjacency list and queue
    """
    if endWord not in wordList:
        return 0
    
    wordList = set(wordList)
    queue = deque([(beginWord, 1)])
    visited = {beginWord}
    
    while queue:
        word, length = queue.popleft()
        
        if word == endWord:
            return length
        
        # Try changing each character
        for i in range(len(word)):
            for c in 'abcdefghijklmnopqrstuvwxyz':
                if c != word[i]:
                    new_word = word[:i] + c + word[i+1:]
                    
                    if new_word in wordList and new_word not in visited:
                        visited.add(new_word)
                        queue.append((new_word, length + 1))
    
    return 0

# Test the function
result = ladder_length("hit", "cog", ["hot","dot","dog","lot","log","cog"])
print(result)''',
      solutionExplanation: '''Use BFS to find the shortest transformation path. For each word, try changing each character to all possible letters and check if the resulting word is in the dictionary and not visited. BFS guarantees we find the shortest path first.''',
    ),

    // Additional Meta Questions
    CodingQuestion(
      id: 'meta_2',
      title: 'Binary Tree Right Side View (Meta)',
      description: '''Given the root of a binary tree, imagine yourself standing on the right side of it, return the values of the nodes you can see ordered from top to bottom.

Example 1:
Input: root = [1,2,3,null,5,null,4]
Output: [1,3,4]

Example 2:
Input: root = [1,null,3]
Output: [1,3]

Constraints:
- The number of nodes in the tree is in the range [0, 100].
- -100 <= Node.val <= 100''',
      difficulty: 'Medium',
      tags: ['Tree', 'DFS', 'BFS', 'Binary Tree', 'Meta'],
      sampleInput: '[1,2,3,null,5,null,4]',
      expectedOutput: '[1,3,4]',
      solutionCode: '''from collections import deque

class TreeNode:
    def __init__(self, val=0, left=None, right=None):
        self.val = val
        self.left = left
        self.right = right

def right_side_view(root):
    """
    Get right side view using level-order traversal (BFS).
    
    Time Complexity: O(n) where n is number of nodes
    Space Complexity: O(w) where w is maximum width of tree
    """
    if not root:
        return []
    
    result = []
    queue = deque([root])
    
    while queue:
        level_size = len(queue)
        
        for i in range(level_size):
            node = queue.popleft()
            
            # The last node at each level is visible from right side
            if i == level_size - 1:
                result.append(node.val)
            
            if node.left:
                queue.append(node.left)
            if node.right:
                queue.append(node.right)
    
    return result

# Test with example tree
root = TreeNode(1)
root.left = TreeNode(2)
root.right = TreeNode(3)
result = right_side_view(root)
print(result)''',
      solutionExplanation: '''Use level-order traversal (BFS) and take the rightmost node at each level. Process all nodes level by level, and the last node processed at each level will be visible from the right side.''',
    ),

    // Additional Apple Questions  
    CodingQuestion(
      id: 'apple_2',
      title: 'Design Add and Search Words Data Structure (Apple)',
      description: '''Design a data structure that supports adding new words and finding if a string matches any previously added string.

Implement the WordDictionary class:
- WordDictionary() Initializes the object.
- void addWord(word) Adds word to the data structure, it can be matched later.
- bool search(word) Returns true if there is any string in the data structure that matches word or false otherwise. word may contain dots '.' where dots can be matched with any letter.

Example:
Input: ["WordDictionary","addWord","addWord","addWord","search","search","search","search"]
[[],["bad"],["dad"],["mad"],["pad"],["bad"],[".ad"],["b.."]]
Output: [null,null,null,null,false,true,true,true]''',
      difficulty: 'Medium',
      tags: ['String', 'Design', 'Trie', 'DFS', 'Apple'],
      sampleInput: 'addWord("bad"), addWord("dad"), search(".ad")',
      expectedOutput: 'true',
      solutionCode: '''class TrieNode:
    def __init__(self):
        self.children = {}
        self.is_end_word = False

class WordDictionary:
    """
    Word Dictionary using Trie with wildcard support.
    
    Time Complexity: 
    - addWord: O(m) where m is length of word
    - search: O(n) for exact match, O(26^k * n) for wildcards
    Space Complexity: O(ALPHABET_SIZE * N * M)
    """
    
    def __init__(self):
        self.root = TrieNode()
    
    def addWord(self, word: str) -> None:
        node = self.root
        for char in word:
            if char not in node.children:
                node.children[char] = TrieNode()
            node = node.children[char]
        node.is_end_word = True
    
    def search(self, word: str) -> bool:
        return self._search_helper(word, 0, self.root)
    
    def _search_helper(self, word: str, index: int, node: TrieNode) -> bool:
        if index == len(word):
            return node.is_end_word
        
        char = word[index]
        if char == '.':
            # Wildcard: try all possible characters
            for child in node.children.values():
                if self._search_helper(word, index + 1, child):
                    return True
            return False
        else:
            if char not in node.children:
                return False
            return self._search_helper(word, index + 1, node.children[char])

# Test the WordDictionary
wd = WordDictionary()
wd.addWord("bad")
print(wd.search(".ad"))  # True''',
      solutionExplanation: '''Use a Trie data structure to store words efficiently. For search with wildcards, use DFS: when encountering a dot, recursively try all possible children. When encountering a regular character, follow the exact path in the trie.''',
    ),
  ];

  // Getters
  CodingQuestion? get currentQuestion => _currentQuestion;
  String get currentCode => _currentCode;
  String get selectedLanguage => _selectedLanguage;
  int get selectedLanguageId => _selectedLanguageId;
  bool get isExecuting => _isExecuting;
  bool get isGettingFeedback => _isGettingFeedback;
  bool get isGeneratingSolution => _isGeneratingSolution;
  Map<String, dynamic>? get executionResult => _executionResult;
  Map<String, dynamic>? get aiFeedback => _aiFeedback;
  Map<String, dynamic>? get solutionData => _solutionData;
  List<Submission> get submissions => _submissions;
  List<LeaderboardEntry> get leaderboard => _leaderboard;
  List<CodingQuestion> get sampleQuestions => _sampleQuestions;
  String? get error => _error;

  // Initialize provider
  Future<void> _initializeProvider() async {
    try {
      await loadQuestions().timeout(const Duration(seconds: 15));
    } catch (e) {
      print('Failed to initialize coding practice provider: $e');
      _isLoading = false;
      _error = 'Failed to load coding questions. Please try again.';
      notifyListeners();
    }
  }


  Future<void> loadQuestions() async {
    if (_isLoading) return; // Prevent concurrent loading
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _questions = _sampleQuestions; // Use sample questions for now
      if (_questions.isNotEmpty) {
        _currentQuestion = _questions[0];
      }
    } catch (e) {
      _error = 'Failed to load questions: $e';
      print('Error loading questions: $e');
      // Set empty list on error to prevent null issues
      _questions = [];
      _currentQuestion = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  CodingPracticeProvider() {
    // Don't initialize in constructor to prevent blocking initialization
    // Provider will be initialized when needed
  }

  // Initialize provider with timeout protection
  Future<void> initialize() async {
    try {
      await _initializeProvider().timeout(const Duration(seconds: 15));
    } catch (e) {
      print('CodingPracticeProvider initialization failed: $e');
      _isLoading = false;
      _error = 'Failed to initialize coding practice. Please try again.';
      notifyListeners();
    }
  }

  // Update code
  void updateCode(String code) {
    _currentCode = code;
    notifyListeners();
  }

  // Select question
  void selectQuestion(CodingQuestion question) {
    _currentQuestion = question;
    _loadQuestionTemplate();
    notifyListeners();
  }

  // Select language
  void selectLanguage(String language) {
    _selectedLanguage = language;
    _selectedLanguageId = _getLanguageId(language);
    _loadQuestionTemplate();
    notifyListeners();
  }

  // Run code
  Future<void> runCode({String? stdin}) async {
    _isExecuting = true;
    _executionResult = null;
    notifyListeners();

    try {
      log('CodingPracticeProvider: Running code');
      final result = await _judge0Service.executeCode(
        sourceCode: _currentCode,
        languageId: _selectedLanguageId,
        stdin: stdin ?? '',
      ).timeout(const Duration(seconds: 30));

      _executionResult = result;
      log('CodingPracticeProvider: Code execution completed');
    } catch (e) {
      log('CodingPracticeProvider: Error running code: $e');
      _executionResult = {
        'success': false,
        'funny_message': 'Oops! 🤯 Something went wrong while running your code!',
        'stdout': '',
        'stderr': 'Execution failed: $e',
      };
    } finally {
      _isExecuting = false;
      notifyListeners();
    }
  }

  void _loadQuestionTemplate() {
    if (_currentQuestion == null) return;
    
    // Load basic template based on language
    switch (_selectedLanguage) {
      case 'python':
        _currentCode = 'def solution():\n    # Write your code here\n    pass\n\n# Test your solution\nprint(solution())';
        break;
      case 'java':
        _currentCode = 'public class Solution {\n    public static void main(String[] args) {\n        // Write your code here\n    }\n}';
        break;
      case 'javascript':
        _currentCode = 'function solution() {\n    // Write your code here\n}\n\n// Test your solution\nconsole.log(solution());';
        break;
      default:
        _currentCode = '// Write your code here';
    }
  }

  int _getLanguageId(String language) {
    switch (language) {
      case 'python': return 71;
      case 'java': return 62;
      case 'javascript': return 63;
      case 'cpp': return 54;
      case 'c': return 50;
      default: return 71;
    }
  }

  // AI feedback
  Future<void> checkAnswer() async {
    if (_currentQuestion == null || _executionResult == null) {
      return;
    }

    _isGettingFeedback = true;
    _aiFeedback = null;
    notifyListeners();

    try {
      log('CodingPracticeProvider: Getting AI feedback');
      final feedback = await _groqService.getFeedback(
        question: _currentQuestion!.description,
        studentCode: _currentCode,
        executionResult: _executionResult!,
        expectedOutput: _currentQuestion!.expectedOutput,
      );

      _aiFeedback = feedback;
      
      // Save submission
      await _saveSubmission(feedback);
      
      log('CodingPracticeProvider: AI feedback received');
    } catch (e) {
      log('CodingPracticeProvider: Error getting feedback: $e');
      _aiFeedback = {
        'score': 5,
        'feedback': 'Great attempt! 🚀 Keep coding and you\'ll get there!',
        'suggestion': 'Practice makes perfect! Try again! 💪',
      };
    } finally {
      _isGettingFeedback = false;
      notifyListeners();
    }
  }

  // Show solution
  Future<void> showSolution() async {
    if (_currentQuestion == null) {
      log('CodingPracticeProvider: No current question available');
      return;
    }

    log('CodingPracticeProvider: Starting solution generation for question: ${_currentQuestion!.title}');
    
    _isGeneratingSolution = true;
    _solutionData = null;
    notifyListeners();

    try {
      // Always provide the pre-written solution as primary solution
      String solutionCode = _currentQuestion!.solutionCode;
      String explanation = _currentQuestion!.solutionExplanation;
      
      log('CodingPracticeProvider: Original solution code length: ${solutionCode.length}');
      log('CodingPracticeProvider: Selected language: $_selectedLanguage');
      
      // Convert solution to selected language if needed
      if (_selectedLanguage != 'python') {
        String convertedCode = _convertSolutionToLanguage(_currentQuestion!.solutionCode, _selectedLanguage);
        if (convertedCode.isNotEmpty) {
          solutionCode = convertedCode;
          log('CodingPracticeProvider: Converted solution to $_selectedLanguage');
        }
      }

      // Try to get AI-generated solution using Cerebras AI
      Map<String, dynamic>? aiSolution;
      try {
        log('CodingPracticeProvider: Generating solution using Cerebras AI');
        aiSolution = await _cerebrasService.generateSolution(
          question: _currentQuestion!.description,
          language: _selectedLanguage,
          expectedOutput: _currentQuestion!.expectedOutput,
          difficulty: _currentQuestion!.difficulty,
          tags: _currentQuestion!.tags,
        );
        log('CodingPracticeProvider: Cerebras AI solution generated successfully');
      } catch (e) {
        log('CodingPracticeProvider: Cerebras AI solution failed, using fallback: $e');
      }

      _solutionData = {
        'code': aiSolution?['code'] ?? solutionCode,
        'explanation': aiSolution?['explanation'] ?? explanation,
        'approach': aiSolution?['approach'] ?? 'Optimal algorithmic approach for ${_currentQuestion!.title}',
        'time_complexity': aiSolution?['time_complexity'] ?? _getTimeComplexity(_currentQuestion!.id),
        'space_complexity': aiSolution?['space_complexity'] ?? _getSpaceComplexity(_currentQuestion!.id),
        'key_insights': aiSolution?['key_insights'] ?? ['Focus on problem constraints', 'Consider edge cases'],
        'edge_cases': aiSolution?['edge_cases'] ?? ['Empty input', 'Single element'],
        'optimization_tips': aiSolution?['optimization_tips'] ?? 'Consider space-time tradeoffs',
        'question_title': _currentQuestion!.title,
        'question_difficulty': _currentQuestion!.difficulty,
        'is_ai_generated': aiSolution != null,
        'ai_service': aiSolution != null ? 'Cerebras AI' : 'Fallback',
      };
      
      log('CodingPracticeProvider: Solution data set successfully with code length: ${_solutionData!['code']?.length ?? 0}');
    } catch (e) {
      log('CodingPracticeProvider: Critical error in showSolution: $e');
      
      // Emergency fallback - ensure we always have solution data
      String fallbackCode = _currentQuestion!.solutionCode;
      if (_selectedLanguage != 'python') {
        String convertedCode = _convertSolutionToLanguage(_currentQuestion!.solutionCode, _selectedLanguage);
        if (convertedCode.isNotEmpty) {
          fallbackCode = convertedCode;
        }
      }
      
      _solutionData = {
        'code': fallbackCode,
        'explanation': _currentQuestion!.solutionExplanation,
        'approach': 'Standard solution approach for ${_currentQuestion!.title}',
        'time_complexity': _getTimeComplexity(_currentQuestion!.id),
        'space_complexity': _getSpaceComplexity(_currentQuestion!.id),
        'key_insights': ['Focus on problem constraints', 'Consider edge cases', 'Analyze time complexity'],
        'edge_cases': ['Empty input', 'Single element', 'Maximum constraints'],
        'optimization_tips': 'Focus on the most efficient algorithm for the given constraints',
        'question_title': _currentQuestion!.title,
        'question_difficulty': _currentQuestion!.difficulty,
        'is_ai_generated': false,
        'ai_service': 'Fallback',
        'error': 'Fallback solution due to generation error',
      };
    } finally {
      _isGeneratingSolution = false;
      log('CodingPracticeProvider: Solution generation completed. Data available: ${_solutionData != null}');
      notifyListeners();
    }
  }

  String _convertSolutionToLanguage(String pythonCode, String targetLanguage) {
    // Basic conversion for demonstration - in production, you'd want more sophisticated conversion
    switch (targetLanguage) {
      case 'java':
        if (_currentQuestion?.id == 'google_1') {
          return '''import java.util.*;

public class Solution {
    public int[] twoSum(int[] nums, int target) {
        Map<Integer, Integer> numMap = new HashMap<>();
        
        for (int i = 0; i < nums.length; i++) {
            int complement = target - nums[i];
            if (numMap.containsKey(complement)) {
                return new int[]{numMap.get(complement), i};
            }
            numMap.put(nums[i], i);
        }
        
        return new int[]{};
    }
    
    public static void main(String[] args) {
        Solution solution = new Solution();
        int[] nums = {2, 7, 11, 15};
        int target = 9;
        int[] result = solution.twoSum(nums, target);
        System.out.println(Arrays.toString(result));
    }
}''';
        } else if (_currentQuestion?.id == 'amazon_1') {
          return '''import java.util.*;

public class Solution {
    public boolean isValid(String s) {
        Stack<Character> stack = new Stack<>();
        Map<Character, Character> mapping = new HashMap<>();
        mapping.put(')', '(');
        mapping.put('}', '{');
        mapping.put(']', '[');
        
        for (char c : s.toCharArray()) {
            if (mapping.containsKey(c)) {
                if (stack.isEmpty() || stack.pop() != mapping.get(c)) {
                    return false;
                }
            } else {
                stack.push(c);
            }
        }
        
        return stack.isEmpty();
    }
    
    public static void main(String[] args) {
        Solution solution = new Solution();
        System.out.println(solution.isValid("()[]{}"));
    }
}''';
        }
        break;
      case 'cpp':
        if (_currentQuestion?.id == 'google_1') {
          return '''#include <iostream>
#include <vector>
#include <unordered_map>
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

int main() {
    Solution solution;
    vector<int> nums = {2, 7, 11, 15};
    int target = 9;
    vector<int> result = solution.twoSum(nums, target);
    
    cout << "[" << result[0] << ", " << result[1] << "]" << endl;
    return 0;
}''';
        }
        break;
      case 'javascript':
        if (_currentQuestion?.id == 'google_1') {
          return '''function twoSum(nums, target) {
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

// Test
const nums = [2, 7, 11, 15];
const target = 9;
const result = twoSum(nums, target);
console.log(result);''';
        }
        break;
    }
    
    // If no specific conversion available, return a basic template
    return _getBasicTemplate(targetLanguage);
  }

  String _getBasicTemplate(String language) {
    switch (language) {
      case 'java':
        return '''public class Solution {
    public static void main(String[] args) {
        // Implement the solution here
        System.out.println("Solution for ${_currentQuestion?.title}");
    }
}''';
      case 'cpp':
        return '''#include <iostream>
using namespace std;

int main() {
    // Implement the solution here
    cout << "Solution for ${_currentQuestion?.title}" << endl;
    return 0;
}''';
      case 'javascript':
        return '''function solution() {
    // Implement the solution here
    return "Solution for ${_currentQuestion?.title}";
}

console.log(solution());''';
      default:
        return _currentQuestion!.solutionCode;
    }
  }

  String _getTimeComplexity(String questionId) {
    switch (questionId) {
      case 'google_1':
        return 'O(n)';
      case 'amazon_1':
        return 'O(n)';
      case 'microsoft_1':
        return 'O(n)';
      case 'meta_1':
        return 'O(n)';
      case 'apple_1':
        return 'O(n)';
      case 'netflix_1':
        return 'O(n)';
      case 'uber_1':
        return 'O(n * k * log k)';
      default:
        return 'O(n)';
    }
  }

  String _getSpaceComplexity(String questionId) {
    switch (questionId) {
      case 'google_1':
        return 'O(n)';
      case 'amazon_1':
        return 'O(n)';
      case 'microsoft_1':
        return 'O(1)';
      case 'meta_1':
        return 'O(1)';
      case 'apple_1':
        return 'O(n)';
      case 'netflix_1':
        return 'O(min(m,n))';
      case 'uber_1':
        return 'O(n * k)';
      default:
        return 'O(1)';
    }
  }

  // Data management
  Future<void> _saveSubmission(Map<String, dynamic> feedback) async {
    if (_currentQuestion == null || _executionResult == null) return;

    try {
      final submission = Submission(
        id: '${DateTime.now().millisecondsSinceEpoch}',
        studentId: 'current_user', // You might want to get this from auth provider
        questionId: _currentQuestion!.id,
        code: _currentCode,
        language: _selectedLanguage,
        languageId: _selectedLanguageId,
        executionResult: _executionResult.toString(),
        status: _executionResult!['success'] ? 'accepted' : 'failed',
        score: feedback['score'] ?? 0,
        feedback: feedback['feedback'] ?? '',
        suggestion: feedback['suggestion'] ?? '',
        timestamp: DateTime.now(),
        isCorrect: _executionResult!['success'] ?? false,
        executionTime: double.tryParse(_executionResult!['execution_time'] ?? '0') ?? 0.0,
      );

      await CodingStorageService.saveSubmission(submission);
      await loadSubmissions();
      await loadLeaderboard();
    } catch (e) {
      log('CodingPracticeProvider: Error saving submission: $e');
    }
  }

  Future<void> loadSubmissions() async {
    try {
      _submissions = CodingStorageService.getSubmissions(studentId: 'current_user');
      notifyListeners();
    } catch (e) {
      log('CodingPracticeProvider: Error loading submissions: $e');
    }
  }

  Future<void> loadLeaderboard() async {
    try {
      _leaderboard = CodingStorageService.getLeaderboard();
      notifyListeners();
    } catch (e) {
      log('CodingPracticeProvider: Error loading leaderboard: $e');
    }
  }


  // Utility methods
  void _clearResults() {
    _executionResult = null;
    _aiFeedback = null;
    _solutionData = null;
  }

  Map<String, dynamic> getStudentStats() {
    return CodingStorageService.getStudentStats('current_user');
  }

  void resetCurrentQuestion() {
    _clearResults();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
