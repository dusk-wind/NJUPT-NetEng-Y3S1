#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define BLOCKSIZ		512		/* 磁盘块大小 */
#define NICFREE			10	        /* 空闲块堆栈可装入的物理块数 */
#define FILEBLK			25		/* 文件区占用磁盘块数 */
#define DATASTART		11 		/* 文件区开始块 */
/* 超级块数据结构 */
struct filsys
{
	unsigned int s_nfree;				/* 空闲盘块数 */
	unsigned short s_pfree;				/* 空闲盘块指针 */
	unsigned int s_free[NICFREE];		        /* 空闲盘块堆栈 */
};



