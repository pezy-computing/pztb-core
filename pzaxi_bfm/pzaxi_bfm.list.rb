##========================================
##
## Copyright (c) 2023 PEZY Computing, K.K.
##                    All Rights Reserved.
##
##========================================
if env?(:PZBCM_HOME)
  file_list 'pzaxi_common/pzaxi_common.list.rb', from: env(:PZBCM_HOME)
end

[
  'tb_pzaxi_master_bfm.sv',
  'tb_pzaxi_slave_bfm.sv'
].each { |file| source_file file }
