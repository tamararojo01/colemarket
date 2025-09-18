import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Paleta verde propia (no Wallapop)
const kGreen = Color(0xFF0E9F6E);        // CTA principal
const kGreenDark = Color(0xFF0B7F58);    // hover/pressed / textos acción
const kGreenSoft = Color(0xFFCFEDE6);    // bordes suaves / acentos
const kMintSelected = Color(0xFFEAFBF6); // chips seleccionados claritos

ThemeData buildAppTheme(Brightness brightness) {
  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: ColorScheme.fromSeed(
      seedColor: kGreen,
      brightness: brightness,
    ),
  );

  final textTheme = GoogleFonts.poppinsTextTheme(base.textTheme).apply(
    bodyColor: Colors.black87,
    displayColor: Colors.black87,
  );

  return base.copyWith(
    // Base blanca para web
    scaffoldBackgroundColor: Colors.white,

    // Tipografías
    textTheme: textTheme,
    primaryTextTheme: textTheme,

    // AppBar
    appBarTheme: base.appBarTheme.copyWith(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: Colors.black,
        letterSpacing: 0.5,
      ),
    ),

    // Cards
    cardTheme: base.cardTheme.copyWith(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 1.5,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    iconTheme: const IconThemeData(color: Colors.black87),
    listTileTheme: const ListTileThemeData(
      iconColor: Colors.black87,
      textColor: Colors.black87,
    ),

    // Inputs y desplegables (menús blancos)
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      labelStyle: TextStyle(color: Colors.black87),
      hintStyle: TextStyle(color: Colors.black54),
      border: OutlineInputBorder(),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: kGreenSoft),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: kGreen, width: 1.6),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      textStyle: const TextStyle(color: Colors.black87),
      inputDecorationTheme: base.inputDecorationTheme,
      menuStyle: MenuStyle(
        backgroundColor: const MaterialStatePropertyAll(Colors.white),
        side: const MaterialStatePropertyAll(BorderSide(color: kGreenSoft)),
        shape: MaterialStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    ),

    // Chips de filtro claros
    chipTheme: base.chipTheme.copyWith(
      labelStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
      surfaceTintColor: Colors.transparent,
    ),

    // Botón principal (unificado)
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.disabled)) return kGreen.withOpacity(0.45);
          return kGreen;
        }),
        foregroundColor: const MaterialStatePropertyAll(Colors.white),
        overlayColor: MaterialStatePropertyAll(kGreen.withOpacity(0.08)),
        shape: MaterialStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        padding: const MaterialStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    ),

    // Botón contorneado a juego (Google, etc.)
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kGreenDark,              // texto/ícono
        side: const BorderSide(color: kGreen),    // borde verde
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ).copyWith(
        overlayColor: MaterialStatePropertyAll(kGreen.withOpacity(0.08)),
      ),
    ),

    // Enlaces/acciones
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: kGreenDark,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),

    // Diálogos legibles (API nueva DialogThemeData)
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: textTheme.titleMedium?.copyWith(
        color: Colors.black87, fontWeight: FontWeight.w700),
      contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.black87),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: kGreenSoft),
      ),
    ),
  );
}
