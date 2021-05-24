require "watch"

Watch.watch "./src/**/*.*", "crystal run src/kaipi.cr", opts: [:verbose, :log_changes]
# Watch.watch "./*", "echo \"My Lord, a file has changed\"", opts: [:verbose, :log_changes]
Watch.run