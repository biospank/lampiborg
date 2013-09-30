require 'sinatra'
require 'tempfile'
require 'tmpdir'

configure :production do
  disable :logging
  set :lamposx_version, '30'
  set :lamposx_download_link, "https://dl.dropboxusercontent.com/u/621599/work/Lamp-3.0.dmg"
  set :lampwin_version, '30'
  set :lampwin_download_link, "https://dl.dropboxusercontent.com/u/621599/work/Lamp-3.0-setup.exe"
end

system 'gpio mode 0 out' # transmitter pin
system 'gpio mode 2 out' # computer led pin
system 'gpio mode 3 out' # phone led pin
system 'gpio mode 8 in' # push button

# reset
system 'gpio write 2 0'
system 'gpio write 3 0'
FileUtils.rm("#{Dir.tmpdir}/blink.2.lock") rescue nil
FileUtils.rm("#{Dir.tmpdir}/blink.3.lock") rescue nil

# Thread.new do
#   while true do
#    if(( res = `gpio read 8` ).chomp == '1')
#       sleep 2
#     else
#       system 'gpio write 2 0'
#       system 'gpio write 3 0'
#     end
#   end
# end

$pids = []

get '/lamp/:device' do
  system 'gpio write 0 1'
  sleep 0.5
  system 'gpio write 0 0'

  case params[:device]
  when 'osx', 'win'
    led = 2
  when 'droid'
    led = 3
  end

  #system 'gpio write #{led} 1'

  unless File.exist?("#{Dir.tmpdir}/blink.#{led}.lock")

    $pids << fork do
      $interrupt = false

      Signal.trap("HUP") do
        $interrupt = true
      end

      File.open("#{Dir.tmpdir}/blink.#{led}.lock", File::RDWR|File::CREAT, 0644) do |f|
        #f.flock(File::LOCK_EX)
        while true do
          if $interrupt
            system 'gpio write 2 0'
            system 'gpio write 3 0'
            break
          else
            sleep 0.8
            system "gpio write #{led} 1"
            sleep 0.6
            system "gpio write #{led} 0"
          end
        end
      end

      FileUtils.rm("#{Dir.tmpdir}/blink.#{led}.lock")

    end

  end

  params[:device]
end

get '/lamp/:device/version' do

  case params[:device]
  when 'osx'
    version = settings.lamposx_version
  when 'win'
    version = settings.lampwin_version
  end

  version
end

get '/lamp/:device/download' do

  case params[:device]
  when 'osx'
    download_link = settings.lamposx_download_link
  when 'win'
    download_link = settings.lampwin_download_link
  end

  download_link
end

get '/lamp/led/reset' do
  #system 'gpio write 2 0'
  #system 'gpio write 3 0'
  $pids.each do |pid|
    Process.kill("HUP", pid) rescue nil
  end

  $pids.clear

  'ok'
end

