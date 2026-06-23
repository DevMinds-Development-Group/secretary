import 'package:flutter/material.dart';

import '../colors.dart';
import 'app_typography.dart';
import 'design_constants.dart';

/// Tema central de la aplicación, derivado del sistema de diseño
/// "FF Expandable-Menu" (ver design.md).
///
/// Expone [AppTheme.light]. La app es solo modo claro.
class AppTheme {
  AppTheme._();

  static ThemeData get light => _build();

  static ThemeData _build() {
    const Color bgPrimary = backgroundColor;
    const Color bgSecondary = secondaryBackground;
    const Color textPrimary = primaryText;
    const Color textSecondary = secondaryText;
    const Color alternate = alternateColor;

    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: primaryColor,
      onPrimary: infoColor,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      // secondary tonal == primaryContainer para que FilledButton.tonal use el azul tonal
      secondary: accentColor,
      onSecondary: infoColor,
      secondaryContainer: primaryContainer,
      onSecondaryContainer: onPrimaryContainer,
      tertiary: tertiaryColor,
      onTertiary: primaryText,
      tertiaryContainer: warningContainer,
      onTertiaryContainer: onWarningContainer,
      error: errorColor,
      onError: infoColor,
      errorContainer: errorContainerColor,
      onErrorContainer: onErrorContainer,
      surface: bgSecondary,
      onSurface: textPrimary,
      onSurfaceVariant: textSecondary,
      outline: alternate,
      outlineVariant: alternate,
      surfaceContainerLowest: bgSecondary,
      surfaceContainerLow: surfaceSubtle,
      surfaceContainer: surfaceSubtle,
      surfaceContainerHigh: surfaceSubtle,
      surfaceContainerHighest: surfaceSubtle,
      shadow: shadowColor,
    );

    final textTheme = AppTypography.textTheme;

    OutlineInputBorder inputBorder(Color color, double width) =>
        OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(DesignConstants.borderRadiusInput),
          borderSide: BorderSide(color: color, width: width),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bgPrimary,
      canvasColor: bgSecondary,
      fontFamily: AppTypography.fontBody,
      textTheme: textTheme,
      shadowColor: shadowColor,

      // --- AppBar (header minimalista claro, elevado con sombra persistente) ---
      appBarTheme: AppBarTheme(
        backgroundColor: bgSecondary,
        foregroundColor: textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        scrolledUnderElevation: 3,
        shadowColor: shadowColor,
        iconTheme: const IconThemeData(color: primaryText),
        titleTextStyle: textTheme.titleLarge?.copyWith(color: primaryText),
      ),

      // --- Cards ---
      cardTheme: CardThemeData(
        color: bgSecondary,
        elevation: 0,
        shadowColor: shadowColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignConstants.borderRadiusCard),
          side: BorderSide(
            color: alternate,
            width: DesignConstants.borderWidthCard,
          ),
        ),
      ),

      // --- Elevated (Primary) Button ---
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: infoColor,
          elevation: DesignConstants.elevationButton,
          shadowColor: shadowColor,
          textStyle: textTheme.titleSmall?.copyWith(color: infoColor),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(DesignConstants.borderRadiusButton),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: DesignConstants.buttonPaddingMedium,
          ),
        ),
      ),

      // --- Filled Button (M3 primary) ---
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: infoColor,
          textStyle: textTheme.titleSmall?.copyWith(color: infoColor),
          minimumSize: const Size(64, DesignConstants.buttonHeightMedium),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(DesignConstants.borderRadiusButton),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: DesignConstants.buttonPaddingMedium,
          ),
        ),
      ),

      // --- Outlined (Neutral) Button ---
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: bgSecondary,
          foregroundColor: textPrimary,
          textStyle: textTheme.bodyMedium,
          side: BorderSide(
            color: alternate,
            width: DesignConstants.borderWidthDefault,
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(DesignConstants.borderRadiusButton),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: DesignConstants.buttonPaddingMedium,
          ),
        ),
      ),

      // --- Text Button ---
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: textTheme.bodyMedium?.copyWith(color: primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(DesignConstants.borderRadiusButton),
          ),
        ),
      ),

      // --- Inputs / TextFields ---
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgSecondary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DesignConstants.inputPaddingHorizontal,
          vertical: DesignConstants.inputPaddingVertical,
        ),
        labelStyle: textTheme.labelMedium,
        hintStyle: textTheme.labelMedium,
        border: inputBorder(alternate, DesignConstants.borderWidthCard),
        enabledBorder:
            inputBorder(alternate, DesignConstants.borderWidthCard),
        focusedBorder:
            inputBorder(primaryColor, DesignConstants.borderWidthDefault),
        errorBorder:
            inputBorder(errorColor, DesignConstants.borderWidthDefault),
        focusedErrorBorder:
            inputBorder(errorColor, DesignConstants.borderWidthDefault),
      ),

      // --- Dropdown menu ---
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: bgSecondary,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(DesignConstants.borderRadiusDropdown),
            borderSide: BorderSide(
              color: alternate,
              width: DesignConstants.borderWidthDefault,
            ),
          ),
        ),
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(bgSecondary),
          elevation:
              const WidgetStatePropertyAll(DesignConstants.elevationDropdown),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(DesignConstants.borderRadiusDropdown),
            ),
          ),
        ),
      ),

      // --- Chips (tonal) ---
      chipTheme: ChipThemeData(
        backgroundColor: surfaceSubtle,
        selectedColor: primaryContainer,
        secondarySelectedColor: primaryContainer,
        labelStyle: textTheme.bodySmall?.copyWith(color: textSecondary),
        secondaryLabelStyle:
            textTheme.bodySmall?.copyWith(color: onPrimaryContainer),
        side: BorderSide(
          color: alternate,
          width: DesignConstants.borderWidthCard,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignConstants.borderRadiusChip),
        ),
      ),

      // --- Dialogs ---
      dialogTheme: DialogThemeData(
        backgroundColor: bgSecondary,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignConstants.borderRadiusCard),
        ),
        titleTextStyle: textTheme.headlineSmall,
        contentTextStyle: textTheme.bodyMedium,
      ),

      // --- Progress indicator ---
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
      ),

      // --- Divider (hairline) ---
      dividerTheme: const DividerThemeData(
        color: alternateColor,
        thickness: 1,
        space: 1,
      ),

      // --- ListTile (selección tonal, ícono monocromático) ---
      listTileTheme: ListTileThemeData(
        iconColor: textSecondary,
        selectedColor: primaryColor,
        selectedTileColor: primaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignConstants.borderRadiusCard),
        ),
      ),

      // --- Navigation Bar (compacto / móvil) ---
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: bgSecondary,
        surfaceTintColor: Colors.transparent,
        indicatorColor: primaryContainer,
        elevation: 2,
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? onPrimaryContainer : textSecondary,
            size: 24,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelMedium?.copyWith(
            color: selected ? primaryColor : textSecondary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          );
        }),
      ),

      // --- Navigation Rail (tablet / escritorio) ---
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: bgSecondary,
        indicatorColor: primaryContainer,
        selectedIconTheme:
            const IconThemeData(color: onPrimaryContainer, size: 24),
        unselectedIconTheme:
            const IconThemeData(color: secondaryText, size: 24),
        selectedLabelTextStyle:
            textTheme.labelMedium?.copyWith(color: primaryColor),
        unselectedLabelTextStyle:
            textTheme.labelMedium?.copyWith(color: textSecondary),
      ),

      // --- Date picker (migrado desde main.dart) ---
      datePickerTheme: _datePickerTheme(bgColor: bgSecondary),
    );
  }

  static DatePickerThemeData _datePickerTheme({
    required Color bgColor,
  }) {
    const textColor = primaryText;

    return DatePickerThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignConstants.borderRadiusCard),
      ),
      backgroundColor: bgColor,
      headerBackgroundColor: primaryColor,
      headerForegroundColor: infoColor,
      dayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return infoColor;
        return textColor;
      }),
      dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return primaryColor;
        return null;
      }),
      todayForegroundColor: WidgetStateProperty.all(primaryColor),
      todayBackgroundColor:
          WidgetStateProperty.all(primaryColor.withOpacity(0.15)),
      yearForegroundColor: WidgetStateProperty.all(textColor),
      headerHelpStyle: const TextStyle(
        fontFamily: AppTypography.fontBody,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      headerHeadlineStyle: const TextStyle(
        fontFamily: AppTypography.fontDisplay,
        fontSize: 28,
        fontWeight: FontWeight.w600,
      ),
      weekdayStyle: const TextStyle(
        fontFamily: AppTypography.fontBody,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      dayStyle: const TextStyle(
        fontFamily: AppTypography.fontBody,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      yearStyle: const TextStyle(
        fontFamily: AppTypography.fontBody,
        fontSize: 18,
      ),
    );
  }
}
