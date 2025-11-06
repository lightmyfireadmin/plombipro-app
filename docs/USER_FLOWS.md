# PlombiPro User Flows

Key user journeys through the app with UX considerations and implementation notes.

---

## Primary User Personas

### Pierre - Solo Plumber
**Goals:** Quick job tracking, simple invoicing, client management
**Pain Points:** Limited time, not tech-savvy, needs efficiency
**Priorities:** Speed, simplicity, mobile-first

### Sophie - Small Business Owner
**Goals:** Team management, detailed reports, professional branding
**Pain Points:** Managing multiple jobs, cash flow tracking
**Priorities:** Organization, insights, growth

---

## Core User Flows

### Flow 1: New User Onboarding

**Goal:** Get user to "aha moment" (first completed job) in < 5 minutes

```
┌────────────────────────────────────────────────────────────┐
│ ONBOARDING FLOW                                             │
└────────────────────────────────────────────────────────────┘

1. App Launch (First Time)
   ↓
   [Splash Screen] (1-2s)
   ↓
2. Welcome Screen
   ┌─────────────────────────────┐
   │  PlombiPro Logo             │
   │  "Your business, organized" │
   │                             │
   │  [Get Started]              │
   │  Already have account? Login│
   └─────────────────────────────┘
   ↓
3. Quick Setup (Single Screen - Progressive Form)
   ┌─────────────────────────────┐
   │  Let's get you set up       │
   │                             │
   │  👤 Your Name:              │
   │     [_______________]       │
   │                             │
   │  🏢 Company Name:           │
   │     [_______________]       │
   │                             │
   │  📧 Email:                  │
   │     [_______________]       │
   │                             │
   │  🔒 Password:               │
   │     [_______________]       │
   │                             │
   │  [Create Account]           │
   └─────────────────────────────┘
   ↓
4. Success Animation
   ✓ Checkmark with confetti
   "Welcome to PlombiPro!"
   ↓
5. Optional: Feature Tour (Swipeable)
   Screen 1: "Track all your jobs"
   Screen 2: "Generate invoices instantly"
   Screen 3: "Get paid faster"
   [Skip] button on each
   ↓
6. Dashboard (with Empty State)
   ┌─────────────────────────────┐
   │  Home                       │
   │                             │
   │  🚀 Welcome, Pierre!        │
   │                             │
   │  Ready to create your       │
   │  first job?                 │
   │                             │
   │  [+ Create First Job]       │
   └─────────────────────────────┘
```

**UX Considerations:**
- Keep initial form short (4 fields max)
- Allow skipping feature tour
- Immediately show value with empty state CTA
- Use celebratory animation for accomplishment feeling

**Implementation:**
```dart
class OnboardingFlow extends StatefulWidget {
  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (page) => setState(() => _currentPage = page),
            children: [
              WelcomePage(),
              QuickSetupPage(),
              FeatureTourPage(feature: 'jobs'),
              FeatureTourPage(feature: 'invoices'),
              FeatureTourPage(feature: 'payments'),
            ],
          ),

          // Skip button
          if (_currentPage > 1 && _currentPage < 4)
            Positioned(
              top: 48,
              right: 16,
              child: TextButton(
                onPressed: () => _controller.jumpToPage(4),
                child: Text('Skip'),
              ),
            ),

          // Page indicators
          if (_currentPage > 1 && _currentPage < 4)
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    width: (_currentPage - 2) == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: (_currentPage - 2) == index
                          ? AppTheme.primary
                          : AppTheme.neutral300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}
```

---

### Flow 2: Create Job → Complete → Invoice

**Goal:** Smooth workflow from job creation to payment

```
┌────────────────────────────────────────────────────────────┐
│ COMPLETE JOB WORKFLOW                                       │
└────────────────────────────────────────────────────────────┘

1. Dashboard
   ┌─────────────────────────────┐
   │  📍 Active Jobs (3)         │
   │  💰 Pending Invoices (2)    │
   │                             │
   │  Quick Actions:             │
   │  [+ New Job] [+ Invoice]    │
   └─────────────────────────────┘
   ↓ Tap [+ New Job]

2. New Job Form (Step 1: Basics)
   ┌─────────────────────────────┐
   │  ← New Job            [1/3] │
   │                             │
   │  Client:                    │
   │  [Select Client ▼]          │
   │  or [+ Add New Client]      │
   │                             │
   │  Site Address:              │
   │  [_______________]          │
   │  [📍 Use Current Location]  │
   │                             │
   │  Scheduled Date:            │
   │  [📅 Select Date]           │
   │                             │
   │       [Next: Add Tasks →]   │
   └─────────────────────────────┘
   ↓

3. New Job Form (Step 2: Tasks)
   ┌─────────────────────────────┐
   │  ← New Job            [2/3] │
   │                             │
   │  What needs to be done?     │
   │                             │
   │  ✓ Install sink             │
   │  ✓ Replace pipes            │
   │  ⚪ Test system             │
   │                             │
   │  [+ Add Task]               │
   │                             │
   │  [← Back]    [Next: Details]│
   └─────────────────────────────┘
   ↓

4. New Job Form (Step 3: Details - Optional)
   ┌─────────────────────────────┐
   │  ← New Job            [3/3] │
   │                             │
   │  Estimated Budget:          │
   │  [€ ___________]            │
   │                             │
   │  Notes:                     │
   │  [_______________]          │
   │  [_______________]          │
   │                             │
   │  [← Back]  [Create Job ✓]  │
   └─────────────────────────────┘
   ↓

5. Success Animation + Navigation
   ✓ "Job created!"
   ↓ Auto-navigate to:

6. Job Detail Page
   ┌─────────────────────────────┐
   │  ← Dupont Residence         │
   │                             │
   │  📍 123 Rue de Paris        │
   │  👤 Jean Dupont             │
   │  📅 Today, 14:00            │
   │                             │
   │  Status: [⚡ Active]        │
   │                             │
   │  ⏱️ [Start Timer]           │
   │                             │
   │  Tasks (2 of 3 done):       │
   │  ✓ Install sink             │
   │  ✓ Replace pipes            │
   │  ⚪ Test system             │
   │                             │
   │  [📸 Add Photo]             │
   │  [📝 Add Note]              │
   │                             │
   │  💡 Tip: Add photos as you  │
   │     work for your records   │
   └─────────────────────────────┘
   ↓ Complete tasks...

7. All Tasks Complete → Smart Suggestion
   ┌─────────────────────────────┐
   │  🎉 All tasks completed!    │
   │                             │
   │  ┌─────────────────────────┐│
   │  │ Ready to invoice?       ││
   │  │                         ││
   │  │ [Create Invoice →]      ││
   │  │                         ││
   │  │ or [Mark as Complete]   ││
   │  └─────────────────────────┘│
   └─────────────────────────────┘
   ↓ Tap [Create Invoice]

8. Invoice Form (Pre-filled)
   ┌─────────────────────────────┐
   │  ← New Invoice              │
   │                             │
   │  Client: Jean Dupont ✓      │
   │  Job: Dupont Residence ✓    │
   │                             │
   │  Services:                  │
   │  Install sink       €120    │
   │  Replace pipes      €280    │
   │  Test system         €50    │
   │                             │
   │  [+ Add Line Item]          │
   │                             │
   │  Subtotal:          €450    │
   │  VAT (20%):          €90    │
   │  ─────────────────────      │
   │  Total:             €540    │
   │                             │
   │  [← Back]  [Send Invoice →]│
   └─────────────────────────────┘
   ↓

9. Send Options
   ┌─────────────────────────────┐
   │  Send Invoice               │
   │                             │
   │  To: jean@example.com       │
   │                             │
   │  Method:                    │
   │  ⚪ Email (Recommended)     │
   │  ⚪ SMS                      │
   │  ⚪ Download PDF            │
   │                             │
   │  Add message (optional):    │
   │  [_______________]          │
   │                             │
   │       [Send Now]            │
   └─────────────────────────────┘
   ↓

10. Success!
    ┌─────────────────────────────┐
    │       ✓                     │
    │   Invoice Sent!             │
    │                             │
    │  Jean Dupont will receive   │
    │  your invoice at            │
    │  jean@example.com           │
    │                             │
    │  [View Invoice]             │
    │  [Back to Dashboard]        │
    └─────────────────────────────┘
```

**UX Considerations:**
- Multi-step form with clear progress (1/3, 2/3, 3/3)
- Allow going back to edit
- Smart suggestions at completion milestones
- Pre-fill invoice from job data
- Immediate success feedback
- Clear next actions

**Key Moments:**
1. **First "Next"**: User commits to creating job
2. **Last task complete**: Celebrate + suggest invoice
3. **Invoice sent**: Major accomplishment, big celebration

---

### Flow 3: Quick Actions from Dashboard

**Goal:** 1-tap access to common actions

```
Dashboard with Contextual Quick Actions

┌─────────────────────────────────────────────┐
│  Good morning, Pierre! 👋                   │
│                                             │
│  ┌─ Active Jobs ──────────────────────┐    │
│  │                                     │    │
│  │  📍 Dupont Residence                │    │
│  │  ⏱️ 2h 15m tracked                  │    │
│  │  [⏸️ Pause] [✓ Complete]            │    │
│  │                                     │    │
│  └─────────────────────────────────────┘    │
│                                             │
│  ┌─ Needs Attention ──────────────────┐    │
│  │                                     │    │
│  │  💰 Martin Invoice                  │    │
│  │     Overdue by 5 days               │    │
│  │     [Send Reminder]                 │    │
│  │                                     │    │
│  │  📋 Incomplete Quote                │    │
│  │     Started yesterday               │    │
│  │     [Continue Editing]              │    │
│  │                                     │    │
│  └─────────────────────────────────────┘    │
│                                             │
│  ┌─ Quick Actions ────────────────────┐    │
│  │  [+ Job] [+ Client] [+ Invoice]    │    │
│  └─────────────────────────────────────┘    │
│                                             │
│  ┌─ This Week ─────────────────────────┐   │
│  │  €2,450 revenue                     │    │
│  │  5 jobs completed                   │    │
│  │  2 invoices pending                 │    │
│  └─────────────────────────────────────┘    │
└─────────────────────────────────────────────┘

[🏠 Home] [📍 Sites] [👥 Clients] [💰 Money] [⋯ More]
```

**Smart Contextual Actions:**
- Active job → Show timer controls
- Completed job without invoice → Suggest creating invoice
- Overdue invoice → Show "Send Reminder" button
- Draft quote → Show "Continue Editing"
- No jobs today → Show "Create Job" prominently

---

### Flow 4: Error Recovery

**Goal:** Help users recover gracefully from errors

```
┌────────────────────────────────────────────────────────────┐
│ ERROR RECOVERY PATTERNS                                     │
└────────────────────────────────────────────────────────────┘

Scenario 1: Network Error While Sending Invoice

┌─────────────────────────────┐
│  Sending invoice...         │
│  [Spinner]                  │
└─────────────────────────────┘
↓ Network fails
┌─────────────────────────────┐
│        ⚠️                   │
│  Couldn't send invoice      │
│                             │
│  Check your internet        │
│  connection and try again.  │
│                             │
│  Your invoice has been      │
│  saved as a draft.          │
│                             │
│  [Try Again]                │
│  [View Draft]               │
└─────────────────────────────┘

Scenario 2: Form Validation Error

┌─────────────────────────────┐
│  New Client                 │
│                             │
│  Name:                      │
│  [Jean Dupont____]  ✓       │
│                             │
│  Email:                     │
│  [invalidemail___]  ❌      │
│  Please enter valid email   │
│                             │
│  Phone:                     │
│  [______________]           │
│                             │
│  [Create Client]            │
└─────────────────────────────┘
↓ Tap button
┌─────────────────────────────┐
│  ⚠️ Please fix errors:      │
│  • Valid email required     │
│                             │
│  [OK]                       │
└─────────────────────────────┘
↓ Focus on email field

Scenario 3: Delete Confirmation

┌─────────────────────────────┐
│  Delete this job?           │
│                             │
│  "Dupont Residence" and all │
│  associated data will be    │
│  permanently deleted.       │
│                             │
│  This cannot be undone.     │
│                             │
│  [Cancel]                   │
│  [Delete Job]               │
└─────────────────────────────┘
```

**Error Recovery Principles:**
1. **Explain what happened** (in plain language)
2. **Suggest what to do** (clear recovery action)
3. **Preserve user data** (save drafts, don't lose work)
4. **Provide alternatives** (multiple recovery paths)
5. **Learn and prevent** (improve validation, handle edge cases)

---

## Navigation Patterns

### Bottom Navigation Structure

```
Home (🏠)
├─ Dashboard
├─ Quick Stats
├─ Recent Activity
└─ Quick Actions

Sites (📍)
├─ Active Jobs
├─ Scheduled Jobs
├─ Completed Jobs
└─ [Tabs: Active | Scheduled | Complete | Archive]

Clients (👥)
├─ Client List
├─ Client Detail
│  ├─ Contact Info
│  ├─ Job History
│  ├─ Invoices
│  └─ Documents
└─ [Search & Filter]

Money (💰)
├─ Overview Dashboard
├─ Invoices
│  ├─ Paid
│  ├─ Pending
│  └─ Overdue
├─ Quotes
├─ Payments
└─ [Tabs: Invoices | Quotes | Payments]

More (⋯)
├─ Profile
├─ Company Settings
├─ Invoice Settings
├─ Reports & Analytics
├─ Products & Catalog
├─ Templates
├─ Tools
│  ├─ Scanner
│  ├─ Calculator
│  └─ Comparator
├─ Backup & Export
├─ Help & Support
└─ Log Out
```

---

## Animation Timing

### Micro-interactions
- Button press: 100ms
- Ripple effect: 200ms
- Card elevation: 200ms

### Transitions
- Page navigation: 300ms
- Modal appear: 250ms
- Bottom sheet: 300ms

### Feedback
- Success checkmark: 400ms (with elastic bounce)
- Loading spinner: Immediate (<50ms)
- Progress update: 200ms

### Celebrations
- Confetti: 2000ms
- Count-up animation: 800ms
- Success pulse: 600ms (repeat 2x)

---

## Accessibility Flows

### Screen Reader Navigation

```
Home Screen (Screen Reader ON)

1. Announces: "Dashboard. Heading."
2. Focus: "Good morning, Pierre. Text."
3. Focus: "Active jobs, 3. Button. Double tap to view."
4. Focus: "Pending invoices, 2. Button. Double tap to view."
5. Focus: "New job. Button. Double tap to create new job."
...
```

### Keyboard Navigation

```
Job Detail Form (Keyboard/External Input)

Tab Order:
1. [Back button]
2. Client dropdown
3. Add client button
4. Site address field
5. Current location button
6. Date picker
7. Time picker
8. Next button

Enter/Space: Activate buttons
Esc: Close modals/dropdowns
Arrow keys: Navigate lists
```

---

## Offline Behavior

```
Offline Mode Flow

1. User loses internet connection
   ↓
2. Banner appears:
   "You're offline. Changes will sync when reconnected."
   ↓
3. User continues working
   - Create jobs ✓ (saved locally)
   - Add photos ✓ (queued for upload)
   - Edit data ✓ (saved locally)
   - Send invoice ❌ (queued for sending)
   ↓
4. User reconnects
   ↓
5. Auto-sync
   "Syncing 3 changes..."
   [Progress bar]
   ↓
6. Success
   "✓ All changes synced"
   [Dismiss after 2s]
```

---

## Edge Cases to Handle

1. **Empty States**
   - No jobs yet
   - No clients yet
   - No invoices yet
   - Search returns no results
   - All filters applied, nothing matches

2. **Loading States**
   - Initial app load
   - Fetching list data
   - Submitting form
   - Uploading photos
   - Generating PDF

3. **Error States**
   - Network error
   - Server error (5xx)
   - Not found (404)
   - Unauthorized (401)
   - Validation errors
   - Timeout errors

4. **Success States**
   - Item created
   - Item updated
   - Item deleted
   - Email sent
   - Payment received

5. **Partial States**
   - Form partially filled (draft)
   - Upload partially complete
   - Some items synced, others failed

---

## Testing Checklist

### User Flow Testing

- [ ] Can complete onboarding in < 5 minutes
- [ ] Can create job from dashboard in < 2 minutes
- [ ] Can create invoice from completed job in < 1 minute
- [ ] Can find specific client in < 10 seconds
- [ ] Can navigate to any major section in < 3 taps
- [ ] Back button works on every screen
- [ ] No "trapped" pages (always can go back)

### Interaction Testing

- [ ] All buttons provide immediate feedback
- [ ] Form validation happens inline (not on submit)
- [ ] Loading states show within 50ms
- [ ] Success animations complete smoothly (60fps)
- [ ] Error messages are clear and actionable
- [ ] All touch targets are 48dp minimum

### Accessibility Testing

- [ ] Screen reader can navigate entire app
- [ ] All images have alt text
- [ ] All buttons have semantic labels
- [ ] Color is not sole means of conveying info
- [ ] Text scales properly (up to 200%)
- [ ] Focus indicators are visible

---

*Last Updated: November 2025*
