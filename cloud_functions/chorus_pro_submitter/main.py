import functions_framework
from supabase import create_client, Client
import os
import requests
import logging
from datetime import datetime, timedelta
import base64
import json

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize Supabase client
SUPABASE_URL = os.environ.get("SUPABASE_URL")
SUPABASE_KEY = os.environ.get("SUPABASE_KEY")
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

# Chorus Pro API configuration
# Test environment URLs
CHORUS_PRO_TEST_API_URL = "https://sandbox.chorus-pro.gouv.fr/api/v1"
CHORUS_PRO_TEST_AUTH_URL = "https://sandbox.chorus-pro.gouv.fr/oauth/token"

# Production environment URLs
CHORUS_PRO_PROD_API_URL = "https://chorus-pro.gouv.fr/api/v1"
CHORUS_PRO_PROD_AUTH_URL = "https://chorus-pro.gouv.fr/oauth/token"

# Credentials from environment variables
CHORUS_PRO_CLIENT_ID = os.environ.get("CHORUS_PRO_CLIENT_ID")
CHORUS_PRO_CLIENT_SECRET = os.environ.get("CHORUS_PRO_CLIENT_SECRET")
CHORUS_PRO_LOGIN = os.environ.get("CHORUS_PRO_LOGIN")
CHORUS_PRO_PASSWORD = os.environ.get("CHORUS_PRO_PASSWORD")
CHORUS_PRO_SIRET = os.environ.get("CHORUS_PRO_SIRET")  # Company SIRET

# Test mode flag (default to True for safety)
CHORUS_PRO_TEST_MODE = os.environ.get("CHORUS_PRO_TEST_MODE", "true").lower() == "true"


class ChorusProClient:
    """
    Chorus Pro API client for French B2G e-invoicing

    Handles authentication, invoice submission, and status tracking.
    Supports both test and production modes.
    """

    def __init__(self, test_mode=True):
        self.test_mode = test_mode
        self.api_url = CHORUS_PRO_TEST_API_URL if test_mode else CHORUS_PRO_PROD_API_URL
        self.auth_url = CHORUS_PRO_TEST_AUTH_URL if test_mode else CHORUS_PRO_PROD_AUTH_URL
        self.access_token = None
        self.token_expiry = None

    def authenticate(self):
        """
        Authenticate with Chorus Pro using OAuth2

        Returns access token valid for 3600 seconds (1 hour)
        """
        try:
            logger.info(f"Authenticating with Chorus Pro ({'TEST' if self.test_mode else 'PRODUCTION'} mode)")

            # Prepare authentication request
            auth_string = f"{CHORUS_PRO_CLIENT_ID}:{CHORUS_PRO_CLIENT_SECRET}"
            auth_bytes = auth_string.encode('ascii')
            auth_b64 = base64.b64encode(auth_bytes).decode('ascii')

            headers = {
                'Authorization': f'Basic {auth_b64}',
                'Content-Type': 'application/x-www-form-urlencoded'
            }

            data = {
                'grant_type': 'password',
                'username': CHORUS_PRO_LOGIN,
                'password': CHORUS_PRO_PASSWORD,
                'scope': 'openid profile email'
            }

            response = requests.post(
                self.auth_url,
                headers=headers,
                data=data,
                timeout=30
            )

            if response.status_code == 200:
                token_data = response.json()
                self.access_token = token_data.get('access_token')
                expires_in = token_data.get('expires_in', 3600)
                self.token_expiry = datetime.now() + timedelta(seconds=expires_in)

                logger.info("Authentication successful")
                return True
            else:
                logger.error(f"Authentication failed: {response.status_code} - {response.text}")
                return False

        except Exception as e:
            logger.error(f"Authentication error: {e}", exc_info=True)
            return False

    def is_token_valid(self):
        """Check if current access token is still valid"""
        if not self.access_token or not self.token_expiry:
            return False
        return datetime.now() < (self.token_expiry - timedelta(minutes=5))

    def ensure_authenticated(self):
        """Ensure we have a valid access token"""
        if not self.is_token_valid():
            return self.authenticate()
        return True

    def submit_invoice(self, invoice_data):
        """
        Submit invoice to Chorus Pro

        invoice_data should contain:
        - facturx_xml: XML content (Factur-X format)
        - invoice_number: Invoice number
        - recipient_siret: Recipient SIRET number
        - total_ttc: Total amount TTC
        - invoice_date: Invoice date
        """
        try:
            if not self.ensure_authenticated():
                raise Exception("Authentication failed")

            logger.info(f"Submitting invoice {invoice_data.get('invoice_number')} to Chorus Pro")

            # Prepare submission payload
            headers = {
                'Authorization': f'Bearer {self.access_token}',
                'Content-Type': 'application/json',
                'Accept': 'application/json'
            }

            payload = {
                'facture': {
                    'numeroFacture': invoice_data.get('invoice_number'),
                    'dateFacture': invoice_data.get('invoice_date'),
                    'montantTTC': invoice_data.get('total_ttc'),
                    'siretEmetteur': CHORUS_PRO_SIRET,
                    'siretDestinataire': invoice_data.get('recipient_siret'),
                    'typeFacture': 'FACTURE',  # ou 'AVOIR' for credit note
                    'modeDepot': 'FLUX_API',
                    'fichierXML': base64.b64encode(invoice_data.get('facturx_xml')).decode('utf-8')
                }
            }

            # Submit invoice
            submit_url = f"{self.api_url}/factures/deposer"
            response = requests.post(
                submit_url,
                headers=headers,
                json=payload,
                timeout=60
            )

            if response.status_code in [200, 201]:
                result = response.json()
                invoice_id = result.get('idFacture')
                status = result.get('statut', 'DEPOSE')

                logger.info(f"Invoice submitted successfully. ID: {invoice_id}, Status: {status}")

                return {
                    'success': True,
                    'chorus_invoice_id': invoice_id,
                    'status': status,
                    'message': 'Invoice submitted successfully'
                }
            else:
                logger.error(f"Submission failed: {response.status_code} - {response.text}")
                return {
                    'success': False,
                    'error': f"Submission failed: {response.text}"
                }

        except Exception as e:
            logger.error(f"Invoice submission error: {e}", exc_info=True)
            return {
                'success': False,
                'error': str(e)
            }

    def check_status(self, chorus_invoice_id):
        """
        Check invoice status in Chorus Pro

        Possible statuses:
        - DEPOSE: Deposited
        - EN_TRAITEMENT: In progress
        - REFUSE: Rejected
        - A_RECYCLER: To recycle (error to fix)
        - SUSPENDU: Suspended
        - PAYE: Paid
        - MIS_EN_PAIEMENT: Payment initiated
        """
        try:
            if not self.ensure_authenticated():
                raise Exception("Authentication failed")

            logger.info(f"Checking status for Chorus Pro invoice: {chorus_invoice_id}")

            headers = {
                'Authorization': f'Bearer {self.access_token}',
                'Accept': 'application/json'
            }

            status_url = f"{self.api_url}/factures/{chorus_invoice_id}/statut"
            response = requests.get(
                status_url,
                headers=headers,
                timeout=30
            )

            if response.status_code == 200:
                result = response.json()
                status = result.get('statut')
                date_update = result.get('dateModification')

                logger.info(f"Status: {status}, Last updated: {date_update}")

                return {
                    'success': True,
                    'status': status,
                    'date_update': date_update,
                    'details': result
                }
            else:
                logger.error(f"Status check failed: {response.status_code} - {response.text}")
                return {
                    'success': False,
                    'error': f"Status check failed: {response.text}"
                }

        except Exception as e:
            logger.error(f"Status check error: {e}", exc_info=True)
            return {
                'success': False,
                'error': str(e)
            }

    def get_invoice_details(self, chorus_invoice_id):
        """Get full invoice details from Chorus Pro"""
        try:
            if not self.ensure_authenticated():
                raise Exception("Authentication failed")

            headers = {
                'Authorization': f'Bearer {self.access_token}',
                'Accept': 'application/json'
            }

            details_url = f"{self.api_url}/factures/{chorus_invoice_id}"
            response = requests.get(
                details_url,
                headers=headers,
                timeout=30
            )

            if response.status_code == 200:
                return {
                    'success': True,
                    'details': response.json()
                }
            else:
                return {
                    'success': False,
                    'error': f"Failed to get details: {response.text}"
                }

        except Exception as e:
            logger.error(f"Get details error: {e}", exc_info=True)
            return {
                'success': False,
                'error': str(e)
            }


@functions_framework.http
def submit_to_chorus_pro(request):
    """
    Cloud Function to submit invoices to Chorus Pro

    Handles CORS, authentication, submission, and status updates
    """
    # Handle CORS preflight
    if request.method == 'OPTIONS':
        headers = {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'POST',
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Max-Age': '3600'
        }
        return ('', 204, headers)

    headers = {
        'Access-Control-Allow-Origin': '*',
        'Content-Type': 'application/json'
    }

    try:
        request_json = request.get_json(silent=True)
        if not request_json:
            return {'success': False, 'error': 'Invalid JSON payload'}, 400, headers

        invoice_id = request_json.get('invoice_id')
        action = request_json.get('action', 'submit')  # submit, check_status, get_details

        if not invoice_id:
            return {'success': False, 'error': 'Missing invoice_id'}, 400, headers

        # Initialize Chorus Pro client
        test_mode = request_json.get('test_mode', CHORUS_PRO_TEST_MODE)
        client = ChorusProClient(test_mode=test_mode)

        # Handle different actions
        if action == 'submit':
            # Fetch invoice data from Supabase
            logger.info(f"Fetching invoice {invoice_id} from database")
            invoice_response = supabase.table('invoices').select(
                'invoice_number, facturx_xml_url, total_ttc, invoice_date, client:clients(siret)'
            ).eq('id', invoice_id).single().execute()

            if not invoice_response.data:
                raise Exception('Invoice not found')

            invoice = invoice_response.data

            # Validate required data
            if not invoice.get('facturx_xml_url'):
                raise Exception('Factur-X XML not generated. Please generate PDF with Factur-X first.')

            if not invoice.get('client') or not invoice['client'].get('siret'):
                raise Exception('Client SIRET is required for Chorus Pro submission')

            # Download Factur-X XML
            logger.info(f"Downloading Factur-X XML from {invoice['facturx_xml_url']}")
            xml_response = requests.get(invoice['facturx_xml_url'], timeout=30)
            xml_response.raise_for_status()
            facturx_xml = xml_response.content

            # Prepare invoice data for submission
            invoice_data = {
                'invoice_number': invoice['invoice_number'],
                'facturx_xml': facturx_xml,
                'total_ttc': invoice['total_ttc'],
                'invoice_date': invoice['invoice_date'],
                'recipient_siret': invoice['client']['siret']
            }

            # Submit invoice
            result = client.submit_invoice(invoice_data)

            # Update invoice in database
            if result['success']:
                supabase.table('invoices').update({
                    'chorus_pro_id': result['chorus_invoice_id'],
                    'chorus_pro_status': result['status'],
                    'chorus_pro_submitted_at': datetime.utcnow().isoformat(),
                    'chorus_pro_test_mode': test_mode
                }).eq('id', invoice_id).execute()

                logger.info(f"Invoice {invoice_id} successfully submitted to Chorus Pro")
            else:
                supabase.table('invoices').update({
                    'chorus_pro_status': 'FAILED',
                    'chorus_pro_error': result.get('error')
                }).eq('id', invoice_id).execute()

            return result, 200 if result['success'] else 500, headers

        elif action == 'check_status':
            # Get Chorus Pro invoice ID from database
            invoice_response = supabase.table('invoices').select('chorus_pro_id').eq('id', invoice_id).single().execute()

            if not invoice_response.data or not invoice_response.data.get('chorus_pro_id'):
                return {'success': False, 'error': 'Invoice not submitted to Chorus Pro'}, 400, headers

            chorus_invoice_id = invoice_response.data['chorus_pro_id']

            # Check status
            result = client.check_status(chorus_invoice_id)

            # Update database
            if result['success']:
                supabase.table('invoices').update({
                    'chorus_pro_status': result['status'],
                    'chorus_pro_last_check': datetime.utcnow().isoformat()
                }).eq('id', invoice_id).execute()

            return result, 200 if result['success'] else 500, headers

        elif action == 'get_details':
            # Get Chorus Pro invoice ID from database
            invoice_response = supabase.table('invoices').select('chorus_pro_id').eq('id', invoice_id).single().execute()

            if not invoice_response.data or not invoice_response.data.get('chorus_pro_id'):
                return {'success': False, 'error': 'Invoice not submitted to Chorus Pro'}, 400, headers

            chorus_invoice_id = invoice_response.data['chorus_pro_id']

            # Get details
            result = client.get_invoice_details(chorus_invoice_id)

            return result, 200 if result['success'] else 500, headers

        else:
            return {'success': False, 'error': f'Unknown action: {action}'}, 400, headers

    except Exception as e:
        logger.error(f"Chorus Pro submission failed: {e}", exc_info=True)

        # Update invoice status to failed
        try:
            if invoice_id:
                supabase.table('invoices').update({
                    'chorus_pro_status': 'FAILED',
                    'chorus_pro_error': str(e)
                }).eq('id', invoice_id).execute()
        except:
            pass

        return {
            'success': False,
            'error': str(e)
        }, 500, headers
