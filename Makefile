#
#  Makefile
#  Licence : https://github.com/wolfviking0/webcl-translator/blob/master/LICENSE
#
#  Created by Anthony Liot.
#  Copyright (c) 2013 Anthony Liot. All rights reserved.
#

# Default parameter
DEB = 0
VAL = 0
NAT = 0
ORIG= 0
FAST= 1

# Chdir function
CHDIR_SHELL := $(SHELL)
define chdir
   $(eval _D=$(firstword $(1) $(@D)))
   $(info $(MAKE): cd $(_D)) $(eval SHELL = cd $(_D); $(CHDIR_SHELL))
endef

# Current Folder
CURRENT_ROOT:=$(PWD)

# Current CUDA
CUDA_ROOT:=/Developer/NVIDIA/CUDA-5.5/

# Emscripten Folder
EMSCRIPTEN_ROOT:=$(CURRENT_ROOT)/../webcl-translator/emscripten

# Native build
ifeq ($(NAT),1)
$(info ************ NATIVE : CUDA             ************)

CXX = $(CUDA_ROOT)bin/nvcc
CC  = $(CUDA_ROOT)bin/nvcc

BUILD_FOLDER = $(CURRENT_ROOT)/bin/
EXTENSION = .out

ifeq ($(DEB),1)
$(info ************ NATIVE : DEBUG = 1        ************)

CFLAGS =

else
$(info ************ NATIVE : DEBUG = 0        ************)

CFLAGS = 

endif

# Emscripten build
else
ifeq ($(ORIG),1)
$(info ************ EMSCRIPTEN : SUBMODULE     = 0 ************)

EMSCRIPTEN_ROOT:=$(CURRENT_ROOT)/../emscripten
else
$(info ************ EMSCRIPTEN : SUBMODULE     = 1 ************)
endif

CXX = $(EMSCRIPTEN_ROOT)/em++
CC  = $(EMSCRIPTEN_ROOT)/emcc

BUILD_FOLDER = $(CURRENT_ROOT)/js/
EXTENSION = .js
GLOBAL =

ifeq ($(DEB),1)
$(info ************ EMSCRIPTEN : DEBUG         = 1 ************)

GLOBAL += EMCC_DEBUG=1

CFLAGS = -s OPT_LEVEL=1 -s DEBUG_LEVEL=1 -s CL_PRINT_TRACE=1 -s WARN_ON_UNDEFINED_SYMBOLS=1 -s CL_DEBUG=1 -s CL_GRAB_TRACE=1 -s CL_CHECK_VALID_OBJECT=1
else
$(info ************ EMSCRIPTEN : DEBUG         = 0 ************)

CFLAGS = -s OPT_LEVEL=3 -s DEBUG_LEVEL=0 -s CL_PRINT_TRACE=0 -s DISABLE_EXCEPTION_CATCHING=0 -s WARN_ON_UNDEFINED_SYMBOLS=1 -s CL_DEBUG=0 -s CL_GRAB_TRACE=0 -s CL_CHECK_VALID_OBJECT=0
endif

ifeq ($(VAL),1)
$(info ************ EMSCRIPTEN : VALIDATOR     = 1 ************)

PREFIX = val_

CFLAGS += -s CL_VALIDATOR=1
else
$(info ************ EMSCRIPTEN : VALIDATOR     = 0 ************)
endif

ifeq ($(FAST),1)
$(info ************ EMSCRIPTEN : FAST_COMPILER = 1 ************)

GLOBAL += EMCC_FAST_COMPILER=1
else
$(info ************ EMSCRIPTEN : FAST_COMPILER = 0 ************)
endif

endif

SOURCES_vectoradd		=	vectorAdd.cu
SOURCES_matrixmul		=	matrixMul.cu

INCLUDES_common			=	-I$(CUDA_ROOT)/include -I$(CUDA_ROOT)/samples/common/inc 

ifeq ($(NAT),0)

CFLAGS_vectoradd		=	
CFLAGS_matrixmul		=

endif

.PHONY:    
	all clean

all: \
	all_1 all_2 all_3

all_1: \
	vectoradd_sample matrixmul_sample

all_2: \
	

all_3: \
	

# Create build folder is necessary))
mkdir:
	mkdir -p $(BUILD_FOLDER);

vectoradd_sample: mkdir
	$(call chdir,samples/0_simple/vectorAdd/)
	$(GLOBAL) $(CXX) $(CFLAGS) $(CFLAGS_hello)			$(INCLUDES_common)		$(SOURCES_vectoradd)	-o $(BUILD_FOLDER)$(PREFIX)vectoradd$(EXTENSION) 

matrixmul_sample: mkdir
	$(call chdir,samples/0_simple/matrixMul/)
	$(GLOBAL) $(CXX) $(CFLAGS) $(CFLAGS_transpose)		$(INCLUDES_common)		$(SOURCES_matrixmul)	-o $(BUILD_FOLDER)$(PREFIX)matrixmul$(EXTENSION) 

clean:
	rm -rf bin/
	mkdir -p bin/
	mkdir -p tmp/
	cp js/memoryprofiler.js tmp/ && cp js/settings.js tmp/ && cp js/index.html tmp/
	rm -rf js/
	mkdir js/
	cp tmp/memoryprofiler.js js/ && cp tmp/settings.js js/ && cp tmp/index.html js/
	rm -rf tmp/
	$(EMSCRIPTEN_ROOT)/emcc --clear-cache

# simpleTexture_sample:
# 	$(call chdir,samples/0_simple/simpleTexture)
# 	JAVA_HEAP_SIZE=8096m $(EMCCDEBUG)=1 $(CXX) $(MODE) \
# 		simpleTexture.cu \
# 	-I$(CUDA_ROOT)/include \
# 	-I$(CUDA_ROOT)/samples/common/inc \
# 	--preload-file data/lena_bw_out.pgm \
# 	--preload-file data/lena_bw.pgm \
# 	--preload-file data/ref_rotated.pgm \
# 	-o ../../../build/$(PREFIX)cud_simpleTexture.js

# simpleCubemapTexture_sample:
# 	$(call chdir,samples/0_simple/simpleCubemapTexture)
# 	JAVA_HEAP_SIZE=8096m $(EMCCDEBUG)=1 $(CXX) $(MODE) \
# 		simpleCubemapTexture.cu \
# 	-I$(CUDA_ROOT)/include \
# 	-I$(CUDA_ROOT)/samples/common/inc \
# 	-o ../../../build/$(PREFIX)cud_simpleCubemapTexture.js

# simplePrintf_sample:
# 	$(call chdir,samples/0_simple/simplePrintf)
# 	JAVA_HEAP_SIZE=8096m $(EMCCDEBUG)=1 $(CXX) $(MODE) \
# 		cuPrintf.cu \
# 		simplePrintf.cu \
# 	-I$(CUDA_ROOT)/include \
# 	-I$(CUDA_ROOT)/samples/common/inc \
# 	-o ../../../build/$(PREFIX)cud_simplePrintf.js

# bandwidthTest_sample:
# 	$(call chdir,samples/1_Utilities/bandwidthTest)
# 	JAVA_HEAP_SIZE=8096m $(EMCCDEBUG)=1 $(CXX) $(MODE) \
# 		bandwidthTest.cu \
# 	-I$(CUDA_ROOT)/include \
# 	-I$(CUDA_ROOT)/samples/common/inc \
# 	-o ../../../build/$(PREFIX)cud_bandwidthTest.js

# deviceQuery_sample:
# 	$(call chdir,samples/1_Utilities/deviceQuery)
# 	JAVA_HEAP_SIZE=8096m $(EMCCDEBUG)=1 $(CXX) $(MODE) \
# 		deviceQuery.cpp \
# 	-I$(CUDA_ROOT)/include \
# 	-I$(CUDA_ROOT)/samples/common/inc \
# 	-o ../../../build/$(PREFIX)cud_deviceQuery.js

# deviceQueryDrv_sample:
# 	$(call chdir,samples/1_Utilities/deviceQueryDrv)
# 	JAVA_HEAP_SIZE=8096m $(EMCCDEBUG)=1 $(CXX) $(MODE) \
# 		deviceQueryDrv.cpp \
# 	-I$(CUDA_ROOT)/include \
# 	-I$(CUDA_ROOT)/samples/common/inc \
# 	-o ../../../build/$(PREFIX)cud_deviceQueryDrv.js

# simpleGL_sample:
# 	$(call chdir,samples/2_Graphics/simpleGL)
# 	JAVA_HEAP_SIZE=8096m $(EMCCDEBUG)=1 $(CXX) $(MODE) \
# 		simpleGL.cpp \
# 	-I$(CUDA_ROOT)/include \
# 	-I$(CUDA_ROOT)/samples/common/inc \
# 	-o ../../../build/$(PREFIX)cud_simpleGL.js

# bilateralFilter_sample:
# 	$(call chdir,samples/3_Imaging/simpleGL)
# 	JAVA_HEAP_SIZE=8096m $(EMCCDEBUG)=1 $(CXX) $(MODE) \
# 		bilateral_kernel.cu \
# 		bilateralFilter_cpu.cpp \
# 		bilateralFilter.cpp \
# 		bmploader.cpp \
# 	-I$(CUDA_ROOT)/include \
# 	-I$(CUDA_ROOT)/samples/common/inc \
# 	--preload-file data/nature_monte.bmp \
# 	--preload-file data/ref_05.ppm \
# 	--preload-file data/ref_06.ppm \
# 	--preload-file data/ref_07.ppm \
# 	--preload-file data/ref_08.ppm \
# 	-o ../../../build/$(PREFIX)cud_bilateralFilter.js

# MonteCarloMultiGPU_sample:
# 	$(call chdir,samples/4_Finance/MonteCarloMultiGPU)
# 	JAVA_HEAP_SIZE=8096m $(EMCCDEBUG)=1 $(CXX) $(MODE) \
# 		MonteCarlo_gold.cpp \
# 		MonteCarlo_kernel.cu \
# 		MonteCarloMultiGPU.cpp \
# 		multithreading.cpp \
# 	-I$(CUDA_ROOT)/include \
# 	-I$(CUDA_ROOT)/samples/common/inc \
# 	-o ../../../build/$(PREFIX)cud_MonteCarloMultiGPU.js

# fluidsGL_sample:
# 	$(call chdir,samples/5_Simulations/fluidsGL)
# 	JAVA_HEAP_SIZE=8096m $(EMCCDEBUG)=1 $(CXX) $(MODE) \
# 		fluidsGL_kernels.cu \
# 		fluidsGL.cpp \
# 	-I$(CUDA_ROOT)/include \
# 	-I$(CUDA_ROOT)/samples/common/inc \
# 	--preload-file data/ref_fluidsGL.ppm \
# 	-o ../../../build/$(PREFIX)cud_fluidsGL.js

# oceanFFT_sample:
# 	$(call chdir,samples/5_Simulations/oceanFFT)
# 	JAVA_HEAP_SIZE=8096m $(EMCCDEBUG)=1 $(CXX) $(MODE) \
# 		oceanFFT_kernel.cu \
# 		oceanFFT.cpp \
# 	-I$(CUDA_ROOT)/include \
# 	-I$(CUDA_ROOT)/samples/common/inc \
# 	--preload-file data/ocean.frag \
# 	--preload-file data/ocean.vert \
# 	--preload-file data/reference.ppm \
# 	-o ../../../build/$(PREFIX)cud_oceanFFT.js

# clean:
# 	$(call chdir,build/)
# 	rm -rf tmp/	
# 	mkdir tmp
# 	cp memoryprofiler.js tmp/
# 	cp settings.js tmp/
# 	rm -f *.data
# 	rm -f *.js
# 	rm -f *.map
# 	cp tmp/memoryprofiler.js ./
# 	cp tmp/settings.js ./
# 	rm -rf tmp/
# 	$(CXX) --clear-cache

