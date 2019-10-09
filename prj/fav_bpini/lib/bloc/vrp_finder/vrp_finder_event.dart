import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class VrpFinderEvent extends Equatable {
  VrpFinderEvent() : super();
}

@immutable
class LoadCamera extends VrpFinderEvent {
  @override
  List<Object> get props => [];
}

class TextFound extends VrpFinderEvent {
  final String textFound;

  TextFound(this.textFound);
  @override
  List<Object> get props => [textFound];
}
