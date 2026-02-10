//磁盘页面结构： 

#ifndef _PAGE_H
#define _PAGE_H

class CPage
{
public:
	int m_nPageNumber,  //程序空间的页号
		m_nPageFaceNumber, //页框页
		m_nCounter,
		m_nTime;
};
#endif
