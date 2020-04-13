import 'package:equatable/equatable.dart';
import 'package:favbpini/app_localizations.dart';
import 'package:flutter/material.dart';

class VRP extends Equatable {
  final String firstPart;
  final String secondPart;
  final VRPType type;

  VRP(this.firstPart, this.secondPart, this.type);

  @override
  List<Object> get props => [firstPart, secondPart];
}

enum VRPType { ONE_LINE_CLASSIC, ONE_LINE_OLD, ONE_LINE_VIP, TWO_LINE_BIKE, TWO_LINE_OTHER }

extension NameResolve on VRPType {
  String getName(BuildContext context) {
    switch (this) {
      case VRPType.ONE_LINE_CLASSIC:
        return AppLocalizations.of(context).translate("vrp_type_one_line_classic");
      case VRPType.ONE_LINE_OLD:
        return AppLocalizations.of(context).translate("vrp_type_one_line_old");
      case VRPType.ONE_LINE_VIP:
        return AppLocalizations.of(context).translate("vrp_type_one_line_vip");
      case VRPType.TWO_LINE_BIKE:
        return AppLocalizations.of(context).translate("vrp_type_two_line_bike");
      case VRPType.TWO_LINE_OTHER:
        return AppLocalizations.of(context).translate("vrp_type_two_line_other");
      default:
        return "UNKNOWN";
    }
  }
}
