#!/bin/bash

CONFIG_PATHS=$(awk -F: '{ print $2 }' /etc/unicorn.conf)
CONFIG=$(cat /etc/unicorn.conf)

start_app() {
  local path=$1
  local config_path=$2
  local bin=$3
  local user=$4

  cd $path
  sudo -iu $user bundle exec "${bin}" -c "${config_path}" -E production -D
  cd $OLDPWD
}

case "$1" in
  restart)
    $0 stop
    $0 start
  ;;

  reload)
    for path in ${CONFIG_PATHS}
    do
      pkill -USR2 -f "unicorn master.*${path}"
      echo "Waiting for new unicorns..."
      sleep 5
      pkill -QUIT -f "unicorn master \\(old\\).*${path}"
    done
  ;;

  start)
    for line in ${CONFIG}
    do
      # I'm too dumb to use bash arrays properly
      path=$(echo -n $line | awk -F: '{ print $1 }')
      config_path=$(echo -n $line | awk -F: '{ print $2 }')
      bin=$(echo -n $line | awk -F: '{ print $3 }')
      user=$(echo -n $line | awk -F: '{ print $4 }')

      if [ ! -z $2 ]
      then
        if [ $2 = $path ]
        then
          echo "${path} specified: starting it individually"
          start_app $path $config_path $bin $user
        fi
      else
        echo "Starting ${path}"
        start_app $path $config_path $bin $user
      fi
    done
  ;;

  stop)
    for path in ${CONFIG_PATHS}
    do
      echo "Killing ${path} with INT signal"
      pkill -INT -f "unicorn master.*${path}"
    done
  ;;
esac
