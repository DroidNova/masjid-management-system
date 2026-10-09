# App icon and launch screen

The mosque mark is drawn in code (`mosque.js`), so it stays sharp at every
size and can be recoloured. Nothing here is bundled into the app.

- `icon.png`: green square with a white mosque (iOS, old Android, website).
- `icon-foreground.png`: white mosque on transparent (Android adaptive icon;
  the background colour is `#00695C`).
- `splash.png`: green mosque on transparent (launch screen on white).

To change the picture:

1. Edit `mosque.js` (shapes) or `make.js` (sizes and colours).
2. Start Chrome with `--headless=new --remote-debugging-port=9222
   --allow-file-access-from-files`, then from a scratch folder run
   `node make.js . <path to masjid-core-frontend/web>` (it also writes the
   website icons and favicon) and copy the three PNGs back here.
3. Run `dart run flutter_launcher_icons` and
   `dart run flutter_native_splash:create` (settings are in `pubspec.yaml`).
4. The website loading screen in `web/index.html` holds the same mark as an
   inline SVG; paste the new `mosque.js` output there too.
