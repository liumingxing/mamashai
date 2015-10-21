# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
Mamashai::Application.config.session = {
  :key         => '_ttt_session',
  :secret      => 'b0fa4c3e44cb079b5681fdad7b8df4eba824619c9c1b5cd66137341be28cbffb02bb3bc524d3b58e8b7f72cca4e9413b8a85f56d5b4897010585c9dfbf62a246'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
