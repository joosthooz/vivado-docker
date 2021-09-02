#!/bin/bash

echo "Extracting Vivado Installer..."
cd /opt/ && tar -zf Xilinx_Vivado_Vitis_Update_2019.2.1_1205_0436.tar.gz && chmod +x /opt/Xilinx_Vivado_Vitis_Update_2019.2.1_1205_0436/xsetup
echo "Running Vivado Installer in Batch mode..."
/opt/Xilinx_Vivado_Vitis_Update_2019.2.1_1205_0436/xsetup --agree XilinxEULA,3rdPartyEULA,WebTalkTerms --batch Install --config /opt/install_config.txt