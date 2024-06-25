`ifndef PZVIP_MEMORY_SVH
`define PZVIP_MEMORY_SVH

localparam  int PZVIP_MEMORY_MAX_ADDRESS_WIDTH  =
  `ifdef  PZVIP_MEMORY_MAX_ADDRESS_WIDTH  `PZVIP_MEMORY_MAX_ADDRESS_WIDTH
  `else                                   64
  `endif;

localparam  int PZVIP_MEMORY_MAX_DATA_WIDTH =
  `ifdef  PZVIP_MEMORY_MAX_DATA_WIDTH `PZVIP_MEMORY_MAX_DATA_WIDTH
  `else                               512
  `endif;

class pzvip_memory_base extends uvm_object;
  localparam  int KEY_LSB   = $clog2(PZVIP_MEMORY_MAX_DATA_WIDTH / 8);
  localparam  int KEY_WIDTH = PZVIP_MEMORY_MAX_ADDRESS_WIDTH - KEY_LSB;

  typedef bit   [KEY_WIDTH-1:0]                       pzvip_memory_key;
  typedef bit   [PZVIP_MEMORY_MAX_ADDRESS_WIDTH-1:0]  pzvip_memory_address;
  typedef bit   [PZVIP_MEMORY_MAX_DATA_WIDTH-1:0]     pzvip_memory_data;
  typedef bit   [PZVIP_MEMORY_MAX_DATA_WIDTH/8-1:0]   pzvip_memory_byte_enable;
  typedef logic [PZVIP_MEMORY_MAX_DATA_WIDTH-1:0]     pzvip_memory_logic_data;

  protected pzvip_memory_data                       memory[pzvip_memory_key];
  protected int                                     default_word_width;
  protected logic [PZVIP_MEMORY_MAX_DATA_WIDTH-1:0] default_data;
  protected bit                                     default_data_valid;
  protected pzvip_pa_writer_base                    pa_writer;

  function new(string name = "pzvip_memory_base");
    super.new(name);
    default_word_width  = PZVIP_MEMORY_MAX_DATA_WIDTH / 8;
  endfunction

  function void set_default_data(logic [PZVIP_MEMORY_MAX_DATA_WIDTH-1:0] data);
    default_data_valid  = '1;
    default_data        = data;
  endfunction

  function void connect_pa_writer(pzvip_pa_writer_base pa_writer);
    this.pa_writer  = pa_writer;
  endfunction

  virtual function void put(
    pzvip_memory_data         data,
    pzvip_memory_byte_enable  byte_enable,
    pzvip_memory_address      base,
    int                       word_index  = 0,
    int                       word_width  = 0,
    bit                       backdoor    = 1
  );
    int                   width;
    pzvip_memory_address  address;
    pzvip_memory_key      key;
    int                   offset;
    pzvip_memory_data     write_data;

    width       = (word_width > 0) ? word_width : default_word_width;
    address     = base + width * word_index;
    key         = address[KEY_LSB+:KEY_WIDTH];
    offset      = get_offset(address, width);
    write_data  = get_memory_data(key);
    for (int i = 0;i < width;++i) begin
      if (byte_enable[i]) begin
        write_data[8*(offset+i)+:8] = data[8*i+:8];
      end
    end
    set_memory_data(key, write_data);

    if (pa_writer != null) begin
      pzvip_memory_data result;
      result  = shift_data(write_data, offset, width);
      pa_writer.memory_write_masked(address, data, byte_enable, result, backdoor);
    end
  endfunction

  virtual function pzvip_memory_logic_data get(
    pzvip_memory_address  base,
    int                   word_index  = 0,
    int                   word_width  = 0,
    bit                   backdoor    = 1
  );
    int                     width;
    pzvip_memory_address    address;
    pzvip_memory_key        key;
    int                     offset;
    pzvip_memory_logic_data data;

    width   = (word_width > 0) ? word_width : default_word_width;
    address = base + width * word_index;
    key     = address[KEY_LSB+:KEY_WIDTH];
    offset  = get_offset(address, width);
    data    = get_memory_data(key);
    data    = shift_data(data, offset, width);

    if (pa_writer != null) begin
      pa_writer.memory_read(address, data, backdoor);
    end

    return data;
  endfunction

  virtual function bit exists(
    pzvip_memory_address  base,
    int                   word_index  = 0,
    int                   word_width  = 0
  );
    int                   width;
    pzvip_memory_address  address;
    pzvip_memory_key      key;
    width   = (word_width > 0) ? word_width : default_word_width;
    address = base + width * word_index;
    key     = address[KEY_LSB+:KEY_WIDTH];
    return exist_memory_data(key);
  endfunction

  virtual function void clear();
    memory.delete();
  endfunction

  protected function int get_offset(pzvip_memory_address address, int width);
    bit [KEY_LSB-1:0] offset;
    bit [KEY_LSB-1:0] mask;
    offset  = address[0+:KEY_LSB];
    mask    = width - 1;
    return offset & (~mask);
  endfunction

  protected virtual function pzvip_memory_logic_data get_memory_data(pzvip_memory_key key);
    if (!exist_memory_data(key)) begin
      if (default_data_valid) begin
        return default_data;
      end
      else begin
        pzvip_memory_data data  = get_random_data();
        set_memory_data(key, data);
      end
    end

    return memory[key];
  endfunction

  protected virtual function void set_memory_data(pzvip_memory_key key, pzvip_memory_data data);
    memory[key] = data;
  endfunction

  protected virtual function bit exist_memory_data(pzvip_memory_key key);
    return memory.exists(key);
  endfunction

  protected function pzvip_memory_data get_random_data();
    if (PZVIP_MEMORY_MAX_DATA_WIDTH == 8) begin
      return $urandom_range(32'h0000_00FF);
    end
    else if (PZVIP_MEMORY_MAX_DATA_WIDTH == 16) begin
      return $urandom_range(32'h0000_FFFF);
    end
    else if (PZVIP_MEMORY_MAX_DATA_WIDTH == 32) begin
      return $urandom_range(32'hFFFF_FFFF);
    end
    else begin
      pzvip_memory_data data;
      for (int i = 0;i < PZVIP_MEMORY_MAX_DATA_WIDTH;i += 32) begin
        data[i+:32] = $urandom_range(32'hFFFF_FFFF);
      end
      return data;
    end
  endfunction

  protected function pzvip_memory_logic_data shift_data(
    pzvip_memory_logic_data data,
    int                     byte_offset,
    int                     byte_width
  );
    pzvip_memory_logic_data mask;
    pzvip_memory_logic_data result;
    mask    = (1 << (8 * byte_width)) - 1;
    result  = (data >> (8 * byte_offset)) & mask;
    return result;
  endfunction
endclass

class pzvip_memory #(
  type  CONFIGURATION = tue_configuration,
  type  STATUS        = tue_status
) extends tue_object_base #(
  .BASE           (pzvip_memory_base  ),
  .CONFIGURATION  (CONFIGURATION      ),
  .STATUS         (STATUS             )
);
  `tue_object_default_constructor(pzvip_memory)
endclass
`endif
