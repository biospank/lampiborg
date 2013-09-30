#!/usr/bin/env bash
# Execute the actual ruby script
# The "$@" passes in any parameters into the ruby exectuable
# The '&' puts the process into background (as a daemon)
# The 'echo $! > lamp.pid'  write the process id to a file

ruby lamp_server.rb -e production & #"$@" &
echo $! > lamp_server.pid
