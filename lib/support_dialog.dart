import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_strings.dart';

final supportUrl = Uri.parse('https://timcker.chivincent.net/support');
final privacyUrl = Uri.parse('https://timcker.chivincent.net/privacy');

typedef OpenUrl = Future<bool> Function(Uri url);

Future<bool> openExternalUrl(Uri url) =>
    launchUrl(url, mode: LaunchMode.externalApplication);

class SupportButton extends StatelessWidget {
  const SupportButton({
    super.key,
    required this.useCupertino,
    this.openUrl = openExternalUrl,
  });

  final bool useCupertino;
  final OpenUrl openUrl;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    void showSupport() {
      Widget dialog(BuildContext context) =>
          _SupportDialog(useCupertino: useCupertino, openUrl: openUrl);
      if (useCupertino) {
        showCupertinoDialog<void>(context: context, builder: dialog);
      } else {
        showDialog<void>(context: context, builder: dialog);
      }
    }

    if (useCupertino) {
      return CupertinoButton(
        key: const ValueKey('support-button'),
        minimumSize: const Size(48, 48),
        padding: EdgeInsets.zero,
        onPressed: showSupport,
        child: Icon(
          CupertinoIcons.question_circle,
          semanticLabel: strings.supportAndPrivacy,
        ),
      );
    }
    return IconButton(
      key: const ValueKey('support-button'),
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      tooltip: strings.supportAndPrivacy,
      onPressed: showSupport,
      icon: Icon(Icons.help_outline, semanticLabel: strings.supportAndPrivacy),
    );
  }
}

class _SupportDialog extends StatefulWidget {
  const _SupportDialog({required this.useCupertino, required this.openUrl});

  final bool useCupertino;
  final OpenUrl openUrl;

  @override
  State<_SupportDialog> createState() => _SupportDialogState();
}

class _SupportDialogState extends State<_SupportDialog> {
  bool _opening = false;
  bool _failed = false;

  Future<void> _open(Uri url) async {
    setState(() {
      _opening = true;
      _failed = false;
    });
    var opened = false;
    try {
      opened = await widget.openUrl(url);
    } catch (_) {
      opened = false;
    }
    if (!mounted) return;
    setState(() {
      _opening = false;
      _failed = !opened;
    });
  }

  Widget _link(String label, Uri url) {
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(url.toString(), style: const TextStyle(fontSize: 13)),
      ],
    );
    return Semantics(
      link: true,
      child: widget.useCupertino
          ? CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 12),
              onPressed: _opening ? null : () => _open(url),
              child: text,
            )
          : TextButton(
              onPressed: _opening ? null : () => _open(url),
              child: text,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final links = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _link(strings.support, supportUrl),
        const SizedBox(height: 8),
        _link(strings.privacyPolicy, privacyUrl),
        if (_failed) ...[
          const SizedBox(height: 12),
          Semantics(liveRegion: true, child: Text(strings.urlOpenFailed)),
        ],
      ],
    );
    if (widget.useCupertino) {
      return CupertinoAlertDialog(
        title: Text(strings.supportAndPrivacy),
        content: Padding(padding: const EdgeInsets.only(top: 12), child: links),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(),
            child: Text(strings.close),
          ),
        ],
      );
    }
    return AlertDialog(
      title: Text(strings.supportAndPrivacy),
      scrollable: true,
      content: links,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(strings.close),
        ),
      ],
    );
  }
}
