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


    logic [DATA_WIDTH-1:0] FIFO_MEM [NR_ENTRIES-1:0];

    logic [$clog2(NR_ENTRIES) - 1:0] head_ptr_d, head_ptr_q;
    logic [$clog2(NR_ENTRIES) - 1:0] tail_ptr_d, tail_ptr_q; 
    logic [$clog2(NR_ENTRIES) :0] data_count_d, data_count_q; 

    logic push_en, pop_en;        // Write Enable signal generated iff FIFO is not full
    logic full_d, full_q;        // Full signal
    logic valid_d, valid_q;       // Empty signal


    // Write and Read Enables internal
    assign push_en = push_i && (!full_q || (full_q && pop_i));
    assign pop_en = pop_i && valid_q; // || (!valid_q && push_i));

    // assing full = (data_count_d == (NR_ENTRIES - 1));
    // assing valid = (data_count_d == (0));

    assign valid_o = valid_q;
    assign full_o = full_q;

    // assign data_o = FIFO_MEM[head_ptr_d];

    integer i = 0;

    always_comb begin
        //combinational nets

        // registers
        head_ptr_d = head_ptr_q;
        tail_ptr_d = tail_ptr_q;
        data_count_d = data_count_q;
        full_d = full_q;
        valid_d = valid_q;
        
        // Counter logic, if both read and write not change in amount of data
        if( pop_en ) begin // There was a read

            if(head_ptr_d == (NR_ENTRIES - 1) ) begin
                head_ptr_d = 0;
            end
            else begin 
                head_ptr_d = head_ptr_d + 1;
                
            end
          
            full_d = 1'b0;

            if((head_ptr_d == tail_ptr_d) && (data_count_d == (0))) begin
                $display("Empty, head: %d, tail: %d.", head_ptr_d, tail_ptr_d);
                valid_d = 1'b0; // We are now empty
            end 
            else begin 
                data_count_d = data_count_d - 1'b1;
            end
  
        end
        if(push_en) begin // There was a write
            if(tail_ptr_d == (NR_ENTRIES - 1) ) begin
                tail_ptr_d = 0;
            end
            else begin  
                tail_ptr_d = tail_ptr_d + 1;
            end

            
            valid_d = 1'b1;

            if((head_ptr_d == tail_ptr_d) && (data_count_d == (NR_ENTRIES - 1))) begin
                $display("Full, head: %d, tail: %d.", head_ptr_d, tail_ptr_d);
                full_d = 1'b1;
            end
            else begin 
                data_count_d = data_count_d + 1'b1;
            end
        end

        if (push_en && pop_en) begin
            $display("Push+pop, head: %d, tail: %d.", head_ptr_d, tail_ptr_d);

            if((head_ptr_d == tail_ptr_d) && (data_count_d == (NR_ENTRIES - 1))) begin // Push after pop, when full
                full_d = 1'b1;
            end
            if((data_count_d != (0))) begin // Push after pop, when empty
                valid_d = 1'b1; // We are now empty
            end 
            else begin
                data_count_d = data_count_d;
            end
        end

    end

    always_ff @(posedge clk_i or posedge rst_i) begin

        head_ptr_q <= head_ptr_d;
        tail_ptr_q <= tail_ptr_d;
        full_q <= full_d;
        valid_q <= valid_d;
        data_count_q <= data_count_d;
        data_o <= 'x;

        // handle reset/flush/disable
        if(rst_i) begin
            head_ptr_q <= 0;
            tail_ptr_q <= 0;
            data_count_q <= 0;
            full_q <= 0;
            valid_q <= 0;
            for (i = 0; i < NR_ENTRIES; i++) begin
                FIFO_MEM[i] <= '0;
            end
            data_o <= 'x;
        end
        else begin
            if(pop_en) begin  
                data_o <= FIFO_MEM[head_ptr_q];
                $display("Popping %d, head_ptr: %d.", data_o, head_ptr_q );
                $display("Num: %d.", data_count_q );
            end               
            if(push_en) begin
                $display("Pushing %d, tail_ptr: %d.", data_i, tail_ptr_q );
                $display("Num: %d.", data_count_q );
                FIFO_MEM[tail_ptr_q] <= data_i;

            end
        end


    end


endmodule
