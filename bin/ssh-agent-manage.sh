#!/usr/bin/bash

AUTHOR="Arno-Can Uestuensoez"
LICENSE="Artistic-License-2.0 + Forced-Fairplay-Constraints"
COPYRIGHT="Copyright (C) 2017 Arno-Can Uestuensoez @Ingenieurbuero Arno-Can Uestuensoez"
VERSION='0.1.7'
DATE='2017-06-22'
WWW='https://arnocan.wordpress.com'
UUID='a8ecde1c-63a9-44b9-8ff0-6c7c54398565'
NICKNAME="Scotty"
MISSION="Beam you up to, where ever you want."

#
# persistenst vars
#
SSH_AGENT_PID=${SSH_AGENT_PID:-""}
SSH_AUTH_SOCK=${SSH_AUTH_SOCK:-""}
if [ -z "${SSH_ADDONS_DIRS}" ];then
    SSH_ADDONS_DIRS=~/.ssh
    SSH_ADDONS_DIRS=${SSH_ADDONS_DIRS}:~/data/.ssh
    SSH_ADDONS_DIRS=${SSH_ADDONS_DIRS}:/media/truecrypt1
fi


#
# temp vars, unset at last
#
FSEP=':'
STATE=0
ENVIRONMENT=0
VERBOSE=0
DEBUG=0
TERSE=0
LONG=0
FORCE=0
VERS=0
LIST=0
ENUMKEYS=0
ENUMTYPE=0
SORT=0
DELETE=0
SETAGENT=0
AGENTIDX=''
SETAGENTIDX=''
CURAGENTIDX=''
ADDKEY=0
KEYNAME=''
ADDAGENT=0
AGENTLABEL=''
LISTLABELS=0
LISAGENTPROCESSES=0
EXIT=0

unset LIFETIME

MYPATH=${BASH_SOURCE%/*}
. ${MYPATH}/bootstrap/bootstrap-03_01_009.sh

function printIt () {
    ((TERSE==0))&&echo "$*"
}
function printItOptional () {
    ((VERBOSE>=1))&&echo "VERB:$*"
}
function printDebug () {
    ((DEBUG>=1))&&echo "DBG:${BASH_LINENO[1]}:$*" >&2
}
function printError () {
	echo "ERR:${BASH_LINENO[0]}:$*" >&2
}
function printInfo () {
    ((TERSE==0))&&echo "INFO:${BASH_LINENO[0]}:$*" >&2
}
function printWarning () {
	echo "WNG:${BASH_LINENO[0]}:$*" >&2
}
function printEnv () {
    _PATH=${PATH//:/
        :}
    _SSH_ADDONS_DIRS=${SSH_ADDONS_DIRS//:/
        :}

    cat <<EOF

PATH                      = ${_PATH}

Utilized shell env for SSH:
   USER                   = ${USER}
   LOGNAME                = ${LOGNAME}
   HOME                   = ${HOME}
   MAIL                   = ${MAIL}
   DISPLAY                = ${DISPLAY}

Current SSH environment:

   Search for keys:
     SSH_ADDONS_DIRS      = ${_SSH_ADDONS_DIRS}

   Current assigned agent:
     SSH_AGENT_PID        = ${SSH_AGENT_PID}
     SSH_AUTH_SOCK        = ${SSH_AUTH_SOCK}

   SSH env:
     SSH_ASKPASS          = ${SSH_ASKPASS}
     SSH_CONNECTION       = ${SSH_CONNECTION}
     SSH_ORIGINAL_COMMAND = ${SSH_ORIGINAL_COMMAND}
     SSH_TTY              = ${SSH_TTY}
     SSH_USE_STRONG_RNG   = ${SSH_USE_STRONG_RNG}


EOF
}

function printHelp () {
    cat <<EOF

SYNOPSIS:

  ${BASH_SOURCE##*/} [OPTIONS]

DESCRIPTION:

  Enumerate SSH keys and SSH agents, manages and
  assigns to current shell/bash. Each call processes
  one action only, so multiple action require
  multiple calls. Exceptions are generic options,
  e.g. ' -v -V' for verbose/detailed version
  information.


  To be "sourced" for setting environment variables
  by '-e' in bash:

     '. set_ssh-agent.sh [OPTIONS]'

  else could be executed

     'set_ssh-agent.sh [batch] [OPTIONS]'

OPTIONS:

  -a [<name>] | --add-key[=<name>]
     Interactive add a key from a displayed list,
     or load a specified key with name.
     Sets/reads:
        SSH_ADDONS_DIRS

  -A [<label>] | --add-agent[=<label>]
     Creates a new agent.

  -c | --clear-agent
    Cleares the agent variables in current shell.

  -C | --clear-standard-mapping-path
    Cleares the assignment, removes in standard path only.
    Custom mapping bind adresses are not supported by
    this option, so has to be cleared manually.
    See also '-a' option of 'ssh-agent'.

  -e [<name>][:(a|p)] | --enum-keys [<name>][:(a|p)]
    Enumerate available keys based on SSH_ADDONS_DIRS.

       SSH_ADDONS_DIRS=${SSH_ADDONS_DIRS}

    Suboptions constraint the type:
      :a - all, private + pubic
      :p - public only
      default:=private only

  -E | --enum-assigned-labels
     Lists current assigned labels

  -f | --force
     Force execution, suppresses confirmation dialogue.

  -k [<name>] | --kill-key[=<name>]
    Delete loaded key.

  -K [<label>] | --kill-agent[=<label>]
     Kills agent, sets environment if active connection.
     The set of the environment requires 'source-call'.

  -l | --long
     Adds details to displayed information.

  -p | --list-loaded-keys
     Lists loaded keys of current agent.

  -P | --list-agent-processes
     Lists running agents

  -S [#index|<label>] | --set-agent[=#index|<label>]
     Interactive set agent, if only one this is the default.
     Sets:
       SSH_AGENT_PID
       SSH_AUTH_SOCK

  -s #index:<label> | --set-index=#index:<label>
     Assign a label to an index.

  --sort
     Sort output where applicable.

  -t <lifetime> | --lifetime[=<lifetime>]
	 Lifetime for the loaded key, same syntax as with 'ssh-agent'.

  --display-env | --de
     Displays environment.

  --filed-separator=<sep> | --fs <sep>
    Seperator for fields in case of CVS output.

  -h
     Short help.

  -help | --help
     Detailed help.

  -v | --verbose
     Verbose.

  -X | --terse
     Verbose.

  -V | --version
     Version, extended when combined with '-v'.

ENVIRONMENT:

  SSH_AGENT_PID
    See SSH.

  SSH_AUTH_SOCK
    See SSH.

  SSH_ADDONS_DIRS
    Defines search path for stored ID files in PATH syntax.
    See also option '-E'.

  SSH_ASKPASS
    See SSH.

  SSH_CONNECTION
    See SSH.

  SSH_ORIGINAL_COMMAND
    See SSH.

  SSH_TTY
    See SSH.

  SSH_USE_STRONG_RNG
    See SSH.

COPYRIGHT:

  $COPYRIGHT

LICENSE:

  $LICENSE

EOF
}

function printHelpShort () {
    cat <<EOF

  ${BASH_SOURCE##*/} [OPTIONS]

  -a [<name>]         | --add-key[=<name>]
  -A [<label>]        | --add-agent[=<label>]
  -c                  | --clear-agent
  -C                  | --clear-standard-mapping-path
  -e [<name>][:(a|p)] | --enum-keys[=<name>][:(a|p)]
  -E                  | --enum-assigned-labels
  -f                  | --force
  -k [<name>]         | --kill-key[=<name>]
  -K [<label>]        | --kill-agent[=<label>]
  -l                  | --long
  -p                  | --list-loaded-keys
  -P                  | --list-agent-processes
  -s #index:<label>   | --set-index=#index:<label>
  -S [#index|<label>] | --set-agent[=#index|<label>]
  -t <lifetime>       | --lifetime[=<lifetime>]

  --de                | --display-env
                        --sort
  --fs <sep>          | --filed-separator=<sep>

  -d                  | --debug
  -v                  | --verbose
  -X                  | --terse

  -V                  | --version

  -h (short)
  -help               | --help (detailed)

  Set for current shell with: '. set_ssh-agent.sh [OPTIONS]'
    SSH_AGENT_PID
    SSH_AUTH_SOCK

  Set search path for stored IDs files.
    SSH_ADDONS_DIRS

EOF
}

#
###
#
[[ "X$1" == "X" ]]&&{
	printHelpShort
	cat <<EOF

------------------------------

Requires at least one option.

EOF
	STATE=1
}

CHOICE=;
ARGS=$*
while [[ "X$1" != "X" ]];do
    case $1 in
		-a|--add-key)
			CHOICE=ADDKEY
			ADDKEY=1
			if [[ "X${2#-}" == "X${2}" ]];then
				KEYNAME=$2
				shift
			fi
			;;
		--add-key=*)
			CHOICE=ADDKEY
			ADDKEY=1
			KEYNAME=${1#*=}
			;;
		-A|--add-agent)
			ADDAGENT=1
			CHOICE=ADDAGENT
			if [[ "X${2#-}" == "X${2}" ]];then
				AGENTLABEL=$2
				shift
			fi
			;;
		--add-agent=*)
			ADDAGENT=1
			CHOICE=ADDAGENT
			AGENTLABEL=${1#*=}
			;;
		-c|--clear-agent)
			CLEARAGENT=1
			ENVIRONMENT=1
			CHOICE=CLEARAGENT
			;;
		-C|--clear-standard-mapping-path)
			CLEARMAP=1
			CHOICE=CLEARMAP
			;;
		-e|--enum-keys)
			ENUMKEYS=1
			CHOICE=ENUMKEYS
			if [[ "X${2#-}" == "X${2}" ]];then
				KEYNAME=${2%:*}
				ENUMTYPE=${2##*:}
				shift
			fi
			case $ENUMTYPE in
				'p')ENUMTYPE=1;;
				'a')ENUMTYPE=2;;
				*)ENUMTYPE=0;;
			esac
			;;
		--enum-keys=*)
			ENUMKEYS=1
			CHOICE=ENUMKEYS
			KEYNAME=${1#*=}
			KEYNAME=${1%:*}
			ENUMTYPE=${2##*:}
			case $ENUMTYPE in
				p)ENUMTYPE=1;;
				a)ENUMTYPE=2;;
				*)ENUMTYPE=0;;
			esac
			;;
        -E|--enum-assigned-labels)
			LISTLABELS=1
			CHOICE=LISTLABELS
        	;;
		-f|--force)
			FORCE=1
			;;
		--fs|--field-separator)
			if [[ "X${2#-}" == "X${2}" ]];then
				FSEP=$2
				shift
			fi
			;;
		--fs=*|--field-separator=*)
			FSEP=${1#*=}
			;;
		-k|--kill-key)
			DELETE=1
			CHOICE=DELETE
			if [[ "X${2#-}" == "X${2}" ]];then
				KEYNAME=$2
				shift
			fi
			;;
		--kill-key=*)
			DELETE=1
			CHOICE=DELETE
			KEYNAME=${1#*=}
			;;
		-K|--kill-agent)
			KILLAGENT=1
			CHOICE=KILLAGENT
			if [ "$2" != "" -a  "${2//[0-9]/}" == "" ];then
				shift
				AGENTIDX=$1
			elif [ "$2" != "" -a  "${2//[0-9]/}" == "-" ];then
				shift
				AGENTIDX=$1
			elif [ "$2" != "" -a  "${2//[0-9]/}" == "+" ];then
				shift
				AGENTIDX=${1:1}
			elif [[ "X${2#-}" == "X${2}" ]];then
				shift
				AGENTLABEL=$1
			fi
			;;
		--kill-agent=*)
			KILLAGENT=1
			CHOICE=KILLAGENT
			OPT=${1#*=}
			if [ "${OPT//[0-9]/}" == "" ];then
				AGENTIDX=$OPT
			elif [ "${OPT//[0-9]/}" == "-" ];then
				AGENTIDX=$OPT
			elif [ "${OPT//[0-9]/}" == "+" ];then
				AGENTIDX=$OPT
			elif [[ "X${OPT#-}" == "X${OPT}" ]];then
				shift
				AGENTLABEL=$OPT
			fi
			;;
		-l|--long)
			LONG=1
			if((TERSE==0));then 
				[[ "${FSEP}" == ":" ]]&&{ FSEP='|' ; }
			else
				[[ "${FSEP}" == ":" ]]&&{ FSEP=';' ; }
			fi
			;;
		-p|--list-loaded-keys)
			LIST=1
			CHOICE=LIST
			;;
		-P|--list-agent-processes)
			LISAGENTPROCESSES=1
			CHOICE=LISAGENTPROCESSES
			;;
		-s|--set-index)
			SETINDEX=1
			CHOICE=SETINDEX
			shift
			SETAGENTIDX=${1%%:*}
			AGENTLABEL=${1#*:}
			;;
		--set-index=*)
			SETINDEX=1
			CHOICE=SETINDEX
			shift
			SETAGENTIDX=${1%%:*}
			AGENTLABEL=${1#*:}
			;;
		-S|--set-agent)
			SETAGENT=1
			ENVIRONMENT=1
			CHOICE=SETAGENT
			if [ "$2" != "" -a  "${2//[0-9]/}" == "" ];then
				shift
				SETAGENTIDX=$1
			elif [ "$2" != "" -a  "${2//[0-9]/}" == "-" ];then
				shift
				SETAGENTIDX=$1
			elif [ "$2" != "" -a  "${2//[0-9]/}" == "+" ];then
				shift
				SETAGENTIDX=${1:1}
			elif [[ "X${2#-}" == "X${2}" ]];then
				shift
				AGENTLABEL=$1
			fi
			;;
		--set-agent=*)
			SETAGENT=1
			ENVIRONMENT=1
			CHOICE=SETAGENT
			OPT=${1#*=}
			if [ "${OPT//[0-9]/}" == "" ];then
				SETAGENTIDX=$OPT
			elif [[ "X${OPT#-}" == "X${OPT}" ]];then
				shift
				AGENTLABEL=$OPT
			fi
			;;
		-t|--lifetime)
			if [[ "X${2#-}" == "X${2}" ]];then
				LIFETIME=$2
				shift
			fi
			;;
		--lifetime=*)
			LIFETIME=${1#*=}
			;;


		--sort)
			SORT=1
			;;

		--display-env|--de|-de)
			printEnv
			STATE=1
			;;

		-h)
			printHelpShort
			STATE=1
			;;
		-help|--help)
			printHelp
			STATE=1
			;;
		-d|-debug|--debug)
			DEBUG=1
			;;
		-v|-verbose|--verbose)
			VERBOSE=1
			TERSE=0
			;;
		-X|--terse)
			VERBOSE=0
			TERSE=1
			LONG=1
			[[ "${FSEP}" == ":" ]]&&{ FSEP=';' ; }
			;;
		-V|--version)
			CHOICE=VERSION
			;;

		*)
			printHelpShort
			printError
			printError "Unknown option: $1 / $ARGS"
			printError
			STATE=1
    esac
    shift
done

if [ "$ENVIRONMENT" -eq 1 ];then
	case $0 in
		/*/bash);;
		bash);;
		*)cat <<EOF
Requires to be "sourced" in bash:

   '. $0 [OPTIONS]'
or
   '. ${0##*/} [OPTIONS]'

EOF
			STATE=1
			;;
	esac
fi

###
##
#
#####################

set -a P
#
# P[n]=<index>
# P[n+1]=<PID>
# P[n+2]=<usock>
# P[n+3]=<label>
#
function clearSocket () {
	local _a=`{ ls ${1}/agent.* ; } 2>/dev/null`
	local _pl=`{ ls ${1}/[pl].* ; } 2>/dev/null`
	if [[ -e "$1" && "X$_a" == "X" && "X$_pl" != "X"  ]];then
		rm -rf "$1"
	fi
}

function getPIdx4Label () {
	local l=$1
	local i=0
	[[ ${#L[@]} -eq 0 ]]&&{ getAgentLabels ; }
	local lmax=${#L[@]}
	for((i=0;i<lmax;i+=4));do
    	[[ "$l" == "${L[$((i+2))]}" ]]&&{ echo $((i/4)); return 0 ; }
	done
	local pmax=${#P[@]}
	for((i=0;i<pmax;i+=4));do
    	[[ "$l" == "${P[$((i+3))]}" ]]&&{ echo $((i/4)); return 0 ; }
	done
	return 1
}

function getAgentPIDMulti () {
    local sx=0 px=0 cmd='' s=''
    local OFS=$IFS
    IFS="
"
    P=()
    for p in $(ps -ef |awk '/ssh-agent/&&!/awk/{printf("%d\n", $2);}');do
		if [ ! -e "/proc/${p}" ];then
			continue
		fi
		cmd=$(cat /proc/${p}/cmdline)
		if [ "${cmd#ssh-agent}" == "${cmd}" ];then
			continue
		fi
		let sx=p-1;
		s=$(ls /tmp/ssh-*/agent.$sx)
		if [ -z "$s" ];then
			printError "Missing authentication socket for:$sx"
			printInfo "Check ssh-agent by:'-P'"
			STATE=2
		fi
		P[${px}]=$((px/4))
		P[$((px+1))]=$p
		P[$((px+2))]=$s
		P[$((px+3))]=$(getLabel4Pid $p)
		let px+=4;
    done
    IFS=$OFS
    return $px
}

function displayAgentMulti (){
    local px=0 st='' sock=''
    getAgentPIDMulti
    local _PMAX=$?
    getAgentLabels

    for((px=0;px<_PMAX;px+=4));do
    	P[$((px+3))]=`getLabel4Pid ${P[$((px+1))]}`
    done
    ((_PMAX==0))&&echo "#*No agents present"&&return 0
    printIt "#"
    printIt "#Current running SSH Agents:"
    printIt "#"
    if((TERSE==0));then
		printf " %5s  %-10s %-5s %-14s %-s\n" idx label pid st usock
		echo "--------------------------------------------------------------------------------------------"
	else
		printf "%s${FSEP}%s${FSEP}%s${FSEP}%s${FSEP}%s\n" idx label pid st lt usock
	fi
    for((px=0;px<_PMAX;px+=4));do
		sock=${P[$((px+2))]};sock=${sock%/*}
		st=''
		[[ -e "${sock}/st" ]]&&{ st=$(date --date=@`cat ${sock}/st` +%Y%m%d%H%M%S) ; }||st=0
    	if((TERSE==0));then
			if [ "${SSH_AGENT_PID}" != "${P[$((px+1))]}" ];then
				CURAGENTIDX=${CURAGENTIDX:-0}
				printf " %5d: %-10s:%5d:%14d:%s\n" ${P[${px}]} '"'${P[$((px+3))]}'"' ${P[$((px+1))]} $st ${P[$((px+2))]}
			else
				CURAGENTIDX=${P[${px}]}
				printf "*%5d: %-10s:%5d:%14d:%s\n" ${P[${px}]} '"'${P[$((px+3))]}'"' ${P[$((px+1))]} $st ${P[$((px+2))]}
			fi
		else
			if [ "${SSH_AGENT_PID}" != "${P[$((px+1))]}" ];then
				CURAGENTIDX=${CURAGENTIDX:-0}
			else
				CURAGENTIDX=${P[${px}]}
			fi
			printf "%d${FSEP}%s${FSEP}%d${FSEP}%s${FSEP}%s\n" ${P[${px}]} '"'${P[$((px+3))]}'"' ${P[$((px+1))]} $st ${P[$((px+2))]}
		fi
    done
    printIt
    return $((_PMAX/4))
}



set -a A
#
# A[n]=<index>
# A[n+1]=<search-path>
# A[n+2]=<rel=path>
# A[n+3]=<file=type>
#
function getAvailableKeys () {
    printItOptional "#"
    printItOptional "#Current available keys:"
    printItOptional "#SSH_ADDONS_DIRS=${SSH_ADDONS_DIRS}"
    local C=0 t='' ft=''
    OFS=$IFS
    IFS=" "
    for i in ${SSH_ADDONS_DIRS//:/ };do
		printItOptional "#"
		i=$(bootstrapGetRealPathname $i)
		printItOptional "#$i/"
		OFS=$IFS
		IFS="
"
		if [ ! -d "$i" ];then
			continue
		fi
		export SORT
		for f in $( ((SORT==0))&&{ find $i -type f  ; }||{ find $i -type f  | sort ; } ; );
        do
			t=`$MYPATH/ssh-pk-type.sh $f 2>/dev/null`
			if [[ $? != 0 ]];then
				continue
			fi
        	ft="${f##*:}"
        	case $ENUMTYPE in
        		2);;
        		1)[[ "X${t%pub}" == "X${t}" ]]&&{ continue ; };;
				*)[[ "X${t%pub}" != "X${t}" ]]&&{ continue ; };;
        	esac

			A[$C]=$((C/4))
			f=${f%%:*}
			F=${f#$i};F=${F##*/}
			A[$((C+1))]="${F#/}"
			A[$((C+2))]="$i"
            A[$((C+3))]="${f##*:}"
            A[$((C+4))]="${ft}"
			let C=C+4;
		done
		IFS=$OFS
    done
    return $C
}

function listAvailableKeys () {
	local _k="$1"
    getAvailableKeys
    local _CMAX=$?
    C=0;
    LPATH=""
    printIt
    printIt
    printIt "Available keys:"
    printIt "==============="
    local nmax=0
    for((n=0;n<_CMAX;n+=4));do
		nx=${#A[$((n+1))]}
		if((nmax<nx));then
			nmax=$nx
		fi
    done
    local pmax=0
    for((n=0;n<_CMAX;n+=4));do
		nx=${#A[$((n+3))]}
		if((pmax<nx));then
			pmax=$nx
		fi
    done

	if((TERSE!=0));then
		printf "%s${FSEP}%s${FSEP}%s${FSEP}%s${FSEP}%s\n" idx name path filepath type
	fi

    for((n=0;n<_CMAX;n+=4));do
		if [ "$LPATH" != "${A[$((n+2))]}" ];then
			LPATH="${A[$((n+2))]}"
			printIt
			printIt "#*************"
			printIt "#***In: $LPATH"
			printIt "#"
		fi
		if [[ "X$_k" == "X" ]];then
			if((TERSE==0));then
				if((LONG==0));then
					printf "%3d${FSEP} %-"${nmax}"s${FSEP}%-"${pmax}"s${FSEP}%s\n" ${A[${n}]} ${A[$((n+1))]} "${A[$((n+3))]}" `${MYPATH}/ssh-pk-type.sh "${A[$((n+3))]}"`
				else
					local l=0 lmax=0
					for((l=0;l<_CMAX;l+=4));do
						nx=${#A[$((l+2))]}
						if((lmax<nx));then
							lmax=$nx
						fi
					done
					printf "%3d${FSEP} %-"${nmax}"s${FSEP}%-"${lmax}"s${FSEP}%-"${pmax}"s${FSEP}%s\n" ${A[${n}]} ${A[$((n+1))]} "${A[$((n+2))]}" "${A[$((n+3))]}" `${MYPATH}/ssh-pk-type.sh "${A[$((n+3))]}"`
				fi
			else
		 		printf "%d${FSEP}%s${FSEP}%s${FSEP}%s${FSEP}%s\n" ${A[${n}]} ${A[$((n+1))]} ${A[$((n+2))]} "${A[$((n+3))]}" "${A[$((n+4))]}"
			fi
		else
			dx="${A[$((n+1))]}/${A[$((n+2))]}"
			if [[ "X${dx//$_k/}" == "X${dx}" ]];then
				continue
			fi
			d0="${A[$((n+2-4))]}"
			d1="${A[$((n+2))]}"
			if [ \( "${d0%%/*}" != "${d0}" -o  "${d1%%/*}" != "${d1}" \) -a  "${d0%%/*}" != "${d1%%/*}" ];then
				printIt
			fi
			if((TERSE==0));then
				printf "%3d: %-"${nmax}"s:%s:%s:%s\n" ${A[${n}]} ${A[$((n+2))]} "${A[$((n+3))]}" "${A[$((n+3))]}" "${A[$((n+4))]}"
			else
				printf "%d${FSEP}%s${FSEP}%s${FSEP}%s${FSEP}%s\n" ${A[${n}]} "${LPATH}/${A[$((n+1))]}" "${LPATH}/${A[$((n+2))]}" "${A[$((n+3))]## }" "${A[$((n+4))]## }"
			fi
		fi
    done
    return $((_CMAX/4))
}

function searchAvailableKey () {
	local k=$1
    getAvailableKeys
    local _CMAX=$?
    local C=0;
    local LPATH=""
    local nmax=0
    for((n=0;n<_CMAX;n+=4));do
		local px=${A[$((n+1))]}/${A[$((n+2))]}

	    if [[ "X${px//$k/}" != "X$px" ]];then
			echo  "$px"
			printDebug "MATCH([$n]$k):$px"
		fi
		nx=${#A[$((n+2))]}
		if((nmax<nx));then
			nmax=$nx
		fi
    done
    return $((_CMAX/4))
}

set -a L
#
# L[n]=<index>
# L[n+1]=<label>
# L[n+2]=<pid>
# L[n+3]=<search-path>
#
function getAgentLabels () {
	# socket-path could be changed by '-a', so 'all' is risky

    printItOptional "#"
    printItOptional "#Current defined labels:"

    local C=0
    OFS=$IFS
    IFS=" "
    local pidx=0
    local pmax=${#P[@]}
    for((pidx=0;pidx<pmax;pidx+=4));do
		printItOptional "#"
		_pl=${P[$((pidx+2))]};_pl=${_pl%/*}
		_p="`{ ls ${_pl}/p.* ; } 2>/dev/null`"
		_l="`{ ls ${_pl}/l.* ; } 2>/dev/null`"

		if [[ "X$_p" == "X" ]];then
			continue
		fi
		if [[ "X$_l" == "X" ]];then
			_l=$_p
		fi
		_pid=${_p##*/p.}
		_lbl=${_l##*/l.}
		L[$pidx]=$((pidx/4))
		L[$((pidx+1))]=$_pid
		L[$((pidx+2))]=$_lbl
		L[$((pidx+3))]=$_pl
		let C=C+4;
    done
    return $((C/4))
}

function getLabels () {
	local _k="$1"
	getAgentPIDMulti
    getAgentLabels
    return $?
 }

function enumerateActiveLabels () {
	getLabels
    local _CMAX=$?
    C=0;
    LPATH=""
    printIt
    printIt
    printIt "Assigned Active Labels:"
    printIt "======================="
    printIt
	smax=5
    for((n=0;n<_CMAX;n+=4));do
		nx=${#L[$((n+2))]}
		if((smax<nx));then
			smax=$nx
		fi
    done
    nmax=${_CMAX}
    if((TERSE==0));then
		printf "%3s: %-"${smax}"s:%-5s:%s\n" idx pid label path
		echo "---------------------------------------------------"
	else
		printf "%s${FSEP}%s${FSEP}%s${FSEP}%s\n" idx pid label path
	fi
    for((n=0;n<nmax;n+=4));do
    	if((TERSE==0));then
			printf "%3d: %-"${smax}"s:%5s:%s\n" ${L[${n}]} ${L[$((n+1))]} ${L[$((n+2))]} "${L[$((n+3))]}"
		else
			printf "%d${FSEP}%s${FSEP}%s${FSEP}%s\n" ${L[${n}]} ${L[$((n+1))]} ${L[$((n+2))]} "${L[$((n+3))]}"
		fi
    done
    printIt
    return $((_CMAX/4))
}

function getLabel4Pid () {
	local _pid=$1
   	local _CMAX=${#L[@]};
   	for((i=0;i<_CMAX;i+=4));do
		if [[ "${L[$((i+1))]}" == "$_pid" ]];then
			echo "${L[$((i+2))]}"
			return 0
		fi
	done
	echo $_pid
	return 1
}

function getPid4Label () {
	local _lbl=$1
	if [[ "${L[@]}" == "X" ]];then
		getLabels
    	local _CMAX=$?
	else
      	local _CMAX=${#L[@]};_CMAX=$((_CMAX/4))
	fi
	for((i=0;i<_CMAX;i+=4));do
		if [[ "${L[$((i+1))]}" == "$_lbl" ]];then
			echo "${L[$((i+2))]}"
			return 0
		fi
	done
	echo $_lbl
	return 1
}

set -a B
#
# B[n]=<index>
# B[n+1]=<file-pathname>
# B[n+2]=<type>
# B[n+3]=<finger-print>
# B[n+4]=<#bsize>
#
function getBIdx4Key () {
	local l=$1 lx=''
	local i=0
	[[ ${#B[@]} -eq 0 ]]&&{ getLoadedKeys ; }
	local bmax=${#B[@]}
	for((i=0;i<bmax;i+=5));do
		lx="${B[$((i+1))]##*/}"
    	[[ "$l" == "$lx" || "$l" == "${lx%.*}" ]]&&{ echo $((i/5)); return 0 ; }
	done
	if [[ "X${l//[0-9]/}" == "X" ]];then
		((X>=0&&X<bmax/5))&&{ echo $l; }
	fi
	return 1
}

function getBKey4Idx () {
	local l=$1 lx=''
	local i=0

	if [[ "X${l}" == "X" || "X${l//[0-9]/}" != "X" ]];then
		printError "Requires a numeric index:$l"
		return 1
	fi
	[[ ${#B[@]} -eq 0 ]]&&{ getLoadedKeys ; }
	local bmax=${#B[@]}
	((l<0&&l>=bmax))&&{
		printError "Out of range:$l"
		return 1
	}
	echo ${B[$((5*l+1))]}
}


function getLoadedKeys () {
    printItOptional "#"
    printItOptional "#Current Loaded keys:"
    local C=0 f='' F='' t=''
    OFS=$IFS
    IFS="
"
    for f in $(ssh-add -l);
    do
		[[ "${f#[0-9]}" == "$f" ]]&&{ continue ; }
		B[$C]=$((C/5))
		B[$((C+4))]=${f%% *}
		F=${f#* }
		B[$((C+3))]=${F%% *}
        t=${f##* }
		B[$((C+2))]=${t//[()]/}
		F=${f% *}
		B[$((C+1))]=${F##* }
		let C=C+5;
    done
    IFS=$OFS
    return $C
}

function listLoadedKeys () {
    local px=0 st='' lt='' sock='' _gap=-1 cur=0 curx=0 kn=''
    local _SSH_AGENT_PID=${SSH_AGENT_PID}
    local _SSH_AUTH_SOCK=${SSH_AUTH_SOCK}

    printIt
    printIt "Loaded keys:"
    printIt "============"
    printIt
    getAgentPIDMulti
    [[ "X${#L[@]}" == "X0" ]]&&getAgentLabels
    local PMAX=$?
	if((TERSE!=0));then
		printf "%s${FSEP}%s${FSEP}%s${FSEP}%s${FSEP}%s${FSEP}%s${FSEP}%s${FSEP}%s${FSEP}%s${FSEP}%s\n" idx pid usock kidx kpath ktype fingerp bsize startdatetime lifedatetime
    fi
    for((curx=0;curx<=PMAX;curx+=4));do
		if((PMAX==curx&&_gap==-1));then
			break
		elif((PMAX==curx));then
		    SSH_AGENT_PID=${_SSH_AGENT_PID}
		    SSH_AUTH_SOCK=${_SSH_AUTH_SOCK}
		    cur=$_gap
			getLoadedKeys
		elif [[ "X$_SSH_AUTHx_SOCK" == "X${P[$((curx+2))]}" ]];then
			_gap=-$curx
			continue
		else
		    cur=$curx
			SSH_AGENT_PID=${P[$((cur+1))]}
			SSH_AUTH_SOCK=${P[$((cur+2))]}
			getLoadedKeys
		fi
		local LMAX=$?
		local C=0;
		local LPATH=""
		local nmax=0
		for((n=0;n<LMAX;n+=5));do
			nx=${#B[$((n+1))]}
			if((nmax<nx));then
				nmax=$nx
			fi
		done
		sock=${SSH_AUTH_SOCK%/*}
		[[ -e "${sock}/st" ]]&&{ st=$(date --date=@`cat ${sock}/st` +%Y%m%d%H%M%S) ; }||st=0
		if((TERSE==0));then
			if [ "${_SSH_AGENT_PID}" != "${SSH_AGENT_PID}" ];then
				printf "  agent(%d)${FSEP} %s${FSEP}%s${FSEP}%s${FSEP}%s\n" ${P[${cur}]} `getLabel4Pid ${P[$((cur+1))]}` ${P[$((cur+1))]} $st ${P[$((cur+2))]}
			else
				printf " *agent(%d): %s${FSEP}%s${FSEP}%s${FSEP}%s\n" ${P[${cur}]} `getLabel4Pid ${P[$((cur+1))]}` ${P[$((cur+1))]} $st ${P[$((cur+2))]}
			fi
			if((LMAX==0));then
				printf "    %3s\n\n" "-"
				continue
			fi
		fi
		for((n=0;n<LMAX;n+=5));do # keys for agent 'curx'
			local tst=''
			local lst=''
			kn=${B[$((n+1))]##*/}
			[[ -e "${sock}/keys/$kn/st" ]]&&{ tst=$(cat ${sock}/keys/$kn/st);st=$(date --date=@${tst} +%Y%m%d%H%M%S) ; }||st=0
			[[ -e "${sock}/keys/$kn/lt" ]]&&{ tlt=$((tst+`cat ${sock}/keys/$kn/lt`));lt=$(date --date=@${tlt} +%Y%m%d%H%M%S) ; }||lt=0
			if((TERSE==0));then
				if((LONG==0));then
					printf "    %3d: %-"${nmax}"s${FSEP}%s${FSEP}%s${FSEP}%s\n" ${B[${n}]} ${B[$((n+1))]} ${B[$((n+2))]//[()]/} $st $lt
				else
					printf "    %3d: %-"${nmax}"s${FSEP}%s${FSEP}%s${FSEP}%s${FSEP}%s${FSEP}%s${FSEP}%s\n" ${B[${n}]} ${B[$((n+1))]} ${B[$((n+2))]//[()]/} ${B[$((n+3))]}  ${B[$((n+4))]} $st $lt
				fi
			else
				printf "%s${FSEP}%s${FSEP}%s${FSEP}%s${FSEP}%s${FSEP}%s${FSEP}%s${FSEP}%s${FSEP}%s${FSEP}%s\n" "${P[${cur}]}" "${P[$((cur+1))]}" "${P[$((cur+2))]}" "${B[${n}]}" "${B[$((n+1))]}" "${B[$((n+2))]//[()]/}" "${B[$((n+3))]}" "${B[$((n+4))]}"  $st $lt
			fi
		done
		printIt
    done
    SSH_AGENT_PID=${_SSH_AGENT_PID}
    SSH_AUTH_SOCK=${_SSH_AUTH_SOCK}
}

function doit () {
	local PMAX=0
	if [ $STATE -eq 0 ];then
		case $CHOICE in
			ADDKEY)
				if [ -z "$SSH_AGENT_PID" ];then
					printError "Missing SSH_AGENT_PID"
					printInfo "Attach current shell to an ssh-agent first:'-A', '-S'"
					STATE=1
					return 1
				fi
				if [ -z "$SSH_AUTH_SOCK" ];then
					printError "Missing SSH_AUTH_SOCK"
					STATE=1
					return 1
				fi

	 			local sock=${SSH_AUTH_SOCK%/agent.*} #directory of udomain socket
				[[ ! -e "$sock/keys" ]]&&{ mkdir "$sock/keys"; }
				local ut=`date +%s`

				if [[ "X${KEYNAME}" != "X" ]];then
					local _k=`searchAvailableKey ${KEYNAME}`
					if [[ "X$_k" == "X" ]];then
						printError "No key found: $KEYNAME"
						return 1
					fi
                    local ki=''
                    local IFSO=$IFS
                    local IFS='
'
                    for ki in $_k;do
						if [[ "X${ki}" != "X" ]];then
							local _f=`cat ${ki}`
							if [[ "X${_f#ssh-}" != "X${_f}" ]];then
								printWarning "Ignored, seems to be a public key: $ki"
							else
								ssh-add ${LIFETIME:+-t $LIFETIME} ${ki}
								[[ ! -e "$sock/keys/${KEYNAME}" ]]&&{ mkdir "$sock/keys/${KEYNAME}"; }
								echo $ut > $sock/keys/${KEYNAME}/st;
								[[ "X$LIFETIME" != "X" ]]&&{
									echo $LIFETIME > "$sock/keys/${KEYNAME}/lt" ;
								}
							fi
						else
							printError "Invalid keyname: $KEYNAME"
						fi
					done
				else
					listLoadedKeys
					listAvailableKeys
					CMAX=$?
					if((CMAX==0));then
						echo "No keys available"
					else
						X=0
						read -p "Select number($X):" X
						[[ -z "$X" ]]&&X=0
						if((X<CMAX));then
							KEYNAME="${A[$((4*X+1))]}/${A[$((4*X+2))]}"
							ssh-add ${LIFETIME:+ -t $LIFETIME} "${KEYNAME}"
							mkdir "$sock/keys/${KEYNAME}"
							echo $ut > $sock/keys/${KEYNAME}/st;
							[[ "X$LIFETIME" != "X" ]]&&{
								echo $LIFETIME > "$sock/keys/${KEYNAME}/lt" ;
							}
						else
							printError "Invalid value: $X>$CMAX"
						fi
					fi
				fi
				unset ADDKEY CMAX X
				;;
			ADDAGENT)
				printIt ""
				printIt "Create a new ssh-agent, requires '-S' for attachment."
				printIt ""
				local s=`ssh-agent`
				local ut=`date +%s`
				local pid=${s#*SSH_AGENT_PID=};pid=${pid%%;*};
		 		local sock=${s#*SSH_AUTH_SOCK=};sock=${sock%%;*};sock=${sock%/agent.*} #directory of udomain socket
				echo "${AGENTLABEL:-$pid}" > "$sock/p.$pid" # pid file: p.<pid>
				echo "$pid" > "$sock/l.${AGENTLABEL:-$pid}" # label file: l.<label>
				echo $ut > $sock/st
				mkdir $sock/keys

				unset ADDAGENT
				;;
			CLEARMAP)
				printIt
				printIt "#"
				printIt "#Clear mapping of labels:"
				printIt
				OFS=$IFS
				IFS='
'
				for _p in `{ ls -d /tmp/ssh-* ; } 2>/dev/null`;do
					_a=`{ ls ${_p}/agent.* ; } 2>/dev/null`
					_pl=`{ ls ${_p}/[pl].* ; } 2>/dev/null`
					if [[ -e "$_p" && "X$_a" == "X" && "X$_pl" != "X"  ]];then
						rm -rf "$_p"
					fi
				done
				unset CLEARMAP OFS _p _a _pl
				;;
			CLEARAGENT)
				printIt
				printIt "#"
				printIt "#Clear assignement of:"
				printIt "  SSH_AGENT_PID=${SSH_AGENT_PID}"
				printIt "  SSH_AUTH_SOCK=${SSH_AUTH_SOCK}"
				printIt
				SSH_AGENT_PID=;
				SSH_AUTH_SOCK=;
				unset CLEARAGENT
				;;
			DELETE)
				if [ -z "$SSH_AGENT_PID" ];then
					printError "Missing SSH_AGENT_PID"
					printInfo "Check ssh-agent by:'-P'"
					STATE=1
					return 1
				fi
				if [ -z "$SSH_AUTH_SOCK" ];then
					printError "Missing SSH_AUTH_SOCK"
					printInfo "Check ssh-agent by:'-P'"
					STATE=1
					return 1
				fi
				X=$KEYNAME
				[[ ${#B[@]} -eq 0 ]]&&{ getLoadedKeys ; }
				if [[ "X$X" == "X" ]];then
					listLoadedKeys
					read -p "Select index for active:" X
				elif [[ "X${X//[0=9]/}" == "X" ]];then
					X=`getBKey4Idx $X`
				else
					X=`getBIdx4Key $X`
				fi
				local X1=`getBIdx4Key $X`
				[[ -z "$X1" ]]&&X1=-1
				if((X1>=0&&X1<${#B[@]}));then

					if((FORCE==0));then
						echo "Selected: key[$X] = `getBKey4Idx $X`"
						Y=N
						read -p "Continue[yN]:" Y
						if [ "$Y" == y -o "$Y" == Y  ];then
							FORCE=1
						fi
					fi
					if((FORCE==1));then
						ssh-add -d ${B[$((5*X1+1))]}
					fi
				else
					printError "No key in range:$X"
				fi
				unset DELETE
				;;
			ENUMKEYS)
				listAvailableKeys "${KEYNAME}"
				unset ENUMKEYS
				;;
			KILLAGENT)
				[[ ${#L[@]} -eq 0 ]]&&{ getAgentPIDMulti;getAgentLabels ; }
				if [ "X$AGENTIDX" != 'X' ];then
					getAgentPIDMulti
					local PMAX=$?
					local X=$AGENTIDX
				elif [ "X$AGENTLABEL" != 'X' ];then
					getAgentPIDMulti
					local PMAX=$?
					local X=`getPIdx4Label $AGENTLABEL`
				else
					displayAgentMulti
					local PMAX=$?
					local X=-1
					read -p "Select number to be stopped($X):" X
					[[ -z "$X" ]]&&X=-1
				fi
				if [[ "X$X" == "X" ]];then
					printError "Missing value, check with '-P'"
				elif((X<0||X>=PMAX/4));then
					printError "Invalid value:$X>$((PMAX/4-1))"
				else
					if((FORCE==0));then
						echo "Selected: agent[$X] = ${L[$((X+2))]}:${L[$((X+3))]}"
						Y=N
						read -p "Continue[yN]:" Y
						if [ "$Y" == y -o "$Y" == Y  ];then
							FORCE=1
						fi
					fi
					if((FORCE!=0));then
						if((TERSE==0));then
							printIt "SSH_AGENT_PID=${P[$((4*X+1))]}"
							printIt "SSH_AUTH_SOCK=${P[$((4*X+2))]}"
						else
							echo "SSH_AGENT_PID${FSEP}SSH_AUTH_SOCK"
							echo "${P[$((4*X+1))]}${FSEP}${P[$((4*X+2))]}"

						fi
						kill ${P[$((4*X+1))]}
						clearSocket ${P[$((4*X+2))]%/*}
						if [ "$SSH_AGENT_PID" == "${P[$((3*X+1))]}" ];then
							unset SSH_AGENT_PID
							unset SSH_AUTH_SOCK
						fi
					fi
				fi
				unset KILLAGENT AGENTIDX AGENTIDX X
				;;
			LIST)
				if [ -z "$SSH_AGENT_PID" ];then
					printError "Missing SSH_AGENT_PID"
					printInfo "Check ssh-agent by:'-P'"
					STATE=1
					return 1
				fi
				if [ -z "$SSH_AUTH_SOCK" ];then
					printError "Missing SSH_AUTH_SOCK"
					printInfo "Check ssh-agent by:'-P'"
					STATE=1
					return 1
				fi

				listLoadedKeys "${KEYNAME}"
				unset LIST
				;;
			LISAGENTPROCESSES)
				displayAgentMulti
				if [[ $? > 0 ]];then
					printIt
					printIt "#"
					printIt "#Current assigned agent:"
					printIt "  SSH_AGENT_PID=${SSH_AGENT_PID}"
					printIt "  SSH_AUTH_SOCK=${SSH_AUTH_SOCK}"
					printIt
				fi
				unset LISAGENTPROCESSES
				;;
			LISTLABELS)
				enumerateActiveLabels "${KEYNAME}"
				unset LISTLABELS
				;;
			SETINDEX)
				if [ "X$SETAGENTIDX" == 'X' ];then
					printWarning "Missing index for label: $AGENTLABEL"
				else
					getAgentPIDMulti
				fi
				PMAX=$?
				if((PMAX==0));then
					echo "#*Start agents with '-A'"
				else
					if((SETAGENTIDX>=PMAX||SETAGENTIDX<0));then
						printError "Index out of range:$X > $((PMAX/4-1))"
					fi
					PKEY=${P[$((4*SETAGENTIDX+2))]}
					PKEY=${PKEY%/*}
					echo "$AGENTLABEL" > "$PKEY/p.${P[$((4*SETAGENTIDX+1))]}" # pid file: p.<pid>
					echo "${P[$((4*SETAGENTIDX+1))]}" > "$PKEY/l.$AGENTLABEL" # label file: l.<label>
				fi
				unset SETAGENT
				;;


			SETAGENT)
				if [ "X$SETAGENTIDX" == 'X' ];then
					displayAgentMulti
				else
					getAgentPIDMulti
				fi
				PMAX=$?
				if((PMAX==0));then
					echo "#*Start agents with '-A'"
				else
					if [ "X$SETAGENTIDX" != "X" ];then
						X=$SETAGENTIDX
					elif [ "X$AGENTLABEL" != "X" ];then
						X=`getPIdx4Label $AGENTLABEL`
					else
						X=$CURAGENTIDX
						read -p "Select number to be activated($X):" X
					fi
					if((X>=PMAX));then
						printWarning "Index($X > $((PMAX/4-1))) set to: $((PMAX/4-1))"
						X=$((PMAX/4-1))
					elif((X<0));then
						printWarning "Index($X < 0) set to: 0"
						X=0
					fi
					[[ -z "$X" ]]&&X=$CURAGENTIDX
					if((X<PMAX));then
						SSH_AGENT_PID=${P[$((4*X+1))]}
						SSH_AUTH_SOCK=${P[$((4*X+2))]}
						if [ "X$SETAGENTIDX" != "X" ];then
							displayAgentMulti
						fi
						printIt "setting:SSH_AGENT_PID=${SSH_AGENT_PID}"
						printIt "setting:SSH_AUTH_SOCK=${SSH_AUTH_SOCK}"
					else
						printError "Invalid value: $X>$PMAX"
					fi
				fi
				unset SETAGENT
				;;
			VERSION)
				if((VERBOSE==1));then
					printIt ""
					printIt "AUTHOR    = ${AUTHOR}"
					printIt "WWW       = ${WWW}"
					printIt "VERSION   = ${VERSION}"
					printIt "DATE      = ${DATE}"
					printIt "UUID      = ${UUID}"
					printIt "LICENSE   = ${LICENSE}"
					printIt "COPYRIGHT = ${COPYRIGHT}"
					printIt ""
				elif((TERSE!=0));then
					echo "AUTHOR${FSEP}WWW${FSEP}VERSION${FSEP}DATE${FSEP}UUID${FSEP}LICENSE${FSEP}COPYRIGHT"
					echo "${AUTHOR}${FSEP}${WWW}${FSEP}${VERSION}${FSEP}${DATE}${FSEP}${UUID}${FSEP}${LICENSE}${FSEP}${COPYRIGHT}"
				else
					echo -n "${VERSION}"
                fi
				;;
			*);;
		esac
	fi
}
doit

# clear temporary vars
unset A B L P X PMAX AUTHOR LICENSE COPYRIGHT VERSION DATE WWW UUID STATE ENVIRONMENT VERBOSE DEBUG VERS LIST ENUMKEYS
unset SORT DELETE SETAGENT SETAGENTIDX ADDKEY KEYNAME ADDAGENT AGENTLABEL AGENTIDX LISAGENTPROCESSES EXIT CHOICE ARGS OFS LIFETIME
