import 'package:flutter/material.dart';
import 'package:masjid_core_frontend/shared/ui/responsive.dart';
import 'package:masjid_core_frontend/shared/ui/tokens.dart';
import 'package:masjid_core_frontend/shared/ui/tone_icon.dart';

/// A big square tile: picture on top, one or two words below. Home and
/// other "what do you want to do?" screens are grids of these.
class ActionTile extends StatelessWidget {
  const ActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.tone,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String label;
  final AppTone tone;
  final VoidCallback onTap;

  /// A small count in the corner (for example, unread news).
  final int? badge;

  @override
  Widget build(BuildContext context) {
    final count = badge;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Card(
        child: InkWell(
          onTap: onTap,
          hoverColor: tone.container.withValues(alpha: 0.5),
          child: Stack(
            // Fill the tile so the picture and label sit in its centre.
            fit: StackFit.expand,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(AppSpace.m),
                child: LayoutBuilder(
                  // Small tiles (narrow phones, large text) get a smaller
                  // picture so a two-line label still fits.
                  builder: (context, constraints) => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ToneIcon(
                        icon: icon,
                        tone: tone,
                        size: (constraints.maxHeight * 0.42).clamp(36, 64),
                      ),
                      const SizedBox(height: AppSpace.s),
                      Flexible(
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (count != null && count > 0)
                PositionedDirectional(
                  top: AppSpace.m,
                  end: AppSpace.m,
                  child: Badge.count(
                    count: count,
                    backgroundColor: AppTones.danger.color,
                    largeSize: 24,
                    textStyle: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lays out [ActionTile]s in 2, 3, or 4 columns depending on screen width.
class ActionTileGrid extends StatelessWidget {
  const ActionTileGrid({super.key, required this.tiles});

  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = ScreenSize.fromWidth(constraints.maxWidth);
        final columns = size.tileColumns;
        // Square on phones, wider on big screens so tiles do not tower.
        final shape = switch (size) {
          ScreenSize.compact => 1.0,
          ScreenSize.medium => 1.25,
          ScreenSize.expanded => 1.5,
        };
        // Taller tiles when the text is enlarged, so labels never clip.
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        return GridView.count(
          crossAxisCount: columns,
          mainAxisSpacing: AppSpace.m,
          crossAxisSpacing: AppSpace.m,
          childAspectRatio: (shape / textScale).clamp(0.6, shape),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: tiles,
        );
      },
    );
  }
}
