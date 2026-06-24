# FF Expandable-Menu - Design System

Sistema de diseño extraído del proyecto FlutterFlow "FF Expandable-Menu" para replicar la apariencia visual en otras aplicaciones.

---

## 1. Paleta de Colores

### Colores Principales

| Nombre | Light Mode | Dark Mode | Uso |
|--------|------------|-----------|-----|
| **Primary** | `#0F77FF` | `#0F77FF` | Color principal de la marca, botones primarios, enlaces |
| **Secondary** | `#27C880` | `#27C880` | Acentos secundarios, indicadores de éxito |
| **Tertiary** | `#FFB560` | `#FFB560` | Acentos terciarios, elementos destacados |

### Colores de Fondo

| Nombre | Light Mode | Dark Mode | Uso |
|--------|------------|-----------|-----|
| **Primary Background** | `#F1F4F8` | `#16191D` | Fondo principal de la app |
| **Secondary Background** | `#FFFFFF` | `#1A1D21` | Fondo de cards, contenedores |
| **Background (Custom)** | `#1B1D27` | `#1B1D27` | Fondo alternativo/especial |

### Colores de Texto

| Nombre | Light Mode | Dark Mode | Uso |
|--------|------------|-----------|-----|
| **Primary Text** | `#1A1D21` | `#FFFFFF` | Texto principal, títulos |
| **Secondary Text** | `#57636C` | `#A9ADC6` | Texto secundario, descripciones |

### Colores de UI

| Nombre | Light Mode | Dark Mode | Uso |
|--------|------------|-----------|-----|
| **Alternate** | `#E0E3E7` | `#24282E` | Bordes, divisores, fondos alternativos |
| **Info** | `#FFFFFF` | `#FFFFFF` | Texto sobre fondos de color |

### Colores de Estado

| Nombre | Valor | Uso |
|--------|-------|-----|
| **Success** | `#03CE9F` | Estados exitosos, confirmaciones |
| **Warning** | `#F9A33F` | Advertencias, alertas |
| **Error** | `#FF4D6A` | Errores, validaciones fallidas |

### Colores de Acento (con transparencia)

| Nombre | Light Mode | Dark Mode | Uso |
|--------|------------|-----------|-----|
| **Accent 1** | `#0F77FF` (30% opacity) | `#0F77FF` (30% opacity) | Hover sobre primary, fondos sutiles |
| **Accent 2** | `#27C880` (30% opacity) | `#27C880` (30% opacity) | Hover sobre secondary |
| **Accent 3** | `#FFB560` (30% opacity) | `#FFB560` (30% opacity) | Hover sobre tertiary |
| **Accent 4** | `#FFFFFF` (60% opacity) | `#24282E` (70% opacity) | Overlays, fondos difusos |

### Sombras

| Nombre | Valor | Uso |
|--------|-------|-----|
| **Shadow** | `#000000` (20% opacity) | Sombras de elevación |

---

## 2. Tipografía

### Fuentes

| Tipo | Familia | Notas |
|------|---------|-------|
| **Primaria** | `Figtree` | Títulos, displays, headlines |
| **Secundaria** | `Plus Jakarta Sans` | Body, labels, títulos pequeños |

### Escala Tipográfica

#### Display (Figtree)

| Estilo | Tamaño | Peso | Color |
|--------|--------|------|-------|
| **Display Large** | 48px | Regular (w400) | Primary Text |
| **Display Medium** | 36px | Semi-bold (w600) | Primary Text |
| **Display Small** | 32px | Semi-bold (w600) | Primary Text |

#### Headline (Figtree)

| Estilo | Tamaño | Peso | Color |
|--------|--------|------|-------|
| **Headline Large** | 32px | Regular (w400) | Primary Text |
| **Headline Medium** | 24px | Medium (w500) | Primary Text |
| **Headline Small** | 22px | Semi-bold (w600) | Primary Text |

#### Title (Plus Jakarta Sans)

| Estilo | Tamaño | Peso | Color |
|--------|--------|------|-------|
| **Title Large** | 18px | Medium (w500) | Primary Text |
| **Title Medium** | 18px | Medium (w500) | Info (blanco) |
| **Title Small** | 16px | Medium (w500) | Info (blanco) |

#### Body (Plus Jakarta Sans)

| Estilo | Tamaño | Peso | Color |
|--------|--------|------|-------|
| **Body Large** | 16px | Medium (w500) | Primary Text |
| **Body Medium** | 14px | Medium (w500) | Primary Text |
| **Body Small** | 12px | Medium (w500) | Primary Text |

#### Label (Plus Jakarta Sans)

| Estilo | Tamaño | Peso | Color |
|--------|--------|------|-------|
| **Label Large** | 16px | Medium (w500) | Secondary Text |
| **Label Medium** | 14px | Medium (w500) | Secondary Text |
| **Label Small** | 12px | Medium (w500) | Secondary Text |

---

## 3. Espaciado y Border Radius

### Border Radius

| Componente | Valor |
|------------|-------|
| **Botones** | 12px |
| **Inputs/TextFields** | 12px |
| **Cards/Containers** | 12px |
| **Dropdowns** | 8px |
| **Chips** | 12px |

### Espaciado (Padding/Margin)

| Uso | Valor |
|-----|-------|
| **Container horizontal** | 16px |
| **Input content horizontal** | 20px |
| **Input content vertical** | 24px |
| **Button small padding** | 16px horizontal |
| **Button medium padding** | 24px horizontal |
| **Button large padding** | 44px horizontal |
| **Chip padding** | 12px horizontal, 4px vertical |
| **Chip spacing** | 8px |

---

## 4. Componentes

### Botones

#### Primary Button (Filled)

```
Fondo: Primary (#0F77FF)
Texto: Info (#FFFFFF)
Border: ninguno
Border Radius: 12px
Elevación: 3

Hover:
  Fondo: Accent 1 (Primary 30%)
  Borde: Primary
  Texto: Primary Text
  Elevación: 0
```

| Tamaño | Altura | Padding H | Estilo Texto |
|--------|--------|-----------|--------------|
| Small | 36px | 16px | Body Medium |
| Medium | 44px | 24px | Title Small |
| Large | 48px | 44px | Title Medium |

#### Primary Outline Button

```
Fondo: Accent 1 (Primary 30%)
Texto: Primary Text
Border: 2px Primary
Border Radius: 12px
Elevación: 0

Hover:
  Fondo: Primary
  Borde: Primary
  Texto: Info
  Elevación: 3
```

| Tamaño | Altura | Padding H | Estilo Texto |
|--------|--------|-----------|--------------|
| Small | 36px | 16px | Body Medium |
| Medium | 44px | 24px | Body Large |
| Large | 48px | 44px | Title Large (18px) |

#### Outline Button (Neutral)

```
Fondo: Secondary Background
Texto: Primary Text
Border: 2px Alternate
Border Radius: 12px
Elevación: 0

Hover:
  Fondo: Alternate
  Borde: Alternate
  Texto: Primary Text
  Elevación: 3
```

| Tamaño | Altura | Padding H | Estilo Texto |
|--------|--------|-----------|--------------|
| Small | 36px | 16px | Body Medium |
| Medium | 44px | 24px | Body Medium |
| Large | 48px | 44px | Title Large (18px) |

---

### Text Fields

```
Fondo: Secondary Background
Border: 2px Alternate
Border Radius: 12px
Padding: 20px horizontal, 24px vertical

Focus:
  Border: 2px Primary

Error:
  Border: 2px Error

Cursor: Primary
Texto: Body Medium
Label: Label Medium
Hint: Label Medium
```

---

### Dropdown

```
Fondo: Secondary Background
Border: 2px Alternate
Border Radius: 8px
Elevación: 2
Dimensiones: 300px x 50px
Padding: 16px horizontal, 4px vertical

Icono: keyboard_arrow_down_rounded
Icono Color: Secondary Text
Icono Tamaño: 24px

Texto: Body Medium
Search Hint: Label Medium
```

---

### Choice Chips

#### Chip Seleccionado

```
Fondo: Accent 1 (Primary 30%)
Texto: Primary
Border: 2px Primary
Border Radius: 12px
Elevación: 4
Padding: 12px horizontal, 4px vertical
Icono Color: Primary
Icono Tamaño: 18px
```

#### Chip No Seleccionado

```
Fondo: Primary Background
Texto: Secondary Text
Border: 2px Alternate
Border Radius: 12px
Elevación: 0
Padding: 12px horizontal, 4px vertical
Icono Color: Secondary Text
Icono Tamaño: 18px
```

---

### Cards / Containers con Elevación

#### Elevation 1

```
Fondo: Secondary Background
Border: 1px Alternate
Border Radius: 12px
Shadow:
  - Color: #000000 (20% opacity)
  - Blur: 3px
  - Offset: (0, 1)
Max Width: 770px
Min Height: 70px
Padding: 16px horizontal
Animation: ease-in-out, 100ms
```

#### Elevation 2

```
Fondo: Secondary Background
Border: 1px Alternate
Border Radius: 12px
Shadow:
  - Color: #000000 (20% opacity)
  - Blur: 4px
  - Offset: (0, 2)
```

---

## 5. Loading Indicator

```
Tipo: Three Bounce
Color: Primary
Diámetro: 50px
```

---

## 6. Implementación en Flutter

### Colores (lib/flutter_flow/flutter_flow_theme.dart)

```dart
class LightModeTheme extends FlutterFlowTheme {
  @override Color get primary => const Color(0xFF0F77FF);
  @override Color get secondary => const Color(0xFF27C880);
  @override Color get tertiary => const Color(0xFFFFB560);
  @override Color get alternate => const Color(0xFFE0E3E7);
  @override Color get primaryText => const Color(0xFF1A1D21);
  @override Color get secondaryText => const Color(0xFF57636C);
  @override Color get primaryBackground => const Color(0xFFF1F4F8);
  @override Color get secondaryBackground => const Color(0xFFFFFFFF);
  @override Color get accent1 => const Color(0x4C0F77FF);
  @override Color get accent2 => const Color(0x4D27C880);
  @override Color get accent3 => const Color(0x4DFFB560);
  @override Color get accent4 => const Color(0x9AFFFFFF);
  @override Color get success => const Color(0xFF03CE9F);
  @override Color get warning => const Color(0xFFF9A33F);
  @override Color get error => const Color(0xFFFF4D6A);
  @override Color get info => const Color(0xFFFFFFFF);
}

class DarkModeTheme extends FlutterFlowTheme {
  @override Color get primary => const Color(0xFF0F77FF);
  @override Color get secondary => const Color(0xFF27C880);
  @override Color get tertiary => const Color(0xFFFFB560);
  @override Color get alternate => const Color(0xFF24282E);
  @override Color get primaryText => const Color(0xFFFFFFFF);
  @override Color get secondaryText => const Color(0xFFA9ADC6);
  @override Color get primaryBackground => const Color(0xFF16191D);
  @override Color get secondaryBackground => const Color(0xFF1A1D21);
  @override Color get accent1 => const Color(0x4C0F77FF);
  @override Color get accent2 => const Color(0x4D27C880);
  @override Color get accent3 => const Color(0x4DFFB560);
  @override Color get accent4 => const Color(0xB224282E);
  @override Color get success => const Color(0xFF03CE9F);
  @override Color get warning => const Color(0xFFF9A33F);
  @override Color get error => const Color(0xFFFF4D6A);
  @override Color get info => const Color(0xFFFFFFFF);
}
```

### Tipografía

```dart
// pubspec.yaml - agregar fuentes
google_fonts: ^6.0.0

// En el código
import 'package:google_fonts/google_fonts.dart';

TextStyle displayLarge = GoogleFonts.figtree(
  fontSize: 48,
  fontWeight: FontWeight.w400,
  color: primaryText,
);

TextStyle displayMedium = GoogleFonts.figtree(
  fontSize: 36,
  fontWeight: FontWeight.w600,
  color: primaryText,
);

TextStyle displaySmall = GoogleFonts.figtree(
  fontSize: 32,
  fontWeight: FontWeight.w600,
  color: primaryText,
);

TextStyle headlineLarge = GoogleFonts.figtree(
  fontSize: 32,
  fontWeight: FontWeight.w400,
  color: primaryText,
);

TextStyle headlineMedium = GoogleFonts.figtree(
  fontSize: 24,
  fontWeight: FontWeight.w500,
  color: primaryText,
);

TextStyle headlineSmall = GoogleFonts.figtree(
  fontSize: 22,
  fontWeight: FontWeight.w600,
  color: primaryText,
);

TextStyle titleLarge = GoogleFonts.plusJakartaSans(
  fontSize: 18,
  fontWeight: FontWeight.w500,
  color: primaryText,
);

TextStyle titleMedium = GoogleFonts.plusJakartaSans(
  fontSize: 18,
  fontWeight: FontWeight.w500,
  color: info,
);

TextStyle titleSmall = GoogleFonts.plusJakartaSans(
  fontSize: 16,
  fontWeight: FontWeight.w500,
  color: info,
);

TextStyle bodyLarge = GoogleFonts.plusJakartaSans(
  fontSize: 16,
  fontWeight: FontWeight.w500,
  color: primaryText,
);

TextStyle bodyMedium = GoogleFonts.plusJakartaSans(
  fontSize: 14,
  fontWeight: FontWeight.w500,
  color: primaryText,
);

TextStyle bodySmall = GoogleFonts.plusJakartaSans(
  fontSize: 12,
  fontWeight: FontWeight.w500,
  color: primaryText,
);

TextStyle labelLarge = GoogleFonts.plusJakartaSans(
  fontSize: 16,
  fontWeight: FontWeight.w500,
  color: secondaryText,
);

TextStyle labelMedium = GoogleFonts.plusJakartaSans(
  fontSize: 14,
  fontWeight: FontWeight.w500,
  color: secondaryText,
);

TextStyle labelSmall = GoogleFonts.plusJakartaSans(
  fontSize: 12,
  fontWeight: FontWeight.w500,
  color: secondaryText,
);
```

### Constantes de Diseño

```dart
class DesignConstants {
  // Border Radius
  static const double borderRadiusButton = 12.0;
  static const double borderRadiusInput = 12.0;
  static const double borderRadiusCard = 12.0;
  static const double borderRadiusDropdown = 8.0;
  static const double borderRadiusChip = 12.0;

  // Button Heights
  static const double buttonHeightSmall = 36.0;
  static const double buttonHeightMedium = 44.0;
  static const double buttonHeightLarge = 48.0;

  // Button Padding
  static const double buttonPaddingSmall = 16.0;
  static const double buttonPaddingMedium = 24.0;
  static const double buttonPaddingLarge = 44.0;

  // Input Padding
  static const double inputPaddingHorizontal = 20.0;
  static const double inputPaddingVertical = 24.0;

  // Container Padding
  static const double containerPaddingHorizontal = 16.0;

  // Border Width
  static const double borderWidthDefault = 2.0;
  static const double borderWidthCard = 1.0;

  // Elevation
  static const double elevationButton = 3.0;
  static const double elevationDropdown = 2.0;
  static const double elevationChipSelected = 4.0;

  // Card Max Width
  static const double cardMaxWidth = 770.0;

  // Chip Spacing
  static const double chipSpacing = 8.0;

  // Loading Indicator
  static const double loadingIndicatorSize = 50.0;

  // Animation
  static const Duration animationDuration = Duration(milliseconds: 100);
}

// Box Shadow para cards
BoxShadow cardShadow = BoxShadow(
  color: const Color(0x33000000),
  blurRadius: 3,
  offset: const Offset(0, 1),
);
```

---

## 7. Tokens CSS (Para web o React Native)

```css
:root {
  /* Colores principales */
  --color-primary: #0F77FF;
  --color-secondary: #27C880;
  --color-tertiary: #FFB560;

  /* Fondos - Light Mode */
  --color-background-primary-light: #F1F4F8;
  --color-background-secondary-light: #FFFFFF;
  --color-alternate-light: #E0E3E7;

  /* Fondos - Dark Mode */
  --color-background-primary-dark: #16191D;
  --color-background-secondary-dark: #1A1D21;
  --color-alternate-dark: #24282E;

  /* Texto - Light Mode */
  --color-text-primary-light: #1A1D21;
  --color-text-secondary-light: #57636C;

  /* Texto - Dark Mode */
  --color-text-primary-dark: #FFFFFF;
  --color-text-secondary-dark: #A9ADC6;

  /* Estados */
  --color-success: #03CE9F;
  --color-warning: #F9A33F;
  --color-error: #FF4D6A;
  --color-info: #FFFFFF;

  /* Acentos con transparencia */
  --color-accent1: rgba(15, 119, 255, 0.3);
  --color-accent2: rgba(39, 200, 128, 0.3);
  --color-accent3: rgba(255, 181, 96, 0.3);

  /* Sombra */
  --shadow-card: 0 1px 3px rgba(0, 0, 0, 0.2);

  /* Border Radius */
  --radius-button: 12px;
  --radius-input: 12px;
  --radius-card: 12px;
  --radius-dropdown: 8px;
  --radius-chip: 12px;

  /* Tipografía */
  --font-primary: 'Figtree', sans-serif;
  --font-secondary: 'Plus Jakarta Sans', sans-serif;

  /* Tamaños de fuente */
  --font-size-display-large: 48px;
  --font-size-display-medium: 36px;
  --font-size-display-small: 32px;
  --font-size-headline-large: 32px;
  --font-size-headline-medium: 24px;
  --font-size-headline-small: 22px;
  --font-size-title-large: 18px;
  --font-size-title-medium: 18px;
  --font-size-title-small: 16px;
  --font-size-body-large: 16px;
  --font-size-body-medium: 14px;
  --font-size-body-small: 12px;
  --font-size-label-large: 16px;
  --font-size-label-medium: 14px;
  --font-size-label-small: 12px;

  /* Alturas de botón */
  --button-height-small: 36px;
  --button-height-medium: 44px;
  --button-height-large: 48px;

  /* Padding */
  --padding-button-small: 16px;
  --padding-button-medium: 24px;
  --padding-button-large: 44px;
  --padding-input-h: 20px;
  --padding-input-v: 24px;
  --padding-container: 16px;

  /* Bordes */
  --border-width: 2px;
  --border-width-card: 1px;
}
```

---

## 8. Resumen Visual

```
┌─────────────────────────────────────────────────────────────┐
│                    FF Expandable Menu                        │
│                      Design System                           │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  COLORES PRINCIPALES                                         │
│  ┌──────┐  ┌──────┐  ┌──────┐                              │
│  │ 0F77 │  │ 27C8 │  │ FFB5 │                              │
│  │  FF  │  │  80  │  │  60  │                              │
│  └──────┘  └──────┘  └──────┘                              │
│  Primary   Secondary  Tertiary                               │
│                                                              │
│  FUENTES                                                     │
│  ╔════════════════╗  ╔═══════════════════════╗             │
│  ║    Figtree     ║  ║  Plus Jakarta Sans    ║             │
│  ║   (Títulos)    ║  ║      (Body)           ║             │
│  ╚════════════════╝  ╚═══════════════════════╝             │
│                                                              │
│  BORDER RADIUS: 12px (general) | 8px (dropdown)             │
│                                                              │
│  BOTONES                                                     │
│  ┌─────────────────┐  Small:  36px                          │
│  │    Primary      │  Medium: 44px                          │
│  └─────────────────┘  Large:  48px                          │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

*Documento generado automáticamente desde los YAMLs de FlutterFlow*
