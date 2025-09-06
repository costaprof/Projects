import 'package:flutter/material.dart';
import 'package:was_essen/widgets/sterne_bewertung.dart';
import 'package:was_essen/widgets/week_selector.dart';

class RecipePlanner extends StatefulWidget {
  final GeplantesRezept rezept;

  const RecipePlanner({super.key, required this.rezept});

  @override
  _RecipePlannerState createState() => _RecipePlannerState();
}

class _RecipePlannerState extends State<RecipePlanner> {
  List<List<GeplantesRezept>> recipesPerDay = List.generate(5, (index) => []);

  @override
  Widget build(BuildContext context) {
    final days = [
      'Mittwoch, 17.07.',
      'Donnerstag, 18.07.',
      'Freitag, 19.07.',
      'Samstag, 20.07.',
      'Sonntag, 21.07.',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rezept einplanen'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Fertig', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
      body: Column(
        children: [
          WeekSelector(
              weekRange: '15.7 - 21.7.',
              onPreviousWeek: _onPreviousWeek,
              onNextWeek: _onNextWeek),
          ListTile(
            leading: Image.asset('assets/all-american-burger.png'),
            title:
                Text(widget.rezept.name, style: const TextStyle(color: Colors.black)),
            subtitle: Wrap(
              spacing: 8.0, // space between the widgets
              children: [
                SterneBewertung(
                  rating: widget.rezept.rating,
                  iconSize: 16,
                  fontSize: 16,
                  textColor: Colors.black,
                  iconColor: Colors.yellow,
                ),
                //mocked placeholders
                const Icon(Icons.timer, color: Colors.black, size: 16),
                Text('${widget.rezept.time} Min.',
                    style: const TextStyle(color: Colors.black)),
                const Icon(Icons.bar_chart, color: Colors.black, size: 16),
                Text(widget.rezept.difficulty,
                    style: const TextStyle(color: Colors.black)),
              ],
            ),
          ),
          const Divider(color: Colors.black),
          Expanded(
            child: ListView.builder(
              itemCount: days.length,
              itemBuilder: (context, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Row(
                        children: [
                          Text(days[index],
                              style: const TextStyle(color: Colors.black)),
                          if (index == 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('HEUTE',
                                  style: TextStyle(color: Colors.black)),
                            ),
                          ],
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.add_circle_outline,
                            color: Colors.green),
                        onPressed: () {
                          setState(() {
                            recipesPerDay[index].add(widget.rezept);
                          });
                        },
                      ),
                    ),
                    ...recipesPerDay[index]
                        .map((recipe) => Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: ListTile(
                                leading: Image.asset(
                                    'assets/all-american-burger.png'),
                                title: Text(recipe.name,
                                    style:
                                        const TextStyle(color: Colors.black)),
                                subtitle: Wrap(
                                  spacing: 8.0, // space between the widgets
                                  children: [
                                    SterneBewertung(
                                      rating: recipe.rating,
                                      iconSize: 16,
                                      fontSize: 16,
                                      textColor: Colors.black,
                                      iconColor: Colors.yellow,
                                    ),
                                    const Icon(Icons.timer,
                                        color: Colors.black, size: 16),
                                    Text('${recipe.time} Min.',
                                        style: const TextStyle(
                                            color: Colors.black)),
                                    const Icon(Icons.bar_chart,
                                        color: Colors.black, size: 16),
                                    Text(recipe.difficulty,
                                        style: const TextStyle(
                                            color: Colors.black)),
                                  ],
                                ),
                              ),
                            ))
                        ,
                    const Divider(color: Colors.black),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _onPreviousWeek() {
    print('previous week clicked');
  }

  void _onNextWeek() {
    print(('next week'));
  }
}

class GeplantesRezept {
  final String name;
  final double rating;
  final int time;
  final String difficulty;

  GeplantesRezept(
      {required this.name,
      required this.rating,
      required this.time,
      required this.difficulty});
}
