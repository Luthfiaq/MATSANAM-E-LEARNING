import 'package:http/http.dart' as http;

/// Progress ratio ranges from 0.0 to 1.0.
typedef UploadProgressCallback = void Function(double progress);

/// Sends a multipart request while reporting the request-body bytes written.
/// The response body is fully read before the HTTP client is closed.
Future<http.Response> sendMultipartWithProgress(
  http.MultipartRequest request, {
  required Duration timeout,
  UploadProgressCallback? onProgress,
}) async {
  final body = request.finalize();
  final totalBytes = request.contentLength;
  final outgoing = http.StreamedRequest(request.method, request.url)
    ..headers.addAll(request.headers)
    ..contentLength = totalBytes;

  final client = http.Client();
  final responseFuture = client.send(outgoing).timeout(timeout);
  var sentBytes = 0;

  try {
    await outgoing.sink
        .addStream(
          body.map((chunk) {
            sentBytes += chunk.length;
            if (totalBytes > 0) {
              onProgress?.call(
                (sentBytes / totalBytes).clamp(0.0, 1.0).toDouble(),
              );
            }
            return chunk;
          }),
        )
        .timeout(timeout);
    await outgoing.sink.close();

    final streamedResponse = await responseFuture;
    final response = await http.Response.fromStream(
      streamedResponse,
    ).timeout(timeout);
    onProgress?.call(1.0);
    return response;
  } catch (_) {
    try {
      await outgoing.sink.close();
    } catch (_) {
      // The sink may already be closed after a transport error.
    }
    rethrow;
  } finally {
    client.close();
  }
}
