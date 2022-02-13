// ignore_for_file: constant_identifier_names

enum NetworkRoutes { DEFAULT, SEARCH_PLACE, LOGIN }

extension NetworkRoutesString on NetworkRoutes {
  String get rawValue {
    switch (this) {
      case NetworkRoutes.DEFAULT:
        return '';
      case NetworkRoutes.SEARCH_PLACE:
        return 'public/registry/verify';
      case NetworkRoutes.LOGIN:
        return 'en/login';
      default:
        throw Exception('Routes Not Found');
    }
  }
}
