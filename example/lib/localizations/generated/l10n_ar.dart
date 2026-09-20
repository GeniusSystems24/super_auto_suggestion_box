// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class SuperExampleLocalizationAr extends SuperExampleLocalization {
  SuperExampleLocalizationAr([String locale = 'ar']) : super(locale);

  @override
  String get validation => 'التحقق';

  @override
  String get fieldOverride => 'تجاوز إعداد الحقل';

  @override
  String get suffix => 'لاحقة';

  @override
  String get under => 'أسفل';

  @override
  String get label => 'التسمية';

  @override
  String get account => 'الحساب';

  @override
  String get accounts => 'الحسابات';

  @override
  String get searchAccounts => 'ابحث في الحسابات...';

  @override
  String get recentAccounts => 'الحسابات الأخيرة';

  @override
  String get pickAccount => 'اختر حسابًا...';

  @override
  String get requiredAccountLookup => 'البحث عن الحساب مطلوب.';

  @override
  String get selectionCleared => 'تم مسح التحديد';

  @override
  String get directoryEntry => 'إدخال في الدليل';

  @override
  String accountCode(String code) {
    return 'رمز الحساب $code';
  }

  @override
  String get searchModes => 'أوضاع البحث';

  @override
  String get searchModesSubtitle => 'حقل نص · عرض متقدم · كلاهما';

  @override
  String get searchModeVersion => 'v1.3.1 · وضع البحث';

  @override
  String get threeSearchSurfaces => 'مكوّن واحد وثلاث واجهات للبحث';

  @override
  String get searchModeResponsiveDescription =>
      'عند عدم تحديد الوضع، تستخدم منصات سطح المكتب TextBox افتراضيًا، بينما تستخدم Android وiOS وFuchsia وضع AdvanceView.';

  @override
  String get adaptiveDefault => 'الوضع التكيفي الافتراضي';

  @override
  String get adaptiveDefaultDescription =>
      'لا يتم تمرير وضع محدد؛ يستخدم سطح المكتب TextBox بينما تستخدم الأجهزة المحمولة AdvanceView.';

  @override
  String get adaptiveSearch => 'بحث تكيفي';

  @override
  String get platformDefaultMode => 'يستخدم الوضع الافتراضي بحسب المنصة.';

  @override
  String get textBox => 'حقل نص';

  @override
  String get textBoxDescription =>
      'حقل نص تقليدي قابل للتحرير مع قائمة اقتراحات منسدلة مرتبطة بالحقل.';

  @override
  String get textBoxMode => 'وضع TextBox';

  @override
  String get typeAndPickInline => 'اكتب مباشرة واختر من القائمة المضمنة.';

  @override
  String get advanceView => 'العرض المتقدم';

  @override
  String get advanceViewDescription =>
      'يتحول الحقل إلى مشغّل لواجهة البحث المتقدم بدلًا من فتح القائمة المنسدلة المضمنة.';

  @override
  String get advanceViewMode => 'وضع AdvanceView';

  @override
  String get openAdvancedView =>
      'اضغط على الحقل أو ركّز عليه لفتح العرض المتقدم.';

  @override
  String get both => 'كلاهما';

  @override
  String get bothDescription =>
      'يجمع بين سلوك TextBox المضمن والعرض المتقدم. استخدم إجراء البحث المتقدم أو Ctrl/Cmd + F أثناء التركيز على الحقل.';

  @override
  String get bothModes => 'كلا الوضعين';

  @override
  String get bothEnabled => 'تم تفعيل الاقتراحات المضمنة والعرض المتقدم معًا.';

  @override
  String get searchDirectoryHint => 'الاسم أو الرمز أو الفئة أو المدينة...';

  @override
  String get autovalidateMode => 'وضع التحقق التلقائي';

  @override
  String get formAutovalidation => 'التحقق التلقائي للنموذج';

  @override
  String get formDefault => 'إعداد النموذج الافتراضي';

  @override
  String get formDefaultDescription =>
      'يقرأ الحقلان أدناه autovalidateMode من النموذج.';

  @override
  String get disabled => 'معطل';

  @override
  String get always => 'دائمًا';

  @override
  String get onChange => 'عند التغيير';

  @override
  String get postingAccount => 'حساب الترحيل';

  @override
  String get expenseAccount => 'حساب المصروف';

  @override
  String get mustBeExpense => 'يجب أن يكون حساب مصروف.';

  @override
  String get chooseExpense => 'اختر حساب مصروف.';

  @override
  String get validate => 'تحقق';

  @override
  String get reset => 'إعادة تعيين';

  @override
  String get fieldAlwaysValidates =>
      'يتحقق هذا الحقل دائمًا بشكل مستقل عن وضع النموذج.';

  @override
  String get immediateAccount => 'حساب فوري';

  @override
  String get fieldAutovalidatePrecedence =>
      'إعداد autovalidateMode على مستوى الحقل له الأولوية.';

  @override
  String get validationPosition => 'موضع التحقق';

  @override
  String get feedbackPlacement => 'موضع رسالة التحقق';

  @override
  String get globalDefault => 'الإعداد العام الافتراضي';

  @override
  String get globalDefaultDescription =>
      'اتركه متجاوبًا أو حدد موضعًا واحدًا على مستوى الحزمة.';

  @override
  String get responsive => 'متجاوب';

  @override
  String get usesPackageDefault => 'يستخدم إعداد الحزمة الافتراضي';

  @override
  String get fieldPositionDescription =>
      'موضع الحقل المحدد يتجاوز إعداد الحزمة الافتراضي.';

  @override
  String get usesFieldPosition => 'يستخدم موضع الحقل';

  @override
  String get exampleScreen => 'شاشة المثال';

  @override
  String get documentReference => 'مرجع المستند';

  @override
  String directoryEntryNumber(int number) {
    return 'إدخال الدليل $number';
  }

  @override
  String get stringSource => 'مصدر النصوص';

  @override
  String get stringSourceDescription =>
      'مصدر مبسط تكون فيه التسمية مساوية للقيمة';

  @override
  String get listSource => 'مصدر القائمة';

  @override
  String get listSourceDescription => 'مطابقة contains داخل الذاكرة';

  @override
  String get fuzzySource => 'مصدر البحث التقريبي';

  @override
  String get fuzzySourceDescription => 'ترتيب داخل الذاكرة يتحمل أخطاء الكتابة';

  @override
  String get asyncSource => 'مصدر غير متزامن';

  @override
  String get asyncSourceDescription => 'بحث غير متزامن مشابه لبحث الخادم';

  @override
  String get hybridSource => 'مصدر هجين';

  @override
  String get hybridSourceDescription =>
      'نتائج محلية فورية مدمجة مع بيانات بعيدة';

  @override
  String get remoteFallback => 'رجوع إلى المصدر البعيد';

  @override
  String get remoteFallbackDescription =>
      'بحث محلي أولًا مع الرجوع إلى المصدر البعيد';

  @override
  String get pagedSource => 'مصدر مقسم إلى صفحات';

  @override
  String get pagedSourceDescription => 'تمرير لا نهائي عبر صفحات الخادم';

  @override
  String get sourceExample => 'مثال المصدر';

  @override
  String sourceVersion(String title) {
    return 'v1.3.1 · $title';
  }

  @override
  String get basicLookup => 'بحث أساسي';

  @override
  String get widgetOwnsSource => 'المكوّن يدير المصدر ووحدة التحكم.';

  @override
  String get externalController => 'وحدة تحكم خارجية';

  @override
  String get controlFromHost =>
      'اقرأ التحديد وتحكم بالحقل من كود التطبيق المضيف.';

  @override
  String get controlledAccount => 'حساب متحكم به';

  @override
  String get hostControlledLookup => 'بحث يتحكم به التطبيق المضيف...';

  @override
  String get multiSelect => 'تحديد متعدد';

  @override
  String get selectSeveralValues => 'اختر عدة قيم خام من نوع المصدر نفسه.';

  @override
  String get selectAccounts => 'اختر الحسابات...';

  @override
  String get recentSelections => 'التحديدات الأخيرة';

  @override
  String get committedValuesPinned =>
      'تُثبت القيم المحددة عند كون عبارة البحث فارغة.';

  @override
  String accountNumber(int number) {
    return 'الحساب $number';
  }

  @override
  String get allItemScenarios => 'كل سيناريوهات العناصر';

  @override
  String get itemApiVersion => 'v1.3.1 · واجهة العنصر';

  @override
  String get everyItemScenario => 'كل سيناريوهات SuperAutoSuggestionsItem';

  @override
  String get itemScenarioOverview =>
      'تغطي القائمة أدناه البيانات النصية، والمكونات المخصصة، والتجميع، والكلمات المفتاحية، وحالة التفعيل الثابتة، وStream<bool> enabledSnapshot، وعنصرًا غنيًا مركبًا.';

  @override
  String get enabledSnapshotDescription =>
      'يحدّث هذا المفتاح Stream<bool> المستخدم في سيناريو enabledSnapshot.';

  @override
  String get dynamicSuggestionEnabled => 'الاقتراح الديناميكي مفعّل';

  @override
  String get dynamicSuggestionDisabled => 'الاقتراح الديناميكي معطل';

  @override
  String get allItemScenariosTitle => 'كل سيناريوهات العناصر';

  @override
  String get inspectItemCases =>
      'افتح الاقتراحات وتفحص كل حالة عرض/واجهة برمجية.';

  @override
  String get itemScenariosLabel => 'سيناريوهات SuperAutoSuggestionsItem';

  @override
  String get openEmptyQuery =>
      'افتح القائمة بعبارة بحث فارغة لرؤية جميع الحالات.';

  @override
  String get searchTitleKeywords => 'ابحث في العنوان أو الكلمات المفتاحية...';

  @override
  String get plainTitleText => 'نص عنوان عادي';

  @override
  String get descriptionAsText => 'وصف كنص';

  @override
  String get descriptionTextSupport =>
      'يعرض descriptionText نصًا توضيحيًا عاديًا';

  @override
  String get descriptionAsWidget => 'وصف كمكوّن';

  @override
  String get customDescriptionWidget => 'مكوّن وصف مخصص';

  @override
  String get trailingText => 'نص لاحق';

  @override
  String get trailingWidget => 'مكوّن لاحق';

  @override
  String get active => 'نشط';

  @override
  String get customIconWidget => 'مكوّن أيقونة مخصص';

  @override
  String get groupedSuggestion => 'اقتراح مجمّع';

  @override
  String get metadataScenarios => 'سيناريوهات البيانات الوصفية';

  @override
  String get searchableAliases => 'أسماء بديلة قابلة للبحث';

  @override
  String get searchAliasesHint => 'ابحث عن: invoice أو vendor أو INV-1042';

  @override
  String get staticallyDisabled => 'معطل بشكل ثابت';

  @override
  String get streamControlledState => 'حالة تفعيل يتحكم بها Stream';

  @override
  String get streamControlledDescription =>
      'enabledSnapshot: Stream<bool> · بدّل حالته أعلى الحقل';

  @override
  String get combinedRichSuggestion => 'اقتراح غني مركب';

  @override
  String get richDescription =>
      'وصف بمكوّن · يظل العنوان القابل للبحث هو titleText';

  @override
  String get richScenarios => 'سيناريوهات غنية';

  @override
  String get autoSuggestionBox => 'مربع الاقتراح التلقائي';

  @override
  String get accountLookup => 'البحث عن الحساب';

  @override
  String get postToAccount => 'الترحيل إلى حساب';

  @override
  String get searchChartAccounts => 'ابحث في دليل الحسابات بالاسم أو الرمز';

  @override
  String get accountsReceivableExample => 'مثال: حسابات العملاء';

  @override
  String get tagCostCenters => 'تحديد مراكز التكلفة';

  @override
  String get assignCostCenters => 'عيّن مركز تكلفة واحدًا أو أكثر لهذا الإدخال';

  @override
  String get quickFilter => 'تصفية سريعة';

  @override
  String get fuzzyMatchHint => 'مطابقة تقريبية - اكتب بشكل مرن';

  @override
  String get rdhExample => 'مثال: rdh';

  @override
  String get selectVendor => 'اختر المورد';

  @override
  String get vendorRemoteDescription =>
      'يظهر الموردون المحليون فورًا، ويعمل بحث الخادم عندما تكون النتائج المحلية قليلة';

  @override
  String get vendorExample => 'مثال: إسمنت، شحن، زجاج...';

  @override
  String get vendorDirectory => 'دليل الموردين';

  @override
  String get advancedSearchShortcutDescription =>
      'ركّز على الحقل واضغط Ctrl / Cmd + F لفتح البحث المتقدم';

  @override
  String get searchDirectory => 'ابحث في الدليل... (Cmd/Ctrl+F)';

  @override
  String get requiredCustomValidator =>
      'حقل مطلوب مع مدقق مخصص - اتركه فارغًا ثم انتقل بالحرف Tab';

  @override
  String get debitAccount => 'حساب المدين';

  @override
  String get pickAccountTypes =>
      'اختر حساب أصل أو التزام أو حقوق ملكية أو إيراد أو مصروف';

  @override
  String get pickAccountFromList => 'اختر حسابًا من القائمة';

  @override
  String get lockedAccount => 'حساب مقفل';

  @override
  String get disabledFieldDescription =>
      'الحقل المعطل يمنع الكتابة وفتح واجهة الاقتراحات';

  @override
  String get reconciliationAccount => 'حساب التسوية';

  @override
  String get themedField => 'حقل مخصص الثيم';

  @override
  String get themedFieldDescription =>
      'ثيم مخصص لهذا الحقل مباشرة - تعبئة وحدود خضراء عند التركيز ونص عريض';

  @override
  String get ledgerAccount => 'حساب دفتر الأستاذ';

  @override
  String get customFocusedStyleHint => 'ركّز عليّ لرؤية نمط التركيز المخصص';

  @override
  String get recentAccountsDescription =>
      'اختر عدة حسابات ثم امسح الحقل وأعد فتحه - ستظهر الاختيارات الأخيرة في الأعلى';

  @override
  String get projectTag => 'وسم المشروع';

  @override
  String get createProjectDescription =>
      'اكتب اسمًا غير موجود واضغط Enter لإنشائه';

  @override
  String get project => 'المشروع';

  @override
  String get seafrontVillasExample => 'مثال: فلل الواجهة البحرية';

  @override
  String get itemCatalog => 'دليل الأصناف';

  @override
  String get itemCatalogDescription =>
      'بيانات رئيسية كبيرة - 12 صفًا لكل صفحة؛ مرر القائمة لتحميل المزيد';

  @override
  String get item => 'الصنف';

  @override
  String get search64Items => 'ابحث في 64 صنفًا...';

  @override
  String get boundAccount => 'حساب مرتبط';

  @override
  String get boundAccountDescription =>
      'اربط الحساب بالرمز المخزن ثم اقفله في وضع قراءة فقط';

  @override
  String get pickOrBindCode => 'اختر أو اربط بواسطة الرمز';

  @override
  String get bind1020 => 'اربط 1020';

  @override
  String get bind4000 => 'اربط 4000';

  @override
  String get edit => 'تعديل';

  @override
  String get lockReadOnly => 'قفل (للقراءة فقط)';

  @override
  String get erpDocumentReference => 'مرجع مستند ERP';

  @override
  String get erpReferenceDescription =>
      'اكتب بادئة واضغط Tab لقبول الإكمال، ثم Tab مرة أخرى للانتقال';

  @override
  String get inv1042Example => 'مثال: INV-1042';

  @override
  String get fieldTapped => 'تم الضغط على الحقل';

  @override
  String get pointerDownOutside => 'ضغط المؤشر خارج الحقل';

  @override
  String get pointerUpOutside => 'رفع المؤشر خارج الحقل';

  @override
  String selectedValue(String value) {
    return 'المحدد: $value';
  }

  @override
  String get validateAndSave => 'تحقق واحفظ';

  @override
  String get formValidated => 'تم التحقق من النموذج';

  @override
  String savedStatus(String reference, String event) {
    return 'محفوظ: $reference - $event';
  }

  @override
  String get fixableAccount => 'حساب قابل للتثبيت';

  @override
  String get fixableDescription =>
      'استخدم إجراء التسمية الصغير لحماية القيمة الحالية أو إلغاء قفلها';

  @override
  String get settlementAccount => 'حساب التسوية';

  @override
  String get lockAfterSelecting => 'اقفل الحقل بعد اختيار حساب';

  @override
  String get pickThenFix => 'اختر حسابًا ثم ثبته';

  @override
  String get focusField => 'ركّز على الحقل';

  @override
  String get validateField => 'تحقق من الحقل';

  @override
  String get inputDecoration => 'تنسيق الإدخال';

  @override
  String get inputDecorationDescription =>
      'تستخدم التسمية والنص المساعد والنص الإرشادي InputDecoration القياسي في Flutter';

  @override
  String get cashAccount => 'حساب النقدية';

  @override
  String get standardInputHelper => 'نص مساعد قياسي لـ InputDecoration';

  @override
  String get searchByAccount => 'ابحث برمز الحساب أو اسمه';

  @override
  String get projectTagDescription => 'وسم المشروع';

  @override
  String catalogItem(String number) {
    return 'الصنف $number';
  }

  @override
  String warehouseDescription(String sku) {
    return '$sku - المستودع A';
  }

  @override
  String inStock(int count) {
    return '$count في المخزون';
  }

  @override
  String get localRiyadh => 'محلي - الرياض';

  @override
  String get serverRemote => 'الخادم - بعيد';

  @override
  String get noSelectionEventYet => 'لا يوجد حدث تحديد بعد';

  @override
  String get appTitle => 'مربع الاقتراحات التلقائية Super';

  @override
  String get galleryEyebrow => 'SUPER AUTO SUGGESTION BOX • معرض الأمثلة';

  @override
  String get componentDemos => 'أمثلة المكونات';

  @override
  String get suggestionItemScenarios => 'سيناريوهات عناصر الاقتراح';

  @override
  String get suggestionItemScenariosGalleryDescription =>
      'جميع حقول SuperAutoSuggestionsItem · enabledSnapshot';

  @override
  String get autovalidateGalleryDescription =>
      'قيمة الحقل · إعداد Form الافتراضي · بديل عند التعطيل';

  @override
  String get validationPositionGalleryDescription =>
      'أيقونة لاحقة · نص أسفل الحقل · أيقونة بعد التسمية';

  @override
  String get advancedSearch => 'البحث المتقدم';

  @override
  String get advancedSearchGalleryDescription =>
      'Ctrl / Cmd + F · مربع حوار مدمج · واجهة بحث متقدم مخصصة';

  @override
  String get autoSuggestionBoxGalleryDescription =>
      'اقتراح أثناء الكتابة · حديثة · إنشاء · صفحات · تحديد متعدد · بحث تقريبي';

  @override
  String get sourceDemoCapabilities =>
      'أساسي · متحكم به · تحديد متعدد · تحديدات حديثة';

  @override
  String get lightTheme => 'المظهر الفاتح';

  @override
  String get darkTheme => 'المظهر الداكن';

  @override
  String get switchToArabic => 'العربية (RTL)';

  @override
  String get switchToEnglish => 'English (LTR)';

  @override
  String get version151Changes => 'تغييرات الإصدار 1.5.1';

  @override
  String get version151GalleryDescription =>
      'اقتراحات تراعي لوحة المفاتيح · زر إنشاء في العرض المتقدم';

  @override
  String get version151Eyebrow => 'الإصدار 1.5.1 · السلوك';

  @override
  String get version151Title =>
      'بحث يراعي لوحة المفاتيح وإنشاء من العرض المتقدم';

  @override
  String get version151Description =>
      'تعرض هذه الأمثلة إصلاحات احتساب المساحة وزر الإنشاء المضافة في الإصدار 1.5.1.';

  @override
  String get version151KeyboardSafeOverlay => 'اقتراحات تراعي لوحة المفاتيح';

  @override
  String get version151KeyboardSafeOverlayDescription =>
      'يجب أن تستخدم قائمة الاقتراحات الجزء الظاهر فقط من الشاشة وألا تمتد خلف لوحة المفاتيح.';

  @override
  String get version151KeyboardSafeInstruction =>
      'على الهاتف أو المحاكي، ركّز الحقل مع إبقاء لوحة المفاتيح ظاهرة ثم اكتب ACC. يجب أن تبقى قائمة الاقتراحات الطويلة داخل المنطقة المرئية.';

  @override
  String get version151AccountLookup => 'بحث حساب يراعي لوحة المفاتيح';

  @override
  String get version151KeyboardSafeHelper =>
      'تجعل النتائج الكثيرة التحقق من احتساب الارتفاع المتاح أكثر وضوحاً.';

  @override
  String get version151AccountHint => 'اكتب ACC أو رمز حساب...';

  @override
  String get version151SampleAccount => 'حساب تجريبي';

  @override
  String get version151AdvancedCreate => 'الإنشاء من العرض المتقدم';

  @override
  String get version151AdvancedCreateDescription =>
      'عندما تكون onCreate متاحة ولا توجد اقتراحات للاستعلام، يجب أن يعرض العرض المتقدم زر الإنشاء.';

  @override
  String get version151ProjectLookup => 'البحث عن مشروع';

  @override
  String get version151ProjectLookupHelper =>
      'افتح العرض المتقدم واكتب قيمة غير موجودة مسبقاً في قائمة المشاريع.';

  @override
  String get version151ProjectHint => 'ابحث عن مشروع أو أنشئه...';

  @override
  String get version151SampleProject => 'مشروع موجود';

  @override
  String get version151NoProjectSelected => 'لم يتم اختيار مشروع بعد.';

  @override
  String version151SelectedProject(String project) {
    return 'المحدد: $project';
  }

  @override
  String version151CreatedProject(String project) {
    return 'تم إنشاء المشروع: $project';
  }

  @override
  String version151CreateProject(String query) {
    return 'إنشاء \"$query\"';
  }
}
