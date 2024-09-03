#!/bin/bash

# Automate the creation of timestamped backups.

source_dir="/source_dir_path"
backup_dir="/backup_path"
timestamp=$(date +%Y_%m_%d_%H_%M_%S) # +%Y-%m-%d' '%H:%M:%S

backup_file="backup_${timestamp}.tar.gz"

tar -czvf "${backup_dir}/${backup_file}" "${source_dir}
