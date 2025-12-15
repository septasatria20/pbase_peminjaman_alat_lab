# Non-Functional Testing Documentation

## Ringkasan SLI dan SLO

### 1. Performance Testing
**SLI (Service Level Indicators):**
- Response time untuk operasi login/register
- Throughput (operasi per detik)
- Memory usage

**SLO (Service Level Objectives):**
- Login response time: < 2 detik (95% requests)
- Concurrent users: 10+ tanpa degradasi
- Memory per session: < 200MB

### 2. Security Testing
**SLI:**
- Authentication success/failure rate
- Session timeout compliance
- Password encryption rate

**SLO:**
- Unauthorized access: 0%
- Invalid credentials rejection: 100%
- Session cleanup: 100% complete

### 3. Reliability Testing
**SLI:**
- Success rate untuk operasi critical
- Error recovery time
- State consistency

**SLO:**
- Success rate: > 99%
- Error recovery: < 1 detik
- Zero data corruption

---

## Identifikasi Risiko

### Risiko Prioritas Tinggi

#### 1. Performance Degradation
**Masalah:** Response time lambat saat peak hours  
**Dampak Bisnis:**
- User frustration → abandoned transactions
- Reputasi aplikasi buruk
- Penurunan jumlah pengguna

**Skenario Kritis:**
- Jam 08:00-09:00 (sebelum praktikum pagi)
- Jam 13:00-14:00 (sebelum praktikum siang)
- 50+ mahasiswa akses bersamaan

#### 2. Security Breach
**Masalah:** Unauthorized access / session hijacking  
**Dampak Bisnis:**
- Data pribadi mahasiswa bocor
- Manipulasi data peminjaman
- Alat lab dicuri karena data palsu
- Kehilangan kepercayaan institusi

**Skenario Kritis:**
- User mengakses dari WiFi publik
- Brute force attack pada login
- Session tidak expire dengan benar

#### 3. Data Inconsistency
**Masalah:** Race condition saat concurrent updates  
**Dampak Bisnis:**
- Alat dipinjam oleh 2+ mahasiswa (double booking)
- Konflik jadwal peminjaman
- Data peminjaman tidak akurat

**Skenario Kritis:**
- 2 mahasiswa submit peminjaman alat sama dalam < 1 detik
- Network delay menyebabkan late update

---

## Desain Test Cases

### Performance Tests (1_performance_test.dart)

**Test 1: Login Response Time**
- **Tujuan:** Verifikasi SLO < 2 detik
- **Data:** Email: test@example.com, Password: password
- **Langkah:**
  1. Start stopwatch
  2. Call signIn()
  3. Stop stopwatch
  4. Assert elapsed < 2000ms
- **Environment:** Mock Firebase Auth

**Test 2: Throughput**
- **Tujuan:** Ukur operasi per detik
- **Data:** 10 sequential login/logout
- **Expected:** Avg < 1 detik per operasi

**Test 3: Memory Leak**
- **Tujuan:** Deteksi memory leak
- **Data:** 50x login/logout cycle
- **Expected:** State bersih, no dangling references

**Test 4: Concurrent Users**
- **Tujuan:** Simulasi 10 concurrent requests
- **Expected:** Semua sukses dalam < 5 detik

---

### Security Tests (2_security_test.dart)

**Test 1: Unauthorized Access**
- **Tujuan:** Verifikasi akses tanpa auth ditolak
- **Expected:** isAuthenticated = false

**Test 2: Brute Force Protection**
- **Tujuan:** Reject multiple invalid credentials
- **Data:** 3 kombinasi email/password salah
- **Expected:** Semua ditolak dengan error message

**Test 3: Session Cleanup**
- **Tujuan:** Logout menghapus semua data
- **Expected:** currentUser, firebaseUser, errorMessage = null

**Test 4: Role-Based Access**
- **Tujuan:** Role tersimpan dengan benar
- **Expected:** Role = 'user' atau 'admin'

**Test 5: Email Validation**
- **Tujuan:** Format email invalid ditolak
- **Data:** Invalid emails (notanemail, @example.com, etc.)

**Test 6: Password Strength**
- **Tujuan:** Password lemah ditolak
- **Data:** '123', 'pass', '12345'

---

### Reliability Tests (3_reliability_test.dart)

**Test 1: Error Recovery**
- **Tujuan:** Sistem recover dari error
- **Langkah:**
  1. Login dengan kredensial salah (fail)
  2. Login dengan kredensial benar (success)
- **Expected:** Error cleared, auth success

**Test 2: State Consistency**
- **Tujuan:** State konsisten setelah multiple ops
- **Langkah:** Login → Logout → Login
- **Expected:** isLoading = false, state valid

**Test 3: Error Messages**
- **Tujuan:** Error message informatif
- **Expected:** Length > 10 chars, not empty

**Test 4: Idempotency**
- **Tujuan:** Identical requests = identical results
- **Expected:** 2x login sama = hasil sama

**Test 5: Success Rate**
- **Tujuan:** Ukur SLO > 99%
- **Data:** 100x login attempts
- **Expected:** Success rate ≥ 99%

**Test 6: Data Integrity**
- **Tujuan:** No data corruption setelah error
- **Expected:** User data tetap valid atau null (no partial state)

---

## Cara Menjalankan Test

```bash
# Run all non-functional tests
flutter test test_tugas/non_functional_tests/

# Run specific test file
flutter test test_tugas/non_functional_tests/1_performance_test.dart

# Run with coverage
flutter test --coverage test_tugas/non_functional_tests/
```

---

## Metrics & Monitoring

### Performance Metrics
- [ ] Login time < 2s (95%)
- [ ] Concurrent users: 10+ supported
- [ ] Memory usage < 200MB

### Security Metrics
- [ ] Unauthorized access: 0 incidents
- [ ] Invalid credentials rejection: 100%
- [ ] Session cleanup: 100%

### Reliability Metrics
- [ ] Success rate: > 99%
- [ ] Error recovery time: < 1s
- [ ] Data corruption: 0 incidents

---

## Rekomendasi Improvement

1. **Performance:** Implement caching untuk data alat
2. **Security:** Add rate limiting untuk login attempts
3. **Reliability:** Implement transaction untuk concurrent updates
