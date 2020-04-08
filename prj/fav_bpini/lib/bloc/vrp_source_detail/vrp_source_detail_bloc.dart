import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:favbpini/bloc/vrp_source_detail/vrp_source_detail_state.dart';

import 'vrp_source_detail_event.dart';

class VrpSourceDetailBloc extends Bloc<VrpSourceDetailEvent, VrpSourceDetailState> {
  var _earlyHide = false;

  @override
  VrpSourceDetailState get initialState => ClassicDetail();

  @override
  Stream<VrpSourceDetailState> mapEventToState(
    VrpSourceDetailEvent event,
  ) async* {
    if (event is Highlighted) {
      if (_earlyHide) {
        _earlyHide = false;
        yield ClassicDetail();
      } else {
        yield HighlightedDetail(event.highlightedArea, event.imageSize);
      }
    } else if (event is NotHighlighted) {
      if (state is ClassicDetail) {
        _earlyHide = true;
      } else {
        yield ClassicDetail();
      }
    }
  }
}
