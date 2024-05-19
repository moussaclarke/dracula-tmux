#!/usr/bin/env bash
# setting the locale, some users have issues with different locales, this forces the correct one
export LC_ALL=en_US.UTF-8

HOSTS="google.com github.com example.com"

get_ssid()
{
  # Check OS
  case $(uname -s) in
    Linux)
      SSID=$(iw dev | sed -nr 's/^\t\tssid (.*)/\1/p')
      if [ -n "$SSID" ]; then
        printf '%s' "$SSID"
      else
        echo 'Ethernet'
      fi
      ;;

    Darwin)
      # Identify the active network interface
      interface=$(ifconfig | awk '/en0/ && /inet/ {print "en0"} /en1/ && /inet/ {print "en1"}')
      # Get the airport network information
      airport=$(networksetup -getairportnetwork $interface | cut -d ':' -f 2 | sed 's/^[[:blank:]]*//g')
      # Check for wireless error message
      notwifi=$(echo "$airport" | sed -n '/Error obtaining wireless information./p')

      if [ -z "$notwifi" ] && [ -n "$airport" ]; then
        echo "$airport"
      elif [ -n "$interface" ]; then
          echo 'Ethernet'
      else
          echo 'No connection found'
      fi
      ;;

    CYGWIN*|MINGW32*|MSYS*|MINGW*)
      # leaving empty - TODO - windows compatability
      ;;

    *)
      ;;
  esac

}

main()
{
  network="Offline"
  for host in $HOSTS; do
    if ping -q -c 1 -W 1 $host &>/dev/null; then
      network="$(get_ssid)"
      break
    fi
  done

  echo "$network"
}

#run main driver function
main
