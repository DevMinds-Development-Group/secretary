import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../colors.dart';
import '../models/member_model.dart';
import '../providers/member_provider.dart';
import '../theme/design_constants.dart';
import '../utils/app_log.dart';
import 'custom_text_form_field.dart';
import 'member_profile_image.dart';

class MemberAutocompleteField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final Function(Member?) onMemberSelected;

  const MemberAutocompleteField({
    Key? key,
    required this.controller,
    required this.labelText,
    required this.onMemberSelected,
  }) : super(key: key);

  @override
  State<MemberAutocompleteField> createState() =>
      _MemberAutocompleteFieldState();
}

class _MemberAutocompleteFieldState extends State<MemberAutocompleteField> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final memberProvider = context.watch<MemberProvider>();
        final List<Member> allMembers = memberProvider.allMembers;

        return Consumer<MemberProvider>(
          builder: (context, memberProvider, child) {
            appLog(
              "Autocomplete '${widget.labelText}' - Miembros cargados: ${allMembers.length}",
            );

            return Autocomplete<Member>(
              displayStringForOption: (Member option) =>
                  '${option.name} ${option.lastName}'.trim(),

              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty || allMembers.isEmpty) {
                  return const Iterable<Member>.empty();
                }
                return allMembers.where((Member member) {
                  final fullName = '${member.name} ${member.lastName}'
                      .toLowerCase();
                  return fullName.contains(textEditingValue.text.toLowerCase());
                });
              },

              onSelected: (Member selection) {
                final String fullName =
                    '${selection.name} ${selection.lastName}'.trim();
                widget.controller.text = fullName;
                widget.onMemberSelected(selection);
              },

              // DENTRO de MemberAutocompleteField -> fieldViewBuilder
              fieldViewBuilder:
                  (context, fieldController, focusNode, onFieldSubmitted) {
                    // Sincronización inmediata: Si el controlador externo cambia (desde el padre),
                    // actualizamos el interno del Autocomplete.
                    if (widget.controller.text != fieldController.text) {
                      Future.microtask(() {
                        if (mounted)
                          fieldController.text = widget.controller.text;
                      });
                    }

                    return CustomTextFormField(
                      labelText: widget.labelText,
                      controller: fieldController,
                      focusNode: focusNode,
                      onChanged: (text) {
                        // Actualizamos el controlador del padre para que no se pierda el dato
                        widget.controller.text = text;
                        if (text.isEmpty) {
                          widget.onMemberSelected(null);
                        }
                      },
                    );
                  },

              optionsViewBuilder: (context, onSelected, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4.0,
                    borderRadius: BorderRadius.circular(
                      DesignConstants.borderRadiusDropdown,
                    ),
                    color: Theme.of(context).colorScheme.surface,
                    child: Container(
                      width: constraints.maxWidth,
                      constraints: const BoxConstraints(maxHeight: 250),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (BuildContext context, int index) {
                          final Member option = options.elementAt(index);
                          return ListTile(
                            leading: MemberProfileImage(
                              imageUrl: option.photoUrl,
                              name: option.name,
                              radius: 16,
                              squared: true,
                              borderColor: primaryColor,
                              borderWidth: 1.5,
                            ),
                            title: Text(
                              '${option.name} ${option.lastName}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            subtitle: Text(
                              option.phone,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                            onTap: () => onSelected(option),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
