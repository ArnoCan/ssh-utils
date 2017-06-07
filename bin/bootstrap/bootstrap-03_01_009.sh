#!/bin/bash
#HEADSTART##############################################################
#
#PROJECT:      UnifiedTraceAndLogManager
#AUTHOR:       Arno-Can Uestuensoez - acue.opensource@gmail.com
#MAINTAINER:   Arno-Can Uestuensoez - acue.opensource@gmail.com
#SHORT:        utalm-bash
#LICENCE:      Apache-2.0
#VERSION:      03_01_002
#
########################################################################
#
#   Copyright [2007,2008,2010,2013] Arno-Can Uestuensoez
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
#HEADEND################################################################
#
#$Header$
#


#MODULEBEG###############################################################
#NAME:
#  bootstrap
#
#TYPE:
#  bash-function-library
#
#DESCRIPTION:
#  Used during bootstrap of current called script in order to find and
#  assign the installed runtime environment. 
#
#  Has to be located in the same directory as the callee gwhich is
#  going to set it's environment.
#
#EXAMPLE:
#
#PARAMETERS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#MODULEEND###############################################################


if [ -z "$__BOOTSTRAP__" ];then #*** prevent multiple inclusion
__BOOTSTRAP__=1 #*** prevent multiple inclusion

_myLIBNAME_bootstrap="${BASH_SOURCE}"
_myLIBVERS_bootstrap="03.01.009"


declare -a LIBMAN_NAME
declare -a LIBMAN_VERS

#FUNCBEG###############################################################
#NAME:
#  bootstrapRegisterLib
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Adds an entry to info array, where all libraries will be registered
#  with basic information, which is for now:
#
#  bootstrapRegisterLib <pkg-name> <pkg-version>
#
#EXAMPLE:
#
#PARAMETERS:
# <pkg-name> 
# <pkg-version>
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function bootstrapRegisterLib () {
  local _s=${#LIBMAN_NAME[@]}

  if [ -n "$1" ];then
    LIBMAN_NAME[$_s]="${1##/*/}"
  fi
  if [ -n "$2" ];then
    LIBMAN_VERS[$_s]="$2"
  fi
}

#
#the initial entry
bootstrapRegisterLib "${_myLIBNAME_bootstrap}" "${_myLIBVERS_bootstrap}"

#FUNCBEG###############################################################
#NAME:
#  bootstrapListLib
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Lists all entries from LIBMAN.
#
#EXAMPLE:
#
#PARAMETERS:
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function bootstrapListLib () {
    local _s=${#LIBMAN_NAME[@]}

    echo "LIBRARIES(static-loaded - generic):"
    echo
    printf "  %02s   %-43s%s\n" "Nr" "Library" "Version"
    echo "  ------------------------------------------------------------"
    for((i=0;i<_s;i++));do
	printf "  %02d   %-43s%s\n" $i ${LIBMAN_NAME[$i]} ${LIBMAN_VERS[$i]}
    done
    echo
}


#FUNCBEG###############################################################
#NAME:
#  bootstrapGetRealPathname
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Used during bootstrap of curretn called script in order to find and
#  assign the installed runtime environment. 
#  Therefore the "physical" path to the call directory is expanded
#  thus the well defined relative paths of project convention could
#  be evaluated.
#
#  The exeption is, that hardlinks are not treated specially, thus 
#  symbolic links has to be used instead.
#
#  Has to be located in the same directory as the callee gwhich is
#  going to set it's environment.
#
#EXAMPLE:
#
#PARAMETERS:
# $1: Argument is checked for beeing a sysmbolic link, and
#     if so the target will be evaluated and returned,
#     else input is echoed.
#
#OUTPUT:
#  RETURN:
#  VALUES:
#     Returns real target for sysmbolic links, else the 
#     pathname itself.
#
#FUNCEND###############################################################
function bootstrapGetRealPathname () {
    local _maxCnt=20;
    local _realPath=${1}
    local _cnt=0

    if [ "${_realPath%%/*}" == "." ];then
	_realPath="${PWD}${_realPath#.}"
    fi
    _realPath="${_realPath/\/.\///}"

    while((_cnt<_maxCnt)) ;do    
	if [ -h "${_realPath}" ];then
            _realPath=`ls -l ${1}|awk '{print $NF}'`
	else
	    break;
	fi
	let cnt++;
    done
    if((_maxCnt==0));then
	echo "$BASH_SOURCE:$LINENO:Path could not be evaluated:${1}">&2
	echo "$BASH_SOURCE:$LINENO:INFO: Seems to be a circular-chained sysmbolic link">&2
	echo "$BASH_SOURCE:$LINENO:INFO: Aborted recursion level: ${_maxCnt}">&2
        exit 1
    fi

    echo -n "$_realPath"
}




#FUNCBEG###############################################################
#NAME:
#  bootstrapCheckInitialPath
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Checks the almost in all my projects defined root hook for 
#  existence, of not gives extensive hints.
#
#  Yes, the first intention counts!!!
#
#EXAMPLE:
#
#PARAMETERS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#
#FUNCEND###############################################################
function bootstrapCheckInitialPath () {
if [ ! -d "${MYLIBPATH}" ];then
  echo "${MYCALLNAME}:$LINENO:ERROR:Missing:MYLIBPATH=${MYLIBPATH}"
cat << EOF1

The installation might be corrupted, here are some hints to prerequisites
to find the required paths for utilities from project "${MYPROJECT}".

  This tool requires the project structure of ${MYPROJECT}:

    ${HOME}/lib/${MYPROJECT}/....
       All installed files of the project.

    ${HOME}/bin/${MYCALLNAME}
       This is expected to be a sysmbolic link to:
       ${HOME}/lib/${MYPROJECT}/bin/${MYCALLNAME}

Else the following environment variable is required to be
set to the containing directory of project:${MYPROJECT}

   UTALM_LIBPATH=/<base-directory>/${MYPROJECT}/{bin,lib,...}

The executables from 

   \${UTALM_LIBPATH}/bin/...

Should be set as a symbolic link to a directory within PATH, e.g.

   \${HOME}/bin/...

The variable assignment is generated as standard value during
installation into $HOME/.profile or $HOME/.bashrc.

EOF1

  exit 1
fi
}


#FUNCBEG###############################################################
#NAME:
#  gwhich
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Generic which.
#
#PARAMETERS:
#
#OUTPUT:
#  RETURN:
#    0: found
#    1: not found
#  VALUES:
#
#FUNCEND###############################################################
function gwhich () {
    case ${MYOS} in
	SunOS)
	    local _xf=`which $*`;
	    local _ret=$?;
	    case $_xf in
		no*)#solaris
		    return 1;
		    ;;
		*not*found*)#opensolaris
		    return 1;
		    ;;
		*)#opensolaris
		    if [ $_ret -ne 0 ];then
			return 1;
		    fi
		    ;;
	    esac
	    echo -n -e $_xf
	    ;;
	CYGWIN)
	    #requires workaround for PATH error: "which $(which which)"
	    local _xf=;
	    local _ret=;

	    if [ -x "$*" ];then
		echo -n -e $*
		return 0
	    fi

	    local _d=${*%/*}
	    local _b=${*##*/}
	    if [ "$_b" == "$_d" ];then
		_d=;
	    fi
	    _xf=`which $_b 2>/dev/null`;
	    _ret=$?;
	    if [ -z "$_xf" ];then
		_xf=`PATH=$PATH:$_d which $_b 2>/dev/null`;
		_ret=$?;
	    fi
            # let's say: /bin == /usr/bin
#4TEST-4CYGWIN:	    if [ $_ret -eq 0 ];then
	    if [ -n "$_xf" ];then
		if [ -n "$_d" ];then
		    local _dx=${_xf%/*}
		    test "$_d" == "$_dx"
		    _ret=$?;
		    if [ "$_ret" -ne 0 ];then
			if [ "/usr${_xf%/*}" == "$_d" ];then
			    _xf=$_d/$_b;
			    _ret=0;
			fi
		    fi
		fi
		echo -n -e $_xf
	    fi
	    return $_ret
	    ;;
	*)
	    local _xf=;
	    local _ret=;
	    _xf=`which $* 2>/dev/null`;
	    _ret=$?;
	    echo -n -e $_xf
	    return $_ret
	    ;;
    esac
}

export -f gwhich 



fi #*** prevent multiple inclusion
