# Be sure to restart your server when you modify this file.

# Your secret key is used for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!

# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
# You can use `rake secret` to generate a secure secret key.

# Make sure your secret_key_base is kept private
# if you're sharing your code publicly.
require 'securerandom'

def secure_token
  token_file = Rails.root.join('.secret')
  if File.exist?(token_file)
     # Use the existing token
     File.read(token_file).chomp
  else
    # Generate a new token and store it in token_file.
    token = SecureRandom.hex(64)
    File.write(token_file, token)
    token
  end
end
  
#Chapter2App::Application.config.secret_key_base = '15a198fab509d1b6d87d4a3db0b2fd4271101639c167f71840f934e7b4d235a3a2bc8e273c28a7e8ce24715fd15b61361923a9d83e2f508e059b6981bb561e54'
Chapter2App::Application.config.secret_key_base = secure_token