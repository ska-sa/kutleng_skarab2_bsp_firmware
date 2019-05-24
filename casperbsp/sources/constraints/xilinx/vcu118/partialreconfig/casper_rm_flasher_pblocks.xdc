# Base Reference Clock
create_pblock pblock_partialflasher_rm
add_cells_to_pblock [get_pblocks pblock_partialflasher_rm] [get_cells -quiet [list PartialBlinker_i]]
resize_pblock [get_pblocks pblock_partialflasher_rm] -add {SLICE_X43Y75:SLICE_X50Y109}
resize_pblock [get_pblocks pblock_partialflasher_rm] -add {DSP48E2_X7Y30:DSP48E2_X7Y43}
resize_pblock [get_pblocks pblock_partialflasher_rm] -add {RAMB18_X3Y30:RAMB18_X3Y43}
resize_pblock [get_pblocks pblock_partialflasher_rm] -add {RAMB36_X3Y15:RAMB36_X3Y21}



