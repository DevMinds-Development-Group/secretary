import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../colors.dart';
import '../models/member_model.dart';
import '../routes/page_route_builder.dart';
import '../services/geocoding_service.dart';
import '../theme/design_constants.dart';
import '../utils/window_size.dart';
import '../widgets/body_width.dart';
import '../widgets/button.dart';
import '../widgets/nav_shell.dart';
import 'create/create_member.dart';

const Color _kWhatsAppGreen = Color(0xFF25D366);

class MemberProfileScreen extends StatefulWidget {
  final Member member;

  const MemberProfileScreen({Key? key, required this.member}) : super(key: key);

  @override
  State<MemberProfileScreen> createState() => _MemberProfileScreenState();
}

class _MemberProfileScreenState extends State<MemberProfileScreen> {
  static const List<String> _meses = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
  ];

  static const LatLng _lasTunas = LatLng(20.9600, -76.9544);

  final MapController _mapController = MapController();

  LatLng? _coords;
  bool _isApprox = false;
  double _zoom = 15;
  bool _geocoding = true;

  @override
  void initState() {
    super.initState();
    _resolveLocation();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _resolveLocation() async {
    final address = widget.member.address.trim();
    final coords =
        address.isEmpty ? null : await GeocodingService.geocode(address);
    if (!mounted) return;
    setState(() {
      if (coords != null) {
        _coords = coords;
        _isApprox = false;
        _zoom = 15;
      } else {
        _coords = _lasTunas;
        _isApprox = true;
        _zoom = 13;
      }
      _geocoding = false;
    });
  }

  // ---------------------------------------------------------------------------
  // Lanzadores externos (url_launcher)
  // ---------------------------------------------------------------------------
  Future<void> _launchUri(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el enlace')),
      );
    }
  }

  void _callPhone() {
    if (widget.member.phone.replaceAll(RegExp(r'\D'), '').isEmpty) return;
    _launchUri(Uri(scheme: 'tel', path: widget.member.phone));
  }

  void _openWhatsApp() {
    final digits = widget.member.phone.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return;
    _launchUri(Uri.parse('https://wa.me/53$digits'));
  }

  void _openInMaps() {
    final query =
        Uri.encodeComponent('${widget.member.address}, Las Tunas, Cuba');
    _launchUri(
      Uri.parse('https://www.google.com/maps/search/?api=1&query=$query'),
    );
  }

  void _openEdit() {
    Navigator.push(
      context,
      createFadeRoute(CreateMember(memberToEdit: widget.member)),
    );
  }

  void _zoomBy(double delta) {
    final z = (_mapController.camera.zoom + delta).clamp(3.0, 19.0);
    _mapController.move(_mapController.camera.center, z);
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = context.isCompact;

    final left = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildIdentityCard(),
        const SizedBox(height: Spacing.lg),
        _buildBirthdayPill(),
      ],
    );

    final right = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildPhoneCard(isCompact),
        const SizedBox(height: Spacing.lg),
        _buildMapCard(),
      ],
    );

    return NavShell(
      isSecondary: true,
      title: 'Perfil de Miembro',
      body: Stack(
        children: [
          Positioned.fill(child: _buildBackground()),
          Positioned.fill(
            child: SingleChildScrollView(
              child: BodyWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: Spacing.lg),
                    _buildIdRow(),
                    const SizedBox(height: Spacing.lg),
                    if (isCompact)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          left,
                          const SizedBox(height: Spacing.lg),
                          right,
                        ],
                      )
                    else
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 5, child: left),
                          const SizedBox(width: Spacing.xl),
                          Expanded(flex: 7, child: right),
                        ],
                      ),
                    const SizedBox(height: Spacing.xxxl),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Fondo fluido (estático)
  // ---------------------------------------------------------------------------
  Widget _buildBackground() {
    return Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFEFF4FB), Color(0xFFF3F4F6)],
              ),
            ),
          ),
        ),
        _buildBlob(
          alignment: const Alignment(-1.1, -1.2),
          size: 460,
          color: const Color(0xFFC2DCFC),
        ),
        _buildBlob(
          alignment: const Alignment(1.3, 1.3),
          size: 560,
          color: const Color(0xFFE1E6EE),
        ),
      ],
    );
  }

  Widget _buildBlob({
    required Alignment alignment,
    required double size,
    required Color color,
  }) {
    return Align(
      alignment: alignment,
      child: IgnorePointer(
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(color: color.withOpacity(0.55)),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Decoración glass
  // ---------------------------------------------------------------------------
  BoxDecoration _glass(BorderRadius radius) {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.85),
      borderRadius: radius,
      border: Border.all(color: Colors.white.withOpacity(0.6)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 40,
          spreadRadius: -10,
          offset: const Offset(0, 20),
        ),
      ],
    );
  }

  Widget _buildIdRow() {
    final id = widget.member.id;
    final shortId = id.length > 8 ? id.substring(0, 8) : id;
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        'ID MIEMBRO: #${shortId.toUpperCase()}',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: tertiaryTextColor,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tarjeta de identidad
  // ---------------------------------------------------------------------------
  Widget _buildIdentityCard() {
    final member = widget.member;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.xl,
        vertical: Spacing.xxl,
      ),
      decoration: _glass(
        const BorderRadius.only(
          topLeft: Radius.circular(56),
          topRight: Radius.circular(24),
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(88),
        ),
      ),
      child: Column(
        children: [
          _buildAvatar(),
          const SizedBox(height: Spacing.lg),
          Text(
            member.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: primaryText,
              height: 1.05,
            ),
          ),
          if (member.lastName.isNotEmpty) ...[
            const SizedBox(height: Spacing.xs),
            Text(
              member.lastName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: secondaryText,
              ),
            ),
          ],
          const SizedBox(height: Spacing.lg),
          _buildNetworkPill(),
          const SizedBox(height: Spacing.xl),
          Button(
            text: 'Actualizar Información',
            icon: Icons.refresh_rounded,
            onPressed: _openEdit,
            size: const Size(double.infinity, 54),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkPill() {
    final hasNetwork = widget.member.networkName != null &&
        widget.member.networkName!.isNotEmpty;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(hasNetwork ? Icons.star_rounded : Icons.person_off_outlined,
              size: 18, color: primaryColor),
          const SizedBox(width: 8),
          Text(
            hasNetwork ? widget.member.networkName! : 'Sin red',
            style: const TextStyle(
              color: primaryColor,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    const double size = 160;
    final url = widget.member.photoUrl;

    final Widget inner = (url != null && url.isNotEmpty)
        ? Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: elevationLow,
              image: DecorationImage(
                image: CachedNetworkImageProvider(url),
                fit: BoxFit.cover,
              ),
            ),
          )
        : Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: primaryText,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: elevationLow,
            ),
            alignment: Alignment.center,
            child: Text(
              _initials(widget.member),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 46,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          );

    return SizedBox(
      width: size + 24,
      height: size + 16,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              width: size * 0.95,
              height: size * 0.95,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.25),
                shape: BoxShape.circle,
              ),
            ),
          ),
          inner,
          Positioned(
            right: 6,
            bottom: 4,
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              elevation: 3,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _openEdit,
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.edit_rounded, size: 18, color: primaryColor),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _initials(Member m) {
    final a = m.name.trim().isNotEmpty ? m.name.trim()[0] : '';
    final b = m.lastName.trim().isNotEmpty ? m.lastName.trim()[0] : '';
    final result = '$a$b'.toUpperCase();
    return result.isNotEmpty ? result : '?';
  }

  // ---------------------------------------------------------------------------
  // Pastilla de fecha de nacimiento
  // ---------------------------------------------------------------------------
  Widget _buildBirthdayPill() {
    final d = widget.member.birthdate;
    final formatted = '${d.day} de ${_meses[d.month - 1]}, ${d.year}';
    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: _glass(BorderRadius.circular(999)),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
              color: warningContainer,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.card_giftcard_rounded,
                color: onWarningContainer, size: 26),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('FECHA DE NACIMIENTO', style: _kicker()),
                const SizedBox(height: 2),
                Text(
                  formatted,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: primaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tarjeta de teléfono / WhatsApp
  // ---------------------------------------------------------------------------
  Widget _buildPhoneCard(bool isCompact) {
    final hasPhone = widget.member.phone.trim().isNotEmpty;

    final info = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: elevationLow,
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.phone_in_talk_rounded,
              color: primaryText, size: 30),
        ),
        const SizedBox(width: Spacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('TELÉFONO DE CONTACTO', style: _kicker()),
              const SizedBox(height: Spacing.xs),
              InkWell(
                onTap: hasPhone ? _callPhone : null,
                child: Text(
                  hasPhone ? widget.member.phone : 'Sin teléfono',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: primaryText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final waButton =
        _WhatsAppButton(onPressed: _openWhatsApp, fullWidth: isCompact);

    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: Container(
        decoration: _glass(BorderRadius.circular(40)),
        child: Stack(
          children: [
            Positioned(
              right: -30,
              bottom: -30,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  color: _kWhatsAppGreen.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Spacing.xl),
              child: isCompact
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        info,
                        if (hasPhone) ...[
                          const SizedBox(height: Spacing.lg),
                          waButton,
                        ],
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(child: info),
                        if (hasPhone) ...[
                          const SizedBox(width: Spacing.lg),
                          waButton,
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tarjeta de mapa + dirección
  // ---------------------------------------------------------------------------
  Widget _buildMapCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: Container(
        height: 450,
        decoration: _glass(BorderRadius.circular(40)),
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(Spacing.sm),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: _buildMapArea(),
                ),
              ),
            ),
            Positioned(
              top: Spacing.xl,
              left: Spacing.xl,
              child: _buildAddressOverlay(),
            ),
            if (!_geocoding)
              Positioned(
                right: Spacing.lg,
                bottom: Spacing.lg,
                child: _buildZoomControls(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapArea() {
    final coords = _coords;
    if (_geocoding || coords == null) {
      return Container(
        color: surfaceSubtle,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      );
    }

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: coords,
        initialZoom: _zoom,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate:
              'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
          subdomains: const ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'com.vientorecio.koinos',
          retinaMode: RetinaMode.isHighDensity(context),
        ),
        if (!_isApprox)
          MarkerLayer(
            markers: [
              Marker(
                point: coords,
                width: 44,
                height: 44,
                child: _buildMapMarker(),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildMapMarker() {
    return Container(
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: primaryColor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: elevationLow,
        ),
      ),
    );
  }

  Widget _buildZoomControls() {
    Widget btn(IconData icon, VoidCallback onTap) => Material(
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 2,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onTap,
            child: SizedBox(
              width: 40,
              height: 40,
              child: Icon(icon, color: primaryText, size: 22),
            ),
          ),
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        btn(Icons.add, () => _zoomBy(1)),
        const SizedBox(height: Spacing.sm),
        btn(Icons.remove, () => _zoomBy(-1)),
      ],
    );
  }

  Widget _buildAddressOverlay() {
    final address = widget.member.address.trim();
    return Container(
      constraints: const BoxConstraints(maxWidth: 340),
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(24),
        boxShadow: elevationLow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.location_on_rounded, color: primaryColor, size: 24),
          ),
          const SizedBox(width: Spacing.sm),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('DIRECCIÓN REGISTRADA', style: _kicker()),
                const SizedBox(height: Spacing.xs),
                Text(
                  address.isNotEmpty ? address : 'Sin dirección registrada',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: primaryText,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                InkWell(
                  onTap: _openInMaps,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.navigation_rounded,
                          size: 16, color: primaryColor),
                      SizedBox(width: 4),
                      Text(
                        'Las Tunas, Cuba',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _kicker() => TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
        color: secondaryText.withOpacity(0.7),
      );
}

/// Botón "Contactar" (WhatsApp): verde de marca, icono real de WhatsApp y un
/// pulso continuo (única animación que se conserva en la pantalla). Respeta
/// `MediaQuery.disableAnimations` (sin pulso cuando el usuario reduce el movimiento).
class _WhatsAppButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool fullWidth;

  const _WhatsAppButton({required this.onPressed, this.fullWidth = false});

  @override
  State<_WhatsAppButton> createState() => _WhatsAppButtonState();
}

class _WhatsAppButtonState extends State<_WhatsAppButton>
    with SingleTickerProviderStateMixin {
  AnimationController? _pulse;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (reduceMotion) {
      _pulse?.stop();
    } else if (_pulse == null) {
      _pulse = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 2),
      )..repeat();
    }
  }

  @override
  void dispose() {
    _pulse?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton.icon(
      onPressed: widget.onPressed,
      icon: const FaIcon(FontAwesomeIcons.whatsapp,
          size: 20, color: Colors.white),
      label: const Text('Contactar'),
      style: ElevatedButton.styleFrom(
        backgroundColor: _kWhatsAppGreen,
        foregroundColor: Colors.white,
        elevation: 3,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        minimumSize: widget.fullWidth
            ? const Size(double.infinity, 50)
            : const Size(0, 50),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );

    final controller = _pulse;
    if (controller == null) return button;

    return AnimatedBuilder(
      animation: controller,
      builder: (_, child) {
        final t = controller.value;
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: _kWhatsAppGreen.withOpacity(0.7 * (1 - t)),
                spreadRadius: 14 * t,
                blurRadius: 0,
              ),
            ],
          ),
          child: child,
        );
      },
      child: button,
    );
  }
}
