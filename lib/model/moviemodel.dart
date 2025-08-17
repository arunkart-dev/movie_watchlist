class Moviemodel {
  int? id;
  String title;
  String category;
  String poster;
  int? year;
  bool watched;
  double ratings;
  String notes;

  Moviemodel({
    this.id,
    required this.title,
    required this.category,
    required this.poster,
    this.year,
    required this.watched,
    required this.ratings,
    required this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "category": category,
      "poster": poster,
      "year": year,
      "watched": watched ? 1 : 0,
      "ratings": ratings,
      "notes": notes,
    };
  }

  factory Moviemodel.fromMap(Map<String, dynamic> map) {
    return Moviemodel(
      title: map['title'],
      category: map['category'],
      poster: map['poster'],
      year: map['year'],
      watched: map['watched']==1,
      ratings: map['ratings']*1.0,
      notes: map['notes'],
    );
  }
}
