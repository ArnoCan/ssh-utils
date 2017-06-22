#!/usr/bin/bash

AUTHOR="Arno-Can Uestuensoez"
LICENSE="Artistic-License-2.0 + Forced-Fairplay-Constraints"
COPYRIGHT="Copyright (C) 2017 Arno-Can Uestuensoez @Ingenieurbuero Arno-Can Uestuensoez"
VERSION='0.1.6'
DATE='2017-06-22'
WWW='https://arnocan.wordpress.com'
UUID='a8ecde1c-63a9-44b9-8ff0-6c7c54398565'
NICKNAME="Scotty"
MISSION="Beam you up to, where ever you want."

function printHelpShort () {
    cat <<EOF

${BASH_SOURCE##*/} [OPTIONS] <ssh-key>

  -l                  | --long

  -d                  | --debug
  -v                  | --verbose
  -X                  | --terse

  -V                  | --version

  -h (short)
  -help               | --help (detailed)

EOF
}


function printHelp () {
    cat <<EOF

SYNOPSIS:

  ${BASH_SOURCE##*/} [OPTIONS] <ssh-key>

DESCRIPTION:

  Show type of SSH private keys.

  Supports RSA, DSA, and ECDSA.

OPTIONS:

  -a | --asn1
    Pure ASN.1.

  -l | --long
	 Full length of fields.


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

COPYRIGHT:

  $COPYRIGHT

LICENSE:

  $LICENSE

EOF
}

LONG=0
ARGS=$*
while [[ "X$1" != "X" ]];do
    case $1 in
		-l|--long)
			LONG=1
    		shift
			;;
		-r|--raw)
			RAW=1
    		shift
			;;
		-h)
			printHelpShort
			exit
			;;
		-help|--help)
			printHelp
			exit
			;;
		-d|-debug|--debug)
			DEBUG=1
    		shift
			;;
		-v|-verbose|--verbose)
			VERBOSE=1
			TERSE=0
			shift
			;;
		-X|--terse)
			VERBOSE=0
			TERSE=1
			shift
			;;
		-V|--version)
			((TERSE==0))&&{ echo $VERSION ; }||{ echo -n $VERSION ; }
			exit 0
			;;

		-*|--*)
			printHelpShort
			printError
			printError "Unknown option: $1 / $ARGS"
			printError
			exit 1
			;;
		*)break;;
    esac
done

#-------------------------

_FI=$*
_FT=""

# exists
if [[ ! -e "${_FI}" ]];then
	echo "ERROR:Missing key:\"${_FI}\"" >&2
	unset _FI _FT
	exit 1
fi

# is type of RSA
_F=`file $_FI`
_FT="${_F#$_FI: PEM}"
_FT="${_FT## }"
((TERSE==1))&&{ _E=' -n ' ; }
_FT=${_FT#*OpenSSH}
_FT=${_FT## }
case "$_FT" in
	RSA*public*)((LONG==0))&&{ echo ${_E} RSApub ; }||{ echo ${_E} $_F ; };; # RSA-public
	RSA*private*)((LONG==0))&&{ echo ${_E} RSApriv ; }||{ echo ${_E} $_F ; };; # RSA-private
	DSA*public*)((LONG==0))&&{ echo ${_E} DSApub ; }||{ echo ${_E} $_F ; };; # DSA-public
	DSA*private*)((LONG==0))&&{ echo ${_E} DSApriv ; }||{ echo ${_E} $_F ; };; # DSA-private
	*)
		_FT="${_FT#$_FI: }"
		_FT="${_FT## }"
		case "$_FT" in
			ASCII*)
				openssl ec -in "$_FI" -outform DER 2>/dev/null >/dev/null
				if [[ $? == 0 ]];then  ((LONG==0))&&{ echo ${_E} ECDSApriv ; }||{ echo ${_E} $_F ; }; # ECDSA-private
				else
					egrep -q '^ecdsa[-]' "$_FI" 2>/dev/null >/dev/null
					if [[ $? == 0 ]];then  ((LONG==0))&&{ echo ${_E} ECDSApub ; }||{ echo ${_E} $_F ; }; # ECDSA-public
					else
						echo "ERROR:$LINENO:Unknown type ${_FT%% *}:${_FI}" >&2
						unset _FI _FT
						exit 1
					fi
				fi
				;;
			*)
				echo "ERROR:$LINENO:Unknown type ${_FT%% *}:${_FI}" >&2
				unset _FI _FT
				exit 1
				;;
	esac
esac
unset _FI _FT _F
