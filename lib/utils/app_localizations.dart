// lib/utils/app_localizations.dart
// Simple key-value localization. No farming/agri keys remain.
// Add new keys to _en first, then mirror in _sw, _rw, _am, _fr.

class L10n {
  final Map<String, String> _s;
  const L10n._(this._s);

  factory L10n.of(String langCode) => L10n._(_locales[langCode] ?? _en);

  String t(String key) => _s[key] ?? _en[key] ?? key;

  // ── Getters ───────────────────────────────────────────────────────────────
  String get getStarted       => t('get_started');
  String get cont             => t('continue');
  String get skip             => t('skip');
  String get chooseLanguage   => t('choose_language');
  String get chooseLanguageSub=> t('choose_language_sub');
  String get setLocation      => t('set_location');
  String get setLocationSub   => t('set_location_sub');
  String get howUseAbss       => t('how_use_abss');
  String get onlineMode       => t('online_mode');
  String get onlineModeDesc   => t('online_mode_desc');
  String get offlineMode      => t('offline_mode');
  String get offlineModeDesc  => t('offline_mode_desc');
  String get onlineBenefits   => t('online_benefits');
  String get offlineBenefits  => t('offline_benefits');
  String get yourPhoneNumber  => t('your_phone_number');
  String get registerSms      => t('register_sms');
  String get yourName         => t('your_name');
  String get goodMorning      => t('good_morning');
  String get goodAfternoon    => t('good_afternoon');
  String get goodEvening      => t('good_evening');
  String get activeAlerts     => t('active_alerts');
  String get earlyAlerts      => t('early_alerts');
  String get offlineForecasts => t('offline_forecasts');
  String get multiLanguage    => t('multi_language');   // replaces farming_advice
  String get welcomeSubtitle  => t('welcome_subtitle');
  String get step1            => t('step1');
  String get step2            => t('step2');
  String get step3            => t('step3');
  String get step4            => t('step4');
  String get completeReg      => t('complete_reg');
  String get dailyCheckin     => t('daily_checkin');
  String get almostThere      => t('almost_there');
  String get startUsing       => t('start_using');
  String get detectLocation   => t('detect_location');
  String get chooseCity       => t('choose_city');
  String get alertTypes       => t('alert_types');
  String get refreshNeeded    => t('refresh_needed');
  String get refreshNow       => t('refresh_now');
  String get verifyNumber     => t('verify_number');
  String get verifying        => t('verifying');
  String get verifiedMsg      => t('verified_msg');
  String get verifyRequired   => t('verify_required');
  String get smsAlertNote     => t('sms_alert_note');

  // ── ENGLISH ───────────────────────────────────────────────────────────────
  static const _en = <String, String>{
    'get_started':        'Get Started',
    'continue':           'Continue',
    'skip':               'Skip',
    'choose_language':    'Choose your language',
    'choose_language_sub':'Select the language you\'re most comfortable with.',
    'set_location':       'Set your location',
    'set_location_sub':   'We use this to give you local alerts and forecasts.',
    'how_use_abss':       'How will you use ABSS?',
    'online_mode':        'Connected Mode',
    'online_mode_desc':   'Live alerts and forecasts. The app refreshes every 2–4 hours.',
    'offline_mode':       'SMS / Offline Mode',
    'offline_mode_desc':  'Critical alerts via SMS. No internet needed. Daily check-in required.',
    'online_benefits':    '• Forecast refreshed every 2–4 hours automatically\n• Push notifications for critical alerts\n• Full app experience on all screens',
    'offline_benefits':   '• SMS alerts delivered to any phone — no data needed\n• Alerts cached for 7 days offline\n• Must connect once per day to stay current',
    'your_phone_number':  'Your mobile number',
    'register_sms':       'Register for SMS Alerts',
    'your_name':          'Your name (optional)',
    'good_morning':       'Good morning',
    'good_afternoon':     'Good afternoon',
    'good_evening':       'Good evening',
    'active_alerts':      'Active Alerts',
    'early_alerts':       'Early disaster alerts via SMS & push',
    'offline_forecasts':  'Offline-first weather forecasts',
    'multi_language':     'Available in 5 languages',
    'welcome_subtitle':   'Know before the storm hits. Stay safe wherever you are.',
    'step1':              'Step 1 of 4',
    'step2':              'Step 2 of 4',
    'step3':              'Step 3 of 4',
    'step4':              'Step 4 of 4',
    'complete_reg':       'Registration complete',
    'daily_checkin':      'As an offline user you must open the app while connected at least once per day to refresh alerts and forecasts.',
    'almost_there':       'Almost there!',
    'start_using':        'Start using ABSS',
    'detect_location':    'Detect my location',
    'choose_city':        'Or choose your city',
    'alert_types':        'Alert types',
    'refresh_needed':     'Daily sync required — connect to refresh your data.',
    'refresh_now':        'Refresh now',
    'verify_number':      'Send verification code',
    'verifying':          'Sending code...',
    'verified_msg':       'Number verified! You\'re all set.',
    'verify_required':    'Verify your number to continue',
    'sms_alert_note':     'You will receive SMS alerts for critical hazards',
  };

  // ── KISWAHILI ─────────────────────────────────────────────────────────────
  static const _sw = <String, String>{
    'get_started':        'Anza',
    'continue':           'Endelea',
    'skip':               'Ruka',
    'choose_language':    'Chagua lugha yako',
    'choose_language_sub':'Chagua lugha unayoipenda zaidi.',
    'set_location':       'Weka eneo lako',
    'set_location_sub':   'Tunatumia hii kukupa arifa na utabiri wa hali ya hewa.',
    'how_use_abss':       'Utatumia ABSS vipi?',
    'online_mode':        'Hali ya Mtandaoni',
    'online_mode_desc':   'Arifa na utabiri wa ziada. Programu inasasishwa kila masaa 2–4.',
    'offline_mode':       'Hali ya SMS / Bila Mtandao',
    'offline_mode_desc':  'Arifa muhimu kupitia SMS. Inafanya kazi bila intaneti. Ukaguzi wa kila siku unahitajika.',
    'online_benefits':    '• Utabiri unasasishwa kila masaa 2–4 kiotomatiki\n• Arifa za push kwa matukio muhimu\n• Uzoefu kamili wa programu kwenye kila skrini',
    'offline_benefits':   '• Arifa za SMS kwa simu yoyote — bila data\n• Arifa zimehifadhiwa kwa siku 7 bila mtandao\n• Lazima uungane mara moja kwa siku',
    'your_phone_number':  'Nambari yako ya simu',
    'register_sms':       'Jiandikishe kwa Arifa za SMS',
    'your_name':          'Jina lako (hiari)',
    'good_morning':       'Habari ya asubuhi',
    'good_afternoon':     'Habari ya mchana',
    'good_evening':       'Habari ya jioni',
    'active_alerts':      'Arifa Zinazoendelea',
    'early_alerts':       'Arifa za mapema za majanga kupitia SMS',
    'offline_forecasts':  'Utabiri wa hali ya hewa bila mtandao',
    'multi_language':     'Inapatikana kwa lugha 5',
    'welcome_subtitle':   'Jua kabla ya dhoruba kufika. Kaa salama popote ulipo.',
    'step1':              'Hatua 1 ya 4',
    'step2':              'Hatua 2 ya 4',
    'step3':              'Hatua 3 ya 4',
    'step4':              'Hatua 4 ya 4',
    'complete_reg':       'Usajili umekamilika',
    'daily_checkin':      'Kama mtumiaji wa nje ya mtandao, lazima ufungue programu ukiwa umeunganishwa mara moja kwa siku.',
    'almost_there':       'Karibu mwisho!',
    'start_using':        'Anza kutumia ABSS',
    'detect_location':    'Gundua eneo langu',
    'choose_city':        'Au chagua jiji lako',
    'alert_types':        'Aina za arifa',
    'refresh_needed':     'Usasishaji wa kila siku unahitajika — unganika kusasisha data yako.',
    'refresh_now':        'Sasisha sasa',
    'verify_number':      'Tuma nambari ya uthibitisho',
    'verifying':          'Inatuma nambari...',
    'verified_msg':       'Nambari imethibitishwa! Uko tayari.',
    'verify_required':    'Thibitisha nambari yako ili uendelee',
    'sms_alert_note':     'Utapokea arifa za SMS kwa hatari muhimu',
  };

  // ── KINYARWANDA ───────────────────────────────────────────────────────────
  static const _rw = <String, String>{
    'get_started':        'Tangira',
    'continue':           'Komeza',
    'skip':               'Simbuka',
    'choose_language':    'Hitamo ururimi rwawe',
    'choose_language_sub':'Hitamo ururimi ukunda cyane.',
    'set_location':       'Shyiraho aho uherereye',
    'set_location_sub':   'Turabikoresha kugutanga ibyemezo no guhanura ibihe.',
    'how_use_abss':       'ABSS uzayikoresha ute?',
    'online_mode':        'Uburyo bwa Interineti',
    'online_mode_desc':   'Inzitizi n\'ubuhanuzi buzima. Porogaramu isanduza buri masaha 2–4.',
    'offline_mode':       'SMS / Nta Interineti',
    'offline_mode_desc':  'Inzitizi z\'ingenzi kuri SMS. Ikora nta interineti. Bisaba kwinjira buri munsi.',
    'online_benefits':    '• Ubuhanuzi busanduza buri masaha 2–4 iwa kuri iwa\n• Ubutumwa bwa push k\'inzitizi z\'ingenzi\n• Uburambe bwuzuye bwa porogaramu',
    'offline_benefits':   '• Inzitizi za SMS kuri telefone iyo ari yo yose — nta data\n• Inzitizi zibitswe iminsi 7 nta interineti\n• Ugomba gutumanaho rimwe ku munsi',
    'your_phone_number':  'Numero yawe ya telefone',
    'register_sms':       'Iyandikishe kwa SMS',
    'your_name':          'Izina ryawe (bishoboka)',
    'good_morning':       'Mwaramutse',
    'good_afternoon':     'Mwiriwe',
    'good_evening':       'Mwiriwe neza',
    'active_alerts':      'Inzitizi Ziracyakorana',
    'early_alerts':       'Inzitizi z\'ibanze z\'ibyago kuri SMS',
    'offline_forecasts':  'Ubuhanuzi bw\'ibihe nta interineti',
    'multi_language':     'Iraboneka mu ndimi 5',
    'welcome_subtitle':   'Menya mbere y\'inkubi. Komeza ufite umutekano aho uri hose.',
    'step1':              'Intambwe 1 ya 4',
    'step2':              'Intambwe 2 ya 4',
    'step3':              'Intambwe 3 ya 4',
    'step4':              'Intambwe 4 ya 4',
    'complete_reg':       'Iyandikisha ryarangiye',
    'daily_checkin':      'Nka mutumiaji udafite interineti, ugomba gufungura porogaramu uhanutse rimwe ku munsi.',
    'almost_there':       'Hafi ya iherezo!',
    'start_using':        'Tangira gukoresha ABSS',
    'detect_location':    'Shaka aho ndi',
    'choose_city':        'Cyangwa hitamo umugi wawe',
    'alert_types':        'Ubwoko bw\'inzitizi',
    'refresh_needed':     'Gusanduza buri munsi bisabwa — tumanaho kugirango usanduze amakuru yawe.',
    'refresh_now':        'Sanduza ubu',
    'verify_number':      'Ohereza kode y\'ukwemeza',
    'verifying':          'Kohereza kode...',
    'verified_msg':       'Numero yemejwe! Witeguye.',
    'verify_required':    'Emeza nimero yawe kugirango ukomeze',
    'sms_alert_note':     'Uzahabwa ubutumwa bwa SMS ku byago bikomeye',
  };

  // ── AMHARIC ───────────────────────────────────────────────────────────────
  static const _am = <String, String>{
    'get_started':        'ጀምር',
    'continue':           'ቀጥል',
    'skip':               'ዝለል',
    'choose_language':    'ቋንቋዎን ይምረጡ',
    'choose_language_sub':'ምቹ የሆነባቸዎ ቋንቋ ይምረጡ።',
    'set_location':       'ቦታዎን ያዘጋጁ',
    'set_location_sub':   'ይህን ለአካባቢዎ ማስጠንቀቂያዎች እና ትንበያ እንጠቀምበታለን።',
    'how_use_abss':       'ABSSን እንዴት ትጠቀሙ?',
    'online_mode':        'የኢንተርኔት ሁኔታ',
    'online_mode_desc':   'ቀጥታ ማስጠንቀቂያዎች እና ትንበያ። መተግበሪያ በ2–4 ሰዓት ይሻሻላል።',
    'offline_mode':       'SMS / ያለ ኢንተርኔት',
    'offline_mode_desc':  'ወሳኝ ማስጠንቀቂያዎችን በSMS ያግኙ። ያለ ኢንተርኔት ይሰራል። ዕለታዊ ቃኝ ያስፈልጋል።',
    'online_benefits':    '• ትንበያ በ2–4 ሰዓት ይሻሻላል\n• ለወሳኝ ተጠንቀቂያዎች Push ማሳወቂያ\n• ሙሉ የመተግበሪያ ሙሌት ሁሉም ስክሪን ላይ',
    'offline_benefits':   '• SMS ማስጠንቀቂያዎች ለማንኛውም ስልክ — ዳታ ሳያስፈልግ\n• ለ7 ቀናት ኦፍላይን የሚቆዩ ማስጠንቀቂያዎች\n• ዕለታዊ ቃኝ ያስፈልጋል',
    'your_phone_number':  'ስልክ ቁጥርዎ',
    'register_sms':       'ለSMS ማስጠንቀቂያዎች ይመዝገቡ',
    'your_name':          'ስምዎ (አማራጭ)',
    'good_morning':       'እንደምን አደሩ',
    'good_afternoon':     'ሰላም',
    'good_evening':       'ደህና ሰነበቱ',
    'active_alerts':      'ንቁ ማስጠንቀቂያዎች',
    'early_alerts':       'ቀደምት የአደጋ ማስጠንቀቂያዎች በSMS',
    'offline_forecasts':  'ያለ ኢንተርኔት የአየር ትንበያ',
    'multi_language':     'በ5 ቋንቋዎች ይገኛል',
    'welcome_subtitle':   'ዝናቡ ሳይደርስ ዝጋጅ። በዩቡሁም ይሁኑ ጤናማ።',
    'step1':              'ደረጃ 1 ከ 4',
    'step2':              'ደረጃ 2 ከ 4',
    'step3':              'ደረጃ 3 ከ 4',
    'step4':              'ደረጃ 4 ከ 4',
    'complete_reg':       'ምዝገባ ተጠናቋል',
    'daily_checkin':      'ያለ ኢንተርኔት ተጠቃሚ እንደ ቀን አንድ ጊዜ ኢንተርኔት ሲኖር ይክፈቱ።',
    'almost_there':       'ቅርብ ደርሰዋል!',
    'start_using':        'ABSS መጠቀም ጀምሩ',
    'detect_location':    'ቦታዬን ፈልግ',
    'choose_city':        'ወይም ከተማዎን ይምረጡ',
    'alert_types':        'የማስጠንቀቂያ ዓይነቶች',
    'refresh_needed':     'ዕለታዊ ማደስ ያስፈልጋል — ይገናኙ ውሂቡን ለማደስ።',
    'refresh_now':        'አሁን አድስ',
    'verify_number':      'የማረጋገጫ ኮድ ላክ',
    'verifying':          'ኮድ በመላክ ላይ...',
    'verified_msg':       'ቁጥር ተረጋግጧል! ዝጋጅተዋል።',
    'verify_required':    'ለመቀጠል ቁጥርዎን ያረጋግጡ',
    'sms_alert_note':     'ለወሳኝ አደጋዎች የSMS ማስጠንቀቂያ ይደርስዎታል',
  };

  // ── FRANÇAIS ──────────────────────────────────────────────────────────────
  static const _fr = <String, String>{
    'get_started':        'Commencer',
    'continue':           'Continuer',
    'skip':               'Passer',
    'choose_language':    'Choisissez votre langue',
    'choose_language_sub':'Sélectionnez la langue avec laquelle vous êtes le plus à l\'aise.',
    'set_location':       'Définir votre emplacement',
    'set_location_sub':   'Nous l\'utilisons pour vous donner des alertes et prévisions locales.',
    'how_use_abss':       'Comment utiliserez-vous ABSS ?',
    'online_mode':        'Mode Connecté',
    'online_mode_desc':   'Alertes et prévisions en direct. L\'app se rafraîchit toutes les 2–4 heures.',
    'offline_mode':       'Mode SMS / Hors Ligne',
    'offline_mode_desc':  'Alertes critiques par SMS. Sans internet. Connexion quotidienne requise.',
    'online_benefits':    '• Prévisions mises à jour toutes les 2–4 h automatiquement\n• Notifications push pour les alertes critiques\n• Expérience complète sur tous les écrans',
    'offline_benefits':   '• Alertes SMS sur tout téléphone — sans données mobiles\n• Alertes en cache 7 jours hors ligne\n• Connexion quotidienne obligatoire',
    'your_phone_number':  'Votre numéro de téléphone',
    'register_sms':       'S\'inscrire aux alertes SMS',
    'your_name':          'Votre nom (facultatif)',
    'good_morning':       'Bonjour',
    'good_afternoon':     'Bon après-midi',
    'good_evening':       'Bonsoir',
    'active_alerts':      'Alertes Actives',
    'early_alerts':       'Alertes précoces de catastrophes par SMS',
    'offline_forecasts':  'Prévisions météo hors ligne',
    'multi_language':     'Disponible en 5 langues',
    'welcome_subtitle':   'Sachez avant la tempête. Restez en sécurité où que vous soyez.',
    'step1':              'Étape 1 sur 4',
    'step2':              'Étape 2 sur 4',
    'step3':              'Étape 3 sur 4',
    'step4':              'Étape 4 sur 4',
    'complete_reg':       'Inscription terminée',
    'daily_checkin':      'En tant qu\'utilisateur hors ligne, vous devez ouvrir l\'app en ligne au moins une fois par jour.',
    'almost_there':       'Presque terminé !',
    'start_using':        'Commencer à utiliser ABSS',
    'detect_location':    'Détecter ma position',
    'choose_city':        'Ou choisissez votre ville',
    'alert_types':        'Types d\'alertes',
    'refresh_needed':     'Synchronisation quotidienne requise — connectez-vous pour actualiser.',
    'refresh_now':        'Actualiser maintenant',
    'verify_number':      'Envoyer le code de vérification',
    'verifying':          'Envoi du code...',
    'verified_msg':       'Numéro vérifié ! Vous êtes prêt.',
    'verify_required':    'Vérifiez votre numéro pour continuer',
    'sms_alert_note':     'Vous recevrez des alertes SMS pour les risques critiques',
  };

  static const _locales = {'en': _en, 'sw': _sw, 'rw': _rw, 'am': _am, 'fr': _fr};
}
