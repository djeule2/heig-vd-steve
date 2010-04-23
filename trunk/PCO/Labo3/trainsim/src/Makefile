LIB=libtrainsim

C_SRCS=ctrain_handler
ADA_MSRC=train_handler
ADA_SRCS=tunnel
ADA_BSRC=b~$(ADA_MSRC)
OBJECTS=$(C_SRCS:=.o) $(ADA_MSRC:=.o) $(ADA_SRCS:=.o) $(ADA_BSRC:=.o) 

ADAC=gnatmake
ADAC_FLAGS=-c
ADAC_CFLAGS =-fPIC
ADAB=gnatbind
CC=gcc
CC_FLAGS=-c -fPIC

all: $(LIB)

$(LIB) : $(ADA_BSRC) $(C_SRCS)
	$(CC) -shared -o $(LIB).so $(OBJECTS)

$(ADA_BSRC) : $(ADA_MSRC)
	$(ADAC) $(ADAC_FLAGS) $@.adb -cargs $(ADAC_CFLAGS)

$(ADA_MSRC) :
	$(ADAC) $(ADAC_FLAGS) $@.adb -cargs $(ADAC_CFLAGS)
	$(ADAB) -n $@

$(C_SRCS) :
	$(CC) $(CC_FLAGS) $@.c

clean :
	rm *.o *.ali b~*.adb b~*.ads 
