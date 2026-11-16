// Floating "Chat with us" button that opens the Spoony Facebook Messenger chat.
// Mounted once in MaterialApp.builder so it floats over every visitor page;
// hidden on staff/auth screens.
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'wm_ui.dart';

const _kMessengerUrl = 'https://m.me/CebuSpoony';
const _kMessengerBlue = Color(0xFF0084FF);

/// Routes where the button should not appear.
const _hiddenOn = {'/admin', '/driver', '/login'};

/// Tracks the current route name so the button can hide itself on staff pages.
final ValueNotifier<String?> currentRouteName = ValueNotifier<String?>('/');

class RouteNameObserver extends NavigatorObserver {
  void _set(Route<dynamic>? r) {
    if (r is PageRoute) currentRouteName.value = r.settings.name;
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) => _set(route);
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) => _set(previousRoute);
  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) => _set(newRoute);
}

class MessengerFab extends StatefulWidget {
  /// Hide on the root route too (used while the login screen owns '/').
  final bool hideOnRoot;
  const MessengerFab({super.key, this.hideOnRoot = false});

  @override
  State<MessengerFab> createState() => _MessengerFabState();
}

class _MessengerFabState extends State<MessengerFab> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.of(context).size.width < 700;
    return ValueListenableBuilder<String?>(
      valueListenable: currentRouteName,
      builder: (context, route, _) {
        final hidden = _hiddenOn.contains(route) || (widget.hideOnRoot && (route == '/' || route == null));
        if (hidden) return const SizedBox.shrink();
        return Positioned(
          right: mobile ? 16 : 28,
          bottom: mobile ? 16 : 28,
          child: Material(
            type: MaterialType.transparency,
            child: Semantics(
            button: true,
            label: 'Chat with us on Messenger',
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (_) => setState(() => _hover = true),
              onExit: (_) => setState(() => _hover = false),
              child: GestureDetector(
                onTap: () => launchUrl(Uri.parse(_kMessengerUrl), mode: LaunchMode.externalApplication),
                child: AnimatedContainer(
                  duration: Wm.fast,
                  padding: EdgeInsets.symmetric(horizontal: mobile ? 14 : 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: _kMessengerBlue,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: _kMessengerBlue.withValues(alpha: _hover ? 0.45 : 0.30),
                        blurRadius: _hover ? 22 : 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 22),
                    if (!mobile) ...[
                      const SizedBox(width: 8),
                      const Text('Chat with us',
                          style: TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w700)),
                    ],
                  ]),
                ),
              ),
            ),
          ),
          ),
        );
      },
    );
  }
}
