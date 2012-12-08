HOME=..
BUILD_DIR=$(HOME)/build
BUILD_IMG_DIR=$(BUILD_DIR)/images
BUILD_CSS_DIR=$(BUILD_DIR)/css


SRC_LESS_DIR=less
SRC_IMG_DIR=images

all:
	mkdir -p $(BUILD_DIR)
	echo "Copying static files..."
	mkdir -p $(BUILD_IMG_DIR)
	cp $(SRC_IMG_DIR)/* $(BUILD_IMG_DIR)/
	cp index.html $(BUILD_DIR)/
	echo "Copying static files done."
	echo "Compiling less..."
	mkdir -p $(BUILD_CSS_DIR)
	lessc $(SRC_LESS_DIR)/style.less > $(BUILD_CSS_DIR)/style.css
	echo "Compiling less done."

clean:
	rm -Rf $(BUILD_DIR)/*
