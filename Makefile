#
#  Makefile
#
#  Created by Anthony Liot.
#  Copyright (c) 2013 Anthony Liot. All rights reserved.
#

CURRENT_ROOT:=$(PWD)/

ORIG=0
ifeq ($(ORIG),1)
EMSCRIPTEN_ROOT:=$(CURRENT_ROOT)../emscripten
else

$(info )
$(info )
$(info **************************************************************)
$(info **************************************************************)
$(info ************ /!\ BUILD USE SUBMODULE CARREFUL /!\ ************)
$(info **************************************************************)
$(info **************************************************************)
$(info )
$(info )

EMSCRIPTEN_ROOT:=$(CURRENT_ROOT)../webcl-translator/emscripten
endif

CUDA_ROOT:=/Developer/NVIDIA/CUDA-5.5/

CXX = $(EMSCRIPTEN_ROOT)/em++

CC = $(EMSCRIPTEN_ROOT)/emcc

CHDIR_SHELL := $(SHELL)
define chdir
   $(eval _D=$(firstword $(1) $(@D)))
   $(info $(MAKE): cd $(_D)) $(eval SHELL = cd $(_D); $(CHDIR_SHELL))
endef

DEB=0
VAL=0

ifeq ($(VAL),1)
PREFIX = val_
VALIDATOR = '[""]' # Enable validator without parameter
$(info ************  Mode VALIDATOR : Enabled ************)
else
PREFIX = 
VALIDATOR = '[]' # disable validator
$(info ************  Mode VALIDATOR : Disabled ************)
endif

DEBUG = -O0 -s DISABLE_EXCEPTION_CATCHING=0 -s WARN_ON_UNDEFINED_SYMBOLS=1 -s CU_DEBUG=1 -s CU_GRAB_TRACE=1 -s CU_PRINT_TRACE=1 

NO_DEBUG = -02 -s WARN_ON_UNDEFINED_SYMBOLS=0  -s CU_DEBUG=0 -s CU_GRAB_TRACE=0 -s CU_PRINT_TRACE=0

ifeq ($(DEB),1)
MODE=$(DEBUG)
EMCCDEBUG = EMCC_DEBUG
$(info ************  Mode DEBUG : Enabled ************)
else
MODE=$(NO_DEBUG)
EMCCDEBUG = EMCCDEBUG
$(info ************  Mode DEBUG : Disabled ************)
endif

$(info )
$(info )

#----------------------------------------------------------------------------------------#
#----------------------------------------------------------------------------------------#
# BUILD
#----------------------------------------------------------------------------------------#
#----------------------------------------------------------------------------------------#		

all: all_1 all_2 all_3

all_1: \
	vectorAdd_sample

all_2: \
	matrixMul_sample

all_3:	

vectorAdd_sample:
	$(call chdir,samples/0_simple/vectorAdd)
	JAVA_HEAP_SIZE=8096m $(EMCCDEBUG)=1 $(CXX) $(MODE) \
		vectorAdd.cu \
	-I$(CUDA_ROOT)/include \
	-o ../../../build/$(PREFIX)cud_vectorAdd.js

matrixMul_sample:
	$(call chdir,samples/0_simple/matrixMul)
	JAVA_HEAP_SIZE=8096m $(EMCCDEBUG)=1 $(CXX) $(MODE) \
		matrixMul.cu \
	-I$(CUDA_ROOT)/include \
	-I$(CUDA_ROOT)/samples/common/inc \
	-o ../../../build/$(PREFIX)cud_matrixMul.js

simpleTexture_sample:
	$(call chdir,samples/0_simple/simpleTexture)
	JAVA_HEAP_SIZE=8096m $(EMCCDEBUG)=1 $(CXX) $(MODE) \
		simpleTexture.cu \
	-I$(CUDA_ROOT)/include \
	-I$(CUDA_ROOT)/samples/common/inc \
	--preload-file data/lena_bw_out.pgm \
	--preload-file data/lena_bw.pgm \
	--preload-file data/ref_rotated.pgm \
	-o ../../../build/$(PREFIX)cud_simpleTexture.js

simpleCubemapTexture_sample:
	$(call chdir,samples/0_simple/simpleCubemapTexture)
	JAVA_HEAP_SIZE=8096m $(EMCCDEBUG)=1 $(CXX) $(MODE) \
		simpleCubemapTexture.cu \
	-I$(CUDA_ROOT)/include \
	-I$(CUDA_ROOT)/samples/common/inc \
	-o ../../../build/$(PREFIX)cud_simpleCubemapTexture.js

simplePrintf_sample:
	$(call chdir,samples/0_simple/simplePrintf)
	JAVA_HEAP_SIZE=8096m $(EMCCDEBUG)=1 $(CXX) $(MODE) \
		cuPrintf.cu \
		simplePrintf.cu \
	-I$(CUDA_ROOT)/include \
	-I$(CUDA_ROOT)/samples/common/inc \
	-o ../../../build/$(PREFIX)cud_simplePrintf.js

bandwidthTest_sample:
	$(call chdir,samples/1_Utilities/bandwidthTest)
	JAVA_HEAP_SIZE=8096m $(EMCCDEBUG)=1 $(CXX) $(MODE) \
		bandwidthTest.cu \
	-I$(CUDA_ROOT)/include \
	-I$(CUDA_ROOT)/samples/common/inc \
	-o ../../../build/$(PREFIX)cud_bandwidthTest.js

deviceQuery_sample:
	$(call chdir,samples/1_Utilities/deviceQuery)
	JAVA_HEAP_SIZE=8096m $(EMCCDEBUG)=1 $(CXX) $(MODE) \
		deviceQuery.cpp \
	-I$(CUDA_ROOT)/include \
	-I$(CUDA_ROOT)/samples/common/inc \
	-o ../../../build/$(PREFIX)cud_deviceQuery.js

deviceQueryDrv_sample:
	$(call chdir,samples/1_Utilities/deviceQueryDrv)
	JAVA_HEAP_SIZE=8096m $(EMCCDEBUG)=1 $(CXX) $(MODE) \
		deviceQueryDrv.cpp \
	-I$(CUDA_ROOT)/include \
	-I$(CUDA_ROOT)/samples/common/inc \
	-o ../../../build/$(PREFIX)cud_deviceQueryDrv.js

simpleGL_sample:
	$(call chdir,samples/2_Graphics/simpleGL)
	JAVA_HEAP_SIZE=8096m $(EMCCDEBUG)=1 $(CXX) $(MODE) \
		simpleGL.cpp \
	-I$(CUDA_ROOT)/include \
	-I$(CUDA_ROOT)/samples/common/inc \
	-o ../../../build/$(PREFIX)cud_simpleGL.js

bilateralFilter_sample:
	$(call chdir,samples/3_Imaging/simpleGL)
	JAVA_HEAP_SIZE=8096m $(EMCCDEBUG)=1 $(CXX) $(MODE) \
		bilateral_kernel.cu \
		bilateralFilter_cpu.cpp \
		bilateralFilter.cpp \
		bmploader.cpp \
	-I$(CUDA_ROOT)/include \
	-I$(CUDA_ROOT)/samples/common/inc \
	--preload-file data/nature_monte.bmp \
	--preload-file data/ref_05.ppm \
	--preload-file data/ref_06.ppm \
	--preload-file data/ref_07.ppm \
	--preload-file data/ref_08.ppm \
	-o ../../../build/$(PREFIX)cud_bilateralFilter.js

MonteCarloMultiGPU_sample:
	$(call chdir,samples/4_Finance/MonteCarloMultiGPU)
	JAVA_HEAP_SIZE=8096m $(EMCCDEBUG)=1 $(CXX) $(MODE) \
		MonteCarlo_gold.cpp \
		MonteCarlo_kernel.cu \
		MonteCarloMultiGPU.cpp \
		multithreading.cpp \
	-I$(CUDA_ROOT)/include \
	-I$(CUDA_ROOT)/samples/common/inc \
	-o ../../../build/$(PREFIX)cud_MonteCarloMultiGPU.js

fluidsGL_sample:
	$(call chdir,samples/5_Simulations/fluidsGL)
	JAVA_HEAP_SIZE=8096m $(EMCCDEBUG)=1 $(CXX) $(MODE) \
		fluidsGL_kernels.cu \
		fluidsGL.cpp \
	-I$(CUDA_ROOT)/include \
	-I$(CUDA_ROOT)/samples/common/inc \
	--preload-file data/ref_fluidsGL.ppm \
	-o ../../../build/$(PREFIX)cud_fluidsGL.js

oceanFFT_sample:
	$(call chdir,samples/5_Simulations/oceanFFT)
	JAVA_HEAP_SIZE=8096m $(EMCCDEBUG)=1 $(CXX) $(MODE) \
		oceanFFT_kernel.cu \
		oceanFFT.cpp \
	-I$(CUDA_ROOT)/include \
	-I$(CUDA_ROOT)/samples/common/inc \
	--preload-file data/ocean.frag \
	--preload-file data/ocean.vert \
	--preload-file data/reference.ppm \
	-o ../../../build/$(PREFIX)cud_oceanFFT.js

clean:
	$(call chdir,build/)
	rm -rf tmp/	
	mkdir tmp
	cp memoryprofiler.js tmp/
	cp settings.js tmp/
	rm -f *.data
	rm -f *.js
	rm -f *.map
	cp tmp/memoryprofiler.js ./
	cp tmp/settings.js ./
	rm -rf tmp/
	$(CXX) --clear-cache

