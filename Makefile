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

all: vectorAdd_sample matrixMul_sample

all_1: \
	vectorAdd_sample

all_2: \
	matrixMul_sample

all_3:	

vectorAdd_sample:
	$(call chdir,samples/0_simple/vectorAdd)
	JAVA_HEAP_SIZE=8096m $(EMCCDEBUG)=1 $(CC) $(MODE) \
		vectorAdd.cu \
	-I$(CUDA_ROOT)/include \
	-o ../../../build/$(PREFIX)cud_vectorAdd.js

matrixMul_sample:
	$(call chdir,samples/0_simple/matrixMul)
	JAVA_HEAP_SIZE=8096m $(EMCCDEBUG)=1 $(CC) $(MODE) \
		matrixMul.cu \
	-I$(CUDA_ROOT)/include \
	-I$(CUDA_ROOT)/samples/common/inc \
	-o ../../../build/$(PREFIX)cud_matrixMul.js

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

