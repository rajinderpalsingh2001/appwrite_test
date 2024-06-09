class Note {
  String? title;
  String? description;
 String? get getTitle => this.title;

 set setTitle(String? title) => this.title = title;

  get getDescription => this.description;

 set setDescription( description) => this.description = description;

  Note({required this.title, required this.description});

  Map<String, String> toMap() {
    Map<String, String> mp = {};
    mp["title"] = this.title!;
    mp["description"] = this.description!;
    return mp;
  }

  Note.toObj(Map<String, String> mp) {
    this.title = mp["title"];
    this.description = mp["description"];  
  }
}
