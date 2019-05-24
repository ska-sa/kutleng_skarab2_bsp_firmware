#Create bin and mcs files for the PR over PCIe application note

set static  "gmactop"

set partials  { \
                    PartialBlinker_i_partialblinker_partial\
                    PartialBlinker_i_partialflasher_partial\
				}


# Convert each partial bitfile into a bin file formatted for the ICAP port
# Disable bit swapping as that is done the ICAP Writer SM
foreach p $partials {
    set cmd "write_cfgmem -force -format BIN -interface SMAPx32 -loadbit \"up 0x00000000 pr_bitstreams/$p.bit\" pr_bitstreams/$p"
    eval $cmd 
    #set cmd "write_cfgmem -force -format BIN -interface SMAPx32 -disablebitswap -loadbit \"up 0x00000000 pr_bitstreams/$p.bit\" pr_bitstreams/$p_noswapped"
    #eval $cmd 
}

# Now do the static alone for dual QSPI programming
set    cmd "write_cfgmem -force -format MCS -interface SPIx8 -size 256 -loadbit \"up 0x00000000 pr_bitstreams/${static}.bit"

append cmd "\" pr_bitstreams/pr_over_pcie_prom"

puts $cmd
eval $cmd 


# Now create a report with the sizes
foreach p $partials {
    set ret [file size pr_bitstreams/$p.bin]
    puts "$p : $ret bytes"
}


