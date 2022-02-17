# Tsunami

Run Tsunami Network Scans on your servers and Get Notified on Critical findings

## Prerequisites

 1. You should have a kubectl client configured to the cluster you wish workers will run on

 1. That k8s cluster should have network access to the target servers

 1. You should have Elastic & Kibana running. You can follow [Deploy ECK in your K8s cluster] (https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-deploy-eck.htmli) or use your own existing tls disabled EK.

## Configure Index, Kibana view and Alerts

 1. Add an ES index called tsunami
   ```
   curl -u "elastic:${ES_PASSWORD}" -k -XPUT "${ES_HOST}/tsunami"
   ```

 2. Add a kibana view for tsunami index
   ```
   curl -u "elastic:qBQswjTM6tTUlwozsqqv07ff" -k -X POST "https://gloat.kb.eu-west-1.aws.found.io:9243/api/index_patterns/index_pattern" -H 'kbn-xsrf: true' -H 'Content-Type: application/json' -d'
{
  "index_pattern": {
     "title": "tsunami"
  }
}
'
   ```

 3. Add your alert rule to kibana. You can use this [Kibana alerting rules API](https://www.elastic.co/guide/en/kibana/current/create-rule-api.html)
    I have Added a rule that runs every 24hr, checkes elastic docs matching the following ES query in the last 24 hr:
    ```
    {
      "query": {
        "bool" : {
          "must" : {
            "term" : { "scanFindings.vulnerability.severity" : "CRITICAL" }
          }
        }
      }
    }
    ```

## Run The Scans
 1.  Goto scripts folder and run TsunamiScanTheseServers.sh:

     ```
     cd scripts
     #### Please read the help to understand the meaning of each flag ###
     bash  TsunamiScanTheseServers.sh -h
     ####
     bash  TsunamiScanTheseServers.sh -l "172.31.10.93 172.31.21.64 172.31.27.76 172.31.38.67" -n 1 -e https://gloat.es.eu-west-1.aws.found.io:9243 -p <password not conatining ~>
     ```

     You can also provide a file instead of a servers list

 2. NOTICE - You can run this priodically if you want to continually scan your servers (make sure the ips list is updated as well). This can be done as a cron/job/other, or run on demand

## Solution Description

![alt text](https://github.com/KarenJoseph/tsunami-security-scanner/blob/master/pics/diamgram.PNG?raw=true)

List of servers to scan is entered into a redis FIFO queue.

A k8s job is then run with number of parallel scans to be performed at once.

Each job takes an entry for the queue and runs the scan on.

If creats a json results file. I have found that the json contains too large and unusuful information.

The json can be sent to logstash to prase, but I found it simpler to remove those lines using sed.

That cleaned json is sent to ES.

The rules you defined in Kibana will run as defined to send Alerts.
