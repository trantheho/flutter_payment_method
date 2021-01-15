import 'package:rxdart/rxdart.dart';

class Bloc<I, O> {
  /// Input data driven
  final BehaviorSubject<I> _inputSubject = BehaviorSubject<I>();

  /// Output data driven
  final BehaviorSubject<O> _outputSubject = BehaviorSubject<O>();

  ///  Dynamic logic
  /// Transfer data from input to mapper to output
  set logic(Stream<O> Function(Stream<I> input) mapper) {
    mapper(_inputSubject).listen(_outputSubject.sink.add);
  }

  /// Push input data to BLoC
  void push(I input) => _inputSubject.sink.add(input);

  /// Get input stream
  Stream<I> get input => _inputSubject;

  /// Stream output from BLoC
  Stream<O> get stream => _outputSubject;

  /// Dispose BLoC
  void dispose() {
    _inputSubject.close();
    _outputSubject.close();
  }

  /// Build a BLoC instance with logic function as a parameter
  static Bloc build<I, O>(Stream<O> Function(Stream<I> input) mapper) {
    var blocUnit = Bloc<I, O>();
    blocUnit.logic = mapper;
    return blocUnit;
  }
}

/// Default Bloc
class BlocDefault<I> extends Bloc<I, I> {
  BlocDefault() {
    this.logic = (Stream<I> data) => data;
  }
}

/// Base of Bloc
abstract class AppBloc {
  void initLogic();

  void dispose();
}