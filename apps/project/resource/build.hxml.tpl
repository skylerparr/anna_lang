-cp apps/main
-cp ports
-cp ../../src
-cp ../../scripts
-cp ../../apps/lang/lib
-cp ../../apps/vm/lib
-cp ../../apps/vm_api/lib
-D analyzer-optimize
-D hscriptPos
-D HXCPP_M64
-cpp ../::app_name::
-main StandaloneMain
-lib sepia
-lib hscript-plus
-lib hxbert
--macro keep("CPPCLIInput")
