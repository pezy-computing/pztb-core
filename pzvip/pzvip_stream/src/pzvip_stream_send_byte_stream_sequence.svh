class pzvip_stream_send_byte_stream_sequence extends pzvip_stream_sequence;
  rand  int   length;
  rand  byte  bytes[];

  constraint c_valid_length {
    length > 0;
  }

  constraint c_valid_bytes {
    solve length before bytes;
    bytes.size() == length;
  }

  task body();
    int               byte_width;
    int               word_length;
    pzvip_stream_item stream_item;

    byte_width  = configuration.data_width / 8;
    word_length = (length + byte_width - 1) / byte_width;

    `uvm_create(stream_item)
    stream_item.length      = word_length;
    stream_item.data        = new[word_length];
    stream_item.byte_enable = new[word_length];
    stream_item.delay       = new[word_length];

    for (int i = 0;i < word_length;++i) begin
      for (int j = 0;j < byte_width;++j) begin
        int byte_index;
        byte_index  = byte_width * i + j;
        if (byte_index < length) begin
          stream_item.data[i][8*j+:8]   = bytes[byte_index];
          stream_item.byte_enable[i][j] = '1;
        end
        else begin
          stream_item.data[i][8*j+:8]   = '0;
          stream_item.byte_enable[i][j] = '0;
        end
      end

      stream_item.delay[i]  = randomize_delay();
    end

    `uvm_send(stream_item)
  endtask

  protected function int randomize_delay();
    int delay;

    if (!std::randomize(delay) with {
      `pzvip_delay_constraint(delay, this.configuration.data_delay)
    }) begin
      `uvm_fatal("RNDFLD", "Randomization failed")
    end

    return delay;
  endfunction

  `tue_object_default_constructor(pzvip_stream_send_byte_stream_sequence)
  `uvm_object_utils_begin(pzvip_stream_send_byte_stream_sequence)
    `uvm_field_int(length, UVM_DEFAULT | UVM_DEC)
    `uvm_field_array_int(bytes, UVM_DEFAULT | UVM_HEX)
  `uvm_object_utils_end
endclass
