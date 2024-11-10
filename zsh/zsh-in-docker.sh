#!/bin/sh

set -e

THEME=default
PLUGINS=""
ZSHRC_APPEND=""
INSTALL_DEPENDENCIES=true

load_file_to_var() {
    local file=$1
    local delimiter=$2
    local content=""

    # Get the directory of the current script
    SCRIPT_DIR=$(dirname "$(realpath "$0")")

    # Change to the script directory
    cd "$SCRIPT_DIR" || exit 1

    # Resolve relative paths to absolute paths
    if [ ! -f "$file" ]; then
        file=$(realpath "$file")
    fi

    if [ ! -f "$file" ]; then
        echo "Error: File $file not found."
        return 1
    fi

    # Read the file line by line and append each line to the content variable
    while IFS= read -r line; do
        # Remove carriage return character (if any) from the end of the line
        line=$(echo "$line" | tr -d '\r')
        
        if [[ -n "$line" ]]; then  # Check if line is not empty
            content="${content}${line}${delimiter}"
        fi
    done < "$file"

    # Remove the trailing delimiter at the end of the content
    content="${content%"$delimiter"}"

    # Return the content
    echo "$content"
}

while getopts ":t:p:a:x" opt; do
    case ${opt} in
        t)  THEME=$OPTARG
            ;;
        x)  INSTALL_DEPENDENCIES=false
            ;;
        \?)
            echo "Invalid option: $OPTARG" 1>&2
            ;;
        :)
            echo "Invalid option: $OPTARG requires an argument" 1>&2
            ;;
    esac
done
shift $((OPTIND -1))

# Load plugins from the specified file 
PLUGINS=$(load_file_to_var "zsh_plugins.txt" " ")
ZSHRC_APPEND=$(load_file_to_var ".zshrc_extra" "\n")

echo
echo "Installing Oh-My-Zsh with:"
echo "  THEME   = $THEME"
echo "  PLUGINS = $PLUGINS"
echo

check_dist() {
    (
        . /etc/os-release
        echo "$ID"
    )
}

check_version() {
    (
        . /etc/os-release
        echo "$VERSION_ID"
    )
}

install_dependencies() {
    DIST=$(check_dist)
    VERSION=$(check_version)
    echo "###### Installing dependencies for $DIST"

    if [ "$(id -u)" = "0" ]; then
        Sudo=''
    elif which sudo; then
        Sudo='sudo'
    else
        echo "WARNING: 'sudo' command not found. Skipping the installation of dependencies. "
        echo "If this fails, you need to do one of these options:"
        echo "   1) Install 'sudo' before calling this script"
        echo "OR"
        echo "   2) Install the required dependencies: git curl zsh"
        return
    fi

    case $DIST in
        alpine)
            $Sudo apk add --update --no-cache git curl zsh
        ;;
        amzn)
            $Sudo yum update -y
            $Sudo yum install -y git zsh
            $Sudo yum install -y ncurses-compat-libs # this is required for AMZN Linux (ref: https://github.com/emqx/emqx/issues/2503)
        ;;
        rhel|fedora|rocky)
            $Sudo yum update -y
            $Sudo yum install -y git zsh
        ;;
        *)
            $Sudo apt-get update
            $Sudo apt-get -y install git curl zsh locales
            if [ "$VERSION" != "14.04" ]; then
                $Sudo apt-get -y install locales-all
            fi
            $Sudo locale-gen en_US.UTF-8
    esac
}

zshrc_template() {
    _HOME=$1;
    _THEME=$2; shift; shift
    _PLUGINS=$*;

    if [ "$_THEME" = "default" ]; then
        _THEME="powerlevel10k/powerlevel10k"
    fi

    cat <<EOM
export LANG='en_US.UTF-8'
export LANGUAGE='en_US:en'
export LC_ALL='en_US.UTF-8'
[ -z "$TERM" ] && export TERM=xterm-256color

##### Zsh/Oh-my-Zsh Configuration
export ZSH="$_HOME/.oh-my-zsh"

ZSH_THEME="${_THEME}"
plugins=($_PLUGINS)

EOM
    printf "$ZSHRC_APPEND"
    printf "\nsource \$ZSH/oh-my-zsh.sh\n"
}

powerline10k_config() {
    cat <<EOM
POWERLEVEL9K_SHORTEN_STRATEGY="truncate_to_last"
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(user dir vcs status)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()
POWERLEVEL9K_STATUS_OK=false
POWERLEVEL9K_STATUS_CROSS=true
EOM
}

if [ "$INSTALL_DEPENDENCIES" = true ]; then
    install_dependencies
fi

cd /tmp

# Install On-My-Zsh
if [ ! -d "$HOME"/.oh-my-zsh ]; then
    sh -c "$(curl https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended
fi

# Generate plugin list
plugin_list=""
for plugin in $PLUGINS; do
    if [ "$(echo "$plugin" | grep -E '^http.*')" != "" ]; then
        plugin_name=$(basename "$plugin")
        git clone "$plugin" "$HOME/.oh-my-zsh/custom/plugins/$plugin_name"
    else
        plugin_name=$plugin
    fi
    plugin_list="${plugin_list}$plugin_name "
done

# Handle themes
if [ "$(echo "$THEME" | grep -E '^http.*')" != "" ]; then
    theme_repo=$(basename "$THEME")
    THEME_DIR="$HOME/.oh-my-zsh/custom/themes/$theme_repo"
    git clone "$THEME" "$THEME_DIR"
    theme_name=$(cd "$THEME_DIR"; ls *.zsh-theme | head -1)
    theme_name="${theme_name%.zsh-theme}"
    THEME="$theme_repo/$theme_name"
fi

# Generate .zshrc
zshrc_template "$HOME" "$THEME" "$plugin_list" > "$HOME"/.zshrc

# Install powerlevel10k if no other theme was specified
if [ "$THEME" = "default" ]; then
    git clone --depth 1 https://github.com/romkatv/powerlevel10k "$HOME"/.oh-my-zsh/custom/themes/powerlevel10k
    powerline10k_config >> "$HOME"/.zshrc
fi
