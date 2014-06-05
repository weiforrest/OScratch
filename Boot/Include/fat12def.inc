
%ifdef FAT_HEADER
BS_OEMName 		db		'WForrest' ;size must be 8
BPB_BytesPerSec dw		512		   ;bytes per sector
BPB_SecPerClus	db		1		   ;sector per cluster
BPB_RsvdSecCnt	dw		1		   ;how many sector used by boot record
BPB_NumFATS		db		2		   ;how many FAT table
BPB_ROOTEntCnt	dw		224		   ;the maximum number of file under the root
BPB_TotSec16	dw		2880	   ;count of logical sector(2*80*18)
BPB_Media		db		0xF0	   ;
BPB_FATSz16		dw		9		   ;sector per FAT
BPB_SecPerTrk	dw		18		   ;sector per track
BPB_NumHeads	dw		2		   ;count of disk head
BPB_HiddSec		dd		0		   ;count of hide sector
BPB_TotSec32	dd		0		   ;
BS_DrvNum		db		0		   ;interupt 13 drive number
BS_Reserved1	db		0		   ;
BS_BootSig		db		0x29	   ;extension boot sign
BS_VolID		dd		0		   ;
BS_VolLab		db		'wforrest0.1' ;size must be 11
BS_FileSysType	db		'FAT12   '	  ;size must be 8
%endif

SectorNoOfRootDirectory		equ		19 ;first Sector number of RootDir
RootDirSectors	equ 14			;BPB_RsvdSecCnt * 32(entry size) / 512
FATSize		equ 9				;sector per FAT
SectorNoOfFAT1 equ 1				;the first sector of FAT1
FileDataSectorNo equ (RootDirSectors + SectorNoOfRootDirectory - 2)
SecPerTrk equ 18
DrvNum	equ 0
