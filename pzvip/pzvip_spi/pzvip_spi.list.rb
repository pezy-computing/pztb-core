##========================================
##
## Copyright (c) 2023 PEZY Computing, K.K.
##                    All Rights Reserved.
##
##========================================
file_list 'pzvip/pzvip_common/pzvip_common.list.rb', from: :local_root

unless macro? :PZVIP_SPI_MAX_SS_WIDTH
  define_macro :PZVIP_SPI_MAX_SS_WIDTH, 32
end

include_directory 'src'
source_file 'src/pzvip_spi_if.sv'
source_file 'src/pzvip_spi_pkg.sv'
