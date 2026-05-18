class AppStrings {
  AppStrings._();

  // ---------- App ----------
  static const appName = 'Jaya Buana';
  static const appSubtitle = 'Attendance Studio';
  static const appVersion = 'v1.4.2';
  static const schoolFullName = 'JAYA BUANA';

  // ---------- Registration (01) ----------
  static const setupStep = 'FIRST-TIME SETUP · STEP 1 OF 1';
  static const createAccountHeadline = "Let's create your";
  static const createAccountHeadlineEm = 'admin';
  static const createAccountHeadlineTail = ' account.';
  static const createAccountSub =
      "You'll use this to unlock settings, manage students and download reports.";
  static const labelUsername = 'USERNAME';
  static const labelPassword = 'PASSWORD';
  static const labelConfirmPassword = 'CONFIRM PASSWORD';
  static const hintUsername = 'bu_rini';
  static const createAccount = 'Create account';
  static const terminalAgreement =
      'By continuing you agree this device acts as the official attendance terminal.';
  static const strengthStrong = 'Strong';
  static const strengthStrongTail = ' — nice and memorable.';

  // ---------- Camera Idle (02) ----------
  static const classLabel = 'Class XI RPL · A';
  static const lookAtCamera = 'Look at the camera';
  static const keepFaceInside = 'Keep your face inside the gold frame';
  static const ready = 'READY';
  static const checkedSummary = '26 / 32 checked\nin today';

  // ---------- Password Gate (03) ----------
  static const adminAccessRequired = 'Admin access required';
  static const adminAccessSub =
      'Enter your password to open the menu and change attendance settings.';
  static const cancel = 'Cancel';
  static const unlock = 'Unlock';

  // ---------- Menu (04) ----------
  static const todayLabel = 'TUESDAY, 14 JUNE';
  static const helloHeadline = 'Hello, ';
  static const helloName = 'Bu Rini';
  static const helloPrompt = 'What would you like to do?';
  static const tileStudents = 'Students';
  static const tileStudentsSub = 'enrolled this year';
  static const tileReports = 'Reports';
  static const tileReportsMonth = 'June';
  static const tileReportsPct = '94% attendance';
  static const tileSettings = 'Settings';
  static const tileSettingsSub = 'class · schedule · device';
  static const signOut = 'Sign out admin';

  // ---------- Settings (05) ----------
  static const settings = 'Settings';
  static const sectionClass = '01 · CLASS';
  static const whichClassQ = 'Which class does this device cover?';
  static const gradeTenth = 'Tenth Grade';
  static const gradeEleventh = 'Eleventh';
  static const gradeTwelfth = 'Twelfth';
  static const gradeTenthSub = '48 students';
  static const gradeEleventhSub = '52 students';
  static const gradeTwelfthSub = '42 students';
  static const className = 'CLASS NAME';
  static const classNameValue = 'XI · RPL · A';
  static const edit = 'EDIT';
  static const classNameHint =
      'Type any class or major code — e.g. "XII · AKL · B" or "X · Animation".';
  static const sectionSchedule = '02 · SCHEDULE';
  static const schoolHours = 'School hours';
  static const clockIn = 'CLOCK-IN';
  static const clockOut = 'CLOCK-OUT';
  static const gateOpens = 'gate opens 06:30';
  static const gateCloses = 'gate closes 16:00';
  static const lateTolerance = 'Late tolerance';
  static const lateToleranceSub = 'Mark as "late" after this many minutes.';
  static const min = 'min';
  static const sectionDevice = '03 · DEVICE';
  static const thisTerminal = 'This terminal';
  static const deviceName = 'Device name';
  static const deviceNameValue = 'Gate-1 · Lab building';
  static const soundOnScan = 'Sound on scan';
  static const soundOnScanValue = 'Soft chime';

  // ---------- Students (06) ----------
  static const students = 'Students';
  static const studentsHeading = 'faces';
  static const studentsCheckedSub = '26 checked in today';
  static const searchHint = 'Search by name or NIS…';
  static const enrollFace = 'Enroll face';
  static const statusIn = 'IN';
  static const statusLate = 'LATE';
  static const statusAbsent = 'ABSENT';

  // ---------- Add Student (07) ----------
  static const enrollNewFace = 'Enroll new face';
  static const stepLabel = 'STEP 2 OF 3';
  static const captureHeadline = 'Capture ';
  static const captureHeadlineEm = 'three angles';
  static const captureHeadlineTail = " of the student's face.";
  static const captureSub =
      'Front, slight left, slight right. Good light, no mask, no glasses.';
  static const angleFront = 'FRONT';
  static const angleLeft = 'LEFT';
  static const angleRight = 'RIGHT';
  static const fullName = 'FULL NAME';
  static const fullNameValue = 'Chika Maharani';
  static const nis = 'NIS / STUDENT ID';
  static const nisValue = '2401007';
  static const saveDraft = 'Save draft';
  static const submit = 'Submit';

  // ---------- Recognized (08) ----------
  static const faceRecognized = 'FACE RECOGNIZED · 98% CONFIDENCE';
  static const recognizedTime = '07:14 · on time';
  static const recognizedPrompt = 'What are you doing right now?';
  static const clockInBig = 'Clock-in';
  static const clockInSub = 'Arriving at school';
  static const clockOutBig = 'Clock-out';
  static const clockOutSub = 'Going home';
  static const notYouTap = 'Not you? ';
  static const tapToDismiss = 'Tap to dismiss';
  static const autoCancels = ' · auto-cancels in 8s';

  // ---------- Reports (09) ----------
  static const reports = 'Reports';
  static const attendance = 'Attendance';
  static const reportMonth = 'June 2026';
  static const present = 'PRESENT';
  static const late = 'LATE';
  static const absent = 'ABSENT';
  static const colStudent = 'STUDENT';
  static const colP = 'P';
  static const colL = 'L';
  static const colA = 'A';
  static const colPct = '%';
  static const exportLabel = 'EXPORT';
  static const exportSummary = 'June 2026 · 32 students';
  static const exportPdf = 'PDF';

  // ---------- Success (10) ----------
  static const clockedInSuccess = 'CLOCKED IN\nSUCCESSFULLY';
  static const welcomeName = 'Welcome, ';
  static const welcomeChika = 'Chika';
  static const arrival = 'ARRIVAL';
  static const arrivalTime = '07:14 AM';
  static const status = 'STATUS';
  static const onTime = 'On time';
  static const successSub =
      'Have a wonderful day at school.\nThis screen returns to camera in ';
  static const successCountdown = '3s';

  // ---------- Dev nav ----------
  static const devNav = '_dev navigator';
}
