`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.12.2025 13:14:16
// Design Name: 
// Module Name: axi_4_lite
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module axi_4_lite #( 
  parameter integer   AXI_Dwidth = 32,
  parameter integer   AXI_Addrwidth = 4)(
  //----- Global Signals-----//
  input wire          AXI_aclk,
  input wire          AXI_aresetn,
  //----- Write Address Channel-----//
  input wire[AXI_Addrwidth-1:0] AXI_awaddr,
  output wire         AXI_awready,
  input wire          AXI_awvalid,
  //----- Write Data Channel-----//
  input wire[AXI_Dwidth-1:0] AXI_wdata,
  input wire[(AXI_Dwidth/8)-1:0] AXI_wstrb,
  input wire          AXI_wvalid,
  output wire         AXI_wready,
  //----- Write Response Channel-----//
  output wire         [1:0] AXI_bresp,
  output wire         AXI_bvalid,
  input wire          AXI_bready, 
  //----- Read Address Channel-----//
  input wire[AXI_Addrwidth-1:0] AXI_areadaddr,
  input wire[2:0]     AXI_arprotect,
  input wire          AXI_arvalid,
  output wire         AXI_arready,
  //----- Read Data Channel-----//
  output wire[AXI_Dwidth-1:0] AXI_rdata,
  output wire[1:0]    AXI_rresp,
  output wire         AXI_rvalid,
  input wire          AXI_rready,
  //----- Board Ports------//
  output wire[3:0]    LED,
  input wire [3:0]    SW);
  //----- Internal Signals-----//
  reg                 axi_awready;
  reg                 axi_wready;
  reg                 [1:0] axi_bresp;
  reg                 axi_bvalid;
  reg                 axi_arready;
  reg                 [AXI_Dwidth-1 : 0] axi_rdata;
  reg                 [1:0] axi_rresp;
  reg                 axi_rvalid;
  //----- Latch regs-----//
  reg                 aw_en;
  reg                 [AXI_Addrwidth-1:0] axi_awaddr; // address latch
  reg                 [AXI_Addrwidth-1:0] axi_araddr_latch;
    // --- 2. User Registers (The actual storage) ---
    // 4 registers of 32-bits each
  reg                 [AXI_Dwidth-1:0] slv_reg0;  //0x0
  reg                 [AXI_Dwidth-1:0] slv_reg1;  //0x4
  reg                 [AXI_Dwidth-1:0] slv_reg2;  //0x8
  reg                 [AXI_Dwidth-1:0] slv_reg3;  //0xC
  
  //--- Connecting internal regs with output ports---//
  assign AXI_awready = axi_awready;
  assign AXI_wready  = axi_wready;
  assign AXI_bresp   = axi_bresp;
  assign AXI_bvalid  = axi_bvalid;
  assign AXI_arready = axi_arready;
  assign AXI_rdata   = axi_rdata;
  assign AXI_rresp   = axi_rresp;
  assign AXI_rvalid  = axi_rvalid;
  
  
  //*** 1. Write Address Handshake (AWREADY)***
  always @(posedge AXI_aclk)begin
    if(AXI_aresetn==1'b0)begin
      axi_awready <= 1'b0;
      aw_en <= 1'b1;
      axi_awaddr <= 0;
      slv_reg0 <= 0;
      slv_reg1 <= 0;
      slv_reg2 <= 0;
      slv_reg3 <= 0;
    end
    else begin
      if(~axi_awready && AXI_awvalid && aw_en)begin
        axi_awready <= 1'b1;
        aw_en <= 1'b0;
        axi_awaddr <= AXI_awaddr;
      end
    else if (~axi_awready && AXI_awvalid && aw_en)begin
      axi_awready <= 1'b1;
      aw_en <= 1'b0;
      axi_awaddr <= AXI_awaddr;
    end
    else if (AXI_bready && axi_bvalid) begin
      aw_en <= 1'b1; // Transaction complete, ready for next address
      axi_awready <= 1'b0;
    end
    else begin
      axi_awready <= 1'b0;
    end
  end
end
  //*** 2. Write Channel Handshake (WREADY)***
  always @(posedge AXI_aclk)begin
    if(AXI_aresetn==1'b0)begin
      axi_wready <= 1'b0;
      //axi_awaddr <= 1'b0;
    end
    else begin
      if(~AXI_wready && AXI_wvalid && ((!aw_en)||(aw_en && AXI_awvalid)))begin
      axi_wready <= 1'b1;
    end
    else if (~axi_wready && AXI_wvalid)begin
      axi_wready <= 1'b1;
    end 
    else begin
      axi_wready <= 1'b0;
    end
  end
end

  //*** 3. Actual Write***
  always @(posedge AXI_aclk)begin
    if(AXI_aresetn==1'b0)begin
    slv_reg0 <= 0;
    slv_reg1 <= 0;
    slv_reg2 <= 0;
    slv_reg3 <= 0;
    end
    else if (axi_wready && AXI_wvalid)begin
    case (axi_awaddr[3:2])
                2'h0: // Write to Register 0
                    begin
                        if (AXI_wstrb[0] == 1'b1) slv_reg0[7:0]   <= AXI_wdata[7:0];
                        if (AXI_wstrb[1] == 1'b1) slv_reg0[15:8]  <= AXI_wdata[15:8];
                        if (AXI_wstrb[2] == 1'b1) slv_reg0[23:16] <= AXI_wdata[23:16];
                        if (AXI_wstrb[3] == 1'b1) slv_reg0[31:24] <= AXI_wdata[31:24];
                    end
                2'h1: // Write to Register 1
                    begin
                        if (AXI_wstrb[0] == 1'b1) slv_reg1[7:0]   <= AXI_wdata[7:0];
                        if (AXI_wstrb[1] == 1'b1) slv_reg1[15:8]  <= AXI_wdata[15:8];
                        if (AXI_wstrb[2] == 1'b1) slv_reg1[23:16] <= AXI_wdata[23:16];
                        if (AXI_wstrb[3] == 1'b1) slv_reg1[31:24] <= AXI_wdata[31:24];
                    end
                2'h2: // Write to Register 2
                     begin
                        if (AXI_wstrb[0] == 1'b1) slv_reg2[7:0]   <= AXI_wdata[7:0];
                        if (AXI_wstrb[1] == 1'b1) slv_reg2[15:8]  <= AXI_wdata[15:8];
                        if (AXI_wstrb[2] == 1'b1) slv_reg2[23:16] <= AXI_wdata[23:16];
                        if (AXI_wstrb[3] == 1'b1) slv_reg2[31:24] <= AXI_wdata[31:24];
                    end
                2'h3: // Write to Register 3
                    begin
                        if (AXI_wstrb[0] == 1'b1) slv_reg3[7:0]   <= AXI_wdata[7:0];
                        if (AXI_wstrb[1] == 1'b1) slv_reg3[15:8]  <= AXI_wdata[15:8];
                        if (AXI_wstrb[2] == 1'b1) slv_reg3[23:16] <= AXI_wdata[23:16];
                        if (AXI_wstrb[3] == 1'b1) slv_reg3[31:24] <= AXI_wdata[31:24];
                    end
                 default: begin
                 end
               endcase
             end
           end
           
  //*** 4. Write Response (BVALID/BRESP)***
  always @(posedge AXI_aclk)begin
    if(AXI_aresetn==1'b0)begin
      axi_bvalid <= 0;
      axi_bresp <= 2'b0;
    end
    else begin
      if(~axi_bvalid && axi_wready && AXI_wvalid)
      begin
      axi_bvalid <= 1'b1;
      axi_bresp <= 2'b0;
      end
      else if (AXI_bready && axi_bvalid)begin
      axi_bvalid <= 1'b0;
      end
    end
  end
  
  //*** 5. Read Address Handshake***
  always @(posedge AXI_aclk)begin
    if(AXI_aresetn == 1'b0)begin
      axi_arready <= 1'b0;
      //axi_rvalid <= 1'b0;
      axi_araddr_latch <= 0;
      //axi_rresp <= 0;    
      end
    else begin
    if(~axi_arready && AXI_arvalid)begin
      axi_arready <= 1'b1;
      axi_araddr_latch <= AXI_areadaddr;
    end 
    else begin 
      axi_arready <= 1'b0;
    end
  end
end

  //*** 6. Read Data Handling (RVALID/RRESP)***
  always @(posedge AXI_aclk)begin
    if(AXI_aresetn==1'b0)begin
      axi_rvalid <= 0;
      axi_rresp  <= 0;
    end
    else begin
      if (axi_arready && AXI_arvalid && ~axi_rvalid) begin
        axi_rvalid <= 1'b1; // Data is now valid!
        axi_rresp  <= 2'b0; // OKAY Response
      end
      else if (axi_rvalid && AXI_rready) begin
        axi_rvalid <= 1'b0;
      end
    end
  end
  
  //*** 7. Output Register Logic***
  always @(*)begin
    case (axi_araddr_latch[3:2])
      2'h0   : axi_rdata = slv_reg0;
      2'h1   : axi_rdata = {28'b0, SW};
      2'h2   : axi_rdata = slv_reg2;
      2'h3   : axi_rdata = slv_reg3;
      default: axi_rdata = 0;
    endcase
  end
  //*** Connect lower 4 regs to physical ports on chip.
  assign LED = slv_reg0[3:0];
endmodule

