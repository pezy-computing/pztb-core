##========================================
##
## Copyright (c) 2023 PEZY Computing, K.K.
##                    All Rights Reserved.
##
##========================================
file_list 'memory/memory.list.rb', from: :local_root

if macro? :PZTB_ENABLE_PZCOREBUS_VERYL
  [
    'tb_pzcorebus_master_bfm_task.sv',
    'tb_pzcorebus_master_bfm.sv',
    'tb_pzcorebus_slave_ram_bfm.sv',
    'tb_pzcorebus_slave_bfm.sv',
    'tb_pzcorebus_monitor.sv'
  ].each { |file| source_file File.join('for_veryl', file) }
else
  if env?(:PZBCM_HOME)
    file_list 'pzcorebus.list.rb', from: env(:PZBCM_HOME)
  end

  [
    'tb_pzcorebus_master_bfm_task.sv',
    'tb_pzcorebus_master_bfm.sv',
    'tb_pzcorebus_slave_ram_bfm.sv',
    'tb_pzcorebus_slave_bfm.sv',
    'tb_pzcorebus_monitor.sv'
  ].each { |file| source_file File.join('for_sv', file) }
end
