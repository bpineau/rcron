**rcron** is a minimal tool aiming to help sysadmins in setting up cron jobs redundancy and failover over groups of machines. It just ensures that a job installed on several machines will only run on the _active_ one at any time.

## Using rcron ##
A typical setup would be:
  1. Install rcron on servers sharing a common group of jobs (the "cluster").
  1. Edit rcron configuration file on each server. For instance :
    * /etc/rcron/rcron.conf on server1:
```
    # An arbitrary name
    cluster_name        = myredundant_jobs
    # A file containing either the word "active" or the word "passive"
    state_file          = /var/run/rcron/state
    # The default state in case state_file can't be read
    default_state       = active
    syslog_facility     = LOG_CRON
    syslog_level        = LOG_INFO
    # We can tune jobs niceness/priorities (see nice(1)).
    nice_level          = 19
```
    * /etc/rcron/rcron.conf on server2:
```
    cluster_name        = myredundant_jobs
    state_file          = /var/run/rcron/state
    default_state       = passive
    syslog_facility     = LOG_CRON
    syslog_level        = LOG_INFO
    nice_level          = 19
```
  1. Edit crontabs on all cluster's server to prefix relevant jobs definitions with rcron. Like:
```
  12 11 * * * /usr/bin/rcron myjob
```
  1. Configure an external tool to maintain the configured state\_file up to date: on the master server, this file must contain the word "active", and the word "passive" on slaves servers. See SampleKeepalivedConfs for instance.

## Principles ##
Cron jobs needing redundancy are launched by rcron rather than directly by cron.
When triggered by the cron deamon, rcron will look at his state file's content,
looking for the words "active" or "passive":
  * active: rcron will actually run the command
  * passive: rcron will return immediately


So rcron is a dumb tool with a K.I.S.S. design, and doesn't do much by itself:
  * It doesn't guess the machines states (active/passive, aka master/slave). It just rely on external tools (like keepalived or heartbeat or wackamole, or something depending on your business context) or manual interventions to update his state file's content.
  * It doe not synchronize crontabs content by itself (do it manually for the jobs needing high availability).
  * It does not synchronize any data or code needed to run the jobs (consider using NFS, ocfs2, csync2, or similar).
  * If an active server halt or crash while running a cron job, rcron won't transfer this job elsewhere nor relaunch it. But it does try to log enough informations so you can see which jobs got interrupted.

## Tips ##
Your crontabs can contain mixes of local only cron jobs and redundant jobs
managed by rcron:
```
    # a local only job
    12 11 * * * myjob1
    # a rcron handled job
    14 11 * * * rcron myjob2
```

For a given cluster, only one server can be active at any time, so the load won't be balanced. But you can define several different "cluster\_name" and "state\_file" per server by using different config files for the various jobs. So "server1" can be active by default for jobs using "cluster1" while "server2" can be active for "cluster2" jobs (and both will still preempt other's jobs in case of other server failure).
You would have then something like:
  * On boths server (server1 and server2) crontabs:
```
    12 11 * * * /usr/bin/rcron --conf /etc/rcron/rcronA.conf myjob1
    14 11 * * * /usr/bin/rcron --conf /etc/rcron/rcronB.conf myjob2
```
  * On boths servers /etc/rcron/rcronA.conf :
```
    cluster_name = some_jobs
    state_file = /var/run/rcron/stateA
```
  * On boths servers /etc/rcron/rcronB.conf :
```
    cluster_name = other_jobs
    state_file = /var/run/rcron/stateB
```
  * Configure some HA daemon (keepalived or so) to keep server1 default active for the job group A and server2 active for the job group B. See "Multiple clusters setup" in SampleKeepalivedConfs.

## Authors ##
Benjamin Pineau - ben |dot| pineau |at| gmail |dot| com