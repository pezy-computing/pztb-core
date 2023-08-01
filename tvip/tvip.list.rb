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

file_list 'tvip-common/compile.rb', from: :current
file_list 'tvip-axi/compile.rb', from: :current
