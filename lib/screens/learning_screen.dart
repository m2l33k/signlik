import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/lesson.dart';
import '../models/sign.dart';
import '../widgets/bottom_nav.dart';
import 'lesson_detail_screen.dart';
import 'quiz_screen.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});
  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  List<Lesson> lessons = [];
  List<Sign> allSignsList = [];
  Map<String, List<Sign>> signsByCategory = {};
  bool isLoading = true;
  int tab = 0; // 0 lessons, 1 challenges
  final int _navIndex = 2;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      List<Sign> allSigns = [];
      
      try {
        allSigns = await api.getAllSigns();
      } catch (e) {
        debugPrint('Backend fetch error: $e');
        // Fallback handled below if list is empty
      }
      
      if (allSigns.isEmpty) {
        // Fallback to mock data
        final mockData = [
          {"id": 1, "name": "Hello", "description": "Wave hand", "category": "Greetings", "difficultyLevel": "Beginner"},
          {"id": 2, "name": "Thank You", "description": "Hand from chin forward", "category": "Greetings", "difficultyLevel": "Beginner"},
          {"id": 3, "name": "Please", "description": "Rub chest in circle", "category": "Basics", "difficultyLevel": "Beginner"},
          {"id": 4, "name": "Yes", "description": "Fist nodding", "category": "Basics", "difficultyLevel": "Beginner"},
          {"id": 5, "name": "No", "description": "Index and middle finger tap thumb", "category": "Basics", "difficultyLevel": "Beginner"},
          {"id": 6, "name": "Good Morning", "description": "Hand from chin to palm", "category": "Greetings", "difficultyLevel": "Beginner"},
          {"id": 7, "name": "Family", "description": "Circle with F hands", "category": "Family", "difficultyLevel": "Beginner"},
          {"id": 8, "name": "Friend", "description": "Hook index fingers", "category": "People", "difficultyLevel": "Beginner"},
          {"id": 9, "name": "Help", "description": "Fist on palm, lift up", "category": "Basics", "difficultyLevel": "Beginner"},
          {"id": 10, "name": "Eat", "description": "Hand to mouth", "category": "Daily Life", "difficultyLevel": "Beginner"},
        ];
        
        allSigns = mockData.map((e) => Sign.fromJson(e)).toList();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Using demo data (Backend has no signs)"), duration: Duration(seconds: 3)),
          );
        }
      }

      // Group by category
      final Map<String, List<Sign>> grouped = {};
      for (var s in allSigns) {
        if (!grouped.containsKey(s.category)) {
          grouped[s.category] = [];
        }
        grouped[s.category]!.add(s);
      }

      final List<Lesson> loadedLessons = [];
      int idCounter = 1;
      grouped.forEach((category, signs) {
        loadedLessons.add(Lesson(
          id: 'L${idCounter++}',
          title: category,
          description: 'Learn ${signs.length} signs in $category',
          progress: 0, // TODO: Persist progress
          difficulty: signs.isNotEmpty ? signs.first.difficulty : 'Mixed',
          signsCount: signs.length,
          durationMin: (signs.length * 1.5).ceil(), // Estimate 1.5 min per sign
        ));
      });

      setState(() {
        allSignsList = allSigns;
        signsByCategory = grouped;
        lessons = loadedLessons;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading lessons: $e');
      setState(() {
        isLoading = false;
        // Keep empty or show error
      });
    }
  }

  void _openLesson(Lesson lesson) async {
    final signs = signsByCategory[lesson.title] ?? [];
    if (signs.isEmpty) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LessonDetailScreen(
          category: lesson.title,
          signs: signs,
        ),
      ),
    );

    if (result == true) {
      // Mark as completed
      final idx = lessons.indexWhere((x) => x.id == lesson.id);
      if (idx != -1) {
        setState(() => lessons[idx].progress = 100);
      }
    }
  }

  void _startQuiz(String type) {
    if (allSignsList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No signs available for quiz")));
      return;
    }

    int count = 5;
    String title = "Daily Practice";

    if (type == 'daily') {
      count = 5;
      title = "Daily Practice";
    } else if (type == 'warrior') {
      count = 10;
      title = "Week Warrior";
    } else if (type == 'perfect') {
      count = 15;
      title = "Perfect Score Challenge";
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          allSigns: allSignsList,
          questionCount: count,
          title: title,
        ),
      ),
    );
  }

  void _navTap(int idx) {
    if (idx == 0) Navigator.pushReplacementNamed(context, '/home');
    if (idx == 1) Navigator.pushReplacementNamed(context, '/translator');
    if (idx == 3) Navigator.pushReplacementNamed(context, '/profile');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Colors.blue.shade700, Colors.purple.shade600])),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Learning Center',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('TSL • ${lessons.where((l) => l.progress == 100).length}/${lessons.length} lessons completed',
                          style: const TextStyle(color: Color(0xFFBBDEFB))),
                    ],
                  ),
                  IconButton(
                      onPressed: () => Navigator.pushNamed(context, '/dictionary'),
                      icon: const Icon(Icons.book, color: Colors.white),
                      tooltip: 'Dictionary')
                ],
              ),
            ),
            // Choice Chips
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  ChoiceChip(
                      label: const Text('Lessons'),
                      selected: tab == 0,
                      onSelected: (_) => setState(() => tab = 0)),
                  const SizedBox(width: 8),
                  ChoiceChip(
                      label: const Text('Challenges'),
                      selected: tab == 1,
                      onSelected: (_) => setState(() => tab = 1))
                ],
              ),
            ),
            // Main content
            Expanded(
              child: isLoading 
                  ? const Center(child: CircularProgressIndicator())
                  : tab == 0
                  ? (lessons.isEmpty 
                      ? const Center(child: Text("No lessons available"))
                      : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: lessons.length,
                      itemBuilder: (_, i) {
                        final L = lessons[i];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                  color: L.progress == 100
                                      ? Colors.green[100]
                                      : Colors.blue[50],
                                  borderRadius: BorderRadius.circular(10)),
                              child: Center(
                                  child: L.progress == 100
                                      ? const Icon(Icons.check_circle,
                                          color: Colors.green)
                                      : Text('${i + 1}')),
                            ),
                            title: Text(L.title),
                            subtitle: Text('${L.signsCount} signs • ${L.durationMin} min'),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('${L.progress}%'),
                                const SizedBox(height: 6),
                                SizedBox(
                                    width: 120,
                                    child: LinearProgressIndicator(
                                        value: L.progress / 100))
                              ],
                            ),
                            onTap: () => _openLesson(L),
                          ),
                        );
                      }))
                  : ListView(
                      padding: const EdgeInsets.all(12),
                      children: [
                        Card(
                            child: ListTile(
                                title: const Text('Daily Practice'),
                                subtitle: const Text('5 Random Signs'),
                                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                onTap: () => _startQuiz('daily'),
                            )),
                        Card(
                            child: ListTile(
                                title: const Text('Week Warrior'),
                                subtitle: const Text('10 Signs Challenge'),
                                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                onTap: () => _startQuiz('warrior'),
                            )),
                        Card(
                            child: ListTile(
                                title: const Text('Perfect Score'),
                                subtitle: const Text('15 Signs - No Mistakes Allowed'), // Logic not enforced yet but conceptually
                                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                onTap: () => _startQuiz('perfect'),
                            )),
                      ],
                    ),
            ),
            // Bottom Navigation
            BottomNav(currentIndex: _navIndex, onTap: _navTap),
          ],
        ),
      ),
    );
  }
}
