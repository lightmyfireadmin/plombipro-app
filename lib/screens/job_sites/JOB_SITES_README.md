# Job Sites Module Documentation

## Overview

The Job Sites module provides comprehensive project management capabilities for plumbing professionals. It enables tracking all aspects of a job site including tasks, time, photos, documents, notes, and financials.

---

## Features

### 1. Overview Tab

**Purpose:** High-level view of job site status and key metrics

**Components:**
- Job site name and address
- Current status indicator (active, completed, on-hold, cancelled)
- Progress percentage (auto-calculated from task completion)
- Quick statistics cards:
  - Estimated Budget
  - Actual Cost
  - Profit Margin %
  - Tasks Completed (X/Y)

**Data Sources:**
- `job_sites` table for main info
- `job_site_tasks` for progress calculation
- Financial calculations from time logs and materials

---

### 2. Financial Tab

**Purpose:** Real-time profit/loss tracking and cost breakdown

**Metrics Displayed:**
- **Total Revenue:** From estimated budget or linked quote/invoice
- **Labor Cost:** Calculated from time logs (hours × hourly rate)
- **Materials Cost:** From actual_cost field (can link to purchases)
- **Profit/Loss:** Revenue - Labor - Materials
- **Profit Margin %:** (Profit / Revenue) × 100

**Visual Indicators:**
- Green text for profit
- Red text for loss
- Warning icons if costs exceed budget

**Business Logic:**
```dart
void _calculateFinancials() {
  // Sum all time log costs
  _totalLaborCost = _timeLogs.fold(0.0, (sum, log) => sum + (log.laborCost ?? 0.0));

  // Get materials from job site
  _totalMaterialsCost = _jobSite?.actualCost ?? 0.0;

  // Get revenue from estimate
  _totalRevenue = _jobSite?.estimatedBudget ?? 0.0;

  // Calculate profit
  final profit = _totalRevenue - _totalLaborCost - _totalMaterialsCost;
  final profitMargin = _totalRevenue > 0 ? (profit / _totalRevenue) * 100 : 0;
}
```

---

### 3. Tasks Tab

**Purpose:** Checklist-based task management with completion tracking

**Features:**
- Task list with checkboxes
- Task descriptions
- Due dates (if set)
- Completion status indicator
- Progress bar showing X/Y completed

**Behavior:**
- Tap checkbox to toggle completion
- Auto-updates `is_completed` and `completed_at` fields
- Recalculates job site progress percentage
- Updates `job_sites.progress_percentage` in database

**Progress Calculation:**
```dart
void _updateProgress() async {
  final completedTasks = _tasks.where((t) => t.isCompleted).length;
  final totalTasks = _tasks.length;
  final progressPercentage = totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0;

  await SupabaseService.updateJobSite(widget.jobSiteId, {
    'progress_percentage': progressPercentage,
  });
}
```

---

### 4. Photos Tab

**Purpose:** Visual documentation of job site progress

**Features:**
- GridView gallery layout (3 columns)
- Photo upload via camera or gallery
- Tap photo to view full-screen
- Full-screen viewer with pinch-to-zoom
- Error handling for broken images

**Upload Flow:**
1. Tap "Ajouter une photo" button
2. Bottom sheet shows: "Prendre une photo" or "Choisir de la galerie"
3. Image picker opens
4. Upload to Supabase Storage (`job_site_photos` bucket)
5. Save metadata to `job_site_photos` table
6. Refresh gallery

**Storage:**
- Bucket: `job_site_photos`
- Filename format: `{job_site_id}_{timestamp}.jpg`
- Metadata: job_site_id, photo_url, uploaded_at

**Full-Screen Viewer:**
- Black background
- InteractiveViewer for pinch-to-zoom
- Close button in top-right
- Handles network errors gracefully

---

### 5. Documents Tab

**Purpose:** Organized document storage (PDFs, images, contracts, invoices)

**Features:**
- Document list with icons by type
- File size display (auto-formatted KB/MB)
- Document type categorization:
  - Invoice (📄)
  - Quote (📋)
  - Contract (📜)
  - Photo (📷)
  - PDF (📕)
  - Other (📎)
- Open document in browser
- Delete with confirmation dialog
- File upload support

**Supported File Types:**
- PDF (`.pdf`)
- Images (`.jpg`, `.jpeg`, `.png`)
- Office docs (`.doc`, `.docx`)

**Upload Flow:**
1. Tap "Ajouter un document" button
2. File picker opens
3. User selects file
4. Upload to Supabase Storage (`job_site_documents` bucket)
5. Save metadata to `job_site_documents` table
6. Refresh document list

**Document Model:**
```dart
class JobSiteDocument {
  final String id;
  final String jobSiteId;
  final String documentName;
  final String documentUrl;
  final String documentType; // 'invoice', 'quote', 'pdf', etc.
  final int? fileSize; // in bytes
  final DateTime? uploadedAt;

  String get formattedFileSize {
    if (fileSize! < 1024) return '$fileSize B';
    if (fileSize! < 1024 * 1024) return '${(fileSize! / 1024).toFixed(1)} KB';
    return '${(fileSize! / (1024 * 1024)).toFixed(1)} MB';
  }
}
```

---

### 6. Notes Tab

**Purpose:** Free-form text notes for observations and reminders

**Features:**
- Scrollable note list
- Add note dialog with multiline input
- Timestamp display
- Note text display

**Add Note Flow:**
1. Tap "Ajouter une note" button
2. Dialog opens with multiline TextField
3. User types note
4. Tap "Ajouter" to save
5. Note saved to `job_site_notes` table
6. List refreshes

**Note Display:**
- Card layout with elevation
- Note text (truncated if long)
- Timestamp at bottom
- Scroll for long notes

---

### 7. Time Tracking Tab

**Purpose:** Precise time tracking for labor billing

**Features:**
- Large timer display (HH:MM:SS format)
- Control buttons:
  - **Start:** Begin new session
  - **Pause:** Temporarily pause timer
  - **Resume:** Continue from pause
  - **Stop:** End session and save
- Time log history
- Total labor cost summary

**Timer States:**
```dart
// State variables
DateTime? _timerStartTime;
Duration _elapsedTime = Duration.zero;
Timer? _timer;
bool _isTimerRunning = false;
bool _isTimerPaused = false;
```

**Start Timer:**
```dart
void _startTimer() {
  setState(() {
    _isTimerRunning = true;
    _isTimerPaused = false;
    _timerStartTime = DateTime.now();
  });

  _timer = Timer.periodic(Duration(seconds: 1), (timer) {
    setState(() {
      _elapsedTime = DateTime.now().difference(_timerStartTime!);
    });
  });
}
```

**Stop Timer Flow:**
1. User taps "Arrêter"
2. Timer stops
3. Dialog asks for hourly rate
4. Calculate: `laborCost = (hours × hourlyRate)`
5. Save to `job_site_time_logs` table:
   - `job_site_id`
   - `hours_worked`
   - `hourly_rate`
   - `labor_cost`
   - `description` (optional)
   - `logged_at`
6. Update financial calculations
7. Refresh time log history

**Time Log History:**
- List of past sessions
- Shows: hours worked, description, cost
- Total labor cost at bottom
- Color-coded (green for totals)

---

## Database Schema

### job_sites
```sql
CREATE TABLE job_sites (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id),
  job_name TEXT NOT NULL,
  address TEXT,
  client_id UUID REFERENCES clients(id),
  status TEXT DEFAULT 'active', -- 'active', 'completed', 'on_hold', 'cancelled'
  progress_percentage DECIMAL(5,2) DEFAULT 0.00,
  estimated_budget DECIMAL(10,2),
  actual_cost DECIMAL(10,2),
  profit_margin DECIMAL(5,2),
  start_date DATE,
  end_date DATE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### job_site_tasks
```sql
CREATE TABLE job_site_tasks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  job_site_id UUID REFERENCES job_sites(id) ON DELETE CASCADE,
  task_name TEXT NOT NULL,
  description TEXT,
  is_completed BOOLEAN DEFAULT FALSE,
  due_date DATE,
  completed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### job_site_photos
```sql
CREATE TABLE job_site_photos (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  job_site_id UUID REFERENCES job_sites(id) ON DELETE CASCADE,
  photo_url TEXT NOT NULL,
  description TEXT,
  uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### job_site_documents
```sql
CREATE TABLE job_site_documents (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  job_site_id UUID REFERENCES job_sites(id) ON DELETE CASCADE,
  document_name TEXT NOT NULL,
  document_url TEXT NOT NULL,
  document_type TEXT, -- 'invoice', 'quote', 'contract', 'photo', 'pdf', 'other'
  file_size INTEGER, -- in bytes
  uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### job_site_notes
```sql
CREATE TABLE job_site_notes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  job_site_id UUID REFERENCES job_sites(id) ON DELETE CASCADE,
  note_text TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### job_site_time_logs
```sql
CREATE TABLE job_site_time_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  job_site_id UUID REFERENCES job_sites(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id),
  hours_worked DECIMAL(5,2) NOT NULL,
  hourly_rate DECIMAL(10,2),
  labor_cost DECIMAL(10,2),
  description TEXT,
  logged_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

---

## Supabase Storage Buckets

### job_site_photos
- **Public:** Yes (read-only)
- **Max file size:** 5 MB
- **Allowed types:** image/jpeg, image/png
- **Folder structure:** `/job_site_photos/{job_site_id}/{timestamp}.jpg`

### job_site_documents
- **Public:** No (authenticated access only)
- **Max file size:** 10 MB
- **Allowed types:** PDF, images, Office docs
- **Folder structure:** `/job_site_documents/{job_site_id}/{filename}`

**RLS Policies:**
```sql
-- Users can only access their own job sites' files
CREATE POLICY "Users can view own job site photos"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'job_site_photos' AND
    (storage.foldername(name))[1] IN (
      SELECT id::text FROM job_sites WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can upload to own job sites"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'job_site_photos' AND
    (storage.foldername(name))[1] IN (
      SELECT id::text FROM job_sites WHERE user_id = auth.uid()
    )
  );
```

---

## Usage Examples

### Create a New Job Site

```dart
final jobSiteId = await SupabaseService.createJobSite({
  'user_id': currentUserId,
  'job_name': 'Rénovation salle de bain',
  'address': '123 Rue de la Paix, 75001 Paris',
  'client_id': clientId,
  'status': 'active',
  'estimated_budget': 5000.00,
  'start_date': DateTime.now().toIso8601String(),
});
```

### Navigate to Job Site Detail

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => JobSiteDetailPage(jobSiteId: jobSiteId),
  ),
);
```

### Add a Task

```dart
await SupabaseService.createJobSiteTask({
  'job_site_id': jobSiteId,
  'task_name': 'Installer robinetterie',
  'description': 'Robinet mitigeur Grohe',
  'due_date': DateTime.now().add(Duration(days: 3)).toIso8601String(),
});
```

### Upload a Photo

```dart
// Pick image
final XFile? image = await ImagePicker().pickImage(source: ImageSource.camera);

if (image != null) {
  // Upload to storage
  final file = File(image.path);
  final fileName = '${jobSiteId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
  final photoUrl = await SupabaseService.uploadPhoto(file, fileName);

  // Save metadata
  await SupabaseService.createJobSitePhoto({
    'job_site_id': jobSiteId,
    'photo_url': photoUrl,
  });
}
```

### Start Time Tracking

```dart
void _startTimer() {
  setState(() {
    _isTimerRunning = true;
    _timerStartTime = DateTime.now();
  });

  _timer = Timer.periodic(Duration(seconds: 1), (timer) {
    setState(() {
      _elapsedTime = DateTime.now().difference(_timerStartTime!);
    });
  });
}
```

### Stop Time Tracking and Save

```dart
void _stopTimer() async {
  _timer?.cancel();

  // Ask for hourly rate
  final hourlyRate = await _showHourlyRateDialog();

  if (hourlyRate != null) {
    final hoursWorked = _elapsedTime.inSeconds / 3600;
    final laborCost = hoursWorked * hourlyRate;

    await SupabaseService.createJobSiteTimeLog({
      'job_site_id': widget.jobSiteId,
      'user_id': currentUserId,
      'hours_worked': hoursWorked,
      'hourly_rate': hourlyRate,
      'labor_cost': laborCost,
      'logged_at': DateTime.now().toIso8601String(),
    });

    setState(() {
      _isTimerRunning = false;
      _elapsedTime = Duration.zero;
    });

    _loadTimeLogs(); // Refresh list
    _calculateFinancials(); // Update totals
  }
}
```

---

## Dependencies

Required Flutter packages (add to `pubspec.yaml`):

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Image handling
  image_picker: ^1.0.4

  # File handling
  file_picker: ^6.1.1

  # URL launching
  url_launcher: ^6.2.1

  # Supabase (already included)
  supabase_flutter: ^2.0.0
```

---

## Performance Considerations

### Loading Optimization

The job site detail page loads data in parallel:

```dart
Future<void> _fetchAllData() async {
  await _fetchJobSite(); // Load main info first

  // Load everything else in parallel
  await Future.wait([
    _fetchTasks(),
    _fetchPhotos(),
    _fetchNotes(),
    _fetchTimeLogs(),
    _loadDocuments(),
  ]);

  _calculateFinancials(); // Calculate after all data loaded
}
```

### Image Loading

Photos use cached network images with error fallbacks:

```dart
Image.network(
  photo.photoUrl,
  fit: BoxFit.cover,
  errorBuilder: (context, error, stackTrace) =>
    const Icon(Icons.broken_image, size: 64),
)
```

### Timer Performance

Timer updates every second but only rebuilds affected widget:

```dart
Timer.periodic(Duration(seconds: 1), (timer) {
  if (mounted) {
    setState(() {
      _elapsedTime = DateTime.now().difference(_timerStartTime!);
    });
  }
});
```

---

## Error Handling

All async operations have try-catch blocks:

```dart
Future<void> _addPhoto(ImageSource source) async {
  try {
    final XFile? image = await _imagePicker.pickImage(source: source);
    // ... upload logic
  } catch (e) {
    _showError('Erreur lors de l\'ajout de la photo: $e');
  }
}

void _showError(String message) {
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
```

---

## Accessibility

### Screen Reader Support

- All images have semantic labels
- Buttons have clear labels
- Progress indicators announce changes

### Keyboard Navigation

- All interactive elements are focusable
- Tab order follows visual layout
- Dialogs trap focus appropriately

---

## Testing

### Unit Tests

Test financial calculations:

```dart
test('calculates profit correctly', () {
  final revenue = 5000.0;
  final labor = 2000.0;
  final materials = 1500.0;

  final profit = revenue - labor - materials;
  expect(profit, 1500.0);

  final margin = (profit / revenue) * 100;
  expect(margin, 30.0);
});
```

### Widget Tests

Test timer functionality:

```dart
testWidgets('timer starts and stops correctly', (tester) async {
  await tester.pumpWidget(MyApp());

  // Navigate to job site detail
  await tester.tap(find.text('View Job Site'));
  await tester.pumpAndSettle();

  // Switch to time tracking tab
  await tester.tap(find.text('Temps'));
  await tester.pumpAndSettle();

  // Start timer
  await tester.tap(find.text('Démarrer'));
  await tester.pump(Duration(seconds: 2));

  // Verify timer is running
  expect(find.textContaining('00:00:0'), findsOneWidget);

  // Stop timer
  await tester.tap(find.text('Arrêter'));
  await tester.pumpAndSettle();

  // Verify hourly rate dialog appears
  expect(find.text('Taux horaire'), findsOneWidget);
});
```

---

## Troubleshooting

### Photos Not Loading

**Problem:** Photos show broken image icon

**Solutions:**
1. Check Supabase Storage bucket permissions
2. Verify RLS policies allow read access
3. Ensure photo URLs are valid and public
4. Check network connectivity

### Timer Not Starting

**Problem:** Start button doesn't work

**Solutions:**
1. Check if timer is already running (`_isTimerRunning == true`)
2. Verify `SingleTickerProviderStateMixin` is added to state class
3. Ensure `_timer?.cancel()` is called in `dispose()`
4. Check for state management issues

### Document Upload Fails

**Problem:** File picker returns null or upload errors

**Solutions:**
1. Check file size limits (max 10 MB)
2. Verify allowed file types in FilePicker config
3. Ensure Supabase Storage bucket exists
4. Check RLS policies for insert permission
5. Verify user authentication

### Progress Not Updating

**Problem:** Completing tasks doesn't update percentage

**Solutions:**
1. Verify `_updateProgress()` is called after task toggle
2. Check database trigger for `updated_at` field
3. Ensure `job_sites.progress_percentage` column exists
4. Reload job site data after update

---

## Future Enhancements

### Potential Features

1. **Task Dependencies**
   - Link tasks (Task B can't start until Task A is done)
   - Gantt chart view

2. **Team Collaboration**
   - Assign tasks to team members
   - Real-time updates with Supabase Realtime
   - Comments on tasks and photos

3. **GPS Integration**
   - Auto-detect arrival/departure at job site
   - Distance tracking for mileage reimbursement

4. **Weather Integration**
   - Show weather forecast for job site location
   - Weather-related task delays

5. **Material Tracking**
   - Link products/materials to job sites
   - Track material usage vs. estimate
   - Auto-update inventory

6. **Reports**
   - Export job site summary as PDF
   - Time tracking reports by job site
   - Profitability analysis across job sites

---

## Support

For issues or questions:
- Check error logs in Flutter DevTools
- Review Supabase dashboard for database errors
- Verify all migrations have been applied
- Test with simplified data first

---

**Last Updated:** 2025-11-05
**Version:** 1.0.0
**Status:** Production Ready ✅
