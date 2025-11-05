import functions_framework
import os
from sendgrid import SendGridAPIClient
from sendgrid.helpers.mail import Mail

# Initialize SendGrid client
SENDGRID_API_KEY = os.environ.get("SENDGRID_API_KEY")

@functions_framework.http
def send_email(request):
    request_json = request.get_json(silent=True)
    to_email = request_json.get('to_email')
    subject = request_json.get('subject')
    body = request_json.get('body')

    if not to_email or not subject or not body:
        return {'success': False, 'error': 'Missing to_email, subject, or body'}, 400

    message = Mail(
        from_email='support@plombipro.com', # Replace with your sending email
        to_emails=to_email,
        subject=subject,
        html_content=body)
    try:
        sg = SendGridAPIClient(SENDGRID_API_KEY)
        response = sg.send(message)
        return {'success': True, 'status_code': response.status_code}, 200
    except Exception as e:
        return {'success': False, 'error': str(e)}, 500
