import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

/// WebView screen that shows local Turkish financial tips.
/// Loads a self-contained HTML string — works offline, never fails.
class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen>
    with AutomaticKeepAliveClientMixin {
  late final WebViewController _controller;
  int _loadingProgress = 0;

  @override
  bool get wantKeepAlive => true; // Keep the page alive when switching tabs.

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFF5F5F5))
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (p) {
          if (mounted) setState(() => _loadingProgress = p);
        },
        onPageFinished: (_) {
          if (mounted) setState(() => _loadingProgress = 100);
        },
      ))
      ..loadHtmlString(_tipsHtml);
  }

  // ─── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Text(AppStrings.financialTips),
        elevation: 0,
        bottom: _loadingProgress < 100
            ? PreferredSize(
                preferredSize: const Size.fromHeight(3),
                child: LinearProgressIndicator(
                  value: _loadingProgress / 100,
                  backgroundColor: Colors.white30,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : null,
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}

// ─── HTML Content ─────────────────────────────────────────────────────────────

const String _tipsHtml = '''<!DOCTYPE html>
<html lang="tr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
  <title>Finansal İpuçları</title>
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
      background: #F0F0F8;
      padding: 16px;
      color: #212121;
    }
    .header {
      background: linear-gradient(135deg, #6C63FF, #4B44CC);
      color: white;
      border-radius: 18px;
      padding: 28px 20px 24px;
      margin-bottom: 20px;
      text-align: center;
    }
    .header .emoji { font-size: 40px; display: block; margin-bottom: 10px; }
    .header h1 { font-size: 22px; font-weight: 700; margin-bottom: 6px; }
    .header p  { font-size: 13px; opacity: 0.85; line-height: 1.5; }
    .card {
      background: #FFFFFF;
      border-radius: 16px;
      padding: 18px 16px;
      margin-bottom: 14px;
      box-shadow: 0 2px 10px rgba(0,0,0,0.07);
    }
    .card-header {
      display: flex;
      align-items: center;
      margin-bottom: 10px;
    }
    .card-emoji { font-size: 26px; margin-right: 12px; flex-shrink: 0; }
    .card h2 { font-size: 15px; font-weight: 700; color: #212121; }
    .card p  { font-size: 13.5px; color: #555; line-height: 1.65; }
    .tip {
      background: #F3F1FF;
      border-left: 4px solid #6C63FF;
      border-radius: 0 10px 10px 0;
      padding: 10px 14px;
      margin-top: 10px;
      font-size: 12.5px;
      color: #4B44CC;
      line-height: 1.55;
    }
    .badge {
      display: inline-block;
      background: #6C63FF;
      color: white;
      font-size: 11px;
      font-weight: 700;
      padding: 2px 8px;
      border-radius: 99px;
      margin-bottom: 8px;
    }
    .footer {
      text-align: center;
      color: #AAAAAA;
      font-size: 12px;
      margin-top: 24px;
      padding-bottom: 24px;
    }
    .footer strong { color: #6C63FF; }
  </style>
</head>
<body>

  <div class="header">
    <span class="emoji">💡</span>
    <h1>Finansal İpuçları</h1>
    <p>Daha sağlıklı bir finansal gelecek için<br>pratik ve uygulanabilir öneriler</p>
  </div>

  <div class="card">
    <div class="card-header">
      <span class="card-emoji">💰</span>
      <h2>50 / 30 / 20 Kuralı</h2>
    </div>
    <p>Aylık gelirinizin <strong>%50</strong>'sini zorunlu giderlere (kira, fatura, market), <strong>%30</strong>'unu kişisel harcamalara ve <strong>%20</strong>'sini tasarruf &amp; yatırıma ayırın.</p>
    <div class="tip">💡 Bu kural, bütçenizi üç basit kategoriye bölerek dengelemenin en yaygın yöntemidir.</div>
  </div>

  <div class="card">
    <span class="badge">Öncelikli</span>
    <div class="card-header">
      <span class="card-emoji">🏦</span>
      <h2>Acil Fon Oluşturun</h2>
    </div>
    <p>Beklenmedik durumlara (işten çıkma, sağlık, arıza) karşı en az <strong>3–6 aylık</strong> yaşam masrafınızı karşılayacak bir acil fon biriktirin.</p>
    <div class="tip">💡 Her ay gelirinizin %10'unu ayrı bir tasarruf hesabına aktarın. Küçük adımlar zamanla büyük fon olur.</div>
  </div>

  <div class="card">
    <div class="card-header">
      <span class="card-emoji">📊</span>
      <h2>Harcamalarınızı Takip Edin</h2>
    </div>
    <p>Her harcamayı kayıt altına alın. Nereye para gittiğini bilmeden tasarruf etmek zordur. <strong>SplitMate</strong> gibi uygulamalar grup harcamalarınızı şeffaf hale getirir.</p>
    <div class="tip">💡 Günde 5 dakika harcama takibi, yılda binlerce lira tasarruf sağlayabilir.</div>
  </div>

  <div class="card">
    <div class="card-header">
      <span class="card-emoji">💳</span>
      <h2>Borç Yönetimi</h2>
    </div>
    <p>Yüksek faizli borçları (kredi kartı, tüketici kredisi) önce kapatın. Minimum ödeme yerine borcun tamamını ödemeye çalışın.</p>
    <div class="tip">💡 Çığ yöntemi: En yüksek faizli borçtan başlayarak kapatın; en düşük bakiyeli borçtan başlamak da motivasyon sağlar (kartopu yöntemi).</div>
  </div>

  <div class="card">
    <div class="card-header">
      <span class="card-emoji">📈</span>
      <h2>Erken Yatırım Yapın</h2>
    </div>
    <p>Bileşik faizin gücünden yararlanmak için mümkün olan en erken yaşta yatırıma başlayın. Her ay küçük miktarlar bile uzun vadede büyük fark yaratır.</p>
    <div class="tip">💡 25 yaşında aylık 1.000₺ yatırım, ortalama %10 yıllık getiriyle 65 yaşında yaklaşık 6.4 milyon ₺ olabilir.</div>
  </div>

  <div class="card">
    <div class="card-header">
      <span class="card-emoji">🎯</span>
      <h2>Finansal Hedef Belirleyin</h2>
    </div>
    <p>Kısa (1 yıl), orta (5 yıl) ve uzun vadeli (10+ yıl) finansal hedefler belirleyin. Hedeflerinizi yazılı hale getirin ve ilerlemenizi düzenli olarak ölçün.</p>
    <div class="tip">💡 SMART hedef: Spesifik, Ölçülebilir, Ulaşılabilir, Gerçekçi, Zamanlı.</div>
  </div>

  <div class="card">
    <div class="card-header">
      <span class="card-emoji">🛒</span>
      <h2>Bilinçli Alışveriş</h2>
    </div>
    <p>Alışverişe çıkmadan önce liste yapın ve listeden çıkmayın. Büyük alımlar için 24–48 saat bekleyin; anlık kararların çoğu pişmanlığa yol açar.</p>
    <div class="tip">💡 "Bu gerçekten ihtiyacım mı, yoksa istediğim mi?" sorusunu sormak tek başına büyük tasarruf sağlar.</div>
  </div>

  <div class="card">
    <div class="card-header">
      <span class="card-emoji">🤝</span>
      <h2>Grup Harcamalarını Adil Paylaşın</h2>
    </div>
    <p>Arkadaşlarla tatil, yemek veya ev paylaşımındaki harcamaları şeffaf tutun. Kim ne ödedi, kim ne borçlu — bunları net tutmak hem para hem de dostluğu korur.</p>
    <div class="tip">💡 SplitMate ile grup harcamalarınızı kayıt altına alın, kimin kime ne kadar ödeyeceğini otomatik hesaplayın.</div>
  </div>

  <div class="footer">
    <p>Hazırlayan: <strong>SplitMate</strong> &nbsp;•&nbsp; Finansal Özgürlüğe Giden Yol 🚀</p>
  </div>

</body>
</html>''';
