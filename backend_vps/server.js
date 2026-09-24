/**
 * IF03 Academic REST API Layer
 * Berjalan di VPS Ubuntu: /home/ubuntu/IF03-Bot/src/api/server.js
 * Port default: 3001 (Tidak konflik dengan PM2 if03-bot Discord Gateway)
 * Database: /home/ubuntu/IF03-Bot/if03.db (SQLite WAL Mode)
 */

const express = require('express');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const Database = require('better-sqlite3');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3001;
const JWT_SECRET = process.env.JWT_SECRET || 'IF03_ACADEMIC_SUPER_SECRET_KEY_2026';

// Lokasi database existing SQLite bot
const dbPath = process.env.DB_PATH || path.resolve(__dirname, '../../if03.db');
const db = new Database(dbPath);
db.pragma('journal_mode = WAL'); // Pastikan WAL mode tetap terjaga

app.use(cors());
app.use(express.json());

// Inisialisasi tabel jika belum ada
db.exec(`
  CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    password_hash TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'MAHASISWA',
    discord_user_id TEXT NOT NULL UNIQUE,
    discord_username TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
  );

  CREATE TABLE IF NOT EXISTS account_requests (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    discord_user_id TEXT NOT NULL UNIQUE,
    discord_username TEXT NOT NULL,
    password_hash TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'PENDING',
    rejection_reason TEXT,
    requested_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    reviewed_at DATETIME,
    reviewed_by TEXT
  );

  -- Tabel mock / fallback jika bot belum membuat tabel deadlines & groups
  CREATE TABLE IF NOT EXISTS deadlines (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    subject TEXT NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    deadline_date TEXT NOT NULL,
    priority TEXT DEFAULT 'NORMAL',
    created_by TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
  );

  CREATE TABLE IF NOT EXISTS class_groups (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    group_number INTEGER NOT NULL,
    subject TEXT NOT NULL,
    owner_id TEXT NOT NULL,
    owner_name TEXT NOT NULL,
    members_json TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
  );
`);

// Middleware Verifikasi JWT Bearer Token
function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({
      success: false,
      message: 'Akses ditolak. Token autentikasi tidak ditemukan.',
    });
  }

  jwt.verify(token, JWT_SECRET, (err, decoded) => {
    if (err) {
      return res.status(401).json({
        success: false,
        message: 'Sesi telah berakhir atau token tidak valid. Silakan login kembali.',
      });
    }

    // Ambil data user terbaru dari DB untuk memverifikasi role aktual
    const user = db.prepare('SELECT id, username, name, role, discord_user_id, discord_username FROM users WHERE id = ?').get(decoded.id);
    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'User tidak ditemukan atau akun telah dinonaktifkan.',
      });
    }

    req.user = user;
    next();
  });
}

// Middleware Verifikasi Role ADMIN
function requireAdmin(req, res, next) {
  if (req.user && req.user.role === 'ADMIN') {
    return next();
  }
  return res.status(403).json({
    success: false,
    message: 'Akses ditolak. Tindakan ini hanya boleh dilakukan oleh ADMIN.',
  });
}

// ==========================================
// 1. ENDPOINTS AUTENTIKASI
// ==========================================

// POST /api/auth/login
app.post('/api/auth/login', async (req, res) => {
  try {
    const { username, password } = req.body;

    if (!username || !password) {
      return res.status(400).json({
        success: false,
        message: 'Username dan password wajib diisi.',
      });
    }

    const cleanUsername = username.trim().toLowerCase();

    // 1. Cari user di tabel users
    const user = db.prepare('SELECT * FROM users WHERE LOWER(username) = ?').get(cleanUsername);

    if (!user) {
      // Periksa apakah username ada di permohonan akun dengan status PENDING atau REJECTED
      const pendingReq = db.prepare('SELECT status, rejection_reason FROM account_requests WHERE LOWER(username) = ? ORDER BY id DESC LIMIT 1').get(cleanUsername);
      if (pendingReq) {
        if (pendingReq.status === 'PENDING') {
          return res.status(403).json({
            success: false,
            status: 'PENDING',
            message: 'Permohonan akun kamu masih menunggu persetujuan admin.',
          });
        } else if (pendingReq.status === 'REJECTED') {
          return res.status(403).json({
            success: false,
            status: 'REJECTED',
            message: `Permohonan akun kamu ditolak. Alasan: ${pendingReq.rejection_reason || 'Tidak memenuhi syarat.'}`,
          });
        }
      }

      return res.status(401).json({
        success: false,
        message: 'Username atau password salah.',
      });
    }

    // 2. Verifikasi Password Hash menggunakan bcrypt
    const isPasswordValid = await bcrypt.compare(password, user.password_hash);
    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        message: 'Username atau password salah.',
      });
    }

    // 3. Buat JWT Token
    const token = jwt.sign(
      {
        id: user.id,
        username: user.username,
        role: user.role,
        discord_user_id: user.discord_user_id,
      },
      JWT_SECRET,
      { expiresIn: '30d' }
    );

    return res.json({
      success: true,
      message: 'Login berhasil.',
      token,
      user: {
        id: user.id,
        username: user.username,
        name: user.name,
        role: user.role,
        discord_user_id: user.discord_user_id,
        discord_username: user.discord_username,
      },
    });
  } catch (error) {
    console.error('Error saat login:', error);
    return res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan pada server saat memproses login.',
    });
  }
});

// GET /api/auth/me
app.get('/api/auth/me', authenticateToken, (req, res) => {
  return res.json({
    success: true,
    user: req.user,
  });
});

// ==========================================
// 2. ENDPOINTS PERMOHONAN AKUN (PHASE 3)
// ==========================================

// POST /api/account-requests
app.post('/api/account-requests', async (req, res) => {
  try {
    const { username, name, password, discord_user_id, discord_username } = req.body;

    // Validasi kelengkapan data
    if (!username || !name || !password || !discord_user_id || !discord_username) {
      return res.status(400).json({
        success: false,
        message: 'Semua field (Username, Nama Lengkap, Password, Discord User ID, Discord Username) wajib diisi.',
      });
    }

    const cleanUsername = username.trim().toLowerCase();
    const cleanDiscordId = discord_user_id.trim();

    // Validasi format Discord User ID (harus 17-19 digit angka)
    if (!/^\d{17,19}$/.test(cleanDiscordId)) {
      return res.status(400).json({
        success: false,
        message: 'Discord User ID tidak valid. Discord User ID harus berupa 17-19 digit angka (contoh: 123456789012345678).',
      });
    }

    // Validasi panjang password minimal 6 karakter
    if (password.length < 6) {
      return res.status(400).json({
        success: false,
        message: 'Password minimal terdiri dari 6 karakter.',
      });
    }

    // Cek apakah username sudah ada di users
    const existingUser = db.prepare('SELECT id FROM users WHERE LOWER(username) = ?').get(cleanUsername);
    if (existingUser) {
      return res.status(409).json({
        success: false,
        message: 'Username tersebut sudah terdaftar sebagai pengguna aktif. Silakan gunakan username lain atau login langsung.',
      });
    }

    // Cek apakah discord_user_id sudah ada di users
    const existingDiscord = db.prepare('SELECT id FROM users WHERE discord_user_id = ?').get(cleanDiscordId);
    if (existingDiscord) {
      return res.status(409).json({
        success: false,
        message: 'Akun Discord tersebut sudah terdaftar pada pengguna lain.',
      });
    }

    // Cek apakah sudah ada permohonan yang berstatus PENDING
    const existingPending = db.prepare('SELECT id FROM account_requests WHERE (LOWER(username) = ? OR discord_user_id = ?) AND status = "PENDING"').get(cleanUsername, cleanDiscordId);
    if (existingPending) {
      return res.status(409).json({
        success: false,
        message: 'Permohonan akun untuk username atau Discord ID ini sudah diajukan dan masih menunggu persetujuan admin.',
      });
    }

    // Hash password menggunakan bcrypt (salt rounds = 10)
    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(password, salt);

    // Simpan permohonan akun ke tabel account_requests
    const insertStmt = db.prepare(`
      INSERT INTO account_requests (username, name, discord_user_id, discord_username, password_hash, status)
      VALUES (?, ?, ?, ?, ?, 'PENDING')
    `);

    const result = insertStmt.run(
      cleanUsername,
      name.trim(),
      cleanDiscordId,
      discord_username.trim(),
      passwordHash
    );

    return res.status(201).json({
      success: true,
      message: 'Permohonan akun berhasil dikirim! Silakan tunggu persetujuan dari Admin IF03.',
      requestId: result.lastInsertRowid,
    });
  } catch (error) {
    console.error('Error saat submit permohonan akun:', error);
    return res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan pada server saat memproses permohonan akun.',
    });
  }
});

// GET /api/account-requests/status/:username
app.get('/api/account-requests/status/:username', (req, res) => {
  try {
    const { username } = req.params;
    const reqData = db.prepare(`
      SELECT id, username, name, status, rejection_reason, requested_at, reviewed_at
      FROM account_requests
      WHERE LOWER(username) = ?
      ORDER BY id DESC LIMIT 1
    `).get(username.trim().toLowerCase());

    if (!reqData) {
      return res.status(404).json({
        success: false,
        message: 'Permohonan akun tidak ditemukan.',
      });
    }

    return res.json({
      success: true,
      data: reqData,
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

// ==========================================
// 3. ENDPOINTS DEADLINE (PHASE 5)
// ==========================================

// GET /api/deadlines
app.get('/api/deadlines', authenticateToken, (req, res) => {
  try {
    const rows = db.prepare(`
      SELECT id, subject, title, description, deadline_date, priority, created_by, created_at
      FROM deadlines
      ORDER BY deadline_date ASC
    `).all();

    return res.json({
      success: true,
      data: rows,
    });
  } catch (error) {
    console.error('Error fetching deadlines:', error);
    return res.status(500).json({ success: false, message: 'Gagal mengambil data deadline.' });
  }
});

// GET /api/deadlines/active
app.get('/api/deadlines/active', authenticateToken, (req, res) => {
  try {
    const rows = db.prepare(`
      SELECT id, subject, title, description, deadline_date, priority, created_by, created_at
      FROM deadlines
      ORDER BY deadline_date ASC
    `).all();

    return res.json({
      success: true,
      data: rows,
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

// ==========================================
// 4. ENDPOINTS KELOMPOK MAHASISWA (PHASE 6)
// ==========================================

// GET /api/groups
app.get('/api/groups', authenticateToken, (req, res) => {
  try {
    const rows = db.prepare(`
      SELECT id, group_number, subject, owner_id, owner_name, members_json, created_at
      FROM class_groups
      ORDER BY group_number ASC
    `).all();

    const formatted = rows.map((r) => {
      let members = [];
      try {
        members = JSON.parse(r.members_json || '[]');
      } catch (_) {
        members = [];
      }
      return {
        id: r.id,
        groupNumber: r.group_number,
        subject: r.subject,
        ownerId: r.owner_id,
        ownerName: r.owner_name,
        members: members,
        createdAt: r.created_at,
      };
    });

    return res.json({
      success: true,
      data: formatted,
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

// GET /api/groups/my-active
app.get('/api/groups/my-active', authenticateToken, (req, res) => {
  try {
    const discordId = req.user.discord_user_id;
    const username = req.user.username.toLowerCase();

    const rows = db.prepare(`
      SELECT id, group_number, subject, owner_id, owner_name, members_json, created_at
      FROM class_groups
    `).all();

    const myGroups = [];
    for (const r of rows) {
      let members = [];
      try {
        members = JSON.parse(r.members_json || '[]');
      } catch (_) {}

      const isOwner = r.owner_id === discordId || r.owner_name.toLowerCase() === username;
      const isMember = members.some((m) => {
        if (typeof m === 'string') return m.toLowerCase() === username;
        return m.discord_id === discordId || m.name?.toLowerCase() === username;
      });

      if (isOwner || isMember) {
        myGroups.push({
          id: r.id,
          groupNumber: r.group_number,
          subject: r.subject,
          ownerId: r.owner_id,
          ownerName: r.owner_name,
          members: members,
          isUserOwner: isOwner,
          createdAt: r.created_at,
        });
      }
    }

    return res.json({
      success: true,
      data: myGroups,
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

// ==========================================
// 5. ENDPOINTS ADMIN PANEL (PHASE 7)
// ==========================================

// GET /api/admin/account-requests (List permohonan akun)
app.get('/api/admin/account-requests', authenticateToken, requireAdmin, (req, res) => {
  try {
    const statusFilter = req.query.status ? req.query.status.toUpperCase() : null;
    let query = 'SELECT id, username, name, discord_user_id, discord_username, status, rejection_reason, requested_at, reviewed_at, reviewed_by FROM account_requests';
    const params = [];

    if (statusFilter) {
      query += ' WHERE status = ?';
      params.push(statusFilter);
    }
    query += ' ORDER BY requested_at DESC';

    const rows = db.prepare(query).all(...params);
    return res.json({
      success: true,
      data: rows,
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

// POST /api/admin/account-requests/:id/approve (Setujui Permohonan)
app.post('/api/admin/account-requests/:id/approve', authenticateToken, requireAdmin, (req, res) => {
  try {
    const requestId = req.params.id;

    // Ambil data permohonan
    const request = db.prepare('SELECT * FROM account_requests WHERE id = ?').get(requestId);
    if (!request) {
      return res.status(404).json({ success: false, message: 'Permohonan akun tidak ditemukan.' });
    }

    if (request.status === 'APPROVED') {
      return res.status(400).json({ success: false, message: 'Permohonan akun ini sudah disetujui sebelumnya.' });
    }

    // Transaksi: Insert ke users dan update status di account_requests
    const transaction = db.transaction(() => {
      // 1. Insert ke tabel users
      const insertUser = db.prepare(`
        INSERT INTO users (username, name, password_hash, role, discord_user_id, discord_username)
        VALUES (?, ?, ?, 'MAHASISWA', ?, ?)
      `);
      insertUser.run(
        request.username,
        request.name,
        request.password_hash,
        request.discord_user_id,
        request.discord_username
      );

      // 2. Update status account_requests
      const updateReq = db.prepare(`
        UPDATE account_requests
        SET status = 'APPROVED', reviewed_at = CURRENT_TIMESTAMP, reviewed_by = ?
        WHERE id = ?
      `);
      updateReq.run(req.user.username, requestId);
    });

    transaction();

    return res.json({
      success: true,
      message: `Permohonan akun '${request.username}' berhasil disetujui. Akun sekarang dapat digunakan untuk login APK.`,
    });
  } catch (error) {
    console.error('Error saat approve request:', error);
    return res.status(500).json({ success: false, message: `Gagal menyetujui akun: ${error.message}` });
  }
});

// POST /api/admin/account-requests/:id/reject (Tolak Permohonan)
app.post('/api/admin/account-requests/:id/reject', authenticateToken, requireAdmin, (req, res) => {
  try {
    const requestId = req.params.id;
    const { reason } = req.body;

    const request = db.prepare('SELECT * FROM account_requests WHERE id = ?').get(requestId);
    if (!request) {
      return res.status(404).json({ success: false, message: 'Permohonan akun tidak ditemukan.' });
    }

    const updateReq = db.prepare(`
      UPDATE account_requests
      SET status = 'REJECTED', rejection_reason = ?, reviewed_at = CURRENT_TIMESTAMP, reviewed_by = ?
      WHERE id = ?
    `);
    updateReq.run(reason || 'Data verifikasi Discord atau Nama tidak cocok.', req.user.username, requestId);

    return res.json({
      success: true,
      message: `Permohonan akun '${request.username}' berhasil ditolak.`,
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

// GET /api/admin/users (Manajemen Pengguna)
app.get('/api/admin/users', authenticateToken, requireAdmin, (req, res) => {
  try {
    const rows = db.prepare(`
      SELECT id, username, name, role, discord_user_id, discord_username, created_at, updated_at
      FROM users
      ORDER BY role ASC, name ASC
    `).all();

    return res.json({
      success: true,
      data: rows,
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

// PUT /api/admin/users/:id/role (Ubah Role User)
app.put('/api/admin/users/:id/role', authenticateToken, requireAdmin, (req, res) => {
  try {
    const userId = req.params.id;
    const { role } = req.body;

    if (!['ADMIN', 'MAHASISWA'].includes(role)) {
      return res.status(400).json({ success: false, message: 'Role harus berupa ADMIN atau MAHASISWA.' });
    }

    const updateStmt = db.prepare('UPDATE users SET role = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?');
    updateStmt.run(role, userId);

    return res.json({
      success: true,
      message: `Role pengguna berhasil diubah menjadi ${role}.`,
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

// DELETE /api/admin/users/:id (Hapus User)
app.delete('/api/admin/users/:id', authenticateToken, requireAdmin, (req, res) => {
  try {
    const userId = req.params.id;
    // Jangan izinkan admin menghapus diri sendiri
    if (parseInt(userId) === req.user.id) {
      return res.status(400).json({ success: false, message: 'Tidak dapat menghapus akun Anda sendiri saat sedang login.' });
    }

    db.prepare('DELETE FROM users WHERE id = ?').run(userId);
    return res.json({
      success: true,
      message: 'Pengguna berhasil dihapus.',
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

// Health check
app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    service: 'IF03 Academic API Layer',
    timestamp: new Date().toISOString(),
  });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`[IF03 API] Server berjalan di port ${PORT}`);
});
