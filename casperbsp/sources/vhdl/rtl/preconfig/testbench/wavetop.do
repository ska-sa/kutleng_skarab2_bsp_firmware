onerror { resume }
set curr_transcript [transcript]
transcript off

add wave -vgroup /prconfigcontroller_tb \
	/prconfigcontroller_tb/axis_clk \
	/prconfigcontroller_tb/icap_clk \
	/prconfigcontroller_tb/axis_reset \
	/prconfigcontroller_tb/ICAP_PRDONE \
	/prconfigcontroller_tb/ICAP_PRERROR \
	/prconfigcontroller_tb/ICAP_AVAIL \
	/prconfigcontroller_tb/ICAP_CSIB \
	/prconfigcontroller_tb/ICAP_RDWRB \
	/prconfigcontroller_tb/ICAP_DataOut \
	/prconfigcontroller_tb/ICAP_DataIn \
	/prconfigcontroller_tb/axis_rx_tdata \
	/prconfigcontroller_tb/axis_rx_tvalid \
	/prconfigcontroller_tb/axis_rx_tkeep \
	/prconfigcontroller_tb/axis_rx_tlast \
	/prconfigcontroller_tb/axis_rx_tuser \
	/prconfigcontroller_tb/axis_tx_tpriority_1_pr \
	/prconfigcontroller_tb/axis_tx_tdata_1_pr \
	/prconfigcontroller_tb/axis_tx_tvalid_1_pr \
	/prconfigcontroller_tb/axis_tx_tkeep_1_pr \
	/prconfigcontroller_tb/axis_tx_tlast_1_pr \
	/prconfigcontroller_tb/axis_tx_tready_1_pr \
	/prconfigcontroller_tb/G_SLOT_WIDTH \
	/prconfigcontroller_tb/G_EMAC_ADDR \
	/prconfigcontroller_tb/G_PR_SERVER_PORT \
	/prconfigcontroller_tb/G_IP_ADDR \
	/prconfigcontroller_tb/C_ICAP_CLK_PERIOD \
	/prconfigcontroller_tb/C_CLK_PERIOD
add wave -expand -vgroup /prconfigcontroller_tb/UUT_i/ProtocolCheck_i \
	/prconfigcontroller_tb/UUT_i/ProtocolCheck_i/axis_clk \
	/prconfigcontroller_tb/UUT_i/ProtocolCheck_i/axis_reset \
	( -vgroup InputRingBuffer \
		/prconfigcontroller_tb/UUT_i/ProtocolCheck_i/FilterRingBufferSlotID \
		/prconfigcontroller_tb/UUT_i/ProtocolCheck_i/FilterRingBufferSlotClear \
		/prconfigcontroller_tb/UUT_i/ProtocolCheck_i/FilterRingBufferSlotStatus \
		/prconfigcontroller_tb/UUT_i/ProtocolCheck_i/FilterRingBufferSlotTypeStatus \
		/prconfigcontroller_tb/UUT_i/ProtocolCheck_i/FilterRingBufferDataRead \
		/prconfigcontroller_tb/UUT_i/ProtocolCheck_i/FilterRingBufferByteEnable \
		/prconfigcontroller_tb/UUT_i/ProtocolCheck_i/FilterRingBufferDataIn \
		/prconfigcontroller_tb/UUT_i/ProtocolCheck_i/FilterRingBufferAddress \
	) \
	( -vgroup ICAPRingBuffer \
		/prconfigcontroller_tb/UUT_i/ProtocolCheck_i/ICAPRingBufferSlotID \
		/prconfigcontroller_tb/UUT_i/ProtocolCheck_i/ICAPRingBufferSlotSet \
		/prconfigcontroller_tb/UUT_i/ProtocolCheck_i/ICAPRingBufferSlotStatus \
		/prconfigcontroller_tb/UUT_i/ProtocolCheck_i/ICAPRingBufferSlotType \
		/prconfigcontroller_tb/UUT_i/ProtocolCheck_i/ICAPRingBufferDataWrite \
		/prconfigcontroller_tb/UUT_i/ProtocolCheck_i/ICAPRingBufferByteEnable \
		/prconfigcontroller_tb/UUT_i/ProtocolCheck_i/ICAPRingBufferDataOut \
		( -unsigned /prconfigcontroller_tb/UUT_i/ProtocolCheck_i/ICAPRingBufferAddress ) \
	) \
	( -vgroup Addressing \
		( -literal /prconfigcontroller_tb/UUT_i/ProtocolCheck_i/ClientMACAddress ) \
		( -literal /prconfigcontroller_tb/UUT_i/ProtocolCheck_i/ClientUDPPort ) \
		( -literal /prconfigcontroller_tb/UUT_i/ProtocolCheck_i/ClientIPAddress ) \
		( -literal /prconfigcontroller_tb/UUT_i/ProtocolCheck_i/lDestinationIPAddress ) \
		( -literal /prconfigcontroller_tb/UUT_i/ProtocolCheck_i/lSourceIPAddress ) \
		( -literal /prconfigcontroller_tb/UUT_i/ProtocolCheck_i/lSourceMACAddress ) \
		( -literal /prconfigcontroller_tb/UUT_i/ProtocolCheck_i/lDestinationMACAddress ) \
		( -literal /prconfigcontroller_tb/UUT_i/ProtocolCheck_i/lDestinationUDPPort ) \
		( -literal /prconfigcontroller_tb/UUT_i/ProtocolCheck_i/lSourceUDPPort ) \
	) \
	( -logic /prconfigcontroller_tb/UUT_i/ProtocolCheck_i/ICAPRingBufferDataWrite ) \
	/prconfigcontroller_tb/UUT_i/ProtocolCheck_i/SenderBusy \
	/prconfigcontroller_tb/UUT_i/ProtocolCheck_i/StateVariable \
	( -unsigned /prconfigcontroller_tb/UUT_i/ProtocolCheck_i/lRecvRingBufferSlotID ) \
	( -unsigned /prconfigcontroller_tb/UUT_i/ProtocolCheck_i/lRecvRingBufferAddress ) \
	( -unsigned /prconfigcontroller_tb/UUT_i/ProtocolCheck_i/lSenderRingBufferSlotID ) \
	( -unsigned /prconfigcontroller_tb/UUT_i/ProtocolCheck_i/lSenderRingBufferAddress ) \
	( -unsigned /prconfigcontroller_tb/UUT_i/ProtocolCheck_i/lSenderRingBufferAddressDFrameMax ) \
	( -height 30 -color 0,128,0 -color_waveform -bold /prconfigcontroller_tb/UUT_i/ProtocolCheck_i/lRingBufferData ) \
	/prconfigcontroller_tb/UUT_i/ProtocolCheck_i/lPayloadArray \
	( -height 30 -color 255,0,0 -color_waveform -bold -literal /prconfigcontroller_tb/UUT_i/ProtocolCheck_i/ICAPRingBufferDataOut ) \
	( -height 30 -color 0,0,255 -color_waveform -bold -literal /prconfigcontroller_tb/UUT_i/ProtocolCheck_i/lUDPCheckSum ) \
	( -height 30 -color 255,0,0 -color_waveform -bold -literal /prconfigcontroller_tb/UUT_i/ProtocolCheck_i/lUDPFinalCheckSum ) \
	( -height 30 -color 128,0,128 -color_waveform -literal /prconfigcontroller_tb/UUT_i/ProtocolCheck_i/lPreUDPHDRCheckSum ) \
	( -color 128,0,0 -color_waveform -bold -literal /prconfigcontroller_tb/UUT_i/ProtocolCheck_i/lPRPacketID ) \
	( -unsigned /prconfigcontroller_tb/UUT_i/ProtocolCheck_i/lUDPHeaderCheckSumCounter ) \
	( -unsigned /prconfigcontroller_tb/UUT_i/ProtocolCheck_i/lFinalCheckSumCounter ) \
	( -unsigned -literal /prconfigcontroller_tb/UUT_i/ProtocolCheck_i/lBufferFrameIterations ) \
	( -unsigned -literal /prconfigcontroller_tb/UUT_i/ProtocolCheck_i/lBufferDwordPointer ) \
	( -vgroup Framing \
		/prconfigcontroller_tb/UUT_i/ProtocolCheck_i/lPRPacketID \
		/prconfigcontroller_tb/UUT_i/ProtocolCheck_i/lPRPacketSequence \
		/prconfigcontroller_tb/UUT_i/ProtocolCheck_i/lPRDWordCommand \
		/prconfigcontroller_tb/UUT_i/ProtocolCheck_i/lUDPDataStreamLength \
		/prconfigcontroller_tb/UUT_i/ProtocolCheck_i/lIdentification \
	) \
	( -vgroup ProtocolError \
		/prconfigcontroller_tb/UUT_i/ProtocolCheck_i/ProtocolError \
		/prconfigcontroller_tb/UUT_i/ProtocolCheck_i/ProtocolErrorClear \
		/prconfigcontroller_tb/UUT_i/ProtocolCheck_i/ProtocolErrorID \
		/prconfigcontroller_tb/UUT_i/ProtocolCheck_i/ProtocolIPIdentification \
		/prconfigcontroller_tb/UUT_i/ProtocolCheck_i/ProtocolID \
		/prconfigcontroller_tb/UUT_i/ProtocolCheck_i/ProtocolSequence \
		/prconfigcontroller_tb/UUT_i/ProtocolCheck_i/lProtocolSequence \
		/prconfigcontroller_tb/UUT_i/ProtocolCheck_i/lProtocolIPIdentification \
		/prconfigcontroller_tb/UUT_i/ProtocolCheck_i/lProtocolError \
	) \
	( -vgroup Constants \
		/prconfigcontroller_tb/UUT_i/ProtocolCheck_i/G_SLOT_WIDTH \
		/prconfigcontroller_tb/UUT_i/ProtocolCheck_i/G_ICAP_RB_ADDR_WIDTH \
		/prconfigcontroller_tb/UUT_i/ProtocolCheck_i/G_ADDR_WIDTH \
		/prconfigcontroller_tb/UUT_i/ProtocolCheck_i/C_BUFFER_FRAME_ITERATIONS_MAX \
		/prconfigcontroller_tb/UUT_i/ProtocolCheck_i/C_PACKET_DWORD_POINTER_MAX \
		/prconfigcontroller_tb/UUT_i/ProtocolCheck_i/C_COMMAND_DWORD_POINTER_MAX \
		/prconfigcontroller_tb/UUT_i/ProtocolCheck_i/C_BUFFER_DWORD_POINTER_MAX \
		/prconfigcontroller_tb/UUT_i/ProtocolCheck_i/C_BUFFER_COMMAND_DWORD_POINTER_OFFSET \
		/prconfigcontroller_tb/UUT_i/ProtocolCheck_i/C_BUFFER_COMMAND_DWORD_POINTER_MAX \
		/prconfigcontroller_tb/UUT_i/ProtocolCheck_i/C_UDP_HEADER_CHECKSUM_COUNTER_MAX \
		/prconfigcontroller_tb/UUT_i/ProtocolCheck_i/C_FINAL_CHECKSUM_COUNTER_MAX \
		/prconfigcontroller_tb/UUT_i/ProtocolCheck_i/C_RESPONSE_UDP_PROTOCOL \
		/prconfigcontroller_tb/UUT_i/ProtocolCheck_i/C_CHECKSUM_ERROR \
		/prconfigcontroller_tb/UUT_i/ProtocolCheck_i/C_FRAMING_ERROR \
		/prconfigcontroller_tb/UUT_i/ProtocolCheck_i/C_DWORD_WRITE_COMMAND \
		/prconfigcontroller_tb/UUT_i/ProtocolCheck_i/C_DWORD_READ_COMMAND \
		/prconfigcontroller_tb/UUT_i/ProtocolCheck_i/C_FRAME_WRITE_COMMAND \
		/prconfigcontroller_tb/UUT_i/ProtocolCheck_i/C_DFRAME_WRITE_COMMAND \
		/prconfigcontroller_tb/UUT_i/ProtocolCheck_i/C_DFRAME_LENGTH_MAX \
	)
add wave -vgroup /prconfigcontroller_tb/UUT_i/TXResponder_i \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/icap_clk \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/icap_reset \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/ServerMACAddress \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/ServerIPAddress \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/ServerUDPPort \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/ClientMACAddress \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/ClientIPAddress \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/ClientUDPPort \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/SenderRingBufferSlotID \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/SenderRingBufferSlotSet \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/SenderRingBufferSlotType \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/SenderRingBufferDataWrite \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/SenderRingBufferDataEnable \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/SenderRingBufferDataOut \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/SenderRingBufferAddress \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/SenderBusy \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/ProtocolError \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/ProtocolErrorClear \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/ProtocolErrorID \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/ProtocolIPIdentification \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/ProtocolID \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/ProtocolSequence \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/ICAPWriteDone \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/ICAPWriteResponseSent \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/ICAPIPIdentification \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/ICAPProtocolID \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/ICAPProtocolSequence \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/ICAP_PRDONE \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/ICAP_PRERROR \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/ICAP_Readback \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/StateVariable \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/lRingBufferData \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/lSenderRingBufferSlotID \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/lSenderRingBufferAddress \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/lDestinationMACAddress \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/lSourceMACAddress \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/lEtherType \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/lIPVIHL \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/lDSCPECN \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/lTotalLength \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/lIdentification \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/lFlagsOffset \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/lTimeToLeave \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/lProtocol \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/lIPHeaderChecksum \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/lSourceIPAddress \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/lDestinationIPAddress \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/lSourceUDPPort \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/lDestinationUDPPort \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/lUDPDataStreamLength \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/lUDPCheckSum \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/lPRPacketID \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/lPRPacketSequence \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/lPRDWordCommand \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/lIPHDRCheckSum \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/lPreIPHDRCheckSum \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/lUDPHDRCheckSum \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/lPreUDPHDRCheckSum \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/lServerMACAddress \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/lServerMACAddressChanged \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/lServerIPAddress \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/lServerIPAddressChanged \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/lServerUDPPort \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/lServerUDPPortChanged \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/lClientMACAddress \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/lClientMACAddressChanged \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/lClientIPAddress \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/lClientIPAddressChanged \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/lClientUDPPort \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/lClientUDPPortChanged \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/lAddressingChanged \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/lICAP_PRDONE \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/lICAP_PRERROR \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/lProtocolErrorStatus \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/lIPIdentification \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/lPacketID \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/lPacketSequence \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/lPacketDWORDCommand \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/lCheckSumCounter \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/G_SLOT_WIDTH \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/G_ADDR_WIDTH \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/C_DWORD_MAX \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/C_RESPONSE_UDP_LENGTH \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/C_RESPONSE_IPV4_LENGTH \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/C_RESPONSE_ETHER_TYPE \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/C_RESPONSE_IPV4IHL \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/C_RESPONSE_DSCPECN \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/C_RESPONSE_FLAGS_OFFSET \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/C_RESPONSE_TIME_TO_LEAVE \
	/prconfigcontroller_tb/UUT_i/TXResponder_i/C_RESPONSE_UDP_PROTOCOL
add wave -vgroup /prconfigcontroller_tb/UUT_i/ICAPWRSM_i \
	/prconfigcontroller_tb/UUT_i/ICAPWRSM_i/icap_clk \
	/prconfigcontroller_tb/UUT_i/ICAPWRSM_i/icap_reset \
	/prconfigcontroller_tb/UUT_i/ICAPWRSM_i/RingBufferSlotID \
	/prconfigcontroller_tb/UUT_i/ICAPWRSM_i/RingBufferSlotClear \
	/prconfigcontroller_tb/UUT_i/ICAPWRSM_i/RingBufferSlotStatus \
	/prconfigcontroller_tb/UUT_i/ICAPWRSM_i/RingBufferSlotTypeStatus \
	/prconfigcontroller_tb/UUT_i/ICAPWRSM_i/RingBufferDataRead \
	/prconfigcontroller_tb/UUT_i/ICAPWRSM_i/RingBufferDataEnable \
	/prconfigcontroller_tb/UUT_i/ICAPWRSM_i/RingBufferDataIn \
	/prconfigcontroller_tb/UUT_i/ICAPWRSM_i/RingBufferAddress \
	/prconfigcontroller_tb/UUT_i/ICAPWRSM_i/SenderBusy \
	/prconfigcontroller_tb/UUT_i/ICAPWRSM_i/ICAPWriteDone \
	/prconfigcontroller_tb/UUT_i/ICAPWRSM_i/ICAPWriteResponseSent \
	/prconfigcontroller_tb/UUT_i/ICAPWRSM_i/ICAPIPIdentification \
	/prconfigcontroller_tb/UUT_i/ICAPWRSM_i/ICAPProtocolID \
	/prconfigcontroller_tb/UUT_i/ICAPWRSM_i/ICAPProtocolSequence \
	/prconfigcontroller_tb/UUT_i/ICAPWRSM_i/ICAP_CSIB \
	/prconfigcontroller_tb/UUT_i/ICAPWRSM_i/ICAP_RDWRB \
	/prconfigcontroller_tb/UUT_i/ICAPWRSM_i/ICAP_AVAIL \
	/prconfigcontroller_tb/UUT_i/ICAPWRSM_i/ICAP_DataIn \
	/prconfigcontroller_tb/UUT_i/ICAPWRSM_i/ICAP_DataOut \
	/prconfigcontroller_tb/UUT_i/ICAPWRSM_i/ICAP_Readback \
	/prconfigcontroller_tb/UUT_i/ICAPWRSM_i/StateVariable \
	/prconfigcontroller_tb/UUT_i/ICAPWRSM_i/lFrameDWORDCounter \
	/prconfigcontroller_tb/UUT_i/ICAPWRSM_i/lCommandHeader \
	/prconfigcontroller_tb/UUT_i/ICAPWRSM_i/lCommandSequence \
	/prconfigcontroller_tb/UUT_i/ICAPWRSM_i/lCommandDWORD \
	/prconfigcontroller_tb/UUT_i/ICAPWRSM_i/lFrameDWORD \
	/prconfigcontroller_tb/UUT_i/ICAPWRSM_i/lRecvRingBufferSlotID \
	/prconfigcontroller_tb/UUT_i/ICAPWRSM_i/lRecvRingBufferAddress \
	/prconfigcontroller_tb/UUT_i/ICAPWRSM_i/G_SLOT_WIDTH \
	/prconfigcontroller_tb/UUT_i/ICAPWRSM_i/G_ADDR_WIDTH \
	/prconfigcontroller_tb/UUT_i/ICAPWRSM_i/C_ICAP_NOP_COMMAND \
	/prconfigcontroller_tb/UUT_i/ICAPWRSM_i/C_FRAME_DWORD_MAX
wv.cursors.add -time 2550ns+0 -name {Default cursor}
wv.cursors.setactive -name {Default cursor}
wv.zoom.range -from 2050ns -to 2312502ps
wv.time.unit.auto.set
transcript $curr_transcript
