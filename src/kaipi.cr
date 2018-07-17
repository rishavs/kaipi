require "kemal"
# require "sentry-run"
require "dotenv"
require "pg"
require "granite/adapter/pg"
require "crypto/bcrypt/password"
require "uuid"
require "jwt"

puts "STarting the app ..."

Dotenv.load!

puts "Initializing Database"

require "./errors.cr"
require "./models.cr"
require "./actions/*"

require "./routes.cr"
require "./handlers.cr"

module Kaipi

    # User.migrator.drop_and_create
    # Post.migrator.drop_and_create

    Kemal.run
end
