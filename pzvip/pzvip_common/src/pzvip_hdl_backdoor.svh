`ifndef PZVIP_HDL_BACKDOOR_SVH
`define PZVIP_HDL_BACKDOOR_SVH
class pzvip_hdl_backdoor extends uvm_component;
  protected string  root_path;
  protected string  separator = ".";

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!(
      (root_path.len() > 0) || uvm_config_db #(string)::get(this, "", "root_path", root_path)
    )) begin
      `uvm_fatal(get_name(), "No root path is specified")
      return;
    end
    void'(uvm_config_db #(string)::get(this, "", "separator", separator));
  endfunction

  function string set_path(string path, string separator = ".");
    this.root_path  = path;
    this.separator  = separator;
  endfunction

  function bit check_path(string path);
    string  full_path = get_full_path(path);
    bit     result    = uvm_hdl_check_path(full_path);
    if (!result) begin
      `uvm_warning("HDL", $sformatf("unknown hdl path: %s", full_path))
    end
    return result;
  endfunction

  function void hdl_deposit(string path, uvm_hdl_data_t value);
    if (check_path(path)) begin
      void'(uvm_hdl_deposit(get_full_path(path), value));
    end
  endfunction

  function uvm_hdl_data_t hdl_read(string path);
    if (check_path(path)) begin
      uvm_hdl_data_t  value;
      void'(uvm_hdl_read(get_full_path(path), value));
      return value;
    end
    else begin
      return 0;
    end
  endfunction

  function void hdl_force(string path, uvm_hdl_data_t value);
    if (check_path(path)) begin
      void'(uvm_hdl_force(get_full_path(path), value));
    end
  endfunction

  function void hdl_release(string path);
    if (check_path(path)) begin
      void'(uvm_hdl_release(get_full_path(path)));
    end
  endfunction

  protected function string get_full_path(string path);
    return tue_concat_paths(root_path, path, separator);
  endfunction

  `tue_component_default_constructor(pzvip_hdl_backdoor)
  `uvm_component_utils(pzvip_hdl_backdoor)
endclass
`endif
