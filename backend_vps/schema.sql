-- Skema tabel users dan account_requests untuk backend IF03 Academic
-- Lokasi database: /home/ubuntu/IF03-Bot/if03.db
-- Jangan menghapus data deadline atau tabel bot existing!

-- 1. Tabel users (Akun terverifikasi untuk login APK)
CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    password_hash TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'MAHASISWA', -- 'ADMIN' atau 'MAHASISWA'
    discord_user_id TEXT NOT NULL UNIQUE,
    discord_username TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 2. Tabel account_requests (Permohonan akun baru dari mahasiswa)
CREATE TABLE IF NOT EXISTS account_requests (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    discord_user_id TEXT NOT NULL UNIQUE,
    discord_username TEXT NOT NULL,
    password_hash TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'PENDING', -- 'PENDING', 'APPROVED', 'REJECTED'
    rejection_reason TEXT,
    requested_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    reviewed_at DATETIME,
    reviewed_by TEXT
);

-- Index untuk performa pencarian username dan Discord User ID
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_discord_id ON users(discord_user_id);
CREATE INDEX IF NOT EXISTS idx_requests_status ON account_requests(status);
