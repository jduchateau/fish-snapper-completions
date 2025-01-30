# Fish completion for snapper
# snapper 0.11.0
# libsnapper 7.4.3 
#
# Copyright (C) 2025  Jakub Duchateau

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

function __snapper_configs
    snapper --csv --no-headers list-configs --columns config
end

function __fish_get_commandline_value
    set cli (commandline --current-process --tokenize)
    if test -n "$argv[2]"
        set cli (string join ' ' $argv[2])
    end

    # Example
    # snapper -c config --csv --no-headers list -> config
    # snapper -chome --no-headers list -> home
    # snapper -c=value -> value
    for i in (seq (count $cli))
        if test $cli[$i] = $argv[1]
            set next_i (math $i + 1)
            if test -n "$cli[$next_i]"
                echo $cli[$next_i]
                return
            end
        else if string match -qr -- $argv[1] $cli[$i]
            echo (string match -gr -- $argv[1]'=(\w*)' $cli[$i])
            return
        end
    end
end

function __snapper_list_ids
    set config (__fish_get_commandline_value "-c")
    if test -z "$config"
        set config (__fish_get_commandline_value "--config")
    end
    if test -n "$config"
        sudo snapper -c $config --csv --no-headers list | awk -F',' '{print $3 "\t" $8}'
    else
        sudo snapper --csv --no-headers list | awk -F',' '{print $3 "\t" $8}'
    end
end

function __btrfs_subvolumes
    sudo btrfs subvolume list / | awk '{print $9}'
end


set -l subcommands list-configs create-config delete-config get-config set-config list create modify delete mount umount status diff xadiff undochange rollback setup-quota cleanup

# Disable file completions by default
complete -c snapper --no-files

# Global options
complete -c snapper -n "not __fish_seen_subcommand_from $subcommands" -l quiet -s q -d "Suppress normal output"
complete -c snapper -n "not __fish_seen_subcommand_from $subcommands" -l verbose -s v -d "Increase verbosity"
complete -c snapper -n "not __fish_seen_subcommand_from $subcommands" -l debug
complete -c snapper -n "not __fish_seen_subcommand_from $subcommands" -l utc
complete -c snapper -n "not __fish_seen_subcommand_from $subcommands" -l iso
complete -c snapper -n "not __fish_seen_subcommand_from $subcommands" -l table-style -s t -r -d "Table style (integer)"
complete -c snapper -n "not __fish_seen_subcommand_from $subcommands" -l abbreviate
complete -c snapper -n "not __fish_seen_subcommand_from $subcommands" -l machine-readable -r -a "csv json"
complete -c snapper -n "not __fish_seen_subcommand_from $subcommands" -l csvout
complete -c snapper -n "not __fish_seen_subcommand_from $subcommands" -l jsonout
complete -c snapper -n "not __fish_seen_subcommand_from $subcommands" -l separator -r
complete -c snapper -n "not __fish_seen_subcommand_from $subcommands" -l no-headers
complete -c snapper -n "not __fish_seen_subcommand_from $subcommands" -l config -s c -fr -a "(__snapper_configs)" -d "Set name of config to use"
complete -c snapper -n "not __fish_seen_subcommand_from $subcommands" -l no-dbus
complete -c snapper -n "not __fish_seen_subcommand_from $subcommands" -l root -s r -r -d "Operate on target root (works only without DBus)"
complete -c snapper -n "not __fish_seen_subcommand_from $subcommands" -l ambit -s a -r -d "Operate in the specified ambit"
complete -c snapper -n "not __fish_seen_subcommand_from $subcommands" -l version
complete -c snapper -n "not __fish_seen_subcommand_from $subcommands" -l help -s h -d "Print help"


## list-configs
set -l list_configs_columns config subvolume

complete -c snapper -n "not __fish_seen_subcommand_from $subcommands" -a "list-configs" -d "List configs"

complete -c snapper -n "__fish_seen_subcommand_from list-configs" -l columns -a "$list_configs_columns"

## create-config
complete -c snapper -n "not __fish_seen_subcommand_from $subcommands" -d "Create config" -a "create-config"

complete -c snapper -n "__fish_seen_subcommand_from create-config" -a "(__btrfs_subvolumes)"
complete -c snapper -n "__fish_seen_subcommand_from create-config" -l fstype -s f
complete -c snapper -n "__fish_seen_subcommand_from create-config" -l template -s t

## get-config
complete -c snapper -n "not __fish_seen_subcommand_from $subcommands" -d "Get config" -a "get-config"

complete -c snapper -n "__fish_seen_subcommand_from get-config" -l columns -a "$list_configs_columns"

## list
set -l list_columns config subvolume number default active type date user used-space cleanup description userdata pre-number post-number post-date

complete -c snapper -n "not __fish_seen_subcommand_from $subcommands" -d "List snapshots" -a "list"

complete -c snapper -n "__fish_seen_subcommand_from list" -l type -s t
complete -c snapper -n "__fish_seen_subcommand_from list" -l disable-used-space
complete -c snapper -n "__fish_seen_subcommand_from list" -l all-configs -s a
complete -c snapper -n "__fish_seen_subcommand_from list" -l columns -a "$list_columns"

## create
set -l create_columns number description

complete -c snapper -n "not __fish_seen_subcommand_from $subcommands" -d "Create snapshot" -a "create"

complete -c snapper -n "__fish_seen_subcommand_from create" -l type -s t
complete -c snapper -n "__fish_seen_subcommand_from create" -l pre-number -a "(__snapper_list_ids)"
complete -c snapper -n "__fish_seen_subcommand_from create" -l print-number -s p
complete -c snapper -n "__fish_seen_subcommand_from create" -l description -s d
complete -c snapper -n "__fish_seen_subcommand_from create" -l cleanup-algorithm -s c
complete -c snapper -n "__fish_seen_subcommand_from create" -l userdata -s u
complete -c snapper -n "__fish_seen_subcommand_from create" -l command
complete -c snapper -n "__fish_seen_subcommand_from create" -l read-only
complete -c snapper -n "__fish_seen_subcommand_from create" -l read-write
complete -c snapper -n "__fish_seen_subcommand_from create" -l from -a "(__snapper_list_ids)"

## modify

complete -c snapper -n "not __fish_seen_subcommand_from $subcommands" -a "modify" -d "Modify snapshot"

complete -c snapper -n "__fish_seen_subcommand_from modify" -a "(__snapper_list_ids)"
complete -c snapper -n "__fish_seen_subcommand_from modify" -l description -s d -d "Description for snapshot"
complete -c snapper -n "__fish_seen_subcommand_from modify" -l cleanup-algorithm -s c -d "Cleanup algorithm for snapshot"
complete -c snapper -n "__fish_seen_subcommand_from modify" -l userdata -s u -d "Userdata for snapshot"
complete -c snapper -n "__fish_seen_subcommand_from modify" -l read-only 
complete -c snapper -n "__fish_seen_subcommand_from modify" -l read-write
complete -c snapper -n "__fish_seen_subcommand_from modify" -l default

## delete

complete -c snapper -n "not __fish_seen_subcommand_from $subcommands" -a "delete" -d "Delete snapshot"

complete -c snapper -n "__fish_seen_subcommand_from delete" -a "(__snapper_list_ids)"
complete -c snapper -n "__fish_seen_subcommand_from delete" -l sync -s s -d "Sync after deletion"

## mount

complete -c snapper -n "not __fish_seen_subcommand_from $subcommands" -a "mount" -d "Mount snapshot"

complete -c snapper -n "__fish_seen_subcommand_from mount" -a "(__snapper_list_ids)"

## umount

complete -c snapper -n "not __fish_seen_subcommand_from $subcommands" -a "umount" -d "Umount snapshot"

complete -c snapper -n "__fish_seen_subcommand_from umount" -a "(__snapper_list_ids)"

## status

complete -c snapper -n "not __fish_seen_subcommand_from $subcommands" -a "status" -d "Comparing snapshots"

complete -c snapper -n "__fish_seen_subcommand_from status" -a "(__snapper_list_ids)"
complete -c snapper -n "__fish_seen_subcommand_from status" -x -a '..'

complete -c snapper -n "__fish_seen_subcommand_from status" -a "(__snapper_list_ids)"
complete -c snapper -n "__fish_seen_subcommand_from status" -l output -s o -d "Save status to file" -rF

## diff

complete -c snapper -n "not __fish_seen_subcommand_from $subcommands" -a "diff" -d "Comparing snapshots"

complete -c snapper -n "__fish_seen_subcommand_from diff" -a "(__snapper_list_ids)"
complete -c snapper -n "__fish_seen_subcommand_from diff" -x -a '..'

complete -c snapper -n "__fish_seen_subcommand_from diff" -l input -s i -d "Read files to diff from file" -rF
complete -c snapper -n "__fish_seen_subcommand_from diff" -l diff-cmd -d "Command used for comparing files" -rF
complete -c snapper -n "__fish_seen_subcommand_from diff" -l extensions -s x -d "Extra options passed to the diff command" -rF

## xadiff

complete -c snapper -n "not __fish_seen_subcommand_from $subcommands" -a "xadiff" -d "Comparing snapshots extended attributes"

complete -c snapper -n "__fish_seen_subcommand_from xadiff" -d "Comparing snapshots extended attributes" -a "(__snapper_list_ids)"
complete -c snapper -n "__fish_seen_subcommand_from xadiff" -d "Comparing snapshots extended attributes" -x -a '..'

## undochange

complete -c snapper -n "not __fish_seen_subcommand_from $subcommands" -a "undochange" -d "Undo changes"

complete -c snapper -n "__fish_seen_subcommand_from undochange" -a "(__snapper_list_ids)"
complete -c snapper -n "__fish_seen_subcommand_from undochange" -x -a '..'

complete -c snapper -n "__fish_seen_subcommand_from undochange" -l input -s i -d "Read files for which to undo changes from file" -rF

## rollback


complete -c snapper -n "not __fish_seen_subcommand_from $subcommands" -a "rollback" -d "Rollback"

complete -c snapper -n "__fish_seen_subcommand_from rollback" -a "(__snapper_list_ids)"

complete -c snapper -n "__fish_seen_subcommand_from rollback" -l print-number -s p -d "Print number of second created snapshot"
complete -c snapper -n "__fish_seen_subcommand_from rollback" -l description -s d -d "Description for snapshots"
complete -c snapper -n "__fish_seen_subcommand_from rollback" -l cleanup-algorithm -s c -d "Cleanup algorithm for snapshots"
complete -c snapper -n "__fish_seen_subcommand_from rollback" -l userdata -s u -d "Userdata for snapshots"

## setup-quota

complete -c snapper -n "not __fish_seen_subcommand_from $subcommands" -a "setup-quota" -d "Setup quota"

## cleanup

complete -c snapper -n "not __fish_seen_subcommand_from $subcommands" -a "cleanup" -d "Cleanup snapshots"

complete -c snapper -n "__fish_seen_subcommand_from cleanup" -a "number timeline empty-pre-post"
complete -c snapper -n "__fish_seen_subcommand_from cleanup" -l path -d "Cleanup all configs affecting path." -rF
complete -c snapper -n "__fish_seen_subcommand_from cleanup" -l free-space -d "Try to make space available." -rF



