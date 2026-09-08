import 'package:flutter/material.dart';
import 'package:sqlite3/sqlite3.dart';
import '../services/database_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('توشه آخرت - تست دیتابیس')),
      body: FutureBuilder<Database>(
        future: DatabaseService.db,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('❌ خطا در لود دیتابیس', style: TextStyle(color: Colors.red)),
                  Text(snapshot.error.toString()),
                ],
              ),
            );
          }

          final db = snapshot.data!;
          return FutureBuilder<List<Map>>(
            future: db.select('SELECT COUNT(*) as count FROM contenttb'),
            builder: (context, countSnapshot) {
              if (countSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final count = countSnapshot.data?[0]['count'] ?? 0;
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle, size: 80, color: Colors.green),
                    const SizedBox(height: 20),
                    Text('دیتابیس با موفقیت لود شد!', style: Theme.of(context).textTheme.headlineMedium),
                    Text('تعداد رکورد: $count', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () async {
                        final random = db.select('SELECT * FROM contenttb LIMIT 1');
                        print('نمونه رکورد: ${random.first}');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('نمونه رکورد پرینت شد')),
                        );
                      },
                      child: const Text('تست نمونه رکورد'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
