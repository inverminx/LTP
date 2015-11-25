#!/usr/bin/expect
set timeout 20
set host [lindex $argv 0]
set user [lindex $argv 1]
set password [lindex $argv 2]
set remoteHost [lindex $argv 3]
set remoteUser [lindex $argv 4]
set remotePassword [lindex $argv 5]
set backupFileName [lindex $argv 6]
#spawn $env(SHELL)
spawn ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${user}\@${host}
#spawn ssh "$user\@$host"
expect "password:"
#sleep 1
send "$password\r"
expect "ADVA-->"
send "admin database\r"
expect "ADVA:database-->"
send "backup-db\r"
expect "ADVA:database-->"
send "transfer-file scp put ${remoteUser} ${remotePassword} ip-address ${remoteHost} ${backupFileName}\r"
expect "ADVA:database-->"
send "back\r"
expect "ADVA-->"
send "logout\n"


