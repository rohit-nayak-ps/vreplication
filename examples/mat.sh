
spec_template="{\"workflow\": \"matXXX\",\"sourceKeyspace\": \"load1\",\"targetKeyspace\": \"load2\",\"tableSettings\": [{\"targetTable\": \"tXXX\",\"sourceExpression\": \"select * from c1m\",\"create_ddl\": \"create table tXXX(c1 bigint(20),val2 varchar(50) default null, primary key(c1))\"}]}"

for t in {319..400}
do
    spec=${spec_template//XXX/$t}
    vtctlclient -server localhost:25999 -log_dir ${VTDATAROOT}/tmp Materialize  "$spec"
    if [ $? -eq 1 ]
    then
       echo "Error in Materialize, exiting"
       exit
    fi
    echo "Created workflow mat$t"
    sleep 1
done
