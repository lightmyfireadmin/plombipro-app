import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';
import '../models/quote.dart';
import '../models/client.dart';
import '../models/product.dart';
import '../models/line_item.dart';
import '../models/invoice.dart';
import '../models/payment.dart';
import '../models/scan.dart';
import '../models/template.dart';
import '../models/purchase.dart';
import '../models/job_site.dart';
import '../models/job_site_photo.dart';
import '../models/job_site_task.dart';
import '../models/job_site_time_log.dart';
import '../models/job_site_note.dart';
import '../models/category.dart';
import '../models/setting.dart';
import '../models/notification.dart';
import '../models/stripe_subscription.dart';

import '../models/appointment.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  // ===== APPOINTMENTS =====

  static Future<List<Appointment>> fetchUpcomingAppointments() async {
    // Placeholder implementation
    return Future.delayed(const Duration(seconds: 1), () {
      final now = DateTime.now();
      return [
        Appointment(
          id: '1',
          userId: 'user1',
          title: 'Rendez-vous Client A',
          appointmentDate: now.add(const Duration(days: 1)),
          appointmentTime: '09:00:00',
          addressLine1: '123 Rue Example',
          postalCode: '75001',
          city: 'Paris',
          plannedEta: now.add(const Duration(days: 1, hours: 9)),
          createdAt: now,
          updatedAt: now,
        ),
        Appointment(
          id: '2',
          userId: 'user1',
          title: 'Rendez-vous Client B',
          appointmentDate: now.add(const Duration(days: 2)),
          appointmentTime: '14:00:00',
          addressLine1: '456 Avenue Test',
          postalCode: '75002',
          city: 'Paris',
          plannedEta: now.add(const Duration(days: 2, hours: 14)),
          createdAt: now,
          updatedAt: now,
        ),
        Appointment(
          id: '3',
          userId: 'user1',
          title: 'Rendez-vous Client C',
          appointmentDate: now.add(const Duration(days: 3)),
          appointmentTime: '11:00:00',
          addressLine1: '789 Boulevard Demo',
          postalCode: '75003',
          city: 'Paris',
          plannedEta: now.add(const Duration(days: 3, hours: 11)),
          createdAt: now,
          updatedAt: now,
        ),
      ];
    });
  }

  // ===== AUTHENTICATION =====
  
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String companyName,
    required String siret,
    String? phone,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Create profile
        await _client.from('profiles').insert({
          'id': response.user!.id,
          'email': email,
          'full_name': fullName,
          'company_name': companyName,
          'siret': siret,
          'phone': phone,
        });
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  static Future<void> updateUserProfile({
    required String userId,
    String? companyName,
    String? siret,
    String? vatNumber,
    String? iban,
    String? bic,
    String? address,
    String? postalCode,
    String? city,
    String? phone,
    String? fullName,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (companyName != null) updateData['company_name'] = companyName;
      if (siret != null) updateData['siret'] = siret;
      if (vatNumber != null) updateData['vat_number'] = vatNumber;
      if (iban != null) updateData['iban'] = iban;
      if (bic != null) updateData['bic'] = bic;
      if (address != null) updateData['address'] = address;
      if (postalCode != null) updateData['postal_code'] = postalCode;
      if (city != null) updateData['city'] = city;
      if (phone != null) updateData['phone'] = phone;
      if (fullName != null) updateData['full_name'] = fullName;

      if (updateData.isNotEmpty) {
        updateData['updated_at'] = DateTime.now().toIso8601String();
        await _client
            .from('profiles')
            .update(updateData)
            .eq('id', userId);
      }
    } catch (e) {
      rethrow;
    }
  }

  // ===== QUOTES CRUD =====

  static Future<List<Quote>> fetchQuotes() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client
          .from('quotes')
          .select('''
            *,
            quote_items(*),
            clients(name, email)
          ''')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => Quote.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Quote>> fetchQuotesByClient(String clientId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client
          .from('quotes')
          .select('''
            *,
            quote_items(*),
            clients(name, email)
          ''')
          .eq('user_id', user.id)
          .eq('client_id', clientId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => Quote.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<Quote?> fetchQuoteById(String quoteId) async {
    try {
      final response = await _client
          .from('quotes')
          .select('*,line_items(*)')
          .eq('id', quoteId)
          .single();

      return Quote.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  static Future<String> createQuote(Quote quote) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client.from('quotes').insert({
        ...quote.toJson(),
        'user_id': user.id,
      }).select().single();

      return response['id'] as String;
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> updateQuote(String quoteId, Quote quote) async {
    try {
      await _client.from('quotes').update(quote.toJson()).eq('id', quoteId);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteQuote(String quoteId) async {
    try {
      await _client.from('quotes').delete().eq('id', quoteId);
    } catch (e) {
      rethrow;
    }
  }

  // ===== INVOICES CRUD =====

  static Future<List<Invoice>> fetchInvoices() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client
          .from('invoices')
          .select('''
            *,
            line_items(*),
            clients(name, email)
          ''')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => Invoice.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Invoice>> fetchInvoicesByClient(String clientId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client
          .from('invoices')
          .select('''
            *,
            line_items(*),
            clients(name, email)
          ''')
          .eq('user_id', user.id)
          .eq('client_id', clientId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => Invoice.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<String> createInvoice(Invoice invoice) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client.from('invoices').insert({
        ...invoice.toJson(),
        'user_id': user.id,
      }).select().single();

      return response['id'] as String;
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> updateInvoice(String invoiceId, Invoice invoice) async {
    try {
      await _client.from('invoices').update(invoice.toJson()).eq('id', invoiceId);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteInvoice(String invoiceId) async {
    try {
      await _client.from('invoices').delete().eq('id', invoiceId);
    } catch (e) {
      rethrow;
    }
  }

  static Future<Invoice?> getInvoiceById(String invoiceId) async {
    try {
      final response = await _client
          .from('invoices')
          .select('*,line_items(*)')
          .eq('id', invoiceId)
          .single();

      return Invoice.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // ===== LINE ITEMS CRUD =====

  static Future<void> createLineItems(String quoteId, List<LineItem> items) async {
    try {
      for (var item in items) {
        await _client.from('quote_items').insert({
          'quote_id': quoteId,
          ...item.toJson(),
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> createInvoiceLineItems(String invoiceId, List<LineItem> items) async {
    try {
      final itemMaps = items.map((item) => {
        'invoice_id': invoiceId,
        ...item.toJson(),
      }).toList();
      await _client.from('invoice_items').insert(itemMaps);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteLineItem(String itemId) async {
    try {
      await _client.from('quote_items').delete().eq('id', itemId);
    } catch (e) {
      rethrow;
    }
  }

  // ===== CLIENTS CRUD =====

  static Future<List<Client>> fetchClients() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client
          .from('clients')
          .select('*')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => Client.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<String> createClient(Client client) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client.from('clients').insert({
        ...client.toJson(),
        'user_id': user.id,
      }).select().single();

      return response['id'] as String;
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> updateClient(String clientId, Client client) async {
    try {
      await _client.from('clients').update(client.toJson()).eq('id', clientId);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteClient(String clientId) async {
    try {
      await _client.from('clients').delete().eq('id', clientId);
    } catch (e) {
      rethrow;
    }
  }

  static Future<Client?> getClientById(String clientId) async {
    try {
      final response = await _client
          .from('clients')
          .select('*')
          .eq('id', clientId)
          .single();
      return Client.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // ===== PRODUCTS CRUD =====

  static Future<List<Product>> fetchProducts({String? category, bool? isFavorite, String? source}) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      var query = _client
          .from('products')
          .select('*')
          .eq('user_id', user.id);

      if (category != null) {
        query = query.eq('category', category);
      }

      if (isFavorite != null && isFavorite) {
        query = query.eq('is_favorite', true);
      }

      if (source != null) {
        query = query.eq('source', source);
      }

      final response = await query.order('created_at', ascending: false);

      return (response as List)
          .map((item) => Product.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<String> createProduct(Product product) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client.from('products').insert({
        ...product.toJson(),
        'user_id': user.id,
      }).select().single();

      return response['id'] as String;
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> updateProduct(String productId, Product product) async {
    try {
      await _client.from('products').update(product.toJson()).eq('id', productId);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteProduct(String productId) async {
    try {
      await _client.from('products').delete().eq('id', productId);
    } catch (e) {
      rethrow;
    }
  }

  static Future<Product?> getProductById(String productId) async {
    try {
      final response = await _client
          .from('products')
          .select('*')
          .eq('id', productId)
          .single();
      return Product.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // ===== PAYMENTS CRUD =====

  static Future<String> recordPayment(Payment payment) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client.from('payments').insert({
        ...payment.toJson(),
        'user_id': user.id,
      }).select().single();

      return response['id'] as String;
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Payment>> getPayments() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client
          .from('payments')
          .select('*')
          .eq('user_id', user.id)
          .order('payment_date', ascending: false);

      return (response as List)
          .map((item) => Payment.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Payment>> getPaymentsForInvoice(String invoiceId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client
          .from('payments')
          .select('*')
          .eq('user_id', user.id)
          .eq('invoice_id', invoiceId)
          .order('payment_date', ascending: false);

      return (response as List)
          .map((item) => Payment.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<Payment?> getPaymentById(String paymentId) async {
    try {
      final response = await _client
          .from('payments')
          .select('*')
          .eq('id', paymentId)
          .single();
      return Payment.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  static Future<void> updatePayment(String paymentId, Payment payment) async {
    try {
      await _client.from('payments').update(payment.toJson()).eq('id', paymentId);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deletePayment(String paymentId) async {
    try {
      await _client.from('payments').delete().eq('id', paymentId);
    } catch (e) {
      rethrow;
    }
  }

  // ===== PURCHASES CRUD =====

  static Future<String> addPurchase(Purchase purchase) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client.from('purchases').insert({
        ...purchase.toJson(),
        'user_id': user.id,
      }).select().single();

      return response['id'] as String;
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Purchase>> getPurchases() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client
          .from('purchases')
          .select('*')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => Purchase.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<Purchase?> getPurchaseById(String purchaseId) async {
    try {
      final response = await _client
          .from('purchases')
          .select('*')
          .eq('id', purchaseId)
          .single();
      return Purchase.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  static Future<void> updatePurchase(String purchaseId, Purchase purchase) async {
    try {
      await _client.from('purchases').update(purchase.toJson()).eq('id', purchaseId);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deletePurchase(String purchaseId) async {
    try {
      await _client.from('purchases').delete().eq('id', purchaseId);
    } catch (e) {
      rethrow;
    }
  }

  // ===== SCANS CRUD =====

  static Future<String> addScan(Scan scan) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client.from('scans').insert({
        ...scan.toJson(),
        'user_id': user.id,
      }).select().single();

      return response['id'] as String;
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Scan>> getScanHistory() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client
          .from('scans')
          .select('*')
          .eq('user_id', user.id)
          .order('scan_date', ascending: false);

      return (response as List)
          .map((item) => Scan.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<Scan?> getScanById(String scanId) async {
    try {
      final response = await _client
          .from('scans')
          .select('*')
          .eq('id', scanId)
          .single();
      return Scan.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  static Future<void> updateScan(String scanId, Scan scan) async {
    try {
      await _client.from('scans').update(scan.toJson()).eq('id', scanId);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteScan(String scanId) async {
    try {
      await _client.from('scans').delete().eq('id', scanId);
    } catch (e) {
      rethrow;
    }
  }

  // ===== TEMPLATES CRUD =====

  static Future<String> saveTemplate(Template template) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client.from('templates').insert({
        ...template.toJson(),
        'user_id': user.id,
      }).select().single();

      return response['id'] as String;
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Template>> getTemplates() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client
          .from('templates')
          .select('*')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => Template.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<Template?> getTemplateById(String templateId) async {
    try {
      final response = await _client
          .from('templates')
          .select('*')
          .eq('id', templateId)
          .single();
      return Template.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  static Future<void> updateTemplate(String templateId, Template template) async {
    try {
      await _client.from('templates').update(template.toJson()).eq('id', templateId);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteTemplate(String templateId) async {
    try {
      await _client.from('templates').delete().eq('id', templateId);
    } catch (e) {
      rethrow;
    }
  }

  // ===== JOB SITES CRUD =====

  static Future<String> addJobSite(JobSite jobSite) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client.from('job_sites').insert({
        ...jobSite.toJson(),
        'user_id': user.id,
      }).select().single();

      return response['id'] as String;
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<JobSite>> getJobSites() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client
          .from('job_sites')
          .select('*')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => JobSite.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<JobSite?> getJobSiteById(String jobSiteId) async {
    try {
      final response = await _client
          .from('job_sites')
          .select('*')
          .eq('id', jobSiteId)
          .single();
      return JobSite.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  static Future<void> updateJobSite(String jobSiteId, JobSite jobSite) async {
    try {
      await _client.from('job_sites').update(jobSite.toJson()).eq('id', jobSiteId);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteJobSite(String jobSiteId) async {
    try {
      await _client.from('job_sites').delete().eq('id', jobSiteId);
    } catch (e) {
      rethrow;
    }
  }

  // ===== JOB SITE PHOTOS CRUD =====

  static Future<String> addJobSitePhoto(JobSitePhoto photo) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Verify user owns the job site before adding photo
      final jobSite = await _client.from('job_sites').select('user_id').eq('id', photo.jobSiteId).single();
      if (jobSite['user_id'] != user.id) {
        throw Exception('User does not own this job site');
      }

      final response = await _client.from('job_site_photos').insert({
        ...photo.toJson(),
      }).select().single();

      return response['id'] as String;
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<JobSitePhoto>> getJobSitePhotosForJobSite(String jobSiteId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Verify user owns the job site
      final jobSite = await _client.from('job_sites').select('user_id').eq('id', jobSiteId).single();
      if (jobSite['user_id'] != user.id) {
        throw Exception('User does not own this job site');
      }

      final response = await _client
          .from('job_site_photos')
          .select('*')
          .eq('job_site_id', jobSiteId)
          .order('uploaded_at', ascending: false);

      return (response as List)
          .map((item) => JobSitePhoto.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteJobSitePhoto(String photoId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Verify user owns the photo's job site
      final photo = await _client.from('job_site_photos').select('job_site_id').eq('id', photoId).single();
      final jobSite = await _client.from('job_sites').select('user_id').eq('id', photo['job_site_id']).single();
      if (jobSite['user_id'] != user.id) {
        throw Exception('User does not own this photo');
      }

      await _client.from('job_site_photos').delete().eq('id', photoId);
    } catch (e) {
      rethrow;
    }
  }

  // ===== JOB SITE TASKS CRUD =====

  static Future<String> addTaskToJobSite(JobSiteTask task) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Verify user owns the job site before adding task
      final jobSite = await _client.from('job_sites').select('user_id').eq('id', task.jobSiteId).single();
      if (jobSite['user_id'] != user.id) {
        throw Exception('User does not own this job site');
      }

      final response = await _client.from('job_site_tasks').insert({
        ...task.toJson(),
      }).select().single();

      return response['id'] as String;
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<JobSiteTask>> getTasksForJobSite(String jobSiteId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Verify user owns the job site
      final jobSite = await _client.from('job_sites').select('user_id').eq('id', jobSiteId).single();
      if (jobSite['user_id'] != user.id) {
        throw Exception('User does not own this job site');
      }

      final response = await _client
          .from('job_site_tasks')
          .select('*')
          .eq('job_site_id', jobSiteId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => JobSiteTask.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> updateJobSiteTask(String taskId, JobSiteTask task) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Verify user owns the task's job site
      final existingTask = await _client.from('job_site_tasks').select('job_site_id').eq('id', taskId).single();
      final jobSite = await _client.from('job_sites').select('user_id').eq('id', existingTask['job_site_id']).single();
      if (jobSite['user_id'] != user.id) {
        throw Exception('User does not own this task');
      }

      await _client.from('job_site_tasks').update(task.toJson()).eq('id', taskId);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteJobSiteTask(String taskId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Verify user owns the task's job site
      final existingTask = await _client.from('job_site_tasks').select('job_site_id').eq('id', taskId).single();
      final jobSite = await _client.from('job_sites').select('user_id').eq('id', existingTask['job_site_id']).single();
      if (jobSite['user_id'] != user.id) {
        throw Exception('User does not own this task');
      }

      await _client.from('job_site_tasks').delete().eq('id', taskId);
    } catch (e) {
      rethrow;
    }
  }

  // ===== JOB SITE TIME LOGS CRUD =====

  static Future<String> addTimeLogToJobSite(JobSiteTimeLog timeLog) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Verify user owns the job site before adding time log
      final jobSite = await _client.from('job_sites').select('user_id').eq('id', timeLog.jobSiteId).single();
      if (jobSite['user_id'] != user.id) {
        throw Exception('User does not own this job site');
      }

      final response = await _client.from('job_site_time_logs').insert({
        ...timeLog.toJson(),
        'user_id': user.id, // Ensure user_id is set for RLS
      }).select().single();

      return response['id'] as String;
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<JobSiteTimeLog>> getTimeLogsForJobSite(String jobSiteId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Verify user owns the job site
      final jobSite = await _client.from('job_sites').select('user_id').eq('id', jobSiteId).single();
      if (jobSite['user_id'] != user.id) {
        throw Exception('User does not own this job site');
      }

      final response = await _client
          .from('job_site_time_logs')
          .select('*')
          .eq('user_id', user.id) // RLS check
          .eq('job_site_id', jobSiteId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => JobSiteTimeLog.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> updateJobSiteTimeLog(String timeLogId, JobSiteTimeLog timeLog) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Verify user owns the time log's job site
      final existingTimeLog = await _client.from('job_site_time_logs').select('job_site_id, user_id').eq('id', timeLogId).single();
      if (existingTimeLog['user_id'] != user.id) {
        throw Exception('User does not own this time log');
      }

      await _client.from('job_site_time_logs').update(timeLog.toJson()).eq('id', timeLogId);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteJobSiteTimeLog(String timeLogId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Verify user owns the time log's job site
      final existingTimeLog = await _client.from('job_site_time_logs').select('job_site_id, user_id').eq('id', timeLogId).single();
      if (existingTimeLog['user_id'] != user.id) {
        throw Exception('User does not own this time log');
      }

      await _client.from('job_site_time_logs').delete().eq('id', timeLogId);
    } catch (e) {
      rethrow;
    }
  }

  // ===== JOB SITE NOTES CRUD =====

  static Future<String> addNoteToJobSite(JobSiteNote note) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Verify user owns the job site before adding note
      final jobSite = await _client.from('job_sites').select('user_id').eq('id', note.jobSiteId).single();
      if (jobSite['user_id'] != user.id) {
        throw Exception('User does not own this job site');
      }

      final response = await _client.from('job_site_notes').insert({
        ...note.toJson(),
        'user_id': user.id, // Ensure user_id is set for RLS
      }).select().single();

      return response['id'] as String;
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<JobSiteNote>> getNotesForJobSite(String jobSiteId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Verify user owns the job site
      final jobSite = await _client.from('job_sites').select('user_id').eq('id', jobSiteId).single();
      if (jobSite['user_id'] != user.id) {
        throw Exception('User does not own this job site');
      }

      final response = await _client
          .from('job_site_notes')
          .select('*')
          .eq('user_id', user.id) // RLS check
          .eq('job_site_id', jobSiteId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => JobSiteNote.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> updateJobSiteNote(String noteId, JobSiteNote note) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Verify user owns the note's job site
      final existingNote = await _client.from('job_site_notes').select('job_site_id, user_id').eq('id', noteId).single();
      if (existingNote['user_id'] != user.id) {
        throw Exception('User does not own this note');
      }

      await _client.from('job_site_notes').update(note.toJson()).eq('id', noteId);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteJobSiteNote(String noteId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Verify user owns the note's job site
      final existingNote = await _client.from('job_site_notes').select('job_site_id, user_id').eq('id', noteId).single();
      if (existingNote['user_id'] != user.id) {
        throw Exception('User does not own this note');
      }

      await _client.from('job_site_notes').delete().eq('id', noteId);
    } catch (e) {
      rethrow;
    }
  }

  // ===== CATEGORIES CRUD =====

  static Future<String> addCategory(Category category) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client.from('categories').insert({
        ...category.toJson(),
        'user_id': user.id,
      }).select().single();

      return response['id'] as String;
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Category>> getCategories() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client
          .from('categories')
          .select('*')
          .eq('user_id', user.id)
          .order('category_name', ascending: true);

      return (response as List)
          .map((item) => Category.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> updateCategory(String categoryId, Category category) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Verify user owns the category
      final existingCategory = await _client.from('categories').select('user_id').eq('id', categoryId).single();
      if (existingCategory['user_id'] != user.id) {
        throw Exception('User does not own this category');
      }

      await _client.from('categories').update(category.toJson()).eq('id', categoryId);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteCategory(String categoryId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Verify user owns the category
      final existingCategory = await _client.from('categories').select('user_id').eq('id', categoryId).single();
      if (existingCategory['user_id'] != user.id) {
        throw Exception('User does not own this category');
      }

      await _client.from('categories').delete().eq('id', categoryId);
    } catch (e) {
      rethrow;
    }
  }

  // ===== SETTINGS CRUD =====

  static Future<Setting?> getUserSettings() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client
          .from('settings')
          .select('*')
          .eq('user_id', user.id)
          .single();

      return Setting.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  static Future<void> updateUserSettings(Setting settings) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _client.from('settings').update(settings.toJson()).eq('user_id', user.id);
    } catch (e) {
      rethrow;
    }
  }

  static Future<String> createUserSettings(Setting settings) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client.from('settings').insert({
        ...settings.toJson(),
        'user_id': user.id,
      }).select().single();

      return response['id'] as String;
    } catch (e) {
      rethrow;
    }
  }

  // ===== NOTIFICATIONS CRUD =====

  static Future<String> addNotification(Notification notification) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client.from('notifications').insert({
        ...notification.toJson(),
        'user_id': user.id,
      }).select().single();

      return response['id'] as String;
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Notification>> getNotifications() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client
          .from('notifications')
          .select('*')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => Notification.fromJson(item))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> markNotificationAsRead(String notificationId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Verify user owns the notification
      final existingNotification = await _client.from('notifications').select('user_id').eq('id', notificationId).single();
      if (existingNotification['user_id'] != user.id) {
        throw Exception('User does not own this notification');
      }

      await _client.from('notifications').update({'is_read': true}).eq('id', notificationId);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteNotification(String notificationId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Verify user owns the notification
      final existingNotification = await _client.from('notifications').select('user_id').eq('id', notificationId).single();
      if (existingNotification['user_id'] != user.id) {
        throw Exception('User does not own this notification');
      }

      await _client.from('notifications').delete().eq('id', notificationId);
    } catch (e) {
      rethrow;
    }
  }

  // ===== STRIPE SUBSCRIPTIONS CRUD =====

  static Future<String> createStripeSubscription(StripeSubscription subscription) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client.from('stripe_subscriptions').insert({
        ...subscription.toJson(),
        'user_id': user.id,
      }).select().single();

      return response['id'] as String;
    } catch (e) {
      rethrow;
    }
  }

  static Future<StripeSubscription?> getStripeSubscription() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client
          .from('stripe_subscriptions')
          .select('*')
          .eq('user_id', user.id)
          .single();

      return StripeSubscription.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  static Future<void> updateStripeSubscription(String subscriptionId, StripeSubscription subscription) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Verify user owns the subscription
      final existingSubscription = await _client.from('stripe_subscriptions').select('user_id').eq('id', subscriptionId).single();
      if (existingSubscription['user_id'] != user.id) {
        throw Exception('User does not own this subscription');
      }

      await _client.from('stripe_subscriptions').update(subscription.toJson()).eq('id', subscriptionId);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteStripeSubscription(String subscriptionId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Verify user owns the subscription
      final existingSubscription = await _client.from('stripe_subscriptions').select('user_id').eq('id', subscriptionId).single();
      if (existingSubscription['user_id'] != user.id) {
        throw Exception('User does not own this subscription');
      }

      await _client.from('stripe_subscriptions').delete().eq('id', subscriptionId);
    } catch (e) {
      rethrow;
    }
  }

  // ===== REAL-TIME SUBSCRIPTIONS =====

  static Stream<List<Quote>> streamQuotes() {
    final user = _client.auth.currentUser;
    if (user == null) return const Stream.empty();

    return _client
        .from('quotes')
        .stream(primaryKey: ['id'])
        .eq('user_id', user.id)
        .map((items) => (items as List)
            .map((item) => Quote.fromJson(item as Map<String, dynamic>))
            .toList());
  }

  static Future<Profile?> fetchUserProfile() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final response = await _client
          .from('profiles')
          .select('*')
          .eq('id', user.id)
          .single();

      return Profile.fromJson(response);
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  static Future<void> updateProfile(Profile profile) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _client.from('profiles').update(profile.toJson()).eq('id', user.id);
    } catch (e) {
      rethrow;
    }
  }
}