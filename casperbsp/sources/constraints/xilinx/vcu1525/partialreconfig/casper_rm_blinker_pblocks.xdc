# Base Reference Clock
create_pblock pblock_partialblinker_rm
add_cells_to_pblock [get_pblocks pblock_partialblinker_rm] [get_cells -quiet [list PartialBlinker_i]]
resize_pblock [get_pblocks pblock_partialblinker_rm] -add {SLICE_X58Y600:SLICE_X86Y660}
resize_pblock [get_pblocks pblock_partialblinker_rm] -add {DSP48E2_X8Y240:DSP48E2_X9Y263}
resize_pblock [get_pblocks pblock_partialblinker_rm] -add {RAMB18_X4Y240:RAMB18_X6Y263}
resize_pblock [get_pblocks pblock_partialblinker_rm] -add {RAMB36_X4Y120:RAMB36_X6Y131}
resize_pblock [get_pblocks pblock_partialblinker_rm] -add {URAM288_X1Y160:URAM288_X1Y175}
set_property SNAPPING_MODE ON [get_pblocks pblock_partialblinker_rm]
set_property RESET_AFTER_RECONFIG true  [get_pblocks pblock_partialblinker_rm]

set_property HD.RECONFIGURABLE true [get_cells PartialBlinker_i]




