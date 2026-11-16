# BACKEND ARCHITECTURE (RAILWAY)

Railway is the cloud hosting platform for Spoony Travel & Tours. The Express
backend serves both the REST API (`/api/*`) and the Flutter web build.
Supabase provides the database, authentication, storage and Edge Functions.

---

## TECH STACK

| Layer | Technology |
|---|---|
| Frontend | Flutter Mobile App + Flutter Web Admin Dashboard |
| Backend | Node.js + Express.js |
| Database | Supabase (PostgreSQL) |
| Hosting | Railway |
| Storage | Cloudinary |
| Authentication | JWT + bcrypt |
| Maps & Distance | Google Maps Distance Matrix API |
| Payments | GCash API, Maya API, Stripe API |

---

## PROJECT STRUCTURE

```
backend/
├── server.js                  # Express app entry point
├── package.json
├── .env.example
└── src/
    ├── config/
    │   └── database.js        # PostgreSQL pool connection
    ├── middleware/
    │   └── auth.js            # JWT verification middleware
    ├── routes/
    │   ├── auth.js            # Register, login, OTP
    │   ├── bookings.js        # Booking CRUD + approval
    │   ├── tours.js           # Tour management
    │   ├── destinations.js    # Destinations + distance calc
    │   ├── payments.js        # Receipt upload + verification
    │   └── reviews.js         # Reviews + ratings
    └── database/
        └── schema.sql         # Full PostgreSQL schema
```

---

## BACKEND API ENDPOINTS

### Authentication APIs — `/api/auth`

| Method | Endpoint | Description | Auth Required |
|---|---|---|---|
| POST | `/api/auth/register` | Register guest user | No |
| POST | `/api/auth/login` | Guest login | No |
| POST | `/api/auth/admin/login` | Admin login | No |
| POST | `/api/auth/forgot-password` | Send OTP to email | No |
| POST | `/api/auth/verify-otp` | Verify OTP code | No |

### Booking APIs — `/api/bookings`

| Method | Endpoint | Description | Auth Required |
|---|---|---|---|
| POST | `/api/bookings` | Create new booking | Guest |
| GET | `/api/bookings/my` | Get user's bookings | Guest |
| PUT | `/api/bookings/:id/cancel` | Cancel booking | Guest |
| GET | `/api/bookings` | Get all bookings | Admin |
| PUT | `/api/bookings/:id/approve` | Approve booking | Admin |
| GET | `/api/bookings/:id/qr` | Generate QR reservation | Admin/Guest |

### Tour APIs — `/api/tours`

| Method | Endpoint | Description | Auth Required |
|---|---|---|---|
| GET | `/api/tours` | Get all tours | No |
| GET | `/api/tours/:id` | Get single tour | No |
| POST | `/api/tours` | Create tour | Admin |
| PUT | `/api/tours/:id` | Update tour | Admin |
| DELETE | `/api/tours/:id` | Delete tour | Admin |

### Destination APIs — `/api/destinations`

| Method | Endpoint | Description | Auth Required |
|---|---|---|---|
| GET | `/api/destinations` | Get all destinations | No |
| GET | `/api/destinations/:id` | Get destination | No |
| POST | `/api/destinations` | Add destination | Admin |
| PUT | `/api/destinations/:id` | Edit destination | Admin |
| DELETE | `/api/destinations/:id` | Remove destination | Admin |
| POST | `/api/destinations/distance` | Calculate route distances | No |

### Payment APIs — `/api/payments`

| Method | Endpoint | Description | Auth Required |
|---|---|---|---|
| POST | `/api/payments` | Upload receipt | Guest |
| PUT | `/api/payments/:id/verify` | Verify payment | Admin |
| GET | `/api/payments/:bookingId/invoice` | Generate invoice | Guest |
| GET | `/api/payments` | List all payments | Admin |

### Review APIs — `/api/reviews`

| Method | Endpoint | Description | Auth Required |
|---|---|---|---|
| POST | `/api/reviews` | Add review | Guest |
| GET | `/api/reviews/:destinationId` | Get reviews for destination | No |
| DELETE | `/api/reviews/:id` | Delete review | Admin |
| GET | `/api/reviews/summary/:destinationId` | Rating summary | No |

---

## DATABASE TABLES

### users
```sql
id, name, email, password_hash, phone, avatar_url, role, is_verified, created_at
```

### admins
```sql
id, name, email, password_hash, role, last_login, created_at
```

### destinations
```sql
id, name, description, region, image_urls, entrance_fee, rating, reviews_count,
latitude, longitude, travel_time, average_distance_km, created_at
```

### tours
```sql
id, title, description, price, duration_days, max_guests, image_urls,
destination_ids, is_active, created_at, updated_at
```

### bookings
```sql
id, user_id, tour_id, destination_ids, accommodation_type, transport_type,
guest_count, start_date, end_date, total_amount, status, reference_code,
qr_code_url, created_at, updated_at
```

### payments
```sql
id, booking_id, user_id, amount, method, receipt_url, status, verified_at,
verified_by, created_at
```

### reviews
```sql
id, user_id, destination_id, rating, comment, is_approved, created_at
```

### notifications
```sql
id, user_id, title, body, type, is_read, created_at
```

### itineraries
```sql
id, booking_id, day_number, destination_id, start_time, notes, created_at
```

---

## DISTANCE SYSTEM

Uses Google Maps Distance Matrix API.

Features:
- Distance per tourist spot from departure point
- Total itinerary route distance
- Estimated fuel usage calculation
- Dynamic travel duration by transport type
- Route optimization (nearest neighbor)

---

## ADMIN FEATURES

Admins can:
- Manage tours (CRUD)
- Manage bookings (approve / cancel)
- Change pricing
- Add / edit itineraries
- View analytics dashboard
- Manage registered users
- Verify payments

---

## SECURITY

| Feature | Implementation |
|---|---|
| Authentication | JWT tokens (7-day expiry) |
| Passwords | bcrypt (12 salt rounds) |
| Admin routes | Role-based middleware |
| Rate limiting | express-rate-limit (100 req/15min) |
| Input validation | express-validator |
| CORS | Restricted origins |
| SQL injection | Parameterized queries (pg) |

---

## DEPLOYMENT ON RAILWAY

### Steps

The repo root contains `railway.json` and a `Dockerfile`, so Railway needs no
build/start settings: it builds the image (backend + `build/web`) and checks
`/health` before switching traffic.

1. Build the web app locally (`flutter build web --release`) and commit `build/web`
2. On Railway: **New Project** → **Deploy from GitHub repo** → select the repo
   (leave Root Directory empty)
3. Settings → Networking → **Generate Domain** (or add a custom domain)
4. Set environment variables (copy from `backend/.env.example`):

```env
SUPABASE_URL=https://<project-id>.supabase.co
SUPABASE_ANON_KEY=...
SUPABASE_SERVICE_ROLE_KEY=...
DATABASE_URL=postgresql://...   # Supabase connection string
ALLOWED_ORIGINS=https://<your-app>.up.railway.app
ADMIN_EMAIL=...
ADMIN_PASSWORD=...
SMTP_USER=...                   # optional: Gmail sender for backend emails
SMTP_PASS=...                   # optional: Gmail app password
```

Railway sets `PORT` automatically.

5. In Supabase → Authentication → URL Configuration, set the Site URL and
   redirect URLs to the Railway domain (used for Google sign-in and password reset).

### Auto-Deploy

Railway auto-deploys on every push to the connected branch.

---

## FLUTTER INTEGRATION

The Flutter app communicates with the backend through `lib/src/services/api_service.dart`.

On web, the app calls `/api` on the same host that serves it, so no
configuration is needed. For mobile builds, set the API base URL at build time:

```bash
flutter run --dart-define=API_BASE_URL=https://<your-app>.up.railway.app/api
```

Or for local development:
```bash
flutter run --dart-define=API_BASE_URL=http://localhost:3000/api
```
