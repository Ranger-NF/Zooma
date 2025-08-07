import 'dart:math';

class Task{

  static List<Map<String, dynamic>> tasks = [
    {
      "id": 0,
      "title": "HGJHGJ",
      "description": "kdbdajbkfdakbsjkbjc",
      "points": 5,
      "createdAt": DateTime.now()
    },
    {
      "id": 0,
      "title": "HGJHGsad",
      "description": "kdbdsadaajbkfdakbsjkbjc",
      "points": 8,
      "createdAt": DateTime.now()
    },
    {
      "id": 0,
      "title": "HGDHGJ",
      "description": "kdsdadajbkfdakbsjkbjc",
      "points": 5,
      "createdAt": DateTime.now()
    },
    {
      "id": 0,
      "title": "HGJHGD",
      "description": "SADdbdajbkfdakbsjkbjc",
      "points": 5,
      "createdAt": DateTime.now()
    },
    {
      "id": 0,
      "title": "HGJHdas",
      "description": "dadbdajbkfdakbsjkbjc",
      "points": 5,
      "createdAt": DateTime.now()
    },
  ];

  static List<Map<String, dynamic>> getRandomTasks() {
    final random = Random();
    final shuffled = List<Map<String, dynamic>>.from(tasks)..shuffle(random);
    return shuffled.take(2).toList();
  }

}

  

  
