import 'package:clickup_fading_scroll/clickup_fading_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_svg/flutter_html_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:url_launcher/url_launcher_string.dart';

final _markdownHtmlPod = Provider.family<String, String>((ref, source) {
  return md.markdownToHtml(
    source,
    extensionSet: md.ExtensionSet.gitHubWeb,
  );
});

class MarkdownViewer extends ConsumerWidget {
  const MarkdownViewer({super.key, required this.markdown});

  final String markdown;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final html = ref.read(_markdownHtmlPod(markdown));
    return Html(
      data: html,
      onLinkTap: (url, context, attributes) {
        if (url != null) {
          launchUrlString(url);
        }
      },
    );
  }
}
