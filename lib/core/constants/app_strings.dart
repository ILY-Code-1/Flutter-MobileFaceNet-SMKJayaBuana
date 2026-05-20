class AppStrings {
  AppStrings._();

  // ---------- App ----------
  static const appName = 'Jaya Buana';
  static const appSubtitle = 'Attendance Studio';
  static const appVersion = 'v1.7.0';
  static const schoolFullName = 'JAYA BUANA';

  // ---------- Registration (01) ----------
  static const setupStep1 = 'FIRST-TIME SETUP · STEP 1 OF 2';
  static const setupStep2 = 'FIRST-TIME SETUP · STEP 2 OF 2';
  static const createAccountHeadline = "Let's create your";
  static const createAccountHeadlineEm = 'admin';
  static const createAccountHeadlineTail = ' account.';
  static const createAccountSub =
      "You'll use this to unlock settings, manage students and download reports.";
  static const pinHeadline = 'Now set a';
  static const pinHeadlineEm = '6-digit PIN';
  static const pinHeadlineTail = ' for quick admin access.';
  static const pinSub =
      'This PIN unlocks the admin menu from the camera screen.';
  static const labelUsername = 'USERNAME';
  static const labelPassword = 'PASSWORD';
  static const labelConfirmPassword = 'CONFIRM PASSWORD';
  static const labelPin = 'ADMIN PIN';
  static const labelConfirmPin = 'CONFIRM PIN';
  static const hintUsername = 'admin_smk';
  static const next = 'Next';
  static const createAccount = 'Create account';
  static const terminalAgreement =
      'By continuing you agree this device acts as the official attendance terminal.';

  // ---------- Camera Idle (02) ----------
  static const lookAtCamera = 'Look at the camera';
  static const keepFaceInside = 'Tap the gold button below to start the scan';
  static const ready = 'READY';
  static const scanning = 'SCANNING…';
  static const startScan = 'Start scan';

  // ---------- Password Gate (03) ----------
  static const adminAccessRequired = 'Admin access required';
  static const adminAccessSub =
      'Enter your PIN to open the admin menu and change attendance settings.';
  static const cancel = 'Cancel';
  static const unlock = 'Unlock';
  static const wrongPin = 'Wrong PIN. Try again.';

  // ---------- Menu (04) ----------
  static const helloHeadline = 'Hello, ';
  static const helloPrompt = 'What would you like to do?';
  static const tileStudents = 'Students';
  static const tileStudentsSub = 'enrolled this year';
  static const tileReports = 'Reports';
  static const tileSettings = 'Settings';
  static const tileSettingsSub = 'class · schedule · device';
  static const backToCamera = 'Back to camera';

  // ---------- Settings (05) ----------
  static const settings = 'Settings';
  static const sectionClasses = '01 · CLASSES';
  static const sectionClassesQ = 'Which classes does this device cover?';
  static const sectionClassesHint =
      'Tap a card to enable / disable a class for this terminal.';
  static const addClass = 'Add class';
  static const editClass = 'Edit class';
  static const deleteClass = 'Delete class';
  static const className = 'CLASS NAME';
  static const classNameHint =
      'Type any class or major code — e.g. "XII · AKL · B" or "X · Animation".';
  static const sectionSchedule = '02 · SCHEDULE';
  static const schoolHours = 'School hours';
  static const clockIn = 'CLOCK-IN';
  static const clockOut = 'CLOCK-OUT';
  static const lastCheckOut = 'LAST CHECK-OUT';
  static const schoolHoursHint =
      'Before clock-in → present. After clock-in + 1h → late. After last check-out → absent.';
  static const sectionDevice = '03 · THIS TERMINAL';
  static const deviceName = 'Device name';
  static const soundOnScan = 'Sound on scan';

  // ---------- Students (06) ----------
  static const students = 'Students';
  static const studentsHeading = 'faces';
  static const searchHint = 'Search by name or NIS…';
  static const enrollFace = 'Enroll face';
  static const filterAllClasses = 'All classes';

  // ---------- Add Student (07) ----------
  static const enrollNewFace = 'Enroll new face';
  static const editStudent = 'Edit student';
  static const stepLabel = 'STEP 1 OF 1';
  static const captureHeadline = 'Add the ';
  static const captureHeadlineEm = 'ID photo';
  static const captureHeadlineTail = " of the student.";
  static const captureSub =
      'Use a clear front-facing pas-foto. Good light, no mask, no glasses.';
  static const uploadPhoto = 'Upload photo';
  static const replacePhoto = 'Replace photo';
  static const processEmbed = 'Process embed';
  static const reprocessEmbed = 'Re-process embed';
  static const embedDone = 'Embedding ready';
  static const noFaceFound = 'No face detected — try another photo';
  static const fullName = 'FULL NAME';
  static const nis = 'NIS / STUDENT ID';
  static const classDropdownLabel = 'CLASS';
  static const saveDraft = 'Save draft';
  static const submit = 'Submit';

  // ---------- Recognized (08) ----------
  static const faceRecognized = 'FACE RECOGNIZED';
  static const faceNotRecognized = 'Face not recognized';
  static const faceNotRecognizedSub =
      "We couldn't find a matching student. Please contact the admin.";
  static const recognizedPrompt = 'What are you doing right now?';
  static const clockInBig = 'Clock-in';
  static const clockInSub = 'Arriving at school';
  static const clockOutBig = 'Clock-out';
  static const clockOutSub = 'Going home';
  static const alreadyDoneToday = 'Already checked-in and checked-out today.';
  static const tooEarlyClockOut =
      'Check-out is only open after the configured clock-out time.';
  static const tapToDismiss = 'Tap to dismiss';
  static const autoCancels = ' · auto-cancels in ';

  // ---------- Reports (09) ----------
  static const reports = 'Reports';
  static const attendance = 'Attendance';
  static const present = 'PRESENT';
  static const late = 'LATE';
  static const absent = 'ABSENT';
  static const colStudent = 'STUDENT';
  static const colP = 'P';
  static const colL = 'L';
  static const colA = 'A';
  static const colPct = '%';
  static const exportLabel = 'EXPORT';
  static const exportPdf = 'PDF';

  // ---------- Success (10) ----------
  static const clockedInSuccess = 'CLOCKED IN\nSUCCESSFULLY';
  static const clockedOutSuccess = 'CLOCKED OUT\nSUCCESSFULLY';
  static const welcomeName = 'Welcome, ';
  static const goodbyeName = 'See you, ';
  static const arrival = 'ARRIVAL';
  static const departure = 'DEPARTURE';
  static const status = 'STATUS';
  static const onTime = 'On time';
  static const successSub =
      'Have a wonderful day at school.\nThis screen returns to camera in ';

  // ---------- Dev nav ----------
  static const devNav = '_dev navigator';
}
