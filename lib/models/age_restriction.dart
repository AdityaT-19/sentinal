enum AgeRestriction { AR13, AR18, UR }

extension AgeRestrictionFromMap on AgeRestriction {
  static AgeRestriction fromMap(String value) {
    switch (value) {
      case 'AR13':
        return AgeRestriction.AR13;
      case 'AR18':
        return AgeRestriction.AR18;
      case 'UR':
        return AgeRestriction.UR;
      default:
        throw ArgumentError('Invalid value');
    }
  }
}
