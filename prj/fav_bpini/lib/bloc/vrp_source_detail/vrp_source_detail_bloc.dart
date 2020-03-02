import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:favbpini/bloc/vrp_source_detail/vrp_source_detail_state.dart';
import 'package:flutter/cupertino.dart';

import 'vrp_source_detail_event.dart';

class VrpSourceDetailBloc extends Bloc<VrpSourceDetailEvent, VrpSourceDetailState> {

  var _eagerHide = false;

  @override
  VrpSourceDetailState get initialState => StaticDetail();

  @override
  Stream<VrpSourceDetailState> mapEventToState(
    VrpSourceDetailEvent event,
  ) async* {
    if (event is OnHighlight) {
      if (_eagerHide) {
        _eagerHide = false;
        yield StaticDetail();
      } else {
        debugPrint("received onh");
        yield HighlightedDetail(event.highlightedArea, event.imageSize);
      }
    } else if (event is OnHideHighlight) {
      if (state is StaticDetail) {
        _eagerHide = true;
      } else {
        debugPrint("received onhide");
        yield StaticDetail();
      }
    }
  }
}
