#! /bin/sh

install_redis_queue() {
    # Redis installation based on: https://kubernetes.io/docs/tutorials/stateless-application/guestbook/
    # And this guide: https://kubernetes.io/docs/tasks/job/fine-parallel-processing-work-queue/
    # This should be installed in some namespace, but for simplicity kept yamls as are
    kubectl apply -f https://k8s.io/examples/application/guestbook/redis-leader-deployment.yaml
    kubectl apply -f https://k8s.io/examples/application/guestbook/redis-leader-service.yaml
    kubectl apply -f https://k8s.io/examples/application/guestbook/redis-follower-deployment.yaml
    kubectl apply -f https://k8s.io/examples/application/guestbook/redis-follower-service.yaml

    while [[ $(kubectl get pods -l app=redis,role=leader -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for pod" && sleep 1; done
}

# here i'm populating the k8s deployed queue - if you are using your own - you need to populate your redis
populate_queue() {
    redis_leader=$(kubectl get pods | grep redis-leader | awk '{print $1}')
    if [ ! -z  $file ]; then
        all_scan_ips=$(cat ${file} | uniq )
    elif [ ! -z "$hosts_list" ]; then
        all_scan_ips=${hosts_list}
    else
        echo "No hosts were provided. Exiting"
        exit
    fi

    for scan_ip in ${all_scan_ips}; do
        kubectl exec -it ${redis_leader} -- bash -c "redis-cli -r 1 rpush tsunamiServerScan ${scan_ip}"
    done
}

# if tsunami scan job already existed from the same date, delete it
delete_old_tsunami_job() {
    kubectl delete job tsunami-server-scan
}

create_es_secret() {
    if [ ! -z $ES_HOST ] && [ ! -z $ES_PASSWORD ]; then
      sed -Ei "s~host: .+~host: "${ES_HOST}"~" Secret.yaml
      cat Secret.yaml | sed -E "s~password: .+~password: "${ES_PASSWORD}"~" | kubectl apply -f -
      sed -Ei "s~host: "${ES_HOST}"~host: https://elasticsearch:9200~" Secret.yaml
    else
      kubectl apply -f Secret.yaml
    fi
}

# runs a job with n number of pods in parallel, reading entries from redis
run_tsunami_scans() {
    if [ ! -z $number_parallel ] ; then
        cat Job.yaml | sed -E "s/parallelism: [0-9]+/parallelism: ${number_parallel}/" | kubectl apply -f -
    else
        kubectl apply -f Job.yaml
    fi
}

clean_deployments() {
    kubectl delete deployment -l app=redis
    kubectl delete service -l app=redis
}



