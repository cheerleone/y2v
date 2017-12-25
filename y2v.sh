#!/bin/bash

:<<BLOCK_COMMENT

  Youtube to VLC

  License: GPL-V2.0

  Copyright 2014 CL.

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

  Description

This script monitors the X-Windows Clipboard for changes, if a youtube URL is found, the URL is passed to VLC.

  Notes

While this script is not a Resource-hog. I do not recommend leaving this running any longer than necessary.

  Known Issues
  
XClip often outputs an error when an application that accessed the clipboard is closed, possibly due to a null value in X's Clipboard. Also VLC likes to complain about minutia that's usually nothing to worry about.

BLOCK_COMMENT

#-------------------------------------------------------------------------------

  # version

VERSION="0.3.0.beta";                          # major.minor.point.stage

  # global variables

VIDEO_URL="$1";                                # URL to video
Open_VLC_Fullscreen="True";                    # True = fullscreen, False = @ defaultl size in a window.

SPINDEX=0;                                     # Spinner Index - index into which character to use
CHARS="|/-\\";                                 # Spiner Inxex Characters

#-------------------------------------------------------------------------------

  # functions
  
function Sanitize_Youtube_URL {
  # many youtube URL's contain the ampersand (&) character which creates an issue passing the URL
  # to executables. for and remove any ampersand and successive characters.
  VIDEO_URL="${VIDEO_URL%%&*}";                          # strip ampersand and successive characters
}

function Call_VLC {
  local fs="";
  if [ "$Open_VLC_Fullscreen" == "True" ]; then
    fs="--fullscreen";
  fi
  Sanitize_Youtube_URL;
  echo -e "Opening: $VIDEO_URL";
  vlc $VIDEO_URL $fs --play-and-exit &> /dev/null;
}

function Check_Deps2() {
  xsel --version > /dev/null;
  if [ "$?" -ne "0" ]; then
    echo -e "$pc\033[F $pc\033[2K \b\b XSEL does not appear to be installed"
    exit 1
  fi
  vlc --version &> /dev/null
  if [ "$?" -ne "0" ]; then
    echo -e "$pc\033[F $pc\033[2K \bVLC does not appear to be installed"
    exit 1
  fi
}

function Advance_Spinner {  
  echo -ne "${CHARS:$SPINDEX:1} $pc\033[0K\r";
  (( SPINDEX++ ));
  if [ $SPINDEX = 4 ]; then
    SPINDEX=0;
  fi
}

function Poll_Clipboard {
  local CLIP_CURRENT="";
  local CLIP_CHECK="hsid8fyuib83riwk3urh";
  local Poll_String="Polling for Youtube URL's on X Clipboard..   (CTRL+C to stop)";
  echo "$Poll_String";
  while [ 1 = 1 ]; do
    CLIP_CURRENT=$(xsel -o);
    echo $CLIP_CURRENT | grep "youtube.com/" > /dev/null
    if [[ "$?" = "0" ]]; then
      if [[ "$CLIP_CURRENT" != "$CLIP_CHECK" ]]; then          
        VIDEO_URL=$CLIP_CURRENT;
        Call_VLC;
        CLIP_CHECK=$CLIP_CURRENT;
      fi
    fi
    sleep 1    
    Advance_Spinner;    
  done
}

function control_c() {
  setterm -cursor on          # unhide cursor
  echo -ne "$pc\033[0K\r";    # return cursor to start of line - hides spinner character
  exit $1;
}

#-------------------------------------------------------------------------------

function _Main {
  Check_Deps2;
  setterm -cursor off;          # hide cursor - makes spinner look better.
  trap control_c SIGINT;        # unhide cursor when ctrl+c is used to exit.
  Poll_Clipboard;
}

#-------------------------------------------------------------------------------

  _Main;
  exit 0;

# The End.


