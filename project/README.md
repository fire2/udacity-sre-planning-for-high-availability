# Deploying HA Infrastructure

Project 2 of the SRE Udacity NanoDegree. 
Author: Yoshiya Magana Martinez

### Dependencies

```
- helm
- Terraform
- Postman
- kubectl
- Prometheus and Grafana
```

## Project Structure

1. SLO/SLI document [here](slo_sli).
2. Details of the infrastructure according to the [requirement document](requirements.md) can be found [here](dr).
3. Prometheus queries used in the Grafana dashboard are in [prometheus_queries](prometheus_queries.md)
4. The screenshot of the Grafana dashboard is at [sre_grafana_dashboard.png](screenshots/sre_grafana_dashboard.png)
5. Screenshot of the successful Terraform apply on `zone1`: [zone1_tf.png](screenshots/zone1_tf.png). This includes the 
primary RDS cluster.
6. Screenshot of the successful Terraform apply on `zone2`: [zone2_tf.png](screenshots/zone2_tf.png). This includes the 
secondary RDS cluster.
7. Screenshot aws describe on the RDS cluster on zone2: [rds.png](screenshots/rds.png). This verifies successful 
provisioning of both clusters (note the ReplicationSourceIdentifier) and "in-sync" statuses on each instance.
8. Instead of deleting the RDS clusters manually, I ran this command before destroying `zone2` to promote the cluster 
to a standalone database so it could be destroyed via terraform:
```
aws rds promote-read-replica-db-cluster --db-cluster-identifier udacity-db-cluster-s --profile udacity --region us-west-1
```
Screenshot of destroying zone2: [zone2_tf_destroy.png](screenshots/zone2_tf_destroy.png)
Screenshot of destroying zone1: [zone1_tf_destroy.png](screenshots/zone1_tf_destroy.png). I had to destroy the resources
in multiple attempts because the first ones got stuck destroying the Grafana load balancer, that's why the screenshot 
shows way less resources deleted than initially created, because it only shows the resources deleted in the last 
attempt, after which there were no resources left in `zone1`. They were all destroyed incrementally during the multiple
attempts.

## General comments

- I added the creation of the `monitoring` namespace to the EKS cluster to circumvent having to create it manually and 
running `terraform apply` again.
- I did not like the setup in `zone1` creating resources in `zone2`, so I refactored it so each module contains only what 
is provisioned in that zone. The ARN of the DB cluster is an output of the `zone1` setup now, which is used in the 
`zone2` rds module. For consistency, each zone outputs its own private and public subnet ids, although they are not 
used across zones.
- I did the fixes and refactoring on the `zone1` and `zone2` during the first part of the project, since there were 
several issues included unsupported versions of K8S and MySQL in the code. Hence, only 1 screenshot per zone of the 
`terraform apply` output is submitted. Additionally, I included a screenshot of the following command on zone2 where 
you can see the cluster is provisioned and in sync with the primary cluster on zone1, as well as the 
ReplicationSourceIdentifier:
```
aws rds describe-db-clusters --profile udacity --region us-west-1
```

## License
[License](../LICENSE.md)
