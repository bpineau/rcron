/* rcron -- redundancy for cron jobs
 *
 * Copyright (c) 2009 Benjamin Pineau
 * Distributed under MIT license, see LICENSE file.
 */
#include "config.h"
#include <errno.h>
#include <stdarg.h>
#include <syslog.h>

#define STACTIVE	1
#define STPASSIVE 	0
/* #define DEFCONF		"/etc/rcron/rcron.conf" */
#define DEFNICE		19
#define DEFSTATE	STACTIVE
#define DEFCLUSTER	"default_cluster"
#define DEFSTFILE	"/var/run/rcron/state"
#define DEFSYSLFACILITY	"LOG_CRON"
#define DEFSYSLLEVEL	"LOG_INFO"

#define warning(fmt, ...) \
   do { fprintf(stderr, "%s (%s:%d, %s) warning: " fmt "\n", progname, \
                         __FILE__, __LINE__, __func__, ## __VA_ARGS__); \
	syslog(LOG_INFO, "%s (%s:%d, %s) warning: " fmt "\n", progname, \
                         __FILE__, __LINE__, __func__, ## __VA_ARGS__); \
   } while (0)

typedef struct
{
	char *cluster_name;
	char *state_file;
	int  syslog_facility;
	int  syslog_level;
	int  default_state;
	int  current_state;
	signed int  nice_level;
} rconf;

char *progname;
char *conffile;

rconf *parse_conf(char *cfile);
int    parse_state(rconf *cfg);
void   yyerror (char *s);

