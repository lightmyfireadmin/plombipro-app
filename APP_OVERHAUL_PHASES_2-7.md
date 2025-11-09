# PLOMBIPRO APP OVERHAUL - PHASES 2-7
## Continuation of Comprehensive Overhaul Plan

---

# PHASE 2: STATE MANAGEMENT & ARCHITECTURE
## 🟡 Weeks 3-4 | High Priority

<a name="phase-2-state-management"></a>
## 2.1 RIVERPOD IMPLEMENTATION (5 days) 🟡

### Why Riverpod?
- **Type-safe:** Compile-time error checking
- **Testable:** Easy to mock providers
- **Scalable:** Works well with large apps
- **Reactive:** Automatic UI rebuilds
- **No BuildContext:** Access providers anywhere

### 2.1.1 Setup Riverpod Architecture

**Tasks:**
- [ ] Add dependencies to pubspec.yaml
  ```yaml
  dependencies:
    flutter_riverpod: ^2.5.1
    riverpod_annotation: ^2.3.5

  dev_dependencies:
    riverpod_generator: ^2.4.0
    build_runner: ^2.4.9
  ```

- [ ] Wrap app with ProviderScope
  ```dart
  // In main.dart
  void main() {
    runApp(
      ProviderScope(
        child: PlombiProApp(),
      ),
    );
  }
  ```

- [ ] Create provider directory structure
  ```
  lib/
  ├── providers/
  │   ├── auth_provider.dart
  │   ├── client_provider.dart
  │   ├── quote_provider.dart
  │   ├── invoice_provider.dart
  │   ├── product_provider.dart
  │   ├── job_site_provider.dart
  │   ├── payment_provider.dart
  │   ├── analytics_provider.dart
  │   └── app_state_provider.dart
  ```

**Estimated Time:** 1 day
**Dependencies:** None
**Success Criteria:** Riverpod integrated and providers structure created

---

### 2.1.2 Create Core State Providers

**Tasks:**
- [ ] Auth state provider
  ```dart
  // lib/providers/auth_provider.dart
  import 'package:riverpod_annotation/riverpod_annotation.dart';
  import 'package:supabase_flutter/supabase_flutter.dart';

  part 'auth_provider.g.dart';

  @riverpod
  class AuthState extends _$AuthState {
    @override
    User? build() {
      return Supabase.instance.client.auth.currentUser;
    }

    Future<void> signIn(String email, String password) async {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      state = response.user;
    }

    Future<void> signOut() async {
      await Supabase.instance.client.auth.signOut();
      state = null;
    }

    Future<void> refreshUser() async {
      state = Supabase.instance.client.auth.currentUser;
    }
  }

  @riverpod
  Stream<AuthState> authStateChanges(AuthStateChangesRef ref) {
    return Supabase.instance.client.auth.onAuthStateChange;
  }

  @riverpod
  Future<Map<String, dynamic>?> userProfile(UserProfileRef ref) async {
    final user = ref.watch(authStateProvider);
    if (user == null) return null;

    return await SupabaseService.fetchUserProfile();
  }
  ```

- [ ] Client list provider with caching
  ```dart
  // lib/providers/client_provider.dart
  import 'package:riverpod_annotation/riverpod_annotation.dart';

  part 'client_provider.g.dart';

  @riverpod
  class ClientList extends _$ClientList {
    @override
    Future<List<Map<String, dynamic>>> build() async {
      return await SupabaseService.fetchClients();
    }

    Future<void> refresh() async {
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(() => SupabaseService.fetchClients());
    }

    Future<void> addClient(Map<String, dynamic> clientData) async {
      await SupabaseService.createClient(clientData);
      await refresh();
    }

    Future<void> updateClient(String id, Map<String, dynamic> updates) async {
      await SupabaseService.updateClient(id, updates);
      await refresh();
    }

    Future<void> deleteClient(String id) async {
      await SupabaseService.deleteClient(id);
      await refresh();
    }

    List<Map<String, dynamic>> search(String query) {
      return state.value?.where((client) {
        final name = client['full_name']?.toString().toLowerCase() ?? '';
        final company = client['company_name']?.toString().toLowerCase() ?? '';
        final email = client['email']?.toString().toLowerCase() ?? '';
        final q = query.toLowerCase();

        return name.contains(q) || company.contains(q) || email.contains(q);
      }).toList() ?? [];
    }
  }

  @riverpod
  Future<Map<String, dynamic>?> client(ClientRef ref, String id) async {
    return await SupabaseService.getClient(id);
  }
  ```

- [ ] Quote state provider
  ```dart
  // lib/providers/quote_provider.dart
  @riverpod
  class QuoteList extends _$QuoteList {
    @override
    Future<List<Map<String, dynamic>>> build() async {
      return await SupabaseService.fetchQuotes();
    }

    Future<void> refresh() async {
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(() => SupabaseService.fetchQuotes());
    }

    Future<void> createQuote(Map<String, dynamic> quoteData) async {
      await SupabaseService.createQuote(quoteData);
      await refresh();
    }

    Future<void> updateQuote(String id, Map<String, dynamic> updates) async {
      await SupabaseService.updateQuote(id, updates);
      await refresh();
    }

    Future<void> deleteQuote(String id) async {
      await SupabaseService.deleteQuote(id);
      await refresh();
    }

    Future<void> convertToInvoice(String quoteId) async {
      await SupabaseService.convertQuoteToInvoice(quoteId);
      await refresh();
      // Also refresh invoice list
      ref.invalidate(invoiceListProvider);
    }

    List<Map<String, dynamic>> filterByStatus(String status) {
      return state.value?.where((q) => q['status'] == status).toList() ?? [];
    }

    double getTotalValue() {
      return state.value?.fold(0.0, (sum, quote) {
        return sum + (quote['total_amount'] ?? 0.0);
      }) ?? 0.0;
    }
  }
  ```

- [ ] Invoice state provider (similar to quote)
- [ ] Product catalog provider
- [ ] Dashboard analytics provider

**Estimated Time:** 3 days
**Dependencies:** Riverpod setup
**Success Criteria:** All major features have Riverpod providers

---

### 2.1.3 Migrate Screens to Use Providers

**Tasks:**
- [ ] Update home_page.dart
  ```dart
  // Before (old setState approach)
  class _HomePageState extends State<HomePage> {
    bool _isLoading = true;
    List<Map<String, dynamic>> _quotes = [];

    @override
    void initState() {
      super.initState();
      _loadData();
    }

    Future<void> _loadData() async {
      setState(() => _isLoading = true);
      final quotes = await SupabaseService.fetchQuotes();
      setState(() {
        _quotes = quotes;
        _isLoading = false;
      });
    }
    // ...
  }

  // After (Riverpod)
  class HomePage extends ConsumerWidget {
    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final quotesAsync = ref.watch(quoteListProvider);
      final invoicesAsync = ref.watch(invoiceListProvider);
      final userProfile = ref.watch(userProfileProvider);

      return Scaffold(
        body: quotesAsync.when(
          data: (quotes) => _buildDashboard(quotes),
          loading: () => Center(child: CircularProgressIndicator()),
          error: (err, stack) => ErrorView(error: err),
        ),
      );
    }
  }
  ```

- [ ] Update quote_list_page.dart with provider
- [ ] Update client_list_page.dart with provider
- [ ] Update invoice_list_page.dart with provider
- [ ] Remove all setState() calls in favor of providers

**Estimated Time:** 1 day
**Dependencies:** Providers created
**Success Criteria:** No more setState(), all using Riverpod

---

<a name="phase-2-services"></a>
## 2.2 SERVICE LAYER REFACTOR (3 days) 🟢

### 2.2.1 Split SupabaseService into Repositories

**Current Issue:** `/lib/services/supabase_service.dart` is 1,508 lines - too large

**Tasks:**
- [ ] Create repository pattern structure
  ```
  lib/
  ├── repositories/
  │   ├── auth_repository.dart
  │   ├── client_repository.dart
  │   ├── quote_repository.dart
  │   ├── invoice_repository.dart
  │   ├── product_repository.dart
  │   ├── job_site_repository.dart
  │   ├── payment_repository.dart
  │   └── base_repository.dart
  ```

- [ ] Create base repository with common patterns
  ```dart
  // lib/repositories/base_repository.dart
  abstract class BaseRepository {
    final SupabaseClient _client = Supabase.instance.client;

    String get userId => _client.auth.currentUser?.id ?? '';

    Future<T> execute<T>(Future<T> Function() operation) async {
      try {
        return await operation();
      } catch (e) {
        ErrorService.handleError(runtimeType.toString(), e);
        rethrow;
      }
    }
  }
  ```

- [ ] Refactor client operations into ClientRepository
  ```dart
  // lib/repositories/client_repository.dart
  class ClientRepository extends BaseRepository {
    Future<List<Map<String, dynamic>>> getAll() async {
      return execute(() async {
        final response = await _client
          .from('clients')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

        return List<Map<String, dynamic>>.from(response);
      });
    }

    Future<Map<String, dynamic>?> getById(String id) async {
      return execute(() async {
        final response = await _client
          .from('clients')
          .select()
          .eq('id', id)
          .eq('user_id', userId)
          .single();

        return response;
      });
    }

    Future<String> create(Map<String, dynamic> data) async {
      return execute(() async {
        data['user_id'] = userId;
        final response = await _client
          .from('clients')
          .insert(data)
          .select()
          .single();

        return response['id'] as String;
      });
    }

    Future<void> update(String id, Map<String, dynamic> data) async {
      return execute(() async {
        await _client
          .from('clients')
          .update(data)
          .eq('id', id)
          .eq('user_id', userId);
      });
    }

    Future<void> delete(String id) async {
      return execute(() async {
        await _client
          .from('clients')
          .delete()
          .eq('id', id)
          .eq('user_id', userId);
      });
    }

    Future<List<Map<String, dynamic>>> search(String query) async {
      return execute(() async {
        final response = await _client
          .from('clients')
          .select()
          .eq('user_id', userId)
          .or('full_name.ilike.%$query%,company_name.ilike.%$query%,email.ilike.%$query%')
          .order('full_name', ascending: true);

        return List<Map<String, dynamic>>.from(response);
      });
    }

    Future<Map<String, dynamic>> getClientStats(String clientId) async {
      return execute(() async {
        final invoices = await _client
          .from('invoices')
          .select('total_amount, status')
          .eq('client_id', clientId);

        final total = invoices.fold(0.0, (sum, inv) => sum + (inv['total_amount'] ?? 0.0));
        final paid = invoices.where((inv) => inv['status'] == 'paid').fold(
          0.0, (sum, inv) => sum + (inv['total_amount'] ?? 0.0));
        final unpaid = total - paid;

        return {
          'total_invoiced': total,
          'paid': paid,
          'unpaid': unpaid,
          'invoice_count': invoices.length,
        };
      });
    }
  }
  ```

- [ ] Create repositories for all entities (Quote, Invoice, Product, etc.)
- [ ] Update providers to use repositories instead of SupabaseService
- [ ] Deprecate old SupabaseService gradually

**Estimated Time:** 3 days
**Dependencies:** None
**Success Criteria:** All database operations use repository pattern

---

<a name="phase-2-performance"></a>
## 2.3 PERFORMANCE OPTIMIZATION (4 days) 🟡

### 2.3.1 Implement Pagination

**Tasks:**
- [ ] Add pagination to client list
  ```dart
  @riverpod
  class PaginatedClientList extends _$PaginatedClientList {
    static const pageSize = 20;
    int _currentPage = 0;

    @override
    Future<List<Map<String, dynamic>>> build() async {
      return await _loadPage(0);
    }

    Future<List<Map<String, dynamic>>> _loadPage(int page) async {
      final offset = page * pageSize;

      final response = await Supabase.instance.client
        .from('clients')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .range(offset, offset + pageSize - 1);

      return List<Map<String, dynamic>>.from(response);
    }

    Future<void> loadNextPage() async {
      _currentPage++;
      final nextPage = await _loadPage(_currentPage);

      state = AsyncValue.data([
        ...?state.value,
        ...nextPage,
      ]);
    }

    Future<void> refresh() async {
      _currentPage = 0;
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(() => _loadPage(0));
    }
  }
  ```

- [ ] Implement lazy loading scroll controller
  ```dart
  class LazyLoadingList extends StatefulWidget {
    @override
    _LazyLoadingListState createState() => _LazyLoadingListState();
  }

  class _LazyLoadingListState extends State<LazyLoadingList> {
    final ScrollController _scrollController = ScrollController();
    bool _isLoadingMore = false;

    @override
    void initState() {
      super.initState();
      _scrollController.addListener(_onScroll);
    }

    void _onScroll() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent * 0.8) {
        _loadMore();
      }
    }

    Future<void> _loadMore() async {
      if (_isLoadingMore) return;

      setState(() => _isLoadingMore = true);

      // Load next page
      await ref.read(paginatedClientListProvider.notifier).loadNextPage();

      setState(() => _isLoadingMore = false);
    }

    @override
    Widget build(BuildContext context) {
      return ListView.builder(
        controller: _scrollController,
        itemCount: items.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == items.length) {
            return Center(child: CircularProgressIndicator());
          }
          return ItemTile(item: items[index]);
        },
      );
    }

    @override
    void dispose() {
      _scrollController.dispose();
      super.dispose();
    }
  }
  ```

- [ ] Add pagination to quotes, invoices, products, job sites
- [ ] Implement "Load More" buttons as fallback

**Estimated Time:** 2 days
**Dependencies:** Riverpod providers
**Success Criteria:** All lists paginated, smooth scrolling with 1000+ items

---

### 2.3.2 Implement Caching Layer

**Tasks:**
- [ ] Add Hive for local storage
  ```yaml
  dependencies:
    hive: ^2.2.3
    hive_flutter: ^1.1.0

  dev_dependencies:
    hive_generator: ^2.0.1
  ```

- [ ] Create cache service
  ```dart
  // lib/services/cache_service.dart
  import 'package:hive_flutter/hive_flutter.dart';

  class CacheService {
    static const String _clientsBox = 'clients';
    static const String _quotesBox = 'quotes';
    static const String _invoicesBox = 'invoices';
    static const Duration _cacheDuration = Duration(minutes: 30);

    static Future<void> init() async {
      await Hive.initFlutter();
      await Hive.openBox(_clientsBox);
      await Hive.openBox(_quotesBox);
      await Hive.openBox(_invoicesBox);
    }

    static Future<void> cacheClients(List<Map<String, dynamic>> clients) async {
      final box = Hive.box(_clientsBox);
      await box.put('data', clients);
      await box.put('timestamp', DateTime.now().millisecondsSinceEpoch);
    }

    static Future<List<Map<String, dynamic>>?> getCachedClients() async {
      final box = Hive.box(_clientsBox);
      final timestamp = box.get('timestamp') as int?;

      if (timestamp == null) return null;

      final age = DateTime.now().millisecondsSinceEpoch - timestamp;
      if (age > _cacheDuration.inMilliseconds) {
        return null;  // Cache expired
      }

      final data = box.get('data');
      if (data == null) return null;

      return List<Map<String, dynamic>>.from(data);
    }

    static Future<void> clearCache() async {
      await Hive.box(_clientsBox).clear();
      await Hive.box(_quotesBox).clear();
      await Hive.box(_invoicesBox).clear();
    }
  }
  ```

- [ ] Integrate cache with repositories
  ```dart
  class ClientRepository extends BaseRepository {
    Future<List<Map<String, dynamic>>> getAll({bool forceRefresh = false}) async {
      // Try cache first
      if (!forceRefresh) {
        final cached = await CacheService.getCachedClients();
        if (cached != null) return cached;
      }

      // Fetch from network
      final clients = await execute(() async {
        final response = await _client
          .from('clients')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

        return List<Map<String, dynamic>>.from(response);
      });

      // Cache the result
      await CacheService.cacheClients(clients);

      return clients;
    }
  }
  ```

- [ ] Add cache invalidation on mutations
- [ ] Implement cache-first, network-fallback strategy

**Estimated Time:** 2 days
**Dependencies:** Repositories
**Success Criteria:** 90% faster list loads from cache

---

### 2.3.3 Optimize Image Loading

**Tasks:**
- [ ] Add cached_network_image package
  ```yaml
  dependencies:
    cached_network_image: ^3.3.1
  ```

- [ ] Create optimized image widget
  ```dart
  class CachedImage extends StatelessWidget {
    final String imageUrl;
    final double? width;
    final double? height;
    final BoxFit fit;

    const CachedImage({
      Key? key,
      required this.imageUrl,
      this.width,
      this.height,
      this.fit = BoxFit.cover,
    }) : super(key: key);

    @override
    Widget build(BuildContext context) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => Container(
          color: PlombiProColors.gray200,
          child: Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: PlombiProColors.gray200,
          child: Icon(Icons.error, color: PlombiProColors.error),
        ),
        fadeInDuration: Duration(milliseconds: 300),
        memCacheWidth: width != null ? (width! * 2).toInt() : null,
        memCacheHeight: height != null ? (height! * 2).toInt() : null,
      );
    }
  }
  ```

- [ ] Compress images before upload
  ```dart
  import 'package:flutter_image_compress/flutter_image_compress.dart';

  Future<File> compressImage(File file, {int quality = 85}) async {
    final dir = await getTemporaryDirectory();
    final targetPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: quality,
      minWidth: 1920,
      minHeight: 1080,
    );

    return File(result!.path);
  }
  ```

- [ ] Replace all Image.network with CachedImage
- [ ] Add image compression to photo uploads

**Estimated Time:** 1 day
**Dependencies:** None
**Success Criteria:** Images load instantly from cache, 70% smaller upload sizes

---

## PHASE 2 SUMMARY

**Duration:** 2 weeks
**Key Deliverables:**
- ✅ Riverpod state management throughout app
- ✅ Repository pattern for all data operations
- ✅ Pagination on all lists
- ✅ Local caching for offline-first experience
- ✅ Optimized image loading and compression

**Success Metrics:**
- [ ] Zero setState() calls remain
- [ ] 90% faster list loads from cache
- [ ] Smooth scrolling with 1,000+ items
- [ ] 70% reduction in image upload sizes
- [ ] 50% reduction in API calls

---

# PHASE 3: CRITICAL FEATURE IMPLEMENTATION
## 🔴 Weeks 5-10 | Critical Priority

<a name="phase-3-esignature"></a>
## 3.1 ELECTRONIC SIGNATURE (10 days) 🔴

### Competitive Context
- **Competitors with this:** Batappli, Obat, Kalitics, Kizeo
- **Market Expectation:** Standard feature in 2025
- **User Need:** Client signs quote on-site, work starts immediately

### 3.1.1 Choose E-Signature Solution

**Options:**
1. **Native Flutter signature pad** (FREE, simple but limited)
2. **Yousign API** (French provider, €50+/month, full legal compliance)
3. **DocuSign** (Global leader, €25+/month, enterprise features)
4. **Adobe Sign** (Premium, €50+/month, PDF focus)

**Recommendation:** Start with native pad, add Yousign integration later

**Tasks:**
- [ ] Install signature package
  ```yaml
  dependencies:
    signature: ^5.5.0
  ```

- [ ] Create signature capture widget
  ```dart
  // lib/widgets/signature_pad.dart
  import 'package:signature/signature.dart';

  class SignatureCaptureDialog extends StatefulWidget {
    final String documentType;  // 'quote' or 'invoice'
    final String documentTitle;

    @override
    _SignatureCaptureDialogState createState() => _SignatureCaptureDialogState();
  }

  class _SignatureCaptureDialogState extends State<SignatureCaptureDialog> {
    final SignatureController _controller = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );

    @override
    Widget build(BuildContext context) {
      return Dialog(
        child: Container(
          padding: EdgeInsets.all(Spacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Signature du client',
                style: PlombiProTextStyles.heading2,
              ),

              SizedBox(height: Spacing.md),

              Text(
                widget.documentTitle,
                style: PlombiProTextStyles.body,
                textAlign: TextAlign.center,
              ),

              SizedBox(height: Spacing.lg),

              // Signature pad
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: PlombiProColors.gray300),
                  borderRadius: BorderRadii.circularMedium,
                  color: Colors.white,
                ),
                child: Signature(
                  controller: _controller,
                  backgroundColor: Colors.white,
                ),
              ),

              SizedBox(height: Spacing.md),

              Row(
                children: [
                  // Clear button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _controller.clear(),
                      icon: Icon(Icons.clear),
                      label: Text('Effacer'),
                    ),
                  ),

                  SizedBox(width: Spacing.md),

                  // Save button
                  Expanded(
                    flex: 2,
                    child: GradientButton(
                      text: 'Valider',
                      icon: Icons.check,
                      onPressed: _saveSignature,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    Future<void> _saveSignature() async {
      if (_controller.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veuillez signer avant de valider')),
        );
        return;
      }

      final signatureBytes = await _controller.toPngBytes();
      if (signatureBytes != null) {
        Navigator.of(context).pop(signatureBytes);
      }
    }

    @override
    void dispose() {
      _controller.dispose();
      super.dispose();
    }
  }
  ```

**Estimated Time:** 2 days
**Dependencies:** None
**Success Criteria:** Signature capture works on mobile

---

### 3.1.2 Integrate Signature into Quote/Invoice Flow

**Tasks:**
- [ ] Add signature storage to database
  ```sql
  ALTER TABLE quotes ADD COLUMN signature_url TEXT;
  ALTER TABLE quotes ADD COLUMN signed_at TIMESTAMP WITH TIME ZONE;
  ALTER TABLE quotes ADD COLUMN signed_by_name TEXT;
  ALTER TABLE quotes ADD COLUMN signed_by_email TEXT;

  ALTER TABLE invoices ADD COLUMN signature_url TEXT;
  ALTER TABLE invoices ADD COLUMN signed_at TIMESTAMP WITH TIME ZONE;
  ALTER TABLE invoices ADD COLUMN signed_by_name TEXT;
  ```

- [ ] Create signature upload service
  ```dart
  class SignatureService {
    static Future<String> uploadSignature({
      required Uint8List signatureBytes,
      required String documentType,
      required String documentId,
    }) async {
      final fileName = '${documentType}_${documentId}_signature_${DateTime.now().millisecondsSinceEpoch}.png';
      final path = 'signatures/$fileName';

      await Supabase.instance.client.storage
        .from('signatures')
        .uploadBinary(path, signatureBytes);

      final publicUrl = Supabase.instance.client.storage
        .from('signatures')
        .getPublicUrl(path);

      return publicUrl;
    }

    static Future<void> saveQuoteSignature({
      required String quoteId,
      required String signatureUrl,
      required String clientName,
      String? clientEmail,
    }) async {
      await Supabase.instance.client
        .from('quotes')
        .update({
          'signature_url': signatureUrl,
          'signed_at': DateTime.now().toIso8601String(),
          'signed_by_name': clientName,
          'signed_by_email': clientEmail,
          'status': 'accepted',
        })
        .eq('id', quoteId);
    }
  }
  ```

- [ ] Add signature button to quote detail page
  ```dart
  // In quote_detail_page.dart
  GradientButton(
    text: 'Faire signer',
    icon: Icons.edit,
    onPressed: () async {
      // Show client info dialog first
      final clientInfo = await showDialog<Map<String, String>>(
        context: context,
        builder: (context) => ClientInfoDialog(),
      );

      if (clientInfo == null) return;

      // Show signature pad
      final signatureBytes = await showDialog<Uint8List>(
        context: context,
        builder: (context) => SignatureCaptureDialog(
          documentType: 'quote',
          documentTitle: quote['title'],
        ),
      );

      if (signatureBytes == null) return;

      // Upload and save
      setState(() => _isProcessing = true);

      final signatureUrl = await SignatureService.uploadSignature(
        signatureBytes: signatureBytes,
        documentType: 'quote',
        documentId: quote['id'],
      );

      await SignatureService.saveQuoteSignature(
        quoteId: quote['id'],
        signatureUrl: signatureUrl,
        clientName: clientInfo['name']!,
        clientEmail: clientInfo['email'],
      );

      setState(() => _isProcessing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Devis signé avec succès !')),
      );

      // Optionally auto-convert to invoice
      _showConvertToInvoiceDialog();
    },
  )
  ```

- [ ] Show signature on PDF export
  ```dart
  // In pdf_generator.dart
  if (quote['signature_url'] != null) {
    // Download signature image
    final signatureResponse = await http.get(Uri.parse(quote['signature_url']));
    final signatureImage = pw.MemoryImage(signatureResponse.bodyBytes);

    // Add to PDF
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          children: [
            // ... existing quote content ...

            pw.SizedBox(height: 40),

            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Signé par:'),
                    pw.Text(quote['signed_by_name'], style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('Le: ${formatDate(quote['signed_at'])}'),
                  ],
                ),

                pw.Container(
                  width: 150,
                  height: 75,
                  child: pw.Image(signatureImage),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  ```

- [ ] Add signature to email notifications
- [ ] Implement signature verification (timestamp, IP, device info)

**Estimated Time:** 5 days
**Dependencies:** Signature widget
**Success Criteria:** Quotes can be signed on-site, signature appears on PDF

---

### 3.1.3 Advanced: Yousign API Integration (Optional)

**For full legal compliance:**

**Tasks:**
- [ ] Sign up for Yousign account
- [ ] Add yousign SDK
- [ ] Create Yousign signature request flow
- [ ] Handle webhook callbacks
- [ ] Store Yousign signature metadata

**Estimated Time:** 3 days (if needed)
**Dependencies:** Yousign account
**Success Criteria:** Legally compliant electronic signatures

---

<a name="phase-3-recurring"></a>
## 3.2 RECURRING INVOICES (8 days) 🔴

### Competitive Context
- **Competitors with this:** Henrri VIP, Facture.net, Sellsy
- **User Need:** Maintenance contracts, monthly retainers
- **Market Standard:** Expected feature for subscription businesses

### 3.2.1 Database Schema for Recurring Invoices

**Tasks:**
- [ ] Create recurring_invoices table
  ```sql
  CREATE TABLE recurring_invoices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) NOT NULL,
    client_id UUID REFERENCES clients(id) NOT NULL,
    template_invoice_id UUID REFERENCES invoices(id),  -- Original invoice used as template

    -- Recurrence settings
    frequency TEXT NOT NULL CHECK (frequency IN ('daily', 'weekly', 'monthly', 'quarterly', 'yearly')),
    interval INTEGER DEFAULT 1,  -- Every X [frequency]
    start_date DATE NOT NULL,
    end_date DATE,  -- NULL = no end date
    max_occurrences INTEGER,  -- Alternative to end_date

    -- Invoice template data
    title TEXT NOT NULL,
    items JSONB NOT NULL,
    notes TEXT,
    terms TEXT,

    -- Generation settings
    generate_days_before INTEGER DEFAULT 0,  -- Generate X days before due date
    send_automatically BOOLEAN DEFAULT false,

    -- Status
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'paused', 'completed', 'cancelled')),
    next_generation_date DATE,
    last_generated_at TIMESTAMP WITH TIME ZONE,
    occurrences_generated INTEGER DEFAULT 0,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
  );

  CREATE INDEX idx_recurring_invoices_user_id ON recurring_invoices(user_id);
  CREATE INDEX idx_recurring_invoices_client_id ON recurring_invoices(client_id);
  CREATE INDEX idx_recurring_invoices_next_generation ON recurring_invoices(next_generation_date);

  ALTER TABLE recurring_invoices ENABLE ROW LEVEL SECURITY;

  CREATE POLICY "Users can manage own recurring invoices"
    ON recurring_invoices FOR ALL
    USING (auth.uid() = user_id);

  -- Track relationship between recurring and generated invoices
  CREATE TABLE recurring_invoice_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    recurring_invoice_id UUID REFERENCES recurring_invoices(id) ON DELETE CASCADE,
    invoice_id UUID REFERENCES invoices(id) ON DELETE SET NULL,
    generated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    status TEXT
  );
  ```

- [ ] Add recurring flag to invoices table
  ```sql
  ALTER TABLE invoices ADD COLUMN is_recurring BOOLEAN DEFAULT false;
  ALTER TABLE invoices ADD COLUMN recurring_invoice_id UUID REFERENCES recurring_invoices(id);
  ```

**Estimated Time:** 1 day
**Dependencies:** None
**Success Criteria:** Database schema supports recurring invoices

---

### 3.2.2 Recurring Invoice Setup UI

**Tasks:**
- [ ] Create recurring invoice form screen
  ```dart
  // lib/screens/invoices/recurring_invoice_form_page.dart
  class RecurringInvoiceFormPage extends ConsumerStatefulWidget {
    final String? recurringInvoiceId;  // For editing

    @override
    _RecurringInvoiceFormPageState createState() => _RecurringInvoiceFormPageState();
  }

  class _RecurringInvoiceFormPageState extends ConsumerState<RecurringInvoiceFormPage> {
    String? _selectedClientId;
    String _frequency = 'monthly';
    int _interval = 1;
    DateTime _startDate = DateTime.now();
    DateTime? _endDate;
    int? _maxOccurrences;
    bool _sendAutomatically = false;
    List<Map<String, dynamic>> _items = [];

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Facture récurrente'),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(Spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Client selection
              Text('Client', style: PlombiProTextStyles.heading3),
              SizedBox(height: Spacing.sm),
              ClientDropdown(
                value: _selectedClientId,
                onChanged: (clientId) => setState(() => _selectedClientId = clientId),
              ),

              SizedBox(height: Spacing.lg),

              // Frequency settings
              Text('Fréquence', style: PlombiProTextStyles.heading3),
              SizedBox(height: Spacing.sm),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _frequency,
                      decoration: InputDecoration(
                        labelText: 'Récurrence',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(value: 'daily', child: Text('Quotidien')),
                        DropdownMenuItem(value: 'weekly', child: Text('Hebdomadaire')),
                        DropdownMenuItem(value: 'monthly', child: Text('Mensuel')),
                        DropdownMenuItem(value: 'quarterly', child: Text('Trimestriel')),
                        DropdownMenuItem(value: 'yearly', child: Text('Annuel')),
                      ],
                      onChanged: (value) => setState(() => _frequency = value!),
                    ),
                  ),

                  SizedBox(width: Spacing.md),

                  SizedBox(
                    width: 100,
                    child: TextFormField(
                      initialValue: _interval.toString(),
                      decoration: InputDecoration(
                        labelText: 'Tous les',
                        suffix: Text(_getFrequencySuffix()),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => setState(() => _interval = int.tryParse(value) ?? 1),
                    ),
                  ),
                ],
              ),

              SizedBox(height: Spacing.lg),

              // Date range
              Text('Période', style: PlombiProTextStyles.heading3),
              SizedBox(height: Spacing.sm),

              Row(
                children: [
                  Expanded(
                    child: DateField(
                      label: 'Date de début',
                      value: _startDate,
                      onChanged: (date) => setState(() => _startDate = date),
                    ),
                  ),

                  SizedBox(width: Spacing.md),

                  Expanded(
                    child: DateField(
                      label: 'Date de fin (optionnel)',
                      value: _endDate,
                      onChanged: (date) => setState(() => _endDate = date),
                    ),
                  ),
                ],
              ),

              SizedBox(height: Spacing.md),

              // Or max occurrences
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Nombre maximum de factures (optionnel)',
                  hintText: 'Laisser vide pour illimité',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => setState(() => _maxOccurrences = int.tryParse(value)),
              ),

              SizedBox(height: Spacing.lg),

              // Items (reuse invoice item form)
              Text('Articles', style: PlombiProTextStyles.heading3),
              SizedBox(height: Spacing.sm),

              InvoiceItemsList(
                items: _items,
                onItemsChanged: (items) => setState(() => _items = items),
              ),

              SizedBox(height: Spacing.lg),

              // Auto-send option
              SwitchListTile(
                title: Text('Envoyer automatiquement'),
                subtitle: Text('Les factures seront envoyées par email automatiquement'),
                value: _sendAutomatically,
                onChanged: (value) => setState(() => _sendAutomatically = value),
              ),

              SizedBox(height: Spacing.xl),

              // Preview next 3 invoices
              Container(
                padding: EdgeInsets.all(Spacing.md),
                decoration: BoxDecoration(
                  color: PlombiProColors.primaryLight.withOpacity(0.1),
                  borderRadius: BorderRadii.circularMedium,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: PlombiProColors.primary),
                        SizedBox(width: Spacing.sm),
                        Text('Prochaines factures', style: PlombiProTextStyles.bodyBold),
                      ],
                    ),
                    SizedBox(height: Spacing.sm),
                    ..._getPreviewDates().map((date) => Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Text('• ${formatDate(date)}'),
                    )),
                  ],
                ),
              ),

              SizedBox(height: Spacing.xl),

              // Save button
              GradientButton(
                text: 'Créer la récurrence',
                icon: Icons.repeat,
                onPressed: _saveRecurringInvoice,
                width: double.infinity,
              ),
            ],
          ),
        ),
      );
    }

    String _getFrequencySuffix() {
      switch (_frequency) {
        case 'daily': return 'jour(s)';
        case 'weekly': return 'semaine(s)';
        case 'monthly': return 'mois';
        case 'quarterly': return 'trimestre(s)';
        case 'yearly': return 'an(s)';
        default: return '';
      }
    }

    List<DateTime> _getPreviewDates() {
      List<DateTime> dates = [];
      DateTime current = _startDate;

      for (int i = 0; i < 3; i++) {
        dates.add(current);
        current = _calculateNextDate(current);

        if (_endDate != null && current.isAfter(_endDate!)) break;
        if (_maxOccurrences != null && i >= _maxOccurrences! - 1) break;
      }

      return dates;
    }

    DateTime _calculateNextDate(DateTime from) {
      switch (_frequency) {
        case 'daily':
          return from.add(Duration(days: _interval));
        case 'weekly':
          return from.add(Duration(days: _interval * 7));
        case 'monthly':
          return DateTime(from.year, from.month + _interval, from.day);
        case 'quarterly':
          return DateTime(from.year, from.month + (_interval * 3), from.day);
        case 'yearly':
          return DateTime(from.year + _interval, from.month, from.day);
        default:
          return from;
      }
    }

    Future<void> _saveRecurringInvoice() async {
      // Validation
      if (_selectedClientId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veuillez sélectionner un client')),
        );
        return;
      }

      if (_items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veuillez ajouter au moins un article')),
        );
        return;
      }

      // Save to database
      await ref.read(recurringInvoiceProvider.notifier).create({
        'client_id': _selectedClientId,
        'frequency': _frequency,
        'interval': _interval,
        'start_date': _startDate.toIso8601String(),
        'end_date': _endDate?.toIso8601String(),
        'max_occurrences': _maxOccurrences,
        'items': _items,
        'send_automatically': _sendAutomatically,
        'next_generation_date': _startDate.toIso8601String(),
      });

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Facture récurrente créée !')),
      );
    }
  }
  ```

**Estimated Time:** 3 days
**Dependencies:** Database schema
**Success Criteria:** Users can create recurring invoice schedules

---

### 3.2.3 Automated Invoice Generation (Cloud Function)

**Tasks:**
- [ ] Create cloud function for invoice generation
  ```python
  # cloud_functions/recurring_invoice_generator/main.py
  from google.cloud import firestore
  from datetime import datetime, timedelta
  import functions_framework

  @functions_framework.http
  def generate_recurring_invoices(request):
      """
      Runs daily via Cloud Scheduler.
      Generates invoices for all recurring invoices due today.
      """

      supabase = create_supabase_client()

      # Find recurring invoices due for generation today
      today = datetime.now().date()

      recurring_invoices = supabase.table('recurring_invoices') \\
          .select('*') \\
          .eq('status', 'active') \\
          .lte('next_generation_date', today.isoformat()) \\
          .execute()

      generated_count = 0

      for recurring in recurring_invoices.data:
          try:
              # Generate invoice
              invoice_id = generate_invoice_from_recurring(recurring)

              # Update recurring invoice
              next_date = calculate_next_generation_date(recurring)

              supabase.table('recurring_invoices') \\
                  .update({
                      'next_generation_date': next_date,
                      'last_generated_at': datetime.now().isoformat(),
                      'occurrences_generated': recurring['occurrences_generated'] + 1,
                  }) \\
                  .eq('id', recurring['id']) \\
                  .execute()

              # Add to history
              supabase.table('recurring_invoice_history') \\
                  .insert({
                      'recurring_invoice_id': recurring['id'],
                      'invoice_id': invoice_id,
                      'status': 'generated',
                  }) \\
                  .execute()

              # Send email if auto-send enabled
              if recurring['send_automatically']:
                  send_invoice_email(invoice_id)

              generated_count += 1

          except Exception as e:
              print(f"Error generating invoice for recurring {recurring['id']}: {e}")
              continue

      return {
          'success': True,
          'generated_count': generated_count,
          'timestamp': datetime.now().isoformat(),
      }

  def generate_invoice_from_recurring(recurring):
      """Create an invoice from recurring invoice template"""
      invoice_data = {
          'user_id': recurring['user_id'],
          'client_id': recurring['client_id'],
          'title': f"{recurring['title']} - {datetime.now().strftime('%B %Y')}",
          'items': recurring['items'],
          'notes': recurring['notes'],
          'terms': recurring['terms'],
          'status': 'sent' if recurring['send_automatically'] else 'draft',
          'is_recurring': True,
          'recurring_invoice_id': recurring['id'],
          'issue_date': datetime.now().isoformat(),
          'due_date': (datetime.now() + timedelta(days=30)).isoformat(),
      }

      response = supabase.table('invoices') \\
          .insert(invoice_data) \\
          .execute()

      return response.data[0]['id']

  def calculate_next_generation_date(recurring):
      """Calculate when to generate next invoice"""
      current = datetime.fromisoformat(recurring['next_generation_date'])
      frequency = recurring['frequency']
      interval = recurring['interval']

      if frequency == 'daily':
          next_date = current + timedelta(days=interval)
      elif frequency == 'weekly':
          next_date = current + timedelta(weeks=interval)
      elif frequency == 'monthly':
          next_date = add_months(current, interval)
      elif frequency == 'quarterly':
          next_date = add_months(current, interval * 3)
      elif frequency == 'yearly':
          next_date = add_months(current, interval * 12)

      return next_date.date().isoformat()

  def add_months(date, months):
      """Add months to a date, handling month overflow"""
      month = date.month - 1 + months
      year = date.year + month // 12
      month = month % 12 + 1
      day = min(date.day, [31, 29 if year % 4 == 0 else 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][month - 1])
      return date.replace(year=year, month=month, day=day)
  ```

- [ ] Set up Cloud Scheduler to run daily
  ```bash
  gcloud scheduler jobs create http recurring-invoice-generator \\
    --schedule="0 6 * * *" \\
    --uri="https://us-central1-plombipro.cloudfunctions.net/generate-recurring-invoices" \\
    --http-method=POST \\
    --time-zone="Europe/Paris"
  ```

- [ ] Add notification for generated invoices
- [ ] Create logs/audit trail for generation

**Estimated Time:** 3 days
**Dependencies:** Recurring invoice setup
**Success Criteria:** Invoices generated automatically on schedule

---

### 3.2.4 Recurring Invoice Management UI

**Tasks:**
- [ ] Create recurring invoice list page
  ```dart
  class RecurringInvoiceListPage extends ConsumerWidget {
    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final recurringInvoices = ref.watch(recurringInvoiceListProvider);

      return Scaffold(
        appBar: AppBar(
          title: Text('Factures récurrentes'),
        ),
        body: recurringInvoices.when(
          data: (invoices) => ListView.builder(
            itemCount: invoices.length,
            itemBuilder: (context, index) {
              final recurring = invoices[index];
              return RecurringInvoiceCard(recurring: recurring);
            },
          ),
          loading: () => Center(child: CircularProgressIndicator()),
          error: (error, stack) => ErrorView(error: error),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.go('/invoices/recurring/new'),
          child: Icon(Icons.add),
        ),
      );
    }
  }

  class RecurringInvoiceCard extends StatelessWidget {
    final Map<String, dynamic> recurring;

    @override
    Widget build(BuildContext context) {
      return Card(
        margin: EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm,
        ),
        child: ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: PlombiProColors.primaryGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.repeat, color: Colors.white),
          ),

          title: Text(recurring['title']),

          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 4),
              Text('Tous les ${recurring['interval']} ${_getFrequencyText(recurring['frequency'])}'),
              Text('Prochaine: ${formatDate(recurring['next_generation_date'])}'),
              Text('Générées: ${recurring['occurrences_generated']}'),
            ],
          ),

          trailing: Chip(
            label: Text(
              recurring['status'] == 'active' ? 'Actif' : 'Inactif',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
            backgroundColor: recurring['status'] == 'active'
              ? PlombiProColors.success
              : PlombiProColors.gray400,
          ),

          onTap: () => context.go('/invoices/recurring/${recurring['id']}'),
        ),
      );
    }

    String _getFrequencyText(String frequency) {
      switch (frequency) {
        case 'daily': return 'jour(s)';
        case 'weekly': return 'semaine(s)';
        case 'monthly': return 'mois';
        case 'quarterly': return 'trimestre(s)';
        case 'yearly': return 'an(s)';
        default: return '';
      }
    }
  }
  ```

- [ ] Add pause/resume functionality
- [ ] Add edit recurring invoice
- [ ] Show generation history
- [ ] Add manual generation trigger

**Estimated Time:** 1 day
**Dependencies:** Recurring invoice setup
**Success Criteria:** Users can view and manage recurring invoices

---

## PHASE 3 CONTINUES...

Due to length constraints, I'll provide a summary of remaining Phase 3 sections:

### 3.3 PROGRESS INVOICES (7 days) 🔴
- Database schema for milestone invoicing
- UI for defining work completion percentages
- Automatic calculations (30% upfront, 40% mid, 30% final, etc.)
- Progress tracking on job sites
- French BTP compliance (situations de travaux)

### 3.4 CLIENT PORTAL (10 days) 🔴
- Public web portal for clients
- Unique client login/URL
- View quotes and invoices
- Online quote approval
- Online payment via Stripe
- Mobile-responsive design

### 3.5 BANK RECONCILIATION (10 days) 🟡
- Bank account connection (Bridge API / Plaid)
- Transaction import (CSV fallback)
- Auto-matching payments to invoices
- Reconciliation dashboard
- Cash flow tracking

---

## PHASE 3 SUMMARY

**Duration:** 6 weeks
**Key Deliverables:**
- ✅ Electronic signature (native + Yousign option)
- ✅ Recurring invoices with auto-generation
- ✅ Progress invoices (BTP standard)
- ✅ Client portal for self-service
- ✅ Bank reconciliation for accounting

**Success Metrics:**
- [ ] 100% of quotes can be signed electronically
- [ ] Recurring invoices generate automatically
- [ ] Progress invoicing compliant with French BTP laws
- [ ] Clients can view/approve quotes online
- [ ] Bank transactions auto-match to invoices

---

# PHASES 4-7 SUMMARY

## PHASE 4: OCR & CATALOG OPTIMIZATION (Weeks 11-13)
- Complete OCR implementation with AI
- Point P & Cedeo catalog verification
- Add Leroy Merlin & Castorama catalogs
- Real hydraulic calculator with plumber validation
- Supplier price comparison tool

## PHASE 5: ADVANCED FEATURES (Weeks 14-18)
- Multi-user/team support with roles
- Offline mode with Hive/Isar sync
- Advanced analytics dashboard
- 50+ plumbing templates
- Emergency pricing mode

## PHASE 6: UI/UX TRANSFORMATION (Weeks 19-22)
- Apply website 2.0 design language
- Redesign all major screens
- Add micro-interactions and animations
- Onboarding overhaul with trust signals
- Floating CTAs and urgency elements

## PHASE 7: POLISH & LAUNCH (Weeks 23-26)
- Comprehensive testing suite (unit, widget, integration)
- Performance optimization (60fps animations, <1s loads)
- App Store preparation (screenshots, description, ASO)
- Documentation and help center
- Beta testing with 50 plumbers

---

## TOTAL TIMELINE SUMMARY

| Phase | Duration | Key Focus | Priority |
|-------|----------|-----------|----------|
| Phase 1 | 2 weeks | Critical fixes + design system | 🔴 CRITICAL |
| Phase 2 | 2 weeks | State management + architecture | 🟡 HIGH |
| Phase 3 | 6 weeks | Critical missing features | 🔴 CRITICAL |
| Phase 4 | 3 weeks | OCR & catalogs optimization | 🟡 HIGH |
| Phase 5 | 5 weeks | Advanced features | 🟢 MEDIUM |
| Phase 6 | 4 weeks | UI/UX transformation | 🟡 HIGH |
| Phase 7 | 4 weeks | Polish & launch prep | 🟡 HIGH |

**TOTAL:** 26 weeks (6 months)

---

## SUCCESS CRITERIA

### Technical
- [ ] Zero hardcoded/mock data
- [ ] 95% feature parity with top competitors
- [ ] <1 second list load times (with cache)
- [ ] 60fps animations throughout
- [ ] <0.1% crash rate
- [ ] 95% test coverage on critical paths

### Business
- [ ] All 10 critical features implemented
- [ ] Unique advantages (OCR, catalogs) fully functional
- [ ] Feature parity with Henrri, Batappli, Obat
- [ ] Superior to competitors in plumber-specific features
- [ ] Ready for 1,000+ active users

### User Experience
- [ ] Website 2.0 design language throughout
- [ ] <3 taps to complete common actions
- [ ] Offline-first capability
- [ ] Accessibility compliant (WCAG 2.1)
- [ ] 4.5+ star rating target

---

**END OF COMPREHENSIVE APP OVERHAUL PLAN**

This plan transforms PlombiPro from 65% complete MVP to a market-leading, production-ready mobile application that can compete with and beat established competitors in the French plumber software market.
