import 'dart:io';

import 'package:flutter/material.dart';
import 'package:movie_watchlist/model/moviemodel.dart';
import 'package:movie_watchlist/screens/addmoviescreen.dart';
import 'package:movie_watchlist/services/dbhelper.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  final _searchcontroller = TextEditingController();

  List<Moviemodel> _allmovies = [];
  List<Moviemodel> _filteredmovies = [];
  List<String> _categories = const ['all'];
  String _selectedcategory = '';

  @override
  void initState() {
    super.initState();
    _loadmovies();
  }

  Future<void> _loadmovies() async {
    final movies = await Dbhelper.instance.getmovies();
    setState(() {
      _allmovies = movies;
      _rebuildcategories();
      _applyfilters();
    });
  }

  void _rebuildcategories() {
    final set = <String>{};
    for (final m in _allmovies) {
      if (m.category.trim().isNotEmpty) set.add(m.category.trim());
    }
    final list = ['All', ...set.toList()..sort()];
    _categories = list;
    if (!_categories.contains(_selectedcategory)) {
      _selectedcategory = 'All';
    }
  }

  void _applyfilters() {
    final query = _searchcontroller.text.toLowerCase();
    setState(() {
      _filteredmovies =
          _allmovies.where((m) {
            final matchescategory =
                _selectedcategory == 'All' || m.category == _selectedcategory;
            final matchesSearch = m.title.toLowerCase().contains(query);
            return matchescategory && matchesSearch;
          }).toList();
    });
  }

  Future<void> _togglewatched(Moviemodel movie) async {
    final updated = Moviemodel(
      id: movie.id,
      title: movie.title,
      category: movie.category,
      poster: movie.poster,
      year:  movie.year,
      watched: !movie.watched,
      ratings: movie.ratings,
      notes: movie.notes,
    );
    await Dbhelper.instance.updatemovie(updated);
    final idx = _allmovies.indexWhere((e) => e.id == movie.id);
    if (idx != -1) {
      _allmovies[idx] = updated;
      _applyfilters();
    }
  }

  Future<void> _deleteMovie(int id) async {
    await Dbhelper.instance.deletemovie(id);
    _allmovies.removeWhere((e) => e.id == id);
    _applyfilters();
  }

  Widget _posterthumb(String poster) {
    if (poster.isNotEmpty && poster.startsWith('http')) {
      return Image.network(poster, width: 60, height: 90, fit: BoxFit.cover);
    } else if (poster.isNotEmpty && File(poster).existsSync()) {
      return Image.file(File(poster), width: 60, height: 90, fit: BoxFit.cover);
    }
    return Container(
      width: 60,
      height: 90,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade300,
      ),
      child: const Icon(Icons.movie, size: 28),
    );
  }

  Route _addMovieRoute() {
    return PageRouteBuilder(
      pageBuilder: (_, _, __) => const Addmoviescreen(),
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      transitionsBuilder: (_, animation, secondary, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.98, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Movie watchlist'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: TextField(
              controller: _searchcontroller,
              onChanged: (_) => _applyfilters(),
              decoration: InputDecoration(
                hintText: 'Search movies',
                prefixIcon: Icon(Icons.search),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 50,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, i) {
                final cat = _categories[i];
                final selected = cat == _selectedcategory;
                return ChoiceChip(
                  label: Text(cat),
                  selected: selected,
                  onSelected: (_) {
                    setState(() {
                      _selectedcategory = cat;
                      _applyfilters();
                    });
                  },
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemCount: _categories.length,
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadmovies,
              child:
                  _filteredmovies.isEmpty
                      ? ListView(
                        children: const [
                          SizedBox(height: 120),
                          Center(child: Text('No movies yet')),
                        ],
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        itemCount: _filteredmovies.length,
                        itemBuilder: (context, index) {
                          final m = _filteredmovies[index];
                          return Dismissible(
                            key: ValueKey(m.id),
                            background: Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.red.shade400,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 20),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            secondaryBackground: Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.red.shade400,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            confirmDismiss: (direction) async {
                              return await showDialog<bool>(
                                context: context,
                                builder:
                                    (_) => AlertDialog(
                                      title: const Text('Delete movie?'),
                                      content: Text(
                                        'Remove "${m.title} from the list?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, true),
                                          child: Text('Delete'),
                                        ),
                                      ],
                                    ),
                              );
                            },
                            onDismissed: (_) => _deleteMovie(m.id!),
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 4,
                              ),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Theme.of(context).colorScheme.surface,
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 8,
                                    spreadRadius: 0,
                                    offset: const Offset(0, 2),
                                    color: Colors.black.withOpacity(0.06),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Hero(
                                      tag: 'poster - ${m.id}',
                                      child: _posterthumb(m.poster),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          m.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${m.category} ${m.year ?? "Year N/A"}',
                                          style: TextStyle(
                                            color:
                                                Theme.of(
                                                  context,
                                                ).textTheme.bodySmall?.color,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            const Icon(Icons.star, size: 16),
                                            const SizedBox(width: 4),
                                            Text(m.ratings.toStringAsFixed(1)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  InkWell(
                                    onTap: () => _togglewatched(m),
                                    child: AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 220,
                                      ),
                                      transitionBuilder:
                                          (child, anim) => ScaleTransition(
                                            scale: anim,
                                            child: child,
                                          ),
                                      child:
                                          m.watched
                                              ? const Icon(
                                                Icons.check_circle,
                                                key: ValueKey('watched'),
                                                color: Colors.green,
                                                size: 28,
                                              )
                                              : const Icon(
                                                Icons.radio_button_unchecked,
                                                key: ValueKey('unwatched'),
                                                size: 28,
                                              ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final saved = await Navigator.of(context).push(_addMovieRoute());
          if (saved == true) {
            _loadmovies();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add movie'),
      ),
    );
  }
}
