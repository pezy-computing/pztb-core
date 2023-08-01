class pzvip_stream_send_file_stream_sequence extends pzvip_stream_sequence;
  string  file_name;

  task body();
    int                                     fd;
    int                                     size;
    pzvip_stream_send_byte_stream_sequence  send_byte_stream_sequence;

    fd  = $fopen(file_name, "r");
    if (fd == 0) begin
      `uvm_fatal(get_name(), $sformatf("cannot open such file: %s", file_name))
      return;
    end

    `uvm_create(send_byte_stream_sequence)
    size                              = get_size(fd);
    send_byte_stream_sequence.length  = size;
    send_byte_stream_sequence.bytes   = new[size];
    foreach (send_byte_stream_sequence.bytes[i]) begin
      send_byte_stream_sequence.bytes[i]  = $fgetc(fd);
    end

    $fclose(fd);
    `uvm_send(send_byte_stream_sequence)
  endtask

  protected function int get_size(int fd);
    int size;
    void'($fseek(fd, 0, 2));
    size  = $ftell(fd);
    void'($rewind(fd));
    return size;
  endfunction

  `tue_object_default_constructor(pzvip_stream_send_file_stream_sequence)
  `uvm_object_utils(pzvip_stream_send_file_stream_sequence)
endclass
