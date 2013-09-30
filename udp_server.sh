#!/usr/bin/env bash
# Execute the actual ruby script
# The "$@" passes in any parameters into the ruby exectuable
# The '&' puts the process into background (as a daemon)
# The 'echo $! > lamp.pid'  write the process id to a file

#source $HOME/.bashrc

ruby udp_server.rb "$@" &
echo $! > udp_server.pid
