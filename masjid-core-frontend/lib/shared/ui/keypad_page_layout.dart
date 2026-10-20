import 'package:flutter/material.dart';
import 'package:masjid_core_frontend/shared/ui/responsive.dart';
import 'package:masjid_core_frontend/shared/ui/screen_header.dart';
import 'package:masjid_core_frontend/shared/ui/tokens.dart';

/// The layout of a keypad screen (phone number, track request): the
/// content fills the screen and scrolls only when it must, and [action]
/// (Continue, Check) is pinned at the bottom, so it is never below the
/// fold or behind the system buttons. Put it inside a SafeArea.
///
/// [content] gets `compact: true` when the space is short (see
/// [isShortForKeypad]); pass it to [ScreenHeader] and the keypad.
class KeypadPageLayout extends StatelessWidget {
  const KeypadPageLayout({
    super.key,
    required this.content,
    required this.action,
  });

  final List<Widget> Function(bool compact) content;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: PageBody.form(
                padding: const EdgeInsets.fromLTRB(
                  AppSpace.l,
                  AppSpace.s,
                  AppSpace.l,
                  AppSpace.s,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: content(isShortForKeypad(constraints.maxHeight)),
                ),
              ),
            ),
          ),
        ),
        PageBody.form(
          padding: const EdgeInsets.fromLTRB(
            AppSpace.l,
            AppSpace.s,
            AppSpace.l,
            AppSpace.l,
          ),
          // Full width, like the rest of the app's main buttons.
          child: SizedBox(width: double.infinity, child: action),
        ),
      ],
    );
  }
}
