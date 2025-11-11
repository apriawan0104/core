/// HTTP Inspector infrastructure barrel file
///
/// Provides HTTP request/response inspection capabilities using various tools.
///
/// ## Available Implementations:
/// - ChuckerHttpInspectorServiceImpl (using chucker_flutter)
///
/// ## Usage:
/// ```dart
/// import 'package:app_core/app_core.dart';
///
/// // Initialize
/// final inspector = ChuckerHttpInspectorServiceImpl();
/// await inspector.initialize(HttpInspectorConfig());
///
/// // For Dio
/// dio.interceptors.add(inspector.getDioInterceptor().getOrElse(() => null));
///
/// // For http
/// final client = inspector.getHttpClient(http.Client()).getOrElse(() => null);
///
/// // For MaterialApp
/// MaterialApp(
///   navigatorObservers: [inspector.getNavigatorObserver()],
/// );
///
/// // Add debug button
/// Scaffold(
///   floatingActionButton: HttpInspectorButton(),
/// );
/// ```
library;

export 'constants/constants.dart';
export 'contract/contracts.dart';
export 'impl/impl.dart';
export 'models/models.dart';
export 'widget/widgets.dart';
