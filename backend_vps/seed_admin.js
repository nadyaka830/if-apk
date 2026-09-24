/**
 * Script untuk inisialisasi akun ADMIN pertama pada database VPS
 * Jalankan di VPS:
 * node /home/ubuntu/IF03-Bot/src/api/seed_admin.js
 */

const bcrypt = require('bcrypt');
const Database = require('better-sqlite3');
const path = require('path');

const dbPath = process.env.DB_PATH || path.resolve(__dirname, '../../if03.db');
const db = new Database(dbPath);

async function seedAdmin() {
  const adminUsername = 'admin';
  const adminPassword = process.env.ADMIN_INITIAL_PASSWORD || 'admin123';
  const adminName = 'Administrator IF03';
  const discordUserId = '000000000000000000';
  const discordUsername = 'admin_if03';

  // Cek apakah admin sudah ada
  const existing = db.prepare('SELECT id FROM users WHERE username = ?').get(adminUsername);
  if (existing) {
    console.log('[SEED] Akun admin sudah terdaftar di database.');
    return;
  }

  // Hash password dengan salt 10 rounds
  const salt = await bcrypt.genSalt(10);
  const passwordHash = await bcrypt.hash(adminPassword, salt);

  const insert = db.prepare(`
    INSERT INTO users (username, name, password_hash, role, discord_user_id, discord_username)
    VALUES (?, ?, ?, 'ADMIN', ?, ?)
  `);

  insert.run(adminUsername, adminName, passwordHash, discordUserId, discordUsername);
  console.log(`[SEED] Berhasil membuat akun ADMIN:`);
  console.log(`- Username: ${adminUsername}`);
  console.log(`- Role    : ADMIN`);
  console.log(`- Status  : Siap digunakan untuk login`);
}

seedAdmin().catch(console.error);
