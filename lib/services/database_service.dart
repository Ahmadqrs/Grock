import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

class DatabaseService {
  static Database? _db;
  static bool _isInitialized = false;

  // موقعیت فایل فشرده در assets
  static const String _compressedDbPath = 'assets/book.db.gz';

  /// دیتابیس رو از حالت فشرده خارج می‌کنه و باز می‌کنه
  static Future<Database> get db async {
    if (_isInitialized) return _db!;

    try {
      // ۱. دایرکتوری اپ رو پیدا کن
      final appDocDir = await getApplicationDocumentsDirectory();
      final dbDir = Directory('${appDocDir.path}/databases');
      if (!await dbDir.exists()) {
        await dbDir.create(recursive: true);
      }

      final compressedFile = File('${dbDir.path}/book.db.gz');
      final dbFile = File('${dbDir.path}/book.db');

      // ۲. اگر فایل فشرده در assets هست، کپی کن
      if (await compressedFile.exists()) {
        await compressedFile.delete(); // پاک کردن قبلی
      }

      // کپی از assets به دایرکتوری اپ
      final assetFile = await rootBundle.load(_compressedDbPath);
      final bytes = assetFile.buffer.asUint8List();
      await compressedFile.writeAsBytes(bytes);

      // ۳. فشرده رو خارج کن (gzip)
      final gunzipped = await _gunzip(compressedFile, dbFile);

      // ۴. دیتابیس رو باز کن
      _db = sqlite3.open(gunzipped.path);
      _isInitialized = true;

      print('✅ دیتابیس کتاب به‌روزرسانی شد (book.db.gz → book.db)');
      return _db!;
    } catch (e) {
      print('❌ خطا در لود دیتابیس: $e');
      rethrow;
    }
  }

  /// فشرده‌سازی gzip
  static Future<File> _gunzip(File compressed, File output) async {
    final gunzipped = await GZipDecoder().decodeBytes(await compressed.readAsBytes());
    await output.writeAsBytes(gunzipped);
    await compressed.delete(); // پاک کردن فایل gz بعد از decompress
    return output;
  }
}
