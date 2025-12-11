`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.12.2025 11:21:40
// Design Name: 
// Module Name: axi_4lite_tb
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


module axi_4lite_tb();
    // Parameters
    parameter integer AXI_Dwidth = 32;
    parameter integer AXI_Addrwidth = 4;

    // Signals
    reg AXI_aclk;
    reg AXI_aresetn;
    reg [AXI_Addrwidth-1:0] AXI_awaddr;
    reg [AXI_Dwidth-1:0] AXI_wdata;
    reg [(AXI_Dwidth/8)-1:0] AXI_wstrb;
    reg AXI_wvalid;
    wire AXI_wready;
    wire AXI_awready;
    wire [1:0] AXI_bresp;
    wire AXI_bvalid;
    reg AXI_bready;
    
    reg [AXI_Addrwidth-1:0] AXI_areadaddr;
    reg [2:0] AXI_arprotect;
    reg AXI_awvalid;
    reg AXI_arvalid;
    wire AXI_arready;
    wire [AXI_Dwidth-1:0] AXI_rdata;
    wire [1:0] AXI_rresp;
    wire AXI_rvalid;
    reg AXI_rready;

    // Instantiate the DUT (Device Under Test)
    axi_4lite # (
        .AXI_Dwidth(AXI_Dwidth),
        .AXI_Addrwidth(AXI_Addrwidth)
    ) dut (
        .AXI_aclk(AXI_aclk),
        .AXI_aresetn(AXI_aresetn),
        .AXI_awaddr(AXI_awaddr),
        .AXI_wdata(AXI_wdata),
        .AXI_wstrb(AXI_wstrb),
        .AXI_wvalid(AXI_wvalid),
        .AXI_awready(AXI_awready),
        .AXI_wready(AXI_wready),
        .AXI_bresp(AXI_bresp),
        .AXI_bvalid(AXI_bvalid),
        .AXI_bready(AXI_bready),
        .AXI_areadaddr(AXI_areadaddr),
        .AXI_arprotect(AXI_arprotect),
        .AXI_awvalid(AXI_awvalid),
        .AXI_arvalid(AXI_arvalid),
        .AXI_arready(AXI_arready),
        .AXI_rdata(AXI_rdata),
        .AXI_rresp(AXI_rresp),
        .AXI_rvalid(AXI_rvalid),
        .AXI_rready(AXI_rready)
    );

    // Clock Generation (100MHz equivalent)
    always #5 AXI_aclk = ~AXI_aclk;

    initial begin
        // 1. Initialize Signals
        AXI_aclk = 0;
        AXI_aresetn = 0;
        AXI_awaddr = 0;
        AXI_wdata = 0;
        AXI_wstrb = 0;
        AXI_wvalid = 0;
        AXI_bready = 0;
        AXI_areadaddr = 0;
        AXI_arprotect = 0;
        AXI_awvalid = 0;
        AXI_arvalid = 0;
        AXI_rready = 0;

        // 2. Reset Pulse
        #20 AXI_aresetn = 1; 
        #10;

        // =======================================================
        // TEST CASE 1: WRITE "0xDEADBEEF" to Register 0 (Addr 0x0)
        // =======================================================
        $display("Starting Write Transaction...");
        
        // Setup Address and Data
        AXI_awaddr = 4'h0;
        AXI_awvalid = 1;
        
        AXI_wdata = 32'hDEADBEEF;
        AXI_wstrb = 4'b1111; // All bytes valid
        AXI_wvalid = 1;
        AXI_bready = 1; // We are ready for response

        // Wait for Slave to accept Address
        wait(AXI_wready && AXI_awready); 
        @(posedge AXI_aclk); // Hold for one clock edge
        
        // Deassert Valid signals
        AXI_awvalid <= 0;
        AXI_wvalid <= 0;

        // Wait for Response (BVALID)
        wait(AXI_bvalid);
        @(posedge AXI_aclk);
        AXI_bready = 0; // Transaction Done
        
        $display("Write Transaction Complete.");
        #20;

        // =======================================================
        // TEST CASE 2: READ from Register 0 (Addr 0x0)
        // =======================================================
        $display("Starting Read Transaction...");
        
        AXI_areadaddr = 4'h0;
        AXI_arvalid = 1;
        AXI_rready = 1; // We are ready for data

        // Wait for Slave to accept address
        wait(AXI_arready);
        @(posedge AXI_aclk);
        AXI_arvalid = 0; // Clear address valid

        // Wait for Data Valid
        wait(AXI_rvalid);
        @(posedge AXI_aclk);
        
        // CHECK RESULT
        if (AXI_rdata == 32'hDEADBEEF) 
            $display("SUCCESS: Read Data Matches Written Data (0xDEADBEEF)");
        else 
            $display("FAILURE: Read Data (0x%h) != Expected (0xDEADBEEF)", AXI_rdata);
            
        AXI_rready = 0;
        
        #50;
        $finish;
    end

endmodule
