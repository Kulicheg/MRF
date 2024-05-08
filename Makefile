ifeq ($(OS),Windows_NT)
SOURCES=$(shell cmdfind.bat asm) $(shell cmdfind.bat gph)
SJASMPLUS="../../tools/sjasmplus.exe"
else
SOURCES=$(shell find . -type f -iname  "*.asm") $(shell find . -type f -iname  "*.gph")
SJASMPLUS="sjasmplus"
endif
BINARY=moon.bin moon.com
LST=main.lst
VERSION="17"
BUILD = $(shell type version.txt)
all: 
	@echo "For making NedoOS version call: 'make nedoos'"
	@echo "For making NedoOS(ATM UART) version call: 'make nedoosatm'"
	@echo "For making NedoOS(EVO UART) version call: 'make nedoosevo'"
	@echo "For making TR-DOS(ATM UART) version call: 'make atmtrdos'"
	@echo "For making TR-DOS(AY+6912) version call: 'make aytrdos'"
	@echo "For making TR-DOS(AY+TIMEX80) version call: 'make t80trdos'"
	@echo "For making MSX VERSION(B.C.WiFi) version call: 'make msx'"
	@echo ""
	@echo "Before changing version call: 'make clean' for removing builded images"
	
nedoos: $(SOURCES)
	$(SJASMPLUS) main.asm -DRTC -DNEDOOS -DNEDONET -DGS --lst=main.lst -DV=$(VERSION) -DBLD=$(BUILD) -DBINNAME="\"mrf.com\""

nedoosatm: $(SOURCES)
	$(SJASMPLUS) main.asm -DRTC -DNEDOOS -DUARTATM -DGS --lst=main.lst -DV=$(VERSION) -DBLD=$(BUILD) -DBINNAME="\"mrfua.com\""

nedoosevo: $(SOURCES)
	$(SJASMPLUS) main.asm -DRTC -DNEDOOS  -DUARTEVO -DGS --lst=main.lst -DV=$(VERSION) -DBLD=$(BUILD) -DBINNAME="\"mrfue.com\""

atmtrdos: $(SOURCES)
	$(SJASMPLUS) main.asm -DTRDOS -DUARTATM -DZXSCR -DGS --lst=main.lst -DV=$(VERSION) -DBLD=$(BUILD) -DBINNAME="\"ATM-64.C\""

evotrdos: $(SOURCES)
	$(SJASMPLUS) main.asm -DTRDOS -DUARTEVO -DZXSCR -DGS --lst=main.lst -DV=$(VERSION) -DBLD=$(BUILD) -DBINNAME="\"EVO-64.C\""

aytrdos: $(SOURCES)
	$(SJASMPLUS) main.asm -DTRDOS -DAY -DZXSCR -DGS --lst=main.lst -DV=$(VERSION) -DBLD=$(BUILD) -DBINNAME="\"AY-64.C\""

ay56trdos: $(SOURCES)
	$(SJASMPLUS) main.asm -DTRDOS -DAY56 -DZXSCR -DGS --lst=main.lst -DV=$(VERSION) -DBLD=$(BUILD) -DBINNAME="\"AY56-64.C\""

aytrsmuc: $(SOURCES)
	$(SJASMPLUS) main.asm -DTRDOS -DRTC -DSMUCRTC -DAY -DZXSCR -DGS --lst=main.lst -DV=$(VERSION) -DBLD=$(BUILD) -DBINNAME="\"AY-64-SC.C\""

zwtrdos: $(SOURCES)
	$(SJASMPLUS) main.asm -DTRDOS -DZW -DZXSCR -DGS --lst=main.lst -DV=$(VERSION) -DBLD=$(BUILD) -DBINNAME="\"ZW-64.C\""

zwtrsmuc: $(SOURCES)
	$(SJASMPLUS) main.asm -DTRDOS -DRTC -DSMUCRTC -DZW -DZXSCR -DGS --lst=main.lst -DV=$(VERSION) -DBLD=$(BUILD) -DBINNAME="\"ZW-64-SC.C\""

t80trdos: $(SOURCES)
	$(SJASMPLUS) main.asm -DTRDOS -DAY -DTIMEX80 -DGS --lst=main.lst -DV=$(VERSION) -DBLD=$(BUILD) -DBINNAME="\"AY-80.C\""

truno64: $(SOURCES)
	$(SJASMPLUS) main.asm -DTRDOS -DUNOUART -DZXSCR --lst=main.lst -DV=$(VERSION) -DBLD=$(BUILD) -DBINNAME="\"UN-64.C\""

msx: $(SOURCES)
	$(SJASMPLUS) main.asm -DMSX -DRTC --lst=main.lst -DV=$(VERSION) -DBLD=$(BUILD) -DBINNAME="\"mrfmsx.com\""
	copy DATA\msxfont.bin MSX\font.bin
	copy DATA\msxindex.gph MSX\index.gph
	move mrfmsx.com MSX\mrfmsx.com

godzilla: $(SOURCES)
	$(SJASMPLUS) main.asm -DNOINIT -DTRDOS -DAY56 -DZXSCR -DGS --lst=main.lst -DV=$(VERSION) -DBLD=$(BUILD) -DBINNAME="\"UN-64.C\""	
clean:
	rm $(BINARY) $(LST)