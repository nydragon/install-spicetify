#!/bin/sh

URL="https://github.com/spicetify/spicetify-marketplace/archive/refs/heads/dist.zip"
ZIP=""
SPICETIFY_LOC="$HOME/.config/spicetify"
SKIP_INSTALL=""
MARKETPLACE_LOC="$SPICETIFY_LOC/CustomApps/marketplace"

while getopts 'zcs' flag; do
  case "${flag}" in
    z) ZIP="${OPTARG}" ;;
    c) SPICETIFY_LOC="${OPTARG}" ;;
    s) SKIP_INSTALL="true" ;;
    *) print_usage
       exit 1 ;;
  esac
done

title() {
  echo;
  echo "$1";
  echo;
}

set_rights() {
  
  SPOTIFY_PATH="/opt/spotify";
  SPOTIFY_APPS_PATH="/opt/spotify/Apps"
  
  SET_SPOTIFY_PATH="$(ls -lad $SPOTIFY_PATH | awk '/rw. /')";
  SET_SPOTIFY_APPS_PATH="$(ls -lad $SPOTIFY_APPS_PATH | awk '/rw. /')";

  if [ -z SET_SPOTIFY_PATH ]; then
    echo "Setting read and write rights for Spotify $SPOTIFY_PATH";
    sudo chmod a+wr $SPOTIFY_PATH;
  fi;

  if [ -z SET_SPOTIFY_APPS_PATH ]; then
    echo "Setting read and write rights for Spotify $SPOTIFY_APPS_PATH";
    sudo chmod a+wr $SPOTIFY_APPS_PATH -R;
  fi;
};


if [ -z "$(yay -Q spotify | awk '/spotify/')" ]; then
  echo "Spotify is not installed. Install it with:";
  echo "yay -Sy spotify";
  exit;
fi;

if [ -z $SKIP_INSTALL ]; then
  title "------ INSTALLING SPICETIFY ------";
  yay -S spicetify-cli;
fi;

set_rights;

title "------ INSTALLING SPICETIFY MARKETPLACE ------";

if [[ -d $MARKETPLACE_LOC || -f $MARKETPLACE_LOC ]]; then
  echo "File found at $MARKETPLACE_LOC.";
  echo "This could be a Marketplace installation or another file."
  echo "Would you like to delete it to proceed?";

  while :
  do
    echo -n "y/n: ";
    read answer
    
    if [[ $answer == "y" ]]; then
      rm -rf $MARKETPLACE_LOC;
      break;
    elif [[ $answer == "n" ]]; then
      exit;
    fi;
  done
fi;

if [ -z $ZIP ]; then
    ZIP="spicetify-marketplace-dist.zip";
    URL="https://github.com/spicetify/spicetify-marketplace/archive/refs/heads/dist.zip"

    echo "Retrieving the file from $URL";
    echo "Verify if the URL is still correct.";

    echo "";
    curl -Lo $ZIP https://github.com/spicetify/spicetify-marketplace/archive/refs/heads/dist.zip;
    echo "";
else
    mv $ZIP .;
fi;

ROOT_FOLDER=$(zipinfo -1 $ZIP | head -n 1);

if [ -d $ROOT_FOLDER ]; then
  echo "Deleting $ROOT_FOLDER, move it somewhere else in case it is an unrelated file.";
  rm -rI $ROOT_FOLDER;p
fi;

unzip $ZIP;

mv $ROOT_FOLDER $MARKETPLACE_LOC;

title "------ INSTALLING SPICETIFY MARKETPLACE THEME ------";

MARKETPLACE_THEME_LOC="$SPICETIFY_LOC/Themes/marketplace";

mkdir -p $MARKETPLACE_THEME_LOC;
curl -Lo $MARKETPLACE_THEME_LOC/color.ini https://raw.githubusercontent.com/spicetify/spicetify-marketplace/main/resources/color.ini;

spicetify config inject_css 1
spicetify config replace_colors 1
spicetify config current_theme marketplace

spicetify config custom_apps marketplace
spicetify apply
spicetify backup apply