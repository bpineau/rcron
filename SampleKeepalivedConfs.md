# Configurations examples #
Sample keepalived configuration files to maintain servers states informations (in state\_file) up to date.

Note that keepalived won't update the state\_file when exiting. This can be dealt with by tweaking init scripts, or using a monitoring (local) cron job or daemon...

### Simple setup, one cluster ###

Server1 will be our "active" server by default. Server2 will be passive (won't really execute cron jobs) until server1 is down or unreachable.

**server1, rcron.conf**
```
cluster_name 	= mycluster
state_file 	= /var/run/rcron/state
default_state 	= active
```

**server1, keepalived.conf**
```
vrrp_instance VI_1 {
    state MASTER
    interface eth0
    virtual_router_id 31
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    notify_backup "/bin/echo passive > /var/run/rcron/state"
    notify_master "/bin/echo active  > /var/run/rcron/state"
    notify_fault  "/bin/echo passive > /var/run/rcron/state"
}
```

**server2, rcron.conf**
```
cluster_name 	= mycluster
state_file 	= /var/run/rcron/state
default_state 	= passive
```

**server2, keepalived.conf**. Note that only two params changed : "state" and "priority".
```
vrrp_instance VI_1 {
    state SLAVE
    interface eth0
    virtual_router_id 31
    priority 99
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    notify_backup "/bin/echo passive > /var/run/rcron/state"
    notify_master "/bin/echo active  > /var/run/rcron/state"
    notify_fault  "/bin/echo passive > /var/run/rcron/state"
}
```

### Multiple clusters setup ###
In this scenario, both severs will run some of the redundant jobs. And both will preempt jobs when the other server is down.

**server1, crontab**
```
    12 11 * * * /usr/bin/rcron --conf /etc/rcron/rcron_groupA.conf myjob1
    14 11 * * * /usr/bin/rcron --conf /etc/rcron/rcron_groupB.conf myjob2
```

**server1, rcron\_groupA.conf**
```
cluster_name 	= mycluster
state_file 	= /var/run/rcron/state_groupA
default_state 	= active
```

**server1, rcron\_groupB.conf**
```
cluster_name 	= secondcluster
state_file 	= /var/run/rcron/state_groupB
default_state 	= passive
```

**server1, keepalived.conf**
```
vrrp_instance VI_1 {
    state MASTER
    interface eth0
    virtual_router_id 31
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    notify_backup "/bin/echo passive > /var/run/rcron/state_groupA"
    notify_master "/bin/echo active  > /var/run/rcron/state_groupA"
    notify_fault  "/bin/echo passive > /var/run/rcron/state_groupA"
}

vrrp_instance VI_2 {
    state SLAVE
    interface eth0
    virtual_router_id 32
    priority 99
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    notify_backup "/bin/echo passive > /var/run/rcron/state_groupB"
    notify_master "/bin/echo active  > /var/run/rcron/state_groupB"
    notify_fault  "/bin/echo passive > /var/run/rcron/state_groupB"
}
```

**server2, crontab**
```
    12 11 * * * /usr/bin/rcron --conf /etc/rcron/rcron_groupA.conf myjob1
    14 11 * * * /usr/bin/rcron --conf /etc/rcron/rcron_groupB.conf myjob2
```

**server2, rcron\_groupA.conf**
```
cluster_name 	= mycluster
state_file 	= /var/run/rcron/state_groupA
default_state 	= passive
```

**server2, rcron\_groupB.conf**
```
cluster_name 	= secondcluster
state_file 	= /var/run/rcron/state_groupB
default_state 	= active
```

**server2, keepalived.conf**
```
vrrp_instance VI_1 {
    state SLAVE
    interface eth0
    virtual_router_id 31
    priority 99
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    notify_backup "/bin/echo passive > /var/run/rcron/state_groupA"
    notify_master "/bin/echo active  > /var/run/rcron/state_groupA"
    notify_fault  "/bin/echo passive > /var/run/rcron/state_groupA"
}

vrrp_instance VI_2 {
    state MASTER
    interface eth0
    virtual_router_id 32
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    notify_backup "/bin/echo passive > /var/run/rcron/state_groupB"
    notify_master "/bin/echo active  > /var/run/rcron/state_groupB"
    notify_fault  "/bin/echo passive > /var/run/rcron/state_groupB"
}
```