/// Shares one in-flight [Future] across concurrent callers.
///
/// A call that starts after the flight settles runs [action] again.
class SingleFlight<T> {
  Future<T>? _current;

  Future<T> run(Future<T> Function() action) {
    final existing = _current;
    if (existing != null) return existing;

    final flight = action();
    _current = flight;
    flight
        .whenComplete(() {
          if (identical(_current, flight)) _current = null;
        })
        .ignore();
    return flight;
  }
}
