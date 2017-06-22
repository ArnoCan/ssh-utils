#!/usr/bin/bash

AUTHOR="Arno-Can Uestuensoez"
LICENSE="Artistic-License-2.0 + Forced-Fairplay-Constraints"
COPYRIGHT="Copyright (C) 2017 Arno-Can Uestuensoez @Ingenieurbuero Arno-Can Uestuensoez"
VERSION='0.1.0'
DATE='2017-06-11'
WWW='https://arnocan.wordpress.com'
UUID='a8ecde1c-63a9-44b9-8ff0-6c7c54398565'
NICKNAME="Scotty"
MISSION="Beam you up to, where ever you want."

function printHelpShort () {
    cat <<EOF

${BASH_SOURCE##*/} [OPTIONS] <ssh-key>

  -a                  | --asn1
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

  Show ASN.1 of SSH private keys.

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

#ASN1OPTS=" -a -z "
ASN1OPTS=" -a "
ARGS=$*
while [[ "X$1" != "X" ]];do
    case $1 in
		-a|--asn1)
			ASN1OPTS+=" -p "
    		shift
			;;
		-l|--long)
			ASN1OPTS+=" -l "
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
			ASN1OPTS+=" -t "
			shift
			;;
		-X|--terse)
			VERBOSE=0
			TERSE=1
			ASN1OPTS+=" -p "
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


#-------------------------------------------------------

_FI=$*
_FT=""

dumpasn1 2>/dev/null >/dev/null
if [[ $? != 1  ]];then
	echo "ERROR:Missing, current version requires 'dumpasn1' by Peter Gutmann" >&2
	echo "ERROR:0. see 'ext/dumpasn1'" >&2
	echo "ERROR:1. see 'http://www.cs.auckland.ac.nz/~pgut001/dumpasn1.c'" >&2
	unset _FI _FT
	exit 1
fi

# exists
if [[ ! -e "${_FI}" ]];then
	echo "ERROR:Missing key:\"${_FI}\"" >&2
	unset _FI _FT
	exit 1
fi

# is type of RSA
_FT=`file $_FI`
_FT="${_FT#$_FI: PEM}"
_FT="${_FT## }"
case "$_FT" in
	RSA*)openssl rsa -in "$_FI" -outform DER|dumpasn1 $ASN1OPTS -;; # RSA
	DSA*)openssl dsa -in "$_FI" -outform DER|dumpasn1 $ASN1OPTS -;; # DSA
	*)
		_FT="${_FT#$_FI: }"
		_FT="${_FT## }"
		case "$_FT" in
			ASCII*)
				openssl ec -in "$_FI" -outform DER 2>/dev/null >/dev/null
				if [[ $? == 0 ]];then  openssl ec -in "$_FI" -outform DER|dumpasn1  $ASN1OPTS -; # ECDSA
				else
					echo "ERROR:Unknown type ${_FT%% *}:${_FI}" >&2
					unset _FI _FT
					exit 1
				fi
				;;
			*)
				echo "ERROR:Unknown type ${_FT%% *}:${_FI}" >&2
				unset _FI _FT
				exit 1
				;;
	esac
esac
unset _FI _FT
