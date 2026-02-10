#include "file.h"

struct filsys filsys;					// 超级块数据结构  
FILE *fd;
// 写相应盘块号的数据函数：bwrite
void bwrite( unsigned int ino, unsigned int *  buf )
{
	fseek( fd, BLOCKSIZ * ino, SEEK_SET );
	fwrite( buf, 1, BLOCKSIZ, fd );
}
// 读相应盘块号的数据函数：bread 
void bread( unsigned int ino, unsigned int *  buf )
{	fseek( fd, BLOCKSIZ * ino, SEEK_SET );
	fread( buf, 1, BLOCKSIZ, fd );
}
void display()
{
	int i;
	unsigned int block_buf0[BLOCKSIZ ];
	printf("filsys.s_nfree:%d \n",filsys.s_nfree);
	printf("filsys.s_pfree:%d \n",filsys.s_pfree);
	printf("current free :%d# \n",filsys.s_free[filsys.s_pfree]);
	i=0;
	while ( i<=filsys.s_pfree && filsys.s_nfree>0)
	{	printf("filsys.s_free[%d]=%d \n",i,filsys.s_free[i] );
		i++;
	};
	int lastBlk=filsys.s_free[0];
	int free_block_num=NICFREE;
	while ( lastBlk>0 )
	{	bread( lastBlk, block_buf0 );
		free_block_num = block_buf0[NICFREE];	
		printf("lastBlk=%d# ,free_block_num=%d \n",lastBlk,free_block_num );
		for( i=0; i <free_block_num ; i++ )
		    printf("block_buf0[%d]=%d \n",i,block_buf0[i] );
		lastBlk=block_buf0[0];
		//if (lastBlk==0)
		    //printf("block_buf0[%d]=%d \n",free_block_num,block_buf0[free_block_num] );
	}  
}

// 命令解释层函数cmdexp()
char input_buf[20];		//命令行输入缓冲区
int over;			//命令行结束标记
// 取得命令函数：getcmd() 
void getcmd()
{	int i;
	i = 0;
	// 取得命令  
	while( !over )
	{	input_buf[i] = getchar();
		if( input_buf[i] == ' ' )
		{	if( i == 0 )					// 命令行的开始是空格，应舍去  
				i--;
			else
			{
				input_buf[i]='\0';
				break;
			}
		}
		else
			if( input_buf[i] == '\n' )
			{
				over = 1;
				input_buf[i]='\0';
				break;
			}
		i++;
	}
}

int cmdexp()
{	char buf[5];
	over = 0;
	// 显示命令提示行
	printf( "[@localhost]# ");
	// 读取用户输入  
	getcmd();
	if(( strcmp( input_buf, "alloc" ) == 0 ))
	{	//int num = balloc();
		printf( "%s: command not found\n", input_buf );
		//clearbuf();
		return 0;
	}
	if(( strcmp( input_buf, "bfree" ) == 0 ))
	{	if( over )
		{	printf( "bfree: too few arguments\n" );		// 命令参数不足  
			//clearbuf();
			return 0;
		}	
		getcmd();
		if( input_buf[0] == '\0' )
		{	printf( "bfree: too few arguments\n" );
			
			return 0;
		}
 		int num=atoi(input_buf);
		//bfree(num);
                                printf( "%s: command not found\n", input_buf );
		//clearbuf();
		return 0;
	}
	if(( strcmp( input_buf, "df" ) == 0 ))
	{	display();
		//clearbuf();
		return 0;
	}
	if( strcmp( input_buf, "exit" ) == 0 )
	{	printf( "%s: \n", "exit" );
		//clearbuf();
		return 1;
	}
	// 找不到该命令  
	if( input_buf[0] != '\0' )
	{
		printf( "%s: command not found\n", input_buf );
		//clearbuf();
	}
	return 0;
}


int main()  
{
	unsigned int block_buf1[BLOCKSIZ];
	char * buf;
	int i, j;
	fd = tmpfile();		// 建立文件  
	buf = (char * )malloc( (FILEBLK+DATASTART)*BLOCKSIZ );			// 申请1M空间  
	fseek( fd, 0, SEEK_SET );
	fwrite( buf, 1, (FILEBLK+DATASTART)*BLOCKSIZ , fd );
	free ( buf );
	// 初始化超级块  
	filsys.s_nfree = FILEBLK ;					// 空闲文件块数  
	// 初始化空闲盘块堆栈  
	// 把第1组空闲盘块放进空闲盘块堆栈  
	for( i = 0; i < NICFREE; i++ )
	   filsys.s_free[i] = NICFREE - i + DATASTART - 1;
	filsys.s_pfree = NICFREE - 1;		 // 当前空闲盘块堆栈指针  
	for( i = NICFREE * 2 - 1; i < FILEBLK; i += NICFREE )
	{
	   for( j = 0; j < NICFREE; j++ )
  	   {
  	      // 往缓冲区写与成组链接法组织空闲盘块有关的信息：下一组盘块空闲块号与块数  
		block_buf1[j] = i - j + DATASTART;   
	    }
	    block_buf1[NICFREE] = NICFREE;	// 该项记录本组的空闲盘块数  
            // 把缓冲区内容写到每组空闲盘块的最后一块中  
  	    bwrite( i - NICFREE + DATASTART, block_buf1 );
	}
	// 最后一组空闲盘块可能不足NICFREE块，故需单独处理  
	i = i - NICFREE;
	//printf("i=%d\n",i);
	block_buf1[0] = 0;
	for( j = 1; j < FILEBLK - i; j++ )
	  block_buf1[j] = FILEBLK - j + DATASTART;	
	block_buf1[NICFREE] = FILEBLK - i  ;		// 最末组的空闲盘块数  
        bwrite( i + DATASTART, block_buf1 );
	// 把超级块写入 block 1#  
	fseek( fd, BLOCKSIZ, SEEK_SET );
	fwrite( &filsys, 1, sizeof( struct filsys ), fd );
	while( cmdexp() == 0 )	{};		// 当用户quit时, cmdexp()返回1  
	fclose( fd );
	return 1;
}

