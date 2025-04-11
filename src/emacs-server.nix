{ pkgs,paths,emacs-with-packages }: pkgs.writers.writeBashBin "emacs-server" ''

set -eu -o pipefail

id=${pkgs.coreutils}/bin/id
emacs=${emacs-with-packages}/bin/emacs
emacsclient=${emacs-with-packages}/bin/emacsclient
flock=${pkgs.util-linux}/bin/flock
mkdir=${pkgs.coreutils}/bin/mkdir
nohup=${pkgs.coreutils}/bin/nohup
paths=${paths}/bin/paths

uid=$($id --user)
run=/run/user/$uid
emacs_dir=$run/emacs

if [[ -e $emacs_dir ]]; then
  [[ -d $emacs_dir ]] || { echo "not a dir: '$emacs_dir'" >&2; exit 3; }
else
  $mkdir -p $emacs_dir
fi

if ! $emacsclient -a false -e t >&/dev/null; then
  [[ -t 1 ]] && echo "starting emacs server..." >&2
  flock_cmd=( $flock --nonblock --exclusive --no-fork $emacs_dir )
  emacs_cmd=( $emacs --no-window-system --daemon )
  $nohup -- ''${flock_cmd[@]} $paths -- ''${emacs_cmd[@]}>&$emacs_dir/emacs.log &
fi
''

# Local Variables:
# mode: sh
# sh-basic-offset: 2
# End:
