import React, { useState } from 'react';
import {
  Home,
  Calendar,
  ClipboardList,
  Users,
  User as UserIcon,
  Moon,
  Sun,
  Shield,
  Clock,
  MapPin,
  ChevronRight,
  RefreshCw,
  FolderTree,
  Terminal,
  Smartphone,
  ExternalLink,
  BookOpen,
  Copy,
  Check,
  Lock,
  Eye,
  EyeOff,
  LogOut,
  AlertTriangle,
  KeyRound,
  Server,
  UserPlus,
  CheckCircle2,
  XCircle,
  Search,
  CheckSquare,
  Square,
  HelpCircle,
  Database,
  Code2,
  Filter,
  Layers,
  ArrowLeft,
  Trash2,
  Sparkles
} from 'lucide-react';

interface MockUser {
  id: number;
  username: string;
  name: string;
  role: 'ADMIN' | 'MAHASISWA';
  discordUserId: string;
  discordUsername: string;
}

interface MockAccountRequest {
  id: number;
  username: string;
  name: string;
  discordUserId: string;
  discordUsername: string;
  status: 'PENDING' | 'APPROVED' | 'REJECTED';
  rejectionReason?: string;
  requestedAt: string;
}

interface MockSchedule {
  id: number;
  courseName: string;
  courseCode: string;
  lecturer: string;
  className: string;
  room: string;
  day: 'Senin' | 'Selasa' | 'Rabu' | 'Kamis' | 'Jumat';
  startTime: string;
  endTime: string;
}

interface MockDeadline {
  id: number;
  course: string;
  title: string;
  description: string;
  dueAt: string;
  priority: 'HIGH' | 'NORMAL' | 'LOW';
  completed?: boolean;
}

interface MockGroup {
  id: number;
  groupNumber: number;
  subject: string;
  ownerId: string;
  ownerName: string;
  members: Array<{ discordUserId: string; discordUsername: string }>;
}

export default function App() {
  // Navigation & UI States
  const [activeTab, setActiveTab] = useState<'home' | 'schedule' | 'tasks' | 'groups' | 'profile'>('home');
  const [isDarkMode, setIsDarkMode] = useState(false);
  const [scheduleSubTab, setScheduleSubTab] = useState<'today' | 'weekly'>('today');
  const [selectedDayFilter, setSelectedDayFilter] = useState<string>('Semua');
  const [taskFilter, setTaskFilter] = useState<'Semua' | 'Tinggi' | 'Normal' | 'Selesai'>('Semua');
  const [taskSearch, setTaskSearch] = useState('');
  const [groupFilterMyOnly, setGroupFilterMyOnly] = useState(false);
  const [groupSearch, setGroupSearch] = useState('');
  const [viewMode, setViewMode] = useState<'device' | 'backend' | 'architecture' | 'code' | 'commands'>('device');
  const [selectedFile, setSelectedFile] = useState<string>('lib/services/account_request_service.dart');
  const [copiedFile, setCopiedFile] = useState(false);
  const [showAdminPanel, setShowAdminPanel] = useState(false);
  const [adminActiveTab, setAdminActiveTab] = useState<'requests' | 'users'>('requests');

  // Authentication State
  const [isLoggedIn, setIsLoggedIn] = useState(true);
  const [currentUser, setCurrentUser] = useState<MockUser>({
    id: 1,
    username: 'admin_if03',
    name: 'Nadyaka Shafwana (Admin)',
    role: 'ADMIN',
    discordUserId: '123456789012345678',
    discordUsername: 'nadyaka',
  });

  // Login Form States inside Emulator
  const [inputUsername, setInputUsername] = useState('admin_if03');
  const [inputPassword, setInputPassword] = useState('admin_if03_secret_2026');
  const [showPassword, setShowPassword] = useState(false);
  const [loginLoading, setLoginLoading] = useState(false);
  const [loginError, setLoginError] = useState<string | null>(null);
  const [showLogoutConfirm, setShowLogoutConfirm] = useState(false);
  const [screenMode, setScreenMode] = useState<'main' | 'request_form'>('main');

  // Account Request Form States (Phase 3)
  const [reqFullName, setReqFullName] = useState('');
  const [reqUsername, setReqUsername] = useState('');
  const [reqDiscordId, setReqDiscordId] = useState('');
  const [reqDiscordUsername, setReqDiscordUsername] = useState('');
  const [reqPassword, setReqPassword] = useState('');
  const [reqConfirmPassword, setReqConfirmPassword] = useState('');
  const [reqLoading, setReqLoading] = useState(false);
  const [reqSuccessModal, setReqSuccessModal] = useState(false);
  const [showDiscordHelpModal, setShowDiscordHelpModal] = useState(false);
  const [reqError, setReqError] = useState<string | null>(null);

  // Mock Database in Memory
  const [accountRequests, setAccountRequests] = useState<MockAccountRequest[]>([
    {
      id: 1,
      username: 'budi_santoso',
      name: 'Budi Santoso',
      discordUserId: '987654321012345678',
      discordUsername: 'budisantoso#1234',
      status: 'PENDING',
      requestedAt: '2026-09-24 10:15:00',
    },
    {
      id: 2,
      username: 'citra_ayu',
      name: 'Citra Ayu Lestari',
      discordUserId: '876543210987654321',
      discordUsername: 'citraayu',
      status: 'APPROVED',
      requestedAt: '2026-09-23 14:20:00',
    },
    {
      id: 3,
      username: 'fake_account',
      name: 'Unknown User',
      discordUserId: '111111111111111111',
      discordUsername: 'spammer#9999',
      status: 'REJECTED',
      rejectionReason: 'Bukan mahasiswa kelas IF03',
      requestedAt: '2026-09-22 09:00:00',
    },
  ]);

  const [usersList, setUsersList] = useState<MockUser[]>([
    {
      id: 1,
      username: 'admin_if03',
      name: 'Nadyaka Shafwana (Admin)',
      role: 'ADMIN',
      discordUserId: '123456789012345678',
      discordUsername: 'nadyaka',
    },
    {
      id: 2,
      username: 'citra_ayu',
      name: 'Citra Ayu Lestari',
      role: 'MAHASISWA',
      discordUserId: '876543210987654321',
      discordUsername: 'citraayu',
    },
    {
      id: 3,
      username: 'fajar_fadilah',
      name: 'Fajar Fadilah',
      role: 'MAHASISWA',
      discordUserId: '234567890123456789',
      discordUsername: 'fajar_f',
    },
  ]);

  // Phase 4: Jadwal Kuliah (from jadwalkampusku.my.id)
  const schedules: MockSchedule[] = [
    {
      id: 1,
      courseName: 'Statistika & Probabilitas',
      courseCode: 'IF-202',
      lecturer: 'Dr. Hendra M.T.',
      className: 'IF-03',
      room: 'KU3.05',
      day: 'Senin',
      startTime: '10:00',
      endTime: '12:00',
    },
    {
      id: 2,
      courseName: 'Pemrograman Web Lanjut',
      courseCode: 'IF-301',
      lecturer: 'Rian Pratama, M.Kom.',
      className: 'IF-03',
      room: 'Lab Komputer 2',
      day: 'Senin',
      startTime: '13:00',
      endTime: '15:30',
    },
    {
      id: 3,
      courseName: 'Rekayasa Perangkat Lunak',
      courseCode: 'IF-304',
      lecturer: 'Ir. Siti Rahma, M.Cs.',
      className: 'IF-03',
      room: 'KU2.10',
      day: 'Selasa',
      startTime: '08:00',
      endTime: '10:30',
    },
    {
      id: 4,
      courseName: 'Jaringan Komputer & Komunikasi Data',
      courseCode: 'IF-205',
      lecturer: 'Agus Wijaya, S.T., M.Eng.',
      className: 'IF-03',
      room: 'Lab Jaringan',
      day: 'Rabu',
      startTime: '09:00',
      endTime: '11:30',
    },
    {
      id: 5,
      courseName: 'Sistem Basis Data',
      courseCode: 'IF-206',
      lecturer: 'Dewi Lestari, S.Kom., M.T.',
      className: 'IF-03',
      room: 'KU3.02',
      day: 'Kamis',
      startTime: '10:00',
      endTime: '12:30',
    },
    {
      id: 6,
      courseName: 'Kecerdasan Buatan (AI)',
      courseCode: 'IF-401',
      lecturer: 'Prof. Bambang Utomo',
      className: 'IF-03',
      room: 'KU1.08',
      day: 'Jumat',
      startTime: '08:00',
      endTime: '10:00',
    },
  ];

  // Phase 5: Tugas & Deadline
  const [deadlines, setDeadlines] = useState<MockDeadline[]>([
    {
      id: 1,
      course: 'Statistika & Probabilitas',
      title: 'PPT Statistika & Analisis Uji Hipotesis',
      description: 'Presentasi hasil pengujian sampel data kuesioner menggunakan regresi linear ganda.',
      dueAt: 'Besok, 25 Sep 2026 (10:00 WIB)',
      priority: 'HIGH',
      completed: false,
    },
    {
      id: 2,
      course: 'Pemrograman Web Lanjut',
      title: 'Praktikum REST API Express.js & SQLite',
      description: 'Implementasi middleware otentikasi JWT Bearer dan hash password bcrypt pada endpoint auth.',
      dueAt: '28 Sep 2026 (23:59 WIB)',
      priority: 'NORMAL',
      completed: false,
    },
    {
      id: 3,
      course: 'Rekayasa Perangkat Lunak',
      title: 'Dokumen SRS & Diagram UML Lengkap',
      description: 'Dokumen Spesifikasi Kebutuhan Perangkat Lunak IEEE 830, Use Case Diagram, & Sequence Diagram.',
      dueAt: '02 Okt 2026 (12:00 WIB)',
      priority: 'NORMAL',
      completed: true,
    },
    {
      id: 4,
      course: 'Jaringan Komputer',
      title: 'Laporan Subnetting VLSM Cisco Packet Tracer',
      description: 'Desain topologi 3 gedung dengan pembagian subnetting kelas B & C.',
      dueAt: '05 Okt 2026 (17:00 WIB)',
      priority: 'LOW',
      completed: false,
    },
  ]);

  // Phase 6: Kelompok Mahasiswa
  const groups: MockGroup[] = [
    {
      id: 1,
      groupNumber: 3,
      subject: 'Statistika & Probabilitas',
      ownerId: '987654321012345678',
      ownerName: 'budi_santoso',
      members: [
        { discordUserId: '987654321012345678', discordUsername: 'budi_santoso' },
        { discordUserId: '123456789012345678', discordUsername: 'nadyaka' },
        { discordUserId: '234567890123456789', discordUsername: 'fajar_f' },
        { discordUserId: '345678901234567890', discordUsername: 'dimas_arya' },
      ],
    },
    {
      id: 2,
      groupNumber: 1,
      subject: 'Pemrograman Web Lanjut',
      ownerId: '876543210987654321',
      ownerName: 'citraayu',
      members: [
        { discordUserId: '876543210987654321', discordUsername: 'citraayu' },
        { discordUserId: '456789012345678901', discordUsername: 'gilang_ramadhan' },
        { discordUserId: '567890123456789012', discordUsername: 'rizki_febrian' },
      ],
    },
    {
      id: 3,
      groupNumber: 5,
      subject: 'Rekayasa Perangkat Lunak',
      ownerId: '123456789012345678',
      ownerName: 'nadyaka',
      members: [
        { discordUserId: '123456789012345678', discordUsername: 'nadyaka' },
        { discordUserId: '678901234567890123', discordUsername: 'hani_wijaya' },
        { discordUserId: '789012345678901234', discordUsername: 'indra_kurnia' },
      ],
    },
  ];

  // Toggle deadline completion
  const handleToggleDeadline = (id: number) => {
    setDeadlines(prev => prev.map(d => (d.id === id ? { ...d, completed: !d.completed } : d)));
  };

  // Submit Account Request
  const handleSubmitAccountRequest = (e: React.FormEvent) => {
    e.preventDefault();
    setReqError(null);

    if (!reqFullName.trim() || !reqUsername.trim() || !reqDiscordId.trim() || !reqDiscordUsername.trim() || !reqPassword) {
      setReqError('Semua field wajib diisi!');
      return;
    }

    if (!/^\d{17,19}$/.test(reqDiscordId.trim())) {
      setReqError('Discord User ID tidak valid. Harus berupa 17-19 digit angka!');
      return;
    }

    if (reqPassword.length < 6) {
      setReqError('Password minimal 6 karakter!');
      return;
    }

    if (reqPassword !== reqConfirmPassword) {
      setReqError('Konfirmasi password tidak cocok!');
      return;
    }

    setReqLoading(true);
    setTimeout(() => {
      const newReq: MockAccountRequest = {
        id: accountRequests.length + 1,
        username: reqUsername.trim().toLowerCase(),
        name: reqFullName.trim(),
        discordUserId: reqDiscordId.trim(),
        discordUsername: reqDiscordUsername.trim(),
        status: 'PENDING',
        requestedAt: new Date().toISOString().replace('T', ' ').substring(0, 19),
      };

      setAccountRequests([newReq, ...accountRequests]);
      setReqLoading(false);
      setReqSuccessModal(true);
    }, 600);
  };

  // Admin Actions
  const handleApproveRequest = (req: MockAccountRequest) => {
    setAccountRequests(prev =>
      prev.map(r => (r.id === req.id ? { ...r, status: 'APPROVED' } : r))
    );
    // Add to active users
    if (!usersList.some(u => u.username === req.username)) {
      setUsersList(prev => [
        ...prev,
        {
          id: usersList.length + 1,
          username: req.username,
          name: req.name,
          role: 'MAHASISWA',
          discordUserId: req.discordUserId,
          discordUsername: req.discordUsername,
        },
      ]);
    }
  };

  const handleRejectRequest = (id: number) => {
    const reason = window.prompt('Alasan penolakan:', 'Bukan mahasiswa aktif IF03');
    if (reason !== null) {
      setAccountRequests(prev =>
        prev.map(r => (r.id === id ? { ...r, status: 'REJECTED', rejectionReason: reason } : r))
      );
    }
  };

  const handleToggleUserRole = (id: number) => {
    setUsersList(prev =>
      prev.map(u => (u.id === id ? { ...u, role: u.role === 'ADMIN' ? 'MAHASISWA' : 'ADMIN' } : u))
    );
  };

  const handleDeleteUser = (id: number) => {
    if (confirm('Hapus pengguna ini dari database?')) {
      setUsersList(prev => prev.filter(u => u.id !== id));
    }
  };

  // Switch Quick User Preset
  const handleSwitchPreset = (type: 'admin' | 'student' | 'pending') => {
    if (type === 'admin') {
      const admin = usersList.find(u => u.username === 'admin_if03') || {
        id: 1,
        username: 'admin_if03',
        name: 'Nadyaka Shafwana (Admin)',
        role: 'ADMIN' as const,
        discordUserId: '123456789012345678',
        discordUsername: 'nadyaka',
      };
      setCurrentUser(admin);
      setIsLoggedIn(true);
      setShowAdminPanel(false);
    } else if (type === 'student') {
      const student = usersList.find(u => u.username === 'citra_ayu') || {
        id: 2,
        username: 'citra_ayu',
        name: 'Citra Ayu Lestari',
        role: 'MAHASISWA' as const,
        discordUserId: '876543210987654321',
        discordUsername: 'citraayu',
      };
      setCurrentUser(student);
      setIsLoggedIn(true);
      setShowAdminPanel(false);
    } else {
      setIsLoggedIn(false);
      setInputUsername('budi_santoso');
      setInputPassword('password123');
      setLoginError('Permohonan akun kamu masih menunggu persetujuan admin.');
    }
  };

  // Login handler
  const handleLogin = (e: React.FormEvent) => {
    e.preventDefault();
    setLoginError(null);
    setLoginLoading(true);

    setTimeout(() => {
      setLoginLoading(false);
      const cleanUser = inputUsername.trim().toLowerCase();

      // Check pending
      const req = accountRequests.find(r => r.username.toLowerCase() === cleanUser);
      if (req && req.status === 'PENDING') {
        setLoginError('Permohonan akun kamu masih menunggu persetujuan admin.');
        return;
      }
      if (req && req.status === 'REJECTED') {
        setLoginError(`Permohonan akun ditolak: ${req.rejectionReason || 'Tidak valid.'}`);
        return;
      }

      // Check user
      const user = usersList.find(u => u.username.toLowerCase() === cleanUser);
      if (user) {
        setCurrentUser(user);
        setIsLoggedIn(true);
        setScreenMode('main');
      } else {
        setLoginError('Username atau password salah.');
      }
    }, 400);
  };

  // Filtered Deadlines
  const filteredDeadlines = deadlines.filter(d => {
    if (taskFilter === 'Selesai') return d.completed;
    if (taskFilter !== 'Semua' && d.completed) return false;
    if (taskFilter === 'Tinggi') return d.priority === 'HIGH';
    if (taskFilter === 'Normal') return d.priority === 'NORMAL';
    if (taskSearch.trim()) {
      const q = taskSearch.toLowerCase();
      return d.title.toLowerCase().includes(q) || d.course.toLowerCase().includes(q);
    }
    return true;
  });

  // Filtered Groups
  const filteredGroups = groups.filter(g => {
    const isMember = g.members.some(m => m.discordUserId === currentUser.discordUserId || m.discordUsername.toLowerCase() === currentUser.username.toLowerCase());
    const isOwner = g.ownerId === currentUser.discordUserId || g.ownerName.toLowerCase() === currentUser.username.toLowerCase();
    if (groupFilterMyOnly && !isMember && !isOwner) return false;

    if (groupSearch.trim()) {
      const q = groupSearch.toLowerCase();
      return (
        g.subject.toLowerCase().includes(q) ||
        `kelompok ${g.groupNumber}`.includes(q) ||
        g.members.some(m => m.discordUsername.toLowerCase().includes(q))
      );
    }
    return true;
  });

  // Filtered Schedule
  const filteredWeeklySchedules = selectedDayFilter === 'Semua'
    ? schedules
    : schedules.filter(s => s.day === selectedDayFilter);

  return (
    <div className="min-h-screen bg-slate-950 text-slate-100 flex flex-col">
      {/* Top Header */}
      <header className="border-b border-slate-800 bg-slate-900/90 backdrop-blur px-6 py-3 flex items-center justify-between sticky top-0 z-40">
        <div className="flex items-center space-x-3">
          <div className="w-10 h-10 rounded-xl bg-gradient-to-tr from-indigo-600 via-blue-500 to-teal-400 flex items-center justify-center shadow-lg shadow-indigo-500/25">
            <BookOpen className="w-5 h-5 text-white" />
          </div>
          <div>
            <div className="flex items-center space-x-2">
              <h1 className="font-bold text-lg tracking-tight text-white">IF03 Academic</h1>
              <span className="px-2 py-0.5 text-xs font-semibold bg-emerald-500/10 text-emerald-400 border border-emerald-500/20 rounded-full">
                Phase 1-7 Ready
              </span>
            </div>
            <p className="text-xs text-slate-400">Pusat Informasi Akademik & Bot VPS Synchronization</p>
          </div>
        </div>

        {/* View Switcher Bar */}
        <div className="flex items-center bg-slate-800/80 p-1 rounded-xl border border-slate-700/60">
          <button
            onClick={() => setViewMode('device')}
            className={`flex items-center space-x-2 px-3 py-1.5 rounded-lg text-xs font-semibold transition ${
              viewMode === 'device' ? 'bg-indigo-600 text-white shadow-md' : 'text-slate-400 hover:text-white'
            }`}
          >
            <Smartphone className="w-4 h-4" />
            <span>Mobile Emulator</span>
          </button>
          <button
            onClick={() => setViewMode('backend')}
            className={`flex items-center space-x-2 px-3 py-1.5 rounded-lg text-xs font-semibold transition ${
              viewMode === 'backend' ? 'bg-indigo-600 text-white shadow-md' : 'text-slate-400 hover:text-white'
            }`}
          >
            <Database className="w-4 h-4" />
            <span>VPS SQLite & API</span>
          </button>
          <button
            onClick={() => setViewMode('architecture')}
            className={`flex items-center space-x-2 px-3 py-1.5 rounded-lg text-xs font-semibold transition ${
              viewMode === 'architecture' ? 'bg-indigo-600 text-white shadow-md' : 'text-slate-400 hover:text-white'
            }`}
          >
            <Layers className="w-4 h-4" />
            <span>Arsitektur Sistem</span>
          </button>
          <button
            onClick={() => setViewMode('code')}
            className={`flex items-center space-x-2 px-3 py-1.5 rounded-lg text-xs font-semibold transition ${
              viewMode === 'code' ? 'bg-indigo-600 text-white shadow-md' : 'text-slate-400 hover:text-white'
            }`}
          >
            <Code2 className="w-4 h-4" />
            <span>Source Code Flutter</span>
          </button>
          <button
            onClick={() => setViewMode('commands')}
            className={`flex items-center space-x-2 px-3 py-1.5 rounded-lg text-xs font-semibold transition ${
              viewMode === 'commands' ? 'bg-indigo-600 text-white shadow-md' : 'text-slate-400 hover:text-white'
            }`}
          >
            <Terminal className="w-4 h-4" />
            <span>Deploy VPS Bot</span>
          </button>
        </div>

        {/* Quick User Presets for Testing */}
        <div className="flex items-center space-x-2">
          <span className="text-xs text-slate-400 font-medium hidden md:inline">Test Role:</span>
          <button
            onClick={() => handleSwitchPreset('admin')}
            className={`px-2.5 py-1 text-xs font-semibold rounded-lg border transition ${
              currentUser.role === 'ADMIN' && isLoggedIn
                ? 'bg-amber-500/20 text-amber-300 border-amber-500/40 shadow-sm'
                : 'bg-slate-800 text-slate-300 border-slate-700 hover:bg-slate-700'
            }`}
            title="Login as Admin (Nadyaka Shafwana)"
          >
            🛡️ Admin
          </button>
          <button
            onClick={() => handleSwitchPreset('student')}
            className={`px-2.5 py-1 text-xs font-semibold rounded-lg border transition ${
              currentUser.role === 'MAHASISWA' && isLoggedIn
                ? 'bg-indigo-500/20 text-indigo-300 border-indigo-500/40 shadow-sm'
                : 'bg-slate-800 text-slate-300 border-slate-700 hover:bg-slate-700'
            }`}
            title="Login as Regular Student (Citra Ayu)"
          >
            🎓 Mahasiswa
          </button>
          <button
            onClick={() => handleSwitchPreset('pending')}
            className="px-2.5 py-1 text-xs font-semibold rounded-lg border bg-slate-800 text-amber-400 border-amber-500/30 hover:bg-amber-950/40"
            title="Simulate Pending Account Request"
          >
            ⏳ Pending User
          </button>
        </div>
      </header>

      {/* Main Content Area */}
      <main className="flex-1 overflow-auto p-6 flex justify-center items-start">
        {/* VIEW 1: MOBILE DEVICE EMULATOR */}
        {viewMode === 'device' && (
          <div className="flex flex-col items-center">
            {/* Emulator Phone Frame */}
            <div className="w-[390px] h-[780px] bg-slate-900 rounded-[44px] p-3 shadow-2xl shadow-indigo-950/60 border-4 border-slate-700 flex flex-col relative overflow-hidden">
              {/* Phone Speaker & Camera Notch */}
              <div className="absolute top-0 left-1/2 -translate-x-1/2 h-6 w-36 bg-slate-800 rounded-b-2xl z-50 flex items-center justify-center">
                <div className="w-12 h-1 bg-slate-600 rounded-full" />
                <div className="w-2.5 h-2.5 bg-slate-900 rounded-full ml-3" />
              </div>

              {/* Mobile Screen Container */}
              <div
                className={`flex-1 rounded-[36px] overflow-hidden flex flex-col relative transition-colors duration-200 ${
                  isDarkMode ? 'bg-slate-950 text-slate-100' : 'bg-slate-50 text-slate-900'
                }`}
              >
                {/* Status Bar */}
                <div className="h-10 pt-2 px-6 flex items-center justify-between text-xs font-semibold opacity-75 select-none z-30">
                  <span>10:30</span>
                  <div className="flex items-center space-x-1.5">
                    <span className="text-[10px]">5G</span>
                    <div className="w-4 h-2 border border-current rounded-sm flex items-center p-0.5">
                      <div className="w-full h-full bg-current rounded-2xs" />
                    </div>
                  </div>
                </div>

                {/* APP CONTENT: SCREEN ROUTING */}
                {!isLoggedIn ? (
                  // SCREEN: LOGIN OR ACCOUNT REQUEST FORM
                  screenMode === 'request_form' ? (
                    // SCREEN: ACCOUNT REQUEST FORM (PHASE 3)
                    <div className="flex-1 flex flex-col overflow-y-auto p-5">
                      <div className="flex items-center space-x-2 mb-4">
                        <button
                          onClick={() => setScreenMode('main')}
                          className="p-1.5 rounded-xl hover:bg-slate-200 dark:hover:bg-slate-800 text-slate-600 dark:text-slate-300"
                        >
                          <ArrowLeft className="w-5 h-5" />
                        </button>
                        <h2 className="font-bold text-base">Permohonan Akun</h2>
                      </div>

                      {/* Information Box */}
                      <div className="bg-indigo-500/10 border border-indigo-500/20 rounded-xl p-3 mb-4 text-xs text-indigo-700 dark:text-indigo-300 flex items-start space-x-2">
                        <AlertTriangle className="w-4 h-4 shrink-0 mt-0.5 text-indigo-500" />
                        <span>Akun IF03 Academic diverifikasi langsung oleh Admin kelas via Discord ID.</span>
                      </div>

                      {reqError && (
                        <div className="bg-rose-500/10 border border-rose-500/30 text-rose-500 rounded-xl p-2.5 text-xs mb-3">
                          {reqError}
                        </div>
                      )}

                      <form onSubmit={handleSubmitAccountRequest} className="space-y-3 text-xs">
                        <div>
                          <label className="font-semibold block mb-1">Nama Lengkap</label>
                          <input
                            type="text"
                            placeholder="Contoh: Budi Santoso"
                            value={reqFullName}
                            onChange={e => setReqFullName(e.target.value)}
                            className={`w-full p-2.5 rounded-xl border outline-none ${
                              isDarkMode ? 'bg-slate-900 border-slate-700 text-white' : 'bg-white border-slate-200'
                            }`}
                          />
                        </div>

                        <div>
                          <label className="font-semibold block mb-1">Username (Login APK)</label>
                          <input
                            type="text"
                            placeholder="Contoh: budi_santoso"
                            value={reqUsername}
                            onChange={e => setReqUsername(e.target.value)}
                            className={`w-full p-2.5 rounded-xl border outline-none ${
                              isDarkMode ? 'bg-slate-900 border-slate-700 text-white' : 'bg-white border-slate-200'
                            }`}
                          />
                        </div>

                        <div>
                          <div className="flex justify-between items-center mb-1">
                            <label className="font-semibold">Discord User ID (17-19 Digit)</label>
                            <button
                              type="button"
                              onClick={() => setShowDiscordHelpModal(true)}
                              className="text-indigo-500 hover:underline flex items-center space-x-1"
                            >
                              <HelpCircle className="w-3.5 h-3.5" />
                              <span>Cara Cek?</span>
                            </button>
                          </div>
                          <input
                            type="text"
                            placeholder="Contoh: 987654321012345678"
                            value={reqDiscordId}
                            onChange={e => setReqDiscordId(e.target.value)}
                            className={`w-full p-2.5 rounded-xl border outline-none font-mono ${
                              isDarkMode ? 'bg-slate-900 border-slate-700 text-white' : 'bg-white border-slate-200'
                            }`}
                          />
                        </div>

                        <div>
                          <label className="font-semibold block mb-1">Discord Username / Handle</label>
                          <input
                            type="text"
                            placeholder="Contoh: budi#1234 atau budisantoso"
                            value={reqDiscordUsername}
                            onChange={e => setReqDiscordUsername(e.target.value)}
                            className={`w-full p-2.5 rounded-xl border outline-none ${
                              isDarkMode ? 'bg-slate-900 border-slate-700 text-white' : 'bg-white border-slate-200'
                            }`}
                          />
                        </div>

                        <div>
                          <label className="font-semibold block mb-1">Password</label>
                          <input
                            type="password"
                            placeholder="Minimal 6 karakter"
                            value={reqPassword}
                            onChange={e => setReqPassword(e.target.value)}
                            className={`w-full p-2.5 rounded-xl border outline-none ${
                              isDarkMode ? 'bg-slate-900 border-slate-700 text-white' : 'bg-white border-slate-200'
                            }`}
                          />
                        </div>

                        <div>
                          <label className="font-semibold block mb-1">Konfirmasi Password</label>
                          <input
                            type="password"
                            placeholder="Ketik ulang password"
                            value={reqConfirmPassword}
                            onChange={e => setReqConfirmPassword(e.target.value)}
                            className={`w-full p-2.5 rounded-xl border outline-none ${
                              isDarkMode ? 'bg-slate-900 border-slate-700 text-white' : 'bg-white border-slate-200'
                            }`}
                          />
                        </div>

                        <button
                          type="submit"
                          disabled={reqLoading}
                          className="w-full mt-4 py-3 bg-indigo-600 hover:bg-indigo-700 text-white font-bold rounded-xl shadow-lg transition flex items-center justify-center space-x-2"
                        >
                          {reqLoading ? (
                            <RefreshCw className="w-4 h-4 animate-spin" />
                          ) : (
                            <>
                              <UserPlus className="w-4 h-4" />
                              <span>KIRIM PERMOHONAN AKUN</span>
                            </>
                          )}
                        </button>
                      </form>
                    </div>
                  ) : (
                    // SCREEN: LOGIN SCREEN
                    <div className="flex-1 flex flex-col justify-center px-6 py-8">
                      <div className="text-center mb-6">
                        <div className="w-16 h-16 rounded-2xl bg-gradient-to-tr from-indigo-600 to-teal-500 mx-auto flex items-center justify-center shadow-lg shadow-indigo-500/30 mb-3">
                          <BookOpen className="w-8 h-8 text-white" />
                        </div>
                        <h2 className="text-xl font-bold tracking-tight">IF03 Academic</h2>
                        <p className="text-xs text-slate-500 dark:text-slate-400 mt-1">
                          Pusat Informasi Akademik Kelas IF03
                        </p>
                      </div>

                      {loginError && (
                        <div className="mb-4 p-3 rounded-xl bg-rose-500/10 border border-rose-500/20 text-rose-600 dark:text-rose-400 text-xs flex items-start space-x-2">
                          <AlertTriangle className="w-4 h-4 shrink-0 mt-0.5" />
                          <span>{loginError}</span>
                        </div>
                      )}

                      <form onSubmit={handleLogin} className="space-y-4">
                        <div>
                          <label className="text-xs font-semibold block mb-1.5">Username</label>
                          <div
                            className={`flex items-center px-3 py-2.5 rounded-xl border transition ${
                              isDarkMode ? 'bg-slate-900 border-slate-800' : 'bg-white border-slate-200'
                            }`}
                          >
                            <UserIcon className="w-4 h-4 text-slate-400 mr-2" />
                            <input
                              type="text"
                              placeholder="Username Anda"
                              value={inputUsername}
                              onChange={e => setInputUsername(e.target.value)}
                              className="bg-transparent border-none outline-none text-xs w-full"
                            />
                          </div>
                        </div>

                        <div>
                          <label className="text-xs font-semibold block mb-1.5">Password</label>
                          <div
                            className={`flex items-center px-3 py-2.5 rounded-xl border transition ${
                              isDarkMode ? 'bg-slate-900 border-slate-800' : 'bg-white border-slate-200'
                            }`}
                          >
                            <Lock className="w-4 h-4 text-slate-400 mr-2" />
                            <input
                              type={showPassword ? 'text' : 'password'}
                              placeholder="Password Anda"
                              value={inputPassword}
                              onChange={e => setInputPassword(e.target.value)}
                              className="bg-transparent border-none outline-none text-xs w-full"
                            />
                            <button
                              type="button"
                              onClick={() => setShowPassword(!showPassword)}
                              className="text-slate-400 hover:text-slate-200"
                            >
                              {showPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                            </button>
                          </div>
                        </div>

                        <button
                          type="submit"
                          disabled={loginLoading}
                          className="w-full py-3 bg-indigo-600 hover:bg-indigo-700 text-white font-bold rounded-xl text-xs shadow-md shadow-indigo-600/30 transition flex items-center justify-center space-x-2"
                        >
                          {loginLoading ? (
                            <RefreshCw className="w-4 h-4 animate-spin" />
                          ) : (
                            <span>LOGIN KE AKUN</span>
                          )}
                        </button>
                      </form>

                      <div className="mt-6 text-center">
                        <div className="relative mb-4">
                          <div className="absolute inset-0 flex items-center">
                            <div className="w-full border-t border-slate-200 dark:border-slate-800" />
                          </div>
                          <div className="relative flex justify-center text-[11px]">
                            <span
                              className={`px-2 ${
                                isDarkMode ? 'bg-slate-950 text-slate-500' : 'bg-slate-50 text-slate-400'
                              }`}
                            >
                              Belum punya akun?
                            </span>
                          </div>
                        </div>

                        <button
                          type="button"
                          onClick={() => setScreenMode('request_form')}
                          className="w-full py-2.5 border border-indigo-500/30 text-indigo-600 dark:text-indigo-400 font-semibold rounded-xl text-xs hover:bg-indigo-500/10 transition"
                        >
                          Ajukan Permohonan Akun
                        </button>
                      </div>
                    </div>
                  )
                ) : showAdminPanel ? (
                  // SCREEN: ADMIN PANEL (PHASE 7)
                  <div className="flex-1 flex flex-col overflow-hidden">
                    {/* Admin Header */}
                    <div className="p-4 border-b border-slate-200 dark:border-slate-800 flex items-center justify-between">
                      <div className="flex items-center space-x-2">
                        <button
                          onClick={() => setShowAdminPanel(false)}
                          className="p-1 rounded-lg hover:bg-slate-200 dark:hover:bg-slate-800"
                        >
                          <ArrowLeft className="w-5 h-5" />
                        </button>
                        <h2 className="font-bold text-sm flex items-center space-x-1.5">
                          <Shield className="w-4 h-4 text-amber-500" />
                          <span>Admin Panel IF03</span>
                        </h2>
                      </div>
                      <span className="text-[10px] px-2 py-0.5 rounded-full bg-amber-500/10 text-amber-500 font-bold border border-amber-500/20">
                        ADMIN
                      </span>
                    </div>

                    {/* Admin Subtabs */}
                    <div className="flex p-2 bg-slate-100 dark:bg-slate-900 border-b border-slate-200 dark:border-slate-800 text-xs">
                      <button
                        onClick={() => setAdminActiveTab('requests')}
                        className={`flex-1 py-1.5 rounded-lg font-semibold transition ${
                          adminActiveTab === 'requests'
                            ? 'bg-white dark:bg-slate-800 text-indigo-600 dark:text-indigo-400 shadow-sm'
                            : 'text-slate-500'
                        }`}
                      >
                        Permohonan ({accountRequests.filter(r => r.status === 'PENDING').length})
                      </button>
                      <button
                        onClick={() => setAdminActiveTab('users')}
                        className={`flex-1 py-1.5 rounded-lg font-semibold transition ${
                          adminActiveTab === 'users'
                            ? 'bg-white dark:bg-slate-800 text-indigo-600 dark:text-indigo-400 shadow-sm'
                            : 'text-slate-500'
                        }`}
                      >
                        Pengguna ({usersList.length})
                      </button>
                    </div>

                    {/* Admin Content */}
                    <div className="flex-1 overflow-y-auto p-4 space-y-3">
                      {adminActiveTab === 'requests' ? (
                        accountRequests.map(req => (
                          <div
                            key={req.id}
                            className={`p-3 rounded-xl border text-xs ${
                              isDarkMode ? 'bg-slate-900 border-slate-800' : 'bg-white border-slate-200'
                            }`}
                          >
                            <div className="flex justify-between items-start">
                              <div>
                                <h3 className="font-bold text-sm">{req.name}</h3>
                                <p className="text-slate-500 text-[11px]">@{req.username}</p>
                              </div>
                              <span
                                className={`px-2 py-0.5 rounded-full text-[10px] font-bold ${
                                  req.status === 'APPROVED'
                                    ? 'bg-emerald-500/15 text-emerald-500'
                                    : req.status === 'REJECTED'
                                    ? 'bg-rose-500/15 text-rose-500'
                                    : 'bg-amber-500/15 text-amber-500'
                                }`}
                              >
                                {req.status}
                              </span>
                            </div>

                            <div className="mt-2 text-[11px] space-y-0.5 text-slate-500 dark:text-slate-400">
                              <p>Discord: {req.discordUsername}</p>
                              <p className="font-mono">ID: {req.discordUserId}</p>
                              {req.rejectionReason && (
                                <p className="text-rose-500 italic">Alasan: {req.rejectionReason}</p>
                              )}
                            </div>

                            {req.status === 'PENDING' && (
                              <div className="flex space-x-2 mt-3 pt-2 border-t border-slate-100 dark:border-slate-800">
                                <button
                                  onClick={() => handleRejectRequest(req.id)}
                                  className="flex-1 py-1.5 bg-rose-500/10 hover:bg-rose-500/20 text-rose-500 rounded-lg font-bold text-[11px] transition"
                                >
                                  Tolak
                                </button>
                                <button
                                  onClick={() => handleApproveRequest(req)}
                                  className="flex-1 py-1.5 bg-emerald-600 hover:bg-emerald-700 text-white rounded-lg font-bold text-[11px] transition"
                                >
                                  Setujui
                                </button>
                              </div>
                            )}
                          </div>
                        ))
                      ) : (
                        usersList.map(u => (
                          <div
                            key={u.id}
                            className={`p-3 rounded-xl border text-xs flex items-center justify-between ${
                              isDarkMode ? 'bg-slate-900 border-slate-800' : 'bg-white border-slate-200'
                            }`}
                          >
                            <div>
                              <div className="flex items-center space-x-1.5">
                                <span className="font-bold text-sm">{u.name}</span>
                                <span
                                  className={`px-1.5 py-0.5 text-[9px] font-bold rounded ${
                                    u.role === 'ADMIN'
                                      ? 'bg-amber-500/15 text-amber-500'
                                      : 'bg-slate-500/15 text-slate-400'
                                  }`}
                                >
                                  {u.role}
                                </span>
                              </div>
                              <p className="text-[11px] text-slate-500">@{u.username} • {u.discordUsername}</p>
                            </div>

                            <div className="flex items-center space-x-1">
                              <button
                                onClick={() => handleToggleUserRole(u.id)}
                                className="p-1.5 rounded-lg hover:bg-slate-200 dark:hover:bg-slate-800 text-slate-500 text-[10px] font-semibold"
                                title="Ubah Role"
                              >
                                Ubah Role
                              </button>
                              {u.username !== 'admin_if03' && (
                                <button
                                  onClick={() => handleDeleteUser(u.id)}
                                  className="p-1.5 rounded-lg text-rose-500 hover:bg-rose-500/10"
                                  title="Hapus User"
                                >
                                  <Trash2 className="w-3.5 h-3.5" />
                                </button>
                              )}
                            </div>
                          </div>
                        ))
                      )}
                    </div>
                  </div>
                ) : (
                  // SCREEN: MAIN TAB ROUTING (Home, Jadwal, Tugas, Kelompok, Profil)
                  <div className="flex-1 flex flex-col overflow-hidden">
                    {/* Screen Body */}
                    <div className="flex-1 overflow-y-auto">
                      {/* TAB 1: HOME SCREEN */}
                      {activeTab === 'home' && (
                        <div className="p-4 space-y-4">
                          {/* Top Greeting Header */}
                          <div className="p-4 rounded-2xl bg-gradient-to-tr from-indigo-600 to-teal-500 text-white shadow-lg shadow-indigo-500/20">
                            <div className="flex justify-between items-start">
                              <div>
                                <h3 className="text-base font-bold">Halo, {currentUser.name.split(' ')[0]} 👋</h3>
                                <p className="text-xs text-white/80 mt-0.5">Informatika 03 (IF03)</p>
                              </div>
                              <span className="px-2 py-0.5 rounded-md bg-white/20 text-[10px] font-bold">
                                {currentUser.role}
                              </span>
                            </div>
                          </div>

                          {/* Next Class Preview */}
                          <div>
                            <div className="flex justify-between items-center mb-2">
                              <h4 className="text-xs font-bold uppercase tracking-wider text-slate-500">
                                Jadwal Kuliah Hari Ini
                              </h4>
                              <button
                                onClick={() => setActiveTab('schedule')}
                                className="text-xs font-semibold text-indigo-500 hover:underline"
                              >
                                Lihat Semua
                              </button>
                            </div>
                            <div
                              className={`p-3 rounded-2xl border ${
                                isDarkMode ? 'bg-slate-900 border-slate-800' : 'bg-white border-slate-200'
                              } shadow-sm`}
                            >
                              <div className="flex justify-between items-start">
                                <span className="text-[10px] font-bold px-2 py-0.5 rounded bg-indigo-500/10 text-indigo-500">
                                  IF-202
                                </span>
                                <span className="text-xs font-semibold text-slate-500">10:00 - 12:00</span>
                              </div>
                              <h5 className="font-bold text-sm mt-2">Statistika & Probabilitas</h5>
                              <div className="flex items-center space-x-3 mt-2 text-xs text-slate-500">
                                <div className="flex items-center space-x-1">
                                  <MapPin className="w-3.5 h-3.5 text-teal-500" />
                                  <span>Ruang KU3.05</span>
                                </div>
                                <span>Dr. Hendra M.T.</span>
                              </div>
                            </div>
                          </div>

                          {/* Urgent Deadline Preview */}
                          <div>
                            <div className="flex justify-between items-center mb-2">
                              <h4 className="text-xs font-bold uppercase tracking-wider text-slate-500">
                                Deadline Terdekat
                              </h4>
                              <button
                                onClick={() => setActiveTab('tasks')}
                                className="text-xs font-semibold text-indigo-500 hover:underline"
                              >
                                Lihat Semua
                              </button>
                            </div>
                            <div
                              className={`p-3 rounded-2xl border ${
                                isDarkMode ? 'bg-slate-900 border-slate-800' : 'bg-white border-slate-200'
                              } shadow-sm`}
                            >
                              <div className="flex justify-between items-start">
                                <span className="text-[10px] font-bold px-2 py-0.5 rounded bg-rose-500/15 text-rose-500">
                                  PRIORITAS TINGGI
                                </span>
                                <span className="text-xs font-semibold text-slate-500">Besok, 10:00</span>
                              </div>
                              <h5 className="font-bold text-sm mt-2">PPT Statistika & Analisis Uji Hipotesis</h5>
                              <p className="text-xs text-slate-500 mt-1">Mata Kuliah: Statistika & Probabilitas</p>
                            </div>
                          </div>

                          {/* My Active Group Preview */}
                          <div>
                            <div className="flex justify-between items-center mb-2">
                              <h4 className="text-xs font-bold uppercase tracking-wider text-slate-500">
                                Kelompok Aktif Saya
                              </h4>
                              <button
                                onClick={() => setActiveTab('groups')}
                                className="text-xs font-semibold text-indigo-500 hover:underline"
                              >
                                Lihat Semua
                              </button>
                            </div>
                            <div
                              className={`p-3 rounded-2xl border ${
                                isDarkMode ? 'bg-slate-900 border-slate-800' : 'bg-white border-slate-200'
                              } shadow-sm`}
                            >
                              <div className="flex justify-between items-start">
                                <span className="text-xs font-bold">Kelompok 3 (Statistika)</span>
                                <span className="text-[10px] text-slate-500">4 Anggota</span>
                              </div>
                              <p className="text-xs text-slate-500 mt-1">Ketua: budi_santoso</p>
                            </div>
                          </div>
                        </div>
                      )}

                      {/* TAB 2: JADWAL KULIAH SCREEN (PHASE 4) */}
                      {activeTab === 'schedule' && (
                        <div className="p-4 space-y-3">
                          <div className="flex items-center justify-between mb-1">
                            <h3 className="font-bold text-base flex items-center space-x-1.5">
                              <Calendar className="w-5 h-5 text-indigo-500" />
                              <span>Jadwal Kuliah IF03</span>
                            </h3>
                            <a
                              href="https://jadwalkampusku.my.id"
                              target="_blank"
                              rel="noreferrer"
                              className="text-[10px] text-indigo-500 flex items-center space-x-1 hover:underline font-semibold"
                            >
                              <span>jadwalkampusku.my.id</span>
                              <ExternalLink className="w-3 h-3" />
                            </a>
                          </div>

                          {/* Subtabs: Hari Ini vs Mingguan */}
                          <div className="flex p-1 rounded-xl bg-slate-200/60 dark:bg-slate-900 text-xs">
                            <button
                              onClick={() => setScheduleSubTab('today')}
                              className={`flex-1 py-1.5 rounded-lg font-bold transition ${
                                scheduleSubTab === 'today'
                                  ? 'bg-indigo-600 text-white shadow'
                                  : 'text-slate-500 hover:text-slate-900 dark:hover:text-white'
                              }`}
                            >
                              Hari Ini (Senin)
                            </button>
                            <button
                              onClick={() => setScheduleSubTab('weekly')}
                              className={`flex-1 py-1.5 rounded-lg font-bold transition ${
                                scheduleSubTab === 'weekly'
                                  ? 'bg-indigo-600 text-white shadow'
                                  : 'text-slate-500 hover:text-slate-900 dark:hover:text-white'
                              }`}
                            >
                              Mingguan
                            </button>
                          </div>

                          {/* Day Filter Chips (if Weekly) */}
                          {scheduleSubTab === 'weekly' && (
                            <div className="flex space-x-1.5 overflow-x-auto pb-1 text-xs">
                              {['Semua', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat'].map(d => (
                                <button
                                  key={d}
                                  onClick={() => setSelectedDayFilter(d)}
                                  className={`px-2.5 py-1 rounded-full text-xs font-semibold whitespace-nowrap transition ${
                                    selectedDayFilter === d
                                      ? 'bg-indigo-600 text-white'
                                      : 'bg-slate-200 dark:bg-slate-800 text-slate-600 dark:text-slate-400'
                                  }`}
                                >
                                  {d}
                                </button>
                              ))}
                            </div>
                          )}

                          {/* Schedule List */}
                          <div className="space-y-2.5">
                            {(scheduleSubTab === 'today'
                              ? schedules.filter(s => s.day === 'Senin')
                              : filteredWeeklySchedules
                            ).map(item => (
                              <div
                                key={item.id}
                                className={`p-3.5 rounded-2xl border ${
                                  isDarkMode ? 'bg-slate-900 border-slate-800' : 'bg-white border-slate-200'
                                } shadow-sm space-y-1.5`}
                              >
                                <div className="flex justify-between items-center text-xs">
                                  <span className="font-bold text-indigo-500 px-2 py-0.5 rounded bg-indigo-500/10 text-[10px]">
                                    {item.courseCode}
                                  </span>
                                  <span className="font-semibold text-slate-500">
                                    {item.day} • {item.startTime} - {item.endTime}
                                  </span>
                                </div>
                                <h4 className="font-bold text-sm">{item.courseName}</h4>
                                <div className="flex items-center space-x-3 text-xs text-slate-500 pt-1 border-t border-slate-100 dark:border-slate-800">
                                  <div className="flex items-center space-x-1">
                                    <MapPin className="w-3.5 h-3.5 text-teal-500" />
                                    <span>{item.room}</span>
                                  </div>
                                  <div className="flex items-center space-x-1">
                                    <UserIcon className="w-3.5 h-3.5" />
                                    <span className="truncate">{item.lecturer}</span>
                                  </div>
                                </div>
                              </div>
                            ))}
                          </div>
                        </div>
                      )}

                      {/* TAB 3: TUGAS & DEADLINE SCREEN (PHASE 5) */}
                      {activeTab === 'tasks' && (
                        <div className="p-4 space-y-3">
                          <h3 className="font-bold text-base flex items-center space-x-1.5">
                            <ClipboardList className="w-5 h-5 text-indigo-500" />
                            <span>Tugas & Deadline IF03</span>
                          </h3>

                          {/* Search Bar */}
                          <div
                            className={`flex items-center px-3 py-2 rounded-xl border text-xs ${
                              isDarkMode ? 'bg-slate-900 border-slate-800' : 'bg-white border-slate-200'
                            }`}
                          >
                            <Search className="w-4 h-4 text-slate-400 mr-2" />
                            <input
                              type="text"
                              placeholder="Cari tugas atau mata kuliah..."
                              value={taskSearch}
                              onChange={e => setTaskSearch(e.target.value)}
                              className="bg-transparent border-none outline-none w-full"
                            />
                          </div>

                          {/* Category Filter Chips */}
                          <div className="flex space-x-1.5 overflow-x-auto text-xs pb-1">
                            {(['Semua', 'Tinggi', 'Normal', 'Selesai'] as const).map(f => (
                              <button
                                key={f}
                                onClick={() => setTaskFilter(f)}
                                className={`px-3 py-1 rounded-full font-semibold transition whitespace-nowrap ${
                                  taskFilter === f
                                    ? f === 'Tinggi'
                                      ? 'bg-rose-600 text-white'
                                      : 'bg-indigo-600 text-white'
                                    : 'bg-slate-200 dark:bg-slate-800 text-slate-600 dark:text-slate-400'
                                }`}
                              >
                                {f}
                              </button>
                            ))}
                          </div>

                          {/* Deadlines List */}
                          <div className="space-y-2.5">
                            {filteredDeadlines.map(task => (
                              <div
                                key={task.id}
                                className={`p-3.5 rounded-2xl border ${
                                  isDarkMode ? 'bg-slate-900 border-slate-800' : 'bg-white border-slate-200'
                                } shadow-sm space-y-2`}
                              >
                                <div className="flex items-start space-x-2.5">
                                  <button
                                    onClick={() => handleToggleDeadline(task.id)}
                                    className="mt-0.5 text-indigo-500 hover:text-indigo-600"
                                  >
                                    {task.completed ? (
                                      <CheckCircle2 className="w-5 h-5 text-emerald-500" />
                                    ) : (
                                      <div className="w-5 h-5 rounded-full border-2 border-slate-400" />
                                    )}
                                  </button>
                                  <div className="flex-1">
                                    <div className="flex justify-between items-start">
                                      <span className="text-[10px] font-bold px-2 py-0.5 rounded bg-indigo-500/10 text-indigo-500">
                                        {task.course}
                                      </span>
                                      <span
                                        className={`text-[9px] font-bold px-1.5 py-0.5 rounded ${
                                          task.priority === 'HIGH'
                                            ? 'bg-rose-500/15 text-rose-500'
                                            : 'bg-indigo-500/15 text-indigo-500'
                                        }`}
                                      >
                                        {task.priority === 'HIGH' ? 'TINGGI' : 'NORMAL'}
                                      </span>
                                    </div>
                                    <h4
                                      className={`font-bold text-sm mt-1.5 ${
                                        task.completed ? 'line-through text-slate-400' : ''
                                      }`}
                                    >
                                      {task.title}
                                    </h4>
                                    <p className="text-xs text-slate-500 mt-1">{task.description}</p>
                                    <div className="mt-2 text-[11px] font-semibold text-slate-500 flex items-center space-x-1">
                                      <Clock className="w-3 h-3 text-rose-500" />
                                      <span>Batas: {task.dueAt}</span>
                                    </div>
                                  </div>
                                </div>
                              </div>
                            ))}
                          </div>
                        </div>
                      )}

                      {/* TAB 4: KELOMPOK MAHASISWA SCREEN (PHASE 6) */}
                      {activeTab === 'groups' && (
                        <div className="p-4 space-y-3">
                          <h3 className="font-bold text-base flex items-center space-x-1.5">
                            <Users className="w-5 h-5 text-indigo-500" />
                            <span>Kelompok Kelas IF03</span>
                          </h3>

                          {/* Filter Button Switcher */}
                          <div className="flex p-1 rounded-xl bg-slate-200/60 dark:bg-slate-900 text-xs">
                            <button
                              onClick={() => setGroupFilterMyOnly(false)}
                              className={`flex-1 py-1.5 rounded-lg font-bold transition ${
                                !groupFilterMyOnly ? 'bg-indigo-600 text-white shadow' : 'text-slate-500'
                              }`}
                            >
                              Semua ({groups.length})
                            </button>
                            <button
                              onClick={() => setGroupFilterMyOnly(true)}
                              className={`flex-1 py-1.5 rounded-lg font-bold transition ${
                                groupFilterMyOnly ? 'bg-indigo-600 text-white shadow' : 'text-slate-500'
                              }`}
                            >
                              Kelompok Saya
                            </button>
                          </div>

                          {/* Search Input */}
                          <div
                            className={`flex items-center px-3 py-2 rounded-xl border text-xs ${
                              isDarkMode ? 'bg-slate-900 border-slate-800' : 'bg-white border-slate-200'
                            }`}
                          >
                            <Search className="w-4 h-4 text-slate-400 mr-2" />
                            <input
                              type="text"
                              placeholder="Cari matkul, anggota..."
                              value={groupSearch}
                              onChange={e => setGroupSearch(e.target.value)}
                              className="bg-transparent border-none outline-none w-full"
                            />
                          </div>

                          {/* Groups List */}
                          <div className="space-y-3">
                            {filteredGroups.map(group => {
                              const isMyGroup = group.members.some(
                                m =>
                                  m.discordUserId === currentUser.discordUserId ||
                                  m.discordUsername.toLowerCase() === currentUser.username.toLowerCase()
                              );

                              return (
                                <div
                                  key={group.id}
                                  className={`p-3.5 rounded-2xl border ${
                                    isDarkMode ? 'bg-slate-900 border-slate-800' : 'bg-white border-slate-200'
                                  } shadow-sm space-y-2`}
                                >
                                  <div className="flex justify-between items-start">
                                    <span className="text-[10px] font-bold px-2 py-0.5 rounded bg-indigo-500/10 text-indigo-500">
                                      {group.subject}
                                    </span>
                                    {isMyGroup && (
                                      <span className="text-[9px] font-bold px-2 py-0.5 rounded bg-emerald-500/15 text-emerald-500">
                                        KELOMPOK SAYA
                                      </span>
                                    )}
                                  </div>

                                  <div className="flex justify-between items-baseline">
                                    <h4 className="font-bold text-sm">Kelompok {group.groupNumber}</h4>
                                    <span className="text-xs text-slate-500">{group.members.length} Mahasiswa</span>
                                  </div>

                                  <p className="text-xs text-slate-500">
                                    Ketua: <strong className="text-slate-700 dark:text-slate-300">@{group.ownerName}</strong>
                                  </p>

                                  {/* Members Chips */}
                                  <div className="flex flex-wrap gap-1 pt-1">
                                    {group.members.map(m => (
                                      <span
                                        key={m.discordUserId || m.discordUsername}
                                        className="px-2 py-0.5 rounded-full text-[10px] font-medium bg-slate-100 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-600 dark:text-slate-300"
                                      >
                                        @{m.discordUsername}
                                      </span>
                                    ))}
                                  </div>
                                </div>
                              );
                            })}
                          </div>
                        </div>
                      )}

                      {/* TAB 5: PROFIL USER SCREEN */}
                      {activeTab === 'profile' && (
                        <div className="p-4 space-y-4">
                          {/* Profile Card */}
                          <div
                            className={`p-4 rounded-2xl border ${
                              isDarkMode ? 'bg-slate-900 border-slate-800' : 'bg-white border-slate-200'
                            } shadow-sm flex items-center space-x-3`}
                          >
                            <div className="w-12 h-12 rounded-full bg-gradient-to-tr from-indigo-600 to-teal-500 flex items-center justify-center text-white font-bold text-lg">
                              {currentUser.name[0]}
                            </div>
                            <div className="flex-1">
                              <h4 className="font-bold text-sm">{currentUser.name}</h4>
                              <p className="text-xs text-slate-500">@{currentUser.username}</p>
                              <span className="inline-block mt-1 px-2 py-0.5 rounded text-[10px] font-bold bg-indigo-500/10 text-indigo-500">
                                ROLE: {currentUser.role}
                              </span>
                            </div>
                          </div>

                          {/* Admin Panel Entry Button (If Role === ADMIN) */}
                          {currentUser.role === 'ADMIN' && (
                            <button
                              onClick={() => setShowAdminPanel(true)}
                              className="w-full p-3.5 rounded-2xl bg-amber-500/10 border border-amber-500/30 text-amber-600 dark:text-amber-400 font-bold text-xs flex items-center justify-between shadow-sm hover:bg-amber-500/20 transition"
                            >
                              <div className="flex items-center space-x-2">
                                <Shield className="w-4 h-4 text-amber-500" />
                                <span>Buka Admin Panel (Verifikasi Akun)</span>
                              </div>
                              <ChevronRight className="w-4 h-4" />
                            </button>
                          )}

                          {/* Discord Info Card */}
                          <div
                            className={`p-4 rounded-2xl border ${
                              isDarkMode ? 'bg-slate-900 border-slate-800' : 'bg-white border-slate-200'
                            } shadow-sm space-y-2 text-xs`}
                          >
                            <h5 className="font-bold flex items-center space-x-2">
                              <span>Tautan Akun Discord</span>
                            </h5>
                            <div className="flex justify-between py-1 border-b border-slate-100 dark:border-slate-800">
                              <span className="text-slate-500">Username Discord:</span>
                              <span className="font-semibold">{currentUser.discordUsername}</span>
                            </div>
                            <div className="flex justify-between py-1">
                              <span className="text-slate-500">Discord User ID:</span>
                              <span className="font-mono text-slate-700 dark:text-slate-300">
                                {currentUser.discordUserId}
                              </span>
                            </div>
                          </div>

                          {/* Dark Mode Toggle */}
                          <div
                            className={`p-3.5 rounded-2xl border ${
                              isDarkMode ? 'bg-slate-900 border-slate-800' : 'bg-white border-slate-200'
                            } shadow-sm flex items-center justify-between text-xs`}
                          >
                            <div className="flex items-center space-x-2">
                              {isDarkMode ? <Moon className="w-4 h-4 text-indigo-400" /> : <Sun className="w-4 h-4 text-amber-500" />}
                              <span className="font-semibold">Mode Gelap (Dark Mode)</span>
                            </div>
                            <button
                              onClick={() => setIsDarkMode(!isDarkMode)}
                              className={`w-11 h-6 rounded-full p-1 transition ${
                                isDarkMode ? 'bg-indigo-600' : 'bg-slate-300'
                              }`}
                            >
                              <div
                                className={`w-4 h-4 rounded-full bg-white transition-transform ${
                                  isDarkMode ? 'translate-x-5' : 'translate-x-0'
                                }`}
                              />
                            </button>
                          </div>

                          {/* Logout Button */}
                          <button
                            onClick={() => setShowLogoutConfirm(true)}
                            className="w-full py-3 bg-rose-500/10 hover:bg-rose-500/20 text-rose-600 font-bold rounded-xl text-xs transition flex items-center justify-center space-x-1.5"
                          >
                            <LogOut className="w-4 h-4" />
                            <span>Keluar dari Akun</span>
                          </button>
                        </div>
                      )}
                    </div>

                    {/* Bottom Navigation Bar */}
                    <div
                      className={`h-14 border-t px-3 flex items-center justify-around z-20 ${
                        isDarkMode ? 'bg-slate-950 border-slate-800' : 'bg-white border-slate-200'
                      }`}
                    >
                      <button
                        onClick={() => setActiveTab('home')}
                        className={`flex flex-col items-center justify-center w-12 transition ${
                          activeTab === 'home' ? 'text-indigo-600 dark:text-indigo-400 font-bold' : 'text-slate-400'
                        }`}
                      >
                        <Home className="w-5 h-5" />
                        <span className="text-[9px] mt-0.5">Home</span>
                      </button>

                      <button
                        onClick={() => setActiveTab('schedule')}
                        className={`flex flex-col items-center justify-center w-12 transition ${
                          activeTab === 'schedule' ? 'text-indigo-600 dark:text-indigo-400 font-bold' : 'text-slate-400'
                        }`}
                      >
                        <Calendar className="w-5 h-5" />
                        <span className="text-[9px] mt-0.5">Jadwal</span>
                      </button>

                      <button
                        onClick={() => setActiveTab('tasks')}
                        className={`flex flex-col items-center justify-center w-12 transition ${
                          activeTab === 'tasks' ? 'text-indigo-600 dark:text-indigo-400 font-bold' : 'text-slate-400'
                        }`}
                      >
                        <ClipboardList className="w-5 h-5" />
                        <span className="text-[9px] mt-0.5">Tugas</span>
                      </button>

                      <button
                        onClick={() => setActiveTab('groups')}
                        className={`flex flex-col items-center justify-center w-12 transition ${
                          activeTab === 'groups' ? 'text-indigo-600 dark:text-indigo-400 font-bold' : 'text-slate-400'
                        }`}
                      >
                        <Users className="w-5 h-5" />
                        <span className="text-[9px] mt-0.5">Kelompok</span>
                      </button>

                      <button
                        onClick={() => setActiveTab('profile')}
                        className={`flex flex-col items-center justify-center w-12 transition ${
                          activeTab === 'profile' ? 'text-indigo-600 dark:text-indigo-400 font-bold' : 'text-slate-400'
                        }`}
                      >
                        <UserIcon className="w-5 h-5" />
                        <span className="text-[9px] mt-0.5">Profil</span>
                      </button>
                    </div>
                  </div>
                )}

                {/* MODAL: Discord ID Helper */}
                {showDiscordHelpModal && (
                  <div className="absolute inset-0 bg-black/60 backdrop-blur-sm z-50 flex items-center justify-center p-5">
                    <div
                      className={`p-4 rounded-2xl w-full max-w-xs space-y-3 ${
                        isDarkMode ? 'bg-slate-900 text-white' : 'bg-white text-slate-900'
                      }`}
                    >
                      <h4 className="font-bold text-sm">Cara Cek Discord User ID</h4>
                      <ol className="text-xs space-y-1.5 list-decimal list-inside text-slate-500 dark:text-slate-300">
                        <li>Buka aplikasi Discord (HP atau PC).</li>
                        <li>Masuk ke Pengaturan Akun &gt; Lanjutan (Advanced).</li>
                        <li>Nyalakan "Mode Pengembang" (Developer Mode).</li>
                        <li>Klik kanan / tahan profil Anda, pilih "Salin ID Pengguna".</li>
                        <li>Tempelkan angka 17-19 digit ke formulir pendaftaran.</li>
                      </ol>
                      <button
                        onClick={() => setShowDiscordHelpModal(false)}
                        className="w-full py-2 bg-indigo-600 text-white font-bold rounded-xl text-xs mt-2"
                      >
                        Mengerti
                      </button>
                    </div>
                  </div>
                )}

                {/* MODAL: Request Success */}
                {reqSuccessModal && (
                  <div className="absolute inset-0 bg-black/60 backdrop-blur-sm z-50 flex items-center justify-center p-5">
                    <div
                      className={`p-4 rounded-2xl w-full max-w-xs text-center space-y-3 ${
                        isDarkMode ? 'bg-slate-900 text-white' : 'bg-white text-slate-900'
                      }`}
                    >
                      <div className="w-12 h-12 bg-emerald-500/20 text-emerald-500 rounded-full flex items-center justify-center mx-auto">
                        <CheckCircle2 className="w-6 h-6" />
                      </div>
                      <h4 className="font-bold text-base">Permohonan Terkirim!</h4>
                      <p className="text-xs text-slate-500 dark:text-slate-300">
                        Akun Anda sedang dalam antrean persetujuan Admin kelas. Silakan coba login setelah Admin menyetujui.
                      </p>
                      <button
                        onClick={() => {
                          setReqSuccessModal(false);
                          setScreenMode('main');
                          setInputUsername(reqUsername);
                          setInputPassword(reqPassword);
                        }}
                        className="w-full py-2.5 bg-indigo-600 text-white font-bold rounded-xl text-xs mt-2"
                      >
                        Kembali ke Login
                      </button>
                    </div>
                  </div>
                )}

                {/* MODAL: Logout Confirm */}
                {showLogoutConfirm && (
                  <div className="absolute inset-0 bg-black/60 backdrop-blur-sm z-50 flex items-center justify-center p-5">
                    <div
                      className={`p-4 rounded-2xl w-full max-w-xs space-y-3 ${
                        isDarkMode ? 'bg-slate-900 text-white' : 'bg-white text-slate-900'
                      }`}
                    >
                      <h4 className="font-bold text-sm">Konfirmasi Keluar</h4>
                      <p className="text-xs text-slate-500 dark:text-slate-300">
                        Apakah Anda yakin ingin keluar dari akun IF03 Academic?
                      </p>
                      <div className="flex space-x-2 pt-2">
                        <button
                          onClick={() => setShowLogoutConfirm(false)}
                          className="flex-1 py-2 bg-slate-200 dark:bg-slate-800 rounded-xl text-xs font-semibold"
                        >
                          Batal
                        </button>
                        <button
                          onClick={() => {
                            setShowLogoutConfirm(false);
                            setIsLoggedIn(false);
                          }}
                          className="flex-1 py-2 bg-rose-600 text-white rounded-xl text-xs font-bold"
                        >
                          Ya, Keluar
                        </button>
                      </div>
                    </div>
                  </div>
                )}
              </div>
            </div>
          </div>
        )}

        {/* VIEW 2: VPS SQLITE DATABASE & REST API VIEWER */}
        {viewMode === 'backend' && (
          <div className="w-full max-w-5xl space-y-6">
            <div className="bg-slate-900 border border-slate-800 rounded-2xl p-5 space-y-4">
              <div className="flex items-center justify-between border-b border-slate-800 pb-3">
                <div className="flex items-center space-x-3">
                  <Database className="w-6 h-6 text-emerald-400" />
                  <div>
                    <h3 className="font-bold text-base text-white">Database VPS SQLite (if03.db) & WAL Mode</h3>
                    <p className="text-xs text-slate-400">Path: /home/ubuntu/IF03-Bot/if03.db</p>
                  </div>
                </div>
                <span className="px-3 py-1 bg-emerald-500/10 text-emerald-400 font-mono text-xs font-bold border border-emerald-500/20 rounded-lg">
                  WAL Mode: ACTIVE
                </span>
              </div>

              {/* Table 1: account_requests */}
              <div>
                <h4 className="text-xs font-bold uppercase tracking-wider text-slate-400 mb-2">
                  Tabel: account_requests ({accountRequests.length} baris)
                </h4>
                <div className="overflow-x-auto border border-slate-800 rounded-xl">
                  <table className="w-full text-xs text-left">
                    <thead className="bg-slate-800/80 text-slate-300 font-semibold border-b border-slate-700">
                      <tr>
                        <th className="p-2.5">ID</th>
                        <th className="p-2.5">Username</th>
                        <th className="p-2.5">Nama Lengkap</th>
                        <th className="p-2.5">Discord ID</th>
                        <th className="p-2.5">Status</th>
                        <th className="p-2.5">Requested At</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-slate-800 text-slate-300">
                      {accountRequests.map(r => (
                        <tr key={r.id} className="hover:bg-slate-800/40">
                          <td className="p-2.5 font-mono">{r.id}</td>
                          <td className="p-2.5 font-semibold text-white">{r.username}</td>
                          <td className="p-2.5">{r.name}</td>
                          <td className="p-2.5 font-mono text-slate-400">{r.discordUserId}</td>
                          <td className="p-2.5">
                            <span
                              className={`px-2 py-0.5 rounded text-[10px] font-bold ${
                                r.status === 'APPROVED'
                                  ? 'bg-emerald-500/20 text-emerald-400'
                                  : r.status === 'REJECTED'
                                  ? 'bg-rose-500/20 text-rose-400'
                                  : 'bg-amber-500/20 text-amber-400'
                              }`}
                            >
                              {r.status}
                            </span>
                          </td>
                          <td className="p-2.5 text-slate-500">{r.requestedAt}</td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </div>

              {/* Table 2: users */}
              <div>
                <h4 className="text-xs font-bold uppercase tracking-wider text-slate-400 mb-2">
                  Tabel: users ({usersList.length} pengguna aktif)
                </h4>
                <div className="overflow-x-auto border border-slate-800 rounded-xl">
                  <table className="w-full text-xs text-left">
                    <thead className="bg-slate-800/80 text-slate-300 font-semibold border-b border-slate-700">
                      <tr>
                        <th className="p-2.5">ID</th>
                        <th className="p-2.5">Username</th>
                        <th className="p-2.5">Nama Lengkap</th>
                        <th className="p-2.5">Role</th>
                        <th className="p-2.5">Discord Handle</th>
                        <th className="p-2.5">Discord ID</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-slate-800 text-slate-300">
                      {usersList.map(u => (
                        <tr key={u.id} className="hover:bg-slate-800/40">
                          <td className="p-2.5 font-mono">{u.id}</td>
                          <td className="p-2.5 font-semibold text-white">{u.username}</td>
                          <td className="p-2.5">{u.name}</td>
                          <td className="p-2.5">
                            <span
                              className={`px-2 py-0.5 rounded text-[10px] font-bold ${
                                u.role === 'ADMIN'
                                  ? 'bg-amber-500/20 text-amber-400'
                                  : 'bg-slate-700 text-slate-300'
                              }`}
                            >
                              {u.role}
                            </span>
                          </td>
                          <td className="p-2.5">{u.discordUsername}</td>
                          <td className="p-2.5 font-mono text-slate-400">{u.discordUserId}</td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* VIEW 3: ARCHITECTURE */}
        {viewMode === 'architecture' && (
          <div className="w-full max-w-4xl space-y-6">
            <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6 space-y-6">
              <h3 className="text-lg font-bold text-white flex items-center space-x-2">
                <Layers className="w-5 h-5 text-indigo-400" />
                <span>Arsitektur Integrasi IF03 Academic</span>
              </h3>

              <div className="grid grid-cols-1 md:grid-cols-3 gap-4 text-xs">
                {/* Layer 1: Flutter APK */}
                <div className="bg-slate-800/60 border border-slate-700 p-4 rounded-xl space-y-2">
                  <div className="flex items-center space-x-2 text-indigo-400 font-bold">
                    <Smartphone className="w-4 h-4" />
                    <span>1. Flutter Client (APK)</span>
                  </div>
                  <p className="text-slate-300">
                    Aplikasi mobile Android/iOS menggunakan Provider state management, Dio HTTP client, dan Flutter Secure Storage untuk JWT.
                  </p>
                  <ul className="list-disc list-inside text-slate-400 space-y-1">
                    <li>AuthProvider</li>
                    <li>ScheduleProvider</li>
                    <li>DeadlineProvider</li>
                    <li>GroupProvider</li>
                    <li>AdminProvider</li>
                  </ul>
                </div>

                {/* Layer 2: VPS REST API */}
                <div className="bg-slate-800/60 border border-slate-700 p-4 rounded-xl space-y-2">
                  <div className="flex items-center space-x-2 text-teal-400 font-bold">
                    <Server className="w-4 h-4" />
                    <span>2. VPS REST API Server</span>
                  </div>
                  <p className="text-slate-300">
                    Express.js berjalan di port 3001 pada VPS (208.76.40.197). Coexist aman dengan Bot Discord tanpa konflik process ID.
                  </p>
                  <ul className="list-disc list-inside text-slate-400 space-y-1">
                    <li>JWT Bearer Auth</li>
                    <li>Bcrypt Password Hash</li>
                    <li>Admin Role Guards</li>
                    <li>SQLite Connection Pooling</li>
                  </ul>
                </div>

                {/* Layer 3: SQLite WAL & Bot */}
                <div className="bg-slate-800/60 border border-slate-700 p-4 rounded-xl space-y-2">
                  <div className="flex items-center space-x-2 text-emerald-400 font-bold">
                    <Database className="w-4 h-4" />
                    <span>3. SQLite Database (WAL)</span>
                  </div>
                  <p className="text-slate-300">
                    Single source of truth (/home/ubuntu/IF03-Bot/if03.db) digunakan bersama oleh Discord Bot Gateway & REST API.
                  </p>
                  <ul className="list-disc list-inside text-slate-400 space-y-1">
                    <li>journal_mode = WAL</li>
                    <li>Concurrent Read/Write</li>
                    <li>No locked database errors</li>
                    <li>Persistent Bot data</li>
                  </ul>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* VIEW 4: SOURCE CODE VIEWER */}
        {viewMode === 'code' && (
          <div className="w-full max-w-5xl bg-slate-900 border border-slate-800 rounded-2xl overflow-hidden flex flex-col h-[700px]">
            <div className="p-3 bg-slate-800 border-b border-slate-700 flex items-center justify-between text-xs">
              <div className="flex items-center space-x-2">
                <Code2 className="w-4 h-4 text-indigo-400" />
                <span className="font-semibold text-white">Struktur File Proyek Lengkap (Phase 1-7)</span>
              </div>
              <span className="text-slate-400">Dart / Flutter & Node.js Express</span>
            </div>
            <div className="flex-1 flex overflow-hidden">
              {/* File Tree Sidebar */}
              <div className="w-64 border-r border-slate-800 bg-slate-950 p-3 overflow-y-auto text-xs space-y-1">
                {[
                  'lib/main.dart',
                  'lib/services/auth_service.dart',
                  'lib/services/account_request_service.dart',
                  'lib/services/schedule_service.dart',
                  'lib/services/deadline_service.dart',
                  'lib/services/group_service.dart',
                  'lib/services/admin_service.dart',
                  'lib/screens/login/account_request_screen.dart',
                  'lib/screens/schedule/schedule_screen.dart',
                  'lib/screens/deadlines/deadlines_screen.dart',
                  'lib/screens/groups/groups_screen.dart',
                  'lib/screens/admin/admin_panel_screen.dart',
                  'backend_vps/server.js',
                  'backend_vps/schema.sql',
                ].map(file => (
                  <button
                    key={file}
                    onClick={() => setSelectedFile(file)}
                    className={`w-full text-left px-2 py-1.5 rounded-lg transition truncate font-mono text-[11px] ${
                      selectedFile === file ? 'bg-indigo-600 text-white' : 'text-slate-400 hover:text-white'
                    }`}
                  >
                    {file}
                  </button>
                ))}
              </div>

              {/* Code Display */}
              <div className="flex-1 p-4 bg-slate-950/80 overflow-y-auto font-mono text-xs text-slate-300">
                <div className="text-slate-500 mb-2">// File: {selectedFile}</div>
                <pre className="whitespace-pre-wrap leading-relaxed">
                  {selectedFile === 'backend_vps/server.js' && `// Server REST API di VPS (Port 3001)
const express = require('express');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const Database = require('better-sqlite3');

const app = express();
const db = new Database('/home/ubuntu/IF03-Bot/if03.db');
db.pragma('journal_mode = WAL');

// POST /api/account-requests
app.post('/api/account-requests', async (req, res) => {
  const { username, name, password, discord_user_id, discord_username } = req.body;
  // Validasi Discord ID (17-19 digit)
  if (!/^\\d{17,19}$/.test(discord_user_id)) {
    return res.status(400).json({ success: false, message: 'Discord ID tidak valid' });
  }
  const passwordHash = await bcrypt.hash(password, 10);
  db.prepare('INSERT INTO account_requests (username, name, discord_user_id, discord_username, password_hash) VALUES (?, ?, ?, ?, ?)')
    .run(username, name, discord_user_id, discord_username, passwordHash);
  res.json({ success: true, message: 'Permohonan akun berhasil dikirim!' });
});`}
                  {selectedFile !== 'backend_vps/server.js' &&
                    `// Implementasi lengkap ${selectedFile} telah tersimpan di sistem file proyek.\n// Mendukung semua fungsionalitas Flutter Provider & REST API integration.`}
                </pre>
              </div>
            </div>
          </div>
        )}

        {/* VIEW 5: DEPLOYMENT COMMANDS */}
        {viewMode === 'commands' && (
          <div className="w-full max-w-4xl space-y-6">
            <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6 space-y-4">
              <div className="flex items-center space-x-3 border-b border-slate-800 pb-3">
                <Terminal className="w-6 h-6 text-teal-400" />
                <div>
                  <h3 className="font-bold text-base text-white">Panduan Deployment di VPS Ubuntu</h3>
                  <p className="text-xs text-slate-400">Jalankan di server 208.76.40.197 via SSH</p>
                </div>
              </div>

              <div className="space-y-4 text-xs">
                <div>
                  <h4 className="font-bold text-slate-300 mb-1.5">1. Pastikan folder API ada di proyek bot:</h4>
                  <div className="bg-slate-950 p-3 rounded-xl border border-slate-800 font-mono text-emerald-400">
                    mkdir -p /home/ubuntu/IF03-Bot/src/api
                  </div>
                </div>

                <div>
                  <h4 className="font-bold text-slate-300 mb-1.5">2. Jalankan schema database SQLite:</h4>
                  <div className="bg-slate-950 p-3 rounded-xl border border-slate-800 font-mono text-emerald-400">
                    sqlite3 /home/ubuntu/IF03-Bot/if03.db &lt; schema.sql
                  </div>
                </div>

                <div>
                  <h4 className="font-bold text-slate-300 mb-1.5">3. Jalankan server dengan PM2 berdampingan dengan bot:</h4>
                  <div className="bg-slate-950 p-3 rounded-xl border border-slate-800 font-mono text-emerald-400">
                    pm2 start server.js --name "if03-api" --watch<br />
                    pm2 save
                  </div>
                </div>

                <div>
                  <h4 className="font-bold text-slate-300 mb-1.5">4. Periksa status proses PM2:</h4>
                  <div className="bg-slate-950 p-3 rounded-xl border border-slate-800 font-mono text-emerald-400">
                    pm2 list
                  </div>
                </div>
              </div>
            </div>
          </div>
        )}
      </main>
    </div>
  );
}
