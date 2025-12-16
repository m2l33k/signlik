# Gesture AI Backend

NestJS backend API for Gesture AI mobile application.

## Setup

1. **Install Dependencies**
   ```bash
   npm install
   ```

2. **Configure Environment**
   - Copy `.env.example` to `.env`
   - Fill in database and JWT configuration

3. **Database Setup**
   - Create PostgreSQL database
   - Update connection details in `.env`

4. **Run Migrations**
   - TypeORM will auto-sync in development
   - For production, use migrations

## Running

### Development
```bash
npm run start:dev
```

### Production
```bash
npm run build
npm run start:prod
```

## API Endpoints

### Authentication
- `POST /auth/register` - Register new user
- `POST /auth/login` - Login user
- `POST /auth/profile` - Get user profile (requires auth)

### Gestures
- `GET /gestures/history` - Get gesture history (requires auth)
- `POST /gestures/history` - Save gesture (requires auth)
- `GET /gestures/stats` - Get statistics (requires auth)

### Users
- `GET /users` - List users (requires auth)
- `GET /users/:id` - Get user (requires auth)
- `PATCH /users/:id` - Update user (requires auth)
- `DELETE /users/:id` - Delete user (requires auth)

## Environment Variables

```env
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=postgres
DB_NAME=gesture_ai
DB_SSL=false
JWT_SECRET=your-secret-key
PORT=3000
NODE_ENV=development
```

## Deployment

See [DEPLOYMENT.md](../DEPLOYMENT.md) for detailed instructions.

### Render
- Use `render.yaml` for configuration
- Set environment variables in dashboard

### Vercel
- Use `vercel.json` for configuration
- Set environment variables in dashboard

## Testing

```bash
npm test
npm run test:e2e
```

## Architecture

- **Auth Module**: JWT-based authentication
- **Users Module**: User management
- **Gestures Module**: Gesture history and analytics
- **ML Module**: Optional cloud-based ML inference

