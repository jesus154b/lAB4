/*
 * File: ucsbece154b_fifo.sv
 * Description: Part 2 Code by Jesus Oviedo 9447947
 * Reference material used: https://www.instructables.com/Designing-a-Synchronous-FIFO-in-RTL/
 */

module ucsbece154b_fifo #(
    parameter int unsigned DATA_WIDTH = 32,
    parameter int unsigned NR_ENTRIES = 4
) (
    input   logic                   clk_i,
    input   logic                   rst_i,

    output  logic [DATA_WIDTH-1:0]  data_o,
    input   logic                   pop_i,

    input   logic [DATA_WIDTH-1:0]  data_i,
    input   logic                   push_i,

    output  logic                   full_o,
    output  logic                   valid_o
);


    logic [DATA_WIDTH-1:0] RAM [0:NR_ENTRIES-1];

    logic [$clog2(NR_ENTRIES) - 1:0] head_ptr;
    logic [$clog2(NR_ENTRIES) - 1:0] tail_ptr; 
    logic [$clog2(NR_ENTRIES) - 1:0] data_count; 

    logic push_en;        // Write Enable signal generated iff FIFO is not full
    logic pop_en;        // Read Enable signal generated iff FIFO is not empty
    logic fifo_full;        // Full signal
    logic fifo_empty;       // Empty signal

    always_ff @( posedge clk_i or negedge rst_i ) begin : q_Block
        if(!rst_i) begin
            RAM <= '{default: '0};
            head_ptr <= 0;
            tail_ptr <= 0;
            data_count <= 0;
        end
        else begin

            // Pop Logic
            if(pop_en) begin
                data_o <= RAM[head_ptr];

                if(head_ptr == (NR_ENTRIES - 1)) begin
                    head_ptr <= 0;
                end
                else begin
                    head_ptr <= head_ptr + 1;
                end
            end

            // Push Logic
            if(push_en) begin
                RAM[tail_ptr] <= data_i;

                if(tail_ptr == (NR_ENTRIES - 1)) begin
                    tail_ptr <= 0;
                end
                else begin
                    tail_ptr <= tail_ptr + 1;
                end
            end

            // Counter logic, if both read and write not change in amount of data
            if(push_en && !pop_en) begin // There was a write
                data_count <= data_count + 1;
            end
            else if(!push_en && pop_en) begin // There was a read
                data_count <= data_count - 1;
            end
            
        end
    end

    // Write and Read Enables internal
    assign push_en = push_i & !fifo_full;  
    assign pop_en = pop_i & !fifo_empty;

    // Full and Empty to output
    assign full_o = fifo_full;
    assign valid_o  = fifo_empty;
    
    // Full and Empty internal
    assign fifo_full = (data_count == NR_ENTRIES) ? 1'b1 : 0;
    assign fifo_empty = (data_count == 0) ? 1'b1 : 0;

    

endmodule
