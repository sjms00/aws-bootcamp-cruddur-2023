-- this file was manually created
INSERT INTO public.users (display_name, handle, email, cognito_user_id)
VALUES
  ('Jordi Morreres', 'jordimorreres' , 'jxxx@gmail.com', 'MOCK'),
  ('Andrew Bayko2', 'bayko2' , 'qxxxx@gmail.com', 'MOCK');

INSERT INTO public.activities (user_uuid, message, expires_at)
VALUES
  (
    (SELECT uuid from public.users WHERE users.handle = 'jordimorreres' LIMIT 1),
    'This was imported as seed Jordi data!',
    current_timestamp + interval '10 day'
  )
