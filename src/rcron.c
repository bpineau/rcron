/* rcron -- redundancy for cron jobs
 *
 * Copyright (c) 2009 Benjamin Pineau
 * Distributed under MIT license, see LICENSE file.
 */
#include <libgen.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <sys/time.h>
#include <sys/resource.h>

#include "rcron_conf.h"

void usage(char *pname);

int main(int argc, char *argv[])
{
	char *cli;
	int ret, i, d = 1, s = 0;
	time_t start, end;
	char *conf = DEFCONF;
	rconf *cfg;

	progname = basename(argv[0]);

	if (argc < 2) {
		warning("not enough arguments.");
		usage(progname);
		exit(1);
	}

	if (strstr(argv[1], "--conf") != NULL) {
		if (argc < 4) {
			warning("not enough arguments.");
			usage(progname);
			exit(1);
		}
		conf = argv[2];
		d = 3;
	}

	for (i = d; i < argc; i++)
		s += strlen(argv[i]) + 1;

	if ((cli = malloc(s + argc + 1)) == NULL) {
		warning("out of memory");
		return 1;
	}

	for (*cli = '\0', i = d; i < argc; i++) {
		strncat(cli, argv[i], strlen(argv[i]));
		if (i + 1 < argc) strncat(cli, " ", 1);
	}

	cfg = parse_conf(conf);
	parse_state(cfg);
	
	openlog(progname, LOG_PID | LOG_NDELAY, cfg->syslog_facility);

	if (cfg->current_state == STPASSIVE) {
		syslog(cfg->syslog_level,
			"cluster=%s state=passive status=ignore cmd=%s",
			cfg->cluster_name, cli);
		free(cli);
		return 0;
	}

	start = time(NULL);
	syslog(cfg->syslog_level, 
		"cluster=%s state=active status=start cmd=%s",
		cfg->cluster_name, cli);

	setpriority(PRIO_PROCESS, 0, cfg->nice_level);
	ret = system(cli);

	end = time(NULL);
	syslog(cfg->syslog_level,
		"cluster=%s state=active status=%s dur=%i cmd=%s",
		cfg->cluster_name, ret > 0 ? "fail" : "ok", 
		(int)(end - start), cli);

	free(cli);
	closelog();

	return ret;
}

int parse_state(rconf *cfg)
{
	FILE *fd;
	char str[10];

	if ((fd = fopen(cfg->state_file, "r")) == NULL) {
		warning("failed to open state file '%s' : %s",
				cfg->state_file, strerror(errno));
		return 1;
	}

	if ((fgets(str, 10, fd)) == NULL) {
		warning("failed to read state file '%s' : %s",
				cfg->state_file, strerror(errno));
		return 1;
	}

	if (strstr(str, "active")) {
		cfg->current_state = STACTIVE;
	} else if (strstr(str, "passive")) {
		cfg->current_state = STPASSIVE;
	} else {
		warning("corrupted state file '%s' (content='%s'), "
			"staying at default state (%s)", cfg->state_file, str,
			cfg->current_state ?  "active" : "passive");
	}

	fclose(fd);
	return 0;
}

void usage(char *pname)
{
	fprintf(stderr, 
		"Usage:\n%s [--conf configfile] command [args]\n",
		pname);
}

