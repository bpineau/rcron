%option nounput
%option yylineno
%{
#include "rcron_conf-parser.h"
#include "rcron_conf.h"

#define YY_NO_INPUT  1

int lineno = 1;
%}

separator	[\t =]+

%%
{separator}			;
^[#;].*$			;
^{separator}*cluster_name	{ yylval.string = yytext; return CLUSTERNAME;}
^{separator}*state_file		{ yylval.string = yytext; return STATEFILE;}
^{separator}*default_state	{ yylval.string = yytext; return DEFAULTSTATE;}
^{separator}*syslog_facility	{ yylval.string = yytext; return SFACILITY;}
^{separator}*syslog_level	{ yylval.string = yytext; return SLEVEL;}
^{separator}*nice_level		{ yylval.string = yytext; return NICELEVEL;}
[Aa][Cc][Tt][Ii][Vv][Ee]	{ yylval.bool = 1; return ACTV_PASSV; }
[Pp][Aa][Ss][Ss][Ii][Vv][Ee]	{ yylval.bool = 0; return ACTV_PASSV; }
[Ll][Oo][Gg]_(auth|AUTH|CRON|cron|DAEMON|daemon|FTP|ftp|KERN|kern|LPR|lpr|MAIL|mail|NEWS|news|SYSLOG|syslog|USER|user|UUCP|uucp|LOCAL[0-7]|local[0-7]) { 
				  yylval.string = yytext; return SYSL_FACILITY; }
\"[Ll][Oo][Gg]_(auth|AUTH|CRON|cron|DAEMON|daemon|FTP|ftp|KERN|kern|LPR|lpr|MAIL|mail|NEWS|news|SYSLOG|syslog|USER|user|UUCP|uucp|LOCAL[0-7]|local[0-7])\" { 
				  yylval.string = yytext; return QSYSL_FACILITY; }
'[Ll][Oo][Gg]_(auth|AUTH|CRON|cron|DAEMON|daemon|FTP|ftp|KERN|kern|LPR|lpr|MAIL|mail|NEWS|news|SYSLOG|syslog|USER|user|UUCP|uucp|LOCAL[0-7]|local[0-7])' { 
				  yylval.string = yytext; return QSYSL_FACILITY; }
[Ll][Oo][Gg]_(EMERG|emerg|ALERT|alert|CRIT|crit|ERR|err|WARNING|warning|NOTICE|notice|INFO|info|DEBUG|debug) {
				  yylval.string = yytext; return SYSL_LEVEL; }
\"[Ll][Oo][Gg]_(EMERG|emerg|ALERT|alert|CRIT|crit|ERR|err|WARNING|warning|NOTICE|notice|INFO|info|DEBUG|debug)\" {
				  yylval.string = yytext; return QSYSL_LEVEL; }
'[Ll][Oo][Gg]_(EMERG|emerg|ALERT|alert|CRIT|crit|ERR|err|WARNING|warning|NOTICE|notice|INFO|info|DEBUG|debug)' {
				  yylval.string = yytext; return QSYSL_LEVEL; }
[Tt][rR][Uu][eE]                { yylval.bool = 1; return BOOLEAN; }
[Ff][Aa][Ll][Ss][eE]            { yylval.bool = 0; return BOOLEAN; }
[Yy][Ee][Ss]                    { yylval.bool = 1; return BOOLEAN; }
[Nn][Oo]                        { yylval.bool = 0; return BOOLEAN; }
[-0-9]+				{ yylval.val = atoi(yytext); return INTEGER; }
\"[^"]*\"			{ yylval.string = yytext; return QSTRING;}
'[^']*'				{ yylval.string = yytext; return QSTRING;}
[^'" \t\n]+			{ yylval.string = yytext; return STRING;}
^{separator}*\n			{ lineno++; }
{separator}*\n			{ lineno++; return EOL; }
<<EOF>>				{ return 0 ; }
%%

void yyerror (char *s)
{
	warning("%s line %i ('%s'): %s\n", conffile, lineno, yytext, s);
	exit(1);
}
