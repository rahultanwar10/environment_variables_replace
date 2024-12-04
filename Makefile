INPUT_CFG_DIR= input_cfg_dir
CSHRC_DIR= cshrc_dir
SCRIPT_DIR= scripts
OUTPUT_DIR= output

all: replace

replace: $(OUTPUT_DIR)/config.cfg

$(OUTPUT_DIR)/config.cfg: $(SCRIPT_DIR)/environment_variables.py $(INPUT_CFG_DIR)/config.cfg $(CSHRC_DIR)/proj_env.cshrc
	python3 $(word 1, $^) -cshrc_file $(word 3, $^) -config_file $(word 2, $^) -output $@

clean:
	rm -rf $(OUTPUT_DIR)/*