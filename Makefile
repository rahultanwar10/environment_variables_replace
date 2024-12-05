INPUT_CFG_DIR= input_cfg_dir
CSHRC_DIR= cshrc_dir
SCRIPT_DIR= scripts
OUTPUT_DIR= output

INPUT_FILES = $(shell find $(INPUT_CFG_DIR) -type f)

all: process

process:
	for file in $(INPUT_FILES); do \
		output_file=$(OUTPUT_DIR)/$$(echo $$file | sed "s|$(INPUT_CFG_DIR)/||"); \
		python3 $(SCRIPT_DIR)/environment_variables.py -cshrc_file $(CSHRC_DIR)/proj_env.cshrc -config_file $$file -output $$output_file; \
	done
# process:
# 	for file in $(INPUT_FILES); do \
# 		output_file=$(OUTPUT_DIR)/$$(echo $$file | sed "s|$(INPUT_CFG_DIR)/||"); \
# 		echo "Checking out the file"; \
# 		# dssc co $$output_file; \
# 		# mkdir -p $$(dirname $$output_file); \
# 		python3 $(SCRIPT_DIR)/environment_variables.py -cshrc_file $(CSHRC_DIR)/proj_env.cshrc -config_file $$file -output $$output_file; \
# 		echo "Checking in the file"; \
# 		dssc ci -noco $$output_file; \
# 	done

# process: $(OUTPUT_DIR)/config.cfg

# $(OUTPUT_DIR)/config.cfg: $(SCRIPT_DIR)/environment_variables.py $(INPUT_CFG_DIR)/config.cfg $(CSHRC_DIR)/proj_env.cshrc
# 	python3 $(word 1, $^) -cshrc_file $(word 3, $^) -config_file $(word 2, $^) -output $@

clean:
	rm -rf $(OUTPUT_DIR)/*