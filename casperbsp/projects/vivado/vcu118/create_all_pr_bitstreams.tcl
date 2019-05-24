set prjDir "vcu118projectpr"
set top "gmactop"
set bitDir  "./pr_bitstreams"

if { ![file exists "./pr_bitstreams"]} { 
   file mkdir pr_bitstreams
}


#write blinker partial
#exec cp -f $prjDir.runs/impl_1/${top}.bit $bitDir
open_checkpoint $prjDir.runs/impl_blinker/${top}_routed.dcp
set_property CONFIG_MODE S_SELECTMAP32 [current_design]
set_property BITSTREAM.GENERAL.PERFRAMECRC yes [current_design]
write_bitstream -force -cell PartialBlinker_i $bitDir/PartialBlinker_i_partialblinker_partial.bit -raw_bitfile -bin_file -verbose
write_debug_probes -force $bitDir/PartialBlinker_i_partialblinker_partial.ltx

#write compressed top level bitstream
set_property BITSTREAM.GENERAL.PERFRAMECRC no [current_design]
set_property bitstream.general.compress true [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 51.0 [current_design]
set_property CONFIG_MODE SPIx8 [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 8 [current_design]
write_bitstream -force -no_partial_bitfile $bitDir/${top}.bit
write_debug_probes -force $bitDir/gmactop.ltx
close_project

#write flasher partial
open_checkpoint $prjDir.runs/impl_flasher/${top}_routed.dcp
set_property BITSTREAM.GENERAL.PERFRAMECRC yes [current_design]
set_property CONFIG_MODE S_SELECTMAP32 [current_design]
write_bitstream -force -cell PartialBlinker_i $bitDir/PartialBlinker_i_partialflasher_partial.bit -raw_bitfile -bin_file -verbose
write_debug_probes -force $bitDir/PartialBlinker_i_partialflasher_partial.ltx
close_project

