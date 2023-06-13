`timescale 1ns / 1ps
/*********************************************************************
 * Filename :    spi_fifo.sv
 * Date     :    02-05-2023
 * Author   :    Shehzeen Malik
 *
 * Description:  FIFO for SPI Circuit
 *********************************************************************/

`ifndef VERILATOR
`include "../../defines/UETRV_PCore_ISA.svh"
`include "../../defines/SPI_defs.svh"
`else
`include "UETRV_PCore_ISA.svh"
`include "SPI_defs.svh"
`endif

module spi_fifo (
    input  logic                                clk,
    input  logic                                rst_n,

    input  logic [7:0]                          data_in,
    output logic [7:0]                          data_out,
 
    // Data_count in fifo
    output logic [ADDR_FIFO:0]                  data_count,
    input  logic                                fifo_en,
 
    // Read and write requests
    input  logic                                fifo_read,
    input  logic                                fifo_write,
 
    // Flags
    output logic                                fifo_full,
    output logic                                fifo_empty
);


// Fifo
logic [7:0]                 fifo_buffer[DEPTH_FIFO-1:0];

// Fifo pointers for read and write operations
logic [ADDR_FIFO-1:0]       read_ptr , write_ptr; 


// Flags update
assign fifo_empty = (data_count == 0);
assign fifo_full  = (data_count == DEPTH_FIFO[ADDR_FIFO:0]);

// Fifo operation
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        read_ptr   <= '0;
        write_ptr  <= '0;
        data_count <= '0;
        data_out   <= '0;

        for (int i = 0; i < DEPTH_FIFO; i = i+1)
            fifo_buffer[i] <= '0;
    end else if (fifo_en) begin
        // Write operation
        if (fifo_write && !fifo_full) begin
            fifo_buffer [write_ptr] <= data_in;
            data_count              <= data_count + 1;
            write_ptr               <= write_ptr + 1;
        end

        if (write_ptr == 3'h7)      //DEPTH_FIFO[ADDR_FIFO-1:0])
            write_ptr <= '0;
        
        // Read operation
        if (fifo_read && !fifo_empty) begin
            data_out   <= fifo_buffer [read_ptr];
            read_ptr   <= read_ptr + 1;
            data_count <= data_count - 1;
        end

        if (read_ptr == DEPTH_FIFO[ADDR_FIFO-1:0])
                read_ptr <= '0;
    end
end

endmodule