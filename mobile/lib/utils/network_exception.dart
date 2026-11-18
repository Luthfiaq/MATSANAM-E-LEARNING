import 'network_exception_stub.dart'
    if (dart.library.io) 'network_exception_io.dart'
    as platform;

bool isSocketException(Object error) => platform.isSocketException(error);
