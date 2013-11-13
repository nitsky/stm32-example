BUILDDIR = build

DEVICE = stm32/device
CORE = stm32/core
PERIPH = stm32/periph
DISCOVERY = stm32/discovery
USB = stm32/usb

SOURCES += $(DISCOVERY)/src/stm32f3_discovery.c

SOURCES += $(PERIPH)/src/stm32f30x_gpio.c \
		   $(PERIPH)/src/stm32f30x_i2c.c \
		   $(PERIPH)/src/stm32f30x_rcc.c \
		   $(PERIPH)/src/stm32f30x_spi.c \
		   $(PERIPH)/src/stm32f30x_exti.c \
		   $(PERIPH)/src/stm32f30x_syscfg.c \
		   $(PERIPH)/src/stm32f30x_misc.c

SOURCES += startup_stm32f30x.s
SOURCES += stm32f30x_it.c
SOURCES += system_stm32f30x.c

SOURCES += main.c

OBJECTS = $(addprefix $(BUILDDIR)/, $(addsuffix .o, $(basename $(SOURCES))))

INCLUDES += -I$(DEVICE)/include \
			-I$(CORE)/include \
			-I$(PERIPH)/include \
			-I$(DISCOVERY)/include \
			-I$(USB)/include \
			-I\

ELF = $(BUILDDIR)/program.elf
HEX = $(BUILDDIR)/program.hex
BIN = $(BUILDDIR)/program.bin

CC = arm-none-eabi-gcc
LD = arm-none-eabi-gcc
AR = arm-none-eabi-ar
OBJCOPY = arm-none-eabi-objcopy
 	
CFLAGS  = -O0 -g -Wall -I.\
   -mcpu=cortex-m4 -mthumb \
   -mfpu=fpv4-sp-d16 -mfloat-abi=hard \
   $(INCLUDES) -DUSE_STDPERIPH_DRIVER

LDSCRIPT = stm32_flash.ld
LDFLAGS += -T$(LDSCRIPT) -mthumb -mcpu=cortex-m4 -nostdlib

$(BIN): $(ELF)
	$(OBJCOPY) -O binary $< $@

$(HEX): $(ELF)
	$(OBJCOPY) -O ihex $< $@

$(ELF): $(OBJECTS)
	$(LD) $(LDFLAGS) -o $@ $(OBJECTS) $(LDLIBS)

$(BUILDDIR)/%.o: %.c
	mkdir -p $(dir $@)
	$(CC) -c $(CFLAGS) $< -o $@

$(BUILDDIR)/%.o: %.s
	mkdir -p $(dir $@)
	$(CC) -c $(CFLAGS) $< -o $@

flash: $(BIN)
	st-flash write $(BIN) 0x8000000

clean:
	rm -rf build
