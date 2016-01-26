date=$(date);ssh $1 -p 9022 date -s \"$date\"
