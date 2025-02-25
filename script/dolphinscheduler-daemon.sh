#!/bin/sh
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

usage="Usage: dolphinscheduler-daemon.sh (start|stop|status) <api-server|master-server|worker-server|alert-server|standalone-server> "

# if no args specified, show usage
if [ $# -le 1 ]; then
  echo $usage
  exit 1
fi

startStop=$1
shift
command=$1
shift

echo "Begin $startStop $command......"

BIN_DIR=`dirname $0`
BIN_DIR=`cd "$BIN_DIR"; pwd`
DOLPHINSCHEDULER_HOME=`cd "$BIN_DIR/.."; pwd`

source "${DOLPHINSCHEDULER_HOME}/bin/env/dolphinscheduler_env.sh"

export HOSTNAME=`hostname`

export DOLPHINSCHEDULER_LOG_DIR=$DOLPHINSCHEDULER_HOME/$command/logs

export STOP_TIMEOUT=5

if [ ! -d "$DOLPHINSCHEDULER_LOG_DIR" ]; then
  mkdir $DOLPHINSCHEDULER_LOG_DIR
fi

log=$DOLPHINSCHEDULER_HOME/$command-$HOSTNAME.out
pid=$DOLPHINSCHEDULER_HOME/$command/pid

cd $DOLPHINSCHEDULER_HOME/$command

if [ "$command" = "api-server" ]; then
  :
elif [ "$command" = "master-server" ]; then
  :
elif [ "$command" = "worker-server" ]; then
  :
elif [ "$command" = "alert-server" ]; then
  :
elif [ "$command" = "logger-server" ]; then
  :
elif [ "$command" = "standalone-server" ]; then
  :
else
  echo "Error: No command named '$command' was found."
  exit 1
fi

case $startStop in
  (start)
    echo starting $command, logging to $DOLPHINSCHEDULER_LOG_DIR
    nohup "$DOLPHINSCHEDULER_HOME/$command/bin/start.sh" > $log 2>&1 &
    echo $! > $pid
    ;;

  (stop)
      if [ -f $pid ]; then
        TARGET_PID=`cat $pid`
        if kill -0 $TARGET_PID > /dev/null 2>&1; then
          echo stopping $command
          pkill -P $TARGET_PID
          sleep $STOP_TIMEOUT
          if kill -0 $TARGET_PID > /dev/null 2>&1; then
            echo "$command did not stop gracefully after $STOP_TIMEOUT seconds: killing with kill -9"
            pkill -P -9 $TARGET_PID
          fi
        else
          echo no $command to stop
        fi
        rm -f $pid
      else
        echo no $command to stop
      fi
      ;;

  (status)
    # more details about the status can be added later
    serverCount=`ps -ef |grep "$CLASS" |grep -v "grep" |wc -l`
    state="STOP"
    #  font color - red
    state="[ \033[1;31m $state \033[0m ]"
    if [[ $serverCount -gt 0 ]];then
      state="RUNNING"
      # font color - green
      state="[ \033[1;32m $state \033[0m ]"
    fi
    echo -e "$command  $state"
    ;;

  (*)
    echo $usage
    exit 1
    ;;

esac

echo "End $startStop $command."
