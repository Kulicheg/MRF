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
	@echo "For making MB03 version call: 'make mb03'"
	@echo "For making ZXUno(esxDOS) version call: 'make zxuno'"
	@echo "For making ZXUno(esxDOS, usual screen) version call: 'make zxuno-zxscreen'"
	@echo "For making Ay-Wifi(esxDOS) version call: make esxdos-ay"
	@echo "For making NedoOS version call: 'make nedoos'"
	@echo "For making NedoOS(ATM UART) version call: 'make nedoosatm'"
	@echo "For making NedoOS(EVO UART) version call: 'make nedoosevo'"
	@echo "For making TR-DOS(ATM UART) version call: 'make atmtrdos'"
	@echo "For making TR-DOS(AY+6912) version call: 'make aytrdos'"
	@echo "For making TR-DOS(AY+TIMEX80) version call: 'make t80trdos'"
	@echo "For making MSX VERSION(B.C.WiFi) version call: 'make msx'"
	@echo ""
	@echo "Before changing version call: 'make clean' for removing builded images"
	
mb03: $(SOURCES)
	$(SJASMPLUS) main.asm -DPROXY -DMB03 -DTIMEX -DGS --lst=main.lst -DV=$(VERSION) -DBLD=$(BUILD)
	
zxuno: $(SOURCES)
	$(SJASMPLUS) main.asm -DP3DOS -DUNO -DTIMEX --lst=main.lst -DV=$(VERSION) -DBLD=$(BUILD)

zxuno-zxscreen: $(SOURCES)
	$(SJASMPLUS) main.asm -DP3DOS -DUNO -DZXSCR --lst=main.lst -DV=$(VERSION) -DBLD=$(BUILD)

esxdos-ay: $(SOURCES)
	$(SJASMPLUS) main.asm -DAY -DZXSCR --lst=main.lst -DV=$(VERSION) -DBLD=$(BUILD)
	
nedoos: $(SOURCES)
	$(SJASMPLUS) main.asm -DNEDOOS -DNEDONET -DGS --lst=main.lst -DV=$(VERSION) -DBLD=$(BUILD)

nedoosatm: $(SOURCES)
	$(SJASMPLUS) main.asm -DNEDOOS -DNEDOOSATM -DAUTH -DGS --lst=main.lst -DV=$(VERSION) -DBLD=$(BUILD)

nedoosevo: $(SOURCES)
	$(SJASMPLUS) main.asm -DNEDOOS  -DNEDOOSEVO -DAUTH -DGS --lst=main.lst -DV=$(VERSION) -DBLD=$(BUILD)

atmtrdos: $(SOURCES)
	copy Sample.trd MOONR.TRD
	$(SJASMPLUS) main.asm -DTRDOS -DNEDOOSATM -DZXSCR -DAUTH -DGS --lst=main.lst -DV=$(VERSION) -DBLD=$(BUILD)
	del TRD\MR-TR-AU-64.TRD
	move MOONR.TRD TRD\MR-TR-AU-64.TRD

evotrdos: $(SOURCES)
	copy Sample.trd MOONR.TRD
	$(SJASMPLUS) main.asm -DTRDOS -DNEDOOSEVO -DZXSCR -DAUTH -DGS --lst=main.lst -DV=$(VERSION) -DBLD=$(BUILD)
	del TRD\MR-TR-EU-64.TRD
	move MOONR.TRD TRD\MR-TR-EU-64.TRD

aytrdos: $(SOURCES)
	copy Sample.trd MOONR.TRD
	$(SJASMPLUS) main.asm -DTRDOS -DAY -DZXSCR -DAUTH -DGS --lst=main.lst -DV=$(VERSION) -DBLD=$(BUILD)
	del TRD\MR-TR-AY-64.TRD
	move MOONR.TRD TRD\MR-TR-AY-64.TRD

zwtrdos: $(SOURCES)
	copy Sample.trd MOONR.TRD
	$(SJASMPLUS) main.asm -DTRDOS -DZW -DZXSCR -DAUTH -DGS --lst=main.lst -DV=$(VERSION) -DBLD=$(BUILD)
	del TRD\MR-TR-ZW-64.TRD
	move MOONR.TRD TRD\MR-TR-ZW-64.TRD

t80trdos: $(SOURCES)
	copy Sample.trd MOONR.TRD
	$(SJASMPLUS) main.asm -DTRDOS -DAY -DTIMEX80 -DAUTH -DGS --lst=main.lst -DV=$(VERSION) -DBLD=$(BUILD)
	del TRD\MR-TR-AY-80.TRD
	move MOONR.TRD TRD\MR-TR-AY-80.TRD

truno64: $(SOURCES)
	copy Sample.trd MOONR.TRD
	$(SJASMPLUS) main.asm -DTRDOS -DUNOUART -DZXSCR -DAUTH --lst=main.lst -DV=$(VERSION) -DBLD=$(BUILD)
	del TRD\MR-TR-UN-64.TRD
	move MOONR.TRD TRD\MR-TR-UN-64.TRD

ayp3d64: $(SOURCES)
	copy Sample.trd MOONR.TRD
	$(SJASMPLUS) main.asm -DP3DOS -DAY -DZXSCR -DGS --lst=main.lst -DV=$(VERSION) -DBLD=$(BUILD)
	del TRD\MR-P3-AY-64.TRD
	move MOONR.TRD TRD\MR-P3-AY-64.TRD

msx: $(SOURCES)
	$(SJASMPLUS) main.asm -DMSX --lst=main.lst -DV=$(VERSION) -DBLD=$(BUILD)
	copy DATA\msxfont.bin MSX\font.bin
	copy DATA\msxindex.gph MSX\index.gph
	move moonr.com MSX\moonr.com

clean:
	rm $(BINARY) $(LST)