import 'package:flutter/material.dart';
import '../widgets/stat_card.dart';
import '../widgets/bottom_nav.dart';
import '../models/lesson.dart';
import '../data/mock_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Lesson> lessons = [];
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    lessons = loadLessons();
  }

  void _onNavTap(int idx) {
    setState(() => _navIndex = idx);
    if (idx == 1) Navigator.pushReplacementNamed(context, '/translator');
    if (idx == 2) Navigator.pushReplacementNamed(context, '/learning');
    if (idx == 3) Navigator.pushReplacementNamed(context, '/profile');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade700, Colors.purple.shade600],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'SignLik',
                        style: TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text('Welcome back! 👋',
                          style: TextStyle(color: Color(0xFFBBDEFB))),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        Column(
                          children: const [
                            Text('TSL', style: TextStyle(color: Colors.white)),
                            Text('Language',
                                style: TextStyle(color: Colors.white70, fontSize: 10))
                          ],
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.notifications, color: Colors.white),
                          onPressed: () => Navigator.pushNamed(context, '/notifications'),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Scrollable content fills remaining space
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Quick Access
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.people),
                            label: const Text('Friends'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: Colors.indigo,
                            ),
                            onPressed: () => Navigator.pushNamed(context, '/friends'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.book),
                            label: const Text('Dictionary'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: Colors.teal,
                            ),
                            onPressed: () => Navigator.pushNamed(context, '/dictionary'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: const [
                        StatCard(
                            icon: Icons.local_fire_department,
                            label: 'Day Streak',
                            value: '7'),
                        SizedBox(width: 8),
                        StatCard(
                            icon: Icons.track_changes,
                            label: 'Signs Learned',
                            value: '45'),
                        SizedBox(width: 8),
                        StatCard(
                            icon: Icons.emoji_events,
                            label: 'Translations',
                            value: '127'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade50,
                          child: Icon(Icons.bolt, color: Colors.blue.shade700),
                        ),
                        title: const Text('Daily Goal'),
                        subtitle: const Text('23 / 50 signs practiced'),
                        trailing: const Text('46%'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/translator'),
                            icon: const Icon(Icons.videocam),
                            label: const Text('Start Translating'),
                            style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 18)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/learning'),
                            icon: const Icon(Icons.menu_book),
                            label: const Text('Practice Signs'),
                            style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 18),
                                backgroundColor: Colors.purple),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text("Today's Lessons",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    for (final l in lessons)
                      Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(child: Text('${l.id}')),
                          title: Text(l.title),
                          subtitle: Text(l.description),
                          trailing: ElevatedButton(
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/learning'),
                              child: const Text('Start')),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Bottom Navigation fixed
            BottomNav(currentIndex: _navIndex, onTap: _onNavTap),
          ],
        ),
      ),
    );
  }
}
