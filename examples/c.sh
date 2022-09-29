#load1=`mysql -h 127.0.0.1 -P 19327 -u msandbox --password=msandbox test -e "analyze table c1m"`
load1=`mysql -h 127.0.0.1 -P 19327 -u msandbox --password=msandbox test -e "select count(*) from c1\G" 2>&1 | grep count|cut -d" " -f2`
load2=`mysql -h 127.0.0.1 -P 21122 -u msandbox --password=msandbox load2 -e "select count(*) from t1\G" 2>&1 | grep count|cut -d" " -f2`
#load3=`mysql -h 127.0.0.1 -P 21122 -u msandbox --password=msandbox load2 -e "select count(*) from t300\G" 2>&1 | grep count|cut -d" " -f2`
echo $load1 $load2 $load3 `expr $load1 - $load2` `expr $load1 - ${load3:-0}`
