#!/usr/bin/env bash
set -eu

# Spectify a path to scripts.zip of DST server
declare -r script_zip_path='/home/tide/Desktop/backup/scripts.zip'

declare -r script_dir='/tmp/scripts'
declare -r work_dir='/tmp/worldgen-parser'
declare -r repo_root=$(cd $(dirname $0); pwd)
declare -r output_dir="$repo_root/output"

function prepare() {
  if [[ -e $script_dir ]]; then
    echo "$script_dir already exists."
    return
  fi

  echo "unzip $script_zip_path to /tmp ..."
  unzip -q -d /tmp $script_zip_path

  if [[ -e $work_dir ]]; then rm -rf $work_dir; fi
  mkdir $work_dir

  cp -r $script_dir/languages $work_dir
  cp $script_dir/speech* $work_dir
  cp $script_dir/skin_strings.lua $work_dir
  cp $script_dir/strings.lua $work_dir
  cp $script_dir/worldsettings_overrides.lua $work_dir

  if [[ ! -e $work_dir/map ]]; then mkdir $work_dir/map; fi
  cp -r $script_dir/map/tasksets $work_dir/map/tasksets
  cp $script_dir/map/levels.lua $work_dir/map/levels.lua
  cp $script_dir/map/startlocations.lua $work_dir/map/startlocations.lua
  cp $script_dir/map/tasksets.lua $work_dir/map/tasksets.lua
  
  echo 'return {}' > $work_dir/map/tasks.lua
  echo 'return {}' > $work_dir/map/levels.lua

  cp $script_dir/map/customize.lua $work_dir/customize.lua
  declare -r start_line=$(sed -n '/^local MOD_WORLDSETTINGS_MISC = {}/=' $work_dir/customize.lua)
  sed -i -e $start_line',$d' $work_dir/customize.lua
  sed -i -e '$a return { WORLDGEN_GROUP = WORLDGEN_GROUP, WORLDSETTINGS_GROUP = WORLDSETTINGS_GROUP }' $work_dir/customize.lua

  cp $repo_root/*.lua $work_dir
}

prepare

cd $work_dir
lua ./parse.lua

if [[ ! -e $output_dir ]]; then mkdir $output_dir; fi
mv *.json $output_dir
