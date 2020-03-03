class VRP {
  final String firstPart;
  final String secondPart;
  final VRPType type;

  VRP(this.firstPart, this.secondPart, this.type);
}

enum VRPType { ONE_LINE_CLASSIC, ONE_LINE_OLD, ONE_LINE_VIP, TWO_LINE_BIKE, TWO_LINE_OTHER }

extension NameResolve on VRPType {
  String getName() {
    switch (this) {
      case VRPType.ONE_LINE_CLASSIC:
        return "Klasická";
      case VRPType.ONE_LINE_OLD:
        return "Historická";
      case VRPType.ONE_LINE_VIP:
        return "VIP";
      case VRPType.TWO_LINE_BIKE:
        return "Dvouřádková - motorka";
      case VRPType.TWO_LINE_OTHER:
        return "Dvouřádková - ostatní";
      default:
        return "UNKNOWN";
    }
  }
}
