##========================================
##
## Copyright (c) 2023 PEZY Computing, K.K.
##                    All Rights Reserved.
##
##========================================
[
  'pzvip_corebus',
  'pzvip_gpio',
  'pzvip_i2c',
  'pzvip_spi',
  'pzvip_stream',
  'pzvip_tilelink',
  'pzvip_uart'
].each do |vip|
  macro = "_pz_#{vip}_enabled_".upcase.to_sym
  if macro? macro
    file_list "#{vip}/#{vip}.list.rb", from: :current
  end
end
