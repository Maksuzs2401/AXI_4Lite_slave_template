`timescale 1ns / 1ps

module axi_4_lite_tb();
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
    wire [3:0] LED_out;
    reg [3:0]  SW_in;

    // Instantiate the DUT
    axi_4_lite # (
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
        .AXI_rready(AXI_rready),
        .LED(LED_out),
        .SW(SW_in)
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

        // -------------------------------------------------------
        // TEST CASE 1: WRITE "0xADDBCFFE" to Register 0 (Addr 0x0)
        // -------------------------------------------------------
        $display("Starting Write Transaction...");
        
        AXI_awaddr = 4'h0;
        AXI_awvalid = 1;
        AXI_wdata = 32'hADDBCFFE;
        AXI_wstrb = 4'b1111; 
        AXI_wvalid = 1;
        AXI_bready = 1; 

        // Wait for Slave to accept Address
        wait(AXI_wready && AXI_awready); 
        @(posedge AXI_aclk); 
        
        AXI_awvalid <= 0;
        AXI_wvalid <= 0;

        // Wait for Response
        wait(AXI_bvalid);
        @(posedge AXI_aclk);
        AXI_bready = 0; 
        
        $display("Write Transaction Complete.");
        #20;
        if (LED_out == 4'b1110) 
            $display("SUCCESS: LEDs match last digit 'E' (Value: %b)", LED_out);
        else 
            $display("FAILURE: LEDs are wrong! Expected 1110, got %b", LED_out);

        // -------------------------------------------------------
        // TEST CASE 2: READ from Register 0 (Addr 0x0)
        // -------------------------------------------------------
        $display("Starting Read Transaction...");
        
        AXI_areadaddr = 4'h0;
        AXI_arvalid = 1;
        
        // *** KEY CHANGE: Keep Ready LOW initially ***
        // This forces the Slave to HOLD the valid signal until we are ready.
        AXI_rready = 0; 

        // 1. Wait for Address Handshake
        wait(AXI_arready);
        @(posedge AXI_aclk);
        AXI_arvalid <= 0; 

        // 2. Wait for Data Valid (The slave will wait for us now)
        wait(AXI_rvalid);
        @(posedge AXI_aclk);
        
        // 3. Check Data
        if (AXI_rdata == 32'hADDBCFFE) 
            $display("SUCCESS: Read Data Matches Written Data (0xADDBCFFE)");
        else 
            $display("FAILURE: Read Data (0x%h) != Expected (0xADDBCFFE)", AXI_rdata);
            
        // 4. Complete the Handshake (Assert Ready for 1 cycle)
        AXI_rready <= 1;
        @(posedge AXI_aclk);
        AXI_rready <= 0;
        
        // -------------------------------------------------------
        // TEST CASE 3: READ SWITCHES (Register 1 / Addr 0x4)
        // -------------------------------------------------------
        $display("\n--- Starting Switch Read Transaction ---");
        
        SW_in = 4'b1001; 
        
        AXI_areadaddr = 4'h4; 
        AXI_arvalid   = 1;
        AXI_rready    = 0; // Keep Low initially

        // 1. Wait for Address Handshake
        wait(AXI_arready);
        @(posedge AXI_aclk);
        AXI_arvalid <= 0;

        // 2. Wait for Data Valid
        wait(AXI_rvalid);
        @(posedge AXI_aclk);
        
        // 3. Check Data
        // Note: Switches are in lower bits. 
        if (AXI_rdata[3:0] == 4'b1001) 
            $display("SUCCESS: Read Switches correctly! Value: %b", AXI_rdata[3:0]);
        else 
            $display("FAILURE: Expected 1001, got %b", AXI_rdata[3:0]);  
        
        // 4. Complete Handshake
        AXI_rready <= 1;
        @(posedge AXI_aclk);
        AXI_rready <= 0;
        
        #50;
        $finish;
    end
endmodule