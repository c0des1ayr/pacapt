#!/usr/bin/env sh

# Purpose: Termux support
# Author : Anh K. Huynh
# License: Fair license (http://www.opensource.org/licenses/fair)
# Source : http://github.com/icy/pacapt/

# Copyright (C) 2010 - 2021 Anh K. Huynh
#
# Usage of the works is permitted provided that this instrument is
# retained with the works, so that any entity that uses the works is
# notified of this instrument.
#
# DISCLAIMER: THE WORKS ARE WITHOUT WARRANTY.

_pkg_init() {
  :
}

# pkg_Q may _not_implemented
# FIXME: Need to support a small list of packages
pkg_Q() {
  if [ "$_TOPT" = "q" ]; then
    dpkg -l \
    | grep -E '^[hi]i' \
    | awk '{print $2}'
  elif [ -z "$_TOPT" ]; then
    dpkg -l "$@" \
    | grep -E '^[hi]i'
  else
    _not_implemented
  fi
}

pkg_Qc() {
  pkg changelog "$@"
}

pkg_Qi() {
  dpkg-query -s "$@"
}

pkg_Qe() {
  apt-mark showmanual "$@"
}

pkg_Qk() {
  _require_programs debsums
  debsums "$@"
}

pkg_Ql() {
  if [ $# -ge 1 ]; then
    dpkg-query -L "$@"
    return
  fi

  dpkg -l \
  | grep -E '^[hi]i' \
  | awk '{print $2}' \
  | while read -r _pkg; do
      if [ "$_TOPT" = "q" ]; then
        dpkg-query -L "$_pkg"
      else
        dpkg-query -L "$_pkg" \
        | while read -r _line; do
            echo "$_pkg $_line"
          done
      fi
    done
}

pkg_Qo() {
  if cmd="$(command -v -- "$@")"; then
    dpkg-query -S "$cmd"
  else
    dpkg-query -S "$@"
  fi
}

pkg_Qp() {
  dpkg-deb -I "$@"
}

pkg_Qu() {
  pkg upgrade --trivial-only "$@"
}

# NOTE: Some field is available for dpkg >= 1.16.2
# NOTE: Debian:Squeeze has dpkg < 1.16.2
pkg_Qs() {
  # dpkg >= 1.16.2 dpkg-query -W -f='${db:Status-Abbrev} ${binary:Package}\t${Version}\t${binary:Summary}\n'
  dpkg-query -W -f='${Status} ${Package}\t${Version}\t${Description}\n' \
  | grep -E '^((hold)|(install)|(deinstall))' \
  | sed -r -e 's#^(\w+ ){3}##g' \
  | grep -Ei "${@:-.}" \
  | _quiet_field1
}

# pkg_Rs may _not_implemented
pkg_Rs() {
  if [ -z "$_TOPT" ]; then
    apt-get autoremove "$@"
  else
    _not_implemented
  fi
}

pkg_Rn() {
  apt-get purge "$@"
}

pkg_Rns() {
  apt-get --purge autoremove "$@"
}

pkg_R() {
  pkg remove "$@"
}

pkg_Sg() {
  _require_programs tasksel
  
  if [ $# -gt 0 ]; then
    tasksel --task-packages "$@"
  else
    tasksel --list-task
  fi
}

pkg_Si() {
  apt-cache show "$@"
}

pkg_Suy() {
  pkg update \
  && pkg upgrade "$@" \
  && apt-get dist-upgrade "$@"
}

pkg_Su() {
  pkg upgrade "$@" \
  && apt-get dist-upgrade "$@"
}

# See also https://github.com/icy/pacapt/pull/78
# This `-w` option is implemented in `00_core/_translate_w`
#
# pkg_Sw() {
#   pkg --download-only install "$@"
# }

pkg_Sy() {
  pkg update "$@"
}

# FIXME: A simple implementation for #53 and
# FIXME: https://github.com/icy/pacapt/pull/156
# FIXME: but I'm not sure there is any issue...
pkg_Ss() {
  apt-cache search "${@:-.}" \
  | while read -r name _ desc; do
      if ! dpkg-query -W "$name" > /dev/null 2>&1; then
        printf "package/%s \n    %s\n" \
          "$name" "$desc"
      else
        dpkg-query -W -f='package/${binary:Package} ${Version}\n    ${binary:Summary}\n' "$name"
      fi
  done
}

pkg_Sc() {
  pkg clean "$@"
}

pkg_Scc() {
  pkg autoclean "$@"
}

pkg_S() {
  # shellcheck disable=SC2086
  pkg install $_TOPT "$@"
}

pkg_U() {
  dpkg -i "$@"
}

pkg_Sii() {
  apt-cache rdepends "$@"
}

pkg_Sccc() {
  rm -fv /var/cache/apt/*.bin
  rm -fv /var/cache/apt/archives/*.*
  rm -fv /var/lib/apt/lists/*.*
  pkg autoclean
}
