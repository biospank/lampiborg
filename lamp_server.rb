require 'sinatra'
require 'tempfile'
require 'tmpdir'

configure :production do
  disable :logging
  set :transmitter_pin, '7'
  set :r_jolly_led_pin, '0'
  set :g_computer_led_pin, '2'
  set :b_phone_led_pin, '3'
  set :lampiosx_version, '30'
  set :lampiosx_download_link, "https://dl.dropboxusercontent.com/u/621599/work/Lamp-3.0.dmg"
  set :lampiwin_version, '30'
  set :lampiwin_download_link, "https://dl.dropboxusercontent.com/u/621599/work/Lamp-3.0-setup.exe"
end

system "gpio mode #{settings.transmitter_pin} out"
system "gpio mode #{settings.r_jolly_led_pin} out"
system "gpio mode #{settings.g_computer_led_pin} out"
system "gpio mode #{settings.b_phone_led_pin} out"

$pids = []

$leds = {
  settings.r_jolly_led_pin => :off,
  settings.g_computer_led_pin => :off,
  settings.b_phone_led_pin => :off
}

# start notification
$leds.keys.each do |key|
  system "gpio write #{key} 1"
  sleep 0.6
end

# reset
$leds.keys.each do |key|
  system "gpio write #{key} 0"
  sleep 0.6
end

FileUtils.rm("#{Dir.tmpdir}/blink.lock") rescue nil

get '/lamp/:device' do
  system "gpio write #{settings.transmitter_pin} 1"
  sleep 0.5
  system "gpio write #{settings.transmitter_pin} 0"

  case params[:device]
  when 'osx', 'win'
    $leds[settings.r_jolly_led_pin] = :on
  when 'droid'
    $leds[settings.g_computer_led_pin] = :on
  end

  $pids.each do |pid|
    Process.kill("HUP", pid) rescue nil
  end

  $pids.clear

  sleep 1

  $pids << fork do
    $interrupt = false

    Signal.trap("HUP") do
      $interrupt = true
    end

    while true do
      if $interrupt
        system "gpio write #{settings.r_jolly_led_pin} 0"
        system "gpio write #{settings.g_computer_led_pin} 0"
        system "gpio write #{settings.b_phone_led_pin} 0"
        break
      else
        $leds.each do |led, value|
          if value == :on
            sleep 0.8
            system "gpio write #{led} 1"
            sleep 0.6
            system "gpio write #{led} 0"
          end
        end
      end
    end

  end

  params[:device]
end

get '/lamp/:device/version' do

  case params[:device]
  when 'osx'
    version = settings.lampiosx_version
  when 'win'
    version = settings.lampiwin_version
  end

  version
end

get '/lamp/:device/download' do

  case params[:device]
  when 'osx'
    download_link = settings.lampiosx_download_link
  when 'win'
    download_link = settings.lampiwin_download_link
  end

  download_link
end

get '/lamp/led/reset' do

  $pids.each do |pid|
    Process.kill("HUP", pid) rescue nil
  end

  $pids.clear

  $leds.keys.each do |key|
    $leds[key] = :off    
  end

  'ok'
end


