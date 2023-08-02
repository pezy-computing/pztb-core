##========================================
##
## Copyright (c) 2023 PEZY Computing, K.K.
##                    All Rights Reserved.
##
##========================================
file_list 'misc/misc.list.rb', from: :local_root
file_list 'tue.list.rb', from: :local_root

## PZTB Common Env
include_directory '.'
source_file 'pztb_common_env_pkg.sv'
