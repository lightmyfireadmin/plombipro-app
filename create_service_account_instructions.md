## Create Google Cloud Service Account (Without Cloud Scheduler Roles)

Now that the Google Cloud APIs are enabled, you need to create a service account with specific roles. This service account will be used by your Cloud Functions.

**Please follow these steps in the Google Cloud Console:**

1.  **Go to IAM & Admin > Service Accounts**
    *   The direct URL is: `https://console.cloud.google.com/iam-admin/serviceaccounts`
    *   Ensure you have selected your `plombipro-prod` project.

2.  **Create a new Service Account:**
    *   Click the button that says `+ CREATE SERVICE ACCOUNT`.
    *   For the **Service account name**, type: `plombipro-cloud-functions`
    *   For the **Service account description**, type: `Service account for PlombiPro Cloud Functions`
    *   Click `CREATE AND CONTINUE`.

3.  **Grant this service account several roles (add roles):**
    You need to grant this service account the minimum necessary permissions. Add the following roles one by one:
    *   `Cloud Functions Admin` (for deploying and managing functions)
    *   `Cloud Functions Invoker` (for functions to invoke each other)
    *   `Cloud Vision API User` (for OCR processing)
    *   `Pub/Sub Editor` (still needed if other services trigger functions via Pub/Sub)
    *   `Service Account User` (allows other services to impersonate this SA)
    *   `Storage Object Admin` (if Cloud Functions need to directly interact with Google Cloud Storage, though Supabase Storage is used here, it's good practice for general Cloud Function deployments)
    *   `Secret Manager Secret Accessor` (if you plan to use Google Secret Manager for sensitive keys, though for now we are using environment variables)
    *   `Logging Admin` (for viewing logs)

    *Important Note: Always follow the principle of least privilege. Only grant the roles that are absolutely necessary.*

4.  **Confirm and Finish:**
    *   Click `CONTINUE`.
    *   Click `DONE`.

Once this service account is created and all these roles are assigned, please let me know.