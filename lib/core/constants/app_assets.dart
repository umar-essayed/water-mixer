class AppAssets {
  // Asset Image Paths
  static const String homeBackground = 'assets/images/background.jpeg';
  static const String gameBackground = 'assets/images/background1.jpeg';
  static const String gameIcon = 'assets/images/game_icon.png';

  // 1. Sleek Modern Glass Test Tube Vector (Realistic Glass Texture - Classic)
  static const String tubeFrameSvg = '''
<svg width="100" height="280" viewBox="0 0 100 280" fill="none" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="glassWall" x1="0" y1="0" x2="100" y2="280" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="#FFFFFF" stop-opacity="0.30"/>
      <stop offset="30%" stop-color="#FFFFFF" stop-opacity="0.04"/>
      <stop offset="70%" stop-color="#38BDF8" stop-opacity="0.06"/>
      <stop offset="100%" stop-color="#FFFFFF" stop-opacity="0.22"/>
    </linearGradient>
    <linearGradient id="specularGleam" x1="18" y1="20" x2="28" y2="260" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="#FFFFFF" stop-opacity="0.75"/>
      <stop offset="60%" stop-color="#FFFFFF" stop-opacity="0.45"/>
      <stop offset="100%" stop-color="#FFFFFF" stop-opacity="0.10"/>
    </linearGradient>
    <linearGradient id="lipGleam" x1="0" y1="0" x2="100" y2="0" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="#FFFFFF" stop-opacity="0.80"/>
      <stop offset="50%" stop-color="#FFFFFF" stop-opacity="0.25"/>
      <stop offset="100%" stop-color="#FFFFFF" stop-opacity="0.70"/>
    </linearGradient>
  </defs>

  <!-- Glass Tube Body (U-shaped capsule with flat top and rounded bottom) -->
  <path d="M 12 18 L 12 232 C 12 258 30 274 50 274 C 70 274 88 258 88 232 L 88 18 Z"
        fill="url(#glassWall)" 
        stroke="rgba(255, 255, 255, 0.40)" 
        stroke-width="3.5"
        stroke-linejoin="round"/>

  <!-- Specular Reflection Highlight Line -->
  <path d="M 19 28 L 19 230 C 19 248 30 260 45 264" 
        stroke="url(#specularGleam)" 
        stroke-width="3.0" 
        stroke-linecap="round"/>

  <!-- Subtle Secondary Right Reflection -->
  <path d="M 81 32 L 81 220" 
        stroke="rgba(255, 255, 255, 0.22)" 
        stroke-width="1.8" 
        stroke-linecap="round"/>

  <!-- Sleek 3D Glass Mouth Rim -->
  <rect x="7" y="8" width="86" height="15" rx="7.5" 
        fill="url(#lipGleam)" 
        stroke="rgba(255, 255, 255, 0.70)" 
        stroke-width="2.5"/>
</svg>
''';

  // 1b. Neon Cyber Tube Skin
  static const String tubeFrameNeonSvg = '''
<svg width="100" height="280" viewBox="0 0 100 280" fill="none" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="neonWall" x1="0" y1="0" x2="100" y2="280" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="#06B6D4" stop-opacity="0.25"/>
      <stop offset="50%" stop-color="#8B5CF6" stop-opacity="0.10"/>
      <stop offset="100%" stop-color="#38BDF8" stop-opacity="0.30"/>
    </linearGradient>
    <linearGradient id="neonEdge" x1="0" y1="0" x2="100" y2="280" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="#22D3EE"/>
      <stop offset="50%" stop-color="#A855F7"/>
      <stop offset="100%" stop-color="#38BDF8"/>
    </linearGradient>
  </defs>
  <!-- Cyber Tube Body with Neon Outline -->
  <path d="M 12 18 L 12 232 C 12 258 30 274 50 274 C 70 274 88 258 88 232 L 88 18 Z"
        fill="url(#neonWall)" 
        stroke="url(#neonEdge)" 
        stroke-width="3.5"
        stroke-linejoin="round"/>
  <!-- Energy Pulse Streaks -->
  <path d="M 18 28 L 18 230" stroke="#67E8F9" stroke-width="2.5" stroke-linecap="round" stroke-opacity="0.8"/>
  <path d="M 82 28 L 82 230" stroke="#C084FC" stroke-width="2.0" stroke-linecap="round" stroke-opacity="0.8"/>
  <!-- Cyber Rim -->
  <rect x="7" y="8" width="86" height="15" rx="7.5" fill="#0F172A" stroke="#22D3EE" stroke-width="2.8"/>
  <circle cx="22" cy="15.5" r="3" fill="#22D3EE"/>
  <circle cx="78" cy="15.5" r="3" fill="#A855F7"/>
</svg>
''';

  // 1c. Royal Gold Tube Skin
  static const String tubeFrameGoldSvg = '''
<svg width="100" height="280" viewBox="0 0 100 280" fill="none" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="goldWall" x1="0" y1="0" x2="100" y2="280" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="#FDE68A" stop-opacity="0.30"/>
      <stop offset="50%" stop-color="#F59E0B" stop-opacity="0.08"/>
      <stop offset="100%" stop-color="#FDE68A" stop-opacity="0.25"/>
    </linearGradient>
    <linearGradient id="goldEdge" x1="0" y1="0" x2="0" y2="280" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="#FDE047"/>
      <stop offset="40%" stop-color="#F59E0B"/>
      <stop offset="80%" stop-color="#D97706"/>
      <stop offset="100%" stop-color="#FDE047"/>
    </linearGradient>
  </defs>
  <!-- Royal Gold Tube Body -->
  <path d="M 12 18 L 12 232 C 12 258 30 274 50 274 C 70 274 88 258 88 232 L 88 18 Z"
        fill="url(#goldWall)" 
        stroke="url(#goldEdge)" 
        stroke-width="4.0"
        stroke-linejoin="round"/>
  <!-- Golden Crown Bands -->
  <line x1="12" y1="60" x2="88" y2="60" stroke="#FDE047" stroke-width="1.8" stroke-dasharray="3 3"/>
  <line x1="12" y1="120" x2="88" y2="120" stroke="#FDE047" stroke-width="1.8" stroke-dasharray="3 3"/>
  <line x1="12" y1="180" x2="88" y2="180" stroke="#FDE047" stroke-width="1.8" stroke-dasharray="3 3"/>
  <!-- Specular Gold Reflection -->
  <path d="M 20 28 L 20 230" stroke="#FEF08A" stroke-width="2.5" stroke-linecap="round"/>
  <!-- Royal Lip Rim -->
  <rect x="7" y="8" width="86" height="15" rx="7.5" fill="#78350F" stroke="#FDE047" stroke-width="3"/>
</svg>
''';

  // 1d. Chemistry Lab Flask Skin with Metric Graduation Marks
  static const String tubeFrameFlaskSvg = '''
<svg width="100" height="280" viewBox="0 0 100 280" fill="none" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="flaskWall" x1="0" y1="0" x2="100" y2="280" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="#FFFFFF" stop-opacity="0.25"/>
      <stop offset="50%" stop-color="#38BDF8" stop-opacity="0.05"/>
      <stop offset="100%" stop-color="#FFFFFF" stop-opacity="0.20"/>
    </linearGradient>
  </defs>
  <!-- Lab Flask Body -->
  <path d="M 12 18 L 12 232 C 12 258 30 274 50 274 C 70 274 88 258 88 232 L 88 18 Z"
        fill="url(#flaskWall)" 
        stroke="rgba(255, 255, 255, 0.55)" 
        stroke-width="3.5"
        stroke-linejoin="round"/>
  <!-- Laboratory Metric Measurement Markings (10ml, 20ml, 30ml, 40ml) -->
  <line x1="72" y1="70" x2="84" y2="70" stroke="#38BDF8" stroke-width="2.5" stroke-linecap="round"/>
  <line x1="76" y1="95" x2="84" y2="95" stroke="rgba(255,255,255,0.7)" stroke-width="1.8" stroke-linecap="round"/>
  <line x1="72" y1="120" x2="84" y2="120" stroke="#38BDF8" stroke-width="2.5" stroke-linecap="round"/>
  <line x1="76" y1="145" x2="84" y2="145" stroke="rgba(255,255,255,0.7)" stroke-width="1.8" stroke-linecap="round"/>
  <line x1="72" y1="170" x2="84" y2="170" stroke="#38BDF8" stroke-width="2.5" stroke-linecap="round"/>
  <line x1="76" y1="195" x2="84" y2="195" stroke="rgba(255,255,255,0.7)" stroke-width="1.8" stroke-linecap="round"/>
  <line x1="72" y1="220" x2="84" y2="220" stroke="#38BDF8" stroke-width="2.5" stroke-linecap="round"/>
  <!-- Reflection -->
  <path d="M 19 28 L 19 230 C 19 248 30 260 45 264" stroke="rgba(255,255,255,0.6)" stroke-width="2.8" stroke-linecap="round"/>
  <!-- Lab Rim -->
  <rect x="7" y="8" width="86" height="15" rx="7.5" fill="rgba(56, 189, 248, 0.25)" stroke="#38BDF8" stroke-width="2.5"/>
</svg>
''';

  // 1e. Lava Plasma Tube Skin
  static const String tubeFrameLavaSvg = '''
<svg width="100" height="280" viewBox="0 0 100 280" fill="none" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="lavaWall" x1="0" y1="0" x2="100" y2="280" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="#FF4500" stop-opacity="0.35"/>
      <stop offset="50%" stop-color="#FF8C00" stop-opacity="0.08"/>
      <stop offset="100%" stop-color="#FF0055" stop-opacity="0.28"/>
    </linearGradient>
    <linearGradient id="lavaGleam" x1="18" y1="20" x2="28" y2="260" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="#FFA500" stop-opacity="0.95"/>
      <stop offset="70%" stop-color="#FF4500" stop-opacity="0.5"/>
      <stop offset="100%" stop-color="#FF1E00" stop-opacity="0.1"/>
    </linearGradient>
  </defs>
  <!-- Tube Body -->
  <path d="M 12 18 L 12 232 C 12 258 30 274 50 274 C 70 274 88 258 88 232 L 88 18 Z"
        fill="url(#lavaWall)" 
        stroke="#FF4500" 
        stroke-width="3.5"
        stroke-linejoin="round"/>
  <!-- Lava Core Reflection -->
  <path d="M 19 28 L 19 230 C 19 248 30 260 45 264" stroke="url(#lavaGleam)" stroke-width="3.0" stroke-linecap="round"/>
  <!-- Heat Energy Rings -->
  <path d="M 20 100 Q 50 112 80 100" stroke="#FF8C00" stroke-width="2.2" stroke-linecap="round" stroke-dasharray="4 6"/>
  <path d="M 20 180 Q 50 192 80 180" stroke="#FF4500" stroke-width="2.2" stroke-linecap="round" stroke-dasharray="4 6"/>
  <!-- Fiery Rim -->
  <rect x="7" y="8" width="86" height="15" rx="7.5" fill="#FF4500" stroke="#FFA500" stroke-width="2.5"/>
</svg>
''';

  // 1f. Diamond Crystal Prism Tube Skin
  static const String tubeFrameCrystalSvg = '''
<svg width="100" height="280" viewBox="0 0 100 280" fill="none" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="crystalWall" x1="0" y1="0" x2="100" y2="280" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="#C084FC" stop-opacity="0.35"/>
      <stop offset="40%" stop-color="#38BDF8" stop-opacity="0.12"/>
      <stop offset="100%" stop-color="#E879F9" stop-opacity="0.30"/>
    </linearGradient>
  </defs>
  <!-- Faceted Crystal Body -->
  <path d="M 12 18 L 12 232 C 12 258 30 274 50 274 C 70 274 88 258 88 232 L 88 18 Z"
        fill="url(#crystalWall)" 
        stroke="#A855F7" 
        stroke-width="3.5"
        stroke-linejoin="round"/>
  <!-- Prismatic Geometric Facet Lines -->
  <path d="M 12 70 L 50 90 L 88 70" stroke="rgba(232, 121, 249, 0.5)" stroke-width="1.8"/>
  <path d="M 12 140 L 50 160 L 88 140" stroke="rgba(56, 189, 248, 0.5)" stroke-width="1.8"/>
  <path d="M 12 210 L 50 230 L 88 210" stroke="rgba(232, 121, 249, 0.5)" stroke-width="1.8"/>
  <line x1="50" y1="18" x2="50" y2="265" stroke="rgba(255, 255, 255, 0.65)" stroke-width="2.5" stroke-linecap="round"/>
  <!-- Specular Sheen -->
  <path d="M 19 28 L 19 230" stroke="#FFFFFF" stroke-width="2.8" stroke-linecap="round"/>
  <!-- Crystal Crown Rim -->
  <rect x="7" y="8" width="86" height="15" rx="7.5" fill="#9333EA" stroke="#C084FC" stroke-width="2.5"/>
</svg>
''';

  /// Helper to return the active tube SVG string according to selected skin ID
  static String getTubeSvg(String skinId) {
    switch (skinId) {
      case 'neon':
        return tubeFrameNeonSvg;
      case 'gold':
        return tubeFrameGoldSvg;
      case 'flask':
        return tubeFrameFlaskSvg;
      case 'lava':
        return tubeFrameLavaSvg;
      case 'crystal':
        return tubeFrameCrystalSvg;
      case 'classic':
      default:
        return tubeFrameSvg;
    }
  }

  // 2. Modern Clean Minimalist Undo Arrow
  static const String undoSvg = '''
<svg width="48" height="48" viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M 20 16 L 12 24 L 20 32" stroke="#FFFFFF" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M 14 24 H 28 C 34.6 24 40 29.4 40 36" stroke="#FFFFFF" stroke-width="4" stroke-linecap="round"/>
</svg>
''';

  // 3. Modern Clean Add Tube Plus Sign
  static const String addTubeSvg = '''
<svg width="48" height="48" viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M 24 12 V 36" stroke="#FFFFFF" stroke-width="4" stroke-linecap="round"/>
  <path d="M 12 24 H 36" stroke="#FFFFFF" stroke-width="4" stroke-linecap="round"/>
</svg>
''';

  // 4. Modern Clean 360 Reset Arrow
  static const String resetSvg = '''
<svg width="48" height="48" viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M 38 18 C 35.5 12.8 30.2 9 24 9 C 15.7 9 9 15.7 9 24 C 9 32.3 15.7 39 24 39 C 31 39 36.8 34.2 38.5 27.8" 
        stroke="#FFFFFF" stroke-width="4" stroke-linecap="round"/>
  <polyline points="32 18 39 18 39 11" stroke="#FFFFFF" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
''';

  // 5. Modern Flat Coin Icon
  static const String coinSvg = '''
<svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
  <circle cx="16" cy="16" r="14" fill="#F59E0B" stroke="#FBBF24" stroke-width="2"/>
  <circle cx="16" cy="16" r="10" stroke="#FDE68A" stroke-width="1.5" stroke-dasharray="2 2"/>
  <path d="M 16 9 V 23 M 13 12 C 13 10.5 19 10.5 19 14 C 19 18 13 18 13 21 C 13 23 19 23 19 21" 
        stroke="#FFFFFF" stroke-width="2" stroke-linecap="round"/>
</svg>
''';

  // 6. Modern Padlock Icon (for Locked Tubes & Levels)
  static const String lockSvg = '''
<svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="7" y="14" width="18" height="14" rx="4" fill="#334155" stroke="#94A3B8" stroke-width="2"/>
  <path d="M 11 14 V 10 C 11 7.2 13.2 5 16 5 C 18.8 5 21 7.2 21 10 V 14" stroke="#94A3B8" stroke-width="2.5" stroke-linecap="round"/>
  <circle cx="16" cy="20" r="2" fill="#F8FAFC"/>
  <path d="M 16 22 V 24" stroke="#F8FAFC" stroke-width="2" stroke-linecap="round"/>
</svg>
''';

  // 7. Modern Geometric Star (Filled)
  static const String starFilledSvg = '''
<svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M 16 3 L 19.8 11.2 L 28.8 12.3 L 22.1 18.4 L 23.9 27.2 L 16 22.8 L 8.1 27.2 L 9.9 18.4 L 3.2 12.3 L 12.2 11.2 Z" 
        fill="#FBBF24" stroke="#F59E0B" stroke-width="1.8" stroke-linejoin="round"/>
</svg>
''';

  // 8. Modern Geometric Star (Empty Outline)
  static const String starEmptySvg = '''
<svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M 16 3 L 19.8 11.2 L 28.8 12.3 L 22.1 18.4 L 23.9 27.2 L 16 22.8 L 8.1 27.2 L 9.9 18.4 L 3.2 12.3 L 12.2 11.2 Z" 
        fill="rgba(255,255,255,0.08)" stroke="rgba(255,255,255,0.30)" stroke-width="1.8" stroke-linejoin="round"/>
</svg>
''';

  // 9. Modern Minimalist Settings Icon
  static const String settingsSvg = '''
<svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
  <circle cx="16" cy="16" r="4.5" stroke="#FFFFFF" stroke-width="2.5"/>
  <path d="M 16 3 V 6 M 16 26 V 29 M 3 16 H 6 M 26 16 H 29 M 6.8 6.8 L 8.9 8.9 M 23.1 23.1 L 25.2 25.2 M 6.8 25.2 L 8.9 23.1 M 23.1 8.9 L 25.2 6.8" 
        stroke="#FFFFFF" stroke-width="2.5" stroke-linecap="round"/>
</svg>
''';

  // 10. Modern Minimalist Shop Flask Icon
  static const String shopSvg = '''
<svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M 12 5 H 20 M 14 5 V 10 L 7 24 C 6 26 7.5 28 10 28 H 22 C 24.5 28 26 26 25 24 L 18 10 V 5" 
        stroke="#FFFFFF" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
  <line x1="9" y1="20" x2="23" y2="20" stroke="#38BDF8" stroke-width="2"/>
</svg>
''';

  // 11. Sleek Modern Game Logo Emblem (Crystal Prism Beaker)
  static const String dropletLogoSvg = '''
<svg width="120" height="150" viewBox="0 0 120 150" fill="none" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="prismGrad" x1="20" y1="20" x2="100" y2="140" gradientUnits="userSpaceOnUse">
      <stop offset="0%" stop-color="#38BDF8"/>
      <stop offset="50%" stop-color="#818CF8"/>
      <stop offset="100%" stop-color="#F43F5E"/>
    </linearGradient>
  </defs>
  <!-- Sleek Hexagonal Crystal Prism Emblem -->
  <polygon points="60,10 105,35 105,115 60,140 15,115 15,35" 
           fill="url(#prismGrad)" 
           fill-opacity="0.25" 
           stroke="rgba(255,255,255,0.7)" 
           stroke-width="3"/>
  <polygon points="60,25 93,44 93,106 60,125 27,106 27,44" 
           stroke="url(#prismGrad)" 
           stroke-width="2.5"/>
  <line x1="60" y1="25" x2="60" y2="125" stroke="rgba(255,255,255,0.5)" stroke-width="2"/>
  <line x1="27" y1="44" x2="93" y2="106" stroke="rgba(255,255,255,0.3)" stroke-width="1.5"/>
  <line x1="27" y1="106" x2="93" y2="44" stroke="rgba(255,255,255,0.3)" stroke-width="1.5"/>
</svg>
''';

  // 12. Clean Modern Hint Lightbulb
  static const String hintSvg = '''
<svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M 16 5 C 11 5 7 9 7 14 C 7 17.5 9.5 20.5 12.5 22 V 24 H 19.5 V 22 C 22.5 20.5 25 17.5 25 14 C 25 9 21 5 16 5 Z" 
        stroke="#FFFFFF" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M 12.5 27 H 19.5" stroke="#FFFFFF" stroke-width="2.5" stroke-linecap="round"/>
</svg>
''';
}
