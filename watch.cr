require "watch"

Watch.watch "./src/**/*.cr", "crystal run src/kaipi.cr"
Watch.watch "./*", "echo \"My Lord, a file has changed\"", opts: [:verbose, :log_changes]
Watch.run