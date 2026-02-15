import 'package:flutter/material.dart';
import 'package:ice_shield/orchestration_layer/ReactiveBlock/Project/ProjectBlock.dart';
import 'package:provider/provider.dart';
import 'package:signals_flutter/signals_flutter.dart';

class ProjectSelectionDialog extends StatelessWidget {
  const ProjectSelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final projectBlock = context.read<ProjectBlock>();

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: colorScheme.outlineVariant.withOpacity(0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 28, 16, 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.folder_copy_rounded,
                      color: colorScheme.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Select Project',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: colorScheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Content
            Flexible(
              child: Watch((context) {
                final projects = projectBlock.projects.value
                    .where((p) => p.status == 0)
                    .toList();

                if (projects.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(48.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.folder_off_rounded,
                          size: 64,
                          color: colorScheme.onSurface.withOpacity(0.1),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'No Active Projects',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create a project first to associate notes.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurface.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 8,
                  ),
                  itemCount: projects.length + 1,
                  itemBuilder: (context, index) {
                    if (index == projects.length) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          tileColor: colorScheme.surfaceVariant.withOpacity(
                            0.3,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: colorScheme.outline.withOpacity(
                              0.1,
                            ),
                            child: Icon(
                              Icons.note_add_rounded,
                              color: colorScheme.onSurface.withOpacity(0.6),
                              size: 18,
                            ),
                          ),
                          title: const Text(
                            'General Note',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: const Text('Not linked to any project'),
                          onTap: () => Navigator.pop(context, -1),
                        ),
                      );
                    }

                    final project = projects[index];
                    final projectColor = project.color != null
                        ? Color(int.parse(project.color!))
                        : colorScheme.primary;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: projectColor.withOpacity(0.1),
                          ),
                        ),
                        tileColor: projectColor.withOpacity(0.05),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: projectColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.folder_rounded,
                            color: projectColor,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          project.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        subtitle:
                            project.description != null &&
                                project.description!.isNotEmpty
                            ? Text(
                                project.description!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurface.withOpacity(0.6),
                                ),
                              )
                            : null,
                        trailing: Icon(
                          Icons.chevron_right_rounded,
                          color: projectColor.withOpacity(0.3),
                        ),
                        onTap: () => Navigator.pop(context, project.projectID),
                      ),
                    );
                  },
                );
              }),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
