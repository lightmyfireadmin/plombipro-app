import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../screens/splash/splash_page.dart';
import '../screens/auth/login_page.dart';
import '../screens/auth/register_page.dart';
import '../screens/auth/forgot_password_page.dart';
import '../screens/auth/reset_password_page.dart';
import '../screens/home/home_page.dart';
import '../screens/quotes/quotes_list_page.dart';
import '../screens/quotes/quote_form_page.dart';
import '../screens/clients/clients_list_page.dart';
import '../screens/clients/client_form_page.dart';
import '../screens/invoices/invoices_list_page.dart';
import '../screens/invoices/invoice_form_page.dart';
import '../screens/products/products_list_page.dart';
import '../screens/products/product_form_page.dart';
import '../screens/ocr/scan_invoice_page.dart';
import '../screens/payments/payments_list_page.dart';
import '../screens/payments/payment_form_page.dart';
import '../screens/profile/user_profile_page.dart';
import '../screens/company/company_profile_page.dart';
import '../screens/settings/settings_page.dart';
import '../screens/settings/invoice_settings_page.dart';

import '../screens/products/catalogs_overview_page.dart';
import '../screens/products/scraped_catalog_page.dart';
import '../screens/products/favorite_products_page.dart';
import '../screens/products/category_management_page.dart';

import '../screens/tools/hydraulic_calculator_page.dart';
import '../screens/tools/supplier_comparator_page.dart';
import '../screens/settings/backup_export_page.dart';
import '../screens/clients/import_clients_page.dart';

import '../screens/job_sites/job_sites_list_page.dart';
import '../screens/job_sites/job_site_form_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return const SplashPage();
        },
      ),
      GoRoute(
        path: '/login',
        builder: (BuildContext context, GoRouterState state) {
          return const LoginPage();
        },
      ),
      GoRoute(
        path: '/register',
        builder: (BuildContext context, GoRouterState state) {
          return const RegisterPage();
        },
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (BuildContext context, GoRouterState state) {
          return const ForgotPasswordPage();
        },
      ),
      GoRoute(
        path: '/reset-password',
        builder: (BuildContext context, GoRouterState state) {
          return const ResetPasswordPage();
        },
      ),
      GoRoute(
        path: '/home',
        builder: (BuildContext context, GoRouterState state) {
          return const HomePage();
        },
      ),
      GoRoute(
        path: '/quotes',
        builder: (BuildContext context, GoRouterState state) {
          return const QuotesListPage();
        },
        routes: [
          GoRoute(
            path: 'new',
            builder: (BuildContext context, GoRouterState state) {
              return const QuoteFormPage();
            },
          ),
          GoRoute(
            path: ':id',
            builder: (BuildContext context, GoRouterState state) {
              final quoteId = state.pathParameters['id']!;
              return QuoteFormPage(quoteId: quoteId); 
            },
          ),
        ],
      ),
      GoRoute(
        path: '/clients',
        builder: (BuildContext context, GoRouterState state) {
          return const ClientsListPage();
        },
        routes: [
          GoRoute(
            path: 'new',
            builder: (BuildContext context, GoRouterState state) {
              return const ClientFormPage();
            },
          ),
          GoRoute(
            path: ':id',
            builder: (BuildContext context, GoRouterState state) {
              final clientId = state.pathParameters['id']!;
              return ClientFormPage(clientId: clientId); 
            },
          ),
        ],
      ),
      GoRoute(
        path: '/invoices',
        builder: (BuildContext context, GoRouterState state) {
          return const InvoicesListPage();
        },
        routes: [
          GoRoute(
            path: 'new',
            builder: (BuildContext context, GoRouterState state) {
              return const InvoiceFormPage();
            },
          ),
          GoRoute(
            path: ':id',
            builder: (BuildContext context, GoRouterState state) {
              final invoiceId = state.pathParameters['id']!;
              return InvoiceFormPage(invoiceId: invoiceId); 
            },
          ),
        ],
      ),
      GoRoute(
        path: '/products',
        builder: (BuildContext context, GoRouterState state) {
          return const ProductsListPage();
        },
        routes: [
          GoRoute(
            path: 'new',
            builder: (BuildContext context, GoRouterState state) {
              return const ProductFormPage();
            },
          ),
          GoRoute(
            path: ':id',
            builder: (BuildContext context, GoRouterState state) {
              final productId = state.pathParameters['id']!;
              return ProductFormPage(productId: productId); 
            },
          ),
        ],
      ),
      GoRoute(
        path: '/scan-invoice',
        builder: (BuildContext context, GoRouterState state) {
          return const ScanInvoicePage();
        },
      ),
      GoRoute(
        path: '/payments',
        builder: (BuildContext context, GoRouterState state) {
          return const PaymentsListPage();
        },
        routes: [
          GoRoute(
            path: 'new',
            builder: (BuildContext context, GoRouterState state) {
              final invoiceId = state.extra as String?; // Expect invoiceId if coming from invoice
              return PaymentFormPage(invoiceId: invoiceId);
            },
          ),
          GoRoute(
            path: ':id',
            builder: (BuildContext context, GoRouterState state) {
              final paymentId = state.pathParameters['id']!;
              return PaymentFormPage(paymentId: paymentId); 
            },
          ),
        ],
      ),
      GoRoute(
        path: '/profile',
        builder: (BuildContext context, GoRouterState state) {
          return const UserProfilePage();
        },
      ),
      GoRoute(
        path: '/company-profile',
        builder: (BuildContext context, GoRouterState state) {
          return const CompanyProfilePage();
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (BuildContext context, GoRouterState state) {
          return const SettingsPage();
        },
      ),
      GoRoute(
        path: '/invoice-settings',
        builder: (BuildContext context, GoRouterState state) {
          return const InvoiceSettingsPage();
        },
      ),
      GoRoute(
        path: '/catalogs',
        builder: (BuildContext context, GoRouterState state) {
          return const CatalogsOverviewPage();
        },
      ),
      GoRoute(
        path: '/scraped-catalog/:source',
        builder: (BuildContext context, GoRouterState state) {
          final source = state.pathParameters['source']!;
          return ScrapedCatalogPage(source: source);
        },
      ),
      GoRoute(
        path: '/favorite-products',
        builder: (BuildContext context, GoRouterState state) {
          return const FavoriteProductsPage();
        },
      ),
      GoRoute(
        path: '/category-management',
        builder: (BuildContext context, GoRouterState state) {
          return const CategoryManagementPage();
        },
      ),
      GoRoute(
        path: '/hydraulic-calculator',
        builder: (BuildContext context, GoRouterState state) {
          return const HydraulicCalculatorPage();
        },
      ),
      GoRoute(
        path: '/supplier-comparator',
        builder: (BuildContext context, GoRouterState state) {
          return const SupplierComparatorPage();
        },
      ),
      GoRoute(
        path: '/backup-export',
        builder: (BuildContext context, GoRouterState state) {
          return const BackupExportPage();
        },
      ),
      GoRoute(
        path: '/import-clients',
        builder: (BuildContext context, GoRouterState state) {
          return const ImportClientsPage();
        },
      ),
      GoRoute(
        path: '/job-sites',
        builder: (BuildContext context, GoRouterState state) {
          return const JobSitesListPage();
        },
        routes: [
          GoRoute(
            path: 'new',
            builder: (BuildContext context, GoRouterState state) {
              return const JobSiteFormPage();
            },
          ),
          GoRoute(
            path: ':id',
            builder: (BuildContext context, GoRouterState state) {
              final jobSiteId = state.pathParameters['id']!;
              return JobSiteFormPage(jobSiteId: jobSiteId);
            },
          ),
        ],
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final bool loggedIn = Supabase.instance.client.auth.currentUser != null;
      final bool loggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/register' || state.matchedLocation == '/forgot-password' || state.matchedLocation == '/reset-password';

      // If not logged in, and not on the login/register/forgot/reset password page, redirect to login
      if (!loggedIn && !loggingIn) {
        return '/login';
      }
      // If logged in, and on the login/register/forgot/reset password page, redirect to home
      if (loggedIn && loggingIn) {
        return '/home';
      }
      // No redirect needed
      return null;
    },
  );
}