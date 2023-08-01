##========================================
##
## Copyright (c) 2023 PEZY Computing, K.K.
##                    All Rights Reserved.
##
##========================================

## TUE
if env? :TUE_HOME
  file_list 'compile.rb', from: env(:TUE_HOME)
else
  file_list 'tue/compile.rb', from: :local_root
end

## Verdi Performance Analyzer
if macro?(:_PZ_PZVIP_ENABLE_PA_WRITER_) && target_tool?(:vcs)
  define_macro :ENABLE_VERDI_PA_WRITER
  compile_argument '-debug_access+r'
  include_directory 'share/pa_writer/sv/src', from: env(:VERDI_HOME)
  source_file 'share/pa_writer/sv/src/verdi_pa_writer.sv', from: env(:VERDI_HOME)
end

include_directory 'src'
source_file 'src/pzvip_common_pkg.sv'
