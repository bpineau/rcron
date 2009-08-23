%{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "rcron_conf.h"

static char *cluster_name;
static char *state_file;
static char *syslog_facility;
static char *syslog_level;
static int  default_state;
static signed int  nice_level;

#define YYERROR_VERBOSE 1

int yylex(void);
int yyrestart(FILE *fd);
%}

%union {
	int	val;
	char	*string;
	int	bool;
}

%token <string>		STRING
%token <string>		QSTRING
%token <string>		SYSL_FACILITY
%token <string>		QSYSL_FACILITY
%token <string>		SYSL_LEVEL
%token <string>		QSYSL_LEVEL
%token <bool>		ACTV_PASSV
%token <bool>		BOOLEAN
%token <val>		INTEGER

%token		CLUSTERNAME
%token		STATEFILE
%token		DEFAULTSTATE
%token		SFACILITY
%token		SLEVEL
%token		NICELEVEL
%token		EOL

%%

config_file: 	lines
		;

lines:		one_line lines
		| one_line
		;

one_line:	line_CLUSTERNAME EOL
		| line_STATEFILE EOL
		| line_DEFAULTSTATE EOL
		| line_SFACILITY EOL
		| line_SLEVEL EOL
		| line_NICELEVEL EOL
		| EOL
		;

line_CLUSTERNAME: CLUSTERNAME STRING
	{{
		/* simple string */
		cluster_name = strdup($2);
	}}
	| CLUSTERNAME QSTRING
	{{
		/* quoted string */
		cluster_name = strdup($2 + 1);
		cluster_name[strlen(cluster_name) - 1] = 0;
	}}
	;

line_STATEFILE: STATEFILE STRING
	{{
		state_file = strdup($2);
	}}
	| STATEFILE QSTRING
	{{
		state_file = strdup($2 + 1);
		state_file[strlen(state_file) - 1] = 0;
	}}
	;

line_SFACILITY: SFACILITY SYSL_FACILITY
	{{
		syslog_facility = strdup($2);
	}}
	| SFACILITY QSYSL_FACILITY
	{{
		syslog_facility = strdup($2 + 1);
		syslog_facility[strlen(syslog_facility) - 1] = 0;
	}}
	;

line_SLEVEL: SLEVEL SYSL_LEVEL
	{{
		syslog_level = strdup($2);
	}}
	| SLEVEL QSYSL_LEVEL
	{{
		syslog_level = strdup($2 + 1);
		syslog_level[strlen(syslog_level) - 1] = 0;
	}}
	;

line_NICELEVEL:	NICELEVEL INTEGER { nice_level = $2; }

line_DEFAULTSTATE: DEFAULTSTATE ACTV_PASSV { default_state = $2; }


%%

rconf *parse_conf(char *cfile)
{
	rconf *cfg = NULL;
	FILE *fd;

	cluster_name    = DEFCLUSTER;
	state_file      = DEFSTFILE;
	default_state   = DEFSTATE;
	syslog_facility = DEFSYSLFACILITY;
	syslog_level    = DEFSYSLLEVEL;
	nice_level      = DEFNICE;

	conffile = cfile;

	if ((fd = fopen(cfile, "r")) == NULL)
		warning("failed to open config file '%s' : %s",
				cfile, strerror(errno));

	if (fd) {
		yyrestart(fd);
		yyparse();
		fclose(fd);
	}

	cfg = (rconf*) malloc(sizeof(rconf));
	cfg->cluster_name 	= cluster_name;
	cfg->state_file 	= state_file;
	cfg->default_state 	= default_state;
	cfg->current_state	= default_state;
	cfg->nice_level 	= nice_level;

	if (strcmp(syslog_facility, "LOG_AUTH") == 0) {
		cfg->syslog_facility 	= LOG_AUTH;
	} else if (strcmp(syslog_facility, "LOG_CRON") == 0) {
		cfg->syslog_facility 	= LOG_CRON;
	} else if (strcmp(syslog_facility, "LOG_DAEMON") == 0) {
		cfg->syslog_facility 	= LOG_DAEMON;
	} else if (strcmp(syslog_facility, "LOG_FTP") == 0) {
		cfg->syslog_facility 	= LOG_FTP;
	} else if (strcmp(syslog_facility, "LOG_KERN") == 0) {
		cfg->syslog_facility 	= LOG_KERN;
	} else if (strcmp(syslog_facility, "LOG_LPR") == 0) {
		cfg->syslog_facility 	= LOG_LPR;
	} else if (strcmp(syslog_facility, "LOG_MAIL") == 0) {
		cfg->syslog_facility 	= LOG_MAIL;
	} else if (strcmp(syslog_facility, "LOG_NEWS") == 0) {
		cfg->syslog_facility 	= LOG_NEWS;
	} else if (strcmp(syslog_facility, "LOG_SYSLOG") == 0) {
		cfg->syslog_facility 	= LOG_SYSLOG;
	} else if (strcmp(syslog_facility, "LOG_USER") == 0) {
		cfg->syslog_facility 	= LOG_USER;
	} else if (strcmp(syslog_facility, "LOG_UUCP") == 0) {
		cfg->syslog_facility 	= LOG_UUCP;
	} else if (strcmp(syslog_facility, "LOG_LOCAL0") == 0) {
		cfg->syslog_facility 	= LOG_LOCAL0;
	} else if (strcmp(syslog_facility, "LOG_LOCAL1") == 0) {
		cfg->syslog_facility 	= LOG_LOCAL1;
	} else if (strcmp(syslog_facility, "LOG_LOCAL2") == 0) {
		cfg->syslog_facility 	= LOG_LOCAL2;
	} else if (strcmp(syslog_facility, "LOG_LOCAL3") == 0) {
		cfg->syslog_facility 	= LOG_LOCAL3;
	} else if (strcmp(syslog_facility, "LOG_LOCAL4") == 0) {
		cfg->syslog_facility 	= LOG_LOCAL4;
	} else if (strcmp(syslog_facility, "LOG_LOCAL5") == 0) {
		cfg->syslog_facility 	= LOG_LOCAL5;
	} else if (strcmp(syslog_facility, "LOG_LOCAL6") == 0) {
		cfg->syslog_facility 	= LOG_LOCAL6;
	} else if (strcmp(syslog_facility, "LOG_LOCAL7") == 0) {
		cfg->syslog_facility 	= LOG_LOCAL7;
	}

	if (strcmp(syslog_level, "LOG_EMERG") == 0) {
		cfg->syslog_level	= LOG_EMERG;
	} else if (strcmp(syslog_level, "LOG_ALERT") == 0) {
		cfg->syslog_level 	= LOG_ALERT;
	} else if (strcmp(syslog_level, "LOG_CRIT") == 0) {
		cfg->syslog_level 	= LOG_CRIT;
	} else if (strcmp(syslog_level, "LOG_ERR") == 0) {
		cfg->syslog_level 	= LOG_ERR;
	} else if (strcmp(syslog_level, "LOG_WARNING") == 0) {
		cfg->syslog_level 	= LOG_WARNING;
	} else if (strcmp(syslog_level, "LOG_NOTICE") == 0) {
		cfg->syslog_level 	= LOG_NOTICE;
	} else if (strcmp(syslog_level, "LOG_INFO") == 0) {
		cfg->syslog_level 	= LOG_INFO;
	} else if (strcmp(syslog_level, "LOG_DEBUG") == 0) {
		cfg->syslog_level 	= LOG_DEBUG;
	}
	
	if (cfg->nice_level > 19 ||  cfg->nice_level < -20) {
		warning("nice_level value (%i) not in [-20,19] range, "
			"defaulting to 0.",
			cfg->nice_level);
		cfg->nice_level = 0;
	}

	return cfg;
}

