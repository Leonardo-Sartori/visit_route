enum VisitTags {
  visitMade,
  absentCustomer,
  visitCanceledByCustomer,
  }

extension StateString on VisitTags? {
  String get state {
    switch (this) {
      case VisitTags.visitMade:
        return "Visita Realizada";
      case VisitTags.absentCustomer:
        return "Cliente Ausente";
      case VisitTags.visitCanceledByCustomer:
        return "Cancelada pelo cliente";
      default:
        return "";
    }
  }
}