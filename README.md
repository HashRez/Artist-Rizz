# ArtistRizz - Local Artists Portfolio Platform

A platform connecting customers with local artists for services like mehendi, makeup, cakes, photography, and more.

## Prerequisites

Before running the application, you need to set up the Supabase database with the required tables. Run these SQL commands in your Supabase SQL Editor:

```sql
-- Create profiles table for user data
create table if not exists profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  name text not null,
  email text not null,
  role text check (role in ('artist','customer')) not null,
  phone text,
  created_at timestamp default now()
);

-- Create artists table
create table if not exists artists (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references auth.users(id) on delete cascade,
  display_name text not null,
  business_name text,
  contact_phone text not null,
  category text not null,
  location text not null,
  short_bio text,
  min_price integer not null,
  max_price integer,
  instagram_url text,
  created_at timestamp default now(),
  updated_at timestamp default now()
);

-- Create portfolios table
create table if not exists portfolios (
  id uuid primary key default uuid_generate_v4(),
  artist_id uuid not null references artists(id) on delete cascade,
  media_url text not null,
  media_type text check (media_type in ('image','video')) not null,
  caption text,
  is_featured boolean default false,
  approved_status text default 'approved',
  uploaded_at timestamp default now()
);

-- Create reviews table
create table if not exists reviews (
  id uuid primary key default uuid_generate_v4(),
  artist_id uuid not null references artists(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  rating integer check (rating >= 1 and rating <= 5) not null,
  text text not null,
  verified boolean default false,
  created_at timestamp default now()
);

-- Create contact_events table
create table if not exists contact_events (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references auth.users(id) on delete cascade,
  artist_id uuid references artists(id) on delete cascade,
  channel text,
  timestamp timestamp default now()
);

-- Create favorites table
create table if not exists favorites (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references auth.users(id) on delete cascade,
  artist_id uuid references artists(id) on delete cascade,
  created_at timestamp default now(),
  unique(user_id, artist_id)
);

-- Create bookings table
create table if not exists bookings (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references auth.users(id) on delete cascade,
  artist_id uuid references artists(id) on delete cascade,
  status text check (status in ('pending','confirmed','completed','cancelled')) default 'pending',
  created_at timestamp default now()
);

-- Enable Row Level Security
alter table profiles enable row level security;
alter table artists enable row level security;
alter table portfolios enable row level security;
alter table reviews enable row level security;
alter table contact_events enable row level security;
alter table favorites enable row level security;
alter table bookings enable row level security;

-- Create RLS policies
create policy "Users can read own profile" on profiles for select using (auth.uid() = id);
create policy "Users can update own profile" on profiles for update using (auth.uid() = id);
create policy "Users can insert own profile" on profiles for insert with check (auth.uid() = id);

create policy "Anyone can read artists" on artists for select using (true);
create policy "Artists can manage own profile" on artists for all using (auth.uid() = user_id);

create policy "Anyone can read portfolios" on portfolios for select using (true);
create policy "Artists can manage own portfolios" on portfolios for all using (
  auth.uid() in (select user_id from artists where id = artist_id)
);

create policy "Anyone can read reviews" on reviews for select using (true);
create policy "Users can insert reviews" on reviews for insert with check (auth.uid() = user_id);

create policy "Users can manage own contact events" on contact_events for all using (auth.uid() = user_id);

create policy "Users can manage own favorites" on favorites for all using (auth.uid() = user_id);

create policy "Users can manage own bookings" on bookings for all using (auth.uid() = user_id);
create policy "Artists can read their bookings" on bookings for select using (
  auth.uid() in (select user_id from artists where id = artist_id)
);
```

## Storage Setup

Create a storage bucket named 'portfolios' in your Supabase dashboard:

1. Go to Storage in your Supabase dashboard
2. Create a new bucket named 'portfolios'
3. Set it to public read access
4. Configure the following RLS policy for the bucket:

```sql
-- Allow authenticated users to upload files
create policy "Authenticated users can upload portfolios" on storage.objects
for insert with check (
  bucket_id = 'portfolios' and 
  auth.role() = 'authenticated'
);

-- Allow public read access
create policy "Public can view portfolios" on storage.objects
for select using (bucket_id = 'portfolios');

-- Allow users to delete their own uploads
create policy "Users can delete own portfolios" on storage.objects
for delete using (
  bucket_id = 'portfolios' and 
  auth.uid()::text = (storage.foldername(name))[1]
);
```

## Environment Variables

Create a `.env` file in the root directory with your Supabase credentials:

```
VITE_SUPABASE_URL=your_supabase_project_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
```

## Installation

```bash
npm install
npm run dev
```

## Features

✅ **Complete Authentication System**
- User signup/signin with role selection (Artist/Customer)
- Supabase Auth integration with session management
- Profile creation and management

✅ **Artist Onboarding & Management**
- Complete artist profile creation form
- Portfolio upload with Supabase Storage integration
- File validation and upload limits (5 free uploads)
- Artist profile editing and management

✅ **Search & Discovery**
- Advanced search with service and location filters
- Real-time database queries (no mock data)
- Rating-based filtering and sorting
- Responsive artist cards with thumbnails

✅ **Artist Profile Pages**
- Complete gallery with lightbox modal
- WhatsApp contact integration with event tracking
- Reviews system with verification via bookings
- Favorites functionality
- Booking system

✅ **Reviews & Ratings**
- Verified reviews for users with confirmed bookings
- Star rating system with average calculations
- Review submission and display

✅ **Favorites System**
- Save/remove favorite artists
- Dedicated favorites page
- Real-time favorite status updates

✅ **File Upload System**
- Supabase Storage integration
- Progress tracking and error handling
- File type and size validation
- Public URL generation

✅ **Mobile-Responsive Design**
- Tailwind CSS styling
- Mobile-first approach
- Touch-friendly interfaces

## Tech Stack

- **Frontend**: React + TypeScript + Vite
- **Styling**: Tailwind CSS
- **Backend**: Supabase (Database + Auth + Storage)
- **Routing**: React Router
- **Icons**: Lucide React

## Database Architecture

- **profiles**: User account information
- **artists**: Artist business profiles
- **portfolios**: Media uploads (images/videos)
- **reviews**: User reviews with verification
- **favorites**: User's saved artists
- **bookings**: Service booking requests
- **contact_events**: WhatsApp contact tracking

## Key Features Implemented

1. **Two-Step Database Queries**: All related data fetched separately to avoid PostgREST join errors
2. **Row Level Security**: Comprehensive RLS policies for data protection
3. **File Upload**: Complete Supabase Storage integration with progress tracking
4. **Authentication Flow**: Proper session management and role-based redirects
5. **Real-time Updates**: Dynamic data loading and state management
6. **Error Handling**: Comprehensive error messages and loading states
7. **Mobile Optimization**: Responsive design with touch-friendly interfaces

## Usage

1. **Sign Up**: Create account as Artist or Customer
2. **Artist Onboarding**: Artists create detailed profiles with contact info
3. **Portfolio Upload**: Artists upload up to 5 photos/videos (free tier)
4. **Search Artists**: Customers search by service and location
5. **Contact Artists**: WhatsApp integration for direct communication
6. **Book Services**: Request bookings through the platform
7. **Leave Reviews**: Verified reviews after confirmed bookings
8. **Save Favorites**: Bookmark preferred artists

## Production Ready

This application is now fully functional with:
- ✅ Real Supabase backend integration
- ✅ Complete authentication system
- ✅ File upload and storage
- ✅ Search and filtering
- ✅ Reviews and ratings
- ✅ Favorites and bookings
- ✅ Mobile-responsive design
- ✅ Error handling and loading states

**No more mock data - everything connects to Supabase!**