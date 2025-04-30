/*
  # Add sample data for bus booking system

  1. Sample Data
    - Add buses with different amenities
    - Add popular routes between major cities
    - Add schedules for the next 7 days
*/

-- Add sample buses
INSERT INTO buses (name, bus_number, total_seats, amenities)
VALUES
  ('Royal Express', 'RX-001', 40, ARRAY['AC', 'WiFi', 'USB Charging']),
  ('Night Rider', 'NR-002', 36, ARRAY['AC', 'Sleeper', 'Blanket']),
  ('City Connect', 'CC-003', 45, ARRAY['Non AC', 'Water Bottle']),
  ('Luxury Line', 'LL-004', 32, ARRAY['AC', 'Entertainment', 'Snacks', 'WiFi']),
  ('Budget Bus', 'BB-005', 48, ARRAY['Non AC', 'Water Bottle'])
ON CONFLICT (bus_number) DO NOTHING;

-- Add popular routes
INSERT INTO routes (from_city, to_city, distance)
VALUES
  ('Mumbai', 'Delhi', 1400),
  ('Delhi', 'Mumbai', 1400),
  ('Bangalore', 'Mumbai', 980),
  ('Mumbai', 'Bangalore', 980),
  ('Delhi', 'Bangalore', 2150),
  ('Bangalore', 'Delhi', 2150),
  ('Chennai', 'Bangalore', 350),
  ('Bangalore', 'Chennai', 350),
  ('Hyderabad', 'Bangalore', 570),
  ('Bangalore', 'Hyderabad', 570)
ON CONFLICT DO NOTHING;

-- Add schedules for the next 7 days
DO $$
DECLARE
  bus record;
  route record;
  current_date date := CURRENT_DATE;
  departure_time timestamp;
  arrival_time timestamp;
  fare numeric;
BEGIN
  -- For each bus
  FOR bus IN SELECT * FROM buses
  LOOP
    -- For each route
    FOR route IN SELECT * FROM routes
    LOOP
      -- For next 7 days
      FOR i IN 0..6
      LOOP
        -- Morning schedule (8 AM departure)
        departure_time := (current_date + i * INTERVAL '1 day' + INTERVAL '8 hours')::timestamp;
        arrival_time := departure_time + (route.distance / 60) * INTERVAL '1 hour'; -- Assuming 60km/h average speed
        fare := (route.distance * 2)::numeric; -- ₹2 per km

        INSERT INTO schedules (
          bus_id,
          route_id,
          departure_time,
          arrival_time,
          fare,
          available_seats
        )
        VALUES (
          bus.id,
          route.id,
          departure_time,
          arrival_time,
          fare,
          bus.total_seats
        )
        ON CONFLICT DO NOTHING;

        -- Evening schedule (8 PM departure)
        departure_time := (current_date + i * INTERVAL '1 day' + INTERVAL '20 hours')::timestamp;
        arrival_time := departure_time + (route.distance / 60) * INTERVAL '1 hour';

        INSERT INTO schedules (
          bus_id,
          route_id,
          departure_time,
          arrival_time,
          fare,
          available_seats
        )
        VALUES (
          bus.id,
          route.id,
          departure_time,
          arrival_time,
          fare,
          bus.total_seats
        )
        ON CONFLICT DO NOTHING;
      END LOOP;
    END LOOP;
  END LOOP;
END $$;