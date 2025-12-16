import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import '../services/api_service.dart';
import '../models/sign.dart';
import '../widgets/sign_card.dart';
import '../widgets/video_player_widget.dart';
class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  List<Sign> signs = [];
  List<Sign> filtered = [];
  Set<int> favorites = {};
  String q = '';
  String selectedCategory = 'All';
  int tabIndex = 0; // 0: All, 1: Favorites
  bool isLoading = true;
  String? error;

  final List<String> categories = ['All', 'Greetings', 'Basics', 'Family', 'People', 'Daily Life', 'Emergency', 'Emotions'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => isLoading = true);
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      
      final prefs = await SharedPreferences.getInstance();
      final favList = prefs.getStringList('favorite_sign_ids') ?? [];
      favorites = favList.map((e) => int.parse(e)).toSet();

      final loadedSigns = await api.getAllSigns();
      
      if (mounted) {
        setState(() {
          signs = loadedSigns;
          final cats = loadedSigns.map((s) => s.category).toSet().toList();
          cats.sort();
          for(var c in cats) {
            if(!categories.contains(c)) categories.add(c);
          }
          
          isLoading = false;
          _applyFilter();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          error = e.toString();
        });
      }
    }
  }

  void _applyFilter() {
    Iterable<Sign> base = tabIndex == 1 ? signs.where((s) => favorites.contains(s.id)) : signs;
    
    if (selectedCategory != 'All') {
      base = base.where((s) => s.category == selectedCategory);
    }
    
    if (q.isNotEmpty) {
      base = base.where((s) => 
        s.name.toLowerCase().contains(q.toLowerCase()) || 
        s.description.toLowerCase().contains(q.toLowerCase())
      );
    }
    
    setState(() => filtered = base.toList());
  }

  Future<void> _toggleFavorite(Sign s) async {
    if (s.id == null) return;
    
    setState(() {
      if (favorites.contains(s.id)) {
        favorites.remove(s.id);
      } else {
        favorites.add(s.id!);
      }
      _applyFilter();
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorite_sign_ids', favorites.map((id) => id.toString()).toList());
  }

  void _playSign(Sign s) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.play_circle_outline, color: Colors.white, size: 48),
                    const SizedBox(height: 8),
                    const Text('Video Playback Placeholder', style: TextStyle(color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(s.videoUrl, style: const TextStyle(color: Colors.white70, fontSize: 10), textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dictionary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (!isLoading && signs.isNotEmpty)
              Text('${signs.length} signs', style: const TextStyle(fontSize: 12)),
          ],
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.purple.shade600],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Search signs...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  ),
                  onChanged: (v) {
                    q = v;
                    _applyFilter();
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ToggleButtons(
                      isSelected: [tabIndex == 0, tabIndex == 1],
                      borderRadius: BorderRadius.circular(8),
                      onPressed: (i) {
                        setState(() => tabIndex = i);
                        _applyFilter();
                      },
                      constraints: const BoxConstraints(minHeight: 36),
                      children: const [
                        Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('All')),
                        Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Favorites')),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: categories.contains(selectedCategory) ? selectedCategory : 'All',
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                          border: OutlineInputBorder(),
                        ),
                        isExpanded: true,
                        items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis))).toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setState(() => selectedCategory = v);
                            _applyFilter();
                          }
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          
          Expanded(
            child: isLoading 
                ? const Center(child: CircularProgressIndicator())
                : error != null
                    ? Center(child: Text('Error: $error'))
                    : filtered.isEmpty
                        ? const Center(child: Text('No signs found'))
                        : ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: filtered.length,
                            itemBuilder: (_, i) {
                              final s = filtered[i];
                              return SignCard(
                                sign: s,
                                isFavorite: favorites.contains(s.id),
                                onPlay: () {},
                                onToggleFavorite: () => _toggleFavorite(s),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
