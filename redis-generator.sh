#!/bin/bash
######################################################
# for centos 7 only
# written by George Liu (eva2000) centminmod.com
######################################################
# variables
#############
DT=`date +"%d%m%y-%H%M%S"`

STARTPORT=6479
DEBUG_REDISGEN='y'
######################################################
# functions
#############

if [ ! -f /usr/lib/systemd/system/redis.service ]; then
  echo
  echo "/usr/lib/systemd/system/redis.service not found"
  echo "Script is for CentOS 7 only and requires redis"
  echo "server installed first"
  echo
  exit
fi

genredis() {
  # increment starts at 0
  NUMBER=$(($1-1))
  if [[ "$NUMBER" -le '1' ]]; then
    NUMBER=1
  fi
  echo
  echo "Creating redis servers starting at TCP = $STARTPORT..."
  for (( p=0; p <= $NUMBER; p++ ))
    do
      REDISPORT=$(($STARTPORT+$p))
      echo "-------------------------------------------------------"
      echo "creating redis server: redis${REDISPORT}.service [increment value: $p]"
      echo "redis TCP port: $REDISPORT"
      if [[ "$DEBUG_REDISGEN" = [yY] ]]; then
        if [ ! -f "/usr/lib/systemd/system/redis${REDISPORT}.service" ]; then
          echo "create systemd redis${REDISPORT}.service"
          echo "cp -a /usr/lib/systemd/system/redis.service /usr/lib/systemd/system/redis${REDISPORT}.service"
        fi
        if [ ! -f "/etc/redis${REDISPORT}.conf" ]; then
          echo "create /etc/redis${REDISPORT}.conf config file"
          echo "cp -a /etc/redis.conf /etc/redis${REDISPORT}.conf"
        fi      
        echo "sed -i \"s|^port 6379|port $REDISPORT|\" "/etc/redis${REDISPORT}.conf""
        echo "sed -i 's|^daemonize no|daemonize yes|' "/etc/redis${REDISPORT}.conf""
        echo "sed -i \"s|pidfile \/var\/run\/redis_6379.pid|pidfile \/var\/run\/redis\/redis_${REDISPORT}.pid|\" "/etc/redis${REDISPORT}.conf""
        echo "sed -i \"s|\/var\/log\/redis\/redis.log|\/var\/log\/redis\/redis${REDISPORT}.log|\" "/etc/redis${REDISPORT}.conf""
        echo "sed -i \"s|dbfilename dump.rdb|dbfilename dump${REDISPORT}.rdb|\" "/etc/redis${REDISPORT}.conf""
        echo "sed -i \"s|appendfilename \"appendonly.aof\"|appendfilename \"appendonly${REDISPORT}.aof\"|\" "/etc/redis${REDISPORT}.conf""
        echo "echo \"#masterauth abc123\" >> "/etc/redis${REDISPORT}.conf""
        echo "sed -i \"s|\/etc\/redis.conf|\/etc\/redis${REDISPORT}.conf|\" "/usr/lib/systemd/system/redis${REDISPORT}.service""
        echo "systemctl daemon-reload"
        echo "systemctl restart redis${REDISPORT}"
        echo "Redis TCP $REDISPORT Info:"
        echo "redis-cli -h 127.0.0.1 -p $REDISPORT INFO SERVER"
      else
        if [ ! -f "/usr/lib/systemd/system/redis${REDISPORT}.service" ]; then
          echo "create systemd redis${REDISPORT}.service"
          echo "cp -a /usr/lib/systemd/system/redis.service /usr/lib/systemd/system/redis${REDISPORT}.service"
          cp -a /usr/lib/systemd/system/redis.service "/usr/lib/systemd/system/redis${REDISPORT}.service"
        fi
        if [ ! -f "/etc/redis${REDISPORT}.conf" ]; then
          echo "create /etc/redis${REDISPORT}.conf config file"
          echo "cp -a /etc/redis.conf /etc/redis${REDISPORT}.conf"
          cp -a /etc/redis.conf "/etc/redis${REDISPORT}.conf"
        fi
        ls -lah "/usr/lib/systemd/system/redis${REDISPORT}.service" "/etc/redis${REDISPORT}.conf "
        sed -i "s|^port 6379|port $REDISPORT|" "/etc/redis${REDISPORT}.conf"
        sed -i 's|^daemonize no|daemonize yes|' "/etc/redis${REDISPORT}.conf"
        sed -i "s|pidfile \/var\/run\/redis_6379.pid|pidfile \/var\/run\/redis\/redis_${REDISPORT}.pid|" "/etc/redis${REDISPORT}.conf"
        sed -i "s|\/var\/log\/redis\/redis.log|\/var\/log\/redis\/redis${REDISPORT}.log|" "/etc/redis${REDISPORT}.conf"
        sed -i "s|dbfilename dump.rdb|dbfilename dump${REDISPORT}.rdb|" "/etc/redis${REDISPORT}.conf"
        sed -i "s|appendfilename \"appendonly.aof\"|appendfilename \"appendonly${REDISPORT}.aof\"|" "/etc/redis${REDISPORT}.conf"
        echo "#masterauth abc123" >> "/etc/redis${REDISPORT}.conf"
        sed -i "s|\/etc\/redis.conf|\/etc\/redis${REDISPORT}.conf|" "/usr/lib/systemd/system/redis${REDISPORT}.service"
        systemctl daemon-reload
        systemctl restart redis${REDISPORT}
        echo "## Redis TCP $REDISPORT Info ##"
        redis-cli -h 127.0.0.1 -p $REDISPORT INFO SERVER
      fi
  done
}

######################################################
NUM=$1

if [[ ! -z "$NUM" && "$NUM" -eq "$NUM" ]]; then
  # NUM is a number
  genredis $NUM
else
  echo
  echo "Usage where X equal postive integer for number of redis"
  echo "servers to create with incrementing TCP redis ports"
  echo "starting at STARTPORT=6479"
  echo
  echo "$0 X"
fi