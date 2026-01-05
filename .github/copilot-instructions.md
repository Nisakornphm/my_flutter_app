---
description: 'Instructions for writing Dart and Flutter code following the official recommendations.'
applyTo: '**/*.dart'
---

# Dart and Flutter

Best practices recommended by the Dart and Flutter teams. These instructions were taken from [Effective Dart](https://dart.dev/effective-dart) and [Architecture Recommendations](https://docs.flutter.dev/app-architecture/recommendations).

## Effective Dart

### Style

### How to read the topics

Each topic is broken into a few sections. Sections contain a list of guidelines. Each guideline starts with one of these words:

*   **DO** guidelines describe practices that should always be followed. There will almost never be a valid reason to stray from them.

*   **DON'T** guidelines are the converse: things that are almost never a good idea. Hopefully, we don't have as many of these as other languages do because we have less historical baggage.

*   **PREFER** guidelines are practices that you *should* follow. However, there may be circumstances where it makes sense to do otherwise. Just make sure you understand the full implications of ignoring the guideline when you do.

*   **AVOID** guidelines are the dual to "prefer": stuff you shouldn't do but where there may be good reasons to on rare occasions.

*   **CONSIDER** guidelines are practices that you might or might not want to follow, depending on circumstances, precedents, and your own preference.

Some guidelines describe an **exception** where the rule does *not* apply. When listed, the exceptions may not be exhaustive—you might still need to use your judgement on other cases.

#### Identifiers
- DO name types using `UpperCamelCase`
- DO name extensions using `UpperCamelCase`
- DO name packages, directories, and source files using `lowercase_with_underscores`
- DO name other identifiers using `lowerCamelCase`
- PREFER using `lowerCamelCase` for constant names
- DON'T use a leading underscore for identifiers that aren't private

#### Formatting
- DO format your code using `dart format`
- PREFER lines 80 characters or fewer
- DO use curly braces for all flow control statements

### Documentation

#### Doc comments
- DO use `///` doc comments to document members and types
- PREFER writing doc comments for public APIs
- DO start doc comments with a single-sentence summary
- CONSIDER including code samples in doc comments
- DO use square brackets in doc comments to refer to in-scope identifiers

### Usage

#### Null
- DON'T explicitly initialize variables to `null`
- DON'T use `true` or `false` in equality operations
- AVOID `late` variables if you need to check whether they are initialized
- CONSIDER type promotion or null-check patterns for using nullable types

#### Collections
- DO use collection literals when possible
- DON'T use `.length` to see if a collection is empty
- AVOID using `Iterable.forEach()` with a function literal
- DO use `whereType()` to filter a collection by type

#### Members
- PREFER using a `final` field to make a read-only property
- CONSIDER using `=>` for simple members
- DON'T use `this.` except to redirect to a named constructor or to avoid shadowing
- DO initialize fields at their declaration when possible

#### Constructors
- DO use initializing formals when possible
- DON'T use `late` when a constructor initializer list will do
- DO use `;` instead of `{}` for empty constructor bodies
- DON'T use `new`
- DON'T use `const` redundantly

#### Error handling
- AVOID catches without `on` clauses
- DON'T discard errors from catches without `on` clauses
- DO use `rethrow` to rethrow a caught exception

#### Asynchrony
- PREFER async/await over using raw futures
- DON'T use `async` when it has no useful effect
- CONSIDER using higher-order methods to transform a stream

### Design

#### Names
- DO use terms consistently
- AVOID abbreviations
- PREFER putting the most descriptive noun last
- PREFER a noun phrase for a non-boolean property or variable
- AVOID starting a method name with `get`

#### Types
- DO type annotate variables without initializers
- DO annotate return types on function declarations
- DO annotate parameter types on function declarations
- DON'T redundantly type annotate initialized local variables
- AVOID using `dynamic` unless you want to disable static checking
- DO use `Future<void>` as the return type of asynchronous members that do not produce values

#### Members
- PREFER making fields and top-level variables `final`
- AVOID returning nullable `Future`, `Stream`, and collection types
- AVOID returning `this` from methods just to enable a fluent interface

## Flutter Architecture Recommendations

### Separation of concerns

#### Use clearly defined data and UI layers (Strongly recommend)
Separation of concerns is the most important architectural principle. The data layer exposes application data to the rest of the app, and contains most of the business logic. The UI layer displays application data and listens for user events.

#### Use the repository pattern in the data layer (Strongly recommend)
The repository pattern isolates the data access logic from the rest of the application. In practice, this means creating Repository classes and Service classes.

#### Use ViewModels and Views in the UI layer - MVVM (Strongly recommend)
This separation makes your code much less error prone because your widgets remain "dumb".

#### Use `ChangeNotifiers` and `Listenables` to handle widget updates (Conditional)
The `ChangeNotifier` API is part of the Flutter SDK, and is a convenient way to have your widgets observe changes in your ViewModels.

#### Do not put logic in widgets (Strongly recommend)
Logic should be encapsulated in methods on the ViewModel. The only logic a view should contain is:
- Simple if-statements to show and hide widgets based on a flag or nullable field in the ViewModel
- Animation logic that relies on the widget to calculate
- Layout logic based on device information, like screen size or orientation
- Simple routing logic

### Handling data

#### Use unidirectional data flow (Strongly recommend)
Data updates should only flow from the data layer to the UI layer. Interactions in the UI layer are sent to the data layer where they're processed.

#### Use `Commands` to handle events from user interaction (Recommend)
Commands prevent rendering errors in your app, and standardize how the UI layer sends events to the data layer.

#### Use immutable data models (Strongly recommend)
Immutable data is crucial in ensuring that any necessary changes occur only in the proper place, usually the data or domain layer.

#### Use freezed or built_value to generate immutable data models (Recommend)
These can generate common model methods like JSON ser/des, deep equality checking and copy methods.

### App structure

#### Use dependency injection (Strongly recommend)
Dependency injection prevents your app from having globally accessible objects, which makes your code less error prone. We recommend you use the `provider` package.

#### Use `go_router` for navigation (Recommend)
Go_router is the preferred way to write 90% of Flutter applications.

#### Use standardized naming conventions (Recommend)
Examples:
- HomeViewModel
- HomeScreen
- UserRepository
- ClientApiService

#### Use abstract repository classes (Strongly recommend)
Creating abstract repository classes allows you to create different implementations for different app environments.

### Testing

#### Test architectural components separately, and together (Strongly recommend)
- Write unit tests for every service, repository and ViewModel class
- Write widget tests for views

#### Make fakes for testing (Strongly recommend)
Fakes force you to write modular, lightweight functions and classes with well defined inputs and outputs.
