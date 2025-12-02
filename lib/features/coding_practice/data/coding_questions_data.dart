import '../models/coding_question.dart';

class CodingQuestionsData {
  static final List<CodingQuestion> questions = [
    // Arrays - 25 questions
    CodingQuestion(
      id: 'array_1',
      title: 'Two Sum',
      description: '''Given an array of integers nums and an integer target, return indices of the two numbers such that they add up to target.

You may assume that each input would have exactly one solution, and you may not use the same element twice.

Example 1:
Input: nums = [2,7,11,15], target = 9
Output: [0,1]
Explanation: Because nums[0] + nums[1] == 9, we return [0, 1].

Example 2:
Input: nums = [3,2,4], target = 6
Output: [1,2]

Constraints:
- 2 <= nums.length <= 10^4
- -10^9 <= nums[i] <= 10^9
- -10^9 <= target <= 10^9
- Only one valid answer exists.''',
      difficulty: 'Easy',
      tags: ['Array', 'Hash Table'],
      sampleInput: '[2,7,11,15]\n9',
      expectedOutput: '[0,1]',
      solutionCode: '''def two_sum(nums, target):
    """
    Find two numbers that add up to target using hash map.
    
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

# Test
nums = [2, 7, 11, 15]
target = 9
result = two_sum(nums, target)
print(result)  # [0, 1]''',
      solutionExplanation: 'Use a hash map to store numbers and their indices. For each number, check if its complement (target - number) exists in the map.',
    ),

    CodingQuestion(
      id: 'array_2',
      title: 'Best Time to Buy and Sell Stock',
      description: '''You are given an array prices where prices[i] is the price of a given stock on the ith day.

You want to maximize your profit by choosing a single day to buy one stock and choosing a different day in the future to sell that stock.

Return the maximum profit you can achieve from this transaction. If you cannot achieve any profit, return 0.

Example 1:
Input: prices = [7,1,5,3,6,4]
Output: 5
Explanation: Buy on day 2 (price = 1) and sell on day 5 (price = 6), profit = 6-1 = 5.

Example 2:
Input: prices = [7,6,4,3,1]
Output: 0
Explanation: In this case, no transactions are done and the max profit = 0.''',
      difficulty: 'Easy',
      tags: ['Array', 'Dynamic Programming'],
      sampleInput: '[7,1,5,3,6,4]',
      expectedOutput: '5',
      solutionCode: '''def max_profit(prices):
    """
    Find maximum profit from buying and selling stock once.
    
    Time Complexity: O(n)
    Space Complexity: O(1)
    """
    if not prices or len(prices) < 2:
        return 0
    
    min_price = prices[0]
    max_profit = 0
    
    for price in prices[1:]:
        # Update minimum price seen so far
        min_price = min(min_price, price)
        # Update maximum profit
        max_profit = max(max_profit, price - min_price)
    
    return max_profit

# Test
prices = [7, 1, 5, 3, 6, 4]
result = max_profit(prices)
print(result)  # 5''',
      solutionExplanation: 'Track the minimum price seen so far and calculate profit at each step. Keep track of maximum profit.',
    ),

    CodingQuestion(
      id: 'array_3',
      title: 'Contains Duplicate',
      description: '''Given an integer array nums, return true if any value appears at least twice in the array, and return false if every element is distinct.

Example 1:
Input: nums = [1,2,3,1]
Output: true

Example 2:
Input: nums = [1,2,3,4]
Output: false

Example 3:
Input: nums = [1,1,1,3,3,4,3,2,4,2]
Output: true

Constraints:
- 1 <= nums.length <= 10^5
- -10^9 <= nums[i] <= 10^9''',
      difficulty: 'Easy',
      tags: ['Array', 'Hash Table', 'Sorting'],
      sampleInput: '[1,2,3,1]',
      expectedOutput: 'true',
      solutionCode: '''def contains_duplicate(nums):
    """
    Check if array contains duplicates using set.
    
    Time Complexity: O(n)
    Space Complexity: O(n)
    """
    return len(nums) != len(set(nums))

# Alternative solution using hash set
def contains_duplicate_v2(nums):
    seen = set()
    for num in nums:
        if num in seen:
            return True
        seen.add(num)
    return False

# Test
nums = [1, 2, 3, 1]
result = contains_duplicate(nums)
print(result)  # True''',
      solutionExplanation: 'Use a set to track seen numbers. If we encounter a number already in the set, return True.',
    ),
  ];
}
