# shellcheck disable=SC2148,SC1090,SC1091
# NOTE - shellcheck isn't compatible w/ zsh (see: https://github.com/koalaman/shellcheck/issues/809#issuecomment-277326918), zsh-sweep might be a viable alternative (see: https://github.com/psprint/zsh-sweep)

##################
# misc
##################

# source custom aliases
[ ! -e ~/.aliases ] || . ~/.aliases

# add `.local/bin` to path (includes `git-filter-repo` - https://github.com/newren/git-filter-repo/blob/main/INSTALL.md)
# TODO - is this still necessary?
export PATH="$HOME/.local/bin:$PATH"

autoload -U add-zsh-hook # used by the functions below

##################
# pyenv setup
##################

# add pyenv to path
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"

# load pyenv into shell
eval "$(pyenv init -)"

# setup python/virtualenv whenever the `env` dir OR a `.python-version` file is detected
# TODO - investigate whether `virtualenv` w/ ohmyzsh's `virtualenvwrapper` plugin is a superior solution
setup_python() {
	if [ -d "env" ]; then # if `env` dir exists, activate the virtualenv
		echo "Activating virtual environment..."
		source env/bin/activate
	elif [ -n "$VIRTUAL_ENV" ] && [ ! -f .python-version ]; then # if there is no `env` dir and no `.python-version` file but there is an active virtualenv, deactivate it
		echo "Deactivating virtual environment..."
		deactivate
		export VIRTUAL_ENV=''
	elif [[ -f .python-version ]]; then # if there is a `.python-version` file, install the Python version (if necessary) and create a virtualenv
		echo "\`.python-version\` found without a virtual environment."
		python_version=$(cat .python-version)

		if ! pyenv versions --bare | grep -q "^$python_version\$"; then # if the Python version is not installed, install it
			echo "Installing Python $python_version using pyenv..."
			pyenv install "$python_version"
		fi

		echo "Creating virtual environment..."
		python -m venv env
	fi
}

add-zsh-hook chpwd setup_python # exec on `cd`
setup_python >/dev/null         # exec on shell initialization

##################
# nvm setup
##################

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

# setup node whenever `.nvmrc` is detected
setup_node() {
	local nvmrc_path
	nvmrc_path="$(nvm_find_nvmrc)"

	if [ -n "$nvmrc_path" ]; then
		echo "\`.nvmrc\` found."

		local node_version
		node_version=$(cat "${nvmrc_path}")
		local nvmrc_node_version
		nvmrc_node_version=$(nvm version "${node_version}")

		if [ "$nvmrc_node_version" = "N/A" ]; then
			echo "Installing Node ${node_version} using nvm..."
			nvm install
		elif [ "$nvmrc_node_version" != "$(nvm version)" ]; then
			echo "Switching to Node ${node_version}..."
			nvm use
		else
			echo "Node version ${node_version} already active."
		fi
	elif [ -n "$(PWD=$OLDPWD nvm_find_nvmrc)" ] && [ "$(nvm version)" != "$(nvm version default)" ]; then
		echo "Reverting to nvm default version"
		nvm use default
	fi
}

add-zsh-hook chpwd setup_node # exec on `cd`
setup_node >/dev/null         # exec on shell initialization

##################
# p10k setup
##################

# solarized dircolors
if [ -f ~/.dir_colors ]; then
	eval "$(dircolors ~/.dir_colors)"
fi

# `history` cmd format
export HISTTIMEFORMAT="%d/%m/%y %T "

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
