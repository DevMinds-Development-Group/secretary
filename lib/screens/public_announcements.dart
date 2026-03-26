import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../colors.dart';
import '../models/announcement_model.dart';
import '../providers/announcement_provider.dart';
import '../widgets/custom_card_container.dart';

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
    final provider = context.watch<AnnouncementProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: () => provider.fetchAnnouncements(),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              expandedHeight: 100.0,
              floating: false,
              pinned: true,
              elevation: 20,
              forceElevated: true,
              shadowColor: Colors.black.withOpacity(0.8),
              backgroundColor: primaryColor2,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: const Text(
                  "Anuncios",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontSize: 28,
                    shadows: [Shadow(offset: Offset(2, 2), blurRadius: 5)],
                  ),
                ),
                background: Image.asset('assets/03.png', fit: BoxFit.cover),
              ),
            ),

            if (provider.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (provider.announcements.isEmpty)
              const SliverFillRemaining(
                child: Center(child: Text("No hay anuncios disponibles.")),
              )
            else
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (provider.todayEvent != null) ...[
                        _buildSectionTitle(
                          "Evento de Hoy",
                          Icons.today_outlined,
                        ),
                        const SizedBox(height: 16),
                        _buildTodayEvent(provider.todayEvent!),
                        const SizedBox(height: 32),
                      ],

                      _buildSectionTitle(
                        "Tiempos de la semana",
                        Icons.calendar_month_rounded,
                      ),
                      const SizedBox(height: 16),

                      // Lista dinámica de servicios del backend
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
        margin: const EdgeInsets.symmetric(horizontal: 24),
        child: ElevatedButton.icon(
          onPressed: () {
            _showLocationDialog(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: darkBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 10,
            shadowColor: darkBlue.withOpacity(0.5),
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

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF64748B), size: 26),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Color(0xFF64748B),
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTodayEvent(Announcement event) {
    return CustomCardContainer(
      gradient: LinearGradient(
        colors: [event.color, event.color.withOpacity(0.8)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              event.description,
              style: const TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(
                  Icons.access_time_filled,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  event.formattedTime,
                  style: const TextStyle(
                    color: Colors.white,
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
                  const Icon(Icons.person, color: Colors.white, size: 24),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      "Predica: ${event.preachers.join(', ')}",
                      style: const TextStyle(color: Colors.white, fontSize: 18),
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
                  const Icon(Icons.person, color: Colors.white, size: 24),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      "Ministra: ${event.worshipMinistry.join(', ')}",
                      style: const TextStyle(color: Colors.white, fontSize: 18),
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
              borderRadius: BorderRadius.circular(18),
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
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule,
                      size: 16,
                      color: Colors.blueGrey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      event.formattedTime,
                      style: const TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 15,
                      ),
                    ),
                    if (event.preachers.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.menu_book_rounded,
                        size: 16,
                        color: Colors.blueGrey,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          event.preachers.first,
                          style: const TextStyle(
                            color: Colors.blueGrey,
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
                        color: Colors.blueGrey,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          event.worshipMinistry.first,
                          style: const TextStyle(
                            color: Colors.blueGrey,
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
            color: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }

  void _showLocationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                child: Image.asset(
                  'assets/location.png',
                  width: MediaQuery.of(context).size.width * 0.3,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: const Color(0xFFD32F2F),
                    child: const Icon(
                      Icons.map_outlined,
                      size: 80,
                      color: Colors.white,
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
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Calle Eddy Martínez #34 entre \n Ave.Camilo Cienfuegos y J.Espinosa \nReparto Buena Vista.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.blueGrey, fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: 130,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F172A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: const Text(
                          "ENTENDIDO",
                          style: TextStyle(color: Colors.white),
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
