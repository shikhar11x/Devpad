import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/services/url_opener.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/cyber_confirm_dialog.dart';
import '../../../../core/widgets/devpad_button.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_state.dart';
import '../../../pads/presentation/providers/pad_providers.dart';
import '../../domain/entities/pad_file.dart';
import '../../domain/file_rules.dart';
import '../providers/file_actions.dart';
import '../providers/file_providers.dart';
import 'file_tile.dart';

/// The Files tab of a Pad: upload, list, open, copy link, delete.
class FilesSection extends ConsumerStatefulWidget {
  const FilesSection({super.key, required this.padId});

  final String padId;

  @override
  ConsumerState<FilesSection> createState() => _FilesSectionState();
}

class _FilesSectionState extends ConsumerState<FilesSection> {
  bool _uploading = false;
  bool _purged = false;

  void _say(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _upload() async {
    if (_uploading) return;
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: FileRules.extensions,
    );
    if (result.isEmpty || !mounted) return;

    final picked = result.first;
    final Uint8List bytes;
    try {
      bytes = await picked.readAsBytes();
    } catch (_) {
      if (mounted) _say('Could not read that file.');
      return;
    }

    setState(() => _uploading = true);
    try {
      await ref
          .read(fileActionsProvider)
          .upload(widget.padId, name: picked.name, bytes: bytes);
      if (mounted) _say('Uploaded ${picked.name}');
    } on AppFailure catch (f) {
      if (mounted) _say(f.message);
    } catch (_) {
      if (mounted) _say('Upload failed. Try again.');
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _open(PadFile file) async {
    final url = ref.read(fileRepositoryProvider).urlFor(file);
    if (!await openExternalUrl(url) && mounted) _say('Could not open the file.');
  }

  Future<void> _copy(PadFile file) async {
    final url = ref.read(fileRepositoryProvider).urlFor(file);
    await Clipboard.setData(ClipboardData(text: url));
    if (mounted) _say('Link copied');
  }

  Future<void> _delete(PadFile file) async {
    final confirmed = await showCyberConfirmDialog(
      context,
      title: 'Delete "${file.name}"?',
      message: '"${file.name}" will be permanently removed from vault storage.',
      confirmLabel: 'Delete File',
      icon: Icons.delete_outline_rounded,
    );
    if (confirmed != true || !mounted) return;
    try {
      await ref.read(fileActionsProvider).delete(file);
      if (mounted) _say('File deleted');
    } on AppFailure catch (f) {
      if (mounted) _say(f.message);
    } catch (_) {
      if (mounted) _say('Could not delete the file.');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(fileRepositoryProvider).isAvailable) {
      return const EmptyState(
        icon: Icons.cloud_off_outlined,
        title: 'Files storage is not set up',
        message: 'Run the app with --dart-define-from-file=env.json that '
            'contains your SUPABASE_URL and SUPABASE_ANON_KEY.',
      );
    }

    final async = ref.watch(filesProvider(widget.padId));
    return async.when(
      loading: () => const LoadingState(),
      error: (e, _) => ErrorState(
        message: padErrorMessage(e),
        onRetry: () => ref.invalidate(filesProvider(widget.padId)),
      ),
      data: _buildData,
    );
  }

  Widget _buildData(List<PadFile> all) {
    final edge = context.screenSize.isMobile ? 16.0 : 24.0;

    if (!_purged && all.any((f) => f.isExpired())) {
      _purged = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ref.read(fileActionsProvider).purgeExpired(all);
      });
    }

    final files = all.where((f) => !f.isExpired()).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final repo = ref.read(fileRepositoryProvider);

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(edge, 16, edge, 6),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.cyan.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.cyan.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.cloud_done_outlined, size: 13, color: AppColors.cyan),
                        const SizedBox(width: 6),
                        Text(
                          files.isEmpty ? 'VAULT // EMPTY' : 'VAULT // ${files.length} ASSETS',
                          style: AppTheme.mono.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                            color: AppColors.cyan,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  DevPadButton(
                    label: 'Upload File',
                    icon: const Icon(Icons.upload_file, size: 18),
                    expand: false,
                    isLoading: _uploading,
                    onPressed: _upload,
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(edge, 0, edge, 10),
              child: Text(
                '// Encrypted object storage · Max 5 MB · 7-day auto-purge policy',
                style: AppTheme.mono.copyWith(
                  fontSize: 11,
                  color: AppColors.textDim,
                ),
              ),
            ),
            Expanded(
              child: files.isEmpty
                  ? EmptyState(
                      icon: Icons.attach_file,
                      title: 'No files yet.',
                      message: 'Attach screenshots, diagrams and PDFs here.',
                      actionLabel: 'Upload your first file →',
                      onAction: _uploading ? null : _upload,
                    )
                  : ListView.separated(
                      padding: EdgeInsets.fromLTRB(edge, 8, edge, 24),
                      itemCount: files.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final file = files[i];
                        return FileTile(
                          file: file,
                          url: repo.urlFor(file),
                          onOpen: () => _open(file),
                          onCopy: () => _copy(file),
                          onDelete: () => _delete(file),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}