##========================================
##
## Copyright (c) 2023 PEZY Computing, K.K.
##                    All Rights Reserved.
##
##========================================
file_list 'pzvip/pzvip_common/pzvip_common.list.rb', from: :local_root

include_directory 'src'
source_file 'src/pzvip_corebus_types_pkg.sv'
source_file 'src/pzvip_corebus_if.sv'
source_file 'src/pzvip_corebus_pkg.sv'
