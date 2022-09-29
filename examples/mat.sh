
spec_template="{\"workflow\": \"matXXX\",\"sourceKeyspace\": \"load1\",\"targetKeyspace\": \"load1\",\"tableSettings\": [{\"targetTable\": \"tXXX\",\"sourceExpression\": \"select * from x\",\"create_ddl\": \"create table tXXX(id bigint, id2 bigint, primary key(id))\"}]}"

for t in {1..1}
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
