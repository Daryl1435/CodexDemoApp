import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Study Companion',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      routes: {
        SummarizedNotesScreen.routeName: (_) => const SummarizedNotesScreen(),
        QuestionBankScreen.routeName: (_) => const QuestionBankScreen(),
        QuizScreen.routeName: (_) => const QuizScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final features = [
      _Feature(
        title: 'Summarized Notes',
        icon: Icons.notes,
        description: 'Quickly review key concepts and summaries.',
        routeName: SummarizedNotesScreen.routeName,
      ),
      _Feature(
        title: 'Question Bank',
        icon: Icons.library_books,
        description: 'Browse curated questions by topic.',
        routeName: QuestionBankScreen.routeName,
      ),
      _Feature(
        title: 'Take a Test',
        icon: Icons.quiz,
        description: 'Challenge yourself with a quick quiz.',
        routeName: QuizScreen.routeName,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Companion'),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth > 900
              ? 3
              : constraints.maxWidth > 600
                  ? 2
                  : 1;
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: GridView.count(
                padding: const EdgeInsets.all(24),
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 24,
                crossAxisSpacing: 24,
                childAspectRatio: crossAxisCount == 1 ? 2.6 : 1.2,
                children: features
                    .map((feature) => _FeatureCard(feature: feature))
                    .toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Feature {
  const _Feature({
    required this.title,
    required this.icon,
    required this.description,
    required this.routeName,
  });

  final String title;
  final IconData icon;
  final String description;
  final String routeName;
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.feature});

  final _Feature feature;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => Navigator.of(context).pushNamed(feature.routeName),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(feature.icon, size: 48, color: Theme.of(context).primaryColor),
              const SizedBox(height: 16),
              Text(
                feature.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                feature.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SummarizedNotesScreen extends StatelessWidget {
  const SummarizedNotesScreen({super.key});

  static const routeName = '/notes';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Summarized Notes')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Your summarized notes will appear here. Use this space to provide a quick overview of important topics.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class QuestionBankScreen extends StatelessWidget {
  const QuestionBankScreen({super.key});

  static const routeName = '/question-bank';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Question Bank')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Organize and review your questions here. You can categorize them by subject or difficulty level.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  static const routeName = '/quiz';

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final List<_Question> _questions = const [
    _Question(
      text: 'Which widget is commonly used for immutable UI components in Flutter?',
      options: ['StatefulWidget', 'StatelessWidget', 'InheritedWidget', 'AnimatedContainer'],
      correctIndex: 1,
    ),
    _Question(
      text: 'What command would you run to create a new Flutter project?',
      options: [
        'flutter new my_app',
        'flutter init my_app',
        'flutter create my_app',
        'flutter start my_app'
      ],
      correctIndex: 2,
    ),
    _Question(
      text: 'Which layout widget allows children to be positioned relative to the edges of their parent?',
      options: ['Column', 'Row', 'Stack', 'ListView'],
      correctIndex: 2,
    ),
  ];

  int _currentIndex = 0;
  int _score = 0;
  int? _selectedIndex;

  _Question get _currentQuestion => _questions[_currentIndex];

  bool get _hasAnswered => _selectedIndex != null;

  void _selectOption(int index) {
    if (_hasAnswered) return;

    final isCorrect = _currentQuestion.correctIndex == index;

    setState(() {
      _selectedIndex = index;
      if (isCorrect) {
        _score++;
      }
    });

    Future.delayed(const Duration(milliseconds: 900), () async {
      if (!mounted) return;

      if (_currentIndex < _questions.length - 1) {
        setState(() {
          _currentIndex++;
          _selectedIndex = null;
        });
      } else {
        await _showFinalScore();
      }
    });
  }

  Future<void> _showFinalScore() async {
    final action = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Quiz Complete'),
          content: Text('You scored $_score out of ${_questions.length}.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop('retake'),
              child: const Text('Retake'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop('close'),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    if (action == 'close') {
      Navigator.of(context).maybePop();
      return;
    }

    setState(() {
      _currentIndex = 0;
      _score = 0;
      _selectedIndex = null;
    });
  }

  Color _optionColor(BuildContext context, int index) {
    if (!_hasAnswered) {
      return Theme.of(context).colorScheme.surface;
    }
    if (index == _currentQuestion.correctIndex) {
      return Colors.green.shade100;
    }
    if (index == _selectedIndex) {
      return Colors.red.shade100;
    }
    return Theme.of(context).colorScheme.surface;
  }

  Icon? _optionIcon(int index) {
    if (!_hasAnswered) return null;
    if (index == _currentQuestion.correctIndex) {
      return const Icon(Icons.check_circle, color: Colors.green);
    }
    if (index == _selectedIndex) {
      return const Icon(Icons.cancel, color: Colors.red);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take a Test')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Question ${_currentIndex + 1} of ${_questions.length}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          'Score: $_score',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: (_currentIndex + (_hasAnswered ? 1 : 0)) /
                          _questions.length,
                    ),
                    const SizedBox(height: 32),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentQuestion.text,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 24),
                            ...List.generate(_currentQuestion.options.length, (index) {
                              final option = _currentQuestion.options[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Card(
                                  color: _optionColor(context, index),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    side: BorderSide(
                                      color: _hasAnswered &&
                                              index == _currentQuestion.correctIndex
                                          ? Colors.green
                                          : Theme.of(context)
                                              .colorScheme
                                              .outlineVariant,
                                    ),
                                  ),
                                  child: ListTile(
                                    onTap: _hasAnswered ? null : () => _selectOption(index),
                                    title: Text(option),
                                    trailing: _optionIcon(index),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: isWide ? 32 : 20,
                                      vertical: isWide ? 20 : 12,
                                    ),
                                  ),
                                ),
                              );
                            }),
                            if (_hasAnswered)
                              Padding(
                                padding: const EdgeInsets.only(top: 24),
                                child: Text(
                                  _selectedIndex == _currentQuestion.correctIndex
                                      ? 'Great job! That is the correct answer.'
                                      : 'Not quite. The correct answer is "${_currentQuestion.options[_currentQuestion.correctIndex]}".',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Question {
  const _Question({
    required this.text,
    required this.options,
    required this.correctIndex,
  });

  final String text;
  final List<String> options;
  final int correctIndex;
}
