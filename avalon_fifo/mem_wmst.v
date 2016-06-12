/*
* Created           : mny
* Date              : 201603
*/

// synposys translate_off
`timescale 1ns/100ps
// synposys translate_on

module mem_wmst (
    input  wire         write_control_fixed_location  ,  //   write_0_control.fixed_location
    input  wire [31:0]  write_control_write_base      ,      //                  .write_base
    input  wire [31:0]  write_control_write_length    ,    //                  .write_length
    input  wire         write_control_go              ,              //                  .go
    output wire         write_control_done            ,            //                  .done
    input  wire         write_user_write_buffer       ,       //      write_0_user.write_buffer
    input  wire [127:0] write_user_buffer_input_data  ,  //                  .buffer_input_data
    output wire         write_user_buffer_full        ,// 
    
    output reg          wreq,
    input               wrdy,
    
    output              wena,
    output       [31:0] waddr,
    output      [127:0] wdata,
    
    input           clk,
    input           rst
);

reg             [31:0] len;
reg             [31:0] addr;
reg                    ena;
reg                    done;
wire                   read;
wire           [127:0] q;
reg            [127:0] data;

assign wena     = ena;
assign waddr    = addr;
assign write_control_done = done;
assign wdata    = data;

always @ ( posedge clk or posedge rst )
    if( rst == 1'b1 )
        len <= 'd0;
    else if( write_control_go )
        len <= write_control_write_length >> 4;
    else if( read )
        len <= len - 'd1;

assign read = (len > 'd0) & wrdy;
always @ ( posedge clk )
    if( read )
        ena <= 'd1;
    else
        ena <= 'd0;
always @ ( posedge clk )
    if( read )
        data <= q;
        
always @ ( posedge clk )
    if( write_control_go )
        wreq <= 1'b1;
    else if( len == 'd0 )
        wreq <= 1'b0;

always @ ( posedge clk )
    if( write_control_go )
        addr <= write_control_write_base >> 4;
    else if( wena )
        addr <= addr + 'd1;
always @ ( posedge clk or posedge rst )
    if( rst == 1'b1 )
        done <= 1'b1;
    else if( write_control_go )
        done <= 1'b0;
    else if( len == 0 )
        done <= 1'b1;

scfifo	SCFF (
    .aclr           ( rst ),
    .clock          ( clk ),
    .data           ( write_user_buffer_input_data ),
    .rdreq          ( read ),
    .sclr           ( 1'b0 ),
    .wrreq          ( write_user_write_buffer ),
    .almost_empty   ( ),
    .almost_full    ( write_user_buffer_full ),
    .empty          ( ),
    .full           ( ),
    .q              ( q ),
    .usedw          ( ),
    .eccstatus ());
defparam
    SCFF.add_ram_output_register = "OFF",
    SCFF.almost_empty_value = 8,
    SCFF.almost_full_value = 250,
    SCFF.intended_device_family = "Cyclone V",
    SCFF.lpm_hint = "RAM_BLOCK_TYPE=M10K",
    SCFF.lpm_numwords = 256,
    SCFF.lpm_showahead = "ON",
    SCFF.lpm_type = "scfifo",
    SCFF.lpm_width = 128,
    SCFF.lpm_widthu = 8,
    SCFF.overflow_checking = "ON",
    SCFF.underflow_checking = "ON",
    SCFF.use_eab = "ON";

   
endmodule
