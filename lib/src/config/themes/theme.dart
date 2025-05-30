import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static MaterialScheme lightScheme() {
    return const MaterialScheme(
      brightness: Brightness.light,
      primary: Color(4278217322),
      surfaceTint: Color(4278217322),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4288475632),
      onPrimaryContainer: Color(4278198304),
      secondary: Color(4278217075),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4288606460),
      onSecondaryContainer: Color(4278198051),
      tertiary: Color(4278217074),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4288540923),
      onTertiaryContainer: Color(4278198051),
      error: Color(4290386458),
      onError: Color(4294967295),
      errorContainer: Color(4294957782),
      onErrorContainer: Color(4282449922),
      background: Color(4294245370),
      onBackground: Color(4279639325),
      surface: Color(4294310651),
      onSurface: Color(4279639325),
      surfaceVariant: Color(4292535525),
      onSurfaceVariant: Color(4282337354),
      outline: Color(4285495674),
      outlineVariant: Color(4290693321),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281020722),
      inverseOnSurface: Color(4293718770),
      inversePrimary: Color(4286633428),
      primaryFixed: Color(4288475632),
      onPrimaryFixed: Color(4278198304),
      primaryFixedDim: Color(4286633428),
      onPrimaryFixedVariant: Color(4278210383),
      secondaryFixed: Color(4288606460),
      onSecondaryFixed: Color(4278198051),
      secondaryFixedDim: Color(4286698463),
      onSecondaryFixedVariant: Color(4278210391),
      tertiaryFixed: Color(4288540923),
      onTertiaryFixed: Color(4278198051),
      tertiaryFixedDim: Color(4286698462),
      onTertiaryFixedVariant: Color(4278210390),
      surfaceDim: Color(4292205532),
      surfaceBright: Color(4294310651),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4293916149),
      surfaceContainer: Color(4293521392),
      surfaceContainerHigh: Color(4293126634),
      surfaceContainerHighest: Color(4292797668),
    );
  }

  ThemeData light() {
    return theme(lightScheme().toColorScheme());
  }

  static MaterialScheme lightMediumContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.light,
      primary: Color(4278209355),
      surfaceTint: Color(4278217322),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4280516993),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4278209106),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4280582283),
      onSecondaryContainer: Color(4294967295),
      tertiary: Color(4278209105),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4280582282),
      onTertiaryContainer: Color(4294967295),
      error: Color(4287365129),
      onError: Color(4294967295),
      errorContainer: Color(4292490286),
      onErrorContainer: Color(4294967295),
      background: Color(4294245370),
      onBackground: Color(4279639325),
      surface: Color(4294310651),
      onSurface: Color(4279639325),
      surfaceVariant: Color(4292535525),
      onSurfaceVariant: Color(4282074182),
      outline: Color(4283916642),
      outlineVariant: Color(4285758590),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281020722),
      inverseOnSurface: Color(4293718770),
      inversePrimary: Color(4286633428),
      primaryFixed: Color(4280516993),
      onPrimaryFixed: Color(4294967295),
      primaryFixedDim: Color(4278216551),
      onPrimaryFixedVariant: Color(4294967295),
      secondaryFixed: Color(4280582283),
      onSecondaryFixed: Color(4294967295),
      secondaryFixedDim: Color(4278216304),
      onSecondaryFixedVariant: Color(4294967295),
      tertiaryFixed: Color(4280582282),
      onTertiaryFixed: Color(4294967295),
      tertiaryFixedDim: Color(4278216303),
      onTertiaryFixedVariant: Color(4294967295),
      surfaceDim: Color(4292205532),
      surfaceBright: Color(4294310651),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4293916149),
      surfaceContainer: Color(4293521392),
      surfaceContainerHigh: Color(4293126634),
      surfaceContainerHighest: Color(4292797668),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme().toColorScheme());
  }

  static MaterialScheme lightHighContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.light,
      primary: Color(4278200103),
      surfaceTint: Color(4278217322),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4278209355),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4278200107),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4278209106),
      onSecondaryContainer: Color(4294967295),
      tertiary: Color(4278200107),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4278209105),
      onTertiaryContainer: Color(4294967295),
      error: Color(4283301890),
      onError: Color(4294967295),
      errorContainer: Color(4287365129),
      onErrorContainer: Color(4294967295),
      background: Color(4294245370),
      onBackground: Color(4279639325),
      surface: Color(4294310651),
      onSurface: Color(4278190080),
      surfaceVariant: Color(4292535525),
      onSurfaceVariant: Color(4280034599),
      outline: Color(4282074182),
      outlineVariant: Color(4282074182),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281020722),
      inverseOnSurface: Color(4294967295),
      inversePrimary: Color(4289133562),
      primaryFixed: Color(4278209355),
      onPrimaryFixed: Color(4294967295),
      primaryFixedDim: Color(4278203187),
      onPrimaryFixedVariant: Color(4294967295),
      secondaryFixed: Color(4278209106),
      onSecondaryFixed: Color(4294967295),
      secondaryFixedDim: Color(4278202936),
      onSecondaryFixedVariant: Color(4294967295),
      tertiaryFixed: Color(4278209105),
      onTertiaryFixed: Color(4294967295),
      tertiaryFixedDim: Color(4278202935),
      onTertiaryFixedVariant: Color(4294967295),
      surfaceDim: Color(4292205532),
      surfaceBright: Color(4294310651),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4293916149),
      surfaceContainer: Color(4293521392),
      surfaceContainerHigh: Color(4293126634),
      surfaceContainerHighest: Color(4292797668),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme().toColorScheme());
  }

  static MaterialScheme darkScheme() {
    return const MaterialScheme(
      brightness: Brightness.dark,
      primary: Color(4286633428),
      surfaceTint: Color(4286633428),
      onPrimary: Color(4278204215),
      primaryContainer: Color(4278210383),
      onPrimaryContainer: Color(4288475632),
      secondary: Color(4286698463),
      onSecondary: Color(4278203964),
      secondaryContainer: Color(4278210391),
      onSecondaryContainer: Color(4288606460),
      tertiary: Color(4286698462),
      onTertiary: Color(4278203964),
      tertiaryContainer: Color(4278210390),
      onTertiaryContainer: Color(4288540923),
      error: Color(4294948011),
      onError: Color(4285071365),
      errorContainer: Color(4287823882),
      onErrorContainer: Color(4294957782),
      background: Color(4279112980),
      onBackground: Color(4292732131),
      surface: Color(4279112725),
      onSurface: Color(4292797668),
      surfaceVariant: Color(4282337354),
      onSurfaceVariant: Color(4290693321),
      outline: Color(4287206036),
      outlineVariant: Color(4282337354),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4292797668),
      inverseOnSurface: Color(4281020722),
      inversePrimary: Color(4278217322),
      primaryFixed: Color(4288475632),
      onPrimaryFixed: Color(4278198304),
      primaryFixedDim: Color(4286633428),
      onPrimaryFixedVariant: Color(4278210383),
      secondaryFixed: Color(4288606460),
      onSecondaryFixed: Color(4278198051),
      secondaryFixedDim: Color(4286698463),
      onSecondaryFixedVariant: Color(4278210391),
      tertiaryFixed: Color(4288540923),
      onTertiaryFixed: Color(4278198051),
      tertiaryFixedDim: Color(4286698462),
      onTertiaryFixedVariant: Color(4278210390),
      surfaceDim: Color(4279112725),
      surfaceBright: Color(4281612859),
      surfaceContainerLowest: Color(4278783760),
      surfaceContainerLow: Color(4279639325),
      surfaceContainer: Color(4279902497),
      surfaceContainerHigh: Color(4280625964),
      surfaceContainerHighest: Color(4281349687),
    );
  }

  ThemeData dark() {
    return theme(darkScheme().toColorScheme());
  }

  static MaterialScheme darkMediumContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.dark,
      primary: Color(4286896600),
      surfaceTint: Color(4286633428),
      onPrimary: Color(4278196762),
      primaryContainer: Color(4282883741),
      onPrimaryContainer: Color(4278190080),
      secondary: Color(4287027172),
      onSecondary: Color(4278196765),
      secondaryContainer: Color(4282948776),
      onSecondaryContainer: Color(4278190080),
      tertiary: Color(4286961890),
      onTertiary: Color(4278196765),
      tertiaryContainer: Color(4282949031),
      onTertiaryContainer: Color(4278190080),
      error: Color(4294949553),
      onError: Color(4281794561),
      errorContainer: Color(4294923337),
      onErrorContainer: Color(4278190080),
      background: Color(4279112980),
      onBackground: Color(4292732131),
      surface: Color(4279112725),
      onSurface: Color(4294376700),
      surfaceVariant: Color(4282337354),
      onSurfaceVariant: Color(4291022286),
      outline: Color(4288390566),
      outlineVariant: Color(4286285190),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4292797668),
      inverseOnSurface: Color(4280625964),
      inversePrimary: Color(4278210897),
      primaryFixed: Color(4288475632),
      onPrimaryFixed: Color(4278195220),
      primaryFixedDim: Color(4286633428),
      onPrimaryFixedVariant: Color(4278205757),
      secondaryFixed: Color(4288606460),
      onSecondaryFixed: Color(4278195223),
      secondaryFixedDim: Color(4286698463),
      onSecondaryFixedVariant: Color(4278205763),
      tertiaryFixed: Color(4288540923),
      onTertiaryFixed: Color(4278195223),
      tertiaryFixedDim: Color(4286698462),
      onTertiaryFixedVariant: Color(4278205762),
      surfaceDim: Color(4279112725),
      surfaceBright: Color(4281612859),
      surfaceContainerLowest: Color(4278783760),
      surfaceContainerLow: Color(4279639325),
      surfaceContainer: Color(4279902497),
      surfaceContainerHigh: Color(4280625964),
      surfaceContainerHighest: Color(4281349687),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme().toColorScheme());
  }

  static MaterialScheme darkHighContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.dark,
      primary: Color(4293591038),
      surfaceTint: Color(4286633428),
      onPrimary: Color(4278190080),
      primaryContainer: Color(4286896600),
      onPrimaryContainer: Color(4278190080),
      secondary: Color(4294049279),
      onSecondary: Color(4278190080),
      secondaryContainer: Color(4287027172),
      onSecondaryContainer: Color(4278190080),
      tertiary: Color(4293983743),
      onTertiary: Color(4278190080),
      tertiaryContainer: Color(4286961890),
      onTertiaryContainer: Color(4278190080),
      error: Color(4294965753),
      onError: Color(4278190080),
      errorContainer: Color(4294949553),
      onErrorContainer: Color(4278190080),
      background: Color(4279112980),
      onBackground: Color(4292732131),
      surface: Color(4279112725),
      onSurface: Color(4294967295),
      surfaceVariant: Color(4282337354),
      onSurfaceVariant: Color(4294180350),
      outline: Color(4291022286),
      outlineVariant: Color(4291022286),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4292797668),
      inverseOnSurface: Color(4278190080),
      inversePrimary: Color(4278202416),
      primaryFixed: Color(4288738805),
      onPrimaryFixed: Color(4278190080),
      primaryFixedDim: Color(4286896600),
      onPrimaryFixedVariant: Color(4278196762),
      secondaryFixed: Color(4289197055),
      onSecondaryFixed: Color(4278190080),
      secondaryFixedDim: Color(4287027172),
      onSecondaryFixedVariant: Color(4278196765),
      tertiaryFixed: Color(4288869631),
      onTertiaryFixed: Color(4278190080),
      tertiaryFixedDim: Color(4286961890),
      onTertiaryFixedVariant: Color(4278196765),
      surfaceDim: Color(4279112725),
      surfaceBright: Color(4281612859),
      surfaceContainerLowest: Color(4278783760),
      surfaceContainerLow: Color(4279639325),
      surfaceContainer: Color(4279902497),
      surfaceContainerHigh: Color(4280625964),
      surfaceContainerHighest: Color(4281349687),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme().toColorScheme());
  }


  ThemeData theme(ColorScheme colorScheme) => ThemeData(
     useMaterial3: true,
     brightness: colorScheme.brightness,
     colorScheme: colorScheme,
     textTheme: textTheme.apply(
       bodyColor: colorScheme.onSurface,
       displayColor: colorScheme.onSurface,
     ),
     scaffoldBackgroundColor: colorScheme.background,
     canvasColor: colorScheme.surface,
  );


  List<ExtendedColor> get extendedColors => [
  ];
}

class MaterialScheme {
  const MaterialScheme({
    required this.brightness,
    required this.primary, 
    required this.surfaceTint, 
    required this.onPrimary, 
    required this.primaryContainer, 
    required this.onPrimaryContainer, 
    required this.secondary, 
    required this.onSecondary, 
    required this.secondaryContainer, 
    required this.onSecondaryContainer, 
    required this.tertiary, 
    required this.onTertiary, 
    required this.tertiaryContainer, 
    required this.onTertiaryContainer, 
    required this.error, 
    required this.onError, 
    required this.errorContainer, 
    required this.onErrorContainer, 
    required this.background, 
    required this.onBackground, 
    required this.surface, 
    required this.onSurface, 
    required this.surfaceVariant, 
    required this.onSurfaceVariant, 
    required this.outline, 
    required this.outlineVariant, 
    required this.shadow, 
    required this.scrim, 
    required this.inverseSurface, 
    required this.inverseOnSurface, 
    required this.inversePrimary, 
    required this.primaryFixed, 
    required this.onPrimaryFixed, 
    required this.primaryFixedDim, 
    required this.onPrimaryFixedVariant, 
    required this.secondaryFixed, 
    required this.onSecondaryFixed, 
    required this.secondaryFixedDim, 
    required this.onSecondaryFixedVariant, 
    required this.tertiaryFixed, 
    required this.onTertiaryFixed, 
    required this.tertiaryFixedDim, 
    required this.onTertiaryFixedVariant, 
    required this.surfaceDim, 
    required this.surfaceBright, 
    required this.surfaceContainerLowest, 
    required this.surfaceContainerLow, 
    required this.surfaceContainer, 
    required this.surfaceContainerHigh, 
    required this.surfaceContainerHighest, 
  });

  final Brightness brightness;
  final Color primary;
  final Color surfaceTint;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color secondary;
  final Color onSecondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color tertiary;
  final Color onTertiary;
  final Color tertiaryContainer;
  final Color onTertiaryContainer;
  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color onErrorContainer;
  final Color background;
  final Color onBackground;
  final Color surface;
  final Color onSurface;
  final Color surfaceVariant;
  final Color onSurfaceVariant;
  final Color outline;
  final Color outlineVariant;
  final Color shadow;
  final Color scrim;
  final Color inverseSurface;
  final Color inverseOnSurface;
  final Color inversePrimary;
  final Color primaryFixed;
  final Color onPrimaryFixed;
  final Color primaryFixedDim;
  final Color onPrimaryFixedVariant;
  final Color secondaryFixed;
  final Color onSecondaryFixed;
  final Color secondaryFixedDim;
  final Color onSecondaryFixedVariant;
  final Color tertiaryFixed;
  final Color onTertiaryFixed;
  final Color tertiaryFixedDim;
  final Color onTertiaryFixedVariant;
  final Color surfaceDim;
  final Color surfaceBright;
  final Color surfaceContainerLowest;
  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;
}

extension MaterialSchemeUtils on MaterialScheme {
  ColorScheme toColorScheme() {
    return ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      tertiary: tertiary,
      onTertiary: onTertiary,
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer,
      error: error,
      onError: onError,
      errorContainer: errorContainer,
      onErrorContainer: onErrorContainer,
      background: background,
      onBackground: onBackground,
      surface: surface,
      onSurface: onSurface,
      surfaceVariant: surfaceVariant,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      outlineVariant: outlineVariant,
      shadow: shadow,
      scrim: scrim,
      inverseSurface: inverseSurface,
      onInverseSurface: inverseOnSurface,
      inversePrimary: inversePrimary,
    );
  }
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
