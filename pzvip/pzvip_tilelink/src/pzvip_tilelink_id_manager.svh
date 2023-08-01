`ifndef PZVIP_TILELINK_ID_MANAGER_SVH
`define PZVIP_TILELINK_ID_MANAGER_SVH
class pzvip_tilelink_id_manager extends tue_object_base #(
  .BASE           (uvm_object                   ),
  .CONFIGURATION  (pzvip_tilelink_configuration ),
  .STATUS         (pzvip_tilelink_status        )
);
  protected pzvip_tilelink_id id_pool[$];
  protected semaphore         id_semaphore;
  protected pzvip_tilelink_id id_mask;

  virtual function void set_configuration(tue_configuration configuration);
    super.set_configuration(configuration);
    initialize_id();
  endfunction

  local function void initialize_id();
    int number_of_tags  = 2**configuration.tag_width;
    id_mask       = number_of_tags - 1;
    id_semaphore  = new(number_of_tags);
    for (int i = 0;i < number_of_tags;++i) begin
      id_pool.push_back(i);
    end
    id_pool.shuffle();
  endfunction

  task get(
    ref   pzvip_tilelink_id id,
    input int               base_id = -1
  );
    id_semaphore.get(1);
    id  = id_pool.pop_front
        | ((base_id >= 0) ? base_id : configuration.base_id);
  endtask

  function void put(pzvip_tilelink_id id);
    id_pool.push_back(id & id_mask);
    id_semaphore.put(1);
  endfunction

  `tue_object_default_constructor(pzvip_tilelink_id_manager)
endclass
`endif
