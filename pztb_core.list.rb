##========================================
##
## Copyright (c) 2023 PEZY Computing, K.K.
##                    All Rights Reserved.
##
##========================================

default_search_path file_list: :current

if macro? :_PZ_UVM_
  file_list 'pzvip/pzvip.list.rb'
  file_list 'tvip/tvip.list.rb'
  file_list 'pztb_common_env/pztb_common_env.list.rb'
end

[
  'pkg', 'misc', 'memory', 'irq_bfm', 'pzcorebus_bfm', 'pzaxi_bfm'
].each do |component|
  file_list "#{component}/#{component}.list.rb"
end
