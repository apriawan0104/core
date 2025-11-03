// ignore_for_file: avoid_print

import 'package:app_core/app_core.dart';
import 'package:dartz/dartz.dart';
import 'package:get_it/get_it.dart';

/// Example of using the Network Service
///
/// This example demonstrates:
/// 1. Setting up the HttpClient
/// 2. Making basic HTTP requests
/// 3. Handling errors with Either
/// 4. Using interceptors
/// 5. File upload/download
void main() async {
  // Setup dependency injection
  await setupDI();

  print('=== Network Service Example ===\n');

  // Basic examples
  await basicRequestExample();
  await errorHandlingExample();
  await interceptorExample();
  await uploadExample();

  print('\n=== Example completed ===');
}

/// Setup dependency injection
Future<void> setupDI() async {
  final getIt = GetIt.instance;

  // Register HttpClient with Dio implementation
  getIt.registerLazySingleton<HttpClient>(
    () => DioHttpClient(
      baseUrl: 'https://jsonplaceholder.typicode.com',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      connectTimeout: 30000,
      receiveTimeout: 30000,
      sendTimeout: 30000,
      enableLogging: true, // Enable logging to see requests
    ),
  );

  print('✅ Dependency injection setup completed\n');
}

/// Example 1: Basic HTTP requests
Future<void> basicRequestExample() async {
  print('--- Example 1: Basic HTTP Requests ---');

  final httpClient = GetIt.instance<HttpClient>();

  // GET request
  print('Making GET request to /posts/1...');
  final getResult = await httpClient.get<Map<String, dynamic>>('/posts/1');

  getResult.fold(
    (failure) => print('❌ GET failed: ${failure.message}'),
    (response) {
      print('✅ GET success!');
      print('   Status: ${response.statusCode}');
      print('   Title: ${response.data?['title']}');
    },
  );

  // POST request
  print('\nMaking POST request to /posts...');
  final postResult = await httpClient.post<Map<String, dynamic>>(
    '/posts',
    data: {
      'title': 'Test Post',
      'body': 'This is a test post from Flutter',
      'userId': 1,
    },
  );

  postResult.fold(
    (failure) => print('❌ POST failed: ${failure.message}'),
    (response) {
      print('✅ POST success!');
      print('   Status: ${response.statusCode}');
      print('   Created ID: ${response.data?['id']}');
    },
  );

  // PUT request
  print('\nMaking PUT request to /posts/1...');
  final putResult = await httpClient.put<Map<String, dynamic>>(
    '/posts/1',
    data: {
      'id': 1,
      'title': 'Updated Post',
      'body': 'This post has been updated',
      'userId': 1,
    },
  );

  putResult.fold(
    (failure) => print('❌ PUT failed: ${failure.message}'),
    (response) {
      print('✅ PUT success!');
      print('   Status: ${response.statusCode}');
    },
  );

  // DELETE request
  print('\nMaking DELETE request to /posts/1...');
  final deleteResult = await httpClient.delete('/posts/1');

  deleteResult.fold(
    (failure) => print('❌ DELETE failed: ${failure.message}'),
    (response) {
      print('✅ DELETE success!');
      print('   Status: ${response.statusCode}');
    },
  );

  print('');
}

/// Example 2: Error handling
Future<void> errorHandlingExample() async {
  print('--- Example 2: Error Handling ---');

  final httpClient = GetIt.instance<HttpClient>();

  // Test 404 error
  print('Testing 404 error...');
  final notFoundResult = await httpClient.get('/posts/999999');

  notFoundResult.fold(
    (failure) {
      if (failure is NotFoundFailure) {
        print('✅ Correctly caught NotFoundFailure: ${failure.message}');
      } else {
        print('   Got ${failure.runtimeType}: ${failure.message}');
      }
    },
    (response) => print('   Unexpected success'),
  );

  // Test invalid endpoint (will likely get 404 or 400)
  print('\nTesting invalid endpoint...');
  final invalidResult = await httpClient.get('/invalid-endpoint-12345');

  invalidResult.fold(
    (failure) {
      print('✅ Correctly caught ${failure.runtimeType}');
      print('   Message: ${failure.message}');
    },
    (response) => print('   Response: ${response.statusCode}'),
  );

  print('');
}

/// Example 3: Using interceptors
Future<void> interceptorExample() async {
  print('--- Example 3: Using Interceptors ---');

  final httpClient = GetIt.instance<HttpClient>();

  // Add request interceptor (add custom header)
  print('Adding request interceptor...');
  httpClient.addRequestInterceptor((options) async {
    print('  → Interceptor: Adding custom header to request');
    final headers = {...?options.headers};
    headers['X-Custom-Header'] = 'Hello from interceptor';
    return options.copyWith(headers: headers);
  });

  // Add response interceptor (log response time)
  print('Adding response interceptor...');
  httpClient.addResponseInterceptor((response) async {
    print(
        '  ← Interceptor: Response received with status ${response.statusCode}');
    return response;
  });

  // Make request with interceptors
  print('\nMaking request with interceptors...');
  final result = await httpClient.get<Map<String, dynamic>>('/posts/1');

  result.fold(
    (failure) => print('❌ Request failed: ${failure.message}'),
    (response) {
      print('✅ Request succeeded!');
      print('   Status: ${response.statusCode}');
    },
  );

  // Clear interceptors for next examples
  httpClient.clearInterceptors();
  print('Interceptors cleared\n');
}

/// Example 4: File upload simulation
Future<void> uploadExample() async {
  print('--- Example 4: File Upload (Simulated) ---');

  // Note: JSONPlaceholder doesn't support file uploads
  // This is just a demonstration of the API

  print('File upload API example:');
  print('''
  
  final result = await httpClient.upload<Map<String, dynamic>>(
    '/upload',
    '/path/to/file.jpg',
    fieldName: 'file',
    data: {
      'description': 'My uploaded file',
      'tags': ['example', 'demo'],
    },
    onProgress: (sent, total) {
      final progress = (sent / total * 100).toStringAsFixed(2);
      print('Upload progress: \$progress%');
    },
  );
  
  result.fold(
    (failure) => print('Upload failed: \${failure.message}'),
    (response) => print('Upload success! ID: \${response.data?['id']}'),
  );
  ''');

  print('Download file API example:');
  print('''
  
  final result = await httpClient.download(
    'https://example.com/file.pdf',
    '/path/to/save/file.pdf',
    onProgress: (received, total) {
      final progress = (received / total * 100).toStringAsFixed(2);
      print('Download progress: \$progress%');
    },
  );
  
  result.fold(
    (failure) => print('Download failed: \${failure.message}'),
    (savePath) => print('Download success! Saved to: \$savePath'),
  );
  ''');

  print('');
}

/// Example repository using HttpClient
class PostRepository {
  final HttpClient _httpClient;

  PostRepository(this._httpClient);

  Future<Either<NetworkFailure, List<Post>>> getPosts() async {
    final result = await _httpClient.get<List<dynamic>>('/posts');

    return result.fold(
      (failure) => Left(failure),
      (response) {
        final posts = (response.data as List)
            .map((json) => Post.fromJson(json as Map<String, dynamic>))
            .toList();
        return Right(posts);
      },
    );
  }

  Future<Either<NetworkFailure, Post>> getPost(int id) async {
    final result = await _httpClient.get<Map<String, dynamic>>('/posts/$id');

    return result.fold(
      (failure) => Left(failure),
      (response) => Right(Post.fromJson(response.data!)),
    );
  }

  Future<Either<NetworkFailure, Post>> createPost(Post post) async {
    final result = await _httpClient.post<Map<String, dynamic>>(
      '/posts',
      data: post.toJson(),
    );

    return result.fold(
      (failure) => Left(failure),
      (response) => Right(Post.fromJson(response.data!)),
    );
  }

  Future<Either<NetworkFailure, Post>> updatePost(Post post) async {
    final result = await _httpClient.put<Map<String, dynamic>>(
      '/posts/${post.id}',
      data: post.toJson(),
    );

    return result.fold(
      (failure) => Left(failure),
      (response) => Right(Post.fromJson(response.data!)),
    );
  }

  Future<Either<NetworkFailure, void>> deletePost(int id) async {
    final result = await _httpClient.delete('/posts/$id');

    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(null),
    );
  }
}

/// Example model
class Post {
  final int id;
  final String title;
  final String body;
  final int userId;

  Post({
    required this.id,
    required this.title,
    required this.body,
    required this.userId,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      userId: json['userId'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'userId': userId,
    };
  }
}
