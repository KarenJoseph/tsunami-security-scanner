#! /bin/sh

############################################################################################
# Prerequisites:
# You should have kubectl and helm clients
# You should have your kubeconfig configured to the cluster you wish the scans will run on
# That k8s cluster should have network access to the target servers
############################################################################################

while getopts f:l:n:e:p:h flag; do
    case "${flag}" in
        f) file=${OPTARG};;
        l) hosts_list=${OPTARG};;
        n) number_parallel=${OPTARG};;
	e) ES_HOST=${OPTARG};;
	p) ES_PASSWORD=${OPTARG};;
        h) echo "Run Tsunami Scan on a list of servers"
	   echo "bash  TsunamiScanTheseServers.sh -l "172.31.10.93 172.31.21.64 172.31.27.76 172.31.38.67" -n 1 -e https://gloat.es.eu-west-1.aws.found.io:9243 -p <password not conatining ~>"
           echo "  -f  file containing list of servers seperated by space/new-line";
           echo "      example: bash ./TsunamiScanTeseServers.sh -f lists/servers_list";
           echo "  -l  string containing list of servers seperated by space";
           echo "      example: bash ./TsunamiScanTeseServers.sh -l '100.67.12.14 100.77.34.9'"
           echo "  -n  number of parallel jobs to run. default is 4"
           echo "      example: [...] -f lists/servers_list -n 8"
	   echo "  -e  Your ES service. default is https://elastic:9200"
	   echo "      example: [...] -e https://gloat.kb.eu-west-1.aws.found.io:9243"
           echo "  -p  Your ES password. default is elastic"
           echo "      example: [...] -p nuinsxui872ndhc"
	   exit 1 ;;
    esac
done

source TsunamiFunctions.sh

# installs redis on k8s
install_redis_queue

# here i'm populating the k8s deployed queue - if you are using your own - you need to populate your redis
populate_queue

# if tsunami scan job already existed from the same date, delete it
delete_old_tsunami_job

# create secret with es creds
create_es_secret

# runs a job with n number of pods in parallel, reading entries from redis
run_tsunami_scans


#clean_deployments
