
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
. "$HOME/.cargo/env"

# Colima's docker socket (XDG path) — keeps docker clients working
# regardless of context config
export DOCKER_HOST="unix://$HOME/.config/colima/default/docker.sock"
