# shellcheck shell=sh
# shellcheck disable=SC1091
# SC1091: not following in Dockerfile context
export PS1="\u@\h:\w "
. /google-cloud-sdk/path.bash.inc
. /google-cloud-sdk/completion.bash.inc
