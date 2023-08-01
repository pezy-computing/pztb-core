`ifndef PZVIP_MEMORY_SVH
`define PZVIP_MEMORY_SVH
virtual class pzvip_memory #(
  type  CONFIGURATION = tue_configuration,
  type  STATUS        = tue_status,
  type  ADDRESS       = logic,
  type  DATA          = logic,
  type  BYTE_ENABLE   = logic
) extends tue_object_base #(
  .BASE           (uvm_object     ),
  .CONFIGURATION  (CONFIGURATION  ),
  .STATUS         (STATUS         )
);
  localparam  int ADDRESS_WIDTH = $bits(ADDRESS);
  localparam  int DATA_WIDTH    = $bits(DATA);
  localparam  int BYTE_WIDTH    = DATA_WIDTH / 8;
  localparam  int KEY_LSB       = $clog2(BYTE_WIDTH);
  localparam  int KEY_WIDTH     = ADDRESS_WIDTH - KEY_LSB;

  typedef bit [KEY_WIDTH-1:0]   pzvip_memory_key;
  typedef bit [DATA_WIDTH-1:0]  pzvip_memory_data;

  protected DATA                  default_data;
  protected bit                   default_data_valid;
  protected pzvip_memory_data     memory[ADDRESS];
  protected pzvip_pa_writer_base  pa_writer;

  function new(string name = "pzvip_memory");
    super.new(name);
  endfunction

  function void set_default_data(DATA data);
    default_data_valid  = '1;
    default_data        = data;
  endfunction

  function void connect_pa_writer(pzvip_pa_writer_base pa_writer);
    this.pa_writer  = pa_writer;
  endfunction

  virtual function void put(
    DATA        data,
    BYTE_ENABLE byte_enable,
    ADDRESS     base,
    int         word_index  = 0,
    int         word_width  = 0,
    bit         backdoor    = 1
  );
    int               width;
    ADDRESS           address;
    pzvip_memory_key  key;
    int               offset;
    pzvip_memory_data write_data;

    width       = (word_width > 0) ? word_width : get_default_word_width();
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
      result      = shift_data(write_data, offset, width);
      pa_writer.memory_write_masked(address, data, byte_enable, result, backdoor);
    end
  endfunction

  virtual function DATA get(
    ADDRESS base,
    int     word_index  = 0,
    int     word_width  = 0,
    bit     backdoor    = 1
  );
    int               width;
    ADDRESS           address;
    pzvip_memory_key  key;
    int               offset;
    pzvip_memory_data data;

    width   = (word_width > 0) ? word_width : get_default_word_width();
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
    ADDRESS base,
    int     word_index  = 0,
    int     word_width  = 0
  );
    int               width;
    ADDRESS           address;
    pzvip_memory_key  key;
    width   = (word_width > 0) ? word_width : get_default_word_width();
    address = base + width * word_index;
    key     = address[KEY_LSB+:KEY_WIDTH];
    return exist_memory_data(key);
  endfunction

  virtual function void clear();
    memory.delete();
  endfunction

  protected function int get_offset(ADDRESS address, int width);
    bit [KEY_LSB-1:0] offset;
    bit [KEY_LSB-1:0] mask;
    offset  = address[0+:KEY_LSB];
    mask    = width - 1;
    return offset & (~mask);
  endfunction

  protected virtual function pzvip_memory_data get_memory_data(pzvip_memory_key key);
    if (!exist_memory_data(key)) begin
      pzvip_memory_data data;

      if (default_data_valid) begin
        data  = default_data;
      end
      else begin
        data  = get_random_data();
      end

      set_memory_data(key, data);
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
    if (DATA_WIDTH == 8) begin
      return $urandom_range(32'h0000_00FF);
    end
    else if (DATA_WIDTH == 16) begin
      return $urandom_range(32'h0000_FFFF);
    end
    else if (DATA_WIDTH == 32) begin
      return $urandom_range(32'hFFFF_FFFF);
    end
    else begin
      pzvip_memory_data data;
      for (int i = 0;i < DATA_WIDTH;i += 32) begin
        data[i+:32] = $urandom_range(32'hFFFF_FFFF);
      end
      return data;
    end
  endfunction

  protected function DATA shift_data(
    DATA  data,
    int   byte_offset,
    int   byte_width
  );
    DATA  mask;
    DATA  result;
    mask    = (1 << (8 * byte_width)) - 1;
    result  = (data >> (8 * byte_offset)) & mask;
    return result;
  endfunction

  protected pure virtual function int get_default_word_width();
endclass
`endif
