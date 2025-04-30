/*
  # Initial Schema for Bus Booking System

  1. New Tables
    - `users` - Store user information
      - `id` (uuid, primary key)
      - `email` (text, unique)
      - `full_name` (text)
      - `phone` (text)
      - `created_at` (timestamp)
    
    - `buses` - Store bus information
      - `id` (uuid, primary key)
      - `name` (text)
      - `bus_number` (text, unique)
      - `total_seats` (integer)
      - `amenities` (text[])
      - `created_at` (timestamp)
    
    - `routes` - Store route information
      - `id` (uuid, primary key)
      - `from_city` (text)
      - `to_city` (text)
      - `distance` (numeric)
      - `created_at` (timestamp)
    
    - `schedules` - Store bus schedules
      - `id` (uuid, primary key)
      - `bus_id` (uuid, references buses)
      - `route_id` (uuid, references routes)
      - `departure_time` (timestamp)
      - `arrival_time` (timestamp)
      - `fare` (numeric)
      - `available_seats` (integer)
      - `created_at` (timestamp)
    
    - `bookings` - Store booking information
      - `id` (uuid, primary key)
      - `user_id` (uuid, references auth.users)
      - `schedule_id` (uuid, references schedules)
      - `seat_numbers` (integer[])
      - `total_amount` (numeric)
      - `status` (text)
      - `created_at` (timestamp)

  2. Security
    - Enable RLS on all tables
    - Add policies for authenticated users
*/

-- Create tables
CREATE TABLE IF NOT EXISTS users (
  id uuid PRIMARY KEY DEFAULT auth.uid(),
  email text UNIQUE NOT NULL,
  full_name text,
  phone text,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS buses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  bus_number text UNIQUE NOT NULL,
  total_seats integer NOT NULL,
  amenities text[],
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS routes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  from_city text NOT NULL,
  to_city text NOT NULL,
  distance numeric NOT NULL,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS schedules (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  bus_id uuid REFERENCES buses NOT NULL,
  route_id uuid REFERENCES routes NOT NULL,
  departure_time timestamptz NOT NULL,
  arrival_time timestamptz NOT NULL,
  fare numeric NOT NULL,
  available_seats integer NOT NULL,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS bookings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users NOT NULL,
  schedule_id uuid REFERENCES schedules NOT NULL,
  seat_numbers integer[] NOT NULL,
  total_amount numeric NOT NULL,
  status text NOT NULL DEFAULT 'pending',
  created_at timestamptz DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE buses ENABLE ROW LEVEL SECURITY;
ALTER TABLE routes ENABLE ROW LEVEL SECURITY;
ALTER TABLE schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can read their own data" ON users
  FOR SELECT TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Anyone can view buses" ON buses
  FOR SELECT TO authenticated
  USING (true);

CREATE POLICY "Anyone can view routes" ON routes
  FOR SELECT TO authenticated
  USING (true);

CREATE POLICY "Anyone can view schedules" ON schedules
  FOR SELECT TO authenticated
  USING (true);

CREATE POLICY "Users can view their own bookings" ON bookings
  FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own bookings" ON bookings
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);