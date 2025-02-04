import 'package:mysql1/mysql1.dart' as mysql;

class Database {
  static Future<mysql.MySqlConnection> _getConnection() async {
    final settings = mysql.ConnectionSettings(
      host: 'localhost',
      port: 3306,
      user: 'root',
      password: '',
      db: 'task_management',
    );

    try {
      return await mysql.MySqlConnection.connect(settings);
    } catch (e) {
      throw Exception('Failed to connect to database: $e');
    }
  }

  static Future<void> initializeDatabase() async {
    final conn = await _getConnection();
    try {
      // Create users table
      await conn.query('''
        CREATE TABLE IF NOT EXISTS users (
          id INT AUTO_INCREMENT PRIMARY KEY,
          name VARCHAR(255) NOT NULL,
          email VARCHAR(255) NOT NULL UNIQUE,
          password VARCHAR(255) NOT NULL,
          profile_image VARCHAR(255),
          phone VARCHAR(20),
          is_admin TINYINT(1) DEFAULT 0,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      ''');

      // Create tasks table
      await conn.query('''
        CREATE TABLE IF NOT EXISTS tasks (
          id INT AUTO_INCREMENT PRIMARY KEY,
          title VARCHAR(255) NOT NULL,
          description TEXT,
          start_time DATETIME NOT NULL,
          end_time DATETIME NOT NULL,
          category VARCHAR(50) NOT NULL,
          is_completed TINYINT(1) DEFAULT 0,
          user_id INT NOT NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        )
      ''');
    } finally {
      await conn.close();
    }
  }

  static Future<List<mysql.ResultRow>> query(String sql,
      [List<Object?>? params]) async {
    final conn = await _getConnection();
    try {
      final results = await conn.query(sql, params);
      return results.toList();
    } finally {
      await conn.close();
    }
  }

  static Future<int> insert(String table, Map<String, dynamic> data) async {
    final conn = await _getConnection();
    try {
      final result = await conn.query(
        'INSERT INTO $table SET ?',
        [data],
      );
      return result.insertId ?? -1;
    } finally {
      await conn.close();
    }
  }

  static Future<int> update(
    String table,
    Map<String, dynamic> data,
    String where,
    List<Object?> whereArgs,
  ) async {
    final conn = await _getConnection();
    try {
      final setClause = data.keys.map((key) => '$key = ?').join(', ');
      final sql = 'UPDATE $table SET $setClause WHERE $where';
      final params = [...data.values, ...whereArgs];
      final result = await conn.query(sql, params);
      return result.affectedRows ?? 0;
    } finally {
      await conn.close();
    }
  }

  static Future<int> delete(
    String table,
    String where,
    List<Object?> whereArgs,
  ) async {
    final conn = await _getConnection();
    try {
      final result = await conn.query(
        'DELETE FROM $table WHERE $where',
        whereArgs,
      );
      return result.affectedRows ?? 0;
    } finally {
      await conn.close();
    }
  }
}
