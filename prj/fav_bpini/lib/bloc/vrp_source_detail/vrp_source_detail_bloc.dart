import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:favbpini/bloc/vrp_source_detail/vrp_source_detail_state.dart';

import 'vrp_source_detail_event.dart';

class VrpSourceDetailBloc extends Bloc<VrpSourceDetailEvent, VrpSourceDetailState> {
  @override
  VrpSourceDetailState get initialState => StaticDetail();

  @override
  Stream<VrpSourceDetailState> mapEventToState(
    VrpSourceDetailEvent event,
  ) async* {
    if (event is OnHighlight) {
      yield HighlightedDetail(event.highlightedArea, event.imageSize);
    } else if (event is OnHideHighlight) {
      yield StaticDetail();
    }
  }
}
