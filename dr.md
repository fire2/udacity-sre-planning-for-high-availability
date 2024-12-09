# Infrastructure

## AWS Zones
Infrastructure will be deployed to regions us-east-2 and us-west-1.
In region us-east-2, resources will be deployed to 3 availability zones: "us-east-2a", "us-east-2b" and "us-east-2c".
In region us-west-1, resources will be deployed to 2 availability zones: "us-west-1a" and "us-west-1b".

## Servers and Clusters

### Table 1.1 Summary
Note: the numbers indicated in the "Qty" column are per AWS region.

| Asset | Purpose                              | Size        | Qty                     | DR                              |
|-------|--------------------------------------|-------------|-------------------------|---------------------------------|
| VPC   | Run application                      |             | 1 instance              | Created in both regions.        |
| EC2   | Run Flask application                | t3.micro    | 3 instances             | Created in both regions.        |
| ALB   | Balance requests among EC2 instances |             | 1 per availability zone | Created in both regions.        |
| EKS   | Run Prometheus and Grafana           | t3.medium   | 1 cluster x 2 nodes     | Created in both regions.        |
| RDS   | Application database                 | db.t2.small | 1 cluster x 2 nodes     | Replicated to secondary region. |

### Descriptions

The VPC (virtual private cloud) is the mandatory virtual network where all resources are provisioned and allows them to 
connect to each other within subnets. VPCs are specific to a region, so 1 is provisioned in each region. 

The application is deployed and runs in EC2 virtual machines. In each region, 3 instances are provisioned to be able to 
handle more load (high availability) and avoid the EC2 instance from being a single point of failure. In case one of the
instances is unhealthy the other instances will serve the requests. Note: in this solution, all 3 instances are deployed 
to the same availability zone (as in the exercises during the course) but an improvement would be to deploy them across 
multiple availability zones in the same region as well.

An application load balancer (ALB) is deployed with 3 instances as well, one in each availability zone, to provide fault
tolerance in case of them fails. An odd number (3) is chosen to support the voting system in case one load balancer is 
unstable. The load balancer routes traffic to the EC2 instances running the application on port 80.

An EKS cluster is provisioned to run the monitoring tools Prometheus and Grafana. The cluster is made up of 2 nodes
(instances) so pods are scheduled in different instances to reduce single points of failure, and to allow EKS to 
automatically reschedule pods in the second instance in the event one of the instance fails and/or has to restart.
In case the complete EKS cluster goes down, we could use the EKS in the DR region (us-west-2), provided the monitoring
helm chart is already installed and running, and configure it to scrape the metrics from the EC2 instances running in the
primary region (same configuration as the primary EKS cluster).

Finally, an RDS SQL database cluster is provisioned with high availability: 2 nodes across different availability zones
within the region. By default, 1 node is the write instance and the secondary one is a read-only instance. In case of a 
failure in the writer instance, the reader instance would automatically be promoted to a writer instance and new reader 
instance would be provisioned if the existing one cannot heal itself. The cluster is configured to make daily backups, 
with a retention of 5 days. A cluster with the same configuration is provisioned in the DR region as well. In the DR 
cluster, data replication is enabled from the cluster in the primary region. In the case of DR a failover would be done 
with near zero downtime since all data is synced automatically from the primary cluster.

Note: ideally a Route 53 hosted zone is provisioned in front of the ALB in the primary region. This makes it easy to 
perform a failover to the ALB in the DR region, but is out of the scope of this project. 

## DR Plan
### Pre-Steps:

Ensure the infrastructure in us-west-1 (DR region) is:
- synced with the infrastructure on us-east-2 in terms of same number of resources and capacity
- deployed and working, to reduce the downtime in case of a disaster recovery failover. 
- monitoring Helm chart is installed and properly configured so Grafana is accessible

## Steps:

1. For an application server failover: assuming we have a cloud load balancer that is initially pointing to the ALB 
in us-east-2 (primary region), reconfigure it to point to the ALB in the DR region (us-west-1). In this case it would 
make sense to switch to using the monitoring tools (Grafana) in the DR region as well since it should be configured
to scrape the EC2 instances in the DR region.

2. For an EKS failover, use the DNS name of the load balancer for Grafana in the DR region while the primary EKS
cluster is restored. In this case, it might be necessary to configure Prometheus to scrape metrics from the primary EC2
instances during recovery of the primary EKS cluster, which may be a short period of time depending on the kind of issue
or disaster that caused the cluster to fail entirely.

3. For database DR, since it is highly available (2 instances per cluster), in case the writer instance has a failure,
the reader instance would automatically be promoted. No manual intervention is needed. In case of a regional failure
where the entire cluster is not available, the DR cluster would be automatically promoted as well without human
intervention and the primary cluster would become a replica. Once service is restored on the primary region, the 
cluster there would have to be promoted (manually) so the cluster in the DR region becomes a standby replica again. 
Ideally, the application is using a generic CNAME DNS record to connect to the database so no changes are needed on the 
connection string during the process.

4. In case the data becomes corrupt on both the primary and secondary clusters, data would have to be restored from the
latest backup. This would incur in data loss since the last backup was performed. The database can be restored from 
the AWS console. 