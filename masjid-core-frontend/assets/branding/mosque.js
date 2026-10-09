// The mosque mark, drawn in a 1024 box. `color` fills it; the crescent
// and door are cut out, so it works on any background.
module.exports = (color, scale = 1) => {
  const t = `translate(512 512) scale(${scale}) translate(-512 -540)`;
  return `
  <defs><mask id="cut">
    <rect width="1024" height="1024" fill="white"/>
    <circle cx="526" cy="226" r="24" fill="black"/>
    <path d="M482 772 V690 a30 30 0 0 1 60 0 V772 Z" fill="black"/>
  </mask></defs>
  <g transform="${t}" mask="url(#cut)" fill="${color}">
    <circle cx="512" cy="236" r="30"/>
    <rect x="506" y="262" width="12" height="80" rx="6"/>
    <path d="M352 580 C352 440 440 372 512 336 C584 372 672 440 672 580 Z"/>
    <rect x="312" y="572" width="400" height="200" rx="10"/>
    <path d="M222 772 V452 L252 372 L282 452 V772 Z"/>
    <path d="M742 772 V452 L772 372 L802 452 V772 Z"/>
  </g>`;
};
