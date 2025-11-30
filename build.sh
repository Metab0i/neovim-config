# TODO:
#   - dependencies handling
#     - lua-language-server
#	- whole ass thing
#     - ts_ls
#	- npm
#     - clangd
#	- simple installation with apt-get
#     - minimap 
#	- https://github.com/wfxr/code-minimap
#	- https://github.com/wfxr/minimap.vim?tab=readme-ov-file
#	- needs cargo to properly install
#     - bash stuff
#	- check if there's n (sudo npm i -g n)
#	- check if node is lts latest
#	- install npm i -g bash-language-server
#	- install sudo apt install shellcheck


# 
# This nvim set-up has dependencies for it to function properly
# This script installs says dependencies 
#

#ensure apt-get is up-to-date
#sudo apt-get upgrade && sudo apt-get update


# Not Installed, Wanna Install?
notIwannaI() {
  echo "current arg is: $1"

  read -pr "$1 not installed. Wanna install? [Y/n]" install_dep
  install_dep=${install_dep:-Y}

  if [[ $install_dep == "Y" ]]; then
    return 0
  else
    return 1
  fi
}



echo -e "\n\nChecking package dependencies..\n\n"



# process apt dependencies
apt_deps=("npm" "cmake" "curl" "build-essential" "git" "gcc" "python3" "gettext" "ninja-build")

for apt_dep in "${apt_deps[@]}"; do
  if ! dpkg -s "$apt_dep" &> /dev/null; then
    if notIwannaI "$apt_dep" ; then
      #main installation process
      sudo apt-get update && sudo apt-get install "$apt_dep" 
    else
      echo "Skiped installing $apt_dep.."
    fi
  else
    echo "$apt_dep already installed.."
  fi
done


# process other software dependencies

# Rust Cargo
rustcargo="Rust Cargo"

if ! cargo --version &> /dev/null; then
  if notIwannaI "$rustcargo" ; then
    #main installation process
    curl https://sh.rustup.rs -sSf | sh
  else
    echo "Skiped installing $rustcargo.."
  fi
else
  echo "$rustcargo already installed.."
fi


# Lua
lua="Lua"

if ! lua -v &> /dev/null; then
  if notIwannaI "$lua" ; then
    #main installation process
    sudo apt install lua5.4 liblua5.4-dev
  else
    echo "Skipped installing $lua.."
  fi
else
  echo "$lua already installed.."
fi



#todo
echo -e "\n\nSetting up lsp dependencies..\n\n"



# ts_ls

if npm list -g --depth=0 typescript &>/dev/null; then
  echo "Typescript already installed.."

else
  if dpkg -s npm &> /dev/null/; then
    if sudo npm i -g typescript 2> ./err.log ; then
      echo "Typescript installation attempt complete.."

    else
      echo "Typescript installation went wrong, check ./err.log"

    fi

  else
    echo "npm isn't installed, cannot handle this dependency.."

    if notIwannaI "npm" ; then
      sudo apt-get install npm && sudo npm i -g typescript
      echo "Typescript and npm installation attempt complete.."

    else
      echo "Typescript dependency cannot be installed, skipped.."
    fi
    
  fi  
fi


if npm list -g --depth=0 typescript-language-server >/dev/null 1>&1; then
  echo "typescript-language-server already installed.."  

else
  if dpkg -s npm &> /dev/null; then
    if notIwannaI "npm" &>/dev/null/ ; then
    else
    fi

  else
    echo "typescript-language-server dependency cannot be installed, skipped.."

  fi
fi


# shellcheck + bash-language-server

if shellcheck --version &> /dev/null; then
  echo "Installed Shellcheck"
else
  echo "Not installed shellcheck"
fi


# clangd

if clangd --version &> /dev/null; then
  echo "clang installed"
else
  echo "clang not installed"
fi


# lua-language-server

if lua-language-server --version &>/dev/null; then
  echo "lua lang server is installed"
else
  echo "lua lang server isn't installed"
fi
