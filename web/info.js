// Keep language resolution aligned with lib/app_strings.dart.
(() => {
  const parts = navigator.language.replaceAll('_', '-').toLowerCase().split('-');
  const language = parts[0] === 'ja' ? 'ja'
    : parts[0] === 'zh'
      ? parts.includes('hant') ? 'zh-TW'
        : parts.includes('hans') ? 'zh-CN'
          : parts.some(part => ['tw', 'hk', 'mo'].includes(part)) ? 'zh-TW' : 'zh-CN'
      : 'en';
  const labels = {
    en: { home: 'Open Timcker', privacy: 'Privacy Policy', support: 'Support', navigation: 'Site navigation' },
    'zh-TW': { home: '開啟 Timcker', privacy: '隱私權政策', support: '支援', navigation: '網站導覽' },
    'zh-CN': { home: '打开 Timcker', privacy: '隐私政策', support: '支持', navigation: '网站导航' },
    ja: { home: 'Timcker を開く', privacy: 'プライバシーポリシー', support: 'サポート', navigation: 'サイトナビゲーション' },
  }[language];

  document.documentElement.lang = language;
  for (const article of document.querySelectorAll('article[lang]')) {
    article.hidden = article.lang !== language;
  }
  for (const link of document.querySelectorAll('[data-label]')) {
    link.textContent = labels[link.dataset.label];
  }
  document.querySelector('nav').setAttribute('aria-label', labels.navigation);
  const article = document.querySelector('article:not([hidden])');
  document.title = `${article.querySelector('h1').textContent} | Timcker`;
  document.querySelector('meta[name="description"]').content = article.querySelector('p').textContent;
})();
