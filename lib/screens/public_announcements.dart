import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../colors.dart';
import '../models/announcement_model.dart';
import '../providers/announcement_provider.dart';
import '../widgets/custom_card_container.dart';
import '../widgets/states/app_skeleton.dart';
import '../widgets/states/empty_state.dart';

class PublicAnnouncements extends StatefulWidget {
  const PublicAnnouncements({super.key});

  @override
  State<PublicAnnouncements> createState() => _PublicAnnouncementsState();
}

class _PublicAnnouncementsState extends State<PublicAnnouncements> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnnouncementProvider>(
        context,
        listen: false,
      ).fetchAnnouncements();
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 700;
    final provider = context.watch<AnnouncementProvider>();

    return Scaffold(
      backgroundColor: backgroundColor,
      body: RefreshIndicator(
        onRefresh: () => provider.fetchAnnouncements(),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: infoColor),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: IconButton(
                    tooltip: 'Iniciar Sesión',
                    icon: const Icon(
                      Icons.login_rounded,
                      color: infoColor,
                      size: 28,
                    ),
                    onPressed: () {
                      // Navega a la pantalla de login (ajusta la ruta si es diferente)
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        'login',
                        (route) => false,
                      );
                    },
                  ),
                ),
              ],
              //expandedHeight: 100.0,
              floating: false,
              pinned: true,
              elevation: 20,
              forceElevated: true,
              shadowColor: shadowColor,
              backgroundColor: cardColor,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: EdgeInsets.only(bottom: isMobile ? 16 : 10),
                centerTitle: true,
                title: Text(
                  "Anuncios",
                  style: TextStyle(
                    color: cardColor,
                    fontWeight: isMobile ? FontWeight.bold : FontWeight.w500,
                    fontSize: 30,
                    fontFamily: 'Figtree',

                    shadows: [
                      Shadow(blurRadius: isMobile ? 20 : 30, color: darkColor),
                    ],
                  ),
                ),
                background: Image.asset('assets/03.png', fit: BoxFit.cover),
              ),
            ),

            if (provider.isLoading)
              const SliverFillRemaining(
                child: AppSkeleton.list(),
              )
            else if (provider.announcements.isEmpty)
              const SliverFillRemaining(
                child: EmptyState(
                  icon: Icons.campaign_outlined,
                  title: 'No hay anuncios disponibles',
                ),
              )
            else
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 20 : 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (provider.todayEvent != null) ...[
                        _buildSectionTitle(
                          "Evento de Hoy",
                          Icons.today_outlined,
                          isMobile,
                        ),
                        const SizedBox(height: 16),
                        _buildTodayEvent(provider.todayEvent!, isMobile),
                        const SizedBox(height: 32),
                      ],

                      _buildSectionTitle(
                        "Tiempos de la semana",
                        Icons.calendar_month_rounded,
                        isMobile,
                      ),
                      SizedBox(height: isMobile ? 0 : 16),

                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: provider.announcements.length,
                        itemBuilder: (context, index) {
                          final event = provider.announcements[index];
                          return _buildModernServiceCard(event);
                        },
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        height: 60,
        margin: EdgeInsets.symmetric(horizontal: 24),
        child: ElevatedButton.icon(
          onPressed: () {
            _showLocationDialog(context, isMobile);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: darkColor,
            foregroundColor: cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 10,
            shadowColor: darkColor.withOpacity(0.5),
          ),
          icon: const Icon(Icons.location_on_rounded),
          label: const Text(
            "¿CÓMO LLEGAR?",
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, isMobile) {
    return Row(
      children: [
        Icon(icon, color: secondaryText, size: 26),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: isMobile ? 18 : 16,
            fontWeight: FontWeight.w900,
            color: secondaryText,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTodayEvent(Announcement event, isMobile) {
    return CustomCardContainer(
      gradient: LinearGradient(
        colors: [event.color, event.color.withOpacity(0.8)],
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 18 : 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.name,
              style: const TextStyle(
                color: infoColor,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                fontFamily: 'Figtree',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              event.description,
              style: const TextStyle(color: infoColor, fontSize: 18),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(
                  Icons.access_time_filled,
                  color: infoColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  event.formattedTime,
                  style: const TextStyle(
                    color: infoColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            if (event.preachers.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.person, color: infoColor, size: 24),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      "Predica: ${event.preachers.join(', ')}",
                      style: const TextStyle(color: infoColor, fontSize: 18),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            if (event.worshipMinistry.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.person, color: infoColor, size: 24),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      "Ministra: ${event.worshipMinistry.join(', ')}",
                      style: const TextStyle(color: infoColor, fontSize: 18),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildModernServiceCard(Announcement event) {
    return CustomCardContainer(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 75,
            decoration: BoxDecoration(
              color: event.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  event.dayName,
                  style: TextStyle(
                    color: event.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  event.dayNumber,
                  style: TextStyle(
                    color: event.color,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: darkColor,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule,
                      size: 16,
                      color: secondaryText,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      event.formattedTime,
                      style: const TextStyle(
                        color: secondaryText,
                        fontSize: 15,
                      ),
                    ),
                    if (event.preachers.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.menu_book_rounded,
                        size: 16,
                        color: secondaryText,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          event.preachers.first,
                          style: const TextStyle(
                            color: secondaryText,
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    if (event.worshipMinistry.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.music_note_outlined,
                        size: 16,
                        color: secondaryText,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          event.worshipMinistry.first,
                          style: const TextStyle(
                            color: secondaryText,
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: alternateColor,
          ),
        ],
      ),
    );
  }

  void _showLocationDialog(BuildContext context, isMobile) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: secondaryBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.asset(
                  'assets/location.png',
                  width:
                      MediaQuery.of(context).size.width *
                      (isMobile ? 0.95 : 0.3),
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: errorColor,
                    child: const Icon(
                      Icons.map_outlined,
                      size: 80,
                      color: infoColor,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Nuestra Ubicación",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Figtree',
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Calle Eddy Martínez #34 entre \n Ave.Camilo Cienfuegos y J.Espinosa \nReparto Buena Vista.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: primaryText, fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: 130,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: darkColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: const Text(
                          "ENTENDIDO",
                          style: TextStyle(color: infoColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
