import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../colors.dart';
import '../../models/service_model.dart';
import '../../providers/service_provider.dart';
import '../../routes/page_route_builder.dart';
import '../../services/auth_service.dart';
import '../../theme/design_constants.dart';
import '../../utils/user_permissions.dart';
import '../../utils/window_size.dart';
import '../../widgets/add_button.dart';
import '../../widgets/body_width.dart';
import '../../widgets/event_feed_item.dart';
import '../../widgets/nav_destinations.dart';
import '../../widgets/nav_shell.dart';
import '../../widgets/showDeleteConfirmationDialog.dart';
import '../../widgets/states/app_skeleton.dart';
import '../../widgets/states/empty_state.dart';
import '../../widgets/states/error_state.dart';
import '../create/create_service.dart';

class Services extends StatefulWidget {
  const Services({super.key});

  @override
  State<Services> createState() => _ServicesState();
}

class _ServicesState extends State<Services> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ServiceProvider>(context, listen: false).fetchServices();
    });
  }

  bool _isToday(ServiceModel s) {
    final now = DateTime.now();
    if (s.recurring) {
      return int.tryParse(s.weekDay.toString()) == now.weekday;
    }
    return s.date.year == now.year &&
        s.date.month == now.month &&
        s.date.day == now.day;
  }

  String _dayName(ServiceModel s) {
    const days = {
      1: 'Lunes',
      2: 'Martes',
      3: 'Miércoles',
      4: 'Jueves',
      5: 'Viernes',
      6: 'Sábado',
      7: 'Domingo',
    };
    if (s.recurring) {
      return days[int.tryParse(s.weekDay.toString())] ?? s.weekDay.toString();
    }
    return days[s.date.weekday] ?? '';
  }

  String _time12h(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  List<String> _names(List<dynamic> members) =>
      members.map((m) => '${m.name} ${m.lastName}'.trim()).toList();

  Future<void> _openEdit(ServiceModel service) async {
    await Navigator.push(
      context,
      createFadeRoute(CreateService(serviceToEdit: service)),
    );
    if (mounted) context.read<ServiceProvider>().fetchServices();
  }

  void _confirmDelete(ServiceModel service, ServiceProvider provider) {
    showDeleteConfirmationDialog(
      context: context,
      itemName: service.title,
      onConfirm: () => provider.deleteService(service.id),
    );
  }

  Future<void> _openCreate() async {
    await Navigator.push(context, createFadeRoute(const CreateService()));
    if (mounted) context.read<ServiceProvider>().fetchServices();
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = context.isCompact;
    final canManage = UserPermissions(context.read<AuthService>()).canSeeMembers;

    return NavShell(
      current: NavSection.services,
      title: 'Servicios',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: Spacing.xl),
          BodyWidth(child: _buildHeader(isCompact, canManage)),
          const SizedBox(height: Spacing.lg),
          Expanded(
            child: BodyWidth(child: _buildListState(canManage)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isCompact, bool canManage) {
    final textTheme = Theme.of(context).textTheme;
    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Servicios', style: textTheme.headlineMedium),
        const SizedBox(height: Spacing.xxs),
        Text(
          'Servicios y eventos de la semana.',
          style: textTheme.bodyMedium?.copyWith(color: secondaryText),
        ),
      ],
    );

    if (!canManage) return heading;

    final add = AddButton(
      size: isCompact ? const Size(double.infinity, 48) : null,
      onPressed: _openCreate,
    );

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [heading, const SizedBox(height: Spacing.lg), add],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: heading),
        const SizedBox(width: Spacing.lg),
        add,
      ],
    );
  }

  Widget _buildListState(bool canManage) {
    final provider = context.watch<ServiceProvider>();
    final services = provider.services;

    if (provider.isLoading) {
      return const AppSkeleton.list();
    }
    if (provider.error != null) {
      return ErrorState(
        error: provider.error,
        onRetry: () => provider.fetchServices(),
      );
    }
    if (services.isEmpty) {
      return const EmptyState(
        icon: Icons.calendar_today_outlined,
        title: 'No hay servicios programados',
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchServices(),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: services.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final service = services[i];
          final showPreachers =
              service.type != 'REUNION' && service.type != 'OTRO';
          return EventFeedItem(
            title: service.title,
            type: service.type,
            description: service.description,
            scheduleLabel: '${_dayName(service)} · ${_time12h(service.time)}',
            preacherNames: showPreachers ? _names(service.preachers) : const [],
            worshipNames: _names(service.worshipMinistries),
            isToday: _isToday(service),
            onEdit: canManage ? () => _openEdit(service) : null,
            onDelete:
                canManage ? () => _confirmDelete(service, provider) : null,
          );
        },
      ),
    );
  }
}
