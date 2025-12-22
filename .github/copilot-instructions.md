# Copilot Code Review Instructions for Flutter App

When performing a code review for this Flutter project, please:

## Focus Areas
- Check for **Flutter best practices** and widget lifecycle management
- Ensure **null safety** is properly implemented
- Verify **StatefulWidget** dispose methods are implemented correctly
- Look for **performance issues** (unnecessary rebuilds, missing const)
- Check for **memory leaks** (undisposed controllers, listeners)

## Specific Checks
- Division by zero and arithmetic errors
- Async operations without proper error handling
- Context usage after async gaps without mounted checks
- Type safety and consistency in data structures
- Resource disposal (AnimationController, StreamController, etc.)

## Code Quality
- Prefer meaningful variable names over abbreviations
- Check for duplicate code that could be extracted
- Ensure proper error handling with try-catch
- Validate edge cases (empty lists, null values, zero values)

## Response Style
- Provide clear explanations in **Thai language** when possible
- Suggest specific code fixes, not just identify problems
- Explain WHY something is a problem, not just WHAT
- Prioritize critical bugs over style issues

## Flutter-Specific
- Check if widgets can be `const` for better performance
- Ensure `BuildContext` is used safely
- Verify proper use of `setState()`
- Check for proper key usage in lists
