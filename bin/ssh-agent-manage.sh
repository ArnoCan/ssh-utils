#!/usr/bin/bash
#
AUTHOR="Arno-Can Uestuensoez"
LICENSE="Artistic-License-2.0 + Forced-Fairplay-Constraints"
COPYRIGHT="Copyright (C) 2011,2012,2013,2017 Arno-Can Uestuensoez @Ingenieurbuero Arno-Can Uestuensoez"
VERSION='0.1.2'
WWW='https://arnocan.wordpress.com'
UUID='a8ecde1c-63a9-44b9-8ff0-6c7c54398565'
#

STATE=0
SSH_AGENT_PID=${SSH_AGENT_PID:-""}
SSH_AUTH_SOCK=${SSH_AUTH_SOCK:-""}
ENVIRONMENT=0
VERBOSE=0
LIST=0
LISTALL=0
DELETE=0
SETAGENT=0
SETAGENTIDX=-1
ADDKEY=0
ADDAGENT=0
LISAGENTPROCESSES=0
EXIT=0
if [ -z "${SSH_ADDONS_DIRS}" ];then
    SSH_ADDONS_DIRS=~/.ssh
    SSH_ADDONS_DIRS=${SSH_ADDONS_DIRS}:~/data/.ssh
    SSH_ADDONS_DIRS=${SSH_ADDONS_DIRS}:/media/truecrypt1
fi
MYPATH=${BASH_SOURCE%/*}
. "${MYPATH}/bootstrap/bootstrap-03_01_009.sh"
#. ~/bin/bootstrap/bootstrap-03_01_009.sh

function printIt () {
    echo "$*"
}
function printItOptional () {
    if((VERBOSE==1));then
		echo "$*"
    fi
}
function printEnv () {
    _PATH=${PATH//:/
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
     SSH_ADDONS_DIRS      = ${SSH_ADDONS_DIRS}

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

  ${0##*/} [OPTIONS]

DESCRIPTION:

  Enumerate SSH keys and SSH agents, manages and 
  assigns to current shell/bash.
 
  To be "sourced" for setting environment variables 
  by '-e' in bash:

     '. set_ssh-agent.sh [OPTIONS]'

  else could be executed

     'set_ssh-agent.sh [batch] [OPTIONS]'

OPTIONS:

  REMARK: label/UUID are to be implemented

  -a [<label>] | --add-key[=<label>]
     Interactive add a key from a displayed list.
     Sets/reads:    
        SSH_ADDONS_DIRS

  -A [<label>] | --add-agent[=<label>]
     Creates a new agent.

  -C [<label>] | --clear-agent[=<label>]
     Cleares the assignment.

  -d | --delete
     Delete loaded key

  -K [<label>] | --kill-agent[=<label>]
     Kils agent, sets environment if active connection

  -l | --list | --list-loaded-keys
     Lists loaded keys of current agent.

  -L | --listall | --listall-available-keys
     Lists loaded and available keys based on SSH_ADDONS_DIRS.

       SSH_ADDONS_DIRS=${SSH_ADDONS_DIRS}

  -P | --list-agent-processes
     Lists running agents

  -S [#index|<label>] | --set-agent[=#index|<label>]
     Interactive set agent, if only one this is the default.
     Sets:
       SSH_AGENT_PID
       SSH_AUTH_SOCK

  --display-env | --de
     Displays environment.

  -h
     Short help.

  -help | --help
     Detailed help.

  -v | --verbose
     Verbose.

ENVIRONMENT:

  SSH_AGENT_PID
    See SSH.

  SSH_AUTH_SOCK
    See SSH.

  SSH_ADDONS_DIRS
    Defines search path for stored ID files in PATH syntax.
    See also option '-L'.

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

EXAMPLES:

  ssh-agent-manage.sh -l    # list keys of current agent
  ssh-agent-manage.sh -L    # enumerate all stored keys

  ssh-agent-manage.sh -A    # create an agent
  ssh-agent-manage.sh -K    # kill an agent
  ssh-agent-manage.sh -P    # list running agents

  ssh-agent-manage.sh --de  # show environment

  . ssh-agent-manage.sh -S  # select and set an agent 
  . ssh-agent-manage.sh -C  # clear current shell

  ssh-agent-manage.sh -h    # help



COPYRIGHT:

  $COPYRIGHT

LICENSE:

  $LICENSE


EOF
}

function printHelpShort () {
    cat <<EOF

  ${0##*/} [OPTIONS]

  -a [<label>] | --add-key[=<label>]
  -A [<label>] | --add-agent[=<label>]
  -C [<label>] | --clear-agent[=<label>]
  -d | --delete
  -K [<label>] | --kill-agent[=<label>]
  -l | --list | --list-loaded-keys
  -L | --listall | --listall-available-keys
  -P | --list-agent-processes
  -S [#index|<label>] | --set-agent[=#index|<label>]
  --display-env | --de

  -v | --verbose

  -h (short)
  -help | --help (detailed)

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
for a in $1;do
    case $a in
		"-a"|"--add-key")
			CHOICE=ADDKEY
			ADDKEY=1
			;;
		"-A"|"--add-agent")
			ADDAGENT=1
			CHOICE=ADDAGENT
			;;
		"-C"|"--clear-agent")
			CLEARAGENT=1
			ENVIRONMENT=1
			CHOICE=CLEARAGENT
			;;
		"-d"|"--delete")
			DELETE=1
			CHOICE=DELETE
			;;
		"-K"|"--kill-agent")
			KILLAGENT=1
			CHOICE=KILLAGENT
			;;
		"-l"|"--list"|"--list-loaded-keys")
			LIST=1
			CHOICE=LIST
			;;
		"-L"|"--list-all"|"--listall=available-keys")
			LISTALL=1
			CHOICE=LISTALL
			;;
		"-P"|"--list-agent-processes")
			LISAGENTPROCESSES=1
			CHOICE=LISAGENTPROCESSES
			;;
		"-S")
			SETAGENT=1
			ENVIRONMENT=1
			CHOICE=SETAGENT
			if [ "$2" != "" -a  "${2//[0-9]/}" == "" ];then
				shift
				SETAGENTIDX=$1
			fi
			;;
		"--set-agent"|"--set-agent="*)
			SETAGENT=1
			ENVIRONMENT=1
			CHOICE=SETAGENT
			OPT=${1#*=}
			if [ "${OPT//[0-9]/}" == "" ];then
				SETAGENTIDX=$OPT
			fi
			;;


		"--display-env"|"--de")
			printEnv
			STATE=1
			;;
		"-h")
			printHelpShort
			STATE=1
			;;
		"-help"|"--help")
			printHelp
			STATE=1
			;;
		"-v"|"--verbose")
			VERBOSE=1
			;;

		*)
			printHelp
			STATE=1
    esac
    shift
done


if [ "${0#/*/bash}" == "${0}" -a "$ENVIRONMENT" -eq 1 ];then
    cat <<EOF
Requires to be "sourced" in bash:

   '. $0 [OPTIONS]'
or
   '. ${0##*/} [OPTIONS]'

EOF
    STATE=1
fi


###
##
#
#####################

set -a P
function getAgentPIDMulti () {
    local sx=0
    local px=0
    OFS=$IFS
    IFS="
"

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
			echo ${LINENO}:"ERROR:Missing authentication socket">&2
			STATE=2
		fi
		P[${px}]=$((px/3))
		P[$((px+1))]=$p
		P[$((px+2))]=$s
		let px+=3;
    done
    IFS=$OFS
    return $px
}


function displayAgentMulti (){
    printIt "#"
    printIt "#Current running SSH Agents:"
    getAgentPIDMulti
    local _PMAX=$?
    local px=0
    ((_PMAX==0))&&echo "#*No agents present"&&return 0
    for((px=0;px<_PMAX;px+=3));do
		if [ "${SSH_AGENT_PID}" != "${P[$((px+1))]}" ];then
			printf "  %5d: %5d:%s\n" ${P[${px}]} ${P[$((px+1))]} ${P[$((px+2))]}
		else
			printf " *%5d: %5d:%s\n" ${P[${px}]} ${P[$((px+1))]} ${P[$((px+2))]}
		fi

    done
    return $((_PMAX/3))
}



set -a A
function getAvailableKeys () {
    printItOptional "#"
    printItOptional "#Current available keys:"
    printItOptional "#SSH_ADDONS_DIRS=${SSH_ADDONS_DIRS}"
    local C=0
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
		for f in $(find $i -exec file {} \; |awk -F':' '/key$/{printf("%s:%s\n",$1,$2);}'|sort); 
        do
			A[$C]=$((C/4))
			A[$((C+1))]="$i"
			F=${f%%:*}
			F=${F#$i}
			A[$((C+2))]="${F#/}"
            A[$((C+3))]="${f##*:}"
			let C=C+4;
		done
		IFS=$OFS
    done
    return $C
}

function listAvailableKeys () {
    getAvailableKeys
    local _CMAX=$?
    C=0;
    LPATH=""
    echo 
    echo 
    echo "Available keys:"
    echo "==============="
    nmax=0
    for((n=0;n<_CMAX;n+=4));do
		nx=${#A[$((n+2))]}
		if((nmax<nx));then
			nmax=$nx
		fi
    done

    for((n=0;n<_CMAX;n+=4));do
		if [ "$LPATH" != "${A[$((n+1))]}" ];then
			LPATH="${A[$((n+1))]}"
			echo
			echo "#*************"
			echo "#***In:$LPATH"
			echo "#"
		fi
		d0="${A[$((n+2-4))]}"
		d1="${A[$((n+2))]}"
		if [ \( "${d0%%/*}" != "${d0}" -o  "${d1%%/*}" != "${d1}" \) -a  "${d0%%/*}" != "${d1%%/*}" ];then
			echo
		fi
		printf "%3d: %-"${nmax}"s:%s\n" ${A[${n}]} ${A[$((n+2))]} "${A[$((n+3))]}"
    done
    return $((_CMAX/4))
}

set -a B
function getLoadedKeys () {
    printItOptional "#"
    printItOptional "#Current Loaded keys:"
    local C=0
    OFS=$IFS
    IFS="
"

    for f in $(ssh-add -l|sort); 
    do
		if [ "${f#[0-9]}" == "$f" ];then
			continue
		fi
		B[$C]=$((C/5)) 
		B[$((C+4))]=${f%% *}
		F=${f#* }
		B[$((C+3))]=${F%% *}
		B[$((C+2))]=${f##* }
		F=${f% *}
		B[$((C+1))]=${F##* }
		let C=C+5;
    done
    IFS=$OFS
    return $C
}

function listLoadedKeys () {
    echo 
    echo "Loaded keys:"
    echo "============"
    echo 

    _SSH_AGENT_PID=${SSH_AGENT_PID}
    _SSH_AUTH_SOCK=${SSH_AUTH_SOCK}
    
    getAgentPIDMulti
    local PMAX=$?
    for((cur=0;cur<PMAX;cur+=3));do
		SSH_AGENT_PID=${P[$((cur+1))]}
		SSH_AUTH_SOCK=${P[$((cur+2))]}
		getLoadedKeys
		local LMAX=$?
		C=0;
		LPATH=""
		nmax=0
		for((n=0;n<LMAX;n+=5));do
			nx=${#B[$((n+1))]}
			if((nmax<nx));then
				nmax=$nx
			fi
		done
		if [ "${_SSH_AGENT_PID}" != "${P[$((cur+1))]}" ];then
			printf "  agent(%d): %s:%s\n" ${P[${cur}]} ${P[$((cur+1))]} ${P[$((cur+2))]}
		else
			printf " *agent(%d): %s:%s\n" ${P[${cur}]} ${P[$((cur+1))]} ${P[$((cur+2))]}
		fi
		if((LMAX==0));then
			printf "    %3s\n\n" "-"
			continue
		fi

		for((n=0;n<LMAX;n+=5));do
			d0="${B[$((n+1-5))]}"
			d1="${B[$((n+1))]}"
			if [ \( "${d0%%/*}" != "${d0}" -o  "${d1%%/*}" != "${d1}" \) -a  "${d0%%/*}" != "${d1%%/*}" ];then
				echo
			fi
			printf "    %3d: %-"${nmax}"s:%s\n" ${B[${n}]} ${B[$((n+1))]} ${B[$((n+2))]}
		done
		echo
    done
    SSH_AGENT_PID=${_SSH_AGENT_PID}
    SSH_AUTH_SOCK=${_SSH_AUTH_SOCK}
}

function doit () {
	if [ $STATE -eq 0 ];then
		case $CHOICE in
			ADDKEY)
				if [ -z "$SSH_AGENT_PID" ];then
					echo "ERROR:Missing SSH_AGENT_PID"
					STATE=1
					return 1
				fi
				if [ -z "$SSH_AUTH_SOCK" ];then
					echo "ERROR:missing SSH_AUTH_SOCK"
					STATE=1
					return 1
				fi

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
						ssh-add ${A[$((4*X+1))]}/${A[$((4*X+2))]}
					else
						echo "ERROR:Invalid value: $X>$CMAX"
					fi
				fi
				unset ADDKEY
				;;
			ADDAGENT)
				printIt ""
				printIt "Create a new ssh-agent, requires '-S' for attachment."
				printIt ""
				ssh-agent
				unset ADDAGENT
				;;
			CLEARAGENT)
				echo
				echo "#"
				echo "#Clear assignement of:"
				echo "  SSH_AGENT_PID=${SSH_AGENT_PID}"
				echo "  SSH_AUTH_SOCK=${SSH_AUTH_SOCK}"
				echo
				SSH_AGENT_PID=;
				SSH_AUTH_SOCK=;
				unset CLEARAGENT
				;;
			DELETE)
				if [ -z "$SSH_AGENT_PID" ];then
					echo "ERROR:Missing SSH_AGENT_PID"
					STATE=1
					return 1
				fi
				if [ -z "$SSH_AUTH_SOCK" ];then
					echo "ERROR:missing SSH_AUTH_SOCK"
					STATE=1
					return 1
				fi

				listLoadedKeys
				read -p "Select number:" X
				[[ -z "$X" ]]&&X=-1
				if((X>=0&&X<LMAX));then
					ssh-add -d ${B[$((4*X+1))]}
				fi
				unset DELETE
				;;
			KILLAGENT)
				displayAgentMulti
				PMAX=$?
				if((PMAX>0));then
					X=-1
					read -p "Select number to be stopped($X):" X
					[[ -z "$X" ]]&&X=-1
					if((X>=PMAX));then
						echo "Invalid value:$X>$PMAX"
					else
						if((X>=0));then
							echo "Selected:$X"
							Y=N
							read -p "Continue[yN]:" Y
							if [ "$Y" == y -o "$Y" == Y  ];then
								if((X>=0&&X<PMAX));then
									printIt "kill:SSH_AGENT_PID=SSH_AGENT_PID=${P[$((3*X+1))]}"
									kill ${P[$((3*X+1))]}
								fi
								if [ "$SSH_AGENT_PID" == "${P[$((3*X+1))]}" ];then
									unset SSH_AGENT_PID
									unset SSH_AUTH_SOCK
								fi
							fi
						fi
					fi
				fi
				unset KILLAGENT
				;;
			LIST)
				if [ -z "$SSH_AGENT_PID" ];then
					echo "ERROR:Missing SSH_AGENT_PID"
					STATE=1
					return 1
				fi
				if [ -z "$SSH_AUTH_SOCK" ];then
					echo "ERROR:missing SSH_AUTH_SOCK"
					STATE=1
					return 1
				fi

				listLoadedKeys
				unset LIST
				;;
			LISTALL)
				listLoadedKeys
				listAvailableKeys
				unset LISTALL
				;;
			LISAGENTPROCESSES)
				displayAgentMulti
				echo
				echo "#"
				echo "#Current assigned agent:"
				echo "  SSH_AGENT_PID=${SSH_AGENT_PID}"
				echo "  SSH_AUTH_SOCK=${SSH_AUTH_SOCK}"
				echo
				unset LISAGENTPROCESSES
				;;
			SETAGENT)
				if [ "$SETAGENTIDX" != -1 ];then
					getAgentPIDMulti
				else
					displayAgentMulti
				fi
				PMAX=$?
				if((PMAX==0));then
					echo "#*Start with '-A'"
				else
					if [ "$SETAGENTIDX" != -1 ];then
						X=$SETAGENTIDX
					else
						X=0
						read -p "Select number to be activated($X):" X
					fi

					[[ -z "$X" ]]&&X=0
					if((X<PMAX));then
						SSH_AGENT_PID=${P[$((3*X+1))]}
						SSH_AUTH_SOCK=${P[$((3*X+2))]}
						if [ "$SETAGENTIDX" != -1 ];then
							displayAgentMulti
						fi
						printIt "setting:SSH_AGENT_PID=${SSH_AGENT_PID}"
						printIt "setting:SSH_AUTH_SOCK=${SSH_AUTH_SOCK}"
					else
						echo "ERROR:Invalid value: $X>$PMAX"
					fi
				fi
				unset SETAGENT
				;;

			*);;
		esac
	fi
}
doit


